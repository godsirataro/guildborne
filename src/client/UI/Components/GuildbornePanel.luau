--!strict
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local AssetImage = require(script.Parent.Parent.AssetImage)
local Ornament = require(script.Parent.RegalOrnament)
export type Options = { name: string?, size: UDim2?, ornate: boolean?, sliceImage: string?, sliceCenter: Rect? }
local Panel = {}
function Panel.create(parent: Instance, options: Options?): Frame
	local opts: Options = options or {}
	local frame = Instance.new("Frame")
	frame.Name = opts.name or "GuildbornePanel"
	frame.Size = opts.size or UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Theme.Colors.Surface
	frame.BorderSizePixel = 0
	frame.Parent = parent
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(170, 180, 204)); gradient.Rotation = 90; gradient.Parent = frame
	local border = Instance.new("UIStroke")
	border.Name = "GoldBorder"; border.Color = Theme.Colors.GoldShadow; border.Thickness = 4; border.Parent = frame
	local decoration = Instance.new("Frame")
	decoration.Name = "Decoration"; decoration.Size = UDim2.fromScale(1, 1)
	decoration.BackgroundTransparency = 1; decoration.Active = false; decoration.ZIndex = 3; decoration.Parent = frame
	local inset = Instance.new("Frame")
	inset.Name = "InsetBorder"; inset.BackgroundTransparency = 1
	inset.Position = UDim2.fromOffset(5, 5); inset.Size = UDim2.new(1, -10, 1, -10)
	inset.Active = false; inset.Parent = decoration
	local inner = Instance.new("UIStroke")
	inner.Color = Theme.Colors.Gold; inner.Thickness = 1; inner.Parent = inset
	local bevel = Instance.new("Frame")
	bevel.Name = "InnerBevel"; bevel.BackgroundTransparency = 1; bevel.Position = UDim2.fromOffset(2, 2)
	bevel.Size = UDim2.new(1, -4, 1, -4); bevel.Active = false; bevel.Parent = decoration
	local highlight = Instance.new("UIStroke"); highlight.Color = Theme.Colors.GoldLight; highlight.Thickness = 1; highlight.Parent = bevel
	local etched = Instance.new("Frame")
	etched.Name = "EtchedInnerEdge"; etched.BackgroundTransparency = 1; etched.Position = UDim2.fromOffset(9, 9)
	etched.Size = UDim2.new(1, -18, 1, -18); etched.Active = false; etched.Parent = decoration
	local darkLine = Instance.new("UIStroke"); darkLine.Color = Theme.Colors.GoldShadow; darkLine.Transparency = .25; darkLine.Parent = etched
	if opts.ornate ~= false then
		Ornament.corner(decoration, UDim2.fromOffset(8, 8), 0)
		Ornament.corner(decoration, UDim2.new(1, -40, 0, 8), 90)
		Ornament.corner(decoration, UDim2.new(1, -40, 1, -40), 180)
		Ornament.corner(decoration, UDim2.new(0, 8, 1, -40), 270)
	end
	if opts.sliceImage and opts.sliceCenter then
		local image = AssetImage.create(decoration, opts.sliceImage, UDim2.fromScale(1, 1))
		if image then image.Name = "OptionalSliceBorder"; image.ScaleType = Enum.ScaleType.Slice; image.SliceCenter = opts.sliceCenter end
	end
	-- Put layout objects inside Content so they cannot reposition border decoration.
	local content = Instance.new("Frame")
	content.Name = "Content"; content.Position = UDim2.fromOffset(12, 12)
	content.Size = UDim2.new(1, -24, 1, -24); content.BackgroundTransparency = 1; content.Parent = frame
	return frame
end
return Panel
