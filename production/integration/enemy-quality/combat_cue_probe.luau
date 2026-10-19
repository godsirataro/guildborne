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
local function now() return workspace:GetServerTimeNow() end
local function settle() task.wait(.14) end
local function count(key)
    local n=0;for _,v in ipairs(requests) do if not key or v.key==key then n+=1 end end;return n
end
local function actor(name)
    local m=Instance.new("Model");m.Name=name
    local p=Instance.new("Part");p.Name="HumanoidRootPart";p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Position=center;p.Parent=m;m.PrimaryPart=p
    m:SetAttribute("GuildborneEnemy",true);m:SetAttribute("OwnerUserId",player.UserId)
    m:SetAttribute("CombatHealth",100);m:SetAttribute("CombatMaxHealth",100);m:SetAttribute("CombatState","Idle")
    m:SetAttribute("ClassId","Archer");m:SetAttribute("ActionEffect","Basic")
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
    assert(#requests==before+1 and requests[#requests].method=="PlayOwned" and requests[#requests].owner==m,"Warning request absent")
    return #requests
end
local function stopped(index,label)
    assert(stops[index]==1,label..": expected exactly one disposal")
    table.insert(cases,label)
end
local ok,err=xpcall(function()
    camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(center+Vector3.new(0,7,16),center);camera.Focus=CFrame.new(center)
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
    controller=require(tree.Controllers.CombatController)();settle()
    initial:SetAttribute("ActionAt",now());local before=count();settle()
    assert(count()==before and #effects==0,"Missing target consumed/emitted action")
    initial:SetAttribute("ActionTargetPosition",center+Vector3.new(0,0,-5));settle()
    assert(count()==before+1 and requests[#requests].key=="bow_release" and #effects>0,"Ready target did not admit same timestamp with actual VFX")
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
    task.wait(.75);initial:SetAttribute("ActionTargetPosition",center+Vector3.new(0,0,-5));settle()
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
    clearObserver=initial:GetAttributeChangedSignal("ActionAt"):Connect(function()
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
    index=warning(initial,.35);task.wait(.5);stopped(index,"warning-expiry")
    initial:SetAttribute("CombatState","Idle");settle()
    index=warning(initial);initial.Parent=nil;settle();stopped(index,"warning-removal")
    local last=actor("DestroyFixture");settle();index=warning(last)
    controller.Destroy();controller=nil;settle();stopped(index,"warning-controller-destroy")
    assert(not gui:FindFirstChild("GuildborneCombatUI"),"Combat UI leaked after Destroy")
end,debug.traceback)
-- Always restore methods before audio destruction, even after assertion failures.
if controller then pcall(controller.Destroy) end
local leftover=gui:FindFirstChild("GuildborneCombatUI");if leftover then leftover:Destroy() end
audio.Play=original.Play;audio.PlayFor=original.PlayFor;audio.PlayOwned=original.PlayOwned
audio.Destroy()
if connection then connection:Disconnect() end
for _,m in ipairs(actors) do m:Destroy() end
for _,v in ipairs(effects) do v:Destroy() end
if createdState then createdState:Destroy() end
if createdRemotes then createdRemotes:Destroy() end
camera.CameraType=oldType;camera.CFrame=oldFrame;camera.Focus=oldFocus
assert(ok,err)
print("PASS_CLIENT_CUE_REQUEST_LIFECYCLE",game:GetService("HttpService"):JSONEncode({cases=cases,requests=#requests,observedVFX=#effects,audibleAcceptance=false,serverCombatTested=false,syntheticAttributes=true,syntheticStopRecorder=true,stopPlayRequired=true}))
