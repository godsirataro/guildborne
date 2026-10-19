-- Execute once in the isolated CLIENT after Play. No cue stimulus is sent.
local Run = game:GetService("RunService")
local Players = game:GetService("Players")
assert(Run:IsStudio() and Run:IsClient() and game.PlaceId == 0 and game.GameId == 0)
local player = assert(Players.LocalPlayer)
local scripts = assert(player:FindFirstChild("PlayerScripts"))
local probe = assert(scripts:FindFirstChild("CombatCueProbe"))
assert(probe:IsA("LocalScript") and probe.Disabled, "Fresh disabled probe required")
assert(probe:GetAttribute("ProbeStatus") == nil and probe:GetAttribute("StartRequested") == nil)
assert(workspace:FindFirstChild("ProbeSpawnFloor") and workspace:FindFirstChild("ProbeSpawn"))
local runtime = require(game.ReplicatedStorage.CombatCueProbeClient.Runtime)
assert(runtime.StudioPersistence == "Memory" and next(runtime.AllowedDataStoreUniverses) == nil)
local report = { status = "INCONCLUSIVE", events = {}, samples = 0, maxGap = 0 }
local started = os.clock()
local previous = started
local stableSince = nil
local stableCharacter, stableCamera = nil, nil
local lastReason = nil
while os.clock() - started < 30 do
    Run.Heartbeat:Wait()
    local current = os.clock()
    local gap = current - previous
    previous = current
    report.samples += 1
    report.maxGap = math.max(report.maxGap, gap)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    local reason = "stable"
    if not character or not humanoid or not root or humanoid.Health <= 0 then reason = "character-not-live"
    elseif not scripts:FindFirstChild("PlayerModule") then reason = "player-module-missing"
    elseif not camera or camera.CameraType ~= Enum.CameraType.Custom or camera.CameraSubject ~= humanoid then reason = "default-camera-not-ready"
    elseif humanoid.FloorMaterial == Enum.Material.Air or root.AssemblyLinearVelocity.Magnitude > 1 then reason = "character-not-grounded"
    elseif math.abs(root.Position.X) > 25 or math.abs(root.Position.Z) > 25 or root.Position.Y < 1 or root.Position.Y > 12 then reason = "outside-spawn-floor"
    elseif gap > .15 then reason = "heartbeat-gap" end
    if reason ~= lastReason and #report.events < 128 then
        table.insert(report.events, { elapsed = current - started, reason = reason,
            rootY = root and root.Position.Y, health = humanoid and humanoid.Health,
            cameraType = camera and camera.CameraType.Name })
        lastReason = reason
    end
    if reason ~= "stable" or character ~= stableCharacter or camera ~= stableCamera then
        stableSince = nil
        stableCharacter, stableCamera = character, camera
    elseif not stableSince then stableSince = current end
    if stableSince and current - stableSince >= 2 then
        assert(probe.Disabled and probe:GetAttribute("ProbeStatus") == nil)
        report.status = "PROBE_ENABLED_ONCE"
        report.stableSeconds = current - stableSince
        report.elapsed = current - started
        report.enabledAt = workspace:GetServerTimeNow()
        report.rootPosition = tostring(root.Position)
        report.cameraType = camera.CameraType.Name
        probe.Disabled = false
        return report
    end
end
report.elapsed = os.clock() - started
report.reason = "No consecutive two-second stable client window; stop Play"
return report
