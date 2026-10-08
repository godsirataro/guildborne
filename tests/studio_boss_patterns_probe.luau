--!strict
-- Synthetic runtime session; never calls the profile, tower reward or player remotes.
return function(): any
	local folder=Instance.new("Folder");folder.Name="UATBossFixture";folder.Parent=workspace
	local ok,result=xpcall(function()
		local service=require(game.ServerScriptService.Server.Services.CombatService)(folder,function() error("Unexpected reward") end,function() error("Unexpected tower result") end)
		local function actor(id: string,kind: string,z: number): any
			local m=Instance.new("Model");m.Name=id;m.Parent=folder
			local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Anchored=true;root.Transparency=1;root.CanCollide=false;root.Position=Vector3.new(0,4,z);root.Parent=m;m.PrimaryPart=root
			local hum=Instance.new("Humanoid");hum.Parent=m
			return {id=id,kind=kind,class=if kind=="Hero" then "Warrior" else nil,owner=-1,model=m,root=root,
				active=true,health=1000,state="Idle",cooldowns={},threat={},nextAbility=math.huge,nextAttack=if kind=="Hero" then math.huge else 0,
				stats={Attack=10,Defense=1,MaxHealth=1000,AttackRange=5,AttackInterval=3,DetectionRange=26,MoveSpeed=12}}
		end
		local hero,boss=actor("h:test","Hero",84),actor("g:test","Enemy",80)
		boss.boss=true;boss.towerFloor=5;boss.home=boss.root.Position
		local s: any={alive=true,active=true,origin=Vector3.zero,plot=folder,
			heroes={[hero.id]={state="Following",combat=hero,root=hero.root,humanoid=hero.model:FindFirstChildOfClass("Humanoid")}},enemies={boss}}
		local function step(now: number,valid: boolean?) service.Step({Character=nil} :: any,s,hero.root,valid~=false,now,function() end) end
		step(0);assert(boss.pendingPattern and boss.model:GetAttribute("TelegraphRadius")==5)
		local fixed=boss.model:GetAttribute("ActionTargetPosition")
		hero.root.Position=Vector3.new(0,4,94);step(1.2)
		assert(hero.health==1000 and boss.model:GetAttribute("TelegraphAt")==nil);assert(fixed==Vector3.new(0,4,84));assert(boss.model:GetAttribute("BossImpactAt")~=nil)
		hero.root.Position=Vector3.new(0,4,84);boss.health=500;step(4.2)
		assert(boss.pendingPattern.name=="Warden Pulse" and boss.model:GetAttribute("TelegraphRadius")==10)
		step(6.01);assert(hero.health<1000);local after=hero.health;assert(boss.model:GetAttribute("BossPhase")==2)
		step(6.21);assert(hero.health==after,"Impact repeated")
		step(9.1);assert(boss.pendingPattern);step(9.2,false)
		assert(boss.pendingPattern==nil and boss.model:GetAttribute("TelegraphAt")==nil)
		step(10.4,false);assert(hero.health==after,"Cancelled attack released")
		return {lockedFootprint=true,escapedSlam=true,phaseTwoPulse=true,impactOnce=true,cancelledOnDisengage=true,noProfileWrites=true}
	end,debug.traceback)
	folder:Destroy();assert(ok,result);return result
end
