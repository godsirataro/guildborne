--!strict
local Config=require(script.Parent.Parent.Config.Combat)
local Profiles=require(script.Parent.Parent.Systems.EnemyProfiles)(Config)
local Appearance=require(script.Parent.EnemyAppearance)
local Articulate=require(script.Parent.EnemyArticulation)
local V=Vector3.new
return function(templates: Folder)
	local S={}
	function S.create(parent: Instance, origin: Vector3, owner: number,floor: number?): {any}
		local enemies={}
		local positions=if floor and floor%5==0 then {V(0,0,91),V(-16,0,82),V(16,0,82)} elseif floor and floor%2==0 then {V(-15,0,80),V(15,0,80),V(-12,0,102),V(12,0,102)} else {V(-13,0,79),V(13,0,85),V(0,0,105)}
		for index,offset in ipairs(positions) do
			local model=if floor then Instance.new("Model") else (templates:FindFirstChild("GoblinScout") :: Model):Clone(); model.Name="Goblin"..index
			local root=Instance.new("Part"); root.Name="HumanoidRootPart"; root.Size=V(2,2,2)
			root.Transparency=1; root.Anchored=true; root.CanCollide=false; root.CanQuery=false; root.CanTouch=false
			root.Position=V(0,2,0); root.Parent=model; model.PrimaryPart=root
			model:SetAttribute("GuildborneEnemy",true); model:SetAttribute("OwnerUserId",owner)
			for _,p in ipairs(model:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide=false; p.CanTouch=false; p.CanQuery=false end
			end
			model.Parent=parent
			local stats,boss,title=Profiles.resolve(floor,index)
			if floor then
				Appearance(model,title)
			end
			Articulate(model,not floor)
			if floor then
				if boss then model:ScaleTo(1.6) end
				model:SetAttribute("TowerFloor",floor);model:SetAttribute("EnemyTitle",title)
			end
			local home=origin+offset+V(0,2*model:GetScale(),0); model:PivotTo(CFrame.new(home))
			table.insert(enemies,{id="g:"..index,kind="Enemy",owner=owner,model=model,root=root,home=home,
				boss=boss,towerFloor=floor,stats=stats,health=stats.MaxHealth,state="Idle",active=true,threat={},cooldowns={},generation=1})
		end
		return enemies
	end
	function S.move(e: any, goal: Vector3, dt: number)
		local delta=V(goal.X-e.root.Position.X,0,goal.Z-e.root.Position.Z)
		if delta.Magnitude<.1 then return end
		local position=e.root.Position+delta.Unit*math.min(delta.Magnitude,e.stats.MoveSpeed*dt*(if (e.slowUntil or 0)>os.clock() then .45 else 1))
		e.model:PivotTo(CFrame.lookAt(position,position+delta.Unit))
	end
	function S.reset(e: any)
		e.model.Parent=e.plot
		e.health=e.stats.MaxHealth; e.state="Idle"; e.target=nil; e.threat={}; e.tauntTarget=nil; e.tauntUntil=nil
		e.pendingPattern=nil;e.patternCount=0;e.model:SetAttribute("TelegraphAt",nil)
		e.nextAttack=0; e.rewardClaimed=nil; e.rewardDone=nil; e.rewardPending=nil; e.participants=nil; e.playerParticipated=nil; e.generation+=1
		e.model:PivotTo(CFrame.new(e.home))
	end
	return S
end
