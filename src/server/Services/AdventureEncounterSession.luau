--!strict
-- Server-owned encounter orchestration. No remotes or Player profile lookup.
-- Reward adapters must retain their immutable persistence command by ticket.deathId.
local Create=require(script.Parent.AdventureEncounterPreview)
local Catalog=require(script.Parent.Parent.Config.AdventureEncounters)
local Lifecycle=require(script.Parent.Parent.Systems.AdventureLifecycle)
local Http=game:GetService("HttpService")
return function(region:string,origin:Vector3,owner:number,callbacks:any):any
    assert(type(callbacks)=="table" and type(callbacks.Members)=="function" and type(callbacks.Reward)=="function")
    local scene=Create(region,origin,owner,callbacks.Effects,callbacks.Geometry);if not scene then return nil end
    local clock=callbacks.Clock or os.clock
    local ledger=Lifecycle(Catalog,owner,function()return Http:GenerateGUID(false)end,18)
    local alive=true;local suspended=false;local parent=scene.model.Parent
    local api={model=scene.model,actors=scene.actors}
    local function reset(actor:any)
        actor.health=actor.maxHealth;actor.position=table.clone(actor.home);actor.pendingPattern=nil
        actor.targetId=nil;actor.nextAttack=0;actor.nextPattern=0;actor.patternCount=0
        actor.state="Idle";actor.participants=nil;actor.playerParticipated=nil;actor.threat={}
        actor.tauntTarget=nil;actor.tauntUntil=nil;actor.slowUntil=nil;actor.guardUntil=nil
        actor.model:PivotTo(CFrame.new(actor.home.x,actor.home.y,actor.home.z))
        actor.model:SetAttribute("RewardState",nil)
    end
    function api.Step(targets:{any},now:number,dt:number):{any}
        assert(alive,"Encounter session closed")
        if suspended then return {} end
        for _,actor in ipairs(scene.actors) do
            if actor.active and actor.health<=0 then
                local state=ledger.read(actor.id)
                if state.state=="Alive" then
                    local members=callbacks.Members(actor)
                    local ok,reason=ledger.death(actor.id,owner,members,now)
                    assert(ok,"Invalid server participation: "..reason)
                end
                local ticket=ledger.claim(actor.id,now)
                if ticket then
                    task.spawn(function()
                        local ok,result=pcall(callbacks.Reward,ticket)
                        -- Exceptions and unknown outcomes remain pending, never become rejection.
                        if not ok or (result~="Committed" and result~="Rejected") then result="Retry" end
                        ledger.finish(ticket,result,clock())
                    end)
                end
                if ledger.respawn(actor.id,now) then reset(actor)
                else actor.model:SetAttribute("RewardState",ledger.read(actor.id).state) end
            end
        end
        return scene.Step(targets,now,dt)
    end
    function api.State(id:string):any return ledger.read(id)end
    function api.Suspend()
        if not alive or suspended then return end;suspended=true
        for _,actor in ipairs(scene.actors) do actor.resumeActive=actor.active;actor.active=false end
        scene.Step({},clock(),0);scene.model.Parent=nil
    end
    function api.Resume()
        if not alive or not suspended then return end;suspended=false;scene.model.Parent=parent
        for _,actor in ipairs(scene.actors) do actor.active=actor.resumeActive;actor.resumeActive=nil end
    end
    function api.Destroy()
        if not alive then return end;alive=false;ledger.close();scene.Destroy()
    end
    return api
end
