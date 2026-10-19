--!strict
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local Button = require(script.Parent.GuildborneButton)
local AssetImage = require(script.Parent.Parent.AssetImage)

-- A recessed mount describes the slot, not an owned item or its rarity.
local function emptyMount(icon: Frame, slot: string)
	local function line(name: string, x: number, y: number, w: number, h: number, rotation: number?)
		local part = Instance.new("Frame"); part.Name = name; part.AnchorPoint = Vector2.new(.5, .5)
		part.Position = UDim2.fromOffset(x, y); part.Size = UDim2.fromOffset(w, h); part.Rotation = rotation or 0
		part.BackgroundColor3 = Theme.Colors.GoldShadow; part.BackgroundTransparency = .15
		part.BorderSizePixel = 0; part.Active = false; part.Selectable = false; part.Parent = icon
	end
	if slot == "weapon" then
		line("Blade", 26, 20, 3, 23, 32); line("Guard", 20, 30, 15, 3, 32); line("Grip", 17, 35, 3, 9, 32)
	elseif slot == "armor" then
		line("ShoulderLeft", 16, 14, 13, 3, -30); line("ShoulderRight", 32, 14, 13, 3, 30)
		line("SideLeft", 16, 27, 2, 22); line("SideRight", 32, 27, 2, 22); line("Hem", 24, 38, 18, 2)
		line("Collar", 24, 12, 8, 2)
	elseif slot == "accessory" then
		local setting = Instance.new("Frame"); setting.Name = "AccessorySetting"
		setting.AnchorPoint = Vector2.new(.5, .5); setting.Position = UDim2.fromOffset(24, 26)
		setting.Size = UDim2.fromOffset(17, 17); setting.Rotation = 45; setting.BackgroundTransparency = 1
		setting.Active = false; setting.Selectable = false; setting.Parent = icon
		local edge = Instance.new("UIStroke"); edge.Color = Theme.Colors.GoldShadow; edge.Parent = setting
		line("Bail", 24, 12, 4, 6)
	end
end

-- Presentation only: the caller supplies the authoritative slot and unequip intent.
return function(parent: Instance, slot: any, T: (string) -> string): Frame
	local root = Instance.new("Frame")
	root.Name = "EquipmentSlot_" .. tostring(slot.slot); root.Size = UDim2.new(1, 0, 0, 78)
	root.BackgroundColor3 = Theme.Colors.Background; root.BorderSizePixel = 0; root.Parent = parent
	local rim = Instance.new("UIStroke"); rim.Color = Theme.Colors.GoldShadow; rim.Parent = root
	local icon = Instance.new("Frame"); icon.Name = "SlotIcon"; icon.BackgroundTransparency = 1
	icon.Position = UDim2.fromOffset(4, 10); icon.Size = UDim2.fromOffset(48, 48); icon.Parent = root
	icon.BackgroundColor3 = Theme.Colors.Surface; icon.BackgroundTransparency = .35
	icon.Active = false; icon.Selectable = false
	local mountRim = Instance.new("UIStroke"); mountRim.Color = Theme.Colors.GoldShadow
	mountRim.Transparency = .55; mountRim.Parent = icon
	if slot.definitionId then
		local artwork = AssetImage.item(icon, slot.definitionId)
		if artwork then local scale = Instance.new("UIScale"); scale.Scale = .6; scale.Parent = artwork end
	else
		emptyMount(icon, tostring(slot.slot))
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
