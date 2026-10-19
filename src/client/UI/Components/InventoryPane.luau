--!strict
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local Panel = require(script.Parent.GuildbornePanel)
local Button = require(script.Parent.GuildborneButton)
local Slot = require(script.Parent.EquipmentSlot)
local Preview = require(script.Parent.InventoryActorPreview)
local AssetImage = require(script.Parent.Parent.AssetImage)
local C = Theme.Colors

local function frame(parent: Instance, name: string, x: number, y: number, w: number, h: number): Frame
	local result = Instance.new("Frame"); result.Name = name; result.BackgroundTransparency = 1
	result.Position = UDim2.fromOffset(x, y); result.Size = UDim2.fromOffset(w, h); result.Parent = parent
	return result
end
local function label(parent: Instance, name: string, text: string, x: number, y: number, w: number, h: number, heading: boolean?): TextLabel
	local result = Instance.new("TextLabel"); result.Name = name; result.BackgroundTransparency = 1
	result.Position = UDim2.fromOffset(x, y); result.Size = UDim2.fromOffset(w, h)
	result.Text = text; result.TextWrapped = true; result.TextXAlignment = Enum.TextXAlignment.Left
	result.TextYAlignment = Enum.TextYAlignment.Center; result.TextColor3 = if heading then C.GoldLight else C.Text
	-- The body face supports Thai; retain hierarchy through size and gold, not a Latin-only face.
	result.Font = Theme.Fonts.Body; result.TextSize = if heading then 21 else 14
	result.Parent = parent; return result
end
local function action(parent: Instance, name: string, text: string, x: number, y: number, w: number, callback: any, selected: boolean?, disabled: boolean?): TextButton
	local handle = Button.create(parent, {name = name, text = text, size = UDim2.fromOffset(w, 48), onActivated = callback})
	handle.button.Position = UDim2.fromOffset(x, y); handle.button.TextSize = 13
	handle.setSelected(selected == true); handle.setDisabled(disabled == true)
	return handle.button
end
local function strip(parent: Instance, name: string, x: number, y: number, w: number): ScrollingFrame
	local result = Instance.new("ScrollingFrame"); result.Name = name; result.BackgroundTransparency = 1; result.BorderSizePixel = 0
	result.Position = UDim2.fromOffset(x, y); result.Size = UDim2.fromOffset(w, 54)
	result.ScrollingDirection = Enum.ScrollingDirection.X; result.ScrollBarThickness = 3
	result.ScrollBarImageColor3 = C.Gold; result.CanvasSize = UDim2.new(); result.Parent = parent
	return result
end

