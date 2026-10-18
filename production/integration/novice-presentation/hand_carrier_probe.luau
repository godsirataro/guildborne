-- LOCAL CLIENT, unsaved isolated Studio, after normal bootstrap (one existing HUD).
-- Synthetic arena attributes only; no remotes, character writes, pose edits or teleport.
-- Controller must run this; compilation alone is NOT_RUN. Keep player input idle.
-- Previous PreRender:Wait sampling failed twice (~.229stud/.222rad); ordering was
-- not guaranteed. This revision samples after a deferred end-of-resumption barrier.
-- Controller reported original-production diagnostic PASS; this revised probe itself
-- remains NOT_RUN until executed. No production metadata or priority changes required.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0,"Local unsaved Studio required")
local player=assert(game.Players.LocalPlayer,"Run on CLIENT")
local character=assert(player.Character,"Real character required")
local hand=character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
assert(hand and hand:IsA("BasePart"),"Real R15 RightHand or R6 Right Arm required")
local root=assert(character:FindFirstChild("HumanoidRootPart"))
assert(root:IsA("BasePart"))
local initialRoot=root.CFrame
local characterAttributes={}
local attributeNames={"ActionAt","ClassId","CombatHealth"}
for _,name in ipairs(attributeNames) do characterAttributes[name]=character:GetAttribute(name) end
local gui=player:WaitForChild("PlayerGui")
local hudCount=0
for _,child in ipairs(gui:GetChildren()) do if child.Name=="NoviceTrialHUD" then hudCount+=1 end end
assert(hudCount==1,"Exactly one bootstrapped NoviceTrialController required")
for _,prefix in ipairs({"NoviceTrial_","ArchiveEncounter_"}) do assert(not workspace:FindFirstChild(prefix..player.UserId),"Refuse active real arena") end
assert(not workspace:FindFirstChild("NoviceTrialCastVisual"),"Refuse existing cast proxy")
local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local camera=assert(workspace.CurrentCamera)
assert((camera.CFrame.Position-hand.Position).Magnitude<config.Distance.Detail-5,"INCONCLUSIVE_CAMERA_DISTANCE: hand must be within detailed VFX distance")
local oldQuality=workspace:GetAttribute(config.QualityAttribute)
local oldHUDActive=player:GetAttribute("NoviceTrialHUDActive")
local originalDescendants={}
for _,child in ipairs(character:GetDescendants()) do originalDescendants[child]=true end
local initialHand=hand.CFrame
local motionObserved=false
local maxPositionError,maxRotationError=0,0
local maxPrePositionError,maxPreRotationError=0,0
local Run=game:GetService("RunService")
local callbackError:string?=nil
local active:any=nil
local collections={}
local frameSequence=0
local completion:BindableEvent?=nil
local simulationEpoch=0
local epochConnection:RBXScriptConnection?=nil
local arena:Model?=nil
local proxies={}
local function waitFor(predicate,label,timeout)
    local untilTime=os.clock()+(timeout or 1)
    repeat
        assert(not callbackError,callbackError)
        if predicate() then return end
        task.wait()
    until os.clock()>untilTime
    assert(not callbackError,callbackError)
    error(label)
end
local function proxy()
    local p=workspace:FindFirstChild("NoviceTrialCastVisual")
    return if p and p:IsA("Model") and p:GetAttribute("OwnerUserId")==player.UserId then p else nil
end
local function sameCharacter()
    assert(player.Character==character and hand:IsDescendantOf(character),"INCONCLUSIVE_REAL_CHARACTER_CHANGED")
    local delta=initialRoot:ToObjectSpace(root.CFrame)
    local _,rotation=delta:ToAxisAngle()
    assert(delta.Position.Magnitude<=.05 and math.abs(rotation)<=.03,"INCONCLUSIVE_REAL_ROOT_MOVED: ordinary movement/physics invalidated stationary probe")
    for _,name in ipairs(attributeNames) do
        assert(character:GetAttribute(name)==characterAttributes[name],"Actual character attribute changed during isolated probe: "..name)
    end
end
local function snapshot(carrier)
    local handFrame,carrierFrame=hand.CFrame,carrier.CFrame
    local delta=handFrame:ToObjectSpace(carrierFrame)
    local _,angle=delta:ToAxisAngle()
    local change=initialHand:ToObjectSpace(handFrame)
    local _,rotation=change:ToAxisAngle()
    motionObserved=motionObserved or change.Position.Magnitude>.001 or math.abs(rotation)>.001
    return {sequence=frameSequence,simulationEpoch=simulationEpoch,serverTime=workspace:GetServerTimeNow(),positionErrorStud=delta.Position.Magnitude,
        rotationErrorRadians=math.abs(angle),handCFrame={handFrame:GetComponents()},carrierCFrame={carrierFrame:GetComponents()}}
