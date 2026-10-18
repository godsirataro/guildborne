--!strict
-- Read-only, one-actor portrait. Copies are sanitized while unparented.
local Players = game:GetService("Players")
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local LIMIT = 512

local function descendants(root: Instance, limit: number): {Instance}?
	local result: {Instance} = {}
	local pending = {root}
	while #pending > 0 do
		local current = table.remove(pending) :: Instance
		for _, child in ipairs(current:GetChildren()) do
			if #result >= limit then return nil end
			table.insert(result, child); table.insert(pending, child)
		end
	end
	return result
end

local function visual(instance: Instance): boolean
	-- Humanoid.Status inherits Model but is engine state, not visual geometry.
	-- It is non-archivable; treating every Model subclass as artwork rejects
	-- otherwise complete player characters before the snapshot can be built.
	return instance.ClassName == "Model" or instance:IsA("Folder") or instance:IsA("Accessory")
		or instance:IsA("BasePart") or instance:IsA("DataModelMesh")
		or instance:IsA("Decal") or instance:IsA("SurfaceAppearance")
		or instance:IsA("Attachment") or instance:IsA("Clothing")
		or instance:IsA("ShirtGraphic") or instance:IsA("BodyColors")
		or instance:IsA("Humanoid") or instance:IsA("WrapLayer") or instance:IsA("WrapTarget")
end

local function signature(source: Model): string?
	local nodes = descendants(source, LIMIT)
	if not nodes then return nil end
	local keys = {tostring(source:GetAttribute("WeaponId")), tostring(source:GetAttribute("AppearanceRevision"))}
	for _, node in ipairs(nodes) do
		if not visual(node) then continue end
		local key = node.ClassName .. ":" .. node.Name
		if node:IsA("BasePart") then
			key ..= tostring(node.Size) .. tostring(node.Color) .. tostring(node.Transparency) .. tostring(node.Material)
			if node:IsA("MeshPart") then key ..= node.MeshId .. node.TextureID end
		elseif node:IsA("SpecialMesh") then key ..= node.MeshId .. node.TextureId .. tostring(node.Scale)
		elseif node:IsA("Decal") then key ..= node.Texture .. tostring(node.Transparency)
		elseif node:IsA("Shirt") then key ..= node.ShirtTemplate
		elseif node:IsA("Pants") then key ..= node.PantsTemplate
		elseif node:IsA("ShirtGraphic") then key ..= node.Graphic
		elseif node:IsA("BodyColors") then
			key ..= tostring(node.HeadColor3) .. tostring(node.TorsoColor3) .. tostring(node.LeftArmColor3)
				.. tostring(node.RightArmColor3) .. tostring(node.LeftLegColor3) .. tostring(node.RightLegColor3)
		elseif node:IsA("SurfaceAppearance") then key ..= node.ColorMap .. node.NormalMap .. node.MetalnessMap .. node.RoughnessMap
		end
		table.insert(keys, key)
	end
	table.sort(keys)
	return table.concat(keys, "|")
end

local function snapshot(source: Model): Model?
	local sourceNodes = descendants(source, LIMIT)
	if not sourceNodes then return nil end
	-- Clone silently omits non-archivable descendants. Reject an incomplete
	-- visual instead of displaying a partially dressed/body-less actor.
	for _, node in ipairs(sourceNodes) do
		if visual(node) and not node.Archivable then return nil end
	end
	if source.Archivable then return source:Clone() end
	-- Player character roots normally disallow cloning. Reconstruct the root
	-- without changing the live Archivable flag; each visual branch is cleaned
	-- while detached before it is attached even to this unparented model.
	local model = Instance.new("Model")
	model.Name = "ActorSnapshot"
	model.WorldPivot = source:GetPivot()
	for _, child in ipairs(source:GetChildren()) do
		if not visual(child) then continue end
		local ok, branch = pcall(function() return child:Clone() end)
		if not ok or not branch then model:Destroy(); return nil end
		local nested = descendants(branch, LIMIT)
		if not nested then branch:Destroy(); model:Destroy(); return nil end
		for _, node in ipairs(nested) do
			if node:IsA("LuaSourceContainer") or not visual(node) then node:Destroy() end
		end
		branch.Parent = model
		if child == source.PrimaryPart and branch:IsA("BasePart") then model.PrimaryPart = branch end
	end
	return model
end

