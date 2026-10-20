--!strict
-- One bounded update per plot, called by the existing follower scheduler.
local Players=game:GetService("Players")
local City=require(game.ReplicatedStorage.Shared.Config.City)
local Config=require(script.Parent.Parent.Config.Combat)
local Content=require(script.Parent.Parent.Config.Content)
local Expansion=require(game.ReplicatedStorage.Shared.Data.Expansion)
local AudioConfig=require(game.ReplicatedStorage.Shared.Config.AudioConfig)
local Gear=require(game.ReplicatedStorage.Shared.Data.Equipment)(Content,Expansion,require(game.ReplicatedStorage.Shared.Data.StatusPoints))
local Stats=require(script.Parent.Parent.Systems.CombatStats)(Content,Config,Gear)
local Space=require(script.Parent.Parent.Systems.CombatSpace)(City)
local sight=require(script.Parent.CombatLineOfSight)(workspace:WaitForChild("GuildborneWorld"))
local MakeTarget=require(script.Parent.Parent.Systems.CombatTargeting)
local Lifecycle=require(script.Parent.Parent.Systems.EnemyLifecycle)
local BossPatterns=require(script.Parent.Parent.Systems.BossPatterns)
local Tactics=require(script.Parent.Parent.Systems.HeroTactics)
local Http=game:GetService("HttpService")
local V=Vector3.new
return function(templates: Folder, reward: any,towerResult: any,regionalRewardFactory:any?,combatObserver:any?,sharedContext:any?)
	local phases=if sharedContext then require(script.Parent.Parent.Systems.SharedCombatPhases)(sharedContext)else nil
	local Target=MakeTarget(function(a:any,b:any)return (a.root.Position-b.root.Position).Magnitude end,if phases then nil else Space.hostile,sight,if phases then phases.Policy else nil)
	local function contains(s:any,a:any):boolean return if phases then phases.Policy.key(a)~=nil else Space.contains(s,a.root.Position)end
	local Enemy=require(script.Parent.EnemyService)(templates)
	local service={}
	local Rig=require(script.Parent.HeroRig)
	local participation=require(script.Parent.Parent.Systems.PlayerParticipation)
	local observerPending=0
	local function observe(owner:number,event:string,payload:any)
		if combatObserver and observerPending<32 then
			-- Capture connection identity before queueing; never attribute an old hit to a rejoin.
			local originalPlayer=Players:GetPlayerByUserId(owner)
			if not originalPlayer then return end
			observerPending+=1
			task.defer(function()pcall(combatObserver,owner,event,payload,originalPlayer);observerPending-=1 end)
		end
	end
	local function emit(name: string,a: any,b: any,value: any)
		if phases then phases.Notify("Observe",name,a,b,value)end
		if combatObserver and a.id=="player" and a.kind=="Hero" and type(value)=="number" and value>0 and (name=="damage_dealt" or name=="healing_done")then
			observe(a.owner,if name=="damage_dealt"then "combat_player_damage"else "combat_player_heal",{amount=value})
		end
		if name=="enemy_basic_attack" then a.model:SetAttribute("EnemyActionAt",workspace:GetServerTimeNow()) end
		-- A commanded companion can land a killing blow before the next AI step.
		-- Capture the same server-owned party snapshot the AI uses, exactly once.
		if not phases and name=="damage_dealt" and a.id~="player" and a.kind=="Hero" and b.kind=="Enemy" and not b.participants then
			b.participants={}
			for _,member in ipairs(if a.session then a.session.allies or {} else {a}) do
				if member.id~="player" and member.owner==a.owner and member.active then table.insert(b.participants,member.id) end
			end
		end
		if not phases then participation(name,a,b,value,if a.session then a.session.enemies else {},os.clock())end
		local plot=a.plot
		if plot then
			plot:SetAttribute(name,(plot:GetAttribute(name) or 0)+1)
			if name=="hero_basic_attack" or name=="hero_ability_used" then
				a.model:SetAttribute("ActionAt",workspace:GetServerTimeNow())
				a.model:SetAttribute("Action",if name=="hero_basic_attack" then "Basic Attack" else Config.Abilities[value].Name)
				a.model:SetAttribute("ActionTargetPosition",b.root.Position)
				a.model:SetAttribute("ActionRange",if name=="hero_basic_attack" then a.stats.AttackRange else Config.Abilities[value].Range)
				a.model:SetAttribute("ActionEffect",if name=="hero_basic_attack" then "Basic" else Config.Abilities[value].Effect)
				a.model:SetAttribute("ActionAbilityId",if name=="hero_ability_used" then value else nil)
				a.model:SetAttribute("BasicAttackCount",(a.model:GetAttribute("BasicAttackCount") or 0)+(if name=="hero_basic_attack" then 1 else 0))
				a.model:SetAttribute("AbilityCount",(a.model:GetAttribute("AbilityCount") or 0)+(if name=="hero_ability_used" then 1 else 0))
			end
		end
		if name=="damage_dealt" or name=="healing_done" then
			if name=="damage_dealt" then
				b.model:SetAttribute("DamageCue",AudioConfig.hitCue(a.class or ""))
				b.model:SetAttribute("DamageCueAt",workspace:GetServerTimeNow())
			end
			if name=="damage_dealt" then a.model:SetAttribute("DamageDealt",(a.model:GetAttribute("DamageDealt") or 0)+value)
			else a.model:SetAttribute("HealingDone",(a.model:GetAttribute("HealingDone") or 0)+value) end
			b.model:SetAttribute("Feedback",(if name=="healing_done" then "+" else "-")..tostring(value))
			b.model:SetAttribute("FeedbackAt",workspace:GetServerTimeNow())
		end
	end
	local Damage=require(script.Parent.Parent.Systems.CombatDamage)(Stats,Target,emit)
    local Regional=require(script.Parent.RegionalCombat)(Damage,regionalRewardFactory)
	local Abilities=require(script.Parent.Parent.Systems.CombatAbilities)(Config,Target,Damage,emit)
	function service.Add(s: any,player: Player)
		if phases then return end
		s.enemies=Enemy.create(s.plot,s.origin,player.UserId)
		s.campEnemies=s.enemies
		for _,e in ipairs(s.enemies) do e.plot=s.plot;e.session=s end
		s.combat=false
	end
	function service.TowerSync(player: Player,s: any,run: any)
		if phases then return end
		local key=if run then run.id..":"..run.floor..":"..run.state else "camp"
		if key==s.towerKey then return end
		Regional.Stop(player,s)
		local previous=s.towerKey;s.towerKey=key;s.towerRun=run;s.towerPending=false;s.towerDone=false
		for _,h in pairs(s.heroes or {}) do if h.combat then Tactics.clear(h.combat) end end
		for _,enemy in ipairs(s.enemies) do enemy.model:Destroy() end
		local fighting=run and run.state=="Fighting";s.towerPosition=fighting
		s.enemies=Enemy.create(s.plot,s.origin,player.UserId,if fighting then run.floor else nil)
		s.campEnemies=s.enemies
		for _,enemy in ipairs(s.enemies) do enemy.plot=s.plot;enemy.session=s end
		local oldArena=s.plot:FindFirstChild("SpireArena");if oldArena then oldArena:Destroy() end
		if fighting then
			local arena=Instance.new("Folder");arena.Name="SpireArena";arena.Parent=s.plot
			local color=if run.floor%5==0 then Color3.fromRGB(178,135,74) elseif run.floor%2==0 then Color3.fromRGB(86,120,162) else Color3.fromRGB(127,94,154)
			local function piece(name: string,pos: Vector3,size: Vector3,neon: boolean)
				local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=s.origin+pos;p.Color=color;p.Anchored=true;p.CanCollide=not neon;p.Material=if neon then Enum.Material.Neon else Enum.Material.Slate;p.Parent=arena;return p
			end
			piece("SpireFloor",V(0,.1,84),V(68,.2,65),false)
			for _,x in ipairs({-32,32}) do for _,z in ipairs({55,112}) do piece("Pillar",V(x,6,z),V(2,12,2),false);piece("Rune",V(x,12,z),V(3,.6,3),true) end end
			local sign=piece("FloorMarker",V(0,8,114),V(14,3,.5),true)
			local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(220,50);gui.MaxDistance=100;gui.Parent=sign
			local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.TextColor3=Color3.new(1,1,1);label.TextSize=22;label.Text="Spire / หอคอย · "..run.floor.." / 10";label.Parent=gui
		end
		s.plot:SetAttribute("TowerFloor",if run then run.floor else nil);s.plot:SetAttribute("TowerState",if run then run.state else nil)
		if player.Character and previous then player.Character:PivotTo(CFrame.new(s.origin+V(0,4,if fighting then 63 else 23)));s.reset=true end
	end
	function service.Sync(h: any,desc: any,player: Player,s: any)
		local stats=Stats.hero(desc.class,desc.level,desc.weapon,desc.armor,desc.accessory,desc.extra)
		if not stats then return end
		if not h.combat then
			h.combat={id=desc.id,class=desc.class,kind="Hero",owner=player.UserId,model=h.model,root=h.root,
				health=stats.MaxHealth,stats=stats,state="Follow",active=false,cooldowns={},plot=s.plot,threatMultiplier=Config.Classes[desc.class].Threat}
		else
			-- Gear/progression changes never refill HP or erase cooldown/downed state.
			h.combat.stats=stats; h.combat.health=math.min(h.combat.health,stats.MaxHealth)
		end
		h.humanoid.MaxHealth=stats.MaxHealth; h.humanoid.Health=stats.MaxHealth -- locomotion only; domain HP is authoritative
		h.combat.ability=desc.build.equipped or Config.Classes[desc.class].Ability
		h.combat.build=desc.build
		h.combat.session=s
		h.combat.allowedAbilities=Expansion.allowedSkills(desc.build,Config.Classes[desc.class].Ability)
		h.combat.skillSlots=Expansion.skillSlots(desc.build,Config.Classes[desc.class].Ability)
		local path=desc.build.path and Expansion.Paths[desc.build.path]
		h.model:SetAttribute("NoParentArt",path~=nil and path.Tier==3 and path.Parent==nil)
		h.combat.active=desc.state=="Following"
		if not h.combat.active then Tactics.clear(h.combat) end
	end
	local function publish(e: any,now: number)
		e.model:SetAttribute("CombatHealth",math.ceil(e.health)); e.model:SetAttribute("CombatMaxHealth",e.stats.MaxHealth)
		e.model:SetAttribute("CombatState",e.state); e.model:SetAttribute("CombatTarget",if e.target then e.target.id else nil)
		if e.kind=="Enemy" then
			if e.boss then e.model:SetAttribute("BossPhase",if e.health<=e.stats.MaxHealth*.5 then 2 else 1) end
			e.model:SetAttribute("Taunted",(e.tauntUntil or 0)>now)
			if e.health==0 and not e.corpseShown then
				e.corpseShown=true
				local pivot=if e.templateId then CFrame.new(e.position.x,e.position.y+1,e.position.z) else e.root.CFrame
				e.model:PivotTo(pivot*CFrame.Angles(0,0,math.pi/2))
			elseif e.health>0 then e.corpseShown=false end
		end
		if e.class then
			e.model:SetAttribute("CompanionOrder",e.order)
			e.model:SetAttribute("TacticalPreset",e.tactic or "Balanced")
			e.model:SetAttribute("TacticalReason",e.tacticReason)
			local ability=e.ability or Config.Classes[e.class].Ability
			e.model:SetAttribute("AbilityName",Config.Abilities[ability].Name)
			e.model:SetAttribute("Cooldown",math.max(0,math.ceil(math.max(e.cooldowns[ability] or 0,e.nextAbility or 0)-now)))
			if e.skillSlots then
				for slot=1,3 do
					local id=e.skillSlots and e.skillSlots[slot]
					e.model:SetAttribute("Skill"..slot.."Name",if id then Config.Abilities[id].Name else nil)
					e.model:SetAttribute("Skill"..slot.."Cooldown",if id then math.max(0,math.ceil(math.max(e.cooldowns[id] or 0,e.nextAbility or 0)-now)) else 0)
				end
			end
		end
	end
	type StepFrame={enemies:any?,support:any?,player:Player?,s:any,leader:BasePart?,character:Model?,now:number,walk:any,combatWalk:any,p:any,allies:{any},engage:boolean,recovery:number,fighting:boolean}
	local function prepareOwner(player:Player,s:any,leader:BasePart?,valid:boolean,now:number,walk:any):StepFrame
		if not phases then Regional.Sync(player,s)end
		local function combatWalk(h: any,goal: Vector3)
			local region=not phases and s.adventureRegion and City.Regions[s.adventureRegion]
			local origin=if phases then sharedContext.Scene.origin else s.origin
			local safe=if region then V(math.clamp(goal.X,region.X-region.HalfWidth+5,region.X+region.HalfWidth-5),goal.Y,math.clamp(goal.Z,region.Z-region.Back+5,region.Z+88))
				else V(math.clamp(goal.X,origin.X-34,origin.X+34),origin.Y+3,math.clamp(goal.Z,origin.Z+49,origin.Z+112))
			walk(s,h,safe,now)
		end
		local character=player.Character
		if not phases and s.towerPosition and character and leader then character:PivotTo(CFrame.new(s.origin+V(0,4,63)));s.towerPosition=false;s.reset=true end
		local c=s.characterData
		if c and c.classId and character and leader then
			local loadout=s.playerLoadout
			local stats=Stats.hero(c.classId,c.level,loadout.weapon,loadout.armor,loadout.accessory,s.extra)
			if not s.playerCombat then
				s.playerCombat={id="player",class=c.classId,kind="Hero",owner=player.UserId,
					health=stats.MaxHealth,state="Idle",cooldowns={},plot=s.plot,session=s,threatMultiplier=Config.Classes[c.classId].Threat}
			end
			local a=s.playerCombat
			a.model=character; a.root=leader; a.stats=stats; a.health=math.min(a.health,stats.MaxHealth)
			a.ability=s.playerBuild.equipped or Config.Classes[c.classId].Ability
			a.allowedAbilities=Expansion.allowedSkills(s.playerBuild,Config.Classes[c.classId].Ability)
			a.skillSlots=Expansion.skillSlots(s.playerBuild,Config.Classes[c.classId].Ability)
			local path=s.playerBuild.path and Expansion.Paths[s.playerBuild.path]
			character:SetAttribute("NoParentArt",path~=nil and path.Tier==3 and path.Parent==nil)
			a.active=valid
			character:SetAttribute("GuildbornePlayer",true); character:SetAttribute("OwnerUserId",player.UserId)
			character:SetAttribute("ClassPath",if s.playerBuild.path then Expansion.Paths[s.playerBuild.path].Name else c.classId);character:SetAttribute("RaceId",c.raceId);Rig.Race(character,c.raceId)
			character:SetAttribute("ClassId",c.classId); character:SetAttribute("Level",c.level); character:SetAttribute("XP",c.xp)
			if character:GetAttribute("WeaponId")~=loadout.weapon or not character:FindFirstChild("EquippedWeapon") then Rig.Equip(character,loadout.weapon,templates) end
			Rig.Outfit(character,loadout.armor,loadout.accessory)
		elseif s.playerCombat then s.playerCombat.active=false end
		local allies={}
		for _,h in pairs(s.heroes) do
			if h.combat then
				h.combat.session=s
				h.combat.active=valid and h.state=="Following"
				h.combat.target=nil
				if h.combat.active then table.insert(allies,h.combat) else Tactics.clear(h.combat) end
				h.combatMove=false
			end
		end
		local p=s.playerCombat
		if p then p.session=s end
		if p and p.active then table.insert(allies,p) end
		s.allies=allies;for _,a in ipairs(allies) do a.allies=allies end
		local engage=valid and leader~=nil and (phases~=nil or Space.contains(s,leader.Position)) and #allies>0
		s.engage=engage
		local recovery=Config.RecoveryPerSecond
		if s.expansionData then for _,b in pairs(s.expansionData.buildings) do if b.kind=="quarters" then recovery*=1.5;break end end end
		return {player=player,s=s,leader=leader,character=character,now=now,walk=walk,combatWalk=combatWalk,p=p,allies=allies,engage=engage,recovery=recovery,fighting=false}
	end
	local function stepEnemies(frame:StepFrame)
		local player,s,now,allies,engage=frame.player,frame.s,frame.now,frame.allies,frame.engage
		local fighting=if phases then false else Regional.Step(s,if engage then allies else {},now,Config.Tick)
		-- Shared completion must leave normal owner recovery running before the
		-- last corpse loses scene membership. Support includes domain-down actors.
		local awaitingRecovery=false
		if phases then for _,ally in ipairs(allies)do if ally.health<=0 then awaitingRecovery=true;break end end end
		for _,e in ipairs(s.enemies) do
			if e.templateId or (phases and not phases.Policy.key(e))then continue end
			e.session=s
			if e.health==0 then
				BossPatterns.cancel(e,now);e.model:SetAttribute("TelegraphAt",nil)
				if not phases and not e.towerFloor and Lifecycle.claimDeath(e) then
					local members=table.clone(e.participants or {})
					if e.playerParticipated then table.insert(members,"player") end
					table.sort(members)
					e.rewardPending=true
					task.spawn(function()
						local succeeded,result=pcall(reward,player,Http:GenerateGUID(false),members)
						local ok=succeeded and result==true
						if not s.alive then return end
						e.rewardDone=ok; e.rewardPending=false
						s.plot:SetAttribute("CombatRewardStatus",if ok then "Reward saved" else "Reward unavailable")
						if ok then s.plot:SetAttribute("RewardsSaved",(s.plot:GetAttribute("RewardsSaved") or 0)+1) end
					end)
				end
				if not awaitingRecovery and now-(e.downedAt or now)>=2 then e.model.Parent=nil end
				if not phases and not e.towerFloor and not e.rewardPending and now-(e.downedAt or now)>=Config.Goblin.RespawnSeconds then Enemy.reset(e) end
			else
				local outside=(e.root.Position-e.home).Magnitude>Config.EnemyLeash
				if not engage or outside then
					BossPatterns.cancel(e,now);e.model:SetAttribute("TelegraphAt",nil)
					e.target=nil; e.threat={}; e.tauntTarget=nil; e.tauntUntil=nil; e.state="ReturnToLeader"
					Enemy.move(e,e.home,Config.Tick)
					if (e.root.Position-e.home).Magnitude<1 then local before=e.health;e.health=e.stats.MaxHealth;if phases and e.health>before then phases.Notify("Recover",e,e.health-before)end; e.state="Idle"; e.participants=nil; e.playerParticipated=nil end
				else
					e.target=Target.enemy(e,allies,e.target,e.stats.DetectionRange,now)
					if e.target then
						fighting=true; e.state="Approach"
						if e.boss then
							local pattern=BossPatterns.begin(e,e.target,now)
							if pattern then
								e.model:SetAttribute("ActionTargetPosition",V(pattern.x,pattern.y,pattern.z))
								e.model:SetAttribute("TelegraphGroundY",s.origin.Y+.3)
								e.model:SetAttribute("TelegraphRadius",pattern.radius);e.model:SetAttribute("TelegraphDuration",pattern.duration)
								e.model:SetAttribute("TelegraphName",pattern.name);e.model:SetAttribute("TelegraphAt",workspace:GetServerTimeNow())
							end
							local hit=BossPatterns.take(e,now)
							if not e.pendingPattern then e.model:SetAttribute("TelegraphAt",nil) end
							if hit then
								e.model:SetAttribute("TelegraphAt",nil);e.state="Attack"
								e.model:SetAttribute("BossImpactAt",workspace:GetServerTimeNow())
								for index,ally in ipairs(allies) do
									if index<=6 and BossPatterns.contains(hit,ally.root.Position) and Space.contains(s,ally.root.Position) then
										Damage.hit(e,ally,e.stats.DetectionRange+hit.radius,hit.multiplier,now)
									end
								end
							elseif e.pendingPattern then e.state="Windup"
							elseif (e.root.Position-e.target.root.Position).Magnitude>e.stats.AttackRange then Enemy.move(e,e.target.root.Position,Config.Tick) end
						elseif Abilities.basic(e,e.target,now) then e.state="Attack"
						elseif (e.root.Position-e.target.root.Position).Magnitude>e.stats.AttackRange-.5 then Enemy.move(e,e.target.root.Position,Config.Tick) end
					else BossPatterns.cancel(e,now);e.model:SetAttribute("TelegraphAt",nil);e.state="Idle" end
				end
			end
		end
		frame.fighting=fighting
	end
	local function stepOwner(frame:StepFrame)
		local s,leader,character,now=frame.s,frame.leader,frame.character,frame.now
		local walk,combatWalk,p,allies=frame.walk,frame.combatWalk,frame.p,frame.allies
		local engage,recovery,fighting=frame.engage,frame.recovery,frame.fighting
		local enemies=frame.enemies or s.enemies
		local support=frame.support or allies
		for _,h in pairs(s.heroes) do
			local a=h.combat
			if not a then continue end
			if a.active and leader and (not phases or phases.Policy.key(a)~=nil)then
				local close=(a.root.Position-leader.Position).Magnitude<=Config.LeaderLeash
				if a.holdPoint and (a.holdPoint-leader.Position).Magnitude>Config.LeaderLeash then Tactics.clear(a) end
				a.detectionRange=Config.DetectionRange
				local enemy,reason=Tactics.select(a,p,enemies,Target,engage,close,now,function(x:any,y:any)return (x.root.Position-y.root.Position).Magnitude end)
				a.tacticReason=reason
				local escape=if a.health>0 and a.order~="Retreat" then (if phases then nil else Regional.Dodge(s,a,now)) else nil
				a.target=enemy; a.previousTarget=enemy
				if a.health<=0 then
					Tactics.clear(a)
					a.state="Downed"; h.combatMove=true; h.humanoid:MoveTo(a.root.Position)
					if not fighting and now-(a.downedAt or now)>=Config.DownSeconds then local before=a.health;a.health=a.stats.MaxHealth*.5;if phases and a.health>before then phases.Notify("Recover",a,a.health-before)end; a.state="Recover" end
				elseif escape then
					fighting=true;h.combatMove=true;a.state="Evade";a.tacticReason="TacticEvading";h.humanoid.WalkSpeed=a.stats.MoveSpeed
					-- Corridor was checked by RegionalEvasion. Avoid the follower's recovery teleport.
					if h.evadeStamp~=a.evasion.stamp then h.evadeStamp=a.evasion.stamp;h.generation+=1;h.path=nil end
					if h.root.Anchored then h.root.Anchored=false;h.root:SetNetworkOwner(nil) end
					h.humanoid:MoveTo(escape)
				elseif a.order=="Hold" and a.holdPoint then
					h.combatMove=true;a.state="Hold";h.humanoid.WalkSpeed=a.stats.MoveSpeed
					walk(s,h,a.holdPoint,now)
				elseif enemy then
					if not phases and not enemy.participants then
						enemy.participants={}; for _,member in ipairs(allies) do if member.id~="player" then table.insert(enemy.participants,member.id) end end
					end
					fighting=true; h.combatMove=true
					local role=Config.Classes[a.class];local skill=a.ability or role.Ability; local def=Config.Abilities[skill]
					local abilityTarget=if def.Effect=="Heal" then Target.heal(a,if phases and not def.Group then support else allies,def.Range) else enemy
					local cast,castProblem=Abilities.cast(a,skill,abilityTarget,enemies,now)
					if phases and not phases.Policy.key(a)then continue end
					if cast then a.tacticReason="TacticCasting" elseif castProblem=="Cooldown"then a.tacticReason="TacticCooldown" elseif def.Effect=="Heal" and not abilityTarget then a.tacticReason="TacticNoHealTarget" elseif castProblem=="InvalidTarget"then a.tacticReason="TacticOutOfRange" end
					local desiredRange=math.min(a.stats.AttackRange,def.Range)
					local distance=(a.root.Position-enemy.root.Position).Magnitude
					local away=a.root.Position-enemy.root.Position
					if distance>desiredRange-1 then
						a.state="Approach"
						local spread=V(((h.slot or 1)%3-1)*2,0,0)
						combatWalk(h,enemy.root.Position+V(0,1,0)+spread)
					elseif desiredRange>10 and distance<9 and away.Magnitude>.1 then
						a.state="Approach"; combatWalk(h,a.root.Position+away.Unit*5)
					else h.humanoid:MoveTo(a.root.Position); a.state="Attack" end
					if phases and not phases.Policy.key(a)then continue end
					h.humanoid.WalkSpeed=a.stats.MoveSpeed
					if cast then a.state="CastAbility" else Abilities.basic(a,enemy,now) end
				else
					a.state=if close then "Follow" else "ReturnToLeader"
					if a.order=="Retreat" then
						a.state="Retreat";h.combatMove=true
						local slot=h.slot or 1
						local destination=s.adventureRegion and City.Destinations[s.adventureRegion]
						local home=if phases then sharedContext.Scene.origin+V(((slot-1)%3-1)*3,3,23+math.floor((slot-1)/3)*3)elseif destination then V(destination.X+((slot-1)%3-1)*3,destination.Y,destination.Z+math.floor((slot-1)/3)*3)
							else s.origin+V(((slot-1)%3-1)*3,3,23+math.floor((slot-1)/3)*3)
						local delta=home-a.root.Position
						-- Short goals preserve walking; avoid the follower's long-distance recovery teleport.
						walk(s,h,if delta.Magnitude>12 then a.root.Position+delta.Unit*12 else home,now)
					elseif a.order=="Regroup" then a.state="Regroup" end
					if phases and not phases.Policy.key(a)then continue end
					if not fighting and now-(a.lastHit or 0)>Config.RecoveryDelay and a.health<a.stats.MaxHealth then
						local before=a.health;a.health=math.min(a.stats.MaxHealth,a.health+recovery*Config.Tick);if phases and a.health>before then phases.Notify("Recover",a,a.health-before)end; a.state="Recover"
					end
					local skill=a.ability or Config.Classes[a.class].Ability;local def=Config.Abilities[skill]
					if not City.contains(leader.Position.X,leader.Position.Z) and def.Effect=="Heal" then Abilities.cast(a,skill,Target.heal(a,if phases and not def.Group then support else allies,def.Range),enemies,now) end
				end
			end
			if not phases or phases.Policy.key(a)then publish(a,now)end
		end
		if p and character and p.model==character and (not phases or phases.Policy.key(p)~=nil)then
			local humanoid=character and character:FindFirstChildOfClass("Humanoid")
			if p.health<=0 then
				p.state="Downed"
				if humanoid then humanoid.WalkSpeed=0; humanoid.JumpPower=0; humanoid.JumpHeight=0 end
				if now-(p.downedAt or now)>=Config.DownSeconds then
					local before=p.health;p.health=p.stats.MaxHealth*.5;if phases and p.health>before then phases.Notify("Recover",p,p.health-before)end; p.state="Recover"; p.lastHit=now
					local destination=s.adventureRegion and City.Destinations[s.adventureRegion]
					if not phases then character:PivotTo(CFrame.new(if destination then V(destination.X,destination.Y,destination.Z) else s.origin+V(0,4,23))); s.reset=true end
				end
			else
				if humanoid then humanoid.WalkSpeed=p.stats.MoveSpeed; humanoid.JumpPower=50; humanoid.JumpHeight=7.2 end
				p.state=if fighting then "Attack" else "Idle"
				if not fighting and now-(p.lastHit or 0)>Config.RecoveryDelay then local before=p.health;p.health=math.min(p.stats.MaxHealth,p.health+recovery*Config.Tick);if phases and p.health>before then phases.Notify("Recover",p,p.health-before)end end
			end
			if not phases or phases.Policy.key(p)then publish(p,now)end
		end
		frame.fighting=fighting
	end
	local function finishStep(frame:StepFrame)
		local player,s,p,now,fighting=frame.player,frame.s,frame.p,frame.now,frame.fighting
		if not phases then for _,e in ipairs(s.enemies) do publish(e,now) end end
		local run=s.towerRun
		if not phases and run and run.state=="Fighting" and not s.towerPending and not s.towerDone then
			local allDead=true;for _,e in ipairs(s.enemies) do if e.health>0 then allDead=false end end
			local failed=p and p.health<=0
			if allDead or failed then
				s.towerPending=true;local captured=s.towerKey
				task.spawn(function()
					local ok,result=pcall(towerResult,player,run.id,run.floor,not failed)
					if s.alive and s.towerKey==captured then s.towerPending=false;s.towerDone=ok and result==true;s.plot:SetAttribute("TowerResult",if s.towerDone then "Saved" else "Retrying save") end
				end)
			end
		end
		if fighting~=s.combat then
			s.combat=fighting; local key=if fighting then "combat_started" else "combat_ended"
			s.plot:SetAttribute(key,(s.plot:GetAttribute(key) or 0)+1)
		end
		s.plot:SetAttribute("InCombat",fighting)
	end
	function service.Step(player:Player,s:any,leader:BasePart?,valid:boolean,now:number,walk:any)
		if phases then return end -- Shared context requires the explicit fenced phases.
		local frame=prepareOwner(player,s,leader,valid,now,walk)
		stepEnemies(frame)
		stepOwner(frame)
		finishStep(frame)
	end
	-- Stage A private API. Caller prepares all owners, registers actors externally, then ticks once.
	function service.PrepareSharedOwner(player:Player,s:any,leader:BasePart?,valid:boolean,stamp:number,walk:any,session:any):(any?,any)
		if not phases or s.mentor or s.towerRun or not phases.CanPrepare(player.UserId,session,stamp)then return nil,"Unavailable"end
		local function guardedWalk(owner:any,hero:any,goal:any,now:any)
			if phases.Policy.key(hero.combat)then phases.Call(walk,owner,hero,goal,now)end
		end
		local frame=prepareOwner(player,s,leader,valid,stamp,guardedWalk)
		local token,problem=phases.Prepare(player.UserId,session,stamp,frame.allies,frame)
		return token,if token then table.freeze(table.clone(frame.allies))else problem
	end
	function service.RegisterSharedOwner(token:any):(boolean,string)
		if not phases then return false,"Unavailable"end;return phases.Register(token)
	end
	function service.StepSharedEnemies(stamp:number):(boolean,string)
		if not phases then return false,"Unavailable"end
		local scene=sharedContext.Scene
		if type(scene)~="table"or type(scene.enemies)~="table"or getmetatable(scene.enemies)~=nil then return false,"InvalidEnemies"end
		for _,enemy in ipairs(scene.enemies)do if type(enemy)~="table"or getmetatable(enemy)~=nil then return false,"InvalidEnemies"end;if enemy.boss or enemy.templateId or enemy.towerFloor then return false,"BasicEnemiesOnly"end end
		return phases.Enemies(stamp,scene.enemies,function(allies:any,enemies:any):boolean
			local frame:any={s=scene,now=stamp,allies=allies,engage=#allies>0,fighting=false}
			stepEnemies(frame)
			for _,enemy in ipairs(enemies)do if phases.Policy.key(enemy)then publish(enemy,stamp)end end
			return frame.fighting
		end)
	end
	function service.StepSharedOwner(token:any):(boolean,string)
		if not phases then return false,"Unavailable"end
		return phases.Owner(token,function(frame:any,own:any,support:any,fighting:boolean)
			frame.allies=own;frame.support=support;frame.enemies=sharedContext.Scene.enemies;frame.fighting=fighting
			for _,actor in ipairs(own)do actor.allies=own end
			stepOwner(frame)
		end)
	end
	function service.FinishSharedOwner(token:any):(boolean,string)
		if not phases then return false,"Unavailable"end;return phases.Finish(token,finishStep)
	end
	function service.DetachSharedOwner(ownerId:number,session:any)if phases then phases.Detach(ownerId,session)end end
	function service.CloseShared()if phases then phases.Close()end end
	function service.PlayerAction(s: any, action: string, now: number, actorId: string?): (boolean,string)
		local leader=s.playerCombat
		if not s.active or not leader or not Target.alive(leader) or not leader.model:FindFirstChildOfClass("Humanoid") or leader.model:FindFirstChildOfClass("Humanoid").Health<=0 then return false,"NotReady" end
		if phases and (not phases.CommandReady()or not phases.Policy.key(leader))then return false,"NotReady"end
		local enemies=if phases then sharedContext.Scene.enemies else s.enemies
		local a=leader; local build=s.playerBuild
		local isOrder=Tactics.isOrder(action)
		if actorId and actorId~="player" then
			local hero=s.heroes and s.heroes[actorId]
			if not hero or hero.state~="Following" or not hero.combat or hero.combat.owner~=leader.owner or not Target.alive(hero.combat) then return false,"CompanionUnavailable" end
			a=hero.combat;build=a.build
			if not build or (not isOrder and (a.root.Position-leader.root.Position).Magnitude>Config.LeaderLeash) then return false,"CompanionUnavailable" end
		end
		if phases and not phases.Policy.key(a)then return false,"CompanionUnavailable"end
		if isOrder then
			if a==leader then return false,"Select a companion first" end
			if not a.model.Parent then return false,"CompanionUnavailable" end
			-- Orders only affect owned AI movement/selection; they never cast, heal or refill cooldowns.
			local anchor=a.root.Position
			if action=="Hold" then
				-- Match follower support: avoid overhead surfaces while retaining
				-- the original lower bound, sixteen studs below the root reference.
				local hit=workspace:Raycast(anchor+V(0,1,0),V(0,-17,0),s.params)
				if not hit then return false,"CompanionUnavailable"end
				anchor=hit.Position+V(0,3,0)
			end
			local controlled=s.heroes[actorId]
			controlled.generation+=1;controlled.path=nil
			Tactics.apply(a,action,anchor);a.focusTarget=if action=="Focus" then Target.enemy(a,enemies,nil,Config.DetectionRange,now) else nil
			a.model:SetAttribute("TacticalPreset",a.tactic or "Balanced")
			observe(leader.owner,"hero_order_accepted",{order=action})
			a.model:SetAttribute("CompanionOrder",a.order)
			return true,"OK"
		end
		-- Re-evaluate bounds at receipt time; never trust stale 5 Hz active flags.
		if not a.model.Parent or not contains(s,a) then return false,"EnterCamp" end
		if not leader.model.Parent or not contains(s,leader) then return false,"EnterCamp" end
		a.session=s;leader.session=s
		local role=Config.Classes[a.class]
		-- Resolve only from committed server progression, never a client ability ID.
		local allowed=Expansion.allowedSkills(build,role.Ability)
		a.allowedAbilities=allowed
		local slot=({Ability1=1,Ability2=2,Ability3=3})[action]
		local slots=Expansion.skillSlots(build,role.Ability)
		local skill=if slot then slots[slot] else a.ability or role.Ability
		if not skill then return false,"SkillNotLearned" end
		if action~="Basic" and action~="Ability" and not slot then return false,"InvalidRequest" end
		local def=Config.Abilities[skill]
		local target=if action~="Basic" and def.Effect=="Heal" then Target.heal(a,if phases then (if def.Group then phases.Own(a)else phases.Support())else s.allies or {},def.Range)
			else Target.enemy(a,enemies,nil,if action=="Basic" then a.stats.AttackRange else def.Range,now)
		if not target then return false,"NoTarget" end
		if action~="Basic" then return Abilities.cast(a,skill,target,enemies,now) end
		local ok=Abilities.basic(a,target,now)
		return ok,if ok then "OK" else "Cooldown"
	end
	function service.Remove(player:Player,s:any) if not phases then Regional.Remove(player,s)end end
	return service
end
