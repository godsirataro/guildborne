--!strict
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local AssetImage = require(script.Parent.Parent.AssetImage)
local Assets = require(game.ReplicatedStorage.Shared.Config.VisualAssets)
local Ornament = require(script.Parent.RegalOrnament)
export type Options = { size: UDim2?, logoId: string?, subtitle: string? }
local Header = {}
function Header.create(parent: Instance, options: Options?)
	local opts: Options = options or {}
	local frame = Instance.new("Frame")
	frame.Name = "GuildborneHeader"; frame.Size = opts.size or UDim2.new(1, 0, 0, 180)
	frame.BackgroundTransparency = 1; frame.Parent = parent
	local nativeBrand = Instance.new("Frame")
	nativeBrand.Name = "NativeBrandFallback"; nativeBrand.Size = UDim2.new(1, 0, 1, -38)
	nativeBrand.BackgroundTransparency = 1; nativeBrand.Active = false; nativeBrand.Parent = frame
	local crest = Ornament.crest(nativeBrand)
	crest.AnchorPoint = Vector2.new(.5, 0); crest.Position = UDim2.new(.5, 0, 0, 0)
	local wordmark = Instance.new("TextLabel")
	wordmark.Name = "LiveWordmark"; wordmark.Size = UDim2.new(1, -24, 1, -60)
	wordmark.Position = UDim2.fromOffset(12, 54); wordmark.BackgroundTransparency = 1
	wordmark.Font = Theme.Fonts.Heading; wordmark.Text = "GUILDBORNE"; wordmark.TextSize = 52
	wordmark.TextStrokeColor3 = Theme.Colors.GoldShadow; wordmark.TextStrokeTransparency = .15
	wordmark.TextColor3 = Theme.Colors.Text; wordmark.TextWrapped = false; wordmark.Parent = nativeBrand
	local lettering = Instance.new("UIGradient")
	lettering.Color = ColorSequence.new(Theme.Colors.Text, Theme.Colors.Gold); lettering.Rotation = 90; lettering.Parent = wordmark
	for _, side in ipairs({0, 1}) do
		local rule = Instance.new("Frame")
		rule.Name = "BrandRule"; rule.BorderSizePixel = 0; rule.BackgroundColor3 = Theme.Colors.Gold
		rule.Position = UDim2.new(if side == 0 then .12 else .56, 0, 1, -3)
		rule.Size = UDim2.new(.32, 0, 0, 1); rule.Active = false; rule.Parent = nativeBrand
	end
	local gem = Instance.new("Frame")
	gem.Name = "BrandGem"; gem.AnchorPoint = Vector2.new(.5, .5); gem.Position = UDim2.new(.5, 0, 1, -3)
	gem.Size = UDim2.fromOffset(6, 6); gem.Rotation = 45; gem.BackgroundColor3 = Theme.Colors.Gold; gem.BorderSizePixel = 0; gem.Active = false; gem.Parent = nativeBrand
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"; subtitle.Position = UDim2.new(0, 12, 1, -38); subtitle.Size = UDim2.new(1, -24, 0, 34)
	subtitle.BackgroundTransparency = 1; subtitle.Font = Theme.Fonts.Body; subtitle.TextSize = 16
	subtitle.TextColor3 = Theme.Colors.Text; subtitle.TextWrapped = true; subtitle.Text = opts.subtitle or ""; subtitle.Parent = frame
	local logo = AssetImage.create(frame, opts.logoId or Assets.Logo, UDim2.new(1, -24, 1, -38))
	local connections: {RBXScriptConnection} = {}
	if logo then
		logo.Name = "GuildborneLogo"; logo.AnchorPoint = Vector2.new(.5, 0); logo.Position = UDim2.new(.5, 0, 0, 0)
		-- Fit preserves the source aspect ratio; bounds avoid stealing subtitle space.
		local function loaded() nativeBrand.Visible = not logo.IsLoaded; wordmark.Visible = not logo.IsLoaded end
		table.insert(connections, logo:GetPropertyChangedSignal("IsLoaded"):Connect(loaded)); loaded()
	end
	local compactOverride: boolean? = nil
	local function responsive()
		local compact = if compactOverride ~= nil then compactOverride else frame.AbsoluteSize.X < 420
		-- The fixed Latin wordmark uses a built-in serif; Thai subtitle keeps the body font.
		wordmark.TextSize = if compact then 32 else 52
		wordmark.Position = UDim2.fromOffset(12, if compact then 48 else 54)
		wordmark.Size = UDim2.new(1, -24, 1, if compact then -52 else -60)
		crest.Size = UDim2.fromOffset(120, 64)
		subtitle.TextSize = if compact then 15 else 16
	end
	table.insert(connections, frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive))
	local function cleanup() for _, connection in ipairs(connections) do connection:Disconnect() end; table.clear(connections) end
	table.insert(connections, frame.Destroying:Connect(cleanup)); responsive()
	return {
		frame = frame, wordmark = wordmark, subtitle = subtitle,
		setSubtitle = function(value: string) subtitle.Text = value end,
		setCompact = function(value: boolean) compactOverride = value; responsive() end,
		destroy = function() cleanup(); frame:Destroy() end,
	}
end
return Header