return function(parent: Instance, options: any)
	local frame = Instance.new("Frame")
	frame.Name = "InventoryActorPreview"; frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1; frame.ClipsDescendants = true; frame.Parent = parent
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "ActorViewport"; viewport.Size = UDim2.fromScale(1, 1)
	viewport.BackgroundTransparency = 1; viewport.BorderSizePixel = 0
	viewport.Ambient = Color3.fromRGB(185, 185, 205); viewport.LightColor = Color3.fromRGB(255, 235, 202)
	viewport.LightDirection = Vector3.new(-1, -1, -1); viewport.Parent = frame
	local fallback = Instance.new("TextLabel")
	fallback.Name = "PreviewUnavailable"; fallback.Size = UDim2.new(1, -16, 1, -16); fallback.Position = UDim2.fromOffset(8, 8)
	fallback.BackgroundTransparency = 1; fallback.TextWrapped = true; fallback.TextSize = 14
	fallback.Font = Theme.Fonts.Body; fallback.TextColor3 = Theme.Colors.Muted
	fallback.Text = options.T("Actor preview unavailable"); fallback.Parent = frame
	local world = Instance.new("WorldModel"); world.Parent = viewport
	local camera = Instance.new("Camera"); camera.FieldOfView = 35; camera.Parent = viewport; viewport.CurrentCamera = camera
	local dead = false
	local timer: thread? = nil
	local lastSource: Model? = nil
	local lastSignature: string? = nil
	local copy: Model? = nil
	local bounds = Vector3.zero
	local function clear()
		if copy then copy:Destroy(); copy = nil end
		lastSource = nil; lastSignature = nil; fallback.Visible = true
	end
	local function fit()
		if not copy then return end
		local aspect = math.max(.05, viewport.AbsoluteSize.X / math.max(1, viewport.AbsoluteSize.Y))
		local tangent = math.tan(math.rad(camera.FieldOfView / 2))
		local distance = math.max(bounds.Y / (2 * tangent), bounds.X / (2 * tangent * aspect)) * 1.15 + bounds.Z / 2
		camera.CFrame = CFrame.lookAt(Vector3.new(0, 0, -distance), Vector3.zero)
	end
	local function visible(): boolean
		if not frame:IsDescendantOf(game) or frame.AbsoluteSize.X <= 0 or frame.AbsoluteSize.Y <= 0 then return false end
		local ancestor: Instance? = frame
		while ancestor do
			if ancestor:IsA("GuiObject") and not ancestor.Visible then return false end
			if ancestor:IsA("LayerCollector") and not ancestor.Enabled then return false end
			ancestor = ancestor.Parent
		end
		return true
	end
	local function sourceModel(): Model?
		local player = Players.LocalPlayer
		if not player then return nil end
		if options.actorId == "player" then
			local character = player.Character
			return if character and character:IsDescendantOf(workspace) then character else nil
		end
		if not options.data or not options.data.adventurers or not options.data.adventurers[options.actorId] then return nil end
		-- Bounded traversal; a missing/streamed-out actor has no substitute.
		local function owned(node: Instance): boolean
			return node:IsA("Model") and node:GetAttribute("GuildborneHero") == true
				and node:GetAttribute("OwnerUserId") == player.UserId
				and node:GetAttribute("AdventurerId") == options.actorId
		end
		if lastSource and lastSource:IsDescendantOf(workspace) and owned(lastSource) then return lastSource end
		local pending: {Instance} = {workspace}
		local scanned = 0
		while #pending > 0 and scanned < 16384 do
			local node = table.remove(pending) :: Instance
			scanned += 1
			if owned(node) then return node :: Model end
			for _, child in ipairs(node:GetChildren()) do
				if #pending + scanned >= 16384 then break end
				table.insert(pending, child)
			end
		end
		return nil
	end
	local function refresh()
		if not visible() then return end
		local source = sourceModel()
		if not source then clear(); return end
		local key = signature(source)
		if not key then clear(); return end
		if source == lastSource and key == lastSignature then return end
		clear()
		local ok, cloned = pcall(function() return snapshot(source) end)
		if not ok or not cloned then return end
		local candidate = cloned :: Model
		-- No parenting, even into a ViewportFrame, until scripts are gone.
		local nodes = descendants(candidate, LIMIT)
		if not nodes then candidate:Destroy(); return end
		for _, node in ipairs(nodes) do
			if node:IsA("LuaSourceContainer") or not visual(node) then node:Destroy() end
		end
		local parts = 0
		for _, node in ipairs(candidate:GetDescendants()) do
			if node:IsA("BasePart") then
				parts += 1; node.Anchored = true; node.CanCollide = false; node.CanTouch = false; node.CanQuery = false
				node.LocalTransparencyModifier = 0
			elseif node:IsA("Humanoid") then
				node.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				node.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
				node.AutoRotate = false; node.EvaluateStateMachine = false
			end
		end
		if parts == 0 then candidate:Destroy(); return end
		candidate:PivotTo(CFrame.identity)
		local box, size = candidate:GetBoundingBox()
		if size.Magnitude ~= size.Magnitude or size.Magnitude > 100 or size.Magnitude <= 0 then candidate:Destroy(); return end
		candidate:PivotTo(CFrame.new(-box.Position) * candidate:GetPivot())
		candidate:SetAttribute("GuildborneHero", nil); candidate:SetAttribute("OwnerUserId", nil)
		candidate.Parent = world; copy = candidate; bounds = size
		lastSource = source; lastSignature = key; fallback.Visible = false; fit()
	end
	local resized = viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	local destroying: RBXScriptConnection? = nil
	local function cleanup()
		if dead then return end
		dead = true; resized:Disconnect()
		if destroying then destroying:Disconnect() end
		if timer then task.cancel(timer); timer = nil end
		clear()
	end
	destroying = frame.Destroying:Connect(cleanup)
	local function tick()
		timer = nil
		if dead then return end
		refresh()
		if not dead then timer = task.delay(1, tick) end
	end
	timer = task.defer(tick)
	return {frame = frame, viewport = viewport, destroy = function() cleanup(); frame:Destroy() end}
end
