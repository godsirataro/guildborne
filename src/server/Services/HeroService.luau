--!strict
local Physics = game:GetService("PhysicsService")
local Pathfinding = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Localization = require(ReplicatedStorage.Shared.Config.Localization)
local City = require(ReplicatedStorage.Shared.Config.City)
local Art = require(ReplicatedStorage.Shared.Config.Art)
local Rig = require(script.Parent.HeroRig)
local templateChoice=require(script.Parent.Parent.Systems.HeroTemplateChoice)
local Content = require(script.Parent.Parent.Config.Content)
local Expansion=require(ReplicatedStorage.Shared.Data.Expansion)
local Gear=require(ReplicatedStorage.Shared.Data.Equipment)(Content,Expansion,require(ReplicatedStorage.Shared.Data.StatusPoints))
local present = require(script.Parent.Parent.Systems.HeroPresentation)(Content,Gear)
local V = Vector3.new
local homes = { V(-30,3,-9), V(-23,3,-9), V(-16,3,-9), V(-27,3,-17), V(-19,3,-17) }

return function(templates: Folder, onOpen: (Player,string) -> (), reward: any,towerResult: any,regionalRewardFactory:any?)
	local combat=require(script.Parent.CombatService)(templates,reward,towerResult,regionalRewardFactory)
	for _, name in ipairs({"GuildborneHeroes","GuildborneCharacters"}) do
		if not Physics:IsCollisionGroupRegistered(name) then Physics:RegisterCollisionGroup(name) end
	end
	Physics:CollisionGroupSetCollidable("GuildborneHeroes","GuildborneHeroes",false)
	Physics:CollisionGroupSetCollidable("GuildborneHeroes","GuildborneCharacters",false)
	Physics:CollisionGroupSetCollidable("GuildborneCharacters","GuildborneCharacters",false)
	local away=Instance.new("Folder"); away.Name="GuildborneAwayHeroes"; away.Parent=ServerStorage
	local sessions: { [Player]: any } = {}
	local service = {}
	function service.Add(player: Player, plot: Model, origin: Vector3)
		local folder=Instance.new("Folder"); folder.Name="Heroes"; folder.Parent=plot
		local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances={workspace:FindFirstChild("GuildborneWorld") :: Instance}; params.RespectCanCollide=true;params.CollisionGroup="GuildborneHeroes"
		sessions[player]={plot=plot,folder=folder,origin=origin,heroes={},history={},params=params,alive=true}
		combat.Add(sessions[player],player)
	end
	function service.Character(player: Player, character: Model)
		local s=sessions[player]; if not s then return end
		if s.characterConnection then s.characterConnection:Disconnect() end
		local function assign(p: Instance) if p:IsA("BasePart") then p.CollisionGroup="GuildborneCharacters" end end
		for _,p in ipairs(character:GetDescendants()) do assign(p) end
		s.characterConnection=character.DescendantAdded:Connect(assign)
		table.clear(s.history); s.reset=true;s.towerPosition=s.towerRun and s.towerRun.state=="Fighting"
	end
	local function makeHero(player: Player, s: any, desc: any): any
		local m=Rig.Build(desc.class,templateChoice(desc.class,desc.id,desc.templateId)); m.Name=desc.class; m:SetAttribute("OwnerUserId",player.UserId)
		m:SetAttribute("AdventurerId",desc.id); m:SetAttribute("ClassId",desc.class); m:SetAttribute("GuildborneHero",true)
		m.Parent=s.folder
		local root=m.PrimaryPart :: BasePart
		local head=m:FindFirstChild("Head") :: BasePart
		local gui=Instance.new("BillboardGui"); gui.Name="HeroLabel"; gui.Size=UDim2.fromOffset(174,66)
		gui.StudsOffsetWorldSpace=V(0,1.8,0); gui.MaxDistance=14; gui.Parent=head
		local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.TextSize=13
		label.TextWrapped=true; label.BackgroundTransparency=.15; label.BackgroundColor3=Art.UI.Background
		label.TextColor3=Art.UI.Text; label.Font=Enum.Font.GothamMedium; label.Parent=gui
		local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,5); corner.Parent=label
		local prompt=Instance.new("ProximityPrompt"); prompt.Name="InspectHero"
		prompt.ActionText="Meet / ดูข้อมูล"; prompt.ObjectText=desc.name.." / "..Localization.translate("th",desc.name)
		prompt.MaxActivationDistance=7; prompt.RequiresLineOfSight=false; prompt.Parent=root
		prompt.Triggered:Connect(function(actor)
			local actorRoot=actor.Character and actor.Character:FindFirstChild("HumanoidRootPart")
			if actor==player and actorRoot and actorRoot:IsA("BasePart") and (actorRoot.Position-root.Position).Magnitude<=12 then onOpen(actor,"Party") end
		end)
		local home=CFrame.new(s.origin+homes[desc.index]+V(0,.4,0))*CFrame.Angles(0,math.pi,0)
		m:PivotTo(home)
		return {model=m,root=root,humanoid=m:FindFirstChildOfClass("Humanoid"),label=label,prompt=prompt,home=home,
			lastPosition=root.Position,lastProgress=os.clock(),nextPath=0,generation=0,recoveries=0}
	end
	function service.Sync(player: Player, data: any, active: boolean)
		local s=sessions[player]; if not s then return end
		s.active=active;s.extra=Gear.extras(data,data.character);s.playerBuild=Gear.build(data,data.character);s.expansionData=data.expansion; s.characterData=data.character; s.playerLoadout=if data.character.classId then Gear.loadout(data,data.character) else nil
		combat.TowerSync(player,s,data.expansion and data.expansion.tower.active)
		for _,desc in ipairs(present(data)) do
			local h=s.heroes[desc.id]
			if not h then h=makeHero(player,s,desc); s.heroes[desc.id]=h end
			h.followSpeedBonus=if desc.extra then desc.extra.Speed or 0 else 0
			local changed=h.state~=desc.state or h.slot~=desc.slot or h.visible~=desc.visible
			if changed then
				h.generation+=1; h.path=nil; h.state=desc.state; h.slot=desc.slot;h.visible=desc.visible; h.lastProgress=os.clock()
				h.root.Anchored=true; h.model.Parent=if desc.state=="On expedition" or desc.state=="Dead" or not desc.visible then away else s.folder
				h.model:PivotTo(h.home)
				if desc.state=="Following" then s.reset=true end
			end
			if h.weapon~=desc.weapon then Rig.Equip(h.model,desc.weapon,templates); h.weapon=desc.weapon end
			Rig.Outfit(h.model,desc.armor,desc.accessory)
			-- Equipment weld changes can reset assembly ownership even while already walking.
			if not h.root.Anchored and (h.root:GetNetworkOwnershipAuto() or h.root:GetNetworkOwner()~=nil) then h.root:SetNetworkOwner(nil) end
			h.model:SetAttribute("HeroState",desc.state); h.model:SetAttribute("PartySlot",desc.slot)
			h.model:SetAttribute("Level",desc.level);h.model:SetAttribute("Rank",desc.rank)
			-- Following companions already have HUD cards; leave E available for nearby city NPCs.
			h.prompt.Enabled=desc.state~="On expedition" and desc.state~="Following"
			h.label.Text=desc.name.." ["..desc.rank.."] · "..desc.class.." · "..(if desc.state=="Available" then tostring(desc.cost).." Gold" else "Lv"..desc.level)
				.."\n"..Localization.translate("th",desc.name).." · "..Localization.translate("th",desc.class)
				.."\n"..desc.state.." / "..Localization.translate("th",desc.state)
			h.label.TextColor3=if desc.state=="Following" then Art.UI.Accent else Art.UI.Text;
			(h.label.Parent :: BillboardGui).Enabled=desc.state~="Following"
			combat.Sync(h,desc,player,s)
		end
	end
	local function floor(s: any, position: Vector3): Vector3?
		local hit=workspace:Raycast(position+V(0,8,0),V(0,-24,0),s.params)
		return if hit then hit.Position+V(0,3,0) else nil
	end
	local function recover(h: any, position: Vector3)
		h.model:PivotTo(CFrame.new(position)); h.root.AssemblyLinearVelocity=Vector3.zero; h.root.AssemblyAngularVelocity=Vector3.zero
		h.path=nil; h.lastProgress=os.clock(); h.recoveries+=1; h.model:SetAttribute("RecoveryCount",h.recoveries)
	end
	local function walk(s: any, h: any, goal: Vector3, now: number)
		if h.root.Anchored then h.root.Anchored=false; h.root:SetNetworkOwner(nil) end
		local position=h.root.Position
		if (position-h.lastPosition).Magnitude>.6 then h.lastProgress=now; h.lastPosition=position end
		local distance=(goal-position).Magnitude
		if distance>45 or position.Y<s.origin.Y-8 or (distance>4 and now-h.lastProgress>7) then recover(h,goal); return end
		if distance<1.8 then h.humanoid:MoveTo(position); h.path=nil; h.lastProgress=now; return end
		h.humanoid.WalkSpeed=(if distance>12 then 21 else 17)+(h.followSpeedBonus or 0)
		local obstruction=workspace:Raycast(position,goal-position,s.params)
		if not obstruction then h.path=nil; h.humanoid:MoveTo(goal); return end
		if h.path then
			local waypoint=h.path[h.waypoint]
			if waypoint and (waypoint.Position-position).Magnitude<3.5 then h.waypoint+=1; waypoint=h.path[h.waypoint] end
			if waypoint then
				if waypoint.Action==Enum.PathWaypointAction.Jump then h.humanoid.Jump=true end
				h.humanoid:MoveTo(waypoint.Position)
			end
		end
		if h.computing or now<h.nextPath then return end
		h.nextPath=now+1.25; h.computing=true
		local generation=h.generation
		task.spawn(function()
			local path=Pathfinding:CreatePath({AgentRadius=1.2,AgentHeight=5,AgentCanJump=true,WaypointSpacing=3})
			local ok=pcall(function() path:ComputeAsync(position,goal) end)
			if s.alive and h.generation==generation and h.state=="Following" and ok and path.Status==Enum.PathStatus.Success then
				h.path=path:GetWaypoints(); h.waypoint=2
			end
			h.computing=false
		end)
	end
	local elapsed=0
	RunService.Heartbeat:Connect(function(dt)
		elapsed+=dt; if elapsed<.2 then return end; elapsed=0
		local now=os.clock()
		for player,s in pairs(sessions) do
			local character=player.Character; local root=character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
			local humanoid=character and character:FindFirstChildOfClass("Humanoid")
			local inCity=root~=nil and City.contains(root.Position.X,root.Position.Z)
			local inWorld=root~=nil and (inCity or City.region(root.Position.X,root.Position.Z)~=nil or (root.Position.Z>=-80 and root.Position.Z<118 and root.Position.X>=-70))
			local valid=root~=nil and humanoid~=nil and humanoid.Health>0 and s.active==true and inWorld

			if valid and root then
				if s.reset or (#s.history>0 and (s.history[1]-root.Position).Magnitude>35) then
					table.clear(s.history)
					for i=0,30 do table.insert(s.history,root.Position+root.CFrame.LookVector*(-i)) end
					s.reset=false
				end
				if #s.history==0 or (s.history[1]-root.Position).Magnitude>1 then table.insert(s.history,1,root.Position) end
				while #s.history>80 do table.remove(s.history) end
			end
			combat.Step(player,s,root,valid,now,walk)
			for _,h in pairs(s.heroes) do
				if h.state=="Following" then
					if h.combatMove then continue end
					if not valid then
						h.root.Anchored=true; h.model:PivotTo(h.home); h.path=nil; s.reset=true
					else
						local remaining=4+(h.slot-1)*(if inCity then 2.5 else 3.5)
						local target=s.history[#s.history]
						for i=2,#s.history do
							local a,b=s.history[i-1],s.history[i]; local length=(b-a).Magnitude
							if length>=remaining then target=a:Lerp(b,remaining/math.max(length,.001)); break end
							remaining-=length
						end
						local safe=target and floor(s,target)
						if safe then walk(s,h,safe,now) end
					end
				end
			end
		end
	end)
	function service.Travel(player: Player)
		local s=sessions[player];local c=player.Character;if not s or not c then return end
		table.clear(s.history);s.reset=true
		for _,h in pairs(s.heroes) do if h.state=="Following" then
			h.generation+=1;h.path=nil;h.combatMove=false
			local target=c:GetPivot().Position+V(((h.slot-1)%3-1)*3,0,4+math.floor((h.slot-1)/3)*3)
			local safe=floor(s,target);if safe then recover(h,safe) end
			if h.combat then h.combat.target=nil;h.combat.previousTarget=nil;h.combat.active=false;h.combat.order=nil;h.combat.focusTarget=nil end
		end end
	end
	function service.PlayerAction(player: Player, action: string, actorId: string?): (boolean, string)
		local s=sessions[player]
		if not s then return false,"NotReady" end
		return combat.PlayerAction(s,action,os.clock(),actorId)
	end
	-- Read-only server evidence for campaign adapters; never accepts a client snapshot.
	function service.CompanionEvidence(player:Player,actorId:string):any?
		local s=sessions[player];local h=s and s.heroes[actorId];local a=h and h.combat
		if not h or h.state~="Following" or not a or a.owner~=player.UserId or not h.model:IsDescendantOf(workspace) then return nil end
		return {id=actorId,health=a.health,position=h.root.Position,order=a.order,
			focus=if a.focusTarget and a.focusTarget.health>0 then a.focusTarget.id else nil}
	end
	function service.Remove(player: Player)
		local s=sessions[player]; if not s then return end
		s.alive=false; if s.characterConnection then s.characterConnection:Disconnect() end
		combat.Remove(player,s)
		for _,h in pairs(s.heroes) do h.generation+=1; h.model:Destroy() end
		for _,e in ipairs(s.enemies) do e.model:Destroy() end
		s.folder:Destroy(); sessions[player]=nil
	end
	return service
end
