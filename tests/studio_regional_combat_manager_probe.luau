--!strict
-- Synthetic players/parties against existing offline terrain, never real player profiles.
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local server=game.ServerScriptService.Server
    local city=require(game.ReplicatedStorage.Shared.Config.City)
    local prior={}
    for _,id in ipairs(city.RegionOrder) do local map=workspace.GuildborneWorld:FindFirstChild(id) :: Model
        prior[id]={map=map,enabled=map:GetAttribute("EncountersEnabled"),mode=map:GetAttribute("EncounterMode")}
    end
    local fixture=Instance.new("Model");fixture.Name="RegionalManagerReview";fixture.Parent=workspace
    local hits=0;local rewardCalls=0
    local space=require(server.Systems.CombatSpace)(city)
    local target=require(server.Systems.CombatTargeting)(function(a:any,b:any)return (a.root.Position-b.root.Position).Magnitude end,space.hostile)
    local damage=require(server.Systems.CombatDamage)({valid=function(n:number)return n>=0 end,damage=function()return 1 end},target,function()hits+=1 end)
    local manager=require(server.Services.RegionalCombat)(damage,function()return function()rewardCalls+=1;return "Rejected"end end)
    local parties={}
    local function party(owner:number):any
        local attrs={CurrentZone="Greenwood"}
        local player:any={UserId=owner,GetAttribute=function(_:any,k:string)return attrs[k]end,SetAttribute=function(_:any,k:string,v:any)attrs[k]=v end}
        local camp=Instance.new("Model");camp.Name="SyntheticCamp";camp.Parent=fixture
        local s:any={origin=Vector3.zero,plot=fixture,active=true,characterData={classId="Warrior"},heroes={},campEnemies={{model=camp,health=100}}}
        s.enemies=s.campEnemies
        local model=Instance.new("Model");model.Name="SyntheticHero";model.Parent=fixture
        local root=Instance.new("Part");root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.Parent=model
        local hero={id="player",kind="Hero",owner=owner,session=s,model=model,root=root,health=1000,active=true,state="Idle",stats={MaxHealth=1000,Defense=0},threat={}}
        local p={player=player,s=s,hero=hero,attrs=attrs,camp=camp};table.insert(parties,p);return p
    end
    local ok,result=pcall(function():any
        local a=party(-801);local b=party(-802);manager.Sync(a.player,a.s);manager.Sync(b.player,b.s)
        assert(#a.s.enemies==4 and #b.s.enemies==4 and a.camp.Parent==nil)
        local scout=a.s.enemies[1];a.hero.root.Position=scout.root.Position+Vector3.new(0,0,4)
        b.hero.root.Position=a.hero.root.Position
        manager.Step(a.s,{b.hero},0,.2);assert(hits==0,"Foreign party damage")
        manager.Step(a.s,{a.hero},1,.2);assert(hits==1)
        a.hero.root.Position=Vector3.new(0,5,1491)
        manager.Step(a.s,{a.hero},3,.2);assert(hits==1,"Safe zone damage")
        for _,enemy in ipairs(a.s.enemies) do assert(enemy.targetId==nil) end
        a.attrs.CurrentZone="City";manager.Sync(a.player,a.s)
        assert(a.s.adventureRegion==nil and a.attrs.RegionalCombatEnabled==nil and a.camp.Parent==fixture)
        assert(a.s.adventures.Greenwood.model.Parent==nil and b.s.adventures.Greenwood.model.Parent==workspace)
        a.attrs.CurrentZone="Greenwood";manager.Sync(a.player,a.s);assert(a.s.enemies[1]==scout,"Travel recreated encounter")
        for _,region in ipairs({"Ironveil","Ashen"}) do
            a.attrs.CurrentZone=region;manager.Sync(a.player,a.s);assert(#a.s.enemies==4 and a.s.adventureRegion==region)
            local d=city.Destinations[region];a.hero.root.Position=Vector3.new(d.X,d.Y,d.Z)
            manager.Step(a.s,{a.hero},5,.2);assert(hits==1,"Arrival dock damage")
        end
        a.s.towerRun={state="Fighting"};manager.Sync(a.player,a.s)
        assert(a.s.adventureRegion==nil and a.s.enemies==a.s.campEnemies)
        assert(rewardCalls==0)
        return {parties=2,regions=3,foreignPartyBlocked=true,safeDocks=true,travelRetainsActors=true,towerRestoresCamp=true,profileWrites=0}
    end)
    for _,p in ipairs(parties) do manager.Remove(p.player,p.s) end
    fixture:Destroy()
    for _,entry in pairs(prior) do entry.map:SetAttribute("EncountersEnabled",entry.enabled);entry.map:SetAttribute("EncounterMode",entry.mode) end
    assert(ok,tostring(result));return result
end
