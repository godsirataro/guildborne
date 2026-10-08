--!strict
-- Synthetic physical authorization and real CombatService sync, without profile writes.
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local services=game.ServerScriptService.Server.Services
    local fixture=Instance.new("Model");fixture.Name="StatusPointSafetyFixture";fixture.Parent=workspace
    -- MCP's module environment does not share Bootstrap's frozen Content instance.
    local worldModule=services.ExpansionWorld:Clone();worldModule.Name="StatusWorldFixtureModule"
    worldModule.Source=worldModule.Source:gsub('local Content=require%(script.Parent.Parent.Config.Content%)','local Content={StatusAllocationAvailable=true}')
    worldModule.Parent=services
    local ok,result=pcall(function():any
        local avatar=Instance.new("Model");avatar.Name="SyntheticStatusHero";avatar.Parent=fixture
        local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.Parent=avatar;avatar.PrimaryPart=root
        local humanoid=Instance.new("Humanoid");humanoid.RequiresNeck=false;humanoid.Parent=avatar
        local station=Instance.new("Part");station.Anchored=true;station.CanCollide=false;station.CanQuery=false;station.Position=Vector3.new(26000,100,0);station.Parent=fixture
        root.Position=station.Position+Vector3.new(0,0,10);avatar:SetAttribute("CombatHealth",7)
        local plot={model=fixture,hallStation=station,origin=station.Position}
        local player:any={UserId=-992,Character=avatar}
        local world=(require :: any)(worldModule)(function()end,function()end)
        local checks=0
        for _,action in ipairs({"AllocateStatus","ResetBuildPoints"}) do
            assert(world.validate(player,plot,action,{})==nil);checks+=1
            root.Position=station.Position+Vector3.new(0,0,25)
            assert(world.validate(player,plot,action,{})=="ReturnToHallForPoints");checks+=1
            root.Position=station.Position+Vector3.new(0,0,10);fixture:SetAttribute("InCombat",true)
            assert(world.validate(player,plot,action,{})=="ReturnToHallForPoints");checks+=1
            fixture:SetAttribute("InCombat",false);avatar:SetAttribute("CombatHealth",0)
            assert(world.validate(player,plot,action,{})=="Downed");checks+=1;avatar:SetAttribute("CombatHealth",7)
        end
        local templates=Instance.new("Folder");templates.Parent=fixture
        local combat=require(services.CombatService)(templates,function()end,function()end)
        local points=require(game.ReplicatedStorage.Shared.Data.StatusPoints)
        local actor:any={class="Priest",health=7,state="Recover",cooldowns={heal=42},nextAbility=50,nextAttack=51}
        local hero={model=avatar,root=root,humanoid=humanoid,combat=actor}
        local desc:any={class="Priest",level=10,weapon="apprentice_staff",build={tier=1,skills={}},state="Following",extra=points.bonuses("Priest",{VIT=15,WIS=12})}
        combat.Sync(hero,desc,player,{})
        local boosted=actor.stats.MaxHealth;assert(actor.stats.HealPower==6)
        assert(actor.health==7 and actor.state=="Recover" and actor.cooldowns.heal==42 and actor.nextAbility==50 and actor.nextAttack==51)
        desc.extra=points.bonuses("Priest",nil);combat.Sync(hero,desc,player,{})
        assert(boosted-actor.stats.MaxHealth==30 and actor.stats.HealPower==0)
        assert(actor.health==7 and actor.cooldowns.heal==42 and actor.nextAbility==50 and actor.nextAttack==51)
        return {spatialChecks=checks,healthPreserved=true,cooldownsPreserved=true,derivedStatsUpdated=true,profileWrites=0,physicalDevicesTested=false}
    end)
    worldModule:Destroy();fixture:Destroy();assert(ok,tostring(result));return result
end
