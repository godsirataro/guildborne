-- Run on LOCAL CLIENT after full-game bootstrap, in an unsaved isolated Studio session.
-- Requires actual SkillEffects; invokes no remotes and proves no combat/rewards/audio.
-- No mock runtime. Compile-only is NOT_RUN until the controller executes this probe.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0,"Local unsaved Studio only")
local player=assert(game.Players.LocalPlayer,"CLIENT required")
local controllers=player:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Controllers")
local factory=require(controllers.SkillEffects)
local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local touch=game:GetService("UserInputService").TouchEnabled
local camera=assert(workspace.CurrentCamera)
local oldType,oldFrame,oldFocus=camera.CameraType,camera.CFrame,camera.Focus
local oldQuality=workspace:GetAttribute(config.QualityAttribute)
local center=(oldFrame+Vector3.new(0,150,0)):PointToWorldSpace(Vector3.new(0,0,-12))
local actors,parts={},{}
local extraConnections={}
local distantCenter: Vector3?=nil
local connection=workspace.DescendantAdded:Connect(function(item)
    if item:IsA("BasePart") and item.Name=="GuildborneSkillEffect" and ((item.Position-center).Magnitude<35 or (distantCenter and (item.Position-distantCenter).Magnitude<35)) then table.insert(parts,item) end
end)
local function settleEvents() task.wait() end -- yield once for Deferred signals
local function actor(age)
    local m=Instance.new("Model");m.Name="FireballPresentationProbe"
    local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Anchored=true;root.CanCollide=false;root.CanTouch=false;root.CanQuery=false;root.Transparency=1
    root.CFrame=CFrame.new(center);root.Parent=m;m.PrimaryPart=root
    m:SetAttribute("ClassId","Mage");m:SetAttribute("ActionEffect","Magic");m:SetAttribute("ActionAbilityId","fireball");m:SetAttribute("CombatHealth",100)
    m:SetAttribute("ActionAt",workspace:GetServerTimeNow()-(age or 0));m:SetAttribute("ActionTargetPosition",center+oldFrame.LookVector*5)
    table.insert(actors,m);m.Parent=workspace;return m
end
local function tally(start)
    local result={Charge=0,Travel=0,Impact=0}
    for i=start+1,#parts do
        local part=parts[i]
        if part:GetAttribute("VFXFamily")=="Mage.Fireball" then
            local stage=part:GetAttribute("VFXStage")
            assert(result[stage]~=nil,"Unrecognized fireball stage")
            result[stage]+=1
            assert(part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery,"VFX acquired physical authority")
            assert((part.Position-center).Magnitude<30,"Unbounded fireball geometry")
        end
    end
    return result
end
local function budget(counts)
    assert(counts.Charge<=(if touch then 7 else 9),"Charge part budget")
    assert(counts.Travel<=2,"Travel part budget")
    assert(counts.Impact<=(if touch then 6 else 8),"Impact part budget")
end
local function at(stamp,age)
    while workspace:GetServerTimeNow()<stamp+age do task.wait() end
end
local function emptyAfter(start)
    for i=start+1,#parts do assert(parts[i].Parent==nil,"Fireball retained an effect beyond cleanup boundary") end
