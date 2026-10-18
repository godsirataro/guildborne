--!strict
-- ISOLATED native review: synthetic inventory; recorded intents NEVER mutate data or call remotes.
-- The selected player preview uses the actual local avatar. Rowan has no fixture model.
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Inventory = require(game.StarterPlayer.StarterPlayerScripts.Client.UI.InventoryView)
local Theme = require(game.StarterPlayer.StarterPlayerScripts.Client.UI.DesignSystem.Theme)
local Localization = require(game.ReplicatedStorage.Shared.Config.Localization)
local gui = Instance.new("ScreenGui"); gui.Name = "InventoryReview"; gui.ResetOnSpawn = false
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local host = Instance.new("Frame"); host.Size = UDim2.fromScale(1, 1); host.BackgroundColor3 = Theme.Colors.Background; host.Parent = gui
local viewer = Instance.new("ScrollingFrame"); viewer.Name = "FixtureViewport"; viewer.Position = UDim2.fromOffset(0, 180)
viewer.Size = UDim2.new(1, 0, 1, -180); viewer.BackgroundColor3 = Color3.fromRGB(35, 42, 48); viewer.ScrollBarThickness = 6; viewer.Parent = host
local notice = Instance.new("TextLabel"); notice.Name = "FixtureNotice"; notice.Position = UDim2.fromOffset(6, 112)
notice.Size = UDim2.new(1, -12, 0, 64); notice.BackgroundTransparency = 1; notice.Font = Theme.Fonts.Body
notice.TextSize = 12; notice.TextColor3 = Theme.Colors.Text; notice.TextWrapped = true; notice.Parent = host
local sizes = {Vector2.new(796, 675), Vector2.new(1366, 768), Vector2.new(320, 568)}
local modes = {"Owned", "Busy", "Empty", "Incompatible", "LongCopy", "Capacity", "HallLocked"}
local sizeIndex, modeIndex, generation, count = 1, 1, 0, 0
local language, fit, lastAction = "en", false, "No intents recorded"
local canvas: Frame? = nil
local scroll: ScrollingFrame? = nil
local renderer: any = nil
local ui: any = {}
local alive = true
local function label(parent: Instance, name: string, text: string, x: number, y: number, w: number, h: number)
	local object = Instance.new("TextLabel"); object.Name = name; object.Text = text; object.BackgroundTransparency = 1
	object.Position = UDim2.fromOffset(x, y); object.Size = UDim2.fromOffset(w, h); object.TextWrapped = true
	object.Font = Theme.Fonts.Body; object.TextSize = 14; object.TextColor3 = Theme.Colors.Text; object.Parent = parent
	return object
end
local function state(): (any, any)
	local catalog: any = {EquipmentLimit = 50, Tavern = {Ranks = {"F", "E"}}, Character = {Classes = {Warrior = {Weapon = "training_sword"}}},
		ItemOrder = {"training_sword", "short_bow", "leather_vest", "timber"}, Items = {
		training_sword = {Name = "Training Sword", Description = "A simple sword for training.", Kind = "Weapon", Slot = "weapon", Class = "Warrior", Attack = 3, Price = 20, HallLevel = 1},
		short_bow = {Name = "Short Bow", Description = "A light bow for a ranger.", Kind = "Weapon", Slot = "weapon", Class = "Ranger", Attack = 4, Price = 25, HallLevel = 2},
		leather_vest = {Name = "Leather Vest", Description = "Light protective armor.", Kind = "Armor", Slot = "armor", Class = "Any", Defense = 2, Price = 18, HallLevel = 2},
		timber = {Name = "Timber", Description = "Material for building and crafting.", Kind = "Material", Tradable = true},
	}}
	local data: any = {gold = 80, hallLevel = 2, quests = {firstClears = {}, active = nil},
		character = {classId = "Warrior", equipmentSlots = {weapon = "playerSword"}, stats = {Health = 63, Attack = 19, Defense = 4}},
		adventurers = {["a:Warrior"] = {name = "Rowan", classId = "Warrior", rank = "F", equipmentSlots = {weapon = "rowanSword"}, stats = {Health = 58, Attack = 16, Defense = 3}}},
		inventory = {equipment = {playerSword = {definitionId = "training_sword"}, rowanSword = {definitionId = "training_sword"}, spareSword = {definitionId = "training_sword"}, bow = {definitionId = "short_bow"}, vest = {definitionId = "leather_vest"}}, stacks = {timber = 12}}}
	local mode = modes[modeIndex]
	if mode == "Empty" then data.inventory.equipment = {}; data.inventory.stacks = {}; data.character.equipmentSlots = {}; data.adventurers["a:Warrior"].equipmentSlots = {}; catalog.ItemOrder = {"training_sword", "short_bow", "leather_vest"} end
	if mode == "Incompatible" then data.inventory.equipment = {bow = {definitionId = "short_bow"}}; data.character.equipmentSlots = {}; data.adventurers["a:Warrior"].equipmentSlots = {} end
	if mode == "Capacity" then for i = 1, 45 do data.inventory.equipment["extra" .. i] = {definitionId = "training_sword"} end end
	if mode == "HallLocked" then data.hallLevel = 0 end
	if mode == "LongCopy" then
		catalog.Items.training_sword.Name = if language == "th" then "ดาบฝึกหัดสำหรับการตรวจสอบชื่ออุปกรณ์ที่ยาวมากเป็นพิเศษ" else "Training sword with an intentionally extended inspection name"
		catalog.Items.training_sword.Description = string.rep(if language == "th" then "ข้อความทดสอบรายละเอียดอุปกรณ์ที่ยาวเพื่อวัดการขยายความสูงและการเลื่อนอ่าน " else "Long synthetic item description to inspect wrapping, height growth and scrolling. ", 12)
	end
	return data, catalog
