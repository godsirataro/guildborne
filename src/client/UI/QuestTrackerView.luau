--!strict
local Theme = require(script.Parent.DesignSystem.Theme)
local CombatLayout = require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
local Asset = require(script.Parent.Components.QualityAsset)
local C = Theme.Colors
return function(gui: ScreenGui)
	local button = Instance.new("TextButton"); button.Name = "QuestTracker"; button.Text = ""
	-- Root ordering wins over the HUD's whole subtree under Sibling ZIndexBehavior.
	-- Keep below Title (20) and world notices (30); SliceUI hides this for menus.
	button.ZIndex = 5
	button.BackgroundColor3 = C.Background; button.BorderSizePixel = 0; button.AutoButtonColor = false; button.Parent = gui
	local stroke = Instance.new("UIStroke"); stroke.Color = C.Gold; stroke.Transparency = .3; stroke.Parent = button
	stroke.Name = "TrackerRim"; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	-- Reference language: engraved navy card, burgundy title ribbon and a compass seal.
	-- These native details remain visible before any optional local image binding.
	local material = Instance.new("UIGradient"); material.Rotation = 90
	material.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(143, 159, 186)); material.Parent = button
	local function plate(name: string, position: UDim2, size: UDim2, color: Color3, z: number): Frame
		local part = Instance.new("Frame"); part.Name = name; part.Position = position; part.Size = size
		part.BackgroundColor3 = color; part.BorderSizePixel = 0; part.Active = false; part.ZIndex = z; part.Parent = button; return part
	end
	local ribbon = plate("QuestRibbon", UDim2.fromOffset(4, 4), UDim2.new(1, -8, 0, 28), C.Primary, 1)
	ribbon.BackgroundTransparency = .25
	plate("EngravedHighlight", UDim2.fromOffset(5, 3), UDim2.new(1, -10, 0, 1), C.GoldLight, 2).BackgroundTransparency = .45
	plate("EngravedShadow", UDim2.new(0, 5, 1, -4), UDim2.new(1, -10, 0, 1), C.GoldShadow, 2)
	local clasps: {Frame} = {}
	for _, right in ipairs({false, true}) do
		local cap = plate("CornerClasp", UDim2.new(if right then 1 else 0, if right then -6 else 6, 0, 6), UDim2.fromOffset(5, 5), C.Gold, 2)
		cap.AnchorPoint = Vector2.new(.5, .5); cap.Rotation = 45
		table.insert(clasps, cap)
	end
	local seal = plate("QuestSeal", UDim2.fromOffset(22, 25), UDim2.fromOffset(26, 26), C.Background, 2)
	seal.AnchorPoint = Vector2.new(.5, .5); seal.Rotation = 45
	local sealRim = Instance.new("UIStroke"); sealRim.Color = C.Gold; sealRim.Thickness = 2; sealRim.Parent = seal
	local nativeStem = plate("QuestMarkStem", UDim2.fromOffset(20, 14), UDim2.fromOffset(4, 14), C.GoldLight, 3)
	local nativeDot = plate("QuestMarkDot", UDim2.fromOffset(20, 31), UDim2.fromOffset(4, 4), C.GoldLight, 3)
	local checkLeft = plate("ReadyCheckLeft", UDim2.fromOffset(17, 26), UDim2.fromOffset(9, 3), C.Focus, 3)
	checkLeft.AnchorPoint = Vector2.new(.5, .5); checkLeft.Rotation = 45
	local checkRight = plate("ReadyCheckRight", UDim2.fromOffset(24, 23), UDim2.fromOffset(15, 3), C.Focus, 3)
	checkRight.AnchorPoint = Vector2.new(.5, .5); checkRight.Rotation = -45
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
	-- A compact quest clasp, not a scaled-down desktop card: fabric behind the
	-- seal, a fine rule below the heading, and a native chevron for opening details.
	local rule = plate("CompactHeadingRule", UDim2.fromOffset(42, 14), UDim2.new(1, -64, 0, 1), C.GoldShadow, 2)
	local openUpper = plate("OpenQuestUpper", UDim2.new(1, -12, .5, -3), UDim2.fromOffset(7, 2), C.Gold, 3)
	local openLower = plate("OpenQuestLower", UDim2.new(1, -12, .5, 2), UDim2.fromOffset(7, 2), C.Gold, 3)
	openUpper.Rotation = 45; openLower.Rotation = -45
	local disabledBar = plate("QuestDisabledMark", UDim2.fromOffset(15, 23), UDim2.fromOffset(12, 2), C.Muted, 4)
	local wide = false
	local compactHeading, micro = false, false
	local ready, enabledState, hovered, focused = false, false, false, false
	local function refreshDecoration()
		local emphasized = enabledState and (hovered or focused)
		stroke.Color = if not enabledState then C.Border elseif focused or ready then C.Focus else C.Gold
		stroke.Thickness = if emphasized then 2 else 1
		stroke.Transparency = if emphasized or ready then 0 else .3
		button.BackgroundColor3 = if emphasized then C.Surface else C.Background
		ribbon.Visible = true; seal.Visible = true
		for _, cap in ipairs(clasps) do cap.Visible = wide or compactHeading end
		icon.Visible = not micro and not ready and enabledState
		nativeStem.Visible = enabledState and not ready and (micro or not icon.IsLoaded); nativeDot.Visible = nativeStem.Visible
		checkLeft.Visible = ready; checkRight.Visible = checkLeft.Visible
		disabledBar.Visible = not enabledState and not ready
		sealRim.Color = if not enabledState then C.Muted elseif ready then C.Focus else C.Gold
		objective.TextColor3 = if enabledState then C.Text else C.Muted
		heading.TextColor3 = if not enabledState then C.Muted elseif ready then C.Focus else C.Gold
		rule.Visible = compactHeading; openUpper.Visible = compactHeading and enabledState; openLower.Visible = openUpper.Visible
	end
	local function resize()
		local layout = CombatLayout(gui.AbsoluteSize.X, gui.AbsoluteSize.Y)
		wide = layout.trackerWide
		local rect = layout.trackerRect
		local compactWidth = rect.w
		compactHeading = not wide and compactWidth >= 210
		micro = not wide and compactWidth < 170
		button.AnchorPoint = Vector2.zero
		button.Position = UDim2.fromOffset(rect.x, rect.y)
		button.Size = UDim2.fromOffset(rect.w, rect.h)
		heading.Visible = wide or compactHeading
		heading.Position = if wide then UDim2.fromOffset(42, 10) else UDim2.fromOffset(42, 0)
		heading.Size = if wide then UDim2.new(1, -54, 0, 20) else UDim2.new(1, -64, 0, 14)
		heading.TextTruncate = Enum.TextTruncate.AtEnd
		objective.Position = if wide then UDim2.fromOffset(42, 32) elseif compactHeading then UDim2.fromOffset(42, 15) elseif micro then UDim2.fromOffset(6, 7) else UDim2.fromOffset(34, 5)
		objective.Size = if wide then UDim2.new(1, -54, 0, 48) elseif compactHeading then UDim2.new(1, -64, 0, 32) elseif micro then UDim2.new(1, -12, 0, 38) else UDim2.new(1, -42, 0, 40)
		objective.TextSize = if wide then 15 elseif micro then 13 else 14
		-- Phone minimum retains both objective lines. A small crest interrupts the
		-- top engraving instead of consuming the already narrow text column.
		local sx, sy = if micro then 10 elseif wide or compactHeading then 22 else 16, if micro then 2 else 24
		local sealSize = if micro then 8 elseif wide then 26 elseif compactHeading then 22 else 18
		seal.Position = UDim2.fromOffset(sx, sy); seal.Size = UDim2.fromOffset(sealSize, sealSize)
		sealRim.Thickness = if wide then 2 else 1
		ribbon.Position = if wide then UDim2.fromOffset(4, 4) else UDim2.fromOffset(3, 3)
		ribbon.Size = if wide then UDim2.new(1, -8, 0, 28) elseif micro then UDim2.new(1, -6, 0, 3) else UDim2.fromOffset(if compactHeading then 32 else 26, 42)
		ribbon.BackgroundTransparency = if wide then .25 else .05
		nativeStem.Position = UDim2.fromOffset(sx - (if micro then 1 else 2), sy - (if micro then 3 else 10))
		nativeStem.Size = UDim2.fromOffset(if micro then 2 else 4, if micro then 4 else 12)
		nativeDot.Position = UDim2.fromOffset(sx - (if micro then 1 else 2), sy + (if micro then 3 else 5))
		nativeDot.Size = UDim2.fromOffset(if micro then 2 else 4, if micro then 2 else 4)
		checkLeft.Position = UDim2.fromOffset(sx - (if micro then 2 else 5), sy + 1)
		checkRight.Position = UDim2.fromOffset(sx + (if micro then 1 else 2), sy - 1)
		checkLeft.Size = UDim2.fromOffset(if micro then 4 else 9, if micro then 1 else 3)
		checkRight.Size = UDim2.fromOffset(if micro then 7 else 15, if micro then 1 else 3)
		disabledBar.Position = UDim2.fromOffset(sx - (if micro then 3 else 6), sy)
		disabledBar.Size = UDim2.fromOffset(if micro then 6 else 12, if micro then 1 else 2)
		icon.Position = UDim2.fromOffset(sx-8, sy-11); icon.Size = UDim2.fromOffset(16, 22)
		track.Position = if wide then UDim2.new(0, 12, 1, -10) else UDim2.new(0, if compactHeading then 42 else 6, 1, -3)
		track.Size = if wide then UDim2.new(1, -24, 0, 3) else UDim2.new(1, if compactHeading then -64 else -12, 0, 2)
		refreshDecoration()
	end
	local connections: {RBXScriptConnection} = {}
	local function connect(signal: RBXScriptSignal, callback: () -> ()) table.insert(connections, signal:Connect(callback)) end
	connect(gui:GetPropertyChangedSignal("AbsoluteSize"), resize)
	connect(icon:GetPropertyChangedSignal("IsLoaded"), refreshDecoration)
	connect(button.MouseEnter, function() hovered = true; refreshDecoration() end)
	connect(button.MouseLeave, function() hovered = false; refreshDecoration() end)
	connect(button.SelectionGained, function() focused = true; refreshDecoration() end)
	connect(button.SelectionLost, function() focused = false; refreshDecoration() end)
	button.Destroying:Connect(function() for _, connection in ipairs(connections) do connection:Disconnect() end end); resize()
	return {button = button, update = function(state: any, title: string, value: string, enabled: boolean)
		ready = state ~= nil and state.ready == true; enabledState = enabled
		button.Active = enabled; button.Selectable = enabled; heading.Text = title; objective.Text = value
		track.Visible = state ~= nil and type(state.progress) == "number" and type(state.count) == "number" and state.count > 0
			and state.progress == state.progress and state.count == state.count and math.abs(state.progress) < math.huge and state.count < math.huge
		fill.Size = UDim2.fromScale(if track.Visible then math.clamp(state.progress / state.count, 0, 1) else 0, 1)
		fill.BackgroundColor3 = if state and state.ready then C.Focus else C.Gold
		refreshDecoration()
	end}
end
