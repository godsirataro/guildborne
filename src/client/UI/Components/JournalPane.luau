--!strict
local State = require(game.ReplicatedStorage.Shared.Data.JournalViewState)
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local Panel = require(script.Parent.GuildbornePanel)
local Button = require(script.Parent.GuildborneButton)
local Asset = require(script.Parent.QualityAsset)
local C = Theme.Colors
return function(ui: any)
	local category, filter = "Main", "All"
	local selected: string? = nil
	local showList = true
	return function(data: any, catalog: any, busy: boolean)
		local T = ui.T
		local focused = ui.journalFocus and ui.journalFocus()
		if focused and catalog.Journal[focused] then selected = focused; category = catalog.Journal[focused].Category; filter = "All"; showList = false end
		local function flow(parent: Instance, gap: number)
			local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, gap); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = parent
		end
		local function label(parent: Instance, value: string, size: number, color: Color3): TextLabel
			local item = Instance.new("TextLabel"); item.Size = UDim2.new(1, 0, 0, size + 8); item.AutomaticSize = Enum.AutomaticSize.Y
			item.BackgroundTransparency = 1; item.Text = T(value); item.TextColor3 = color; item.TextSize = size
			item.Font = Theme.Fonts.Body; item.TextWrapped = true; item.TextXAlignment = Enum.TextXAlignment.Left; item.Parent = parent
			return item
		end
		local function action(parent: Instance, name: string, value: string, enabled: boolean, callback: () -> (), primary: boolean?): TextButton
			local handle = Button.create(parent, {name = name, text = T(value), primary = primary, onActivated = function() if not busy then callback() end end})
			handle.setDisabled(not enabled); return handle.button
		end
		local header = Instance.new("Frame"); header.Name = "JournalHeader"; header.Size = UDim2.new(1, -4, 0, 0)
		header.AutomaticSize = Enum.AutomaticSize.Y; header.BackgroundTransparency = 1; header.Parent = ui.scroll; flow(header, 8)
		local heading = label(header, "Quest journal", 28, C.Gold)
		heading.Font = if ui.language and ui.language() == "th" then Theme.Fonts.Body else Theme.Fonts.Heading
		local categories = Instance.new("Frame"); categories.Name = "JournalCategories"; categories.Size = UDim2.new(1, 0, 0, 48); categories.BackgroundTransparency = 1; categories.Parent = header
		for index, name in ipairs({"Main", "Side", "NPC"}) do
			local tab = action(categories, "Category_" .. name, ({Main = "Main quests", Side = "Side quests", NPC = "NPC quests"})[name], not busy, function() category = name; selected = nil; showList = true; ui.render(true) end, category == name)
			tab.Position = UDim2.new((index - 1) / 3, 0, 0, 0); tab.Size = UDim2.new(1 / 3, -4, 1, 0)
		end
		local labels = {All = "All tasks", Available = "Available", Active = "Active", Ready = "Ready to turn in", Claimed = "Claimed"}
		action(header, "JournalFilter", T("Quest view") .. ": " .. T(labels[filter]), not busy, function()
			filter = ({All = "Available", Available = "Active", Active = "Ready", Ready = "Claimed", Claimed = "All"})[filter]
			selected = nil; showList = true; ui.render(true)
		end)
		local ids: {string} = {}
		for _, id in ipairs(catalog.JournalOrder) do
			if catalog.Journal[id].Category == category and State.matches(State.describe(data, catalog, id), filter) then table.insert(ids, id) end
		end
		if not selected or not table.find(ids, selected) then selected = ids[1] end
		if #ids == 0 then
			require(script.Parent.Parent.EmptyState)(ui.scroll, "no_quests", T)
			if filter ~= "All" then action(header, "ResetJournalFilter", "Show all tasks", not busy, function() filter = "All"; ui.render(true) end) end
			return
		end
		local body = Instance.new("Frame"); body.Name = "JournalLayout"; body.Size = UDim2.new(1, -4, 0, 400); body.BackgroundTransparency = 1; body.Parent = ui.scroll
		local listPanel = Panel.create(body, {name = "QuestList"})
		local listContent = listPanel:FindFirstChild("Content") :: Frame
		listContent.Size = UDim2.new(1, -24, 0, 0); listContent.AutomaticSize = Enum.AutomaticSize.Y; flow(listContent, 8)
		for _, id in ipairs(ids) do
			local state = State.describe(data, catalog, id)
			local value = T(catalog.Journal[id].Name) .. "\n" .. T(if state.ready then "Ready to turn in" else state.state)
			local row = action(listContent, "SelectQuest_" .. id, value, not busy, function() selected = id; showList = false; ui.render(true) end, selected == id)
			row.Size = UDim2.new(1, 0, 0, 76); row.TextSize = 15
		end
		local id = selected :: string
		local def, state, task = catalog.Journal[id], State.describe(data, catalog, id), data.settlement.journal[id]
		local detail = Panel.create(body, {name = "Journal_" .. id})
		detail.BackgroundColor3 = C.Text
		local paper = Asset.create(detail, "parchment"); paper.ZIndex = 0
		local content = detail:FindFirstChild("Content") :: Frame
		content.Position = UDim2.fromOffset(20, 20); content.Size = UDim2.new(1, -40, 0, 0); content.AutomaticSize = Enum.AutomaticSize.Y; flow(content, 12)
		local back = action(content, "JournalBackToList", "All tasks", not busy, function() showList = true; ui.render(true) end)
		local title = label(content, def.Name, 27, C.Background)
		title.Font = if ui.language and ui.language() == "th" then Theme.Fonts.Body else Theme.Fonts.Heading
		label(content, def.Description, 16, C.Background)
		if def.NPC then label(content, T("Visit {npc} in the city to accept and turn in this quest.", {npc = T(def.NPC)}), 14, C.Background) end
		label(content, T(if state.ready then "Ready to turn in" else state.state) .. "  ·  " .. state.progress .. " / " .. def.Count, 16, C.Background).Name = "JournalProgress"
		local track = Instance.new("Frame"); track.Name = "ObjectiveProgress"; track.Size = UDim2.new(1, 0, 0, 6); track.BackgroundColor3 = C.Border; track.BorderSizePixel = 0; track.Parent = content
		local fill = Instance.new("Frame"); fill.Size = UDim2.fromScale(math.clamp(state.progress / math.max(1, def.Count), 0, 1), 1); fill.BackgroundColor3 = C.Primary; fill.BorderSizePixel = 0; fill.Parent = track
		label(content, "Reward", 18, C.Background)
		label(content, T("{amount} Gold", {amount = def.Gold}) .. "   ·   " .. def.XP .. " XP", 20, C.Background)
		if task and task.state == "Active" then
			action(content, "Track_" .. id, if ui.isTracked(id) then "Stop tracking" else "Track quest", not busy, function() ui.trackQuest(id) end)
			if def.Item then label(content, "Required items are consumed when you claim this reward.", 14, C.Background) end
			action(content, "Claim_" .. id, "Claim task reward", state.ready and not busy, function() ui.act("ClaimTask", {questId = id}) end, true)
		elseif not task then
			if state.locked then
				label(content, if state.releaseUnavailable then "Available after the Lv1–35 preview." elseif state.unavailable then "Regional encounters are not open yet." else T("Complete {quest} first", {quest = T(catalog.Journal[def.Requires].Name)}), 14, C.Background)
			end
			action(content, "Accept_" .. id, "Accept quest", not state.locked and not busy, function() ui.act("AcceptTask", {questId = id}) end, true)
		end
		local border = Asset.create(detail, "panelBorder"); border.ImageColor3 = C.Gold; border.ZIndex = 3
		local connections: {RBXScriptConnection} = {}
		local function resize()
			local narrow = body.AbsoluteSize.X < 620
			listPanel.Visible = not narrow or showList; detail.Visible = not narrow or not showList; back.Visible = narrow
			listPanel.Size = UDim2.new(if narrow then 1 else .35, 0, 0, listContent.AbsoluteSize.Y + 24)
			detail.Position = UDim2.fromScale(if narrow then 0 else .38, 0)
			detail.Size = UDim2.new(if narrow then 1 else .62, 0, 0, content.AbsoluteSize.Y + 40)
			body.Size = UDim2.new(1, -4, 0, if narrow then (if showList then listContent.AbsoluteSize.Y + 24 else content.AbsoluteSize.Y + 40) else math.max(listContent.AbsoluteSize.Y + 24, content.AbsoluteSize.Y + 40))
		end
		for _, target in ipairs({body, listContent, content}) do table.insert(connections, target:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)) end
		body.Destroying:Connect(function() for _, connection in ipairs(connections) do connection:Disconnect() end end)
		resize()
	end
end
