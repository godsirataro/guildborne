-- Run by Studio owner in CLIENT context after opening Inventory. Read-only.
local player = game:GetService("Players").LocalPlayer
assert(player, "Client context required")
local result = {panes = {}}
local function highest(node)
 local z = if node:IsA("GuiObject") then node.ZIndex else 0
 for _, child in ipairs(node:GetChildren()) do z = math.max(z, highest(child)) end
 return z
end
for _, pane in ipairs(player.PlayerGui:GetDescendants()) do
 if pane.Name ~= "InventoryPane" or not pane:IsA("GuiObject") then continue end
 local gui = pane:FindFirstAncestorOfClass("ScreenGui")
 local row = {path=pane:GetFullName(), ordering=gui and gui.ZIndexBehavior.Name, sections={}, portraits={}, tiles={}}
 for _, child in ipairs(pane:GetChildren()) do
  if child:IsA("GuiObject") then row.sections[child.Name]=(row.sections[child.Name] or 0)+1 end
 end
 for _, node in ipairs(pane:GetDescendants()) do
  if node.Name == "InventoryActorPreview" then
   local viewport=node:FindFirstChild("ActorViewport");local stage=node:FindFirstChild("PortraitStage")
   if viewport and stage then
    local size=viewport.AbsoluteSize
    table.insert(row.portraits,{width=size.X,height=size.Y,stageVisible=stage.Visible,
     stageMaxZ=highest(stage),viewportZ=viewport.ZIndex,stageBelow=highest(stage)<viewport.ZIndex})
   end
  elseif node:IsA("TextButton") and node:GetAttribute("ItemId") then
   local art=node:FindFirstChild("ItemArtwork");local quantity=node:FindFirstChild("Quantity")
   local corners=node:FindFirstChild("SelectedCorners")
   table.insert(row.tiles,{id=node:GetAttribute("ItemId"),active=node.Active,
    selected=node:GetAttribute("Selected"),artMaxZ=art and highest(art),
    quantity=quantity and quantity.Text,quantityZ=quantity and quantity.ZIndex,
    quantityAbove=if quantity and art then quantity.ZIndex>highest(art) else nil,
    cornersAbove=if corners and art then corners.ZIndex>highest(art) else nil})
  end
 end
 table.insert(result.panes,row)
end
return result
