--!strict
-- Original bounded native geometry; a decorative crest, not a replacement logo asset.
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local C = Theme.Colors
local Ornament = {}
local function line(parent: Instance, a: Vector2, b: Vector2, color: Color3, thickness: number)
	local delta = b - a
	local part = Instance.new("Frame")
	part.Name = "EngravedLine"; part.BorderSizePixel = 0; part.Active = false
	part.AnchorPoint = Vector2.new(.5, .5); part.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
	part.Size = UDim2.fromOffset(delta.Magnitude, thickness); part.Rotation = math.deg(math.atan2(delta.Y, delta.X))
	part.BackgroundColor3 = color; part.Parent = parent
	return part
end
function Ornament.corner(parent: Instance, position: UDim2, rotation: number, small: boolean?): Frame
	local root = Instance.new("Frame")
	root.Name = "BeveledCorner"; root.Size = UDim2.fromOffset(32, 32); root.Position = position
	root.BackgroundTransparency = 1; root.Rotation = rotation; root.Active = false; root.Parent = parent
	local scale = if small then .55 else 1
	local function edge(x: number, y: number, xx: number, yy: number)
		line(root, Vector2.new(x, y) * scale, Vector2.new(xx, yy) * scale, C.GoldShadow, 4)
		line(root, Vector2.new(x, y) * scale, Vector2.new(xx, yy) * scale, C.GoldLight, 1)
	end
	edge(0, 28, 0, 0); edge(0, 0, 28, 0); edge(3, 24, 10, 10); edge(10, 10, 24, 3)
	edge(4, 4, 14, 14)
	return root
end
function Ornament.crest(parent: Instance): Frame
	local root = Instance.new("Frame")
	root.Name = "NativeGuildCrest"; root.Size = UDim2.fromOffset(120, 64)
	root.BackgroundTransparency = 1; root.Active = false; root.Parent = parent
	-- Burgundy mantle, gold shield and central compass gem use only native primitives.
	for _, side in ipairs({-1, 1}) do
		for index = 1, 3 do
			local fold = Instance.new("Frame")
			fold.Name = "MantleFold"; fold.AnchorPoint = Vector2.new(.5, .5)
			fold.Position = UDim2.fromOffset(60 + side * (22 + index * 7), 30 + index * 4)
			fold.Size = UDim2.fromOffset(28, 9); fold.Rotation = side * (12 + index * 8)
			fold.BorderSizePixel = 0; fold.BackgroundColor3 = C.Primary:Lerp(C.Background, index * .12); fold.Parent = root
			local hem = Instance.new("UIStroke"); hem.Color = C.GoldShadow; hem.Thickness = 1; hem.Parent = fold
		end
	end
	local shield = Instance.new("Frame")
	shield.Name = "Shield"; shield.AnchorPoint = Vector2.new(.5, .5); shield.Position = UDim2.fromOffset(60, 31)
	shield.Size = UDim2.fromOffset(34, 34); shield.Rotation = 45; shield.BackgroundColor3 = C.Background; shield.BorderSizePixel = 0; shield.Parent = root
	local rim = Instance.new("UIStroke"); rim.Color = C.Gold; rim.Thickness = 3; rim.Parent = shield
	local inset = Instance.new("Frame")
	inset.Name = "ShieldInset"; inset.Position = UDim2.fromOffset(5, 5); inset.Size = UDim2.new(1, -10, 1, -10)
	inset.BackgroundTransparency = 1; inset.Parent = shield
	local stroke = Instance.new("UIStroke"); stroke.Color = C.GoldLight; stroke.Thickness = 1; stroke.Parent = inset
	for index = 0, 7 do
		local angle = math.rad(index * 45)
		local direction = Vector2.new(math.cos(angle), math.sin(angle))
		line(root, Vector2.new(60, 31) + direction * 5, Vector2.new(60, 31) + direction * (if index % 2 == 0 then 24 else 15), C.GoldLight, if index % 2 == 0 then 2 else 1)
	end
	local gem = Instance.new("Frame")
	gem.Name = "CompassGem"; gem.AnchorPoint = Vector2.new(.5, .5); gem.Position = UDim2.fromOffset(60, 31)
	gem.Size = UDim2.fromOffset(9, 9); gem.Rotation = 45; gem.BorderSizePixel = 0; gem.BackgroundColor3 = C.Focus; gem.Parent = root
	local gemRim = Instance.new("UIStroke"); gemRim.Color = C.GoldLight; gemRim.Thickness = 1; gemRim.Parent = gem
	return root
end
return Ornament
