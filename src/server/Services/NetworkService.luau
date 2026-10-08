--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(deps: any)
	local folder = Instance.new("Folder"); folder.Name = "GuildborneRemotes"
	local command = Instance.new("RemoteEvent"); command.Name = "Command"; command.Parent = folder
	local state = Instance.new("RemoteEvent"); state.Name = "State"; state.Parent = folder
	local combat = Instance.new("RemoteEvent"); combat.Name = "CombatIntent"; combat.Parent = folder
	local input = require(script.Parent.Parent.Systems.PlayerCombatInput)
	local combatBuckets: {[Player]: any} = {}
	local buckets: { [Player]: any } = {}
	local Network: any = {}
	function Network.Send(player: Player, code: string?, result: any?, requestId: string?, navigate: string?)
		if player.Parent ~= Players then return end
		local view = deps.Project(deps.Data.Sessions[player.UserId], deps.Mode, os.time())
		view.code = code; view.result = result; view.requestId = requestId; view.navigate = navigate
		deps.World.Update(player, if view.data then view.data.hallLevel else 1, view.data, view.status == "Active")
		view.islands=if deps.World.IslandDirectory then deps.World.IslandDirectory(player) else {}
		view.islandVisitors=if deps.World.IslandVisitors then deps.World.IslandVisitors(player) else {}
		state:FireClient(player, view)
	end
	function Network.Remove(player: Player) buckets[player] = nil; combatBuckets[player] = nil end
	combat.OnServerEvent:Connect(function(player: Player, packet: any)
		local now = os.clock()
		local bucket = combatBuckets[player] or {tokens = 4, at = now}; combatBuckets[player] = bucket
		if not input.accept(bucket, now) or not input.valid(packet) then return end
		local session = deps.Data.Sessions[player.UserId]
		if not session or session.state ~= "Active" or session.closing or not session.record then return end
		if deps.Content and deps.Content.NoviceActionProblem(session.record.data,"Combat") then return end
		local ok, code = deps.World.PlayerAction(player, packet.action, packet.actorId)
		combat:FireClient(player, if ok then "OK" else code)
	end)
	local function handle(player: Player, packet: any)
		local now = os.clock()
		local bucket = buckets[player] or { tokens = 6, at = now }
		bucket.tokens = math.min(6, bucket.tokens + (now - bucket.at) * 2); bucket.at = now; buckets[player] = bucket
		if bucket.tokens < 1 then return end -- silent bounded drop, client polls its state
		bucket.tokens -= 1
		local valid = deps.Protocol.validate(packet)
		if not valid then Network.Send(player, "InvalidRequest"); return end
		local current=deps.Data.Sessions[player.UserId]
		if deps.Content and current and current.record then
			local gate=deps.Content.NoviceActionProblem(current.record.data,packet.action)
			if gate then Network.Send(player,gate,nil,packet.requestId);return end
		end
		local spatial=deps.World.ValidateIntent(player,packet.action,packet.args)
		if spatial then Network.Send(player,spatial,nil,packet.requestId);return end
		local code, result
		if packet.action == "GetState" then Network.Send(player, nil, nil, packet.requestId); return
		elseif packet.action == "RetryLoad" then
			code = deps.Load(player)
		elseif packet.action == "RetrySave" then
			code = deps.Data.Refresh(player.UserId)
		elseif packet.action=="RequestPermanentPass" then
			local ok,response=pcall(deps.PermanentPassRequest,player,packet)
			code=if ok then response else "PurchaseUnavailable"
		elseif packet.action=="VisitIsland" or packet.action=="KickIslandVisitor" then
			local session=deps.Data.Sessions[player.UserId]
			if not session or session.state~="Active" or session.closing then code="IslandUnavailable"
			else
				local handler=if packet.action=="VisitIsland" then deps.World.VisitIsland else deps.World.KickIslandVisitor
				local targetId=if packet.action=="VisitIsland" then packet.args.ownerId else packet.args.visitorId
				local ok,reason=pcall(handler,player,targetId)
				code=if ok then reason else "TravelUnavailable"
				if not ok then deps.Log("island_visit_error",{}) end
			end
		else
			local ok, status, outcome = pcall(deps.Data.Execute, player.UserId, packet)
			if not ok then
				deps.Log("command_error", { action = packet.action })
				-- Stop further writes after an unexpected application exception.
				local session = deps.Data.Sessions[player.UserId]
				if session then session.state = "LeaseLost"; session.problem = "InternalError"; session.busy = false end
				code = "InternalError"
			else code = status; result = outcome end
		end
		Network.Send(player, code, result, packet.requestId)
		if code == "OK" then deps.World.IntentCommitted(player,packet.action,packet.args);task.defer(function() deps.Data.FlushAudit(player.UserId) end) end
	end
	command.OnServerEvent:Connect(handle)
	function Network.Intent(player: Player,action: string,args: any)
		local s=deps.Data.Sessions[player.UserId];if not s or not s.record then return end
		handle(player,{version=1,requestId=game:GetService("HttpService"):GenerateGUID(false),action=action,args=args,revision=s.record.revision})
	end
	folder.Parent = ReplicatedStorage -- publish only after handlers are ready
	return Network
end
