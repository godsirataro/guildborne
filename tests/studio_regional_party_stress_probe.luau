--!strict
-- Four synthetic parties on shared terrain. Server timing/isolation, not real-client FPS or balance.
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local server=game.ServerScriptService.Server
    local city=require(game.ReplicatedStorage.Shared.Config.City)
    local fixture=Instance.new("Model");fixture.Name="RegionalPartyStressFixture";fixture.Parent=workspace
    local prior={};local parties={};local rewardCounts={};local hits=0;local dodgeChoices=0
    for _,region in ipairs(city.RegionOrder) do
        local map=workspace.GuildborneWorld:FindFirstChild(region) :: Model
        prior[region]={map=map,enabled=map:GetAttribute("EncountersEnabled"),mode=map:GetAttribute("EncounterMode")}
    end
    local space=require(server.Systems.CombatSpace)(city)
    local target=require(server.Systems.CombatTargeting)(function(a:any,b:any)return (a.root.Position-b.root.Position).Magnitude end,space.hostile)
    local damage=require(server.Systems.CombatDamage)({valid=function(n:number)return n>=0 and n<1e9 end,damage=function()return 1 end},target,
        function(event:string,a:any,b:any)
            if event=="damage_dealt" then assert(a.owner==b.owner and a.session==b.session,"Cross-party damage");hits+=1 end
        end)
    local manager=require(server.Services.RegionalCombat)(damage,function(player:any)
        return function(ticket:any)
            assert(ticket.owner==player.UserId,"Cross-party reward owner")
            local key=tostring(player.UserId)..":"..ticket.deathId
            rewardCounts[key]=(rewardCounts[key] or 0)+1;return "Committed"
        end
    end)
    local function makeParty(index:number):any
        local owner=-9300-index;local attrs={CurrentZone="Greenwood"}
        local player:any={UserId=owner,GetAttribute=function(_:any,k:string)return attrs[k]end,SetAttribute=function(_:any,k:string,v:any)attrs[k]=v end}
        local s:any={origin=Vector3.zero,plot=fixture,active=true,characterData={classId="Warrior"},heroes={},campEnemies={},enemies={}}
        local actors={}
        for slot=1,6 do
            local model=Instance.new("Model");model.Name="StressHero_"..index.."_"..slot;model.Parent=fixture
            local root=Instance.new("Part");root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.Transparency=1;root.Parent=model;model.PrimaryPart=root
            local id=if slot==1 then "player" else "companion"..slot
            local actor={id=id,kind="Hero",owner=owner,session=s,model=model,root=root,health=100000,active=true,state="Idle",stats={MaxHealth=100000,Defense=0},threat={}}
            table.insert(actors,actor);s.heroes[id]={combat=actor}
        end
        local p={player=player,s=s,actors=actors,attrs=attrs};table.insert(parties,p);return p
    end
    local ok,result=pcall(function():any
        for index=1,4 do makeParty(index) end
        local reports={};local now=os.clock()
        for _,region in ipairs(city.RegionOrder) do
            for _,party in ipairs(parties) do
                party.attrs.CurrentZone=region;manager.Sync(party.player,party.s);assert(#party.s.enemies==4)
                for slot,actor in ipairs(party.actors) do
                    local enemy=party.s.enemies[math.min(slot,4)]
                    actor.root.Position=enemy.root.Position+Vector3.new((slot-4)*.3,0,4)
                end
            end
            local timings={};local beforeHits=hits;local beforeDodge=dodgeChoices
            for _=1,180 do
                now+=.1;local started=os.clock()
                for _,party in ipairs(parties) do
                    manager.Step(party.s,party.actors,now,.1)
                    for slot=2,6 do if manager.Dodge(party.s,party.actors[slot],now) then dodgeChoices+=1 end end
                end
                table.insert(timings,(os.clock()-started)*1000)
                if #timings%15==0 then task.wait(.02) end
            end
            assert(hits>beforeHits and dodgeChoices>beforeDodge,"Inactive stress region "..region)
            -- An entire foreign six-member party must be excluded even at the same coordinates.
            local hp={};for i,actor in ipairs(parties[2].actors) do hp[i]=actor.health end
            manager.Step(parties[1].s,parties[2].actors,now+1,.1)
            for i,actor in ipairs(parties[2].actors) do assert(actor.health==hp[i],"Foreign party hit") end
            for _,party in ipairs(parties) do
                for _,enemy in ipairs(party.s.enemies) do enemy.health=0;enemy.playerParticipated=true end
                manager.Step(party.s,party.actors,now+2,.1)
            end
            task.wait(.1)
            for _,party in ipairs(parties) do manager.Step(party.s,party.actors,now+2.1,.1) end
            table.sort(timings)
            table.insert(reports,{region=region,ticks=#timings,serverBatchP50Ms=timings[90],serverBatchP95Ms=timings[171],serverBatchMaxMs=timings[#timings],hits=hits-beforeHits,dodgeChoices=dodgeChoices-beforeDodge})
        end
        local rewards=0;for _,count in pairs(rewardCounts) do assert(count==1,"Duplicate reward callback");rewards+=1 end
        assert(rewards==48,"Missing synthetic death receipts: "..rewards)
        return {parties=4,actorsPerParty=6,simultaneousEnemies=16,regions=reports,syntheticRewardCallbacks=rewards,foreignDamageBlocked=true,profileWrites=0,realClients=0,physicalMovementSimulated=false,damageFormula="fixed one damage for isolation, not balance"}
    end)
    for _,party in ipairs(parties) do manager.Remove(party.player,party.s) end
    fixture:Destroy()
    for _,entry in pairs(prior) do entry.map:SetAttribute("EncountersEnabled",entry.enabled);entry.map:SetAttribute("EncounterMode",entry.mode) end
    assert(ok,tostring(result));return result
end
