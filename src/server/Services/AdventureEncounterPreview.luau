--!strict
-- Isolated server review harness. Never attaches Players, remotes, saves or reward producers.
local build=require(script.Parent.AdventureScene)
local definitions=require(script.Parent.Parent.Config.AdventureEncounters)
local profiles=require(script.Parent.Parent.Config.AdventureEnemyProfiles)
local patterns=require(script.Parent.Parent.Systems.AdventurePatterns)
local brain=require(script.Parent.Parent.Systems.AdventureEnemyBrain)(patterns)
local draw=require(game.ReplicatedStorage.Shared.Data.AdventureTelegraph)
local V=Vector3.new
return function(region:string,origin:Vector3,owner:number,effects:any?,geometry:Model?):any
    local model=build(region,geometry);if not model then return nil end
    local def=(definitions.Regions :: any)[region]
    model.Name="ReviewEncounter_"..region;model:PivotTo(CFrame.new(origin));model.Parent=workspace
    local actors:{any}={};local lookup:{[string]:any}={};local arts=model:FindFirstChild("EncounterArt") :: Folder
    for _,entry in ipairs(def.Encounters) do
        local art=arts:FindFirstChild(entry.Asset) :: Model;local tuning=(profiles :: any)[entry.Asset];assert(tuning)
        local p=art:GetPivot().Position;local a=table.clone(tuning)
        a.id=entry.Asset;a.templateId=entry.Asset;a.role=entry.Role;a.owner=owner;a.active=true;a.maxHealth=a.health
        a.position={x=p.X,y=p.Y,z=p.Z};a.home=table.clone(a.position);a.model=art
        table.insert(actors,a);lookup[a.id]=a
    end
    local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=if geometry then {model,geometry} else {model};ray.RespectCanCollide=true
    local function visible(a:any,b:any):boolean
        local start=V(a.position.x,a.position.y+2,a.position.z);local goal=V(b.position.x,b.position.y+2,b.position.z)
        return workspace:Raycast(start,goal-start,ray)==nil
    end
    local alive=true;local api={actors=actors,model=model,damageEvents=0,healEvents=0}
    local navigation=require(script.Parent.AdventureNavigation)(geometry or model)
    function api.Step(targets:{any},now:number,dt:number):{any}
        assert(alive,"Preview already destroyed");assert(#targets<=6,"Review party bound")
        local events={}
        for _,a in ipairs(actors) do
            local action=brain.step(a,targets,actors,now,dt,visible)
            if a.warning and not a.pendingPattern then a.warning:Destroy();a.warning=nil end
            if action.kind=="Telegraph" then
                if a.warning then a.warning:Destroy() end
                a.warning=draw(model,action.pattern)
            elseif action.kind=="Move" then
                local position=V(a.position.x,a.position.y,a.position.z)
                -- Route toward the actual target/home rather than the brain's short steering step.
                local goal=V(action.x,a.position.y,action.z)
                if action.reason=="Leash" then goal=V(a.home.x,a.home.y,a.home.z)
                elseif action.reason=="Approach" then for _,target in ipairs(targets) do if target.id==a.targetId then goal=V(target.position.x,target.position.y,target.position.z);break end end end
                local nextPosition=navigation.move(a,position,goal,a.speed*(if (a.slowUntil or 0)>now then .45 else 1),dt,now)
                if (nextPosition-position).Magnitude>.001 then
                    local delta=nextPosition-position
                    local flat=V(delta.X,0,delta.Z)
                    a.model:PivotTo(if flat.Magnitude>.001 then CFrame.lookAt(nextPosition,nextPosition+flat) else CFrame.new(nextPosition)*a.model:GetPivot().Rotation)
                    a.position={x=nextPosition.X,y=nextPosition.Y,z=nextPosition.Z}
                end
            elseif action.kind=="Heal" then
                local ally=lookup[action.targetId]
                if ally and ally.health>0 then
                    local amount=if effects and effects.Heal then effects.Heal(a,ally,action.amount,now) else math.min(ally.maxHealth-ally.health,action.amount)
                    if not effects or not effects.Heal then ally.health+=amount end
                    if amount>0 then api.healEvents+=1 end
                end
            elseif action.kind=="Basic" or action.kind=="Impact" then
                for _,target in ipairs(targets) do
                    local hit=if action.kind=="Basic" then target.id==action.targetId else patterns.contains(action.pattern,target.position)
                    if hit and target.active and target.health>0 and target.owner==owner and visible(a,target) then
                        local amount=if effects and effects.Hit then effects.Hit(a,target,action,now) else math.min(target.health,a.power)
                        if not effects or not effects.Hit then target.health-=amount end
                        if amount>0 then api.damageEvents+=1 end
                    end
                end
            elseif action.kind=="Idle" and action.recover then
                a.health=a.maxHealth;a.participants=nil;a.playerParticipated=nil;a.threat={};a.tauntTarget=nil;a.tauntUntil=nil
                navigation.remove(a)
            elseif action.kind=="Dead" then navigation.remove(a) end
            a.model:SetAttribute("PreviewHealth",a.health);a.model:SetAttribute("PreviewState",action.kind)
            a.model:SetAttribute("PreviewPhase",if a.health<=a.maxHealth*.5 then 2 else 1)
            table.insert(events,{actor=a.id,action=action})
        end
        return events
    end
    function api.Destroy()
        if not alive then return end;alive=false;navigation.destroy()
        for _,a in ipairs(actors) do a.active=false;a.pendingPattern=nil end
        model:Destroy()
    end
    return api
end
