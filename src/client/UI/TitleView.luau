--!strict
local Art = require(game:GetService("ReplicatedStorage").Shared.Config.Art)
local Assets = require(game.ReplicatedStorage.Shared.Config.VisualAssets)
local AssetImage = require(script.Parent.AssetImage)
local Localization = require(game.ReplicatedStorage.Shared.Config.Localization)
local Symbol=require(script.Parent.SymbolIcon)

-- Presentation consumes the existing authoritative profile snapshot. No new save path.
return function(parent: ScreenGui, enter: () -> (), language: () -> ())
	local colors = Art.UI
	local languageCode = "en"
	local root = Instance.new("Frame")
	root.Name = "TitleScreen"; root.Size = UDim2.fromScale(1, 1)
	root.BackgroundColor3 = colors.Background; root.BorderSizePixel = 0; root.ZIndex = 20; root.Parent = parent
	require(script.Parent.MenuRouter).register("Title", root, true)
	local backdrop = AssetImage.create(root, Assets.KeyArt, UDim2.fromScale(1, 1))
	if backdrop then backdrop.ScaleType = Enum.ScaleType.Crop; backdrop.ImageTransparency = .78 end
	local content = Instance.new("Frame")
	content.AnchorPoint = Vector2.new(.5, .5); content.Position = UDim2.fromScale(.5, .5)
	content.Size = UDim2.new(1, -32, 1, -24); content.BackgroundTransparency = 1; content.Parent = root
	local limit = Instance.new("UISizeConstraint"); limit.MaxSize = Vector2.new(620, 680); limit.Parent = content
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.fromScale(1, 1); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
	scroll.CanvasSize = UDim2.new(); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.ScrollBarThickness = 4; scroll.Parent = content
	local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, 16); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = scroll
	local function label(value: string, size: number, height: number): TextLabel
		local item = Instance.new("TextLabel"); item.Size = UDim2.new(1, -8, 0, height)
		item.BackgroundTransparency = 1; item.Font = Enum.Font.GothamBold; item.TextSize = size
		item.TextColor3 = colors.Text; item.TextWrapped = true; item.Text = value; item.Parent = scroll
		return item
	end
	local wordmark = label("G U I L D B O R N E", 30, 70); wordmark.TextColor3 = colors.Accent
	local monogram=Symbol(wordmark,"ui.brand.monogram",36,colors.Accent)
	if monogram then monogram.Position=UDim2.new(0,4,.5,-18) end
	local function responsiveBrand()
		local narrow=scroll.AbsoluteSize.X<420
		wordmark.TextSize=if narrow then 22 else 30
		if monogram then monogram.Visible=not narrow end
	end
	scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsiveBrand);responsiveBrand()
	local logo = AssetImage.create(scroll, Assets.Logo, UDim2.new(1, -8, 0, 130))
	if logo then
		local function refreshLogo() wordmark.Visible = not logo.IsLoaded end
		logo:GetPropertyChangedSignal("IsLoaded"):Connect(refreshLogo); refreshLogo()
	end
	local tagline = label("", 18, 40)
	tagline.LayoutOrder=1
	local ornament=Symbol(tagline,"ui.brand.title_ornament",22,colors.Accent)
	if ornament then ornament.Position=UDim2.new(.5,-11,1,-8) end
	local company = label("", 16, 64)
	company.LayoutOrder=3
	local preview = require(script.Parent.CompanyPreview)(scroll)
	local companyViewport=scroll:FindFirstChild("CompanyPreview") :: GuiObject
	companyViewport.LayoutOrder=4
	local function button(name: string, callback: () -> ()): TextButton
		local item = Instance.new("TextButton"); item.Name = name; item.Size = UDim2.new(1, -8, 0, 52)
		item.Font = Enum.Font.GothamMedium; item.TextSize = 18; item.TextWrapped = true
		item.BackgroundColor3 = colors.Button; item.TextColor3 = colors.Text; item.Parent = scroll
		local round = Instance.new("UICorner"); round.CornerRadius = UDim.new(0, 8); round.Parent = item
		local border = Instance.new("UIStroke"); border.Color = colors.Accent; border.Transparency = .5; border.Parent = item
		item.Activated:Connect(callback); return item
	end
	local play = button("Continue", function() if root:GetAttribute("ProfileReady") then root.Visible = false; preview.destroy(); enter() end end)
	play.LayoutOrder=2
	local loadingSigil=Symbol(play,"ui.brand.loading_sigil",24,colors.Accent)
	if loadingSigil then loadingSigil.Position=UDim2.new(0,10,.5,-12) end
	local playPadding=Instance.new("UIPadding");playPadding.PaddingLeft=UDim.new(0,40);playPadding.PaddingRight=UDim.new(0,8);playPadding.Parent=play
	-- Loading stays readable without motion and needs no external image or network request.
	if loadingSigil then loadingSigil.Position=UDim2.new(0,-30,.5,-12) end
	local settings = button("Language", language)
	settings.LayoutOrder=5
	local presentation: any = nil
	local settingsToggle = button("Settings", function() if presentation then presentation.frame.Visible = not presentation.frame.Visible end end)
	settingsToggle.LayoutOrder=6
	presentation = require(script.Parent.SettingsControls)(scroll, function(key: string): string return Localization.translate(languageCode, key) end)
	presentation.frame.LayoutOrder=7
	presentation.frame.Visible = false
	local creditsOpen = false
	local creditsLabel: TextLabel
	local credits = button("Credits", function() creditsOpen = not creditsOpen; creditsLabel.Visible = creditsOpen end)
	credits.LayoutOrder=8
	creditsLabel = label("Original Guildborne native geometry and Luau systems. Roblox engine. No purchased assets added in UAT-01.", 14, 80)
	creditsLabel.LayoutOrder=9
	creditsLabel.Visible = false
	local alphaLabel=label("FIRST PLAYABLE ALPHA",12,48);alphaLabel.TextColor3=colors.Muted;alphaLabel.LayoutOrder=10
	local api = {}
	function api.update(view: any)
		-- Recovery belongs to the existing profile UI, including its retry controls.
		if root.Visible and view and view.status ~= "Active" and view.status ~= "Loading" then
			root.Visible = false; preview.destroy(); enter()
		end
		local th = view and view.data and view.data.language == "th"
		languageCode = if th then "th" else "en"
		settingsToggle.Text = Localization.translate(languageCode, "Settings"); presentation.refresh()
		local ready = view and view.data ~= nil and view.status == "Active"
		if root.Visible and view and view.data then preview.update(view.data) end
		root:SetAttribute("ProfileReady", ready == true)
		play.Active = ready == true; play.Selectable = ready == true; play.AutoButtonColor = ready == true
		if loadingSigil then loadingSigil.Visible=not ready end
		playPadding.PaddingLeft=UDim.new(0,if ready then 8 else 40)
		play.BackgroundColor3 = if ready then colors.Button else colors.Card
		local novice=view and view.data and view.data.progression.novice and view.data.progression.novice.claimed<6
		play.Text = if ready then (if novice then (if th then "เริ่มเส้นทางนักผจญภัย"else "Begin your adventure")else (if th then "เข้าสู่กิลด์" else "Continue to your guild")) else (if th then "กำลังโหลดกิลด์…" else "Loading your guild…")
		tagline.Text = if th then "สร้าง · แลกเปลี่ยน · พิชิต" else "Build. Trade. Conquer."
		company.Text = if novice then (if th then "ออกเดินทางบน Crown Road ฝึกฝน เลือกอาชีพ และก่อตั้งกิลด์ของคุณ"else "Follow Crown Road. Train, choose your class, and earn the right to found a guild.")else (if th then "นำทีมนักผจญภัยห้าคน ออกเดินทางจากเมืองของคุณ" else "Command five adventurers. Begin your journey in the guild city.")
		settings.Text = if th then "ภาษา: ไทย → English" else "Language: English → ไทย"
		settings.Active = ready == true; settings.Selectable = ready == true
		credits.Text = if th then "ผู้สร้าง" else "Credits"
		alphaLabel.Text=if th then "อัลฟาทดลองเล่น" else "FIRST PLAYABLE ALPHA"
		creditsLabel.Text = if th then "Guildborne ใช้โมเดลพื้นฐานและระบบ Luau ที่สร้างขึ้นเอง บนเอนจิน Roblox รอบ UAT-01 นี้ไม่มีการซื้อแอสเซ็ต" else "Original Guildborne native geometry and Luau systems. Roblox engine. No purchased assets added in UAT-01."
	end
	api.update(nil)
	function api.isOpen(): boolean return root.Visible end
	return api
end
