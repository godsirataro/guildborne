--!strict
-- Hide another owner's personal markers. The server separately validates every interaction.
return function()
 local player=game.Players.LocalPlayer
 local function apply(item:Instance)
  local ancestor=item.Parent;local owner:any=nil
  while ancestor and ancestor~=workspace do
   owner=ancestor:GetAttribute("CampaignOwner");if owner~=nil then break end;ancestor=ancestor.Parent
  end
  if type(owner)~="number"or owner==player.UserId then return end
  if item:IsA("BasePart")then item.LocalTransparencyModifier=1
  elseif item:IsA("ProximityPrompt")or item:IsA("BillboardGui")then
   local target:any=item;target.Enabled=false;item:GetPropertyChangedSignal("Enabled"):Connect(function()if target.Enabled then target.Enabled=false end end)
  end
 end
 for _,item in ipairs(workspace:GetDescendants())do apply(item)end
 workspace.DescendantAdded:Connect(apply)
end
