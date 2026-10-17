--!strict
-- Local presentation anchored to replicated route geometry; no movement authority.
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local Locale = require(game.ReplicatedStorage.Shared.Config.Localization)
local C = Theme.Colors
return function(gui: ScreenGui)
	local card = Instance.new("Frame"); card.Name = "NextWaypoint"; card.ZIndex = 5
	card.BackgroundColor3 = C.Background; card.BackgroundTransparency = .08; card.BorderSizePixel = 0; card.Visible = false; card.Parent = gui
	local rim = Instance.new("UIStroke"); rim.Color = C.Gold; rim.Thickness = 1; rim.Parent = card
	local rail = Instance.new("Frame"); rail.Size = UDim2.new(0, 3, 1, -12); rail.Position = UDim2.fromOffset(0, 6)
	rail.BackgroundColor3 = C.Focus; rail.BorderSizePixel = 0; rail.ZIndex = 6; rail.Parent = card
	local function text(name: string, size: number, color: Color3): TextLabel
		local label = Instance.new("TextLabel"); label.Name = name; label.BackgroundTransparency = 1; label.TextColor3 = color
		label.Font = Theme.Fonts.Body; label.TextSize = size; label.TextWrapped = true; label.TextTruncate = Enum.TextTruncate.AtEnd
		label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 6; label.Parent = card; return label
	end
	local step = text("NextInstruction", 15, C.Text)
	local destination = text("FinalDestination", 12, C.Gold)
	local distanceLabel = text("NextDistance", 12, C.Focus)
	local marker = Instance.new("BillboardGui"); marker.Name = "WaypointBeacon"; marker.Size = UDim2.fromOffset(52, 68)
	marker.AlwaysOnTop = false; marker.MaxDistance = 180; marker.Enabled = false; marker.Parent = gui
	local diamond = Instance.new("Frame"); diamond.Name = "GoldMedallion"; diamond.AnchorPoint = Vector2.new(.5, .5)
	diamond.Position = UDim2.fromScale(.5, .32); diamond.Size = UDim2.fromOffset(24, 24); diamond.Rotation = 45
	diamond.BackgroundColor3 = C.Background; diamond.BorderSizePixel = 0; diamond.Parent = marker
	local outline = Instance.new("UIStroke"); outline.Color = C.Gold; outline.Thickness = 2; outline.Parent = diamond
	local gem = Instance.new("Frame"); gem.Name = "AzureCenter"; gem.AnchorPoint = Vector2.new(.5, .5)
	gem.Position = UDim2.fromScale(.5, .5); gem.Size = UDim2.fromOffset(9, 9); gem.BackgroundColor3 = C.Focus; gem.BorderSizePixel = 0; gem.Parent = diamond
	-- Native bars form a downward chevron without relying on font glyph coverage.
	for index, rotation in ipairs({45, -45}) do
		local bar = Instance.new("Frame"); bar.Name = "GroundPointer" .. index
		bar.AnchorPoint = Vector2.new(.5, .5); bar.Position = UDim2.fromOffset(if index == 1 then 21 else 31, 47)
		bar.Size = UDim2.fromOffset(16, 3); bar.Rotation = rotation
		bar.BackgroundColor3 = C.Gold; bar.BorderSizePixel = 0; bar.Parent = marker
	end
	local function resize()
		local short = gui.AbsoluteSize.Y < 450
		-- Short landscape uses the right column: the compact actor roster occupies
		-- x8..290 at y64, so a centered card would cover companion selection.
		local narrow = gui.AbsoluteSize.X < 600 or short
		card.AnchorPoint = if narrow then Vector2.new(1, 0) else Vector2.new(.5, 0)
		card.Position = if narrow then UDim2.new(1, -8, 0, 112) else UDim2.new(.5, 0, 0, 66)
		card.Size = UDim2.fromOffset(if narrow then 130 else 260, if short then 56 else 96)
		step.Position = UDim2.fromOffset(10, 6); step.Size = UDim2.new(1, -20, 0, if short then 42 else 44)
		step.TextSize = if narrow then 13 else 15
		destination.Position = UDim2.fromOffset(10, 50); destination.Size = UDim2.new(1, -20, 0, 20); destination.Visible = not short
		distanceLabel.Position = UDim2.fromOffset(10, 72); distanceLabel.Size = UDim2.new(1, -20, 0, 18); distanceLabel.Visible = not short
	end
	local connection = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
	local destroyed = false
	local function destroy()
		if destroyed then return end; destroyed = true; connection:Disconnect(); card:Destroy(); marker:Destroy()
	end
	local lifetime = gui.Destroying:Connect(destroy)
	resize()
	return {update = function(target: any, distance: number?, unavailable: boolean, language: string)
		if destroyed then return end
		card.Visible = target ~= nil or unavailable; marker.Enabled = false; marker.Adornee = nil :: any
		if not card.Visible then return end
		local T = function(key: string, values: any?) return Locale.translate(language, key, values) end
		if unavailable then
			step.Text = T("Route unavailable"); destination.Text = T("Follow the quest instructions"); distanceLabel.Text = ""; return
		end
		local destinationHint = target.guidance == "destination"
		step.Text = T(if destinationHint then "Destination direction — follow paths" else target.stepLabel or "Next waypoint")
		destination.Text = T(target.destinationName or target.name)
		distanceLabel.Text = if distance then T("{distance} studs", {distance = distance}) else ""
		local anchor = target.anchor
		if not destinationHint and anchor and anchor.Parent and type(target.y) == "number" then
			marker.Adornee = anchor
			marker.StudsOffsetWorldSpace = Vector3.new(target.x, target.y + 3.5, target.z) - anchor.Position
			marker.Enabled = true
		end
	end, directionPosition = function(): UDim2 return UDim2.new(1, -90, 0, 216) end,
	destroy = function() lifetime:Disconnect(); destroy() end}
end
