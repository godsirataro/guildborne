--!strict
local Theme = require(script.Parent.DesignSystem.Theme)
local Asset = require(script.Parent.Components.QualityAsset)
local C = Theme.Colors
return function(gui: ScreenGui)
	local button = Instance.new("TextButton"); button.Name = "QuestTracker"; button.Text = ""
	-- Root ordering wins over the HUD's whole subtree under Sibling ZIndexBehavior.
	-- Keep below Title (20) and world notices (30); SliceUI hides this for menus.
	button.ZIndex = 5
	button.BackgroundColor3 = C.Background; button.BorderSizePixel = 0; button.AutoButtonColor = true; button.Parent = gui
	local stroke = Instance.new("UIStroke"); stroke.Color = C.Gold; stroke.Transparency = .3; stroke.Parent = button
	local border = Asset.create(button, "panelBorder"); border.ZIndex = 1
	local icon = Asset.create(button, "questIcon", UDim2.fromOffset(20, 26)); icon.ImageColor3 = C.Gold
	icon.Position = UDim2.fromOffset(12, 12)
	icon.ZIndex = 2
	local heading = Instance.new("TextLabel"); heading.Name = "TrackerHeading"; heading.BackgroundTransparency = 1
	heading.Font = Theme.Fonts.Body; heading.TextSize = 12; heading.TextColor3 = C.Gold; heading.TextXAlignment = Enum.TextXAlignment.Left
	heading.Position = UDim2.fromOffset(42, 10); heading.Size = UDim2.new(1, -54, 0, 20); heading.Parent = button
	heading.ZIndex = 3
	local objective = Instance.new("TextLabel"); objective.Name = "TrackerObjective"; objective.BackgroundTransparency = 1
	objective.Font = Theme.Fonts.Body; objective.TextColor3 = C.Text; objective.TextWrapped = true; objective.TextTruncate = Enum.TextTruncate.AtEnd
	objective.TextXAlignment = Enum.TextXAlignment.Left; objective.Parent = button
	objective.ZIndex = 3
	local track = Instance.new("Frame"); track.Name = "TrackedProgress"; track.BorderSizePixel = 0; track.BackgroundColor3 = C.Border
	track.Position = UDim2.new(0, 12, 1, -10); track.Size = UDim2.new(1, -24, 0, 3); track.Parent = button
	track.ZIndex = 2
	local fill = Instance.new("Frame"); fill.BorderSizePixel = 0; fill.BackgroundColor3 = C.Gold; fill.Parent = track
	fill.ZIndex = 2
	local wide = false
	local function resize()
		wide = gui.AbsoluteSize.X >= 900 and gui.AbsoluteSize.Y >= 560
		local width = gui.AbsoluteSize.X
		-- SliceUI HUD: x=8,width=w-16; gold x=12,width=.3*(w-16)-8;
		-- menu occupies [w-108,w-12]. Reserve eight pixels on both sides.
		local left = math.max(width * .32, width * .3 + 15.2)
		local right = math.min(width * .72 - 12, width - 116)
		button.AnchorPoint = if wide then Vector2.new(1, 0) else Vector2.zero
		button.Position = if wide then UDim2.new(1, -8, 0, 70) else UDim2.fromOffset(left, 10)
		button.Size = if wide then UDim2.fromOffset(300, 96) else UDim2.fromOffset(math.max(44, right - left), 44)
		heading.Visible = wide; icon.Visible = wide
		objective.Position = if wide then UDim2.fromOffset(42, 32) else UDim2.fromOffset(6, 3)
		objective.Size = if wide then UDim2.new(1, -54, 0, 48) else UDim2.new(1, -12, 1, -8)
		-- Keep two readable lines on medium screens without squeezing phone controls.
		objective.TextSize = if wide then 15 elseif right - left >= 200 then 14 else 12
	end
	local connection = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
	button.Destroying:Connect(function() connection:Disconnect() end); resize()
	return {button = button, update = function(state: any, title: string, value: string, enabled: boolean)
		button.Active = enabled; button.Selectable = enabled; heading.Text = title; objective.Text = value
		track.Visible = state ~= nil and type(state.progress) == "number" and type(state.count) == "number" and state.count > 0
		fill.Size = UDim2.fromScale(if track.Visible then math.clamp(state.progress / state.count, 0, 1) else 0, 1)
		fill.BackgroundColor3 = if state and state.ready then C.Focus else C.Gold
	end}
end
