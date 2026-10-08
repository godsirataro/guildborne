--!strict
local Assets = require(game.ReplicatedStorage.Shared.Config.VisualAssets)
local M = {}
function M.create(parent: Instance, id: string, size: UDim2): ImageLabel?
	if not string.match(id, "^rbxassetid://[1-9]%d*$") then return nil end
	local image = Instance.new("ImageLabel"); image.Name = "AssetArtwork"
	image.Size = size; image.BackgroundTransparency = 1; image.ScaleType = Enum.ScaleType.Fit
	image.Visible = false; image.Image = id; image.Parent = parent
	local function loaded() image.Visible = image.IsLoaded end
	image:GetPropertyChangedSignal("IsLoaded"):Connect(loaded); loaded()
	return image
end
function M.item(parent: Instance, definitionId: string): GuiObject?
	local index = table.find(Assets.ItemOrder, definitionId)
	local atlas, atlasSize = Assets.ItemAtlas, Assets.ItemAtlasSize
	if not index then index=table.find(Assets.EquipmentOrder,definitionId);atlas=Assets.EquipmentAtlas;atlasSize=Assets.EquipmentAtlasSize end
	if not index then return nil end
	local holder=Instance.new("Frame");holder.Name="ItemArtwork";holder.Size=UDim2.fromOffset(80,80);holder.BackgroundTransparency=1;holder.Parent=parent
	local fallback=require(script.Parent.ItemViewport)(holder,definitionId)
	local image = M.create(holder, atlas, UDim2.fromOffset(80, 80))
	if not image then return holder end
	local column = (index - 1) % Assets.ItemColumns; local row = math.floor((index - 1) / Assets.ItemColumns)
	local x = math.round(column * atlasSize.X / Assets.ItemColumns)
	local y = math.round(row * atlasSize.Y / Assets.ItemRows)
	local right = math.round((column + 1) * atlasSize.X / Assets.ItemColumns)
	local bottom = math.round((row + 1) * atlasSize.Y / Assets.ItemRows)
	image.ImageRectOffset = Vector2.new(x, y); image.ImageRectSize = Vector2.new(right - x, bottom - y)
	local function refreshFallback() if fallback then fallback.Visible=not image.IsLoaded end end
	image:GetPropertyChangedSignal("IsLoaded"):Connect(refreshFallback);refreshFallback()
	return holder
end
return M
