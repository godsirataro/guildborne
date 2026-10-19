-- COMPILE-ONLY until run by the exclusive Studio owner on an unsaved CLIENT.
-- Installation BEFORE Play: disable normal ServerBootstrap and ClientBootstrap.
-- Copy exact src/client tree to ReplicatedStorage.CombatCueProbeClient (do not run
-- its bootstrap); copy exact src/shared tree to ReplicatedStorage.Shared. Copy
-- src/server/Config/Runtime as CombatCueProbeClient.Runtime solely for guard read.
-- Run this file as an isolated LocalScript. No server gameplay is required.
-- Stop Play after capture: MenuRouter's module-scope input listeners have no
-- Destroy API. Never install into a running gameplay client or reuse its modules.
-- Synthetic attributes exercise actual client admission and VFX, NOT real damage.
-- Audio spies delegate real methods; a synthetic stop recorder stands in for a
-- nil unloaded voice. These observations prove requests/disposal, NOT audibility,
-- actual Sound.Ended/voice-budget cleanup, server combat or earned progression.
local Run=game:GetService("RunService")
local RS=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local player=game:GetService("Players").LocalPlayer
assert(Run:IsStudio() and Run:IsClient() and game.PlaceId==0 and game.GameId==0,"Unsaved Studio CLIENT only")
local tree=assert(RS:FindFirstChild("CombatCueProbeClient"),"Install exact isolated client tree")
local runtime=require(assert(tree:FindFirstChild("Runtime"),"Copy Runtime for read-only Memory guard"))
assert(runtime.StudioPersistence=="Memory" and next(runtime.AllowedDataStoreUniverses)==nil,"Memory-only config required")
for _,container in ipairs({tree,player:WaitForChild("PlayerScripts")}) do
    for _,child in ipairs(container:GetDescendants()) do
        if child:IsA("LocalScript") and child.Name=="ClientBootstrap" then assert(child.Disabled,"Disable ClientBootstrap BEFORE Play") end
    end
end
local gui=player:WaitForChild("PlayerGui")
assert(not gui:FindFirstChild("GuildborneCombatUI") and not SoundService:FindFirstChild("GuildborneAudio"),"Existing client singleton refused")
assert(not workspace:FindFirstChild("GuildborneWorld"),"Existing world refused")
for _,item in ipairs(workspace:GetDescendants()) do
    assert(not(item:IsA("Model") and (item:GetAttribute("GuildborneHero") or item:GetAttribute("GuildborneEnemy") or item:GetAttribute("GuildbornePlayer"))),"Existing combat actor refused")
