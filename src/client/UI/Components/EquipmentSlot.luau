--!strict
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local Button = require(script.Parent.GuildborneButton)
local AssetImage = require(script.Parent.Parent.AssetImage)

-- Presentation only: the caller supplies the authoritative slot and unequip intent.
return function(parent: Instance, slot: any, T: (string) -> string): Frame
	local root = Instance.new("Frame")
	root.Name = "EquipmentSlot_" .. tostring(slot.slot); root.Size = UDim2.new(1, 0, 0, 78)
	root.BackgroundColor3 = Theme.Colors.Background; root.BorderSizePixel = 0; root.Parent = parent
	local rim = Instance.new("UIStroke"); rim.Color = Theme.Colors.GoldShadow; rim.Parent = root
	local icon = Instance.new("Frame"); icon.Name = "SlotIcon"; icon.BackgroundTransparency = 1
	icon.Position = UDim2.fromOffset(4, 10); icon.Size = UDim2.fromOffset(48, 48); icon.Parent = root
	if slot.definitionId then
		local artwork = AssetImage.item(icon, slot.definitionId)
		if artwork then local scale = Instance.new("UIScale"); scale.Scale = .6; scale.Parent = artwork end
	end
	local label = Instance.new("TextLabel"); label.Name = "EquipmentName"; label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(58, 4); label.Size = UDim2.new(1, -64, 0, 70)
	label.Font = Theme.Fonts.Body; label.TextSize = 13; label.TextColor3 = Theme.Colors.Text
	label.TextWrapped = true; label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = tostring(slot.label) .. "\n" .. tostring(slot.itemName or T("Empty")); label.Parent = root
	if slot.onUnequip then
		-- Full-width second row prevents a 48 px action from squeezing Thai item names.
		root.Size = UDim2.new(1, 0, 0, 130)
		local action = Button.create(root, {name = "Unequip_" .. tostring(slot.slot), text = T("Unequip"), size = UDim2.new(1, -8, 0, 48), onActivated = slot.onUnequip})
		action.button.Position = UDim2.fromOffset(4, 78); action.button.TextSize = 13
		action.setDisabled(slot.enabled == false)
	end
	return root
end
