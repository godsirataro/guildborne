--!strict
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Replicated=game:GetService("ReplicatedStorage")
return function(deps: any)
	local c=deps.Config;local util=deps.Util
	local epochs=require(script.Parent.Parent.Systems.MarketEpochs)(c,util,deps.Orders,require(script.Parent.Parent.Systems.MarketMatching)(c,deps.Orders),require(script.Parent.Parent.Systems.MarketBook),deps.MarketData)
	local adapter: any
	if Run:IsStudio() and deps.Runtime.StudioPersistence=="Memory" then
		local values: any={}
		adapter={Store={Read=function(k: string) return util.copy(values[k]) end,Update=function(k: string,f: any)
			local v=f(util.copy(values[k]));if v then values[k]=util.copy(v) end;return util.copy(v)
		end},Changed=function() end,Health={durable="Studio memory",index="Simulation",messages="Simulation"},Metrics={}}
	else
		local env=require(script.Parent.Parent.Systems.MarketNamespace)(deps.Runtime.AllowedDataStoreUniverses[game.GameId] or "",Run:IsStudio(),game.PrivateServerId~="",c)
		if not env or (Run:IsStudio() and env=="prod") then
			adapter={Store={Read=function() error("MarketNotConfigured") end,Update=function() error("MarketNotConfigured") end},Changed=function() end,Health={durable="Unavailable"},Metrics={}}
		else
			-- Match the profile environment; splitting book/profile environments would
			-- make a persisted reservation refer to the wrong market after rejoin.
			-- Destructive Studio QA uses Memory; cloud probes pass isolated names directly.
			local namespace=require(script.Parent.Parent.Systems.MarketAcceptanceConfig)(deps.Runtime.PrivateAcceptance,env,Run:IsStudio(),game.PrivateServerId~="") or env
			adapter=require(script.Parent.Parent.Persistence.MarketCloud)(namespace,c,deps.Orders)
			task.spawn(adapter.Subscribe)
		end
	end
	local service=require(script.Parent.MarketService)({Config=c,Util=util,Data=deps.Data,Escrow=deps.Escrow,Orders=deps.Orders,
		Book=epochs,Epochs=epochs,MarketData=deps.MarketData,Store=adapter.Store,ReadProfile=deps.ReadProfile,Changed=adapter.Changed,Now=os.time})
	local remote=Instance.new("RemoteEvent");remote.Name="Market";remote.Parent=Replicated:WaitForChild("GuildborneRemotes")
	local buckets: any={};local busy: any={};local metrics={requests=0,rejected=0}
	local protocol=require(script.Parent.Parent.Systems.MarketProtocol)(c,deps.Orders)
	remote.OnServerEvent:Connect(function(player: Player,p: any)
		metrics.requests+=1
		local now=os.clock();local b=buckets[player] or {at=now,tokens=4};buckets[player]=b
		if not protocol.accept(b,now) or busy[player] then metrics.rejected+=1;remote:FireClient(player,protocol.busyResponse(p));return end
		if not protocol.valid(p) then metrics.rejected+=1;remote:FireClient(player,protocol.errorResponse(p,"InvalidRequest"));return end
		busy[player]=true
		local ok,result=pcall(function()
			local code="OK"
			if adapter.Breaker and not adapter.Breaker.allow() and (p.action=="Create" or p.action=="Cancel" or p.action=="Claim") then error("MarketCircuitOpen") end
			if p.action=="Create" then code=service.Create(player.UserId,p.requestId,p.order,p.epoch)
			elseif p.action=="Cancel" then code=service.Cancel(player.UserId,p.itemId,p.orderId)
			elseif p.action=="Claim" then code=service.RecoverPlayer(player.UserId,p.itemId) end
			if code~="OK" then metrics.rejected+=1 end
			if adapter.Breaker and (code=="SavePending" or code=="AuditBacklog") then adapter.Breaker.failed(code) end
			if Run:IsStudio() and p.action~="Read" and p.action~="Portfolio" then print("[MarketTransition] "..game:GetService("HttpService"):JSONEncode({operationId=p.requestId,itemId=p.itemId,epoch=p.epoch,action=p.action,code=code,jobId=game.JobId})) end
			local view=service.Read(player.UserId,p.itemId,p.period or "1D")
			local r=deps.Data.Sessions[player.UserId].record
			local portfolioOrders,portfolioHistory={},{}
			if p.action=="Portfolio" then
				for itemId in pairs(c.Items) do
					local own=service.Read(player.UserId,itemId,p.period or "1D")
					for _,o in ipairs(own.orders) do o.itemId=itemId;table.insert(portfolioOrders,o) end
					for _,t in ipairs(own.history) do t.itemId=itemId;table.insert(portfolioHistory,t) end
				end
				table.sort(portfolioOrders,function(a: any,b: any) return a.createdAt>b.createdAt end)
				table.sort(portfolioHistory,function(a: any,b: any) return a.at>b.at end)
				while #portfolioOrders>c.HistoryLimit do table.remove(portfolioOrders) end
				while #portfolioHistory>c.HistoryLimit do table.remove(portfolioHistory) end
			end
			return {code=code,view=view,portfolioOrders=if p.action=="Portfolio" then portfolioOrders else nil,portfolioHistory=if p.action=="Portfolio" then portfolioHistory else nil,gold=r.data.currencies.gold,owned=r.data.inventory.stacks[p.itemId] or 0,feeBps=c.FeeBps,
				language=r.data.settings.language or "en",catalog=deps.Catalog,requestId=p.requestId}
		end)
		busy[player]=nil
		if player.Parent==Players then remote:FireClient(player,if ok then result else {code="MarketUnavailable",requestId=p.requestId});deps.Network.Send(player) end
		if not ok then warn("[Guildborne Market] request deferred: "..tostring(result)) end
		deps.Data.FlushAudit(player.UserId)
	end)
	Players.PlayerRemoving:Connect(function(p) buckets[p]=nil;busy[p]=nil end)
	-- Fixed allowlist, one item per tick. No continuous worldwide order scan.
	local items={};for item in pairs(c.Items) do table.insert(items,item) end;table.sort(items)
	task.spawn(function()
		local cursor=0
		while true do
			task.wait(c.RecoverySeconds);cursor=cursor%#items+1;local item=items[cursor]
			if adapter.CanMaintain and not adapter.CanMaintain() then continue end
			pcall(service.RecoverBook,item)
			for _,player in ipairs(Players:GetPlayers()) do
				if not busy[player] then
					busy[player]=true;pcall(service.RecoverPlayer,player.UserId,item);busy[player]=nil
					deps.Network.Send(player);deps.Data.FlushAudit(player.UserId)
				end
			end
		end
	end)
	local api={Service=service,Adapter=adapter,Metrics=metrics}
	-- Server-only capability; no RemoteEvent/RemoteFunction exposes operator methods.
	local ops=Instance.new("BindableFunction");ops.Name="MarketOperations";ops.Parent=script.Parent.Parent
	local allowed=Run:IsStudio() or (game.PrivateServerId~="" and deps.Runtime.AllowedDataStoreUniverses[game.GameId]=="staging")
	ops.OnInvoke=function(action: string,item: string,args: any)
		assert(allowed,"OperatorDisabled")
		local result=service.Operator(action,item,args)
		result.adapterHealth=util.copy(adapter.Health);result.adapterMetrics=util.copy(adapter.Metrics)
		result.circuitBreakerState=if adapter.Breaker then adapter.Breaker.state else "HEALTHY"
		result.rejectedAdmissionCount=metrics.rejected
		print("[MarketOps] "..game:GetService("HttpService"):JSONEncode({jobId=game.JobId,action=action,item=item,result=result}))
		return result
	end
	return api
end