end
local audio=require(tree.Controllers.AudioController)
local config=require(RS.Shared.Config.AudioConfig)
assert(next(config.AssetIds)==nil,"Probe requires unchanged unbound AudioConfig IDs")
local original={Play=audio.Play,PlayFor=audio.PlayFor,PlayOwned=audio.PlayOwned}
-- After READY, set this LocalScript's StartRequested attribute to true once.
-- No automatic start/retry. The accepted edge requires preceding 1s coverage.
local camera=assert(workspace.CurrentCamera)
local oldType,oldFrame,oldFocus=camera.CameraType,camera.CFrame,camera.Focus
local center=camera.CFrame.Position+Vector3.new(0,10000,0)
assert(#workspace:GetPartBoundsInRadius(center,40)==0,"Empty isolated space required")
local actors,requests,disposals,effects,vfxRecords,cases={},{},{},{},{},{}
local connections,waits,cameraEvents,heartbeats,mutations={},{},{},{},{}
local controller,createdRemotes,createdState=nil,nil,nil
local interference,inconclusive=false,false
local caseID="setup";local activeCast=nil;local firstStamp=nil
local function now() return workspace:GetServerTimeNow() end
local function watch(signal,callback) local c=signal:Connect(callback);table.insert(connections,c);return c end
local function condition(ok,reason) if not ok then inconclusive=true;error("INCONCLUSIVE: "..reason,2) end end
local function fault(reason) interference=true;if #cameraEvents<64 then table.insert(cameraEvents,{time=now(),reason=reason}) end end
local function inspect()
    if workspace.CurrentCamera~=camera or camera.CameraType~=Enum.CameraType.Scriptable or not camera:IsDescendantOf(workspace) then fault("Camera identity/type/ancestry") end
    for _,m in ipairs(actors) do
        if m:IsDescendantOf(workspace) and m.PrimaryPart and (camera.CFrame.Position-m.PrimaryPart.Position).Magnitude>40 then fault("Actor distance: "..m.Name) end
    end
end
local function covered(a,b)
    local previous=nil;local reached=false
    for _,t in ipairs(heartbeats) do
        if t<=a then previous=t
        elseif previous then
            if t-previous>.15 then return false end
            previous=t;if t>=b then reached=true;break end
        else return false end
    end
    return previous~=nil and reached
end
local function pause(seconds,label)
    local start=now();task.wait(seconds)
    table.insert(waits,{caseID=caseID,label=label,requested=seconds,start=start,observed=now()})
    inspect();condition(not interference,"Camera interference")
end
-- Negative windows need real Heartbeat coverage, including both boundaries.
-- A late reader does not lengthen the test window or silently approve a gap.
local function observe(seconds,label,started)
    local start=started or now()
    if now()<start+seconds then pause(start+seconds-now(),label) end
    condition(covered(start,start+seconds),"Heartbeat gap during negative window: "..label)
    return start,start+seconds
end
local function actor(name)
    local m=Instance.new("Model");m.Name=name
    local p=Instance.new("Part");p.Name="HumanoidRootPart";p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Position=center;p.Parent=m;m.PrimaryPart=p
    m:SetAttribute("GuildborneEnemy",true);m:SetAttribute("OwnerUserId",player.UserId)
    m:SetAttribute("CombatHealth",100);m:SetAttribute("CombatMaxHealth",100);m:SetAttribute("CombatState","Idle")
    m:SetAttribute("ClassId","Archer");m:SetAttribute("ActionEffect","Basic")
    table.insert(actors,m);m:SetAttribute("ProbeActorId",#actors)
    watch(p:GetPropertyChangedSignal("CFrame"),function() fault("Fixture root moved: "..name) end)
    m.Parent=workspace;return m
end
local function target(m,value)
    table.insert(mutations,{caseID=caseID,actor=m:GetAttribute("ProbeActorId"),name=m.Name,time=now(),kind="targetReady",ready=typeof(value)=="Vector3",stamp=m:GetAttribute("ActionAt")})
    m:SetAttribute("ActionTargetPosition",value)
end
local function begin(id) caseID=id;activeCast=nil end
local function finish()
    for _,r in ipairs(requests) do
        if r.caseID==caseID then assert(r.validated==true,"Unexpected/unmatched request in case: "..caseID) end
    end
    table.insert(cases,caseID)
end
local function action(m,stamp)
    activeCast={caseID=caseID,actor=m:GetAttribute("ProbeActorId"),name=m.Name,stamp=stamp}
    m:SetAttribute("ActionAt",stamp)
end
local function eventStamp(m,key)
    if key=="enemy_warning" then return m:GetAttribute("RegionalTelegraphAt") end
    if key=="boss_slam" then return m:GetAttribute("RegionalImpactAt") end
    if key=="arrow_hit" or key=="melee_hit" or key=="enemy_defeat" then return m:GetAttribute("DamageCueAt") end
    return m:GetAttribute("ActionAt")
end
local function record(method,key,m)
    local r={caseID=caseID,method=method,key=key,owner=m,actor=if m then m:GetAttribute("ProbeActorId") else 0,name=if m then m.Name else "nil",time=now(),stamp=if m then eventStamp(m,key) else nil}
    table.insert(requests,r);return r
end
local function matching(m,key,stamp)
    local found={}
    for _,r in ipairs(requests) do if r.caseID==caseID and r.owner==m and r.key==key and r.stamp==stamp then table.insert(found,r) end end
    return found
end
local function collect(predicate,label)
    local start=now();local deadline=start+2
    while true do
        inspect();condition(not interference,"Camera interference")
        -- Inspect records BEFORE testing reader timeout. Recorded timely events
        -- remain valid even if this coroutine was resumed late by the host.
        local value=predicate();if value then return value end
        if now()>=deadline then
            condition(covered(start,deadline),"Unobserved collection interval: "..label)
            error("Missing recorded event: "..label)
        end
        pause(.03,"collect "..label)
    end
end
local function expect(m,key,stamp,ttl)
    local r=collect(function() local list=matching(m,key,stamp);assert(#list<=1,"Duplicate correlated request");return list[1] end,key)
    assert(r.time>=stamp and r.time-stamp<=ttl,"Recorded request outside original runtime TTL")
    r.validated=true
    return r
end
local function noNew(startCount,seconds,label,started,deadline)
    local _,ended=observe(seconds,label,started)
    if deadline then condition(ended<=deadline,"Negative observation exceeded original TTL: "..label) end
    assert(#requests==startCount,label..": unexpected cue")
end
local function warning(m,duration)
    local stamp=now();m:SetAttribute("TelegraphName","Antler Cleave")
    m:SetAttribute("RegionalTelegraphAt",stamp);m:SetAttribute("RegionalTelegraphUntil",stamp+duration);m:SetAttribute("CombatState","Windup")
    local r=expect(m,"enemy_warning",stamp,duration)
    assert(r.method=="PlayOwned","Warning did not use owned API")
    return r,stamp+duration
end
local function stopExpected(r,mutationAt)
    local d=collect(function() for _,v in ipairs(disposals) do if v.request==r then return v end end end,"warning disposal")
    assert(d.caseID==r.caseID and d.actor==r.actor and d.stamp==r.stamp,"Disposal identity mismatch")
    assert(d.time>=mutationAt,"Disposal predates cancellation stimulus")
    if d.time-mutationAt>.3 then condition(covered(mutationAt,mutationAt+.3),"Heartbeat gap before delayed disposal") end
    assert(d.time-mutationAt<=.3,"Disposal exceeded presentation cancellation bound")
end
local function readyForMutation(deadline,label)
    condition(now()+.25<deadline,label..": insufficient original window for stimulus and covered observation")
end
local ok,err=xpcall(function()
    camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(center+Vector3.new(0,7,16),center);camera.Focus=CFrame.new(center)
    -- NEVER assign CurrentCamera: changing that reference can destroy cameras.
    watch(workspace:GetPropertyChangedSignal("CurrentCamera"),function() fault("CurrentCamera changed") end)
    watch(camera:GetPropertyChangedSignal("CameraType"),function() fault("CameraType changed") end)
    watch(camera:GetPropertyChangedSignal("CFrame"),function() fault("Camera CFrame changed") end)
    watch(camera.AncestryChanged,function() fault("Camera ancestry changed") end)
    watch(Run.PreRender,inspect)
    watch(Run.Heartbeat,function() table.insert(heartbeats,now());inspect() end)
    audio.Start()
    local initial=actor("CueFixture")
    assert(original.Play("enemy_warning",center)==false and original.PlayFor(initial,"enemy_warning",center)==false,"Boolean APIs/unbound assets changed")
    assert(original.PlayOwned(initial,"enemy_warning",center)==nil,"Unbound owned voice must be nil")
    assert(#SoundService.GuildborneAudio:GetDescendants()==2,"Expected SoundGroups only")
    audio.Play=function(key,pos) record("Play",key,nil);return original.Play(key,pos) end
    audio.PlayFor=function(m,key,pos) record("PlayFor",key,m);return original.PlayFor(m,key,pos) end
    audio.PlayOwned=function(m,key,pos)
        local r=record("PlayOwned",key,m);local actual=original.PlayOwned(m,key,pos);assert(actual==nil,"Unexpected bound voice")
        local done=false
        return function()
            if done then return end;done=true
            table.insert(disposals,{request=r,caseID=r.caseID,actor=r.actor,name=r.name,stamp=r.stamp,time=now()})
            if actual then actual() end
        end
    end
    local remotes=RS:FindFirstChild("GuildborneRemotes")
    if not remotes then remotes=Instance.new("Folder");remotes.Name="GuildborneRemotes";remotes.Parent=RS;createdRemotes=remotes end
    local state=remotes:FindFirstChild("State")
    if not state then state=Instance.new("RemoteEvent");state.Name="State";state.Parent=remotes;createdState=state end
    assert(state:IsA("RemoteEvent"),"Invalid State; probe never fires it")
    watch(workspace.DescendantAdded,function(v)
        if v:IsA("BasePart") and (v.Name=="GuildborneSkillEffect" or v.Name=="GuildborneBossTelegraph") then
            table.insert(effects,v)
            -- Only first cast's VFX is asserted. That context starts with zero
            -- prior casts, so no previous delayed effect can impersonate it.
            if activeCast and activeCast.caseID=="pending-target-then-ready-actual-VFX-and-single-cue" then
                table.insert(vfxRecords,{caseID=activeCast.caseID,actor=activeCast.actor,name=activeCast.name,stamp=activeCast.stamp,time=now(),observationalOnly=false})
            else
                table.insert(vfxRecords,{caseID=caseID,time=now(),observationalOnly=true})
            end
        end
    end)
    controller=require(tree.Controllers.CombatController)()
    assert(script:GetAttribute("StartRequested")~=true,"StartRequested must be a NEW edge after READY")
    local armedAt=nil;local readyAt=now()
    watch(script:GetAttributeChangedSignal("StartRequested"),function()
        if script:GetAttribute("StartRequested")==true and not armedAt then armedAt=now() end
    end)
    script:SetAttribute("ProbeStatus","READY");print("READY_CLIENT_CUE_PROBE",script:GetFullName())
    while not armedAt and now()-readyAt<60 do pause(.05,"manual arm wait") end
    condition(armedAt~=nil and armedAt-readyAt<=60,"Manual arm deadline expired")
    condition(covered(armedAt-1,armedAt),"Manual arm requires preceding 1s Heartbeats with gaps <= .15s")
    condition(not interference,"Camera changed during READY")
    script:SetAttribute("ProbeStatus","RUNNING")

    begin("pending-target-then-ready-actual-VFX-and-single-cue")
    firstStamp=now();action(initial,firstStamp);local before=#requests
    noNew(before,.14,"missing target")
    assert(#effects==0,"Missing target produced VFX before readiness")
    readyForMutation(firstStamp+.62,"Target readiness")
    local firstReadyAt=now();target(initial,center+Vector3.new(0,0,-5));local firstRequest=expect(initial,"bow_release",firstStamp,.62)
    local v=collect(function() for _,r in ipairs(vfxRecords) do if r.caseID==caseID and r.actor==initial:GetAttribute("ProbeActorId") and r.stamp==firstStamp then return r end end end,"first actual VFX")
    assert(v.time>=firstStamp and v.time-firstStamp<=.62,"VFX record outside original TTL")
    for _,r in ipairs(vfxRecords) do
        if r.caseID==caseID then assert(r.time>=firstReadyAt,"First cast VFX predates target readiness") end
    end
    noNew(#requests,.14,"duplicate action",firstRequest.time,firstStamp+.62)
    assert(#matching(initial,"bow_release",firstStamp)==1,"Duplicate first action record");finish()

    begin("duplicate-future-stale-and-valid-recovery")
    before=#requests;action(initial,now()+100);noNew(before,.14,"future action")
    action(initial,now()-10);noNew(before,.14,"stale action")
    local stamp=now();action(initial,stamp);expect(initial,"bow_release",stamp,.62);finish()

    begin("malformed-action-feedback-stamps-keep-HUD-live-and-recover")
    local malformed=actor("MalformedHUDStampFixture");observe(.14,"actor registration")
    target(malformed,center+Vector3.new(0,0,-5));before=#requests
    action(malformed,"invalid");malformed:SetAttribute("FeedbackAt",true);malformed:SetAttribute("CombatHealth",99)
    noNew(before,.14,"string action bool feedback")
    local bar=assert(malformed:FindFirstChild("CombatHealthBar"));local label=assert(bar:FindFirstChildOfClass("TextLabel"))
    assert(bar.Enabled and label.Text:find("99/100",1,true),"HUD stalled on malformed stamps")
    action(malformed,false);malformed:SetAttribute("FeedbackAt","invalid");malformed:SetAttribute("CombatHealth",98)
    noNew(before,.14,"bool action string feedback");assert(bar.Enabled and label.Text:find("98/100",1,true),"HUD stalled")
    stamp=now();action(malformed,stamp);malformed:SetAttribute("FeedbackAt",stamp);malformed:SetAttribute("Feedback","Fixture recovery");malformed:SetAttribute("CombatHealth",97)
    expect(malformed,"bow_release",stamp,.62)
    collect(function() return bar.Enabled and label.Text:find("97/100",1,true) and label.Text:find("Fixture recovery",1,true) end,"HUD recovery");finish()

    begin("target-readiness-does-not-renew-TTL")
    target(initial,nil);action(initial,now());before=#requests
    noNew(before,.75,"pending TTL expiry");target(initial,center+Vector3.new(0,0,-5));noNew(before,.14,"expired ready target");finish()

    begin("nil-clear-consumes-pending-before-next-poll")
    target(initial,nil);stamp=now();action(initial,stamp);before=#requests;noNew(before,.14,"pending cancelled action")
    readyForMutation(stamp+.62,"Nil cancellation")
    local nilAt=nil;local clearObserver
    clearObserver=watch(initial:GetAttributeChangedSignal("ActionAt"),function()
        if initial:GetAttribute("ActionAt")==nil then nilAt=now();clearObserver:Disconnect();action(initial,stamp);target(initial,center+Vector3.new(0,0,-5)) end
    end)
    initial:SetAttribute("ActionAt",nil)
    collect(function() return nilAt end,"nil callback")
    condition(nilAt+.25<stamp+.62,"Nil callback left insufficient original TTL")
    noNew(before,.14,"nil clear then restore",nilAt,stamp+.62);clearObserver:Disconnect();finish()

    begin("same-model-reparent-retains-action-highwater")
    stamp=now();action(initial,stamp);expect(initial,"bow_release",stamp,.62)
    readyForMutation(stamp+.62,"Reparent")
    before=#requests;local reparentAt=now();initial.Parent=nil;initial.Parent=workspace
    noNew(before,.14,"same model reparent",reparentAt,stamp+.62);finish()

    begin("release-vs-damage-heal-future-damage")
    initial:SetAttribute("BossPhase",1);stamp=now();initial:SetAttribute("RegionalImpactAt",stamp)
    expect(initial,"boss_slam",stamp,.5)
    for _,r in ipairs(requests) do if r.caseID==caseID then assert(r.key~="melee_hit","Release became hit") end end
    stamp=now();initial:SetAttribute("DamageCue","arrow_hit");initial:SetAttribute("DamageCueAt",stamp);initial:SetAttribute("CombatHealth",85)
    expect(initial,"arrow_hit",stamp,.6)
    before=#requests;initial:SetAttribute("CombatHealth",95);noNew(before,.14,"healing")
    initial:SetAttribute("DamageCueAt",now()+100);initial:SetAttribute("CombatHealth",90);noNew(before,.14,"future damage");finish()

    begin("damage-stamp-before-lethal-HP-emits-one-defeat")
    local lethal=actor("DamageBeforeLethalFixture");observe(.14,"lethal actor baseline")
    stamp=now();before=#requests;lethal:SetAttribute("DamageCue","melee_hit");lethal:SetAttribute("DamageCueAt",stamp)
    noNew(before,.14,"damage stamp stable HP");readyForMutation(stamp+.6,"Lethal HP stimulus")
    lethal:SetAttribute("CombatHealth",0);local lethalRequest=expect(lethal,"enemy_defeat",stamp,.6)
    noNew(#requests,.14,"lethal duplicate",lethalRequest.time,stamp+.6)
    assert(#matching(lethal,"enemy_defeat",stamp)==1,"Duplicate lethal record");finish()

    local function cancelCase(id,mutate)
        begin(id);local r,deadline=warning(initial,2);readyForMutation(deadline,id)
        local at=now();mutate(initial);stopExpected(r,at);finish()
        initial:SetAttribute("CombatState","Idle");initial:SetAttribute("CombatHealth",100);initial:SetAttribute("OwnerUserId",player.UserId)
    end
    cancelCase("warning-cancel",function(m) m:SetAttribute("CombatState","Idle") end)
    cancelCase("warning-death",function(m) m:SetAttribute("CombatHealth",0) end)
    cancelCase("warning-identity-replacement",function(m) m:SetAttribute("TelegraphName","Root Burst") end)
    cancelCase("warning-end-replacement",function(m) m:SetAttribute("RegionalTelegraphUntil",now()+4) end)
    cancelCase("warning-owner-loss",function(m) m:SetAttribute("OwnerUserId",player.UserId+1) end)
    begin("future-expired-warning-rejected")
    before=#requests;initial:SetAttribute("RegionalTelegraphAt",now()+100);initial:SetAttribute("RegionalTelegraphUntil",now()+101);initial:SetAttribute("CombatState","Windup")
    noNew(before,.14,"future warning");initial:SetAttribute("RegionalTelegraphAt",now()-2);initial:SetAttribute("RegionalTelegraphUntil",now()-1)
    noNew(before,.14,"expired warning");initial:SetAttribute("CombatState","Idle");finish()
    begin("warning-expiry");local r,deadline=warning(initial,.35);stopExpected(r,deadline);finish();initial:SetAttribute("CombatState","Idle")
    begin("warning-removal");r,deadline=warning(initial,2);readyForMutation(deadline,"Removal");local at=now();initial.Parent=nil;stopExpected(r,at);finish()
    begin("warning-controller-destroy");local last=actor("DestroyFixture");observe(.14,"destroy actor registration")
    r,deadline=warning(last,2);readyForMutation(deadline,"Destroy");at=now();controller.Destroy();controller=nil;stopExpected(r,at)
    assert(not gui:FindFirstChild("GuildborneCombatUI"),"UI leaked");finish()
    inspect();condition(not interference,"Camera interference before completion");assert(#cases==17,"Expected all 17 cases")
end,debug.traceback)
local function safe(value)
    local kind=typeof(value)
    if kind=="number" then return if value==value and math.abs(value)<math.huge then value else tostring(value) end
    if kind=="string" or kind=="boolean" then return value end
    if kind=="nil" then return "nil" end
    if kind=="Instance" then return value.Name end
    if kind=="table" then local result={};for k,v in pairs(value) do if k~="owner" and k~="request" then result[k]=safe(v) end end;return result end
    return tostring(value)
end
local report={status=if ok then "PASS" elseif inconclusive or interference then "INCONCLUSIVE" else "FAIL",error=if ok then "" else tostring(err),
    cases=cases,requests=safe(requests),disposals=safe(disposals),vfx=safe(vfxRecords),readiness=safe(mutations),waits=waits,heartbeats=heartbeats,
    originalStamp=firstStamp,actionTTL=.62,cameraEvents=cameraEvents,actors={},audibleAcceptance=false,serverCombatTested=false,syntheticStopRecorder=true,stopPlayRequired=true}
for _,m in ipairs(actors) do
    local root=m.PrimaryPart
    table.insert(report.actors,{name=m.Name,id=m:GetAttribute("ProbeActorId"),attributes=safe(m:GetAttributes()),inWorkspace=m:IsDescendantOf(workspace),root=if root then tostring(root.Position) else "nil",
        actualCameraDistance=if root and workspace.CurrentCamera then (workspace.CurrentCamera.CFrame.Position-root.Position).Magnitude else "nil"})
end
report.camera={sameIdentity=workspace.CurrentCamera==camera,type=camera.CameraType.Name,position=tostring(camera.CFrame.Position),
    actualType=if workspace.CurrentCamera then workspace.CurrentCamera.CameraType.Name else "nil",actualPosition=if workspace.CurrentCamera then tostring(workspace.CurrentCamera.CFrame.Position) else "nil"}
local function output(prefix)
    local maximumGap=0
    for i=2,#heartbeats do maximumGap=math.max(maximumGap,heartbeats[i]-heartbeats[i-1]) end
    local summary={status=report.status,cases=cases,requestCount=#requests,disposalCount=#disposals,VFXCount=#vfxRecords,
        heartbeatCount=#heartbeats,maximumHeartbeatGap=maximumGap,waitCount=#waits,actionTTL=.62,
        error=string.sub(report.error or "",1,2000),cleanupErrors=report.cleanupErrors or {},
        audibleAcceptance=false,serverCombatTested=false,stopPlayRequired=true}
    local http=game:GetService("HttpService")
    script:SetAttribute("ProbeReport",http:JSONEncode(safe(summary)));script:SetAttribute("ProbeStatus",report.status)
    print(prefix,http:JSONEncode(safe(report)))
end
-- Preserve raw failure before cleanup; final record additionally includes teardown.
if not ok then pcall(output,"CLIENT_CUE_PROBE_FAILURE") end
for _,c in ipairs(connections) do c:Disconnect() end
if controller then pcall(controller.Destroy) end
local leftover=gui:FindFirstChild("GuildborneCombatUI");if leftover then leftover:Destroy() end
audio.Play=original.Play;audio.PlayFor=original.PlayFor;audio.PlayOwned=original.PlayOwned;audio.Destroy()
for _,m in ipairs(actors) do m:Destroy() end
for _,v in ipairs(effects) do v:Destroy() end
if createdState then createdState:Destroy() end;if createdRemotes then createdRemotes:Destroy() end
local cleanupErrors={}
for _,restore in ipairs({function() camera.CameraType=oldType end,function() camera.CFrame=oldFrame end,function() camera.Focus=oldFocus end}) do
    local restored,e=pcall(restore);if not restored then table.insert(cleanupErrors,tostring(e)) end
end
if workspace.CurrentCamera~=camera or not camera:IsDescendantOf(workspace) then table.insert(cleanupErrors,"Original camera identity changed externally; never reassigned") end
report.cleanupErrors=cleanupErrors
if #cleanupErrors>0 then report.status="INCONCLUSIVE";ok=false;err="INCONCLUSIVE: camera cleanup" end
output("CLIENT_CUE_PROBE_TERMINAL")
assert(ok,err)
