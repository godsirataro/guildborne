--!strict
-- A disposable local WorldModel. Never clones or alters the live character or profile.
local Input = game:GetService("UserInputService")
local Renderer = require(game:GetService("ReplicatedStorage").Shared.Presentation.ModularAppearance.Renderer)
local V = Vector3.new

return function(view: ViewportFrame)
	local camera = Instance.new("Camera"); camera.FieldOfView = 35; camera.Parent = view; view.CurrentCamera = camera
	local world = Instance.new("WorldModel"); world.Name = "AppearancePreviewWorld"; world.Parent = view
	view.Active = true; view.Ambient = Color3.fromRGB(190, 195, 210)
	view.LightColor = Color3.fromRGB(255, 232, 199); view.LightDirection = V(-1, -1, -1)
	local connections: {RBXScriptConnection} = {}
	local dead = false
	local drag: InputObject? = nil
	local lastPoint = Vector2.zero
	local yaw, elevation, zoom = 0, 0, 1
	local center = V(0, 0, 0)
	local bounds = V(3, 6, 2)
	local api: any = {}
	local function shown(): boolean
		local cursor: Instance? = view
		while cursor do
			if cursor:IsA("GuiObject") and not cursor.Visible then return false end
			if cursor:IsA("ScreenGui") and not cursor.Enabled then return false end
			cursor = cursor.Parent
		end
		return view.Parent ~= nil and not dead
	end
	local function updateCamera()
		if dead then return end
		local aspect = math.max(.3, view.AbsoluteSize.X / math.max(1, view.AbsoluteSize.Y))
		local distance = math.max(bounds.Y, bounds.X / aspect) * .62 / math.tan(math.rad(camera.FieldOfView / 2))
		distance = math.max(3.5, distance) * zoom + bounds.Z * .5
		local direction = V(math.sin(yaw) * math.cos(elevation), math.sin(elevation), -math.cos(yaw) * math.cos(elevation))
		camera.CFrame = CFrame.lookAt(center + direction * distance, center)
	end
	local function zoomBy(amount: number)
		zoom = math.clamp(zoom + amount, .65, 1.8); updateCamera()
	end
	function api.SetSelection(selection: any): (boolean, string?)
		if dead then return false, "AppearancePreviewUnavailable" end
		world:ClearAllChildren()
		-- Renderer only consumes catalog IDs. An assembly failure is an unavailable preview.
		local success, model = pcall(Renderer.Build, selection)
		if not success or typeof(model) ~= "Instance" or not model:IsA("Model") then
			view:SetAttribute("PreviewStatus", "Unavailable")
			return false, "AppearancePreviewUnavailable"
		end
		model.Name = "DraftAppearance"
		for _, child in ipairs(model:GetDescendants()) do
			if child:IsA("BaseScript") then child:Destroy()
			elseif child:IsA("BasePart") then
				child.Anchored = true; child.CanCollide = false; child.CanTouch = false; child.CanQuery = false
			end
		end
		model.Parent = world
		local frame, size = model:GetBoundingBox(); center = frame.Position; bounds = size
		view:SetAttribute("PreviewStatus", "Ready")
		view:SetAttribute("PreviewIsPlaceholder", model:GetAttribute("Placeholder") == true or model:GetAttribute("AssetStatus") == "PLACEHOLDER")
		updateCamera()
		return true, nil
	end
	function api.SetView(name: string)
		yaw = if name == "Side" then math.pi / 2 elseif name == "Back" then math.pi else 0
		elevation = 0; updateCamera()
	end
	function api.ResetView() yaw = 0; elevation = 0; zoom = 1; updateCamera() end
	function api.ZoomIn() zoomBy(-.12) end
	function api.ZoomOut() zoomBy(.12) end
	function api.Clear() world:ClearAllChildren(); view:SetAttribute("PreviewStatus", "Unavailable") end
	table.insert(connections, view.InputBegan:Connect(function(input: InputObject)
		if shown() and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
			drag = input; lastPoint = Vector2.new(input.Position.X, input.Position.Y)
		end
	end))
	table.insert(connections, Input.InputChanged:Connect(function(input: InputObject)
		if not shown() then drag = nil; return end
		if drag and ((drag.UserInputType == Enum.UserInputType.Touch and input == drag) or (drag.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)) then
			local point = Vector2.new(input.Position.X, input.Position.Y)
			local delta = point - lastPoint; lastPoint = point
			yaw += delta.X * .012; elevation = math.clamp(elevation + delta.Y * .006, -.35, .35); updateCamera()
		elseif input.UserInputType == Enum.UserInputType.MouseWheel then
			local point = Input:GetMouseLocation()
			local low, size = view.AbsolutePosition, view.AbsoluteSize
			if point.X >= low.X and point.X <= low.X + size.X and point.Y >= low.Y and point.Y <= low.Y + size.Y then zoomBy(-input.Position.Z * .1) end
		end
	end))
	table.insert(connections, Input.InputEnded:Connect(function(input: InputObject)
		if input == drag or input.UserInputType == Enum.UserInputType.MouseButton1 then drag = nil end
	end))
	table.insert(connections, view:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCamera))
	function api.Destroy()
		if dead then return end
		dead = true; drag = nil
		for _, connection in ipairs(connections) do connection:Disconnect() end
		table.clear(connections); world:Destroy(); camera:Destroy()
	end
	table.insert(connections, view.Destroying:Connect(api.Destroy))
	updateCamera()
	return api
end
