--!strict
-- Isolated actors and synthetic heroes; never touches Players or profile persistence.
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local server=game.ServerScriptService.Server
    local reports={}
    for regionIndex,region in ipairs({"Greenwood","Ironveil","Ashen"}) do
        local session={};local now=0;local hits=0;local heals=0;local rewards={}
        local sight:any=nil
        local targeting=require(server.Systems.CombatTargeting)(function(a:any,b:any)return (a.root.Position-b.root.Position).Magnitude end,
            function(a:any,b:any)return a.session==session and b.session==session end,
            function(a:any,b:any)return sight==nil or sight(a,b)end)
        local stats={valid=function(n:number)return n==n and n>=0 and n<1e6 end,
            damage=function(attack:number,defense:number,multiplier:number)return math.max(1,math.floor(attack*multiplier-defense))end}
        local damage=require(server.Systems.CombatDamage)(stats,targeting,function(event:string,a:any,b:any,amount:number)
            if event=="damage_dealt" then
                hits+=1
                if a.kind=="Enemy" then assert(amount==math.max(1,a.stats.Attack-b.stats.Defense),"Defense mismatch") end
                if a.id=="player" and b.kind=="Enemy" then b.playerParticipated=true end
            elseif event=="healing_done" then heals+=1 end
        end)
        local bridge=require(server.Services.AdventureCombatBridge)(region,Vector3.new(24000+regionIndex*350,100,0),-901,session,damage,function(ticket:any)
            table.insert(rewards,ticket);return "Committed"
        end,function()return now end)
        sight=require(server.Services.CombatLineOfSight)(bridge.model)
        local model=Instance.new("Model");model.Name="SyntheticMatrixHero";model.Parent=workspace
        local root=Instance.new("Part");root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.Parent=model
        local hero={id="player",kind="Hero",owner=-901,session=session,model=model,root=root,active=true,state="Idle",health=100000,
            stats={MaxHealth=100000,Attack=5000,Defense=4},threat={}}
        local ok,result=pcall(function():any
            local rows={}
            for _,actor in ipairs(bridge.actors) do
                for _,other in ipairs(bridge.actors) do other.active=false;other.pendingPattern=nil end
                actor.active=true;actor.health=actor.maxHealth;actor.position=table.clone(actor.home)
                actor.nextPattern=0;actor.nextAttack=0;actor.patternCount=0;actor.model:PivotTo(CFrame.new(actor.home.x,actor.home.y,actor.home.z))
                local phases=if actor.role=="Boss" then 2 else 1
                local names={};local previousHits=hits;local previousHeals=heals
                for phase=1,phases do
                    actor.health=if phase==2 then actor.maxHealth*.5 else actor.maxHealth
                    actor.pendingPattern=nil;actor.nextPattern=now;actor.nextAttack=now;actor.patternCount=0
                    root.Position=actor.root.Position+Vector3.new(0,0,if actor.range<=7 then 4 else 8)
                    if actor.role=="Support" then
                        local ally=bridge.actors[1];ally.active=true;ally.health=ally.maxHealth*.25;ally.nextAttack=now+1000
                        ally.position={x=actor.position.x+4,y=actor.position.y,z=actor.position.z};ally.home=table.clone(ally.position)
                        ally.model:PivotTo(CFrame.new(ally.position.x,ally.position.y,ally.position.z))
                    end
                    local phaseNames={}
                    for _=1,60 do
                        now+=.2
                        for _,event in ipairs(bridge.Step({hero},now,.2)) do
                            if event.actor==actor.id and event.action.kind=="Telegraph" then
                                names[event.action.pattern.name]=true;phaseNames[event.action.pattern.name]=true
                                assert(actor.model:GetAttribute("BossPhase")==phase or actor.role~="Boss")
                                local start=actor.model:GetAttribute("RegionalTelegraphAt")
                                local finish=actor.model:GetAttribute("RegionalTelegraphUntil")
                                assert(type(start)=="number" and math.abs(finish-start-event.action.pattern.duration)<.001,"Warning clock mismatch")
                                assert(actor.model:GetAttribute("TelegraphAt")==nil,"Regional shapes must not trigger legacy circle VFX")
                            elseif event.actor==actor.id and event.action.kind=="Impact" then
                                assert(type(actor.model:GetAttribute("RegionalImpactAt"))=="number")
                                assert(actor.model:GetAttribute("RegionalTelegraphUntil")==nil,"Warning must end at impact")
                            end
                        end
                    end
                    if actor.role=="Boss" then
                        local count=0;for _ in pairs(phaseNames) do count+=1 end
                        assert(count==phase,"Boss phase pattern count: "..actor.id)
                    end
                end
                if actor.role=="Support" then assert(heals>previousHeals,"Support shared heal failed")
                else assert(hits>previousHits,"No shared damage: "..actor.id) end
                -- Each actor's defeat produces its own immutable reward ticket exactly once.
                root.Position=actor.root.Position+Vector3.new(0,0,2)
                assert(damage.hit(hero,actor,5,1,now)>0 and actor.health==0)
                bridge.Step({hero},now,.2);task.wait(.02)
                local count=#rewards;assert(rewards[count].encounterId==actor.templateId)
                bridge.Step({hero},now+.2,.2);assert(#rewards==count)
                table.insert(rows,{id=actor.id,phases=phases,hits=hits-previousHits,heals=heals-previousHeals,patterns=names})
            end
            assert(#rewards==4)
            return {region=region,actors=rows,rewardTickets=#rewards,profileWrites=0}
        end)
        bridge.Destroy();model:Destroy();assert(ok,tostring(result));table.insert(reports,result)
    end
    return reports
end
