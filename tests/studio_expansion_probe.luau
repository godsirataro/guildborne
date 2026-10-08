--!strict
-- QA-only. Load studio_player_probe first, in the isolated expansion namespace.
-- Uses public intents and assisted positioning, never writes stats or grants clears.
local p=game.Players.LocalPlayer
local remote=game.ReplicatedStorage.GuildborneRemotes.CombatIntent :: RemoteEvent
_G.GB27Fight=function(seconds: number)
	_G.GB27FightDone=false;_G.GB27Samples={}
	local run=_G.GB22View.data.expansion.tower.active;local deadline=os.clock()+seconds
	while run and os.clock()<deadline do
		local current=_G.GB22View.data.expansion.tower.active
		if not current or current.state~="Fighting" or current.floor~=run.floor then break end
		local c=p.Character
		if c and (c:GetAttribute("CombatHealth") or 0)>0 then
			local enemy: Model?=nil;local distance=math.huge
			for _,m in ipairs(workspace:GetDescendants()) do
				if m:IsA("Model") and m:GetAttribute("GuildborneEnemy") and m:GetAttribute("TowerFloor")==run.floor and m:GetAttribute("OwnerUserId")==p.UserId and (m:GetAttribute("CombatHealth") or 0)>0 then
					local d=(m:GetPivot().Position-c:GetPivot().Position).Magnitude;if d<distance then enemy=m;distance=d end
				end
			end
			if enemy then c:PivotTo(CFrame.new(enemy:GetPivot().Position+Vector3.new(2,1,0)));remote:FireServer({action="Basic"});task.wait(.15);remote:FireServer({action="Ability"}) end
			table.insert(_G.GB27Samples,{floor=run.floor,hp=c:GetAttribute("CombatHealth"),ability=c:GetAttribute("AbilityName"),casts=c:GetAttribute("AbilityCount"),damage=c:GetAttribute("DamageDealt")})
		end
		task.wait(.65)
	end
	_G.GB27FightDone=true
end
print("[Phase27 QA] Tower sampler ready")
