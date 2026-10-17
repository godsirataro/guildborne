-- LOCAL CLIENT probe: run after the full-game bootstrap creates NoviceTrialHUD.
-- Use an isolated unsaved Studio play session with no active solo arena/input.
-- Runs the existing controller; never requires its factory or invokes remotes.
-- Synthetic presentation attributes only: no combat, reward or earned-progress proof.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId == 0 and game.GameId == 0, "Unsaved local Studio required")
local player = assert(game:GetService("Players").LocalPlayer, "Run on the CLIENT")
local playerGui = player:WaitForChild("PlayerGui")
local function hudCount()
    local count = 0
    for _, child in ipairs(playerGui:GetChildren()) do
        if child.Name == "NoviceTrialHUD" and child:IsA("ScreenGui") then count += 1 end
    end
    return count
end
assert(hudCount() == 1, "Bootstrap exactly one real NoviceTrialController before running")
local names = {"NoviceTrial_" .. player.UserId, "ArchiveEncounter_" .. player.UserId}
for _, name in ipairs(names) do assert(not workspace:FindFirstChild(name), "Refuse to replace an existing arena: " .. name) end
assert(not workspace:FindFirstChild("NoviceTrialCastVisual"), "Refuse existing presentation proxy")
local camera = assert(workspace.CurrentCamera)
local oldType, oldFrame, oldFocus, oldSubject = camera.CameraType, camera.CFrame, camera.Focus, camera.CameraSubject
local quality = require(game.ReplicatedStorage.Shared.Config.VFXConfig).QualityAttribute
local oldQuality = workspace:GetAttribute(quality)
local oldHUDActive = player:GetAttribute("NoviceTrialHUDActive")
local fixtures, proxies, spawned, connections = {}, {}, {}, {}
local origin = (oldFrame + Vector3.new(0, 150, 0)):PointToWorldSpace(Vector3.new(0, 0, -12))
local target = origin + oldFrame.LookVector * 5
local function waitFor(predicate, label, timeout)
    local deadline = os.clock() + (timeout or 1)
    repeat
        if predicate() then return end
        task.wait()
    until os.clock() >= deadline
    error("Timed out: " .. label)
end
local function findProxy()
    local found, count = nil, 0
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name == "NoviceTrialCastVisual" and child:IsA("Model") and child:GetAttribute("OwnerUserId") == player.UserId then
            found = child; count += 1
        end
    end
    assert(count <= 1, "Duplicate owned presentation proxy")
    return found
