--!strict
-- Local review binder supplies the licensed source pixels. Runtime has no guessed ID.
local QualityAsset = {}
function QualityAsset.create(parent: Instance, key: string, size: UDim2?): ImageLabel
	local image = Instance.new("ImageLabel")
	image.Name = "Quality_" .. key; image.BackgroundTransparency = 1; image.Image = ""
	image.Size = size or UDim2.fromScale(1, 1); image.Active = false
	image:SetAttribute("QualityAssetKey", key)
	if key == "panelBorder" or key == "parchment" then
		image.ScaleType = Enum.ScaleType.Slice
		image.SliceCenter = if key == "panelBorder" then Rect.new(28, 28, 68, 68) else Rect.new(16, 16, 84, 84)
		if key == "panelBorder" then image.SliceScale = .5; image.ImageColor3 = require(script.Parent.Parent.DesignSystem.Theme).Colors.Gold end
	else image.ScaleType = Enum.ScaleType.Fit end
	if key == "questIcon" then image.ImageRectOffset = Vector2.new(42, 24); image.ImageRectSize = Vector2.new(16, 60)
	elseif key == "partyIcon" then image.ImageRectOffset = Vector2.new(16, 28); image.ImageRectSize = Vector2.new(70, 48) end
	image.Parent = parent
	return image
end
return QualityAsset
