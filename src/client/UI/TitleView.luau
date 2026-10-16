--!strict
local Art = require(game.ReplicatedStorage.Shared.Config.Art)
local Assets = require(game.ReplicatedStorage.Shared.Config.VisualAssets)
local AssetImage = require(script.Parent.AssetImage)
local Localization = require(game.ReplicatedStorage.Shared.Config.Localization)
local Panel = require(script.Parent.Components.GuildbornePanel)
local Button = require(script.Parent.Components.GuildborneButton)
local Header = require(script.Parent.Components.HeaderBar)
local KeyboardFocus = require(script.Parent.Components.TitleKeyboardFocus)
local MenuRouter = require(script.Parent.MenuRouter)
local Vista = require(script.Parent.Components.TitleVista)
local Theme = require(script.Parent.DesignSystem.Theme)

-- Only presentation changes here: the existing profile, language and recovery
-- callbacks remain authoritative. Concept art supplies no currencies or actions.
return function(parent: ScreenGui, enter: () -> (), language: () -> ())
	local colors = Art.UI
	local languageCode = "en"
	local root = Instance.new("Frame")
	root.Name = "TitleScreen"; root.Size = UDim2.fromScale(1, 1)
	root.BackgroundColor3 = colors.Background; root.BorderSizePixel = 0; root.ZIndex = 20; root.Parent = parent
	MenuRouter.register("Title", root, true)
	KeyboardFocus.bind(root, parent, MenuRouter.focusCurrent)
	local backdrop = AssetImage.create(root, Assets.KeyArt, UDim2.fromScale(1, 1))
	if backdrop then backdrop.ScaleType = Enum.ScaleType.Crop; backdrop.ImageTransparency = .8 end
	local shell = Panel.create(root, {name = "TitleShell", size = UDim2.new(1, -24, 1, -24)})
	shell.AnchorPoint = Vector2.new(.5, .5); shell.Position = UDim2.fromScale(.5, .5)
	local limit = Instance.new("UISizeConstraint"); limit.MaxSize = Vector2.new(1320, 920); limit.Parent = shell
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "TitleContent"; scroll.Position = UDim2.fromOffset(16, 12); scroll.Size = UDim2.new(1, -32, 1, -24)
	scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = colors.Accent; scroll.CanvasSize = UDim2.new()
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.ScrollingDirection = Enum.ScrollingDirection.Y; scroll.Parent = shell
	local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, 16); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = scroll
	local header = Header.create(scroll, {size = UDim2.new(1, -8, 0, 190), logoId = Assets.Logo})
	header.frame.LayoutOrder = 0
	local columns = Instance.new("Frame")
	columns.Name = "TitleColumns"; columns.BackgroundTransparency = 1; columns.Size = UDim2.new(1, -8, 0, 400)
	columns.LayoutOrder = 1; columns.Parent = scroll
	local function column(name: string): Frame
		local frame = Instance.new("Frame"); frame.Name = name; frame.Size = UDim2.new(.48, 0, 0, 0)
		frame.AutomaticSize = Enum.AutomaticSize.Y; frame.BackgroundTransparency = 1; frame.Parent = columns
		local flow = Instance.new("UIListLayout"); flow.SortOrder = Enum.SortOrder.LayoutOrder; flow.Padding = UDim.new(0, 12); flow.Parent = frame
		return frame
	end
	local story = column("YourCompany")
	local rail = Panel.create(columns, {name = "EntryRail", size = UDim2.new(.34, 0, 0, 380)})
	local controls = column("EntryControls"); controls.Parent = rail
	controls.Position = UDim2.fromOffset(18, 18); controls.Size = UDim2.new(1, -36, 0, 0)
	local function label(container: Instance, name: string, size: number, height: number, order: number): TextLabel
		local item = Instance.new("TextLabel"); item.Name = name; item.Size = UDim2.new(1, 0, 0, height)
		item.AutomaticSize = Enum.AutomaticSize.Y; item.BackgroundTransparency = 1
		item.Font = Theme.Fonts.Body; item.TextSize = size; item.TextWrapped = true
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.TextColor3 = colors.Text; item.Text = ""; item.LayoutOrder = order; item.Parent = container
		return item
	end
	local stage = Vista.create(story); stage.frame.LayoutOrder = 0
	local companyHeading = label(story, "CompanyHeading", 28, 38, 1); companyHeading.TextColor3 = colors.Accent
	local company = label(story, "CompanyDescription", 16, 52, 2)
	local preview = require(script.Parent.CompanyPreview)(stage.heroHost)
	local companyViewport = stage.heroHost:FindFirstChild("CompanyPreview") :: GuiObject
	companyViewport.Size = UDim2.fromScale(1, 1); companyViewport.BackgroundTransparency = 1
	local chapter = label(controls, "ChapterHeading", 25, 38, -1); chapter.TextColor3 = colors.Accent
	local previewDestroyed = false
	local function destroyPreview()
		if not previewDestroyed then previewDestroyed = true; preview.destroy() end
	end
	local function leaveTitle()
		if not root.Visible then return end
		root.Visible = false; destroyPreview(); enter()
	end
	local status = label(controls, "ReadinessStatus", 15, 44, 0)
	local play = Button.create(controls, {name = "Continue", primary = true, size = UDim2.new(1, 0, 0, 72), onActivated = function()
		if root:GetAttribute("ProfileReady") then leaveTitle() end
	end})
	play.button.LayoutOrder = 1
	local settings = Button.create(controls, {name = "Language", onActivated = language}); settings.button.LayoutOrder = 2
	local presentation: any = nil
	local settingsToggle = Button.create(controls, {name = "Settings", onActivated = function()
		if presentation then presentation.frame.Visible = not presentation.frame.Visible end
	end}); settingsToggle.button.LayoutOrder = 3
	presentation = require(script.Parent.SettingsControls)(controls, function(key: string): string return Localization.translate(languageCode, key) end)
	presentation.frame.LayoutOrder = 4; presentation.frame.Visible = false
	presentation.frame:GetPropertyChangedSignal("Visible"):Connect(function()
		settingsToggle.setSelected(presentation.frame.Visible)
	end)
	local creditsLabel = label(controls, "CreditsText", 16, 100, 6); creditsLabel.Visible = false
	local credits = Button.create(controls, {name = "Credits", onActivated = function() creditsLabel.Visible = not creditsLabel.Visible end})
	credits.button.LayoutOrder = 5
	local alpha = label(scroll, "AlphaNotice", 13, 32, 2); alpha.TextColor3 = colors.Muted; alpha.TextXAlignment = Enum.TextXAlignment.Center
	local connections: {RBXScriptConnection} = {}
	local function responsive()
		local compact = scroll.AbsoluteSize.X < 680
		header.setCompact(compact); header.frame.Size = UDim2.new(1, -8, 0, if compact then 154 else 190)
		story.Size = UDim2.new(if compact then 1 else .62, 0, 0, 0)
		rail.Size = UDim2.new(if compact then 1 else .35, 0, 0, controls.AbsoluteSize.Y + 36)
		rail.Position = if compact then UDim2.fromOffset(0, 0) else UDim2.fromScale(.65, 0)
		story.Position = if compact then UDim2.fromOffset(0, controls.AbsoluteSize.Y + 60) else UDim2.fromOffset(0, 0)
		stage.frame.Size = UDim2.new(1, 0, 0, if compact then 240 else 350)
		columns.Size = UDim2.new(1, -8, 0, if compact then controls.AbsoluteSize.Y + story.AbsoluteSize.Y + 60 else math.max(controls.AbsoluteSize.Y + 36, story.AbsoluteSize.Y))
	end
	table.insert(connections, scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive))
	table.insert(connections, story:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive))
	table.insert(connections, controls:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive))
	root.Destroying:Connect(function()
		for _, connection in ipairs(connections) do connection:Disconnect() end
		table.clear(connections); destroyPreview()
	end)
	local api = {}
	function api.update(view: any)
		-- Existing recovery UI owns retry/degraded/lease-lost flows.
		if root.Visible and view and view.status ~= "Active" and view.status ~= "Loading" then leaveTitle() end
		local th = view and view.data and view.data.language == "th"
		languageCode = if th then "th" else "en"
		companyHeading.Font = if th then Theme.Fonts.Body else Theme.Fonts.Heading
		chapter.Font = if th then Theme.Fonts.Body else Theme.Fonts.Heading
		chapter.Text = if th then "การเดินทางบทใหม่" else "THE NEXT CHAPTER"
		settingsToggle.button.Text = Localization.translate(languageCode, "Settings"); presentation.refresh()
		settingsToggle.setSelected(presentation.frame.Visible)
		local ready = view ~= nil and view.data ~= nil and view.status == "Active"
		if root.Visible and view and view.data and not previewDestroyed then preview.update(view.data) end
		root:SetAttribute("ProfileReady", ready)
		play.setPending(not ready); settings.setDisabled(not ready)
		local novice = view and view.data and view.data.progression and view.data.progression.novice and view.data.progression.novice.claimed < 6
		play.button.Text = if ready then (if novice then (if th then "เริ่มเส้นทางนักผจญภัย" else "Begin your adventure") else (if th then "เข้าสู่กิลด์" else "Continue to your guild")) else (if th then "กำลังโหลดกิลด์…" else "Loading your guild…")
		status.Text = if ready then (if th then "พร้อมออกเดินทาง" else "Ready for your journey") else (if th then "กำลังรอข้อมูลผู้เล่นจากเซิร์ฟเวอร์…" else "Waiting for your player profile…")
		header.setSubtitle(if th then "ผจญภัย · ร่วมสร้าง · พิชิต" else "ADVENTURE  ·  BELONG  ·  BUILD  ·  CONQUER")
		companyHeading.Text = if novice then (if th then "เส้นทางของคุณเริ่มต้นที่นี่" else "Your journey begins here") else (if th then "เหล่านักผจญภัยของคุณ" else "Your company awaits")
		company.Text = if novice then (if th then "ออกเดินทางบน Crown Road ฝึกฝน เลือกอาชีพ และก่อตั้งกิลด์ของคุณ" else "Follow Crown Road. Train, choose your class, and earn the right to found a guild.") else (if th then "นำทีมนักผจญภัยห้าคน ออกเดินทางจากเมืองของคุณ" else "Command five adventurers. Begin your journey in the guild city.")
		settings.button.Text = if th then "ภาษา: ไทย → English" else "Language: English → ไทย"
		credits.button.Text = if th then "ผู้สร้าง" else "Credits"
		alpha.Text = if th then "อัลฟาทดลองเล่น" else "FIRST PLAYABLE ALPHA"
		creditsLabel.Text = if th then "Guildborne ใช้โมเดลพื้นฐานและระบบ Luau ที่สร้างขึ้นเอง บนเอนจิน Roblox รอบ UAT-01 นี้ไม่มีการซื้อแอสเซ็ต" else "Original Guildborne native geometry and Luau systems. Roblox engine. No purchased assets added in UAT-01."
	end
	api.update(nil); responsive()
	function api.isOpen(): boolean return root.Visible end
	return api
end
