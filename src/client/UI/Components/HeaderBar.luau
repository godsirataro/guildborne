--!strict
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local AssetImage = require(script.Parent.Parent.AssetImage)
local Assets = require(game.ReplicatedStorage.Shared.Config.VisualAssets)
local Symbol = require(script.Parent.Parent.SymbolIcon)
export type Options = { size: UDim2?, logoId: string?, subtitle: string? }
local Header = {}
function Header.create(parent: Instance, options: Options?)
	local opts: Options = options or {}
	local frame = Instance.new("Frame")
	frame.Name = "GuildborneHeader"; frame.Size = opts.size or UDim2.new(1, 0, 0, 134)
	frame.BackgroundTransparency = 1; frame.Parent = parent
	local wordmark = Instance.new("TextLabel")
	wordmark.Name = "LiveWordmark"; wordmark.Size = UDim2.new(1, -24, 1, -38)
	wordmark.Position = UDim2.fromOffset(12, 0); wordmark.BackgroundTransparency = 1
	wordmark.Font = Theme.Fonts.Heading; wordmark.Text = "GUILDBORNE"; wordmark.TextSize = 36
	wordmark.TextColor3 = Theme.Colors.Gold; wordmark.TextWrapped = true; wordmark.Parent = frame
	local ornament = Symbol(frame, "ui.brand.title_ornament", 20, Theme.Colors.Gold)
	if ornament then ornament.Name = "BrandOrnament"; ornament.Position = UDim2.new(.5, -10, 1, -46) end
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"; subtitle.Position = UDim2.new(0, 12, 1, -38); subtitle.Size = UDim2.new(1, -24, 0, 34)
	subtitle.BackgroundTransparency = 1; subtitle.Font = Theme.Fonts.Body; subtitle.TextSize = 16
	subtitle.TextColor3 = Theme.Colors.Text; subtitle.TextWrapped = true; subtitle.Text = opts.subtitle or ""; subtitle.Parent = frame
	local logo = AssetImage.create(frame, opts.logoId or Assets.Logo, UDim2.new(1, -24, 1, -38))
	local connections: {RBXScriptConnection} = {}
	if logo then
		logo.Name = "GuildborneLogo"; logo.AnchorPoint = Vector2.new(.5, 0); logo.Position = UDim2.new(.5, 0, 0, 0)
		-- Fit preserves the source aspect ratio; bounds avoid stealing subtitle space.
		local function loaded() wordmark.Visible = not logo.IsLoaded end
		table.insert(connections, logo:GetPropertyChangedSignal("IsLoaded"):Connect(loaded)); loaded()
	end
	local compactOverride: boolean? = nil
	local function responsive()
		local compact = if compactOverride ~= nil then compactOverride else frame.AbsoluteSize.X < 420
		wordmark.TextSize = if compact then 25 else 36
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
