-- LOCAL CLIENT, unsaved isolated Studio, after normal bootstrap (one existing HUD).
-- Synthetic arena attributes only; no remotes, character writes, pose edits or teleport.
-- Controller must run this; compilation alone is NOT_RUN. Keep player input idle.
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
local arena:Model?=nil
local proxies={}
local function waitFor(predicate,label,timeout)
    local untilTime=os.clock()+(timeout or 1)
    repeat if predicate() then return end;task.wait() until os.clock()>untilTime
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
local function sample(carrier)
    sameCharacter()
    -- Existing controller's PreRender connection precedes this probe observer.
    game:GetService("RunService").PreRender:Wait()
    local delta=hand.CFrame:ToObjectSpace(carrier.CFrame)
    local _,angle=delta:ToAxisAngle()
    maxPositionError=math.max(maxPositionError,delta.Position.Magnitude)
    maxRotationError=math.max(maxRotationError,math.abs(angle))
    assert(delta.Position.Magnitude<.03 and math.abs(angle)<.03,"Carrier did not follow sampled real hand")
    local change=initialHand:ToObjectSpace(hand.CFrame)
    local _,rotation=change:ToAxisAngle()
    motionObserved=motionObserved or change.Position.Magnitude>.001 or math.abs(rotation)>.001
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
    sample(carrier)
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
        task.wait(.8) -- new casts must not enter shared detail fallback
    end
    assert(maxPositionError<.03 and maxRotationError<.03,"Hand-follow sample mismatch")
    sameCharacter()
    waitFor(function() return proxy()==nil end,"Owned proxy survived final arena cleanup",.4)
    for _,p in ipairs(proxies) do assert(not p:FindFirstChild("RightHand"),"Carrier survived final cleanup") end
    return {status="PASS_LOCAL_HAND_CARRIER",sampledHand=hand.Name,actualHandMovementObserved=motionObserved,
        maxPositionErrorStud=maxPositionError,maxRotationErrorRadians=maxRotationError,
        physicalCastTested=true,basicCastTested=true,realDeathRespawnTested=false,otherRigTypeTested=false,
        serverCombatTested=false,characterMutatedByProbe=false,rootStationarityChecked=true,
        characterAttributesChecked=attributeNames,replicationTested=false,carrierExpiryPreservedEvent=true}
end,debug.traceback)
if arena then arena:Destroy() end
task.wait(.2)
for _,p in ipairs(proxies) do p:Destroy() end
workspace:SetAttribute(config.QualityAttribute,oldQuality)
player:SetAttribute("NoviceTrialHUDActive",oldHUDActive)
assert(ok,outcome);return outcome
