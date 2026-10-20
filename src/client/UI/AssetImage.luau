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
export type ItemOptions = {size: number?, modelOnly: boolean?}
function M.item(parent: Instance, definitionId: string, options: ItemOptions?): GuiObject?
	local index = table.find(Assets.ItemOrder, definitionId)
	local atlas, atlasSize = Assets.ItemAtlas, Assets.ItemAtlasSize
	if not index then index=table.find(Assets.EquipmentOrder,definitionId);atlas=Assets.EquipmentAtlas;atlasSize=Assets.EquipmentAtlasSize end
	if not index then return nil end
	-- Existing tile/equipment callers keep their 80px source and .6 equipment scale.
	local edge=if options and options.size then options.size else 80
	if edge~=edge or edge==math.huge or edge==-math.huge then edge=80 end
	edge=math.clamp(edge,16,512)
	local holder=Instance.new("Frame");holder.Name="ItemArtwork";holder.Size=UDim2.fromOffset(edge,edge);holder.BackgroundTransparency=1;holder.Parent=parent
	local fallback=require(script.Parent.ItemViewport)(holder,definitionId,edge)
	-- Inspection must show current original geometry even if an older atlas exists.
	if options and options.modelOnly then return holder end
	local image = M.create(holder, atlas, UDim2.fromOffset(edge, edge))
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