return function(parent: Instance, model: any): Frame
	local root = Instance.new("Frame"); root.Name = "InventoryPane"; root.BackgroundTransparency = 1
	root.Size = UDim2.new(1, 0, 0, 600); root.Parent = parent
	local T = model.T or function(text: string): string return text end
	local categoryOpen = false
	local page = 1
	for i, item in ipairs(model.items or {}) do if item.selected then page = math.ceil(i / 24); break end end
	local destroyed = false
	local previewHandle: any = nil
	local renderedWidth = -1
	local drawing = false
	local drawPending = false
	local cancelled = {}
	local layoutConnections: {RBXScriptConnection} = {}
	local function fitRoot()
		if destroyed or drawing then return end
		local bottom = 0
		for _, child in ipairs(root:GetChildren()) do
			if child:IsA("GuiObject") then bottom = math.max(bottom, child.Position.Y.Offset + child.Size.Y.Offset) end
		end
		root.Size = UDim2.new(1, 0, 0, bottom + 12)
	end
	local function clearLayout()
		for _, connection in ipairs(layoutConnections) do connection:Disconnect() end
		table.clear(layoutConnections)
		if previewHandle then previewHandle.destroy(); previewHandle = nil end
	end
	local function alive()
		if destroyed then error(cancelled, 0) end
	end
	local draw: () -> ()
	local function drawPass()
		alive()
		clearLayout()
		for _, child in ipairs(root:GetChildren()) do child:Destroy() end
		renderedWidth = math.floor(root.AbsoluteSize.X)
		local w = math.max(220, renderedWidth)
		local phone, desktop = w < 600, w >= 900
		local heading = label(root, "InventoryHeading", model.title or T("Inventory"), 4, 0, w * .55, 30, true)
		if phone then heading.TextSize = 18 end
		local capacity = label(root, "Capacity", model.capacity or "", math.floor(w * .55), 0, math.floor(w * .45) - 4, 30)
		capacity.TextXAlignment = Enum.TextXAlignment.Right
		local y = 38
		if #(model.actors or {}) > 1 then
			local actors = strip(root, "ActorSelection", 4, 34, w - 8)
			local actorX = 0
			for _, actor in ipairs(model.actors) do
				action(actors, "Actor_" .. tostring(actor.id), actor.name, actorX, 0, if phone then 146 else 166, actor.onSelect, actor.selected, model.busy)
				actorX += if phone then 152 else 172
			end
			actors.CanvasSize = UDim2.fromOffset(actorX, 48)
			y = 94
		end
		local selected = model.selected or model.details
		if phone then
			for i, view in ipairs({"Items", "Loadout", "Details"}) do
				action(root, "View_" .. view, T(view), (i - 1) * (w / 3), y, w / 3 - 4, function() if model.onView then model.onView(view) end end, (model.view or "Items") == view, view == "Details" and not selected)
			end
			y += 56
		end
		local function loadout(x: number, top: number, width: number): number
			local shell = Panel.create(root, {name = "SelectedActorLoadout", size = UDim2.fromOffset(width, 620)})
			shell.Position = UDim2.fromOffset(x, top)
			local body = shell:FindFirstChild("Content") :: Frame
			local bw = width - 24
			label(body, "ActorName", model.actorName or "", 0, 0, bw, 44, true)
			local stageHeight = if desktop then 200 else if phone then 160 else 180
			local stage = frame(body, "ActorStage", 0, 44, bw, stageHeight)
			previewHandle = Preview(stage, {actorId = model.actorId, data = model.data, T = T})
			alive()
			local row = 44 + stageHeight + 4
			label(body, "ActorStats", model.stats or "", 0, row, bw, 48); row += 52
			for _, slot in ipairs(model.slots or {}) do
				local tile = Slot(body, slot, T); alive(); tile.Position = UDim2.fromOffset(0, row)
				row += tile.Size.Y.Offset + 8
			end
			for _, hint in ipairs({model.weaponHint or "", model.expeditionHint or ""}) do
				if hint ~= "" then label(body, "LoadoutHint", hint, 0, row, bw, 64); row += 68 end
			end
			shell.Size = UDim2.fromOffset(width, row + 24)
			return row + 24
		end
		local function details(x: number, top: number, width: number): number
			local shell = Panel.create(root, {name = "SelectedItemDetails", size = UDim2.fromOffset(width, 100)})
			shell.Position = UDim2.fromOffset(x, top)
			local body = shell:FindFirstChild("Content") :: Frame
			local bw, row = width - 24, 0
			if not selected then label(body, "SelectItemHint", T("Select an item to inspect its details."), 0, 0, bw, 64); return 100 end
			body.Size = UDim2.new(1, -24, 0, 0); body.AutomaticSize = Enum.AutomaticSize.Y
			local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 4)
			layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Parent = body
			local order = 0
			local function add(object: GuiObject)
				order += 1; object.LayoutOrder = order
			end
			if not desktop then
				add(action(body, "BackToItems", T("Back"), 0, 0, bw, model.onBack or function() model.onView("Items") end)); row += 52
			end
			local title = label(body, "ItemName", selected.name or "", 0, 0, bw, 60, true)
			title.AutomaticSize = Enum.AutomaticSize.Y; add(title); row += 64
			-- Keep available intents near the selected item's name, before long copy.
			for _, itemAction in ipairs(selected.actions or {}) do
				add(action(body, itemAction.name, itemAction.label, 0, 0, bw, itemAction.callback, false, model.busy or itemAction.enabled == false)); row += 52
			end
			if selected.definitionId then
				local art = AssetImage.item(body, selected.definitionId); alive()
				if art then add(art); row += 84 end
			end
			for _, key in ipairs({"description", "binding", "stats", "comparison", "assignment"}) do
				local value = selected[key]
				if value and value ~= "" then
					local h = if key == "description" or key == "comparison" then 84 else 64
					local copy = label(body, "Detail_" .. key, tostring(value), 0, 0, bw, h)
					copy.AutomaticSize = Enum.AutomaticSize.Y; add(copy); row += h + 4
				end
			end
			table.insert(layoutConnections, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				shell.Size = UDim2.fromOffset(width, math.max(80, layout.AbsoluteContentSize.Y) + 24); fitRoot()
			end))
			shell.Size = UDim2.fromOffset(width, row + 24); return row + 24
		end
		local function inventory(x: number, top: number, width: number): number
			local entries = model.filters or {}
			local categoryHeight = 48
			local filters = frame(root, "ItemCategories", x, top, width, categoryHeight)
			local function category(name: string, text: string, bx: number, by: number, bw: number, callback: any, selectedFilter: boolean?)
				local handle = Button.create(filters, {name = name, text = text, size = UDim2.fromOffset(bw, 48), quiet = true, onActivated = function()
					if destroyed or model.busy then return end
					callback()
				end})
				handle.button.Position = UDim2.fromOffset(bx, by); handle.button.TextSize = 16
				handle.setSelected(selectedFilter == true); handle.setDisabled(model.busy == true)
				return handle.button
			end
			if phone then
				local selectedLabel = T("All")
				for _, filter in ipairs(entries) do if filter.selected then selectedLabel = filter.label; break end end
				local picker = category("CategoryPicker", selectedLabel, 0, 0, width, function()
					categoryOpen = not categoryOpen; draw()
				end, categoryOpen)
				local padding = picker:FindFirstChildOfClass("UIPadding") :: UIPadding
				padding.PaddingRight = UDim.new(0, 36)
				-- Frame strokes avoid font-dependent glyphs. UIPadding ends the content
				-- 36px from the right; +16 places the chevron center 20px from that edge.
				local chevron = frame(picker, "CategoryChevron", 0, 0, 16, 16)
				chevron.AnchorPoint = Vector2.new(.5, .5)
				chevron.Position = UDim2.new(1, 16, .5, 0)
				chevron.Rotation = if categoryOpen then 180 else 0
				chevron.Active = false; chevron.Selectable = false
				for i, angle in ipairs({45, -45}) do
					local stroke = frame(chevron, "Stroke" .. i, if i == 1 then 5 else 11, 8, 9, 2)
					stroke.AnchorPoint = Vector2.new(.5, .5); stroke.Rotation = angle
					stroke.BackgroundTransparency = 0; stroke.BorderSizePixel = 0
					stroke.BackgroundColor3 = if model.busy then C.Muted else C.GoldLight
					stroke.Active = false; stroke.Selectable = false
				end
				if categoryOpen then
					for i, filter in ipairs(entries) do
						category("Filter_" .. tostring(filter.id), filter.label, 0, i * 52, width, function()
							categoryOpen = false; draw()
							if not destroyed and filter.onSelect then filter.onSelect() end
						end, filter.selected)
					end
					categoryHeight += #entries * 52
				end
			else
				-- Conservative whole-glyph allowance works for both English and Thai.
				-- At the production desktop cap the center pane is still narrow.
				local widest = 0
				for _, filter in ipairs(entries) do widest = math.max(widest, (utf8.len(filter.label) or #filter.label) * 16 + 24) end
				local columns = if #entries > 0 and width >= #entries * widest + (#entries - 1) * 4 then #entries else 3
				local tabWidth = math.floor((width - (columns - 1) * 4) / columns)
				local rows = math.max(1, math.ceil(#entries / columns))
				categoryHeight = rows * 52 - 4
				for i, filter in ipairs(entries) do
					category("Filter_" .. tostring(filter.id), filter.label, ((i - 1) % columns) * (tabWidth + 4), math.floor((i - 1) / columns) * 52, tabWidth, filter.onSelect or function() end, filter.selected)
				end
			end
			filters.Size = UDim2.fromOffset(width, categoryHeight)
			local controls = strip(root, "InventoryTools", x, top + categoryHeight + 8, width)
			local cx = 0
			for _, tool in ipairs({{name = "Shop", text = model.shopLabel, callback = model.onShop}, {name = "Sort", text = model.sortLabel, callback = model.onSort}, {name = "Compatible", text = model.compatibleLabel, callback = model.onCompatible}}) do
				if tool.callback then action(controls, tool.name, tool.text or T(tool.name), cx, 0, 140, tool.callback, false, model.busy); cx += 146 end
			end
			controls.CanvasSize = UDim2.fromOffset(cx, 48)
			local gridOffset = categoryHeight + 66
			local gridTop = top + gridOffset
			local items = model.items or {}
			local columns = math.max(2, math.floor(width / 116))
			local cellWidth = math.floor((width - (columns - 1) * 8) / columns)
			local grid = Instance.new("ScrollingFrame"); grid.Name = "ItemGrid"; grid.BorderSizePixel = 0; grid.BackgroundColor3 = C.Background
			grid.Position = UDim2.fromOffset(x, gridTop); grid.Size = UDim2.fromOffset(width, 294)
			grid.ScrollBarThickness = 4; grid.ScrollBarImageColor3 = C.Gold; grid.ScrollingDirection = Enum.ScrollingDirection.Y; grid.Parent = root
			local cellHeight = if phone then 116 else 138
			local layout = Instance.new("UIGridLayout"); layout.CellSize = UDim2.fromOffset(cellWidth, cellHeight); layout.CellPadding = UDim2.fromOffset(8, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = grid
			local start = (page - 1) * 24 + 1
			local count = 0
			for index = start, math.min(#items, start + 23) do
				local item = items[index]; count += 1
				local tile = action(grid, "Item_" .. tostring(item.id), "", 0, 0, cellWidth, item.onSelect, item.selected, model.busy)
				tile.LayoutOrder = index; tile:SetAttribute("ItemId", tostring(item.id))
				local padding = tile:FindFirstChildOfClass("UIPadding"); if padding then padding:Destroy() end
				if item.definitionId then local art = AssetImage.item(tile, item.definitionId); alive(); if art then art.Position = UDim2.fromOffset(math.max(0, (cellWidth - 80) / 2), 4) end end
				local itemLabel = label(tile, "ItemLabel", item.name or "", 6, 84, cellWidth - 12, cellHeight - 88)
				itemLabel.TextSize = if phone then 13 else 14; itemLabel.TextTruncate = Enum.TextTruncate.AtEnd
				if item.quantity then local quantity = label(tile, "Quantity", tostring(item.quantity), cellWidth - 44, 3, 38, 22); quantity.TextXAlignment = Enum.TextXAlignment.Right end
			end
			grid.CanvasSize = UDim2.fromOffset(0, math.ceil(count / columns) * (cellHeight + 8))
			if #items == 0 then label(root, "EmptyInventory", model.emptyText or T("No items match this filter."), x + 12, gridTop + 20, width - 24, 70) end
			local bottom = gridOffset + 294
			if #items > 24 then
				local pages = math.ceil(#items / 24)
				action(root, "PreviousItems", "\u{2039}", x, top + bottom + 6, 52, function() page -= 1; draw() end, false, page == 1)
				local pageLabel = label(root, "ItemPage", tostring(page) .. " / " .. tostring(pages), x + 58, top + bottom + 6, width - 116, 48); pageLabel.TextXAlignment = Enum.TextXAlignment.Center
				action(root, "NextItems", "\u{203A}", x + width - 52, top + bottom + 6, 52, function() page += 1; draw() end, false, page == pages)
				bottom += 60
			end
			return bottom
		end
		local height = 0
		if phone then
			if model.view == "Loadout" then height = loadout(4, y, w - 8)
			elseif model.view == "Details" and selected then height = details(4, y, w - 8)
			else
				-- Keep the first complete item row visible on phone while the
				-- category picker is collapsed, even with the companion selector.
				height = inventory(4, y, w - 8)
			end
		elseif desktop then
			local left = math.floor(w * .25); local center = math.floor(w * .43); local right = w - left - center - 24
			height = math.max(loadout(4, y, left), inventory(left + 12, y, center), details(left + center + 20, y, right))
		else
			local left = math.floor(w * .34); local right = w - left - 16
			if model.view == "Details" and selected then
				-- A selected card replaces the grid at the same scroll origin on
				-- medium displays, so selection never opens an off-screen detail.
				height = math.max(loadout(4, y, left), details(left + 12, y, right))
			else
				local inventoryHeight = inventory(left + 12, y, right)
				height = math.max(loadout(4, y, left), inventoryHeight)
			end
		end
		root.Size = UDim2.new(1, 0, 0, y + height + 12)
		-- SliceUI uses Sibling ordering. Explicit levels also keep these reusable
		-- components above their surfaces when mounted in a global-order fixture.
		local function layer(node: Instance, z: number)
			if node:IsA("GuiObject") then node.ZIndex = z end
			for _, child in ipairs(node:GetChildren()) do layer(child, if child:IsA("GuiObject") then z + 1 else z) end
		end
		layer(root, 20)
	end
	-- Asset-backed constructors may yield while their modules initialize. A size
	-- notification during that yield must request a later pass, never start a
	-- second writer in the same pane. Coalesce requests to the latest width/page.
	draw = function()
		if destroyed then return end
		drawPending = true
		if drawing then return end
		drawing = true
		repeat
			drawPending = false
			local ok, failure = pcall(drawPass)
			if not ok or destroyed then
				clearLayout()
				drawing = false; drawPending = false
				if not destroyed and failure ~= cancelled then
					for _, child in ipairs(root:GetChildren()) do child:Destroy() end
					error(failure, 0)
				end
				return
			end
		until not drawPending
		drawing = false
		fitRoot()
	end
	local sizeConnection = root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if math.floor(root.AbsoluteSize.X) ~= renderedWidth then draw() end
	end)
	root.Destroying:Connect(function()
		destroyed = true; drawPending = false; sizeConnection:Disconnect()
		clearLayout()
	end)
	draw()
	return root
end
