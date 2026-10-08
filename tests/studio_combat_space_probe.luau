--!strict
-- Server Play only; isolated models and no profile/reward callbacks.
return function():any
    local folder=Instance.new("Folder");folder.Name="CombatBoundaryProbe";folder.Parent=game.ServerStorage
    local ok,result=pcall(function():any
        local service=require(game.ServerScriptService.Server.Services.CombatService)(folder,function()error("reward forbidden")end,function()error("tower result forbidden")end)
        local function actor(id:string,kind:string,z:number):any
            local m=Instance.new("Model");m.Name=id;m.Parent=folder
            local root=Instance.new("Part");root.Anchored=true;root.Position=Vector3.new(0,4,z);root.Name="HumanoidRootPart";root.Parent=m;m.PrimaryPart=root
            local humanoid=Instance.new("Humanoid");humanoid.Parent=m
            return {id=id,kind=kind,class=if kind=="Hero" then "Warrior" else nil,owner=-9,model=m,root=root,active=true,health=1000,state="Idle",cooldowns={},threat={},build={tier=1,skills={}},stats={Attack=10,Defense=1,MaxHealth=1000,AttackRange=10,AttackInterval=1,MoveSpeed=17,DetectionRange=26}}
        end
        local player=actor("player","Hero",52);local hero=actor("companion","Hero",47);local enemy=actor("enemy","Enemy",53)
        enemy.home=enemy.root.Position;enemy.towerFloor=1
        local h={state="Following",combat=hero,root=hero.root,slot=1,humanoid=hero.model:FindFirstChildOfClass("Humanoid")}
        local s:any={alive=true,active=true,origin=Vector3.zero,plot=folder,playerCombat=player,playerBuild=player.build,heroes={[hero.id]=h},enemies={enemy}}
        local function step(now:number)service.Step({Character=nil} :: any,s,player.root,true,now,function()end)end
        step(0);assert(hero.health==1000 and enemy.health==1000,"AI hit across safe boundary")
        hero.root.Position=Vector3.new(0,4,51);step(10)
        assert(hero.health<1000 and enemy.health<1000,"positive combat control failed")
        hero.health=1000;enemy.health=1000;hero.root.Position=Vector3.new(0,4,47);step(20)
        assert(hero.health==1000 and enemy.health==1000,"retreat did not protect both directions")
        hero.root.Position=Vector3.new(0,4,51);enemy.root.Position=Vector3.new(0,4,47);step(30)
        assert(hero.health==1000 and enemy.health==1000,"enemy outside boundary could attack")
        player.active=true
        local accepted,code=service.PlayerAction(s,"Basic",40,hero.id)
        assert(not accepted and code=="NoTarget",code)
        return {safeCompanionProtected=true,insideBothAttack=true,retreatStopsDamage=true,outsideEnemyRejected=true,commandCannotReachSafeTarget=true,noProfileWrites=true}
    end)
    folder:Destroy();assert(ok,tostring(result));return result
end
