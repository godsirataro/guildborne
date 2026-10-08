--!strict
-- Included ONLY by tools/prepare_private_market_acceptance.py, never default.project.json.
local Players=game:GetService('Players')
local Teleport=game:GetService('TeleportService')
local H=game:GetService('HttpService')
local Runtime=require(game.ServerScriptService.Server.Config.Runtime)
local qa=Runtime.PrivateAcceptance
assert(qa.Enabled and not game:GetService('RunService'):IsStudio())
assert(Runtime.AllowedDataStoreUniverses[game.GameId]=='staging')
local users={};for id in pairs(qa.UserIds) do table.insert(users,id) end;table.sort(users)
local namespace='qa45_'..qa.RunId
local evidence=game:GetService('DataStoreService'):GetDataStore('GB_Accept_'..namespace)
if game.PrivateServerId=='' then
	-- Dedicated QA lobby: main bootstrap refuses profile loads here. No normal saves touched.
	local codes={}
	for index,id in ipairs(users) do codes[id]=Teleport:ReserveServerAsync(game.PlaceId) end
	local function send(player: Player)
		if not qa.UserIds[player.UserId] then player:Kick('Private acceptance only');return end
		local options=Instance.new('TeleportOptions');options.ReservedServerAccessCode=codes[player.UserId]
		options:SetTeleportData({runId=qa.RunId,account=player.UserId})
		Teleport:TeleportAsync(game.PlaceId,{player},options)
	end
	Players.PlayerAdded:Connect(send);for _,p in Players:GetPlayers() do task.spawn(send,p) end
else
	assert(game.JobId~='','Live JobId required')
	local probe=Instance.new('BindableFunction');probe.Name='PrivateAcceptanceProbe';probe.Parent=game.ServerScriptService.Server
	probe.OnInvoke=function(action: string)
		if action=='DropProjection' then
			for _,side in ipairs({'BUY','SELL'}) do game:GetService('MemoryStoreService'):GetSortedMap('GBM:'..namespace..':iron_ore:'..side):RemoveAsync('depth') end
			return {namespace=namespace,jobId=game.JobId,removed='disposable iron_ore depth only'}
		end
		assert(action=='Evidence','InvalidAcceptanceAction')
		local options=Instance.new('DataStoreGetOptions');options.UseCache=false
		local store=game:GetService('DataStoreService'):GetDataStore('GB_Market_'..namespace)
		local profiles=game:GetService('DataStoreService'):GetDataStore('GB_Player_'..namespace)
		local rows={};for _,id in ipairs(users) do local p=profiles:GetAsync('p:'..id,options);rows[tostring(id)]={joins=evidence:GetAsync('account:'..id,options),profile=p} end
		return {namespace=namespace,jobId=game.JobId,book=store:GetAsync('b:iron_ore:1',options),profiles=rows}
	end
	local function record(player: Player)
		if not qa.UserIds[player.UserId] then return end
		local key='account:'..player.UserId
		evidence:UpdateAsync(key,function(old)
			local rows=old or {};table.insert(rows,{jobId=game.JobId,privateId=game.PrivateServerId,at=os.time(),place=game.PlaceId,namespace=namespace})
			while #rows>20 do table.remove(rows,1) end;return rows
		end)
		print('[PrivateMarketAcceptance] '..H:JSONEncode({account=player.UserId,jobId=game.JobId,namespace=namespace}))
	end
	Players.PlayerAdded:Connect(record);for _,p in Players:GetPlayers() do task.spawn(record,p) end
	-- Operator APIs stay server-only; no test remote grants currency or modifies price.
end
