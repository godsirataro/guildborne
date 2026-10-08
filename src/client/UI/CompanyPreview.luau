--!strict
-- Viewport copies only the local player's replicated heroes. Never controls actors.
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local Colors = require(game.ReplicatedStorage.Shared.Config.Art).UI
return function(parent: Instance)
	local viewport = Instance.new("ViewportFrame"); viewport.Name = "CompanyPreview"
	viewport.Size = UDim2.new(1, -8, 0, 190); viewport.BackgroundColor3 = Colors.Card; viewport.BorderSizePixel = 0
	viewport.Ambient = Color3.fromRGB(190, 190, 205); viewport.LightColor = Color3.fromRGB(255, 232, 195)
	viewport.LightDirection = Vector3.new(-1, -1, -1); viewport.Active = true; viewport.Visible = false; viewport.Parent = parent
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 12); corner.Parent = viewport
	local world = Instance.new("WorldModel"); world.Parent = viewport
	local camera = Instance.new("Camera"); camera.FieldOfView = 35; camera.Parent = viewport; viewport.CurrentCamera = camera
	local count = 0; local yaw = 0; local drag: InputObject? = nil; local lastX = 0; local signature = ""
	local function positionCamera()
		local aspect = viewport.AbsoluteSize.X / math.max(1, viewport.AbsoluteSize.Y)
		local distance = math.max(14, (count * 4 + 2) / (2 * math.tan(math.rad(17.5)) * math.max(.5, aspect)))
		camera.CFrame = CFrame.lookAt(Vector3.new(math.sin(yaw) * distance, 7, -math.cos(yaw) * distance), Vector3.new(0, 3, 0))
	end
	viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(positionCamera)
	viewport.InputBegan:Connect(function(event: InputObject)
		if event.UserInputType == Enum.UserInputType.MouseButton1 or event.UserInputType == Enum.UserInputType.Touch then drag = event; lastX = event.Position.X end
	end)
	local moved = Input.InputChanged:Connect(function(event: InputObject)
		if drag and (event == drag or event.UserInputType == Enum.UserInputType.MouseMovement) then
			yaw += (event.Position.X - lastX) * .01; lastX = event.Position.X; positionCamera()
		end
	end)
	local released = Input.InputEnded:Connect(function(event: InputObject)
		if event == drag or event.UserInputType == Enum.UserInputType.MouseButton1 then drag = nil end
	end)
	viewport.Destroying:Connect(function() moved:Disconnect(); released:Disconnect() end)
	local api = {}
	function api.update(data: any)
		if not data then return end
		local sources: {Model} = {}
		for _, instance in ipairs(workspace:GetDescendants()) do
			if instance:IsA("Model") and instance:GetAttribute("GuildborneHero") and instance:GetAttribute("OwnerUserId") == Players.LocalPlayer.UserId
				and data.adventurers[instance:GetAttribute("AdventurerId")] then table.insert(sources, instance) end
		end
		table.sort(sources, function(a, b) return tostring(a:GetAttribute("AdventurerId")) < tostring(b:GetAttribute("AdventurerId")) end)
		while #sources > 5 do table.remove(sources) end
		local keys = {}; for _, model in ipairs(sources) do table.insert(keys, tostring(model:GetAttribute("AdventurerId")) .. ":" .. tostring(model:GetAttribute("WeaponId"))) end
		local key = table.concat(keys, "|"); if key == signature then return end; signature = key
		world:ClearAllChildren(); count = #sources; viewport.Visible = count > 0
		for i, source in ipairs(sources) do
			local copy = source:Clone(); if not copy then continue end
			for _, child in ipairs(copy:GetDescendants()) do
				if child:IsA("LuaSourceContainer") or child:IsA("Humanoid") or child:IsA("LayerCollector") or child:IsA("ProximityPrompt") then child:Destroy()
				elseif child:IsA("BasePart") then child.Anchored = true; child.CanCollide = false; child.CanTouch = false; child.CanQuery = false; child.LocalTransparencyModifier=0 end
			end
			copy:SetAttribute("GuildborneHero", nil); copy:PivotTo(CFrame.new((i - (count + 1) / 2) * 4, 3, 0)); copy.Parent = world
		end
		positionCamera()
	end
	function api.destroy() viewport:Destroy() end
	return api
end
