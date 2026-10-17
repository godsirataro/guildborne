--!strict
-- Local presentation anchored to replicated route geometry; no movement authority.
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local Locale = require(game.ReplicatedStorage.Shared.Config.Localization)
local CombatLayout = require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
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
	local compass = Instance.new("Frame"); compass.Name = "DestinationCompass"; compass.BackgroundTransparency = 1
	compass.AnchorPoint = Vector2.new(.5, .5); compass.Position = UDim2.new(1, -22, .5, 0)
	compass.Size = UDim2.fromOffset(24, 24); compass.ZIndex = 6; compass.Visible = false; compass.Parent = card
	local function arrowBar(name: string, x: number, y: number, width: number, height: number, rotation: number)
		local bar = Instance.new("Frame"); bar.Name = name; bar.AnchorPoint = Vector2.new(.5, .5)
		bar.Position = UDim2.fromOffset(x, y); bar.Size = UDim2.fromOffset(width, height); bar.Rotation = rotation
		bar.BackgroundColor3 = C.Gold; bar.BorderSizePixel = 0; bar.ZIndex = 7; bar.Parent = compass
	end
	arrowBar("Shaft", 12, 13, 3, 16, 0)
	arrowBar("LeftWing", 8, 8, 12, 3, -45); arrowBar("RightWing", 16, 8, 12, 3, 45)
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
	local layoutAvailable, cardWanted = true, false
	local function resize()
		local short = gui.AbsoluteSize.Y < 450
		-- Short landscape uses the right column: the compact actor roster occupies
		-- x8..290 at y64, so a centered card would cover companion selection.
		local narrow = gui.AbsoluteSize.X < 600 or short
		card.AnchorPoint = if narrow then Vector2.new(1, 0) else Vector2.new(.5, 0)
		local combat = CombatLayout(gui.AbsoluteSize.X, gui.AbsoluteSize.Y)
		local padBottom = if combat.topAligned then combat.padTop + combat.padHeight else gui.AbsoluteSize.Y / 2 + combat.padHeight / 2
		local cardY = math.max(112, padBottom + 8)
		card.Position = if narrow then UDim2.new(1, -8, 0, cardY) else UDim2.new(.5, 0, 0, 66)
		card.Size = UDim2.fromOffset(if narrow and gui.AbsoluteSize.X < 600 then 130 else 260, if short then 56 else 96)
		local w, h = gui.AbsoluteSize.X, gui.AbsoluteSize.Y
		local bw, bh = if narrow and gui.AbsoluteSize.X < 600 then 130 else 260, if short then 56 else 96
		local rosterRight = 8 + combat.selectionWidth
		local blocked = {
			{x=8,y=64,w=combat.selectionWidth,h=combat.selectionHeight},
			{x=w-138,y=60,w=130,h=48},
			{x=w-8-combat.padWidth,y=padBottom-combat.padHeight,w=combat.padWidth,h=combat.padHeight},
			{x=w*(1-combat.healthScale)/2,y=h-combat.healthBottom-combat.healthHeight,w=w*combat.healthScale,h=combat.healthHeight},
			{x=(w-math.min(w*.9,360))/2,y=h-combat.ordersBottom-44,w=math.min(w*.9,360),h=44},
		}
		local candidates = {
			{x=if narrow then w-8-bw else (w-bw)/2,y=if narrow then cardY else 66},
			{x=rosterRight+8,y=112},
			{x=8,y=64+combat.selectionHeight+8},
		}
		layoutAvailable = false
		for _, p in ipairs(candidates) do
			local clear = p.x >= 8 and p.y >= 60 and p.x+bw <= w-8 and p.y+bh <= h-8
			for _, b in ipairs(blocked) do
				if p.x < b.x+b.w and p.x+bw > b.x and p.y < b.y+b.h and p.y+bh > b.y then clear = false end
			end
			if clear then
				card.AnchorPoint = Vector2.zero; card.Position = UDim2.fromOffset(p.x,p.y); layoutAvailable = true; break
			end
		end
		-- Extremely short screens have no free lane: preserve controls and the map.
		card:SetAttribute("LayoutUnavailable", not layoutAvailable); card.Visible = cardWanted and layoutAvailable
		local inset = if compass.Visible then 52 else 20
		step.Position = UDim2.fromOffset(10, 6); step.Size = UDim2.new(1, -inset, 0, if short then 42 else 44)
		step.TextSize = if narrow then 13 else 15
		destination.Position = UDim2.fromOffset(10, 50); destination.Size = UDim2.new(1, -inset, 0, 20); destination.Visible = not short
		distanceLabel.Position = UDim2.fromOffset(10, 72); distanceLabel.Size = UDim2.new(1, -inset, 0, 18); distanceLabel.Visible = not short
	end
	local connection = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
	local destroyed = false
	local function destroy()
		if destroyed then return end; destroyed = true; connection:Disconnect(); card:Destroy(); marker:Destroy()
	end
	local lifetime = gui.Destroying:Connect(destroy)
	resize()
	return {update = function(target: any, distance: number?, unavailable: boolean, language: string, heading: number?)
		if destroyed then return end
		cardWanted = target ~= nil or unavailable; card.Visible = cardWanted and layoutAvailable
		marker.Enabled = false; marker.Adornee = nil :: any; compass.Visible = false
		if not cardWanted then resize(); return end
		local T = function(key: string, values: any?) return Locale.translate(language, key, values) end
		if target and target.kind=="Instruction" then
			step.Text=target.name;destination.Text="";distanceLabel.Text="";resize();return
		end
		if unavailable then
			step.Text = T("Route unavailable")
			destination.Text = T(if gui.AbsoluteSize.X < 600 then "See quest" else "Follow the quest instructions")
			distanceLabel.Text = ""; resize(); return
		end
		local destinationHint = target.guidance == "destination"
		if destinationHint and heading and heading == heading and math.abs(heading) < math.huge then
			compass.Rotation = heading; compass.Visible = true
		end
		step.Text = T(if destinationHint then (if gui.AbsoluteSize.X < 600 then "Bearing only\nUse paths" else "Destination direction — follow paths") else target.stepLabel or "Next waypoint")
		destination.Text = T(target.destinationName or target.name)
		distanceLabel.Text = if distance then T("{distance} studs", {distance = distance}) else ""
		local anchor = target.anchor
		if not destinationHint and anchor and anchor.Parent and type(target.y) == "number" then
			marker.Adornee = anchor
			marker.StudsOffsetWorldSpace = Vector3.new(target.x, target.y + 3.5, target.z) - anchor.Position
			marker.Enabled = true
		end
		resize()
	end,
	destroy = function() lifetime:Disconnect(); destroy() end}
end
