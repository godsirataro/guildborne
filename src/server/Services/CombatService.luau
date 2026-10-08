--!strict
-- One bounded update per plot, called by the existing follower scheduler.
local City=require(game.ReplicatedStorage.Shared.Config.City)
local Config=require(script.Parent.Parent.Config.Combat)
local Content=require(script.Parent.Parent.Config.Content)
local Expansion=require(game.ReplicatedStorage.Shared.Data.Expansion)
local AudioConfig=require(game.ReplicatedStorage.Shared.Config.AudioConfig)
local Gear=require(game.ReplicatedStorage.Shared.Data.Equipment)(Content,Expansion,require(game.ReplicatedStorage.Shared.Data.StatusPoints))
local Stats=require(script.Parent.Parent.Systems.CombatStats)(Content,Config,Gear)
local Space=require(script.Parent.Parent.Systems.CombatSpace)(City)
local sight=require(script.Parent.CombatLineOfSight)(workspace:WaitForChild("GuildborneWorld"))
local Target=require(script.Parent.Parent.Systems.CombatTargeting)(function(a: any,b: any) return (a.root.Position-b.root.Position).Magnitude end,Space.hostile,sight)
local Lifecycle=require(script.Parent.Parent.Systems.EnemyLifecycle)
local BossPatterns=require(script.Parent.Parent.Systems.BossPatterns)
local Http=game:GetService("HttpService")
local V=Vector3.new
return function(templates: Folder, reward: any,towerResult: any,regionalRewardFactory:any?)
	local Enemy=require(script.Parent.EnemyService)(templates)
	local service={}
	local Rig=require(script.Parent.HeroRig)
	local participation=require(script.Parent.Parent.Systems.PlayerParticipation)
	local function emit(name: string,a: any,b: any,value: any)
		if name=="enemy_basic_attack" then a.model:SetAttribute("EnemyActionAt",workspace:GetServerTimeNow()) end
		-- A commanded companion can land a killing blow before the next AI step.
		-- Capture the same server-owned party snapshot the AI uses, exactly once.
		if name=="damage_dealt" and a.id~="player" and a.kind=="Hero" and b.kind=="Enemy" and not b.participants then
			b.participants={}
			for _,member in ipairs(if a.session then a.session.allies or {} else {a}) do
				if member.id~="player" and member.owner==a.owner and member.active then table.insert(b.participants,member.id) end
			end
		end
		participation(name,a,b,value,if a.session then a.session.enemies else {},os.clock())
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
		s.enemies=Enemy.create(s.plot,s.origin,player.UserId)
		s.campEnemies=s.enemies
		for _,e in ipairs(s.enemies) do e.plot=s.plot;e.session=s end
		s.combat=false
	end
	function service.TowerSync(player: Player,s: any,run: any)
		local key=if run then run.id..":"..run.floor..":"..run.state else "camp"
		if key==s.towerKey then return end
		Regional.Stop(player,s)
		local previous=s.towerKey;s.towerKey=key;s.towerRun=run;s.towerPending=false;s.towerDone=false
		for _,h in pairs(s.heroes or {}) do if h.combat then h.combat.focusTarget=nil;h.combat.order=nil end end
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
		if not h.combat.active then h.combat.order=nil;h.combat.focusTarget=nil end
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
	function service.Step(player: Player,s: any,leader: BasePart?,valid: boolean,now: number,walk: any)
		Regional.Sync(player,s)
		local function combatWalk(h: any,goal: Vector3)
			local region=s.adventureRegion and City.Regions[s.adventureRegion]
			local safe=if region then V(math.clamp(goal.X,region.X-region.HalfWidth+5,region.X+region.HalfWidth-5),goal.Y,math.clamp(goal.Z,region.Z-region.Back+5,region.Z+88))
				else V(math.clamp(goal.X,s.origin.X-34,s.origin.X+34),s.origin.Y+3,math.clamp(goal.Z,s.origin.Z+49,s.origin.Z+112))
			walk(s,h,safe,now)
		end
		local character=player.Character
		if s.towerPosition and character and leader then character:PivotTo(CFrame.new(s.origin+V(0,4,63)));s.towerPosition=false;s.reset=true end
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
				if h.combat.active then table.insert(allies,h.combat) end
				h.combatMove=false
			end
		end
		local p=s.playerCombat
		if p then p.session=s end
		if p and p.active then table.insert(allies,p) end
		s.allies=allies;for _,a in ipairs(allies) do a.allies=allies end
		local engage=valid and leader~=nil and Space.contains(s,leader.Position) and #allies>0
		s.engage=engage
		local recovery=Config.RecoveryPerSecond
		if s.expansionData then for _,b in pairs(s.expansionData.buildings) do if b.kind=="quarters" then recovery*=1.5;break end end end
		local fighting=Regional.Step(s,if engage then allies else {},now,Config.Tick)
		for _,e in ipairs(s.enemies) do
			if e.templateId then continue end
			e.session=s
			if e.health==0 then
				BossPatterns.cancel(e,now);e.model:SetAttribute("TelegraphAt",nil)
				if not e.towerFloor and Lifecycle.claimDeath(e) then
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
				if now-(e.downedAt or now)>=2 then e.model.Parent=nil end
				if not e.towerFloor and not e.rewardPending and now-(e.downedAt or now)>=Config.Goblin.RespawnSeconds then Enemy.reset(e) end
			else
				local outside=(e.root.Position-e.home).Magnitude>Config.EnemyLeash
				if not engage or outside then
					BossPatterns.cancel(e,now);e.model:SetAttribute("TelegraphAt",nil)
					e.target=nil; e.threat={}; e.tauntTarget=nil; e.tauntUntil=nil; e.state="ReturnToLeader"
					Enemy.move(e,e.home,Config.Tick)
					if (e.root.Position-e.home).Magnitude<1 then e.health=e.stats.MaxHealth; e.state="Idle"; e.participants=nil; e.playerParticipated=nil end
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
		for _,h in pairs(s.heroes) do
			local a=h.combat
			if not a then continue end
			if a.active and leader then
				local close=(a.root.Position-leader.Position).Magnitude<=Config.LeaderLeash
				local held=a.order=="Regroup" or a.order=="Retreat"
				local escape=if a.health>0 and not held then Regional.Dodge(s,a,now) else nil
				local focus=a.focusTarget
				local enemy=if engage and close and not held then
					(if focus and table.find(s.enemies,focus) and Target.valid(a,focus,Config.DetectionRange) then focus else Target.enemy(a,s.enemies,a.previousTarget,Config.DetectionRange,now)) else nil
				a.target=enemy; a.previousTarget=enemy
				if a.health<=0 then
					a.order=nil;a.focusTarget=nil
					a.state="Downed"; h.combatMove=true; h.humanoid:MoveTo(a.root.Position)
					if not fighting and now-(a.downedAt or now)>=Config.DownSeconds then a.health=a.stats.MaxHealth*.5; a.state="Recover" end
				elseif escape then
					fighting=true;h.combatMove=true;a.state="Evade";h.humanoid.WalkSpeed=a.stats.MoveSpeed
					-- Corridor was checked by RegionalEvasion. Avoid the follower's recovery teleport.
					if h.evadeStamp~=a.evasion.stamp then h.evadeStamp=a.evasion.stamp;h.generation+=1;h.path=nil end
					if h.root.Anchored then h.root.Anchored=false;h.root:SetNetworkOwner(nil) end
					h.humanoid:MoveTo(escape)
				elseif enemy then
					if not enemy.participants then
						enemy.participants={}; for _,member in ipairs(allies) do if member.id~="player" then table.insert(enemy.participants,member.id) end end
					end
					fighting=true; h.combatMove=true
					local role=Config.Classes[a.class];local skill=a.ability or role.Ability; local def=Config.Abilities[skill]
					local abilityTarget=if def.Effect=="Heal" then Target.heal(a,allies,def.Range) else enemy
					local cast=Abilities.cast(a,skill,abilityTarget,s.enemies,now)
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
					h.humanoid.WalkSpeed=a.stats.MoveSpeed
					if cast then a.state="CastAbility" else Abilities.basic(a,enemy,now) end
				else
					a.state=if close then "Follow" else "ReturnToLeader"
					if a.order=="Retreat" then
						a.state="Retreat";h.combatMove=true
						local slot=h.slot or 1
						local destination=s.adventureRegion and City.Destinations[s.adventureRegion]
						local home=if destination then V(destination.X+((slot-1)%3-1)*3,destination.Y,destination.Z+math.floor((slot-1)/3)*3)
							else s.origin+V(((slot-1)%3-1)*3,3,23+math.floor((slot-1)/3)*3)
						local delta=home-a.root.Position
						-- Short goals preserve walking; avoid the follower's long-distance recovery teleport.
						walk(s,h,if delta.Magnitude>12 then a.root.Position+delta.Unit*12 else home,now)
					elseif a.order=="Regroup" then a.state="Regroup" end
					if not fighting and now-(a.lastHit or 0)>Config.RecoveryDelay and a.health<a.stats.MaxHealth then
						a.health=math.min(a.stats.MaxHealth,a.health+recovery*Config.Tick); a.state="Recover"
					end
					local skill=a.ability or Config.Classes[a.class].Ability;local def=Config.Abilities[skill]
					if not City.contains(leader.Position.X,leader.Position.Z) and def.Effect=="Heal" then Abilities.cast(a,skill,Target.heal(a,allies,def.Range),s.enemies,now) end
				end
			end
			publish(a,now)
		end
		if p and character and p.model==character then
			local humanoid=character and character:FindFirstChildOfClass("Humanoid")
			if p.health<=0 then
				p.state="Downed"
				if humanoid then humanoid.WalkSpeed=0; humanoid.JumpPower=0; humanoid.JumpHeight=0 end
				if now-(p.downedAt or now)>=Config.DownSeconds then
					p.health=p.stats.MaxHealth*.5; p.state="Recover"; p.lastHit=now
					local destination=s.adventureRegion and City.Destinations[s.adventureRegion]
					character:PivotTo(CFrame.new(if destination then V(destination.X,destination.Y,destination.Z) else s.origin+V(0,4,23))); s.reset=true
				end
			else
				if humanoid then humanoid.WalkSpeed=p.stats.MoveSpeed; humanoid.JumpPower=50; humanoid.JumpHeight=7.2 end
				p.state=if fighting then "Attack" else "Idle"
				if not fighting and now-(p.lastHit or 0)>Config.RecoveryDelay then p.health=math.min(p.stats.MaxHealth,p.health+recovery*Config.Tick) end
			end
			publish(p,now)
		end
		for _,e in ipairs(s.enemies) do publish(e,now) end
		local run=s.towerRun
		if run and run.state=="Fighting" and not s.towerPending and not s.towerDone then
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
	function service.PlayerAction(s: any, action: string, now: number, actorId: string?): (boolean,string)
		local leader=s.playerCombat
		if not s.active or not leader or not Target.alive(leader) or not leader.model:FindFirstChildOfClass("Humanoid") or leader.model:FindFirstChildOfClass("Humanoid").Health<=0 then return false,"NotReady" end
		local a=leader; local build=s.playerBuild
		local isOrder=action=="Focus" or action=="Regroup" or action=="Retreat"
		if actorId and actorId~="player" then
			local hero=s.heroes and s.heroes[actorId]
			if not hero or hero.state~="Following" or not hero.combat or hero.combat.owner~=leader.owner or not Target.alive(hero.combat) then return false,"CompanionUnavailable" end
			a=hero.combat;build=a.build
			if not build or (not isOrder and (a.root.Position-leader.root.Position).Magnitude>Config.LeaderLeash) then return false,"CompanionUnavailable" end
		end
		if isOrder then
			if a==leader then return false,"Select a companion first" end
			if not a.model.Parent then return false,"CompanionUnavailable" end
			-- Orders only affect owned AI movement/selection; they never cast, heal or refill cooldowns.
			a.order=action;a.focusTarget=if action=="Focus" then Target.enemy(a,s.enemies,nil,Config.DetectionRange,now) else nil
			a.model:SetAttribute("CompanionOrder",action)
			return true,"OK"
		end
		-- Re-evaluate bounds at receipt time; never trust stale 5 Hz active flags.
		if not a.model.Parent or not Space.contains(s,a.root.Position) then return false,"EnterCamp" end
		if not leader.model.Parent or not Space.contains(s,leader.root.Position) then return false,"EnterCamp" end
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
		local target=if action~="Basic" and def.Effect=="Heal" then Target.heal(a,s.allies or {},def.Range)
			else Target.enemy(a,s.enemies,nil,if action=="Basic" then a.stats.AttackRange else def.Range,now)
		if not target then return false,"NoTarget" end
		if action~="Basic" then return Abilities.cast(a,skill,target,s.enemies,now) end
		local ok=Abilities.basic(a,target,now)
		return ok,if ok then "OK" else "Cooldown"
	end
	function service.Remove(player:Player,s:any) Regional.Remove(player,s) end
	return service
end
