--!strict
-- Synthetic combat records only; no Players or profiles are passed to the prototype adapter.
return function():any
    local create=require(game.ServerScriptService.Server.Services.AdventureEncounterPreview)
    local reports={}
    for index,region in ipairs({"Greenwood","Ironveil","Ashen"}) do
        local s=create(region,Vector3.new(9000+index*350,100,0),-101)
        assert(s)
        local ok,result=pcall(function():any
            local checked={}
            for _,a in ipairs(s.actors) do
                for _,b in ipairs(s.actors) do b.active=false;b.pendingPattern=nil end
                a.active=true;a.health=if a.role=="Boss" then a.maxHealth*.5 else a.maxHealth
                a.position=table.clone(a.home);a.nextPattern=0;a.nextAttack=0;a.patternCount=0
                a.model:PivotTo(CFrame.new(a.position.x,a.position.y,a.position.z))
                local distance=if a.range<=7 then 4 else math.min(12,a.range-1)
                local target={id="synthetic-target",active=true,owner=-101,health=10000,maxHealth=10000,
                    position={x=a.position.x,y=a.position.y,z=a.position.z+distance}}
                local ally=nil
                if a.role=="Support" then
                    ally=s.actors[1];ally.active=true;ally.health=ally.maxHealth*.25;ally.power=0;ally.nextAttack=1000
                    ally.position={x=a.position.x+4,y=a.position.y,z=a.position.z};ally.home=table.clone(ally.position)
                    ally.model:PivotTo(CFrame.new(ally.position.x,ally.position.y,ally.position.z))
                end
                local heals=s.healEvents;local damage=s.damageEvents;local names={}
                for tick=0,50 do
                    for _,event in ipairs(s.Step({target},tick*.2,.2)) do
                        if event.actor==a.id and event.action.kind=="Telegraph" then names[event.action.pattern.name]=true end
                    end
                end
                if a.role=="Support" then assert(s.healEvents>heals,"no support heal") else assert(s.damageEvents>damage,"no damage "..a.id) end
                local count=0;for _ in pairs(names) do count+=1 end
                if a.role=="Boss" then assert(count==2,"boss pattern coverage "..a.id) end
                a.health=0;s.Step({target},11,.2);assert(a.pendingPattern==nil,"dead actor retained pattern")
                table.insert(checked,{id=a.id,damageEvents=s.damageEvents-damage,healEvents=s.healEvents-heals,patterns=count})
            end
            return {region=region,actors=checked,playerProfilesTouched=false}
        end)
        s.Destroy();s.Destroy();assert(s.model.Parent==nil);assert(ok,tostring(result));table.insert(reports,result)
    end
    return reports
end
