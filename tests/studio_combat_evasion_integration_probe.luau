--!strict
-- Full CombatService scheduler with a synthetic party and physical R15; no profiles.
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local services=game.ServerScriptService.Server.Services
    local fixture=Instance.new("Model");fixture.Name="CombatEvasionIntegration";fixture.Parent=workspace
    local templates=Instance.new("Folder");templates.Parent=fixture
    local service=require(services.CombatService)(templates,function()error("No camp rewards")end,function()error("No tower rewards")end,
        function()return function()error("No expected regional deaths")end end)
    local attrs={CurrentZone="Ironveil"}
    local player:any={UserId=-998,GetAttribute=function(_:any,key:string)return attrs[key]end,SetAttribute=function(_:any,key:string,value:any)attrs[key]=value end}
    local map=workspace.GuildborneWorld.Ironveil
    local priorEnabled,priorMode=map:GetAttribute("EncountersEnabled"),map:GetAttribute("EncounterMode")
    local session:any={origin=Vector3.zero,plot=fixture,active=true,alive=true,characterData={classId="Warrior"},heroes={},campEnemies={}}
    session.enemies=session.campEnemies
    local ok,result=pcall(function():any
        local description=Instance.new("HumanoidDescription")
        local avatar=game.Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15);description:Destroy()
        avatar.Name="SyntheticKnight";avatar.Parent=fixture;avatar:PivotTo(CFrame.new(500,14,1340))
        local root=avatar:FindFirstChild("HumanoidRootPart") :: BasePart
        local humanoid=avatar:FindFirstChildOfClass("Humanoid") :: Humanoid
        root:SetNetworkOwner(nil);humanoid.AutoJumpEnabled=false;task.wait(.4)
        local leader=Instance.new("Part");leader.Anchored=true;leader.CanCollide=false;leader.CanQuery=false;leader.Transparency=1
        leader.Position=Vector3.new(500,13,1350);leader.Parent=fixture
        local actor:any={id="a:Knight",class="Knight",kind="Hero",owner=-998,model=avatar,root=root,health=40,
            stats={MaxHealth=40,Attack=1,Defense=7,MoveSpeed=17,AttackRange=5,AttackInterval=1.5},state="Follow",cooldowns={},threatMultiplier=3,plot=fixture}
        local hero={combat=actor,model=avatar,root=root,humanoid=humanoid,state="Following",slot=1,generation=0}
        session.heroes[actor.id]=hero
        local normalWalks=0
        local function walk(_session:any,h:any,goal:Vector3,_now:number)
            assert(h.combat.state~="Evade","Evasion used follower recovery path")
            normalWalks+=1;h.humanoid:MoveTo(goal)
        end
        local start=root.Position;service.Step(player,session,leader,true,os.clock(),walk)
        local boss=session.enemies[4];assert(boss.templateId=="quarry_guardian")
        local pattern=boss.pendingPattern;assert(pattern and pattern.name=="Hammer Fall")
        local evades=if actor.state=="Evade" then 1 else 0
        repeat
            task.wait(.1);service.Step(player,session,leader,true,os.clock(),walk)
            if actor.state=="Evade" then evades+=1 end
        until os.clock()>pattern.due+.1
        assert(evades>=3,"No repeated evasion hold")
        assert(actor.health==40,"Companion took avoidable Hammer Fall damage")
        assert((root.Position-start).Magnitude>7,"Companion failed to walk clear")
        assert(hero.generation>0,"Stale navigation was not invalidated")
        return {evadeTicks=evades,health=actor.health,walkedStuds=(root.Position-start).Magnitude,
            normalWalkCalls=normalWalks,combatServiceIntegrated=true,profileWrites=0}
    end)
    service.Remove(player,session);fixture:Destroy();map:SetAttribute("EncountersEnabled",priorEnabled);map:SetAttribute("EncounterMode",priorMode)
    assert(ok,tostring(result));return result
end
