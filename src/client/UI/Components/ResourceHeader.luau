--!strict
-- Native resource plaque and menu control. Values and actions belong to SliceUI.
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local Ornament = require(script.Parent.RegalOrnament)
local Button = require(script.Parent.GuildborneButton)
local Layout = require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
local C = Theme.Colors
local Header = {}

function Header.new(gui: ScreenGui)
	local root = Instance.new("Frame")
	root.Name = "ResourceHeader"; root.BackgroundTransparency = 1; root.BorderSizePixel = 0
	root.Size = UDim2.new(1, 0, 0, 58); root.Active = false; root.ZIndex = 1; root.Parent = gui
	local plaque = Instance.new("Frame")
	plaque.Name = "ResourcePlaque"; plaque.BackgroundColor3 = C.Background; plaque.BorderSizePixel = 0
	plaque.Active = false; plaque.Parent = root
	local rim = Instance.new("UIStroke"); rim.Color = C.Gold; rim.Transparency = .2; rim.Parent = plaque
	local gradient = Instance.new("UIGradient"); gradient.Rotation = 90
	gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(137, 151, 174)); gradient.Parent = plaque
	local inset = Instance.new("Frame"); inset.Name = "InsetEngraving"; inset.BackgroundTransparency = 1
	inset.Position = UDim2.fromOffset(4, 4); inset.Size = UDim2.new(1, -8, 1, -8); inset.Active = false; inset.Parent = plaque
	local innerRim = Instance.new("UIStroke"); innerRim.Color = C.GoldShadow; innerRim.Parent = inset
	Ornament.corner(plaque, UDim2.fromOffset(1, 1), 0, true)
	Ornament.corner(plaque, UDim2.new(1, -31, 1, -31), 180, true)
	local coin = Instance.new("Frame"); coin.Name = "GoldMedallion"; coin.Size = UDim2.fromOffset(28, 28)
	coin.Position = UDim2.fromOffset(16, 12); coin.BackgroundColor3 = C.GoldShadow; coin.BorderSizePixel = 0; coin.Active = false; coin.Parent = plaque
	local round = Instance.new("UICorner"); round.CornerRadius = UDim.new(1, 0); round.Parent = coin
	local coinRim = Instance.new("UIStroke"); coinRim.Color = C.Gold; coinRim.Thickness = 2; coinRim.Parent = coin
	local stamp = Instance.new("Frame"); stamp.Name = "CoinStamp"; stamp.Size = UDim2.fromOffset(10, 10)
	stamp.AnchorPoint = Vector2.new(.5, .5); stamp.Position = UDim2.fromScale(.5, .5); stamp.Rotation = 45
	stamp.BackgroundColor3 = C.GoldLight; stamp.BorderSizePixel = 0; stamp.Active = false; stamp.Parent = coin
	local function label(name: string, color: Color3, minimum: number, maximum: number): TextLabel
		local text = Instance.new("TextLabel"); text.Name = name; text.BackgroundTransparency = 1
		text.Font = Theme.Fonts.Body; text.TextColor3 = color; text.TextXAlignment = Enum.TextXAlignment.Left
		-- Native Roblox disables TextScaled when TextWrapped is set false later.
		-- Set an explicit fallback size and keep the coupled fitting flags enabled.
		text.TextSize = maximum; text.TextWrapped = true; text.TextScaled = true
		text.Text = ""; text.Parent = plaque
		local size = Instance.new("UITextSizeConstraint"); size.MinTextSize = minimum; size.MaxTextSize = maximum; size.Parent = text
		return text
	end
	local value = label("GoldValue", C.Text, 12, 22)
	local caption = label("ResourceCaption", C.Gold, 11, 13)
	local loading = label("ResourceLoading", C.Gold, 12, 16)
	loading.TextWrapped = true; loading.Position = UDim2.fromOffset(12, 6); loading.Size = UDim2.new(1, -24, 1, -12)
	local menu = Button.create(root, {name="GuildMenuToggle", primary=true})
	local menuPadding: UIPadding? = nil
	for _, child in ipairs(menu.button:GetChildren()) do
		if child.ClassName == "UIPadding" then menuPadding = child :: UIPadding end
	end
	local hasValue, destroyed = false, false
	local function resize()
		if destroyed then return end
		local layout = Layout(gui.AbsoluteSize.X, gui.AbsoluteSize.Y)
		local a, b = layout.resourceRect, layout.menuRect
		plaque.Position = UDim2.fromOffset(a.x, a.y); plaque.Size = UDim2.fromOffset(a.w, a.h)
		menu.button.Position = UDim2.fromOffset(b.x, b.y); menu.button.Size = UDim2.fromOffset(b.w, b.h)
		menu.button.TextSize = if layout.trackerWide then 16 else 14
		if menuPadding then
			menuPadding.PaddingLeft = UDim.new(0, if layout.trackerWide then 18 else 8)
			menuPadding.PaddingRight = UDim.new(0, 22)
		end
		local decorated = a.w >= 220
		coin.Visible = decorated and hasValue
		local left = if decorated then 56 else 12
		value.Position = UDim2.fromOffset(left, 6); value.Size = UDim2.new(1, -left-12, 0, 24)
		caption.Position = UDim2.fromOffset(left, 30); caption.Size = UDim2.new(1, -left-12, 0, 16)
	end
	local resized = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
	root.Destroying:Connect(function() destroyed = true; resized:Disconnect() end)
	resize()
	return {
		button = menu.button,
		update = function(goldValue: string?, resourceCaption: string, loadingText: string)
			if destroyed then return end
			hasValue = goldValue ~= nil
			value.Text = goldValue or ""; caption.Text = resourceCaption; loading.Text = loadingText
			value.Visible = hasValue; caption.Visible = hasValue; loading.Visible = not hasValue
			resize()
		end,
		destroy = function() root:Destroy() end,
	}
end
return Header
