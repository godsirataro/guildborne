--!strict
-- Original decorative diorama, not a map or a claim about unlocked locations.
-- Fixed geometry: no heartbeat, assets, gameplay actors, lights or scripts.
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local Panel = require(script.Parent.GuildbornePanel)
local Vista = {}
function Vista.create(parent: Instance)
	local frame = Panel.create(parent, {name = "CompanyStage", size = UDim2.new(1, 0, 0, 350)})
	local sky = Instance.new("ViewportFrame")
	sky.Name = "CitadelDiorama"; sky.Position = UDim2.fromOffset(8, 8); sky.Size = UDim2.new(1, -16, 1, -16)
	sky.BackgroundColor3 = Theme.Colors.Background; sky.BorderSizePixel = 0
	sky.Ambient = Color3.fromRGB(115, 137, 174); sky.LightColor = Color3.fromRGB(255, 226, 170)
	sky.LightDirection = Vector3.new(-1, -1, -.4); sky.Active = false; sky.Parent = frame
	local world = Instance.new("WorldModel"); world.Name = "DecorativeCitadel"; world.Parent = sky
	local camera = Instance.new("Camera"); camera.FieldOfView = 44
	camera.CFrame = CFrame.lookAt(Vector3.new(28, 20, 34), Vector3.new(0, 8, 0))
	camera.Parent = sky; sky.CurrentCamera = camera
	local stone = Color3.fromRGB(65, 81, 104)
	local roof = Color3.fromRGB(27, 40, 62)
	local function block(name: string, size: Vector3, position: Vector3, color: Color3, wedge: boolean?)
		local part = (if wedge then Instance.new("WedgePart") else Instance.new("Part")) :: BasePart
		part.Name = name; part.Size = size; part.Position = position; part.Color = color
		part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
		part.TopSurface = Enum.SurfaceType.Smooth; part.BottomSurface = Enum.SurfaceType.Smooth
		part.Material = Enum.Material.SmoothPlastic; part.Parent = world
		return part
	end
	block("Foundation", Vector3.new(34, 2, 19), Vector3.new(0, -1, 0), roof)
	block("Hall", Vector3.new(15, 7, 7), Vector3.new(0, 3.5, -3), stone)
	block("HallRoof", Vector3.new(16, 4, 9), Vector3.new(0, 9, -3), roof, true)
	for i, x in ipairs({-12, -7, 0, 7, 12}) do
		local height = if i == 3 then 19 else if i == 2 or i == 4 then 13 else 9
		local z = if i == 3 then -7 else if i == 2 or i == 4 then -4 else 2
		block("Tower", Vector3.new(3, height, 3), Vector3.new(x, height / 2, z), stone)
		block("Cornice", Vector3.new(3.8, .5, 3.8), Vector3.new(x, height, z), Theme.Colors.Gold)
		block("Spire", Vector3.new(3.6, 5, 3.6), Vector3.new(x, height + 2.7, z), roof, true)
		block("Finial", Vector3.new(.25, 3, .25), Vector3.new(x, height + 5, z), Theme.Colors.Gold)
		for level = 1, 3 do
			block("Window", Vector3.new(.5, 1.3, .08), Vector3.new(x, height * level / 4, z + 1.54), Theme.Colors.Gold)
		end
	end
	for _, x in ipairs({-9, 9}) do
		block("Banner", Vector3.new(1.8, 5, .15), Vector3.new(x, 5, 1), Theme.Colors.Primary)
		block("BannerRail", Vector3.new(2.5, .15, .3), Vector3.new(x, 7.6, 1), Theme.Colors.Gold)
	end
	for i = -4, 4 do
		block("Causeway", Vector3.new(7, .5, 1.4), Vector3.new(0, -.5 + (i + 4) * .18, 7 + i * 1.4), stone)
	end
	local host = Instance.new("Frame"); host.Name = "HeroStage"; host.BackgroundTransparency = 1; host.ZIndex = 2
	host.Position = UDim2.new(0, 10, .28, 0); host.Size = UDim2.new(1, -20, .72, -10); host.Parent = frame
	return {frame = frame, heroHost = host}
end
return Vista
