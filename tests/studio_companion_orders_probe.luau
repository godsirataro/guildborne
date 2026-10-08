--!strict
-- Synthetic actors only; movement is captured, not applied to any real character.
return function(): any
	local folder=Instance.new("Folder");folder.Name="UATOrdersFixture";folder.Parent=game.ServerStorage
	local ok,result=xpcall(function()
		local service=require(game.ServerScriptService.Server.Services.CombatService)(folder,function() error("Unexpected reward") end,function() error("Unexpected tower result") end)
		local function actor(id: string,kind: string,z: number): any
			local m=Instance.new("Model");m.Name=id;m.Parent=folder
			local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Anchored=true;root.Position=Vector3.new(0,4,z);root.Parent=m;m.PrimaryPart=root;Instance.new("Humanoid",m)
			return {id=id,kind=kind,class=if kind=="Hero" then "Warrior" else nil,owner=-1,model=m,root=root,
				active=true,health=1000,state="Idle",cooldowns={},threat={},stats={Attack=10,Defense=1,MaxHealth=1000,AttackRange=5,AttackInterval=1,MoveSpeed=17,DetectionRange=26}}
		end
		local player,hero,enemy=actor("player","Hero",80),actor("h:1","Hero",81),actor("g:1","Enemy",83)
		hero.build={tier=1,skills={}};enemy.nextAttack=math.huge;enemy.home=enemy.root.Position;enemy.towerFloor=1
		local h: any={state="Following",combat=hero,root=hero.root,slot=1,humanoid=hero.model:FindFirstChildOfClass("Humanoid")}
		local s: any={alive=true,active=true,plot=folder,origin=Vector3.zero,playerCombat=player,playerBuild={tier=1,skills={}},heroes={[hero.id]=h},enemies={enemy}}
		local moves={}
		local function step(now: number) service.Step({Character=nil} :: any,s,player.root,true,now,function(_s: any,_h: any,goal: Vector3) table.insert(moves,goal) end) end
		local function command(action: string,id: string?): (boolean,string) player.active=true;return service.PlayerAction(s,action,0,id or hero.id) end
		assert(command("Regroup"));step(0)
		assert(hero.order=="Regroup" and enemy.health==1000 and next(hero.cooldowns)==nil and not h.combatMove)
		assert(command("Retreat"));step(1)
		assert(h.combatMove and #moves==1 and moves[1].Z<hero.root.Position.Z)
		assert((moves[1]-hero.root.Position).Magnitude<=12.01 and enemy.health==1000)
		assert(command("Focus"));step(2);assert(enemy.health<1000 and hero.focusTarget==enemy)
		local cooldown=hero.cooldowns.power_strike;assert(cooldown)
		assert(command("Regroup"));assert(hero.cooldowns.power_strike==cooldown)
		local accepted,code=command("Retreat","player");assert(not accepted and code=="Select a companion first")
		accepted=command("Retreat","h:foreign");assert(not accepted)
		hero.owner=-2;accepted=command("Retreat");assert(not accepted);hero.owner=-1
		h.state="Resting at guild";accepted=command("Retreat");assert(not accepted);h.state="Following"
		hero.health=0;accepted=command("Retreat");assert(not accepted);hero.health=1000
		hero.root.Position=Vector3.new(0,4,23);player.root.Position=Vector3.new(0,4,90)
		assert(command("Focus"));accepted,code=command("Basic");assert(not accepted and tostring(code)=="CompanionUnavailable")
		assert(hero.cooldowns.power_strike==cooldown)
		return {regroupSuppressesOffense=true,retreatWalkGoalBounded=true,focusResumesAttack=true,cooldownsPreserved=true,
			foreignRestingDownedRejected=true,remoteResumeAllowed=true,remoteCastStillRejected=true,noProfileWrites=true}
	end,debug.traceback)
	folder:Destroy();assert(ok,result);return result
end