end
local function visible(object: GuiObject): boolean
	local lo, hi = object.AbsolutePosition, object.AbsolutePosition + object.AbsoluteSize
	local node: Instance? = object
	while node do
		if node:IsA("GuiObject") then
			if not node.Visible then return false end
			if node.ClipsDescendants then lo = Vector2.new(math.max(lo.X, node.AbsolutePosition.X), math.max(lo.Y, node.AbsolutePosition.Y)); hi = Vector2.new(math.min(hi.X, node.AbsolutePosition.X + node.AbsoluteSize.X), math.min(hi.Y, node.AbsolutePosition.Y + node.AbsoluteSize.Y)) end
		end
		node = node.Parent
	end
	return hi.X > lo.X and hi.Y > lo.Y
end
local function report()
	local current = canvas; if not current then return end
	local textCount, failed, scripts, models, parts = 0, 0, 0, 0, 0
	for _, object in ipairs(current:GetDescendants()) do
		if object:IsA("TextLabel") or object:IsA("TextButton") then
			if object.Text ~= "" then
				textCount += 1; if not object.TextFits then failed += 1 end
				print("INVENTORY_TEXT " .. Http:JSONEncode({name = object:GetFullName(), fits = object.TextFits, visible = visible(object), x = object.AbsolutePosition.X, y = object.AbsolutePosition.Y, w = object.AbsoluteSize.X, h = object.AbsoluteSize.Y, text = object.Text}))
			end
		elseif object:IsA("LuaSourceContainer") then scripts += 1
		elseif object:IsA("Model") then models += 1
		elseif object:IsA("BasePart") then parts += 1 end
	end
	print("INVENTORY_REVIEW " .. Http:JSONEncode({generation = generation, mode = modes[modeIndex], language = language, nominal = tostring(sizes[sizeIndex]), fit = fit, textCount = textCount, textNotFit = failed, clonedScripts = scripts, displayModels = models, displayParts = parts, intents = count, note = "TextFits does not prove visibility or full game acceptance"}))
