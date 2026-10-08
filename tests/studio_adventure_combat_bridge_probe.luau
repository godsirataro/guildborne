--!strict
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local server=game.ServerScriptService.Server
    local session={};local now=0;local rewards={};local events=0
    local sight:any=nil
    local targeting=require(server.Systems.CombatTargeting)(function(a:any,b:any)return (a.root.Position-b.root.Position).Magnitude end,
        function(a:any,b:any)return a.session==session and b.session==session end,
        function(a:any,b:any)return sight==nil or sight(a,b)end)
    local stats={valid=function(n:number)return n==n and n>=0 and n<1e6 end,damage=function(attack:number,defense:number,multiplier:number)return math.max(1,math.floor(attack*multiplier-defense))end}
    local damage=require(server.Systems.CombatDamage)(stats,targeting,function(event:string,a:any,b:any)
        events+=1
        if event=="damage_dealt" and a.id=="player" and b.kind=="Enemy" then b.playerParticipated=true end
    end)
    local bridge=require(server.Services.AdventureCombatBridge)("Greenwood",Vector3.new(21000,100,0),-700,session,damage,function(ticket:any)
        table.insert(rewards,ticket);return "Committed"
    end,function()return now end)
    sight=require(server.Services.CombatLineOfSight)(bridge.model)
    local heroModel=Instance.new("Model");heroModel.Name="SyntheticCombatHero";heroModel.Parent=workspace
    local root=Instance.new("Part");root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.Parent=heroModel
    local hero={id="player",kind="Hero",owner=-700,session=session,model=heroModel,root=root,active=true,state="Idle",health=500,
        stats={MaxHealth=500,Attack=20,Defense=4},threat={}}
    local ok,result=pcall(function():any
        local scout=bridge.actors[1];root.Position=scout.root.Position+Vector3.new(0,0,4)
        local original=scout.health
        assert(damage.hit(hero,scout,5,1,0)==17 and scout.health==original-17)
        now=.2;bridge.Step({hero},now,.2);assert(hero.health==492,"Regional attack bypassed shared defense math")
        assert(scout.playerParticipated==true,"Initial step erased participation")
        hero.owner=-701;assert(damage.hit(hero,scout,5,1,1)==0);hero.owner=-700
        local wall=Instance.new("Part");wall.Anchored=true;wall.Size=Vector3.new(6,8,.2);wall.Position=(root.Position+scout.root.Position)/2;wall.Parent=bridge.model
        assert(damage.hit(hero,scout,5,1,2)==0,"Regional attack crossed physical wall")
        wall:Destroy()
        hero.stats.Attack=1000;assert(damage.hit(hero,scout,5,1,3)>0 and scout.health==0)
        now=3;bridge.Step({hero},now,.2);task.wait(.05)
        assert(#rewards==1 and rewards[1].encounterId=="greenwood_scout" and rewards[1].members[1]=="player")
        bridge.Suspend();bridge.Resume();now=4;bridge.Step({hero},now,.2);assert(#rewards==1 and scout.health==0)
        root.Position+=Vector3.new(0,0,60);now=21;bridge.Step({hero},now,.2)
        assert(scout.health==scout.maxHealth and scout.playerParticipated==nil and next(scout.threat)==nil)
        assert(scout.model:GetAttribute("CombatHealth")==scout.maxHealth)
        return {damageUsesSharedAuthority=true,defenseApplied=true,foreignOwnerBlocked=true,lineOfSightBlocked=true,
            rewardCount=#rewards,respawnClearedParticipation=true,events=events,profileWrites=0}
    end)
    bridge.Destroy();heroModel:Destroy();assert(ok,tostring(result));return result
end
