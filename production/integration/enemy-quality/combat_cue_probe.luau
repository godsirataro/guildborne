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
local camera=assert(workspace.CurrentCamera)
local oldType,oldFrame,oldFocus=camera.CameraType,camera.CFrame,camera.Focus
local center=camera.CFrame.Position+Vector3.new(0,10000,0)
assert(#workspace:GetPartBoundsInRadius(center,40)==0,"Empty isolated space required")
local actors,requests,stops,effects={},{},{},{}
local controller,connection,createdRemotes,createdState=nil,nil,nil,nil
local cases={}
local probeConnections,waits,cameraEvents={},{},{}
local interference=false;local inconclusive=false;local firstStamp=nil
local function now() return workspace:GetServerTimeNow() end
local function watch(signal,callback)
    local c=signal:Connect(callback);table.insert(probeConnections,c);return c
end
local function cameraFault(reason)
    interference=true
    if #cameraEvents<64 then table.insert(cameraEvents,{reason=reason,time=now()}) end
end
local function inspectCamera()
    if workspace.CurrentCamera~=camera then cameraFault("CurrentCamera identity") end
    if camera.CameraType~=Enum.CameraType.Scriptable then cameraFault("CameraType") end
    if not camera:IsDescendantOf(workspace) then cameraFault("Camera removed") end
    for _,m in ipairs(actors) do
        if m:IsDescendantOf(workspace) and m.PrimaryPart and (camera.CFrame.Position-m.PrimaryPart.Position).Magnitude>40 then cameraFault("Actor distance: "..m.Name) end
    end
end
local function requireCondition(condition,reason)
    if not condition then inconclusive=true;error("INCONCLUSIVE: "..reason,2) end
end
local function measuredWait(seconds,label,maximum)
    local started=now();local clockStarted=os.clock();task.wait(seconds)
    local elapsed=now()-started
    table.insert(waits,{label=label,requested=seconds,serverElapsed=elapsed,localElapsed=os.clock()-clockStarted})
    inspectCamera()
    requireCondition(not interference,"Camera interference; see cameraEvents")
    requireCondition(elapsed>=seconds-.001 and elapsed<=maximum,"Scheduler wait outside bound: "..label)
end
local function settle() measuredWait(.14,"settle",.25) end
local function count(key)
    local n=0;for _,v in ipairs(requests) do if not key or v.key==key then n+=1 end end;return n
end
local function actor(name)
    local m=Instance.new("Model");m.Name=name
    local p=Instance.new("Part");p.Name="HumanoidRootPart";p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Position=center;p.Parent=m;m.PrimaryPart=p
    m:SetAttribute("GuildborneEnemy",true);m:SetAttribute("OwnerUserId",player.UserId)
    m:SetAttribute("CombatHealth",100);m:SetAttribute("CombatMaxHealth",100);m:SetAttribute("CombatState","Idle")
    m:SetAttribute("ClassId","Archer");m:SetAttribute("ActionEffect","Basic")
    watch(p:GetPropertyChangedSignal("CFrame"),function() cameraFault("Fixture root moved: "..m.Name) end)
    table.insert(actors,m);m.Parent=workspace;return m
end
local function record(method,key,owner)
    table.insert(requests,{method=method,key=key,owner=owner,time=now()})
end
local function warning(m,seconds)
    local before=#requests
    local stamp=now();m:SetAttribute("TelegraphName","Antler Cleave")
    m:SetAttribute("RegionalTelegraphAt",stamp);m:SetAttribute("RegionalTelegraphUntil",stamp+(seconds or 2))
    m:SetAttribute("CombatState","Windup");settle()
    requireCondition(now()>=stamp and now()<stamp+(seconds or 2),"Warning expired before admission assertion")
    assert(#requests==before+1 and requests[#requests].method=="PlayOwned" and requests[#requests].owner==m,"Warning request absent")
    return #requests
end
local function stopped(index,label)
    assert(stops[index]==1,label..": expected exactly one disposal")
    table.insert(cases,label)
end
local ok,err=xpcall(function()
    camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(center+Vector3.new(0,7,16),center);camera.Focus=CFrame.new(center)
    -- Reuse the original camera: assigning CurrentCamera can destroy other
    -- Cameras parented directly to Workspace. Never swap camera references.
    -- Latch every property notification, including changes restored before the
    -- next poll. Never recapture or move a camera to hide interference.
    watch(workspace:GetPropertyChangedSignal("CurrentCamera"),function() cameraFault("CurrentCamera changed signal") end)
    watch(camera:GetPropertyChangedSignal("CameraType"),function() cameraFault("CameraType changed signal") end)
    watch(camera:GetPropertyChangedSignal("CFrame"),function() cameraFault("Camera CFrame changed signal") end)
    watch(camera.AncestryChanged,function() cameraFault("Camera ancestry changed signal") end)
    watch(Run.Heartbeat,inspectCamera);watch(Run.PreRender,inspectCamera)
    audio.Start()
    local initial=actor("CueFixture")
    assert(original.Play("enemy_warning",center)==false and original.PlayFor(initial,"enemy_warning",center)==false,"Boolean API changed/unexpected loaded sound")
    assert(original.PlayOwned(initial,"enemy_warning",center)==nil,"Unbound owned voice must be nil")
    assert(#SoundService.GuildborneAudio:GetDescendants()==2,"Unbound audio must contain groups only")
    audio.Play=function(key,position) record("Play",key,nil);return original.Play(key,position) end
    audio.PlayFor=function(owner,key,position) record("PlayFor",key,owner);return original.PlayFor(owner,key,position) end
    audio.PlayOwned=function(owner,key,position)
        record("PlayOwned",key,owner);local index=#requests;local dispose=original.PlayOwned(owner,key,position)
        assert(dispose==nil,"Unbound IDs unexpectedly created a voice")
        local done=false
        return function() if not done then done=true;stops[index]=(stops[index] or 0)+1;if dispose then dispose() end end end
    end
    local remotes=RS:FindFirstChild("GuildborneRemotes")
    if not remotes then remotes=Instance.new("Folder");remotes.Name="GuildborneRemotes";remotes.Parent=RS;createdRemotes=remotes end
    local state=remotes:FindFirstChild("State")
    if not state then state=Instance.new("RemoteEvent");state.Name="State";state.Parent=remotes;createdState=state end
    assert(state:IsA("RemoteEvent"),"State must be a RemoteEvent; no event will be fired")
    connection=workspace.DescendantAdded:Connect(function(v) if v:IsA("BasePart") and (v.Name=="GuildborneSkillEffect" or v.Name=="GuildborneBossTelegraph") then table.insert(effects,v) end end)
    controller=require(tree.Controllers.CombatController)()
    measuredWait(.5,"fixed-startup-stabilization",1.5) -- exactly once, before any action stamp
    firstStamp=now();initial:SetAttribute("ActionAt",firstStamp);local before=count();settle()
    requireCondition(now()-firstStamp>=0 and now()-firstStamp<.62-.25,"Insufficient original TTL for target-ready observation")
    assert(count()==before,"Missing target emitted cue")
    assert(#effects==0,"Missing target emitted VFX")
    initial:SetAttribute("ActionTargetPosition",center+Vector3.new(0,0,-5));settle()
    requireCondition(now()-firstStamp>=0 and now()-firstStamp<.62,"Original action TTL expired before target-ready assertion")
    assert(count()==before+1,"Ready target cue count mismatch")
    assert(requests[#requests].key=="bow_release","Ready target cue key mismatch")
    assert(#effects>0,"Ready target produced no actual VFX")
    settle();assert(count()==before+1,"Duplicate action replayed")
    table.insert(cases,"pending-target-then-ready-actual-VFX-and-single-cue")
    initial:SetAttribute("ActionAt",now()+100);before=count();settle();assert(count()==before,"Future action admitted")
    initial:SetAttribute("ActionAt",now()-10);settle();assert(count()==before,"Stale action admitted")
    initial:SetAttribute("ActionAt",now());settle();assert(count()==before+1,"Rejected future poisoned valid newer action")
    table.insert(cases,"duplicate-future-stale-and-valid-recovery")
    local malformed=actor("MalformedHUDStampFixture");settle()
    malformed:SetAttribute("ActionTargetPosition",center+Vector3.new(0,0,-5))
    local malformedBefore=count()
    malformed:SetAttribute("ActionAt","invalid");malformed:SetAttribute("FeedbackAt",true)
    malformed:SetAttribute("CombatHealth",99);settle()
    local healthBar=assert(malformed:FindFirstChild("CombatHealthBar"),"Malformed stamp actor lost health bar")
    local healthLabel=assert(healthBar:FindFirstChildOfClass("TextLabel"),"Missing health label")
    assert(healthBar.Enabled and healthBar.Adornee==malformed.PrimaryPart and healthLabel.Text:find("99/100",1,true),"String action/bool feedback stopped visible HUD updates")
    assert(count()==malformedBefore,"Malformed stamps emitted a cue")
    malformed:SetAttribute("ActionAt",false);malformed:SetAttribute("FeedbackAt","invalid")
    malformed:SetAttribute("CombatHealth",98);settle()
    assert(healthBar.Enabled and healthLabel.Text:find("98/100",1,true),"Bool action/string feedback stopped visible HUD updates")
    assert(count()==malformedBefore,"Swapped malformed stamps emitted a cue")
    malformed:SetAttribute("ActionAt",now());malformed:SetAttribute("FeedbackAt",now())
    malformed:SetAttribute("Feedback","Fixture recovery");malformed:SetAttribute("CombatHealth",97);settle()
    assert(count()==malformedBefore+1 and requests[#requests].key=="bow_release","Valid action did not recover after malformed stamps")
    assert(healthBar.Enabled and healthLabel.Text:find("97/100",1,true) and healthLabel.Text:find("Fixture recovery",1,true),"Valid HUD timestamps did not recover")
    table.insert(cases,"malformed-action-feedback-stamps-keep-HUD-live-and-recover")
    initial:SetAttribute("ActionTargetPosition",nil);initial:SetAttribute("ActionAt",now());before=count()
    measuredWait(.75,"expire-pending-target",.95);initial:SetAttribute("ActionTargetPosition",center+Vector3.new(0,0,-5));settle()
    assert(count()==before,"Late target revived expired action")
    table.insert(cases,"target-readiness-does-not-renew-TTL")
    initial:SetAttribute("ActionTargetPosition",nil)
    local cancelledStamp=now();initial:SetAttribute("ActionAt",cancelledStamp);before=count();settle()
    assert(count()==before,"Missing-target cancellation setup emitted action")
    -- This observer is connected after the controller's own attribute listener.
    -- Restore from the nil notification, without waiting another Heartbeat, so
    -- the test cannot pass merely because the polling loop saw the nil value.
    local nilObserved=false
    local clearObserver
    clearObserver=watch(initial:GetAttributeChangedSignal("ActionAt"),function()
        if initial:GetAttribute("ActionAt")==nil then
            nilObserved=true;clearObserver:Disconnect()
            initial:SetAttribute("ActionAt",cancelledStamp)
            initial:SetAttribute("ActionTargetPosition",center+Vector3.new(0,0,-5))
        end
    end)
    initial:SetAttribute("ActionAt",nil);settle();clearObserver:Disconnect()
    assert(nilObserved and now()-cancelledStamp<.62,"Cancellation case inconclusive: nil unobserved or original TTL elapsed")
    assert(count()==before,"Cleared pending action revived from the same timestamp")
    table.insert(cases,"nil-clear-consumes-pending-before-next-poll")
    local acceptedStamp=now();initial:SetAttribute("ActionAt",acceptedStamp);settle()
    assert(count()==before+1,"Reparent setup action not admitted")
    before=count();initial.Parent=nil;initial.Parent=workspace;settle()
    assert(now()-acceptedStamp<.62,"Reparent case inconclusive: original TTL elapsed")
    assert(count()==before,"Same-model reparent replayed accepted action")
    table.insert(cases,"same-model-reparent-retains-action-highwater")
    -- Regional impact is an attack release even on evade, never proof of a hit.
    before=count("melee_hit");initial:SetAttribute("BossPhase",1);initial:SetAttribute("RegionalImpactAt",now());settle()
    assert(requests[#requests].key=="boss_slam" and count("melee_hit")==before,"Release incorrectly became hit confirmation")
    initial:SetAttribute("DamageCue","arrow_hit");initial:SetAttribute("DamageCueAt",now());initial:SetAttribute("CombatHealth",85);settle()
    assert(requests[#requests].key=="arrow_hit","Fresh HP drop missing hit cue")
    before=count();initial:SetAttribute("CombatHealth",95);settle();assert(count()==before,"Healing emitted hit cue")
    initial:SetAttribute("DamageCueAt",now()+100);initial:SetAttribute("CombatHealth",90);settle();assert(count()==before,"Future damage cue admitted")
    table.insert(cases,"release-vs-damage-heal-future-damage")
    local lethal=actor("DamageBeforeLethalFixture");settle()
    local damageStamp=now();before=count("enemy_defeat")
    lethal:SetAttribute("DamageCue","melee_hit");lethal:SetAttribute("DamageCueAt",damageStamp);settle()
    assert(count("enemy_defeat")==before,"Stable HP emitted defeat before lethal decrease")
    lethal:SetAttribute("CombatHealth",0);settle()
    assert(now()-damageStamp<.6,"Lethal ordering case inconclusive: damage TTL elapsed")
    assert(count("enemy_defeat")==before+1,"Damage-before-health replication lost lethal defeat cue")
    settle();assert(count("enemy_defeat")==before+1,"Lethal defeat cue replayed")
    table.insert(cases,"damage-stamp-before-lethal-HP-emits-one-defeat")
    local index=warning(initial);initial:SetAttribute("CombatState","Idle");settle();stopped(index,"warning-cancel")
    index=warning(initial);initial:SetAttribute("CombatHealth",0);settle();stopped(index,"warning-death")
    initial:SetAttribute("CombatHealth",100);initial:SetAttribute("CombatState","Idle");settle()
    index=warning(initial);initial:SetAttribute("TelegraphName","Root Burst");settle();stopped(index,"warning-identity-replacement")
    initial:SetAttribute("CombatState","Idle");settle()
    index=warning(initial);initial:SetAttribute("RegionalTelegraphUntil",now()+4);settle();stopped(index,"warning-end-replacement")
    initial:SetAttribute("CombatState","Idle");settle()
    index=warning(initial);initial:SetAttribute("OwnerUserId",player.UserId+1);settle();stopped(index,"warning-owner-loss")
    initial:SetAttribute("CombatState","Idle");initial:SetAttribute("OwnerUserId",player.UserId);settle()
    before=count();initial:SetAttribute("RegionalTelegraphAt",now()+100);initial:SetAttribute("RegionalTelegraphUntil",now()+101)
    initial:SetAttribute("CombatState","Windup");settle();assert(count()==before,"Future warning admitted")
    initial:SetAttribute("RegionalTelegraphAt",now()-2);initial:SetAttribute("RegionalTelegraphUntil",now()-1)
    settle();assert(count()==before,"Expired warning admitted")
    initial:SetAttribute("CombatState","Idle");settle()
    table.insert(cases,"future-expired-warning-rejected")
    index=warning(initial,.35);measuredWait(.5,"warning-expiry",.7);stopped(index,"warning-expiry")
    initial:SetAttribute("CombatState","Idle");settle()
    index=warning(initial);initial.Parent=nil;settle();stopped(index,"warning-removal")
    local last=actor("DestroyFixture");settle();index=warning(last)
    controller.Destroy();controller=nil;settle();stopped(index,"warning-controller-destroy")
    assert(not gui:FindFirstChild("GuildborneCombatUI"),"Combat UI leaked after Destroy")
    inspectCamera();requireCondition(not interference,"Camera interference before completion")
end,debug.traceback)
-- Capture BEFORE cleanup; serialization never dereferences arbitrary objects or
-- forwards nonfinite numbers/Roblox datatypes to JSONEncode.
local function safe(value)
    local kind=typeof(value)
    if kind=="number" then return if value==value and math.abs(value)<math.huge then value else tostring(value) end
    if kind=="string" or kind=="boolean" then return value end
    if kind=="nil" then return "nil" end
    if kind=="Instance" then return value.Name end
    if kind=="table" then local result={};for k,v in pairs(value) do result[k]=safe(v) end;return result end
    return tostring(value)
end
if not ok then
    local diagnosticOK,diagnosticError=pcall(function()
        local actorRecords={}
        for _,m in ipairs(actors) do
            local root=m.PrimaryPart
            table.insert(actorRecords,{name=m.Name,attributes=safe(m:GetAttributes()),inWorkspace=m:IsDescendantOf(workspace),
                root=if root then {name=root.Name,position=tostring(root.Position),cameraDistance=(camera.CFrame.Position-root.Position).Magnitude,
                    actualCameraDistance=if workspace.CurrentCamera then (workspace.CurrentCamera.CFrame.Position-root.Position).Magnitude else "nil"} else "nil",
                targetReady=typeof(m:GetAttribute("ActionTargetPosition"))=="Vector3",hasPrimaryPart=root~=nil})
        end
        local requestRecords={}
        for _,r in ipairs(requests) do table.insert(requestRecords,{method=r.method,key=r.key,owner=if r.owner then r.owner.Name else "nil",time=r.time}) end
        print("CLIENT_CUE_PROBE_FAILURE",game:GetService("HttpService"):JSONEncode(safe({
            status=if inconclusive or interference or tostring(err):lower():find("inconclusive",1,true) then "INCONCLUSIVE" else "FAIL",
            error=tostring(err),requests=requestRecords,actors=actorRecords,originalStamp=firstStamp,
            originalStampAge=if firstStamp then now()-firstStamp else "not-started",actionTTL=.62,waits=waits,
            camera={ownedName=camera.Name,currentName=if workspace.CurrentCamera then workspace.CurrentCamera.Name else "nil",sameIdentity=workspace.CurrentCamera==camera,
                type=camera.CameraType.Name,position=tostring(camera.CFrame.Position),distanceToCenter=(camera.CFrame.Position-center).Magnitude,
                actualType=if workspace.CurrentCamera then workspace.CurrentCamera.CameraType.Name else "nil",
                actualPosition=if workspace.CurrentCamera then tostring(workspace.CurrentCamera.CFrame.Position) else "nil",events=cameraEvents},
            VFXCount=#effects,completedCases=cases,audibleAcceptance=false,serverCombatTested=false})))
    end)
    if not diagnosticOK then print("CLIENT_CUE_PROBE_DIAGNOSTIC_ERROR",tostring(diagnosticError),tostring(err)) end
end
-- Always restore methods before audio destruction, even after assertion failures.
for _,c in ipairs(probeConnections) do c:Disconnect() end
if controller then pcall(controller.Destroy) end
local leftover=gui:FindFirstChild("GuildborneCombatUI");if leftover then leftover:Destroy() end
audio.Play=original.Play;audio.PlayFor=original.PlayFor;audio.PlayOwned=original.PlayOwned
audio.Destroy()
if connection then connection:Disconnect() end
for _,m in ipairs(actors) do m:Destroy() end
for _,v in ipairs(effects) do v:Destroy() end
if createdState then createdState:Destroy() end
if createdRemotes then createdRemotes:Destroy() end
-- Restore only properties we changed; never swap CurrentCamera or destroy a
-- camera we do not own. Each restoration is attempted even if another fails.
local cameraCleanupErrors={}
for _,restore in ipairs({
    function() camera.CameraType=oldType end,
    function() camera.CFrame=oldFrame end,
    function() camera.Focus=oldFocus end,
}) do
    local restored,restoreError=pcall(restore)
    if not restored then table.insert(cameraCleanupErrors,tostring(restoreError)) end
end
if workspace.CurrentCamera~=camera or not camera:IsDescendantOf(workspace) then
    table.insert(cameraCleanupErrors,"Original camera identity/ancestry changed externally; reference not reassigned")
end
if #cameraCleanupErrors>0 then
    print("CLIENT_CUE_PROBE_CAMERA_CLEANUP_INCONCLUSIVE",game:GetService("HttpService"):JSONEncode(cameraCleanupErrors))
    ok=false;err=tostring(err).."; INCONCLUSIVE: original camera restoration failed"
end
assert(ok,err)
print("PASS_CLIENT_CUE_REQUEST_LIFECYCLE",game:GetService("HttpService"):JSONEncode({cases=cases,requests=#requests,observedVFX=#effects,audibleAcceptance=false,serverCombatTested=false,syntheticAttributes=true,syntheticStopRecorder=true,stopPlayRequired=true}))