end
local render: (boolean?) -> ()
render = function(reset: boolean?)
	generation += 1; local version = generation
	local previous = if scroll and not reset then scroll.CanvasPosition else Vector2.zero
	if canvas then canvas:Destroy() end
	local size = sizes[sizeIndex]
	local area = Instance.new("Frame"); area.Name = "SimulatedSafeArea"; area.Size = UDim2.fromOffset(size.X, size.Y)
	area.BackgroundColor3 = Theme.Colors.Background; area.ClipsDescendants = true; area.Parent = viewer; canvas = area
	local scale = Instance.new("UIScale"); scale.Scale = if fit then math.max(.01, math.min(1, viewer.AbsoluteSize.X / size.X, viewer.AbsoluteSize.Y / size.Y)) else 1; scale.Parent = area
	viewer.CanvasSize = UDim2.fromOffset(size.X * scale.Scale, size.Y * scale.Scale)
	label(area, "FixtureBanner", "ISOLATED INVENTORY · synthetic data / recorded intents only", 8, 0, size.X - 16, 56)
	local panel = Instance.new("Frame"); panel.Name = "ManagementPanel"; panel.AnchorPoint = Vector2.new(.5, 0); panel.Position = UDim2.new(.5, 0, 0, 64)
	panel.Size = UDim2.fromOffset(size.X - 16, size.Y - 72); panel.BackgroundColor3 = Theme.Colors.Surface; panel.ClipsDescendants = true; panel.Parent = area
	local cap = Instance.new("UISizeConstraint"); cap.MaxSize = Vector2.new(1000, 1000); cap.Parent = panel
	label(panel, "ManagementHeading", "Inventory · native review", 8, 0, math.min(size.X - 16, 1000) - 16, 56)
	local list = Instance.new("ScrollingFrame"); list.Name = "InventoryScroll"; list.Position = UDim2.fromOffset(8, 64)
	list.Size = UDim2.new(1, -16, 1, -108); list.AutomaticCanvasSize = Enum.AutomaticSize.Y; list.CanvasSize = UDim2.new()
	list.ScrollBarThickness = 5; list.BackgroundTransparency = 1; list.BorderSizePixel = 0; list.Parent = panel; scroll = list; ui.scroll = list
	local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 4); pad.PaddingRight = UDim.new(0, 4); pad.PaddingTop = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 4); pad.Parent = list
	local flow = Instance.new("UIListLayout"); flow.Padding = UDim.new(0, 12); flow.SortOrder = Enum.SortOrder.LayoutOrder; flow.Parent = list
	local data, catalog = state()
	renderer(data, catalog, modes[modeIndex] == "Busy"); list.CanvasPosition = previous
	notice.Text = string.format("%s | %s | %dx%d | %s\nRecorded intents: %d · %s\nPlayer = actual local avatar; Rowan = unavailable model fallback. Fit is not breakpoint/device evidence.", modes[modeIndex], language, size.X, size.Y, if fit then "FIT changes AbsoluteSize/breakpoints" else "1:1 · scroll outer viewport to inspect", count, lastAction)
	task.delay(1.3, function() if alive and version == generation then report() end end)
end
ui.T = function(key: string, values: any?) return Localization.translate(language, key, values) end
ui.render = render
ui.act = function(name: string, payload: any)
	count += 1; lastAction = name .. " " .. Http:JSONEncode(payload)
	print("INVENTORY_INTENT_ONLY " .. lastAction); render(false)
end
renderer = Inventory(ui)
local function control(parent: Instance, name: string, text: string, x: number, callback: () -> ())
	local button = Instance.new("TextButton"); button.Name = name; button.Text = text; button.Position = UDim2.fromOffset(x, 0)
	button.Size = UDim2.fromOffset(132, 48); button.Font = Theme.Fonts.Body; button.TextSize = 13; button.TextWrapped = true
	button.BackgroundColor3 = Theme.Colors.Primary; button.TextColor3 = Theme.Colors.Text; button.Parent = parent; button.Activated:Connect(callback)
end
local function controlRow(y: number): ScrollingFrame
	local row = Instance.new("ScrollingFrame"); row.Size = UDim2.new(1, 0, 0, 54); row.Position = UDim2.fromOffset(0, y)
	row.BackgroundTransparency = 1; row.ScrollBarThickness = 3; row.ScrollingDirection = Enum.ScrollingDirection.X; row.Parent = host; return row
end
local row = controlRow(0)
for i, size in ipairs(sizes) do control(row, "Size" .. size.X, tostring(size.X) .. "×" .. tostring(size.Y), (i - 1) * 138, function() sizeIndex = i; render(true) end) end
control(row, "LanguageEN", "EN", 414, function() language = "en"; render(false) end)
control(row, "LanguageTH", "TH", 552, function() language = "th"; render(false) end)
control(row, "FitToggle", "1:1 / Fit", 690, function() fit = not fit; render(true) end)
control(row, "ReportNow", "Log TextFits / rects", 828, report); row.CanvasSize = UDim2.fromOffset(966, 48)
local modeRow = controlRow(56)
for i, mode in ipairs(modes) do control(modeRow, "Mode" .. mode, mode, (i - 1) * 138, function() modeIndex = i; renderer = Inventory(ui); render(true) end) end
modeRow.CanvasSize = UDim2.fromOffset(#modes * 138, 48)
gui.Destroying:Connect(function() alive = false; generation += 1 end)
render(true)
