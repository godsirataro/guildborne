--!strict
-- Client-only, unpublished inspection adapter. Never required by the live renderer.
-- The real actor retains its body, joints, collision, equipment and combat identity.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Preview = require(script.Parent.LocalGeometryPreview)
local LegacyCosmetics = require(script.Parent.LocalLegacyCosmetics)
local WeaponPresentation = require(script.Parent.LocalWeaponPresentation)
local ActionRetarget = require(script.Parent.LocalActionRetarget)
local Adapter = {}

type Joint = { motor: Motor6D, bind: CFrame, basis: CFrame }
type Handle = {
	Model: Model,
	Destroy: (self: Handle) -> (),
	GetDiagnostics: (self: Handle) -> any,
	GetWeaponModel: (self: Handle) -> Model?,
}
local active: {[Model]: Handle} = {}
local pending: {[Model]: {}} = {}

function Adapter.IsAvailable(): boolean
	return RunService:IsStudio() and RunService:IsClient()
		and game.PlaceId == 0 and game.GameId == 0
end

function Adapter.Detach(actor: Model)
	pending[actor] = nil -- Also cancels an in-flight, yielding EditableMesh build.
	local handle = active[actor]
	if handle then handle:Destroy() end
end

function Adapter.Get(actor: Model): Handle?
	return active[actor]
end

function Adapter.Count(): number
	local count = 0
	for _ in pairs(active) do count += 1 end
	return count
end

local function actorParts(actor: Model): (BasePart?, Humanoid?)
	if not actor:IsDescendantOf(workspace) then return nil, nil end
	local root = actor:FindFirstChild("HumanoidRootPart")
	local humanoid = actor:FindFirstChildOfClass("Humanoid")
	if not root or not root:IsA("BasePart") or not humanoid then return nil, nil end
	return root, humanoid
end

local function snapshotSelection(selection: any): any
	local result = {}
	for key, value in pairs(selection) do
		if type(value) == "table" then
			local copied = {}
			for nestedKey, nestedValue in pairs(value) do copied[nestedKey] = nestedValue end
			result[key] = copied
		else result[key] = value end
	end
	return result
end

