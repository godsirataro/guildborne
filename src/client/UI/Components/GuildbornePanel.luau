--!strict
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local AssetImage = require(script.Parent.Parent.AssetImage)
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
	border.Name = "GoldBorder"; border.Color = Theme.Colors.Gold; border.Transparency = .25; border.Parent = frame
	local decoration = Instance.new("Frame")
	decoration.Name = "Decoration"; decoration.Size = UDim2.fromScale(1, 1)
	decoration.BackgroundTransparency = 1; decoration.Active = false; decoration.Parent = frame
	local inset = Instance.new("Frame")
	inset.Name = "InsetBorder"; inset.BackgroundTransparency = 1
	inset.Position = UDim2.fromOffset(5, 5); inset.Size = UDim2.new(1, -10, 1, -10)
	inset.Active = false; inset.Parent = decoration
	local inner = Instance.new("UIStroke")
	inner.Color = Theme.Colors.Border; inner.Transparency = .45; inner.Parent = inset
	if opts.ornate ~= false then
		for _, position in ipairs({Vector2.new(0, 0), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(1, 1)}) do
			local jewel = Instance.new("Frame")
			jewel.Name = "CornerAccent"; jewel.Size = UDim2.fromOffset(5, 5)
			jewel.AnchorPoint = Vector2.new(.5, .5)
			jewel.Position = UDim2.new(position.X, if position.X == 0 then 5 else -5, position.Y, if position.Y == 0 then 5 else -5)
			jewel.Rotation = 45; jewel.BorderSizePixel = 0; jewel.BackgroundColor3 = Theme.Colors.Gold
			jewel.Active = false; jewel.Parent = decoration
		end
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
