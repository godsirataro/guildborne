-- REVIEW-only observer ModuleScript. Requiring it does not collect or mutate gameplay.
-- Controller starts SERVER first in unsaved Memory, then CLIENT with explicit
-- memoryVerifiedByController=true attestation (client cannot inspect server Runtime).
-- Same owner-supplied runId on both sides; side-specific IDs are not cross-side identities.
-- No inputs, remotes, rewards, profile changes, model attributes, joints or camera writes.
-- Captures observations, never emits an automatic PASS or proves VFX attribution.

-- BEGIN PURE_COLLECTOR
local function finite(v) return type(v)=="number" and v==v and math.abs(v)<math.huge end
local function snapshot(value)
    if type(value)~="table" then return value end
    local copy={};for k,v in pairs(value) do copy[k]=snapshot(v) end
    return table.freeze(copy)
end
local function pureCollector(capacity,gapLimit)
    assert(finite(capacity) and capacity>=1 and capacity<=10000 and capacity%1==0,"Invalid capacity")
    assert(finite(gapLimit) and gapLimit>0,"Invalid gap limit")
    local records={};local state={capacity=capacity,gapLimit=gapLimit,count=0,attempted=0,dropped=0,
        overflow=false,stopped=false,complete=false,frameCount=0,maxGap=0,gapCount=0,clockRegression=false,invalidTimes=0}
    local previousTick=nil
    local function validTime(t)
        if not finite(t) then state.invalidTimes+=1;return false end
        if state.lastTime and t<state.lastTime then state.clockRegression=true;return false end
        state.lastTime=t;if not state.startedAt then state.startedAt=t end;return true
    end
    local C={}
    function C.append(kind,payload,t)
        if state.stopped then return false end
        state.attempted+=1
        if not validTime(t) then state.dropped+=1;return false end
        if #records>=capacity then state.overflow=true;state.dropped+=1;return false end
        local n=#records+1;records[n]={sequence=n,kind=kind,payload=snapshot(payload),time=t};state.count=n;return true
    end
    function C.tick(t)
        if state.stopped or not validTime(t) then return false end
        local previous=previousTick or state.startedAt
        if previous then
            local gap=t-previous;state.maxGap=math.max(state.maxGap,gap)
            if gap>gapLimit then state.gapCount+=1 end
        end
        previousTick=t;state.frameCount+=1;return true
    end
    function C.finish(t,reason)
        if state.stopped then return false end
        local valid=validTime(t);state.stopped=true;state.finishedAt=if valid then t else state.lastTime
        if valid and previousTick then
            local gap=t-previousTick;state.maxGap=math.max(state.maxGap,gap)
            if gap>gapLimit then state.gapCount+=1 end
        end
        state.reason=reason;state.complete=valid and state.frameCount>0 and reason=="duration" and not state.overflow and not state.clockRegression and state.invalidTimes==0 and state.gapCount==0
        return true
    end
    function C.chunk(offset,count)
        assert(finite(offset) and offset>=0 and offset%1==0,"Invalid zero-based offset")
        assert(finite(count) and count>=1 and count<=200 and count%1==0,"Invalid chunk count")
        local result={};for i=offset+1,math.min(#records,offset+count) do table.insert(result,snapshot(records[i])) end
        return table.freeze(result)
    end
    function C.metadata() return snapshot(state) end
    return C
end
-- END PURE_COLLECTOR

local API={}
local activeHandle=nil
function API.start(config)
    assert(activeHandle==nil,"This module already has an active observer")
    assert(type(config)=="table" and config.armed==true,"Explicit armed=true required")
    assert(type(config.runId)=="string" and #config.runId>=1 and #config.runId<=80 and config.runId:match("^[%w_-]+$"),"Owner must provide bounded runId")
    assert(finite(config.ownerUserId) and config.ownerUserId%1==0,"Explicit ownerUserId required")
    assert(finite(config.duration) and config.duration>=1 and config.duration<=30,"Duration must be 1..30 seconds")
    local Run=game:GetService("RunService");local Players=game:GetService("Players")
    assert(Run:IsStudio() and game.PlaceId==0 and game.GameId==0,"Unsaved Studio only")
    local server=Run:IsServer();assert(server or Run:IsClient(),"Unknown execution side")
    if server then
        local serverTree=assert(game:GetService("ServerScriptService"):FindFirstChild("Server"),"Real Server tree required")
        local runtime=require(serverTree.Config.Runtime)
        assert(runtime.StudioPersistence=="Memory" and next(runtime.AllowedDataStoreUniverses)==nil,"Real Runtime must be Memory with no allowed DataStore universes")
    else
        assert(config.memoryVerifiedByController==true,"Client requires explicit controller Memory attestation after paired server verification")
        assert(Players.LocalPlayer and Players.LocalPlayer.UserId==config.ownerUserId,"Observe only this local player's party")
    end
    local owner=assert(Players:GetPlayerByUserId(config.ownerUserId),"Owner not present")
    local side=if server then "server" else "client"
    local collector=pureCollector(config.maxRecords or 4000,.15)
    local connections={};local actorIds,jointIds,vfxIds={},{},{}
    local actorCount,jointCount,vfxCount=0,0,0
    local actors,vfxPending,vfxActive={},{},{};local stopped=false;local discoveryOverflow=false;local timer=nil
    local counts={};local lastTuples={};local started=workspace:GetServerTimeNow()
    local deadline=started+config.duration;local stoppedAt=nil;local cleanupErrors={};local candidates={};local candidateCount=0
    local function now() return workspace:GetServerTimeNow() end
    local function id(kind,n) return config.runId..":"..side..":"..kind..":"..n end
    local function connect(signal,callback) local c=signal:Connect(callback);table.insert(connections,c);return c end
    local function emit(kind,payload,t) local at=t or now();if at<deadline then collector.append(kind,payload,at) end end
    local function read(object,key)
        local ok,value=pcall(function() return object[key] end)
        if not ok then return "UNAVAILABLE" end
        if typeof(value)=="CFrame" then return {value:GetComponents()} end
        if typeof(value)=="Vector3" then return {value.X,value.Y,value.Z} end
        if typeof(value)=="Instance" then return value:GetFullName() end
        if value==nil then return "nil" end
        return if type(value)=="number" or type(value)=="boolean" or type(value)=="string" then value else tostring(value)
    end
    local function frame(cf) return {cf:GetComponents()} end
    local function attributes(m)
        local result={}
        for _,name in ipairs({"OwnerUserId","AdventurerId","ClassId","GuildbornePlayer","GuildborneHero","HeroState","CombatState",
            "CombatHealth","CombatMaxHealth","ActionAt","Action","ActionEffect","ActionAbilityId","ActionTargetPosition","DamageCueAt","DamageCue","FeedbackAt","Feedback",
            "BasicAttackCount","AbilityCount","DamageDealt","HealingDone","CombatTarget"}) do
            local value=m:GetAttribute(name)
            if typeof(value)=="Vector3" then result[name]={value.X,value.Y,value.Z}
            elseif type(value)=="number" then result[name]=if finite(value) then value else tostring(value)
            elseif type(value)=="string" or type(value)=="boolean" then result[name]=value end
        end
        return result
    end
    local function selected(m)
        return m==owner.Character or (m:GetAttribute("GuildborneHero")==true and m:GetAttribute("OwnerUserId")==config.ownerUserId and m:GetAttribute("ClassId")=="Mage")
    end
    local function discover(m,t)
        if not m:IsA("Model") or not m:IsDescendantOf(workspace) or not selected(m) then return end
        if actorIds[m] then
            if not actors[m] then actors[m]=true;emit("entity_returned",{id=actorIds[m]},t) end
            return
        end
        if actorCount>=6 then discoveryOverflow=true;return end
        actorCount+=1;actorIds[m]=id("entity",actorCount);actors[m]=true
        counts[actorIds[m]]={actionChanges=0,damageStampChanges=0,healthDrops=0,basicDelta=0,abilityDelta=0,damageDealtDelta=0,healingDelta=0,counterResets=0,counterUnknownSamples=0}
        emit("entity_added",{id=actorIds[m],name=m.Name,path=m:GetFullName(),expectedActorId=if m==owner.Character then "player" else m:GetAttribute("AdventurerId"),selection=if m==owner.Character then "owned_player" else "owned_Mage",attributes=attributes(m)},t)
    end
    local function jointRecord(j,m,t)
        if not jointIds[j] then
            if jointCount>=384 then discoveryOverflow=true;return nil end
            jointCount+=1;jointIds[j]=id("joint",jointCount)
            emit("joint_inventory",{id=jointIds[j],entity=actorIds[m],name=j.Name,class=j.ClassName,path=j:GetFullName(),
                part0=read(j,"Part0"),part1=read(j,"Part1"),attachment0=read(j,"Attachment0"),attachment1=read(j,"Attachment1")},t)
        end
        local result={id=jointIds[j],transform=read(j,"Transform"),enabled=read(j,"Enabled")}
        local ok,p0,p1=pcall(function()
            if j:IsA("Motor6D") then return j.Part0,j.Part1 end
            local a0,a1=j.Attachment0,j.Attachment1
            return a0 and a0.Parent,a1 and a1.Parent
        end)
        if ok and p0 and p1 and p0:IsA("BasePart") and p1:IsA("BasePart") then
            result.relativeFrame=frame(p0.CFrame:ToObjectSpace(p1.CFrame))
            if m.PrimaryPart then result.rootRelativeLimb=frame(m.PrimaryPart.CFrame:ToObjectSpace(p1.CFrame)) end
        end
        return result
    end
    local function vfxProperties(v)
        local family,stage=v:GetAttribute("VFXFamily"),v:GetAttribute("VFXStage")
        return {id=vfxIds[v],name=v.Name,class=v.ClassName,path=v:GetFullName(),family=family or "nil",stage=stage or "nil",
            parentReady=v:IsDescendantOf(workspace),position=read(v,"Position"),size=read(v,"Size"),transparency=read(v,"Transparency"),
            material=read(v,"Material"),attribution="UNASSIGNED_OBSERVATION"}
    end
    local function observeVFX(v,existing)
        if not (v:IsA("BasePart") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam")) or not v:IsDescendantOf(workspace) then return end
        if vfxIds[v] then
            if not vfxActive[v] then
                vfxActive[v]=true;vfxPending[v]=true;emit("vfx_returned",vfxProperties(v))
            end
            return
        end
        local name=v.Name
        local cursor=v.Parent;local underTracked=false
        while cursor and cursor~=workspace do if vfxIds[cursor] then underTracked=true;break end;cursor=cursor.Parent end
        if not (underTracked or name:find("GuildborneSkill",1,true) or name:find("GuildborneBossTelegraph",1,true) or name:find("GuildborneProjectile",1,true) or name=="GuildborneCastTrail" or v:GetAttribute("VFXFamily")) then return end
        if vfxCount>=512 then discoveryOverflow=true;return end
        vfxCount+=1;vfxIds[v]=id("vfx",vfxCount);vfxActive[v]=true;vfxPending[v]=true;emit(if existing then "vfx_existing" else "vfx_added",vfxProperties(v))
        connect(v.AttributeChanged,function(key) if key=="VFXFamily" or key=="VFXStage" then vfxPending[v]=true end end)
        connect(v:GetPropertyChangedSignal("Name"),function() vfxPending[v]=true end)
    end
    local function stop(reason)
        if stopped then return end;stopped=true
        if timer then local ok,e=pcall(task.cancel,timer);if not ok then table.insert(cleanupErrors,tostring(e)) end;timer=nil end
        for _,c in ipairs(connections) do local ok,e=pcall(function() c:Disconnect() end);if not ok then table.insert(cleanupErrors,tostring(e)) end end;table.clear(connections)
        stoppedAt=now();collector.finish(stoppedAt,reason or "manual");activeHandle=nil
    end
    local handle={}
    function handle.stop(reason) stop(reason) end
    function handle.chunk(offset,count) return collector.chunk(offset,count) end
    function handle.metadata()
        local c=collector.metadata();local issues={}
        if discoveryOverflow then table.insert(issues,"discovery_limit") end
        if c.frameCount==0 then table.insert(issues,"zero_frames") end
        if jointCount==0 then table.insert(issues,"zero_joints") end
        if #cleanupErrors>0 then table.insert(issues,"cleanup_error") end
        return snapshot({runId=config.runId,side=side,ownerUserId=config.ownerUserId,requestedDuration=config.duration,startedAt=started,deadline=deadline,stoppedAt=stoppedAt,
            stopOvershoot=if stoppedAt then math.max(0,stoppedAt-deadline) else nil,cleanupErrors=cleanupErrors,captureIssues=issues,
            memory=if server then "VERIFIED_REAL_RUNTIME" else "CONTROLLER_ATTESTATION_ONLY",status="OBSERVATIONS_ONLY",
            collection=collector.metadata(),discoveryOverflow=discoveryOverflow,entityCount=actorCount,jointCount=jointCount,vfxCount=vfxCount,
            actorCounts=counts,automaticAcceptance=false,attribution="VFX_UNASSIGNED",samplePhase=if server then "Heartbeat" else "PostSimulation"})
    end
    activeHandle=handle
    local setupOK,setupError=xpcall(function()
    emit("run_started",{runId=config.runId,side=side,ownerUserId=config.ownerUserId,memory=if server then "VERIFIED_REAL_RUNTIME" else "CONTROLLER_ATTESTATION_ONLY"},started)
    local function candidate(v)
        -- Source HeroService names the model Mage before parenting. The extra
        -- flag handles a replicated name lag; scenery is never a candidate.
        if v:IsA("Model") and (v==owner.Character or v.Name=="Mage" or v:GetAttribute("GuildborneHero")==true) and not candidates[v] then
            if candidateCount>=128 then discoveryOverflow=true;return end
            candidateCount+=1;candidates[v]=true
            connect(v.AttributeChanged,function(key)
                if not stopped and now()<deadline and (key=="GuildborneHero" or key=="OwnerUserId" or key=="ClassId") and v:IsDescendantOf(workspace) then discover(v) end
            end)
        end
    end
    connect(workspace.DescendantAdded,function(v) if now()>=deadline then stop("duration");return end;candidate(v);discover(v);observeVFX(v,false) end)
    connect(workspace.DescendantRemoving,function(v)
        if actors[v] then emit("entity_removed",{id=actorIds[v]});actors[v]=nil end
        if vfxIds[v] then emit("vfx_removed",{id=vfxIds[v],attribution="UNASSIGNED_OBSERVATION"});vfxPending[v]=nil;vfxActive[v]=nil end
    end)
    for _,v in ipairs(workspace:GetDescendants()) do candidate(v);discover(v);observeVFX(v,true) end
    connect(if server then Run.Heartbeat else Run.PostSimulation,function(dt)
        if stopped then return end
        local ok,errorText=xpcall(function()
            local t=now();collector.tick(t)
            if t-started>=config.duration then stop("duration");return end
            -- Recheck initial attributes that may have arrived after parenting.
            discover(owner.Character or workspace,t)
            for m in pairs(actors) do
                if not m:IsDescendantOf(workspace) or not selected(m) then emit("entity_deselected",{id=actorIds[m]},t);actors[m]=nil;continue end
                local attrs=attributes(m);local joints={};local jointSeen=0
                for _,j in ipairs(m:GetDescendants()) do
                    if j:IsA("Motor6D") or j:IsA("AnimationConstraint") then
                        jointSeen+=1;if jointSeen>64 then discoveryOverflow=true;break end
                        local record=jointRecord(j,m,t);if record then table.insert(joints,record) end
                    end
                end
                local tuple={action=attrs.ActionAt,effect=attrs.ActionEffect,ability=attrs.ActionAbilityId,damage=attrs.DamageCueAt,health=attrs.CombatHealth,
                    basic=attrs.BasicAttackCount,abilityCount=attrs.AbilityCount,damageDealt=attrs.DamageDealt,healing=attrs.HealingDone}
                local previous=lastTuples[m];local totals=counts[actorIds[m]]
                if previous then
                    if tuple.action~=previous.action then totals.actionChanges+=1 end
                    if tuple.damage~=previous.damage then totals.damageStampChanges+=1 end
                    if finite(tuple.health) and finite(previous.health) and tuple.health<previous.health then totals.healthDrops+=1 end
                    for key,total in pairs({basic="basicDelta",abilityCount="abilityDelta",damageDealt="damageDealtDelta",healing="healingDelta"}) do
                        -- CombatService creates these counters on first event;
                        -- observed missing -> numeric therefore has baseline 0.
                        if finite(tuple[key]) then
                            if previous[key]==nil then totals[total]+=tuple[key]
                            elseif finite(previous[key]) and tuple[key]>=previous[key] then totals[total]+=tuple[key]-previous[key]
                            elseif finite(previous[key]) then totals.counterResets+=1
                            else totals.counterUnknownSamples+=1 end
                        elseif tuple[key]==nil and previous[key]~=nil then totals.counterResets+=1
                        elseif tuple[key]~=nil then totals.counterUnknownSamples+=1 end
                    end
                end
                lastTuples[m]=tuple
                local root=m.PrimaryPart
                emit("actor_sample",{entity=actorIds[m],dt=dt,attributes=attrs,tuple=tuple,joints=joints,
                    rootFrame=if root then frame(root.CFrame) else "nil",rootVelocity=if root then read(root,"AssemblyLinearVelocity") else "nil",
                    cameraDistance=if root and workspace.CurrentCamera then (workspace.CurrentCamera.CFrame.Position-root.Position).Magnitude else "nil",
                    downed=finite(attrs.CombatHealth) and attrs.CombatHealth<=0},t)
            end
            for v in pairs(vfxPending) do
                if v:IsDescendantOf(workspace) then emit("vfx_readiness_resample",vfxProperties(v),t) end
                vfxPending[v]=nil
            end
        end,debug.traceback)
        if not ok then emit("observer_error",{error=tostring(errorText)});stop("observer_error") end
    end)
    -- Wall-clock safety is independent of sample delivery; it never extends the window.
    timer=task.delay(math.max(0,deadline-now()),function() timer=nil;if not stopped then stop("duration") end end)
    end,debug.traceback)
    if not setupOK then stop("setup_error");error(setupError) end
    return handle
end
return table.freeze(API)