function Adapter.Attach(actor: Model, selection: any, options: any?): (Handle?, string?)
	if not Adapter.IsAvailable() then return nil, "LOCAL_UNPUBLISHED_CLIENT_STUDIO_ONLY" end
	if options ~= nil and (type(options) ~= "table" or (options.actionPose ~= nil and type(options.actionPose) ~= "function")) then
		return nil,"LOCAL_ACTION_POSE_CALLBACK_REQUIRED"
	end
	-- The caller supplies the existing trusted client ActionPose; no shared-to-client require.
	local actionPose = if options then options.actionPose else nil
	if typeof(actor) ~= "Instance" or not actor:IsA("Model") then return nil, "ACTOR_MODEL_REQUIRED" end
	if type(selection) ~= "table" or selection.raceId ~= "HUMAN"
		or selection.bodyPresetId ~= "HUMAN_STANDARD" then
		return nil, "LOCAL_HUMAN_STANDARD_SLICE_ONLY"
	end
	local root, humanoid = actorParts(actor)
	if not root or not humanoid or humanoid.Health <= 0 then return nil, "LIVE_ACTOR_REQUIRED" end
	local player = Players:GetPlayerFromCharacter(actor)
	Adapter.Detach(actor)
	local ticket = {}
	pending[actor] = ticket
	local model, buildError = Preview.BuildRig(snapshotSelection(selection))
	local currentRoot, currentHumanoid = actorParts(actor)
	if pending[actor] ~= ticket or not Adapter.IsAvailable()
		or (player ~= nil and player.Character ~= actor)
		or currentRoot ~= root or currentHumanoid ~= humanoid or humanoid.Health <= 0 then
		if model then Preview.Destroy(model) end
		if pending[actor] == ticket then pending[actor] = nil end
		return nil, "ATTACH_CANCELLED_OR_ACTOR_REPLACED"
	end
	pending[actor] = nil
	if not model then return nil, buildError end

	local visualRoot = model.PrimaryPart
	if not visualRoot then Preview.Destroy(model); return nil, "PREVIEW_ROOT_MISSING" end
	local joints: {[string]: Joint} = {}
	local cosmetics: any = nil
	local weapon: any = nil
	local action: any = nil
	local connections: {RBXScriptConnection} = {}
	local destroyed = false
	local lastError: string? = nil
	local phase, speed, frames, distance = 0, 0, 0, 0
	local previousPosition = root.Position
	local handle = {} :: Handle
	handle.Model = model

	function handle:Destroy()
		if destroyed then return end
		destroyed = true
		if active[actor] == self then active[actor] = nil end
		for _, connection in ipairs(connections) do connection:Disconnect() end
		table.clear(connections)
		if action then action:Destroy() end
		if weapon then weapon:Destroy() end
		if cosmetics then cosmetics:Destroy() end
		Preview.Destroy(model :: Model)
	end
	function handle:GetDiagnostics(): any
		return {
			localTestOnly=true, destroyed=destroyed, frames=frames,
			observedHorizontalDistance=distance, smoothedSpeed=speed,
			phase=phase, retainedMeshes=Preview.ResourceCount(model),
			lastError=lastError,
			cosmetics=if cosmetics then cosmetics:GetDiagnostics() else nil,
			weapon=if weapon then weapon:GetDiagnostics() else nil,
			action=if action then action:GetDiagnostics() else nil,
			connections=#connections,
			clothingFitAccepted=false, combatRetargetAccepted=false,
		}
	end
	function handle:GetWeaponModel(): Model?
		return if weapon then weapon:GetModel() else nil
	end

	-- Source bind frames can have different axes for every joint. Conjugation
	-- converts a desired parent-part-local bend into that source joint's axes.
	local function bend(name: string, angle: number)
		local joint = joints[name]
		if joint then
			local rotation = joint.basis:Inverse() * CFrame.Angles(angle, 0, 0) * joint.basis
			joint.motor.C0 = joint.bind * rotation
		end
	end
	local function hideBody()
		local success, err = cosmetics:Sync()
		assert(success,err)
	end
	local function guarded(callback: () -> ())
		if destroyed then return end
		local success, err = pcall(function() callback(); return true end)
		if not success then
			lastError = tostring(err)
			handle:Destroy()
		end
	end
	local ok, setupError = pcall(function()
		local footLow = math.huge
		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Massless = true
				descendant.CanCollide = false
				descendant.CanTouch = false
				descendant.CanQuery = false
				descendant.Anchored = descendant == visualRoot
				if descendant:GetAttribute("CoreBodyPart") == true
					and (descendant.Name == "LeftFoot" or descendant.Name == "RightFoot") then
					footLow = math.min(footLow, descendant.Position.Y - descendant.Size.Y / 2)
				end
			elseif descendant:IsA("Motor6D") then
				assert(descendant:GetAttribute("SourceDerived") == true, "SOURCE_JOINT_REQUIRED")
				joints[descendant.Name] = {
					motor=descendant, bind=descendant.C0, basis=descendant.C0.Rotation,
				}
			end
		end
		assert(footLow < math.huge and joints.LeftElbow and joints.RightElbow
			and joints.LeftKnee and joints.RightKnee, "ARTICULATED_FEET_AND_LIMBS_REQUIRED")
		local sourceRootHeight = visualRoot.Position.Y - footLow
		local actorRootHeight = root.Size.Y / 2 + humanoid.HipHeight
		if humanoid.RigType == Enum.HumanoidRigType.R6 then
			local leg = actor:FindFirstChild("Left Leg")
			assert(leg and leg:IsA("BasePart"), "R6_GROUND_REFERENCE_REQUIRED")
			actorRootHeight += leg.Size.Y
		end
		local offset = CFrame.new(0, sourceRootHeight - actorRootHeight, 0)
		model.Name = "LocalActorAppearanceInspection"
		model:SetAttribute("LOCAL_TEST_ONLY", true)
		model:SetAttribute("ActorKind", if player then "PLAYER" else "HERO_OR_LOCAL_FIXTURE")
		model:SetAttribute("MotionStatus", "LOCAL_ROOT_MOTION_COSMETIC_PREVIEW")
		model:SetAttribute("ClothingFitAccepted", false)
		model:SetAttribute("CombatRetargetAccepted", false)
		model:SetAttribute("PreservesOriginalEquipment", true)
		model:SetAttribute("GroundOffsetY", offset.Y)
		-- Independent anchored assembly: never weld decorative physics into actor.
		model:PivotTo(root.CFrame * offset)
		model.Parent = workspace
		active[actor] = handle
		local cosmeticState, cosmeticError = LegacyCosmetics.New(actor)
		assert(cosmeticState,cosmeticError)
		cosmetics = cosmeticState
		local weaponState, weaponError = WeaponPresentation.New(actor,model)
		assert(weaponState,weaponError)
		weapon = weaponState
		if actionPose then
			local actionState = ActionRetarget.New(actor,joints,actionPose)
			assert(actionState,"LOCAL_ACTION_STATE_REQUIRED")
			action = actionState
		end
		hideBody()
		table.insert(connections, actor.Destroying:Connect(function() handle:Destroy() end))
		table.insert(connections, actor.AncestryChanged:Connect(function()
			if not actor:IsDescendantOf(workspace) then handle:Destroy() end
		end))
		table.insert(connections, actor.ChildRemoved:Connect(function(child)
			if child == root or child == humanoid then handle:Destroy() end
		end))
		table.insert(connections, humanoid.Died:Connect(function() handle:Destroy() end))
		if player then
			table.insert(connections, player.CharacterRemoving:Connect(function(character: Model)
				if character == actor then handle:Destroy() end
			end))
			table.insert(connections, player.CharacterAdded:Connect(function(character: Model)
				if character ~= actor then handle:Destroy() end
			end))
		end
		table.insert(connections, model.Destroying:Connect(function() handle:Destroy() end))
		table.insert(connections, model.DescendantRemoving:Connect(function(descendant)
			if descendant == visualRoot or descendant:IsA("Motor6D") then handle:Destroy() end
		end))
		table.insert(connections, model.AncestryChanged:Connect(function()
			if not model:IsDescendantOf(workspace) then handle:Destroy() end
		end))
		table.insert(connections, RunService.PreSimulation:Connect(function(dt)
			guarded(function()
			if not Adapter.IsAvailable() or (player ~= nil and player.Character ~= actor) then
				handle:Destroy(); return
			end
			assert(visualRoot.Parent == model and root.Parent == actor
				and humanoid.Parent == actor and model:IsDescendantOf(workspace), "PREVIEW_OR_ACTOR_REMOVED")
			for _, joint in pairs(joints) do
				assert(joint.motor:IsDescendantOf(model) and joint.motor.Part0 and joint.motor.Part1
					and joint.motor.Part0:IsDescendantOf(model)
					and joint.motor.Part1:IsDescendantOf(model), "PREVIEW_JOINT_REMOVED")
				-- Full reset prevents action translation/rotation accumulating across frames.
				joint.motor.C0 = joint.bind
			end
			local delta = root.Position - previousPosition
			previousPosition = root.Position
			local flat = Vector3.new(delta.X, 0, delta.Z)
			local measured = if dt > 0 and dt <= .25 then flat.Magnitude / dt else 0
			-- Teleports, resumed frames and severe position corrections are not steps.
			if measured > 32 or flat.Magnitude > 8 then measured = 0 end
			if measured < .15 then measured = 0 end
			local boundedDt = math.clamp(dt, 0, .1)
			speed += (measured - speed) * (1 - math.exp(-12 * boundedDt))
			phase = (phase + math.min(speed, 18) * boundedDt * math.pi / 2.4) % (2 * math.pi)
			local weight = math.clamp(speed / 8, 0, 1)
			local stride = math.sin(phase)
			local direction = if flat:Dot(root.CFrame.LookVector) < 0 then -1 else 1
			bend("LeftHip", stride * .48 * weight * direction)
			bend("RightHip", -stride * .48 * weight * direction)
			bend("LeftKnee", math.max(0, -stride) * .62 * weight)
			bend("RightKnee", math.max(0, stride) * .62 * weight)
			bend("LeftShoulder", -stride * .28 * weight * direction)
			bend("RightShoulder", stride * .28 * weight * direction)
			bend("LeftElbow", (.12 + math.max(0, stride) * .16) * weight)
			bend("RightElbow", (.12 + math.max(0, -stride) * .16) * weight)
			bend("LeftAnkle", -math.max(0, -stride) * .15 * weight)
			bend("RightAnkle", -math.max(0, stride) * .15 * weight)
			if action then action:Step(workspace:GetServerTimeNow()) end
			visualRoot.CFrame = root.CFrame * offset
			frames += 1
			if measured > 0 then distance += flat.Magnitude end
			end)
		end))
		-- Read the evaluated source assembly after simulation, not the prior frame's joints.
		table.insert(connections, RunService.PostSimulation:Connect(function()
			guarded(function()
				local success, err = weapon:Sync()
				assert(success,err)
			end)
		end))
		-- The default camera may rewrite local body transparency each frame.
		-- Follow evaluated source joints, then hide only a successfully copied weapon.
		-- Authoritative equipment identity/physics remain untouched; LTM is restored on exit.
		table.insert(connections, RunService.RenderStepped:Connect(function()
			guarded(function()
				hideBody()
				local success, err = weapon:Sync()
				assert(success,err)
			end)
		end))
	end)
	if not ok then handle:Destroy(); return nil, "LOCAL_ACTOR_ATTACH_FAILED:" .. tostring(setupError) end
	return handle, nil
end

return Adapter
