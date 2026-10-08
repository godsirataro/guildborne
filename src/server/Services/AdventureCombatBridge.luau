--!strict
-- Connects regional actors to the same authoritative damage/targeting service as player combat.
-- The caller supplies its owned session, validated damage service, and durable reward adapter.
local Create=require(script.Parent.AdventureEncounterSession)
local Articulate=require(script.Parent.EnemyArticulation)
local Stats=require(script.Parent.Parent.Systems.AdventureStats)
local V=Vector3.new
return function(region:string,origin:Vector3,owner:number,session:any,damage:any,reward:any,clock:any?,geometry:Model?):any
    local scene=Create(region,origin,owner,{
        Clock=clock,
        Geometry=geometry,
        Members=function(actor:any):{string}
            local members=table.clone(actor.participants or {})
            if actor.playerParticipated then table.insert(members,"player") end
            return members
        end,
        Reward=reward,
        Effects={
            Hit=function(actor:any,target:any,action:any,now:number):number
                local entity=target.entity
                if not entity or entity.session~=session then return 0 end
                -- Pattern geometry was checked by the driver; combat authority still checks space/LOS/owner.
                local range=if action.kind=="Basic" then actor.range+1 else 64
                local amount=damage.hit(actor,entity,range,1,now)
                target.health=entity.health;return amount
            end,
            Heal=function(actor:any,ally:any,amount:number,now:number):number
                return damage.heal(actor,ally,actor.range,amount,now)
            end,
        },
    })
    if not scene then return nil end
    for _,actor in ipairs(scene.actors) do
        local parent=actor.model.Parent;actor.model.Parent=nil
        local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Size=V(1,1,1)
        root.CFrame=actor.model:GetPivot()*CFrame.new(0,3,0);root.Transparency=1
        root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.CanTouch=false;root.Parent=actor.model
        root.PivotOffset=CFrame.new(0,-3,0);actor.model.PrimaryPart=root
        actor.root=root;actor.kind="Enemy";actor.session=session;actor.plot=session.plot
        actor.state="Idle";actor.threat={};actor.cooldowns={};actor.lastGeneration=1
        actor.stats=Stats.build(actor,actor.role)
        actor.model:SetAttribute("GuildborneEnemy",true);actor.model:SetAttribute("OwnerUserId",owner)
        actor.model:SetAttribute("EncounterId",actor.templateId)
        actor.model:SetAttribute("TemplateOnly",false);actor.model:SetAttribute("PreviewOnly",false)
        actor.model:SetAttribute("EnemyTitle",Stats.title(actor.templateId))
        actor.model:SetAttribute("CombatHealth",actor.health);actor.model:SetAttribute("CombatMaxHealth",actor.maxHealth)
        actor.model.Parent=parent
        Articulate(actor.model,false)
    end
    local api={actors=scene.actors,model=scene.model}
    function api.Step(allies:{any},now:number,dt:number):{any}
        local views={}
        for _,ally in ipairs(allies) do
            if ally.owner==owner and ally.session==session and ally.kind=="Hero" and ally.root and ally.model and ally.model.Parent then
                local p=ally.root.Position-V(0,3,0)
                table.insert(views,{id=ally.id,owner=owner,active=ally.active,health=ally.health,maxHealth=ally.stats.MaxHealth,
                    position={x=p.X,y=p.Y,z=p.Z},entity=ally})
            end
        end
        assert(#views<=6,"Party bound")
        local events=scene.Step(views,now,dt)
        local actions={};for _,event in ipairs(events) do actions[event.actor]=event.action end
        for _,actor in ipairs(scene.actors) do
            local state=scene.State(actor.id)
            if actor.lastGeneration~=state.generation then
                actor.lastGeneration=state.generation;actor.participants=nil;actor.playerParticipated=nil;actor.threat={}
                actor.tauntTarget=nil;actor.tauntUntil=nil;actor.slowUntil=nil;actor.guardUntil=nil
            end
            local action=actions[actor.id];local kind=action and action.kind
            actor.target=nil;for _,ally in ipairs(allies) do if ally.id==actor.targetId then actor.target=ally;break end end
            actor.state=if actor.health<=0 then "Dead" elseif kind=="Basic" or kind=="Impact" then "Attack"
                elseif kind=="Telegraph" or actor.pendingPattern then "Windup" elseif kind=="Move" then "Approach" else "Idle"
            if kind=="Basic" or kind=="Impact" then actor.model:SetAttribute("EnemyActionAt",workspace:GetServerTimeNow()) end
            -- Separate presentation clock: legacy TelegraphAt would draw an incorrect circular footprint.
            if kind=="Telegraph" then
                local started=workspace:GetServerTimeNow()
                actor.model:SetAttribute("RegionalTelegraphAt",started)
                actor.model:SetAttribute("RegionalTelegraphUntil",started+action.pattern.duration)
            elseif not actor.pendingPattern then actor.model:SetAttribute("RegionalTelegraphUntil",nil) end
            if kind=="Impact" then actor.model:SetAttribute("RegionalImpactAt",workspace:GetServerTimeNow()) end
            actor.model:SetAttribute("TelegraphName",if actor.pendingPattern then actor.pendingPattern.name else nil)
            if actor.role=="Boss" then actor.model:SetAttribute("BossPhase",if actor.health<=actor.maxHealth*.5 then 2 else 1) end
            actor.model:SetAttribute("CombatHealth",math.ceil(actor.health));actor.model:SetAttribute("CombatMaxHealth",actor.maxHealth)
            actor.model:SetAttribute("CombatState",actor.state)
        end
        return events
    end
    function api.Suspend()scene.Suspend()end
    function api.Resume()scene.Resume()end
    function api.State(id:string):any return scene.State(id)end
    function api.Destroy()scene.Destroy()end
    return api
end
