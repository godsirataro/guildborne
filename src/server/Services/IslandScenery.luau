--!strict
-- Deterministic visual scenery only. Adventure regions/AI are a separate milestone.
-- Every part is non-colliding and non-queryable; existing navigation keeps authority.
local V = Vector3.new
return function(parent: Instance): Model
	local scene = Instance.new("Model"); scene.Name = "ArchipelagoScenery"
	scene:SetAttribute("DecorativeOnly", true); scene:SetAttribute("AssetVersion", 1); scene.Parent = parent
	local count = 0
	local function part(name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?): Part
		count += 1; assert(count <= 220, "Island scenery part budget exceeded")
		local p = Instance.new("Part"); p.Name = name; p.Size = size; p.Position = position; p.Color = color
		p.Material = material or Enum.Material.SmoothPlastic; p.Anchored = true
		p.CanCollide = false; p.CanTouch = false; p.CanQuery = false; p.CastShadow = false
		p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth; p.Parent = scene
		return p
	end
	local rock = Color3.fromRGB(98, 113, 119)
	local sand = Color3.fromRGB(221, 200, 150)
	local grass = Color3.fromRGB(102, 153, 90)
	local ocean = part("Ocean", V(3100, 1, 2900), V(0, -13, -1540), Color3.fromRGB(29, 130, 165))
	ocean.Reflectance = .1
	local function coast(center: Vector3, width: number, depth: number, top: number, tint: Color3)
		part("ShallowWater", V(width + 90, .4, depth + 90), V(center.X, -12.3, center.Z), Color3.fromRGB(55, 174, 183))
		part("SandShelf", V(width + 24, 6, depth + 24), V(center.X, -13, center.Z), sand)
		part("IslandCore", V(width, top + 40, depth), V(center.X, (top - 40) / 2, center.Z), rock, Enum.Material.Slate)
		part("IslandSurface", V(width - 12, 2, depth - 12), V(center.X, top - 1, center.Z), tint)
		for i = 1, 16 do
			local a = i * math.pi / 8
			local size = 24 + (i % 3) * 9
			local p = part("CoastRock", V(size, 23 + i % 5, size * 1.2), V(center.X + math.cos(a) * width * .49, top - 16, center.Z + math.sin(a) * depth * .49), rock)
			p.CFrame *= CFrame.Angles(0, a, math.rad((i % 3 - 1) * 9))
		end
	end
	-- Mainland cliffs sit below the existing safe-zone floor and city walls.
	coast(V(0, 0, -1130), 986, 1080, -8.5, sand)
	local forest = V(-940, 0, -1410)
	coast(forest, 330, 360, 7, grass)
	local function tree(at: Vector3, scale: number)
		part("TreeTrunk", V(9, 40, 9) * scale, at + V(0, 20 * scale, 0), Color3.fromRGB(108, 77, 48), Enum.Material.Wood)
		for i = 1, 3 do
			local a = i * 2.094
			local crown = part("TreeCrown", V(45, 30, 40) * scale, at + V(math.cos(a) * 13, 42, math.sin(a) * 13) * scale, Color3.fromRGB(52 + i * 8, 115 + i * 8, 68))
			crown.Shape = Enum.PartType.Ball
		end
	end
	tree(forest + V(0, 7, -20), 2.6)
	for i = 1, 7 do local a = i * .897; tree(forest + V(math.cos(a) * 110, 7, math.sin(a) * 125), .7 + (i % 3) * .15) end
	part("ForestWaterfall", V(17, 44, 2), forest + V(75, -13, 180), Color3.fromRGB(164, 225, 235))
	local quarry = V(930, 0, -1400)
	coast(quarry, 380, 340, 4, Color3.fromRGB(186, 146, 101))
	for i = 1, 4 do
		part("QuarryTerrace", V(310 - i * 46, 22, 255 - i * 36), quarry + V(0, 4 + i * 19, -30), Color3.fromRGB(146 + i * 6, 123 + i * 4, 101))
	end
	for i = 1, 6 do
		local a = i * math.pi / 3
		local ore = part("QuarryCrystal", V(12, 32 + (i % 3) * 7, 12), quarry + V(math.cos(a) * 140, 18, math.sin(a) * 125), Color3.fromRGB(221, 169, 81))
		ore.CFrame *= CFrame.Angles(.1, a, .2)
	end
	part("QuarryCranePost", V(9, 80, 9), quarry + V(-110, 44, 105), Color3.fromRGB(106, 77, 47), Enum.Material.Wood)
	part("QuarryCraneArm", V(74, 7, 7), quarry + V(-83, 80, 105), Color3.fromRGB(106, 77, 47), Enum.Material.Wood)
	local ruins = V(0, 0, -2370)
	coast(ruins, 300, 300, 75, Color3.fromRGB(108, 109, 143))
	for i = 1, 8 do
		local a = i * math.pi / 4
		local at = ruins + V(math.cos(a) * 105, 109, math.sin(a) * 105)
		part("RuinsPillar", V(16, 68, 16), at, Color3.fromRGB(124, 130, 159))
		part("RuinsRune", V(3, 35, 17), at, Color3.fromRGB(96, 216, 229), Enum.Material.Neon)
	end
	part("WardenSpire", V(22, 113, 22), ruins + V(0, 131, 0), Color3.fromRGB(67, 76, 111))
	local crystal = part("WardenBeacon", V(18, 28, 18), ruins + V(0, 194, 0), Color3.fromRGB(115, 222, 235), Enum.Material.Neon)
	crystal.CFrame *= CFrame.Angles(0, 0, math.pi / 4)
	for i = 1, 4 do
		local a = i * math.pi / 2
		part("FloatingFragment", V(30, 24, 36), ruins + V(math.cos(a) * 205, 62 + i * 9, math.sin(a) * 205), Color3.fromRGB(97, 99, 132))
	end
	-- Tiny harbor silhouettes supply scale without adding travel prompts or physics.
	for _, x in ipairs({-570, 570}) do
		local at = V(x, -7, -830)
		part("HarborBoatHull", V(18, 8, 42), at, Color3.fromRGB(110, 76, 48), Enum.Material.Wood)
		part("HarborBoatMast", V(2, 38, 2), at + V(0, 22, 0), Color3.fromRGB(87, 62, 44))
		part("HarborSail", V(22, 27, .5), at + V(0, 24, 1), Color3.fromRGB(237, 226, 198), Enum.Material.Fabric)
	end
	-- The same original prop definitions also export to editable Blender/FBX/GLB.
	-- These distant dressing models do not grant travel, loot or quest progress.
	local props = require(script.Parent.AdventurePropKit)()
	local function dress(name: string, at: Vector3, scale: number, yaw: number)
		local template = props:FindFirstChild(name)
		assert(template and template:IsA("Model"), "Missing adventure prop: " .. name)
		local copy = template:Clone()
		copy:ScaleTo(scale)
		copy:PivotTo(CFrame.new(at) * CFrame.Angles(0, math.rad(yaw), 0))
		copy.Parent = scene
		for _, descendant in ipairs(copy:GetDescendants()) do
			if descendant:IsA("BasePart") then count += 1; descendant.CastShadow = false end
		end
	end
	dress("GreenwoodWaystone", forest + V(-55, 7, 90), 3, 0)
	dress("GreenwoodSupplyCache", forest + V(-70, 7, 83), 2, 15)
	dress("GreenwoodFern", forest + V(65, 7, 65), 4, 0)
	dress("IronveilOreCart", quarry + V(95, 4, 90), 3, 25)
	dress("IronveilCrystalCluster", quarry + V(-90, 4, 85), 3, 0)
	dress("IronveilForge", quarry + V(40, 4, 125), 3, 180)
	dress("AshenRunePillar", ruins + V(-65, 75, 60), 3, 0)
	dress("AshenRunePillar", ruins + V(65, 75, 60), 3, 0)
	dress("AshenShrine", ruins + V(0, 75, 80), 3, 0)
	props:Destroy()
	assert(count <= 300, "Decorated island scenery exceeds 300-part budget")
	scene:SetAttribute("AssetVersion", 2)
	scene:SetAttribute("PartCount", count)
	return scene
end