end
table.insert(connections, workspace.DescendantAdded:Connect(function(child)
    if child:IsA("BasePart") and child.Name == "GuildborneSkillEffect" and (child.Position - origin).Magnitude < 30 then
        table.insert(spawned, child)
    end
end))
local ok, outcome = xpcall(function()
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = oldFrame + Vector3.new(0, 150, 0)
    camera.Focus = CFrame.new(origin)
    workspace:SetAttribute(quality, "High")
    local summaries = {}
    for index, name in ipairs(names) do
        assert(not workspace:FindFirstChild(name), "Arena appeared during probe; refusing overwrite")
        local arena = Instance.new("Model"); arena.Name = name
        arena:SetAttribute(if index == 1 then "NoviceTrialArena" else "ArchiveHeartArena", true)
        arena:SetAttribute("OwnerUserId", player.UserId); arena:SetAttribute("TrialStatus", "Active")
        arena:SetAttribute("ClassId", "Mage"); arena:SetAttribute("ActionEffect", "Magic"); arena:SetAttribute("ActionAbilityId", "fireball")
        arena:SetAttribute("ActionOriginPosition", origin); arena:SetAttribute("ActionTargetPosition", target)
        table.insert(fixtures, arena); arena.Parent = workspace
        waitFor(function() return findProxy() ~= nil end, "existing controller creates proxy")
        local proxy = assert(findProxy()); table.insert(proxies, proxy)
        assert(proxy:GetAttribute("ActionAt") == nil, "New arena inherited old action")
        local forwards = 0
        table.insert(connections, proxy:GetAttributeChangedSignal("ActionAt"):Connect(function()
            if proxy:GetAttribute("ActionAt") ~= nil then forwards += 1 end
        end))
        local stamp = workspace:GetServerTimeNow()
        local before = #spawned
        arena:SetAttribute("ActionAt", stamp)
        waitFor(function() return proxy:GetAttribute("ActionAt") == stamp end, "accepted ActionAt forwarded")
        waitFor(function() return #spawned > before end, "accepted Mage creates actual VFX")
        task.wait(1)
        local observed = #spawned
        arena:SetAttribute("ActionAt", stamp)
        task.wait(.22)
        assert(forwards == 1 and #spawned == observed, "Duplicate action replayed")
        for _, invalid in ipairs({"invalid", stamp - 10, workspace:GetServerTimeNow() + 30}) do
            arena:SetAttribute("ActionAt", invalid); task.wait(.16)
            assert(proxy:GetAttribute("ActionAt") == stamp and forwards == 1 and #spawned == observed, "Invalid/stale/future stamp forwarded")
        end
        -- Missing positional metadata must not consume a valid timestamp.
        arena:SetAttribute("ActionTargetPosition", nil)
        local delayed = workspace:GetServerTimeNow()
        arena:SetAttribute("ActionAt", delayed); task.wait(.13)
        assert(proxy:GetAttribute("ActionAt") == stamp and forwards == 1, "Incomplete action forwarded")
        arena:SetAttribute("ActionTargetPosition", target)
        waitFor(function() return proxy:GetAttribute("ActionAt") == delayed end, "same stamp retried after position arrives", .4)
        assert(forwards == 2, "Deferred action forwarding count")
        task.wait(1)
        arena:SetAttribute("ActionAt", nil)
        waitFor(function() return proxy:GetAttribute("ActionAt") == nil end, "explicit nil clears proxy action")
        assert(forwards == 2, "Explicit cancellation counted as a cast")
        -- Exercise nil cancellation while a real fresh Mage cast is still live.
        before = #spawned
        local cancelledStamp = workspace:GetServerTimeNow()
        arena:SetAttribute("ActionAt", cancelledStamp)
        waitFor(function() return proxy:GetAttribute("ActionAt") == cancelledStamp and #spawned > before end, "fresh nil-cancellation cast")
        assert(#spawned - before >= 5, "INCONCLUSIVE_DETAIL_FALLBACK: nil probe requires detailed Mage seal")
        arena:SetAttribute("ActionAt", nil)
        waitFor(function() return proxy:GetAttribute("ActionAt") == nil end, "live action nil cancellation", .4)
        -- Cancellation begins when the .1s controller observes nil, not when the
        -- fixture writes it. Cues before that observation are not failures.
        local atCancel = #spawned
        assert(workspace:GetServerTimeNow() - cancelledStamp < .25, "INCONCLUSIVE_STUDIO_STALL: nil observed too late to prove pending .3s Mage cue cancellation")
        arena:SetAttribute("ActionAt", cancelledStamp)
        task.wait(.45)
        assert(proxy:GetAttribute("ActionAt") == nil and forwards == 3, "Cancelled timestamp replayed on re-observation")
        assert(#spawned == atCancel, "Delayed effect survived nil cancellation or replay")
        task.wait(.6)
        -- Fresh cast then removal: observe immediate cues before removing arena;
        -- delayed Mage cues must be cancelled when the real controller clears it.
        before = #spawned
        local finalStamp = workspace:GetServerTimeNow()
        arena:SetAttribute("ActionAt", finalStamp)
        waitFor(function() return proxy:GetAttribute("ActionAt") == finalStamp and #spawned > before end, "fresh cancellation cast")
        assert(#spawned - before >= 5, "INCONCLUSIVE_DETAIL_FALLBACK: removal probe requires detailed Mage seal")
        arena:Destroy()
        waitFor(function() return proxy.Parent == nil and findProxy() == nil end, "arena removal destroys proxy", .5)
        assert(workspace:GetServerTimeNow() - finalStamp < .25, "INCONCLUSIVE_STUDIO_STALL: removal observed too late to prove pending .3s Mage cue cancellation")
        local atRemoval = #spawned -- same observation boundary as nil cancellation
        task.wait(.6)
        assert(#spawned == atRemoval, "Delayed effect survived arena removal")
        waitFor(function()
            for _, effect in ipairs(spawned) do if effect.Parent then return false end end
            return true
        end, "effect bounded lifetime", 1.5)
        assert(hudCount() == 1, "Probe duplicated/destroyed bootstrap HUD")
        table.insert(summaries, {arena=name, forwarded=forwards, actualVFX=true, delayedMetadata=true, nilCancelled=true, removalCancelled=true})
    end
    return {status="PASS_LOCAL_EXISTING_NOVICE_CONTROLLER", arenas=summaries, serverCombatTested=false, rewardsTested=false}
end, debug.traceback)
-- Always restore local scene settings and destroy only instances this probe owns.
for _, fixture in ipairs(fixtures) do fixture:Destroy() end
task.wait(.2)
for _, connection in ipairs(connections) do connection:Disconnect() end
for _, proxy in ipairs(proxies) do proxy:Destroy() end
for _, effect in ipairs(spawned) do effect:Destroy() end
workspace:SetAttribute(quality, oldQuality)
camera.CameraType = oldType; camera.CFrame = oldFrame; camera.Focus = oldFocus; camera.CameraSubject = oldSubject
player:SetAttribute("NoviceTrialHUDActive", oldHUDActive)
assert(ok, outcome)
return outcome
