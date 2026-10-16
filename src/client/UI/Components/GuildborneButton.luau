--!strict
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
export type Options = { name: string?, text: string?, size: UDim2?, primary: boolean?, onActivated: (() -> ())? }
export type Handle = { button: TextButton, setDisabled: (boolean) -> (), setPending: (boolean) -> (), setSelected: (boolean) -> (), destroy: () -> () }
local Button = {}
function Button.create(parent: Instance, options: Options?): Handle
	local opts: Options = options or {}
	local button = Instance.new("TextButton")
	button.Name = opts.name or "GuildborneButton"; button.Text = opts.text or ""
	button.Size = opts.size or UDim2.new(1, 0, 0, Theme.MinimumTarget)
	button.BorderSizePixel = 0; button.AutoButtonColor = false
	button.Font = Theme.Fonts.Body; button.TextSize = 17; button.TextWrapped = true
	button.Parent = parent
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(182, 177, 177)); gradient.Rotation = 90; gradient.Parent = button
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 14); padding.PaddingRight = UDim.new(0, 14); padding.Parent = button
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 4); corner.Parent = button
	local border = Instance.new("UIStroke")
	border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; border.Parent = button
	local mark = Instance.new("Frame")
	mark.Name = "SelectedMark"; mark.AnchorPoint = Vector2.new(.5, 1); mark.Position = UDim2.fromScale(.5, 1)
	mark.Size = UDim2.new(1, -24, 0, 3); mark.BorderSizePixel = 0; mark.BackgroundColor3 = Theme.Colors.Gold; mark.Parent = button
	local disabled, pending, selected, hovered, focused, pressed, destroyed = false, false, false, false, false, false, false
	local connections: {RBXScriptConnection} = {}
	local function refresh()
		if destroyed then return end
		local enabled = not disabled and not pending
		button.Active = enabled; button.Selectable = enabled
		button:SetAttribute("Pending", pending); button:SetAttribute("Disabled", disabled); button:SetAttribute("Selected", selected)
		local base = if opts.primary or selected then Theme.Colors.Primary else Theme.Colors.Surface
		button.BackgroundColor3 = if not enabled then Theme.Colors.Surface else if pressed then base:Lerp(Color3.new(0, 0, 0), .22) else if hovered or focused then base:Lerp(Theme.Colors.Gold, .13) else base
		button.TextColor3 = if enabled then Theme.Colors.Text else Theme.Colors.Muted
		border.Color = if focused and enabled then Theme.Colors.Focus else Theme.Colors.Gold
		border.Thickness = if focused and enabled then 2 else 1
		border.Transparency = if enabled then (if selected or hovered or focused then 0 else .3) else .7
		mark.Visible = selected
	end
	local function connect(signal: RBXScriptSignal, callback: (...any) -> ())
		table.insert(connections, signal:Connect(callback))
	end
	connect(button.MouseEnter, function() hovered = true; refresh() end)
	connect(button.MouseLeave, function() hovered = false; pressed = false; refresh() end)
	connect(button.SelectionGained, function() focused = true; refresh() end)
	connect(button.SelectionLost, function() focused = false; pressed = false; refresh() end)
	connect(button.InputBegan, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA then pressed = true; refresh() end
	end)
	connect(button.InputEnded, function() pressed = false; refresh() end)
	connect(button.Activated, function()
		if destroyed or disabled or pending or not button.Active then return end
		local callback = opts.onActivated
		if callback then callback() end
	end)
	local function cleanup()
		if destroyed then return end
		destroyed = true
		for _, connection in ipairs(connections) do connection:Disconnect() end
		table.clear(connections)
	end
	connect(button.Destroying, cleanup)
	refresh()
	return {
		button = button,
		setDisabled = function(value: boolean) disabled = value; pressed = false; refresh() end,
		setPending = function(value: boolean) pending = value; pressed = false; refresh() end,
		setSelected = function(value: boolean) selected = value; refresh() end,
		destroy = function() cleanup(); button:Destroy() end,
	}
end
return Button
