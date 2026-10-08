--!strict
-- QA-only client helper; never mapped by Rojo. Run only in an isolated Studio profile.
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local remotes=game.ReplicatedStorage:WaitForChild("GuildborneRemotes")
local command=remotes:WaitForChild("Command") :: RemoteEvent
local state=remotes:WaitForChild("State") :: RemoteEvent
local combat=remotes:WaitForChild("CombatIntent") :: RemoteEvent
local responses: {[string]: any}={}
local view: any=nil
state.OnClientEvent:Connect(function(v)
	view=v; _G.GB22View=v
	if v.requestId then responses[v.requestId]=v end
end)
combat.OnClientEvent:Connect(function(code) _G.GB22CombatCode=code end)
local function send(action: string,args: any?): any
	for _=1,8 do
		local id=Http:GenerateGUID(false)
		command:FireServer({version=1,requestId=id,action=action,revision=if view then view.revision else 0,args=args or {}})
		local deadline=os.clock()+5
		repeat task.wait(.1) until responses[id] or os.clock()>deadline
		local result=responses[id]
		if result and result.code~="StaleRevision" and result.code~="RevisionConflict" and result.code~="Busy" then return result end
		task.wait(.5)
	end
	error("No acknowledged command: "..action)
end
_G.GB22Send=send
send("GetState")
_G.GB22Drive=function(seconds: number)
	_G.GB22DriverDone=false; _G.GB22CombatSamples={}
	local deadline=os.clock()+seconds
	while os.clock()<deadline do
		local p=Players.LocalPlayer; local c=p.Character
		if c and c.PrimaryPart then
			local best: Model?=nil; local distance=math.huge
			for _,m in ipairs(workspace:GetDescendants()) do
				if m:IsA("Model") and m:GetAttribute("GuildborneEnemy") and m:GetAttribute("OwnerUserId")==p.UserId and (m:GetAttribute("CombatHealth") or 0)>0 then
					local d=(m:GetPivot().Position-c:GetPivot().Position).Magnitude
					if d<distance then best=m; distance=d end
				end
			end
			if best and (c:GetAttribute("CombatHealth") or 0)>0 then
				-- QA positioning isolates casts/rewards from navigation. This is not a movement acceptance test.
				c:PivotTo(CFrame.new(best:GetPivot().Position+Vector3.new(2,1,0)))
				combat:FireServer({action="Basic"}); task.wait(.2); combat:FireServer({action="Ability"})
			end
			table.insert(_G.GB22CombatSamples,c:GetAttributes())
		end
		task.wait(.6)
	end
	_G.GB22DriverDone=true
end
print("[Phase22 QA] Client probe ready, revision",view and view.revision)