end
local ok,result=xpcall(function()
    camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=oldFrame+Vector3.new(0,150,0);camera.Focus=CFrame.new(center)
    workspace:SetAttribute(config.QualityAttribute,"High")
    local start=#parts;local m=actor();local cast=factory();local stamp=m:GetAttribute("ActionAt")
    cast(m);settleEvents()
    assert(workspace:GetServerTimeNow()-stamp<.1,"INCONCLUSIVE_STUDIO_STALL: missed charge observation")
    local initial=tally(start);assert(initial.Charge>0 and initial.Travel==0 and initial.Impact==0,"Expected detailed fresh charge only");budget(initial)
    local duplicate=#parts;cast(m);settleEvents()
    assert(workspace:GetServerTimeNow()-stamp<.1,"INCONCLUSIVE_STUDIO_STALL: duplicate check crossed release")
    assert(#parts==duplicate,"Duplicate action replayed")
    at(stamp,.15);settleEvents()
    assert(workspace:GetServerTimeNow()-stamp<.29,"INCONCLUSIVE_STUDIO_STALL: missed travel observation")
    local travel=tally(start);assert(travel.Travel>0 and travel.Impact==0,"Travel marker missing or impact early")
    at(stamp,.36)
    local final=tally(start);assert(final.Impact>0,"Impact marker missing");budget(final)
    at(stamp,.9);emptyAfter(start)
    duplicate=#parts;cast(m);settleEvents();assert(#parts==duplicate,"Expired duplicate replayed")
    m:Destroy()

    start=#parts;m=actor(.2);cast=factory();stamp=m:GetAttribute("ActionAt");cast(m);settleEvents()
    assert(workspace:GetServerTimeNow()-stamp<.29,"INCONCLUSIVE_STUDIO_STALL: missed late pre-impact observation")
    local late=tally(start);assert(late.Charge==0 and late.Travel==0 and late.Impact==0,"Late observation replayed elapsed charge/release")
    at(stamp,.36);late=tally(start);assert(late.Impact>0 and late.Travel==0,"Late observation lost upcoming impact or replayed travel");budget(late)
    at(stamp,.9);emptyAfter(start);m:Destroy()
    for _,age in ipairs({.31,.5,1}) do
        start=#parts;m=actor(age);factory()(m);task.wait(.35)
        assert(#parts==start,"Past fireball stages replayed");m:Destroy()
    end
    for _,mode in ipairs({"nil","replace","death","remove"}) do
        start=#parts;m=actor();cast=factory();stamp=m:GetAttribute("ActionAt");cast(m);settleEvents()
        assert(tally(start).Charge>0,"Cancellation fixture never emitted real charge")
        assert(workspace:GetServerTimeNow()-stamp<.1,"INCONCLUSIVE_STUDIO_STALL: cancellation missed pending release")
        if mode=="nil" then m:SetAttribute("ActionAt",nil)
        elseif mode=="replace" then m:SetAttribute("ActionAt",stamp+10)
        elseif mode=="death" then m:SetAttribute("CombatHealth",0)
        else m.Parent=nil end
        local cancelled=#parts;task.wait(.05);emptyAfter(start)
        task.wait(.5);assert(#parts==cancelled,"Delayed stage survived "..mode);m:Destroy()
    end
    for _,stage in ipairs({"Travel","Impact"}) do
        start=#parts;m=actor();stamp=m:GetAttribute("ActionAt");factory()(m)
        at(stamp,if stage=="Travel" then .16 else .34);settleEvents()
        assert(workspace:GetServerTimeNow()-stamp<(if stage=="Travel" then .29 else .48),"INCONCLUSIVE_STUDIO_STALL: missed active "..stage)
        local active=false
        for i=start+1,#parts do
            if parts[i].Parent and parts[i]:GetAttribute("VFXStage")==stage then active=true end
        end
        assert(active,"Cancellation did not observe live "..stage)
        m:SetAttribute("ActionAt",nil);local cancelled=#parts
        task.wait(.05);emptyAfter(start)
        task.wait(.5);assert(#parts==cancelled,"Effect appeared after active "..stage.." cancellation");m:Destroy()
    end
    -- Shared scheduler/budget: first cast is detailed, four peers use compact
    -- Primary cues. This is a bounded object-count check, never an FPS claim.
    start=#parts;local party={};local shared=factory();local partyStamp=workspace:GetServerTimeNow()
    for i=1,5 do
        local member=actor();member:SetAttribute("ActionAt",partyStamp)
        table.insert(party,member);shared(member)
    end
    at(partyStamp,.37);settleEvents()
    local detail=tally(start);budget(detail);assert(detail.Impact>0,"Party lost first detailed cast")
    local primary=0
    for i=start+1,#parts do if parts[i]:GetAttribute("VFXBucket")=="Primary" then primary+=1 end end
    assert(primary>=4 and primary<=config.Budget.Primary,"Five-actor compact Primary coverage/budget")
    at(partyStamp,.95);emptyAfter(start)
    for _,member in ipairs(party) do member:Destroy() end
    local invalids:{any}={false,"invalid",workspace:GetServerTimeNow()+10}
    for _,invalid in ipairs(invalids) do
        start=#parts;m=actor();m:SetAttribute("ActionAt",invalid);factory()(m);task.wait(.35)
        assert(#parts==start,"Invalid/future action emitted geometry");m:Destroy()
    end
    start=#parts;m=actor();m:SetAttribute("ActionAt",nil);factory()(m);settleEvents();assert(#parts==start,"Missing timestamp emitted geometry");m:Destroy()
    start=#parts;m=actor();m.PrimaryPart.CFrame=camera.CFrame*CFrame.new(0,0,-config.Distance.Cull-10)
    distantCenter=m.PrimaryPart.Position
    -- The cast spans a distant source and near target: observe both ends and all
    -- workspace skill-effect creation, so an incorrectly admitted travel cannot hide.
    local distantCreated=0
    local distantConnection=workspace.DescendantAdded:Connect(function(item)
        if item:IsA("BasePart") and item.Name=="GuildborneSkillEffect" then distantCreated+=1 end
    end)
    table.insert(extraConnections,distantConnection)
    factory()(m);task.wait(.4);distantConnection:Disconnect()
    assert(distantCreated==0 and #parts==start,"Distant cast emitted geometry (or unrelated cast contaminated isolated probe)")
    m:Destroy();distantCenter=nil
    workspace:SetAttribute(config.QualityAttribute,"Low")
    start=#parts;m=actor();stamp=m:GetAttribute("ActionAt");factory()(m)
    at(stamp,.18);settleEvents()
    assert(workspace:GetServerTimeNow()-stamp<.29,"INCONCLUSIVE_STUDIO_STALL: missed compact travel observation")
    assert(#parts>start,"Low compact path disappeared")
    assert(tally(start).Charge==0,"Low path unexpectedly uses detailed charge")
    task.wait(1.5);emptyAfter(start);m:Destroy()
    return {status="PASS_LOCAL_ACTUAL_FIREBALL_PRESENTATION",touch=touch,stages=final,duplicate=true,lateObservationSkipsTravel=true,cancellation=true,activeTravelImpactCancellation=true,fiveActorPrimaryParts=primary,ttl=true,
        listenerCountVerified=false,particleEmissionCountVerified=false,serverCombatTested=false,studioDevicePerformanceAccepted=false}
end,debug.traceback)
for _,m in ipairs(actors) do m:Destroy() end
connection:Disconnect()
for _,extra in ipairs(extraConnections) do extra:Disconnect() end
for _,part in ipairs(parts) do part:Destroy() end
workspace:SetAttribute(config.QualityAttribute,oldQuality)
camera.CameraType=oldType;camera.CFrame=oldFrame;camera.Focus=oldFocus
assert(ok,result);return result
