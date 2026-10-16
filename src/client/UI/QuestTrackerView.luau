--!strict
local Theme = require(script.Parent.DesignSystem.Theme)
local Asset = require(script.Parent.Components.QualityAsset)
local C = Theme.Colors
return function(gui: ScreenGui)
	local button = Instance.new("TextButton"); button.Name = "QuestTracker"; button.Text = ""
	button.BackgroundColor3 = C.Background; button.BorderSizePixel = 0; button.AutoButtonColor = true; button.Parent = gui
	local stroke = Instance.new("UIStroke"); stroke.Color = C.Gold; stroke.Transparency = .3; stroke.Parent = button
	Asset.create(button, "panelBorder")
	local icon = Asset.create(button, "questIcon", UDim2.fromOffset(20, 26)); icon.ImageColor3 = C.Gold
	icon.Position = UDim2.fromOffset(12, 12)
	local heading = Instance.new("TextLabel"); heading.Name = "TrackerHeading"; heading.BackgroundTransparency = 1
	heading.Font = Theme.Fonts.Body; heading.TextSize = 12; heading.TextColor3 = C.Gold; heading.TextXAlignment = Enum.TextXAlignment.Left
	heading.Position = UDim2.fromOffset(42, 10); heading.Size = UDim2.new(1, -54, 0, 20); heading.Parent = button
	local objective = Instance.new("TextLabel"); objective.Name = "TrackerObjective"; objective.BackgroundTransparency = 1
	objective.Font = Theme.Fonts.Body; objective.TextColor3 = C.Text; objective.TextWrapped = true; objective.TextTruncate = Enum.TextTruncate.AtEnd
	objective.TextXAlignment = Enum.TextXAlignment.Left; objective.Parent = button
	local track = Instance.new("Frame"); track.Name = "TrackedProgress"; track.BorderSizePixel = 0; track.BackgroundColor3 = C.Border
	track.Position = UDim2.new(0, 12, 1, -10); track.Size = UDim2.new(1, -24, 0, 3); track.Parent = button
	local fill = Instance.new("Frame"); fill.BorderSizePixel = 0; fill.BackgroundColor3 = C.Gold; fill.Parent = track
	local wide = false
	local function resize()
		wide = gui.AbsoluteSize.X >= 900 and gui.AbsoluteSize.Y >= 560
		button.AnchorPoint = if wide then Vector2.new(1, 0) else Vector2.zero
		button.Position = if wide then UDim2.new(1, -8, 0, 70) else UDim2.new(.32, 0, 0, 10)
		button.Size = if wide then UDim2.fromOffset(300, 96) else UDim2.new(.40, -12, 0, 44)
		heading.Visible = wide; icon.Visible = wide
		objective.Position = if wide then UDim2.fromOffset(42, 32) else UDim2.fromOffset(6, 3)
		objective.Size = if wide then UDim2.new(1, -54, 0, 48) else UDim2.new(1, -12, 1, -8)
		objective.TextSize = if wide then 15 else 12
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
