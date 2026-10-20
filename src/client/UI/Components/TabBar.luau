--!strict
local Button = require(script.Parent.GuildborneButton)
export type Tab = { id: string, label: string }
local TabBar = {}
function TabBar.create(parent: Instance, tabs: {Tab}, onSelected: (string) -> ())
	local frame = Instance.new("ScrollingFrame")
	frame.Name = "GuildborneTabBar"; frame.Size = UDim2.new(1, 0, 0, 56)
	frame.BackgroundTransparency = 1; frame.BorderSizePixel = 0; frame.ScrollBarThickness = 3
	frame.ScrollingDirection = Enum.ScrollingDirection.X; frame.CanvasSize = UDim2.new()
	frame.AutomaticCanvasSize = Enum.AutomaticSize.X; frame.Parent = parent
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal; layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = frame
	local buttons: {[string]: Button.Handle} = {}
	local destroyed = false
	local function select(id: string)
		local target = buttons[id]
		if destroyed or not target or target.button:GetAttribute("Disabled") then return end
		for key, handle in pairs(buttons) do handle.setSelected(key == id) end
	end
	for index, tab in ipairs(tabs) do
		assert(buttons[tab.id] == nil, "Duplicate tab ID: " .. tab.id)
		local handle = Button.create(frame, { name = tab.id, text = tab.label, size = UDim2.fromOffset(148, 48), onActivated = function() select(tab.id); onSelected(tab.id) end })
		handle.button.LayoutOrder = index; buttons[tab.id] = handle
	end
	return {
		frame = frame, select = select,
		setDisabled = function(id: string, disabled: boolean) local handle = buttons[id]; if handle then handle.setDisabled(disabled) end end,
		destroy = function() if destroyed then return end; destroyed = true; for _, handle in pairs(buttons) do handle.destroy() end; table.clear(buttons); frame:Destroy() end,
	}
end
return TabBar