end
local function sample(carrier)
    sameCharacter()
    assert(active and active.carrier==carrier,"No active collector for carrier")
    local collection=active
    while #collection.samples<3 do
        assert(#collection.samples<120,"Render sample budget exceeded")
        Run.PreRender:Wait()
        frameSequence+=1
        local before=snapshot(carrier)
        assert(before.serverTime-collection.stamp>=.10 and before.serverTime-collection.stamp<=.30,
            "INCONCLUSIVE_RENDER_WINDOW: need three paired samples within .10-.30s")
        local event=Instance.new("BindableEvent");completion=event
        task.defer(function()
            local success,problem=xpcall(function()
                sameCharacter()
                assert(active==collection and carrier.Parent and carrier.Parent:GetAttribute("ActionAt")==collection.stamp,"INCONCLUSIVE_SAMPLE_IDENTITY_CHANGED")
                local after=snapshot(carrier)
                assert(before.simulationEpoch==after.simulationEpoch,"INCONCLUSIVE_SIMULATION_ADVANCED: deferred pair crossed a simulation step")
                assert(after.serverTime-collection.stamp<=.30,"INCONCLUSIVE_RENDER_WINDOW: deferred sample exceeded .30s")
                local previous=collection.samples[#collection.samples]
                if previous then
                    local priorFrame=CFrame.new(table.unpack(previous.after.handCFrame))
                    local currentFrame=CFrame.new(table.unpack(after.handCFrame))
                    local movement=priorFrame:ToObjectSpace(currentFrame)
                    local _,rotation=movement:ToAxisAngle()
                    collection.sampledMotion=collection.sampledMotion or movement.Position.Magnitude>.001 or math.abs(rotation)>.001
                end
                table.insert(collection.samples,{before=before,after=after})
                maxPrePositionError=math.max(maxPrePositionError,before.positionErrorStud)
                maxPreRotationError=math.max(maxPreRotationError,before.rotationErrorRadians)
                maxPositionError=math.max(maxPositionError,after.positionErrorStud)
                maxRotationError=math.max(maxRotationError,after.rotationErrorRadians)
                assert(after.positionErrorStud<.03 and after.rotationErrorRadians<.03,string.format(
                    "Carrier deferred mismatch epoch=%d time=%.6f age=%.6f pre=%.6fstud/%.6frad post=%.6fstud/%.6frad",
                    after.simulationEpoch,after.serverTime,after.serverTime-collection.stamp,before.positionErrorStud,before.rotationErrorRadians,after.positionErrorStud,after.rotationErrorRadians))
            end,debug.traceback)
            if not success then callbackError=tostring(problem) end
            event:Fire() -- completion is signaled on both success and failure
        end)
        event.Event:Wait();event:Destroy();completion=nil
        assert(not callbackError,callbackError)
    end
    assert(collection.sampledMotion,"INCONCLUSIVE_NO_HAND_MOTION: no movement between the three deferred hand samples")
end
local function fresh(effect)
    sameCharacter()
    assert(arena)
    arena:SetAttribute("ActionEffect",effect)
    arena:SetAttribute("ActionAbilityId",if effect=="Physical" then "power_strike" else nil)
    arena:SetAttribute("ActionOriginPosition",root.Position)
    arena:SetAttribute("ActionTargetPosition",root.Position+root.CFrame.LookVector*5)
    local stamp=workspace:GetServerTimeNow();arena:SetAttribute("ActionAt",stamp)
    local p=assert(proxy())
    waitFor(function() return p:GetAttribute("ActionAt")==stamp and p:FindFirstChild("RightHand")~=nil end,"No accepted hand carrier",.5)
    local carrier=assert(p:FindFirstChild("RightHand"))
    assert(carrier:IsA("BasePart") and carrier.Parent==p and carrier~=hand,"Carrier must be proxy-owned")
    assert(carrier.Anchored and not carrier.CanCollide and not carrier.CanQuery and not carrier.CanTouch and carrier.Transparency==1,"Carrier physical/invisibility contract")
    active={carrier=carrier,stamp=stamp,effect=effect,samples={}}
    table.insert(collections,active)
    return p,carrier,stamp
end
local function observeTrail(carrier,stamp)
    waitFor(function() return carrier:FindFirstChildWhichIsA("Trail")~=nil end,"INCONCLUSIVE_RELEASE_MISSED: no real SkillEffects trail",.3)
    assert(workspace:GetServerTimeNow()-stamp<.35,"INCONCLUSIVE_STUDIO_STALL: trail observed too late")
    local trail=assert(carrier:FindFirstChildWhichIsA("Trail"))
    assert(trail.Attachment0 and trail.Attachment1 and trail.Attachment0.Parent==carrier and trail.Attachment1.Parent==carrier,"Trail attachments escaped carrier")
    for _,child in ipairs(character:GetDescendants()) do
        assert(originalDescendants[child] or not (child:IsA("Trail") or child:IsA("Attachment")),"Probe presentation added attachment/trail to actual character")
    end
end
local ok,outcome=xpcall(function()
    epochConnection=Run.PostSimulation:Connect(function() simulationEpoch+=1 end)
    workspace:SetAttribute(config.QualityAttribute,"High")
    arena=Instance.new("Model");arena.Name="NoviceTrial_"..player.UserId
    arena:SetAttribute("NoviceTrialArena",true);arena:SetAttribute("OwnerUserId",player.UserId)
    arena:SetAttribute("TrialStatus","Active");arena:SetAttribute("ClassId","Warrior");arena.Parent=workspace
    waitFor(function() return proxy()~=nil end,"Existing controller did not create proxy")
    table.insert(proxies,assert(proxy()))
    for _,mode in ipairs({"nil","replace","ttl","basic","remove"}) do
        local p,carrier,stamp=fresh(if mode=="basic" then "Basic" else "Physical")
        observeTrail(carrier,stamp)
        sample(carrier)
        arena:SetAttribute("ActionAt",stamp);task.wait()
        assert(p:FindFirstChild("RightHand")==carrier,"Duplicate recreated carrier")
        if mode=="nil" then
            arena:SetAttribute("ActionAt",nil)
            waitFor(function() return carrier.Parent==nil end,"Nil cancellation retained carrier",.4)
        elseif mode=="replace" then
            -- Invalidate the active cast; a future stamp must not become a new cast.
            arena:SetAttribute("ActionAt",stamp+30)
            waitFor(function() return carrier.Parent==nil end,"Replacement retained prior carrier",.4)
        elseif mode=="ttl" or mode=="basic" then
            waitFor(function() return carrier.Parent==nil end,"Expired .62s action retained carrier",.8)
            assert(p:GetAttribute("ActionAt")==stamp,"Carrier expiry truncated proxy event")
        else
            arena:Destroy();arena=nil
            waitFor(function() return carrier.Parent==nil and p.Parent==nil end,"Arena removal retained carrier/proxy",.4)
        end
        assert(not carrier:FindFirstChildWhichIsA("Trail"),"Destroyed carrier retained trail")
        active=nil
        task.wait(.8) -- new casts must not enter shared detail fallback
    end
    assert(maxPositionError<.03 and maxRotationError<.03,"Hand-follow sample mismatch")
    sameCharacter()
    waitFor(function() return proxy()==nil end,"Owned proxy survived final arena cleanup",.4)
    for _,p in ipairs(proxies) do assert(not p:FindFirstChild("RightHand"),"Carrier survived final cleanup") end
    local diagnostics={};local pairedSamples=0
    for _,collection in ipairs(collections) do
        pairedSamples+=#collection.samples
        table.insert(diagnostics,{stamp=collection.stamp,effect=collection.effect,samples=collection.samples,count=#collection.samples,movementWithinSamples=collection.sampledMotion})
    end
    return {status="PASS_LOCAL_HAND_CARRIER",sampledHand=hand.Name,actualHandMovementObserved=motionObserved,
        maxPositionErrorStud=maxPositionError,maxRotationErrorRadians=maxRotationError,
        maxPrePositionErrorStud=maxPrePositionError,maxPreRotationErrorRadians=maxPreRotationError,
        samplingBarrier="PreRender.Wait + task.defer + BindableEvent",pairedSampleCount=pairedSamples,renderDiagnostics=diagnostics,
        physicalCastTested=true,basicCastTested=true,realDeathRespawnTested=false,otherRigTypeTested=false,
        serverCombatTested=false,characterMutatedByProbe=false,rootStationarityChecked=true,
        characterAttributesChecked=attributeNames,replicationTested=false,carrierExpiryPreservedEvent=true}
end,debug.traceback)
if completion then completion:Destroy() end
if epochConnection then epochConnection:Disconnect() end
if arena then arena:Destroy() end
task.wait(.2)
for _,p in ipairs(proxies) do p:Destroy() end
workspace:SetAttribute(config.QualityAttribute,oldQuality)
player:SetAttribute("NoviceTrialHUDActive",oldHUDActive)
assert(ok,outcome);return outcome
