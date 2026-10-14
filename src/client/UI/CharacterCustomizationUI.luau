--!strict
-- Native presentation of server-projected appearance IDs. Drafts never edit profile data.
local Shared = game:GetService("ReplicatedStorage").Shared
local Catalog = require(Shared.Data.AppearanceCatalog)
local Rules = require(Shared.Data.AppearanceRules)
local Localization = require(Shared.Config.Localization)
local Colors = require(Shared.Config.Art).UI
local Preview = require(script.Parent.Parent.Controllers.AppearancePreviewController)
local MenuRouter = require(script.Parent.MenuRouter)
local GuiService = game:GetService("GuiService")

local function equal(left: any, right: any): boolean
	if type(left) ~= type(right) then return false end
	if type(left) ~= "table" then return left == right end
	for key, value in pairs(left) do if not equal(value, right[key]) then return false end end
	for key in pairs(right) do if left[key] == nil then return false end end
	return true
end
local function sortedKeys(map: any): {string}
	local ids = {}; for id in pairs(map) do table.insert(ids, id) end; table.sort(ids); return ids
end
local function decorate(object: GuiObject)
	object.BorderSizePixel = 0
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = object
	local stroke = Instance.new("UIStroke"); stroke.Color = Colors.Border; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Parent = object
end
local function label(parent: Instance, value: string, height: number?): TextLabel
	local object = Instance.new("TextLabel"); object.BackgroundTransparency = 1
	object.Size = UDim2.new(1, 0, 0, height or 0); object.AutomaticSize = if height then Enum.AutomaticSize.None else Enum.AutomaticSize.Y
	object.TextColor3 = Colors.Text; object.TextSize = 15; object.Font = Enum.Font.Gotham
	object.TextWrapped = true; object.TextXAlignment = Enum.TextXAlignment.Left; object.TextYAlignment = Enum.TextYAlignment.Center
	object.Text = value; object.Parent = parent; return object
end
local function list(parent: Instance)
	local layout = Instance.new("UIListLayout"); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 8); layout.Parent = parent
	local padding = Instance.new("UIPadding"); padding.PaddingTop = UDim.new(0, 4); padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 4); padding.PaddingRight = UDim.new(0, 8); padding.Parent = parent
end
local names: {[string]: string} = {
	HUMAN="Human", ELF="Elf", ORC="Orc", DWARF="Dwarf",
	HUMAN_STANDARD="Standard", HUMAN_SLIM="Slim", HUMAN_ATHLETIC="Athletic", HUMAN_HEAVY="Heavy",
	ELF_GRACEFUL="Graceful", ELF_RANGER="Ranger", ELF_STURDY="Sturdy", ORC_LEAN="Lean", ORC_STANDARD="Standard", ORC_HEAVY="Heavy",
	DWARF_COMPACT="Compact", DWARF_BROAD="Broad", DWARF_STOUT="Stout",
	CLO_TUNIC_TRAVELER_01="Traveler tunic", CLO_TROUSERS_TRAVELER_01="Traveler trousers",
	CLO_ROBE_MAGE_01="Mage robe", CLO_ROBE_PRIEST_01="Priest robe", CLO_ROBE_WIZARD_01="Wizard robe",
	CLO_HAT_WIZARD_01="Wizard hat", CLO_HOOD_RANGER_01="Ranger hood", CLO_CLOAK_TRAVELER_01="Traveler cape",
	CLO_CLOAK_GUILD_01="Guild cape", ARM_CHEST_KNIGHT_01="Knight chest armor", ARM_SHOULDER_KNIGHT_01="Knight shoulders",
	INNER_TOP="Inner top", INNER_BOTTOM="Inner bottom", OUTER_TOP="Outer top", OUTER_BOTTOM="Outer bottom",
	CHEST_ARMOR="Chest armor", SHOULDERS="Shoulders", GLOVES="Gloves", BOOTS="Boots", BELT="Belt", CAPE="Cape", HEADWEAR="Headwear",
}

return function(parent: ScreenGui, send: (string, any) -> string?, onClose: () -> ())
	local api: any = {}
	local snapshot: any = nil
	local language = "en"
	local actorId = "player"
	local category = "Body"
	local records: any = {}
	local busy = false
	local pending: any = nil
	local comparing = false
	local closing = false
	local destroyed = false
	local compactLayout = false
	local messageCode = "AppearancePreviewOnly"
	local lastPreview: any = nil
	local previewReady = false
	local warningAction: (() -> ())? = nil
	local connections: {RBXScriptConnection} = {}
	local function T(key: string, values: {[string]: any}?): string return Localization.translate(language, key, values) end
	local root = Instance.new("Frame"); root.Name = "CharacterCustomization"
	root.AnchorPoint = Vector2.new(.5, .5); root.Position = UDim2.fromScale(.5, .5); root.Size = UDim2.new(1, -16, 1, -16)
	root.BackgroundColor3 = Colors.Background; root.Visible = false; root.ZIndex = 40; root.Parent = parent; decorate(root)
	local sizeLimit = Instance.new("UISizeConstraint"); sizeLimit.MaxSize = Vector2.new(1050, 1000); sizeLimit.Parent = root
	local title = label(root, "", 44); title.Position = UDim2.fromOffset(12, 4); title.Size = UDim2.new(1, -118, 0, 44); title.TextSize = 20; title.Font = Enum.Font.GothamBold
	local function button(parentObject: Instance, name: string, text: string, enabled: boolean, action: () -> (), selected: boolean?): TextButton
		local object = Instance.new("TextButton"); object.Name = name; object.Size = UDim2.new(1, -4, 0, 48)
		object.BackgroundColor3 = if selected then Colors.Accent elseif enabled then Colors.Button else Colors.Card
		object.TextColor3 = if selected then Colors.Background elseif enabled then Colors.Text else Colors.Muted
		object.TextWrapped = true; object.TextSize = 15; object.Font = Enum.Font.GothamMedium; object.Text = text
		object.Active = enabled; object.Selectable = enabled; object.AutoButtonColor = enabled; object.Parent = parentObject; decorate(object)
		object.Activated:Connect(function() if object.Active and not destroyed then action() end end)
		return object
	end
	local closeButton = button(root, "AppearanceClose", "", true, function() api.RequestClose() end)
	closeButton.Position = UDim2.new(1, -102, 0, 4); closeButton.Size = UDim2.fromOffset(90, 44)
	local actors = Instance.new("ScrollingFrame"); actors.Name = "AppearanceActors"; actors.BackgroundTransparency = 1
	actors.Position = UDim2.fromOffset(12, 52); actors.Size = UDim2.new(1, -24, 0, 48)
	actors.CanvasSize = UDim2.new(); actors.AutomaticCanvasSize = Enum.AutomaticSize.X; actors.ScrollingDirection = Enum.ScrollingDirection.X
	actors.ScrollBarThickness = 3; actors.BorderSizePixel = 0; actors.Parent = root
	local actorLayout = Instance.new("UIListLayout"); actorLayout.FillDirection = Enum.FillDirection.Horizontal; actorLayout.Padding = UDim.new(0, 8); actorLayout.SortOrder = Enum.SortOrder.LayoutOrder; actorLayout.Parent = actors
	local dossier = label(root, "", 38); dossier.Position = UDim2.fromOffset(12, 102); dossier.Size = UDim2.new(1, -24, 0, 38); dossier.TextColor3 = Colors.Muted
	local body = Instance.new("Frame"); body.Name = "AppearanceContent"; body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(12, 146); body.Size = UDim2.new(1, -24, 1, -274); body.Parent = root
	local previewPanel = Instance.new("Frame"); previewPanel.Name = "AppearancePreview"; previewPanel.BackgroundColor3 = Colors.Card; previewPanel.Parent = body; decorate(previewPanel)
	local viewport = Instance.new("ViewportFrame"); viewport.Name = "AppearanceViewport"; viewport.BackgroundTransparency = 1
	viewport.Position = UDim2.fromOffset(4, 4); viewport.Size = UDim2.new(1, -8, 1, -100); viewport.Parent = previewPanel
	local preview = Preview(viewport)
	local previewStatus = label(previewPanel, "", 44); previewStatus.Position = UDim2.new(0, 8, 1, -96); previewStatus.Size = UDim2.new(1, -16, 0, 44); previewStatus.TextSize = 13; previewStatus.TextColor3 = Colors.Accent
	local orbit = Instance.new("ScrollingFrame"); orbit.Name = "AppearanceOrbit"; orbit.BackgroundTransparency = 1
	orbit.Position = UDim2.new(0, 4, 1, -48); orbit.Size = UDim2.new(1, -8, 0, 48); orbit.BorderSizePixel = 0; orbit.ScrollBarThickness = 2
	orbit.CanvasSize = UDim2.new(); orbit.AutomaticCanvasSize = Enum.AutomaticSize.X; orbit.ScrollingDirection = Enum.ScrollingDirection.X; orbit.Parent = previewPanel
	local orbitLayout = Instance.new("UIListLayout"); orbitLayout.FillDirection = Enum.FillDirection.Horizontal; orbitLayout.Padding = UDim.new(0, 4); orbitLayout.Parent = orbit
	local orbitButtons: any = {}
	for _, name in ipairs({"Front", "Side", "Back", "Reset View", "Zoom in", "Zoom out"}) do
		local control = button(orbit, "Appearance" .. name:gsub(" ", ""), "", true, function()
			if name == "Reset View" then preview.ResetView() elseif name == "Zoom in" then preview.ZoomIn() elseif name == "Zoom out" then preview.ZoomOut() else preview.SetView(name) end
		end)
		control.Size = UDim2.fromOffset(if name == "Reset View" then 104 else 72, 44); orbitButtons[name] = control
	end
	local options = Instance.new("Frame"); options.Name = "AppearanceOptions"; options.BackgroundTransparency = 1; options.Parent = body
	local categoryBar = Instance.new("Frame"); categoryBar.BackgroundTransparency = 1; categoryBar.Size = UDim2.new(1, 0, 0, 48); categoryBar.Parent = options
	local categoryButtons: any = {}
	for index, name in ipairs({"Body", "Head / Hair", "Outfit"}) do
		local control = button(categoryBar, "AppearanceTab" .. index, "", true, function() category = name; api.Render(true) end)
		control.Position = UDim2.new((index - 1) / 3, 0, 0, 0); control.Size = UDim2.new(1 / 3, -4, 0, 44); categoryButtons[name] = control
	end
	local choices = Instance.new("ScrollingFrame"); choices.Name = "AppearanceChoices"; choices.Position = UDim2.fromOffset(0, 52); choices.Size = UDim2.new(1, 0, 1, -52)
	choices.BackgroundTransparency = 1; choices.BorderSizePixel = 0; choices.ScrollBarThickness = 5; choices.CanvasSize = UDim2.new(); choices.AutomaticCanvasSize = Enum.AutomaticSize.Y; choices.ScrollingDirection = Enum.ScrollingDirection.Y; choices.Active = true; choices.Parent = options; list(choices)
	local status = label(root, "", 56); status.Position = UDim2.new(0, 12, 1, -124); status.Size = UDim2.new(1, -24, 0, 56); status.TextSize = 14
	local footer = Instance.new("Frame"); footer.BackgroundTransparency = 1; footer.Position = UDim2.new(0, 12, 1, -60); footer.Size = UDim2.new(1, -24, 0, 52); footer.Parent = root
	local compare = button(footer, "AppearanceCompare", "", true, function() comparing = not comparing; api.Render() end)
	compare.Size = UDim2.new(1 / 3, -4, 1, 0)
	local cancel = button(footer, "AppearanceCancel", "", true, function() api.RequestClose() end)
	cancel.Size = UDim2.new(1 / 3, -4, 1, 0); cancel.Position = UDim2.fromScale(1 / 3, 0)
	local apply = button(footer, "AppearanceApply", "", false, function() api.Apply() end)
	apply.Size = UDim2.new(1 / 3, -4, 1, 0); apply.Position = UDim2.fromScale(2 / 3, 0)
	local warning = Instance.new("Frame"); warning.Name = "AppearanceUnsavedWarning"; warning.Size = UDim2.fromScale(1, 1); warning.BackgroundColor3 = Colors.Background; warning.BackgroundTransparency = .05; warning.Visible = false; warning.ZIndex = 50; warning.Parent = root
	local warningBox = Instance.new("Frame"); warningBox.AnchorPoint = Vector2.new(.5, .5); warningBox.Position = UDim2.fromScale(.5, .5); warningBox.Size = UDim2.new(1, -24, 0, 204); warningBox.BackgroundColor3 = Colors.Card; warningBox.Parent = warning; decorate(warningBox)
	local warningLimit = Instance.new("UISizeConstraint"); warningLimit.MaxSize = Vector2.new(480, 204); warningLimit.Parent = warningBox
	local warningText = label(warningBox, "", 80); warningText.Position = UDim2.fromOffset(12, 4); warningText.Size = UDim2.new(1, -24, 0, 80)
	local keep = button(warningBox, "AppearanceKeepEditing", "", true, function() warning.Visible = false; warningAction = nil; GuiService.SelectedObject = closeButton end)
	keep.Position = UDim2.fromOffset(12, 88); keep.Size = UDim2.new(1, -24, 0, 48)
	local discard = button(warningBox, "AppearanceDiscard", "", true, function()
		local nextAction = warningAction; warningAction = nil; warning.Visible = false
		api.Discard(); if nextAction then nextAction() end
	end)
	discard.Position = UDim2.fromOffset(12, 144); discard.Size = UDim2.new(1, -24, 0, 48)
	local function actor(id: string): any
		local data = snapshot and snapshot.data
		return if not data then nil elseif id == "player" then data.character else data.adventurers and data.adventurers[id]
	end
	local function record(): any return records[actorId] end
	local function dirty(entry: any): boolean return entry ~= nil and not equal(entry.draft, entry.base) end
	local function policy(): any return snapshot and snapshot.catalog and snapshot.catalog.AppearancePreviewPolicy or {} end
	local function editable(): boolean return not busy and not pending and actor(actorId) ~= nil and snapshot and snapshot.status == "Active" and snapshot.catalog.AppearanceAvailable == true end
	local function needsApply(): boolean
		local source = actor(actorId)
		return dirty(record()) or (record() ~= nil and source ~= nil and source.appearanceEnabled ~= true)
	end
	local function allowedAsset(id: string): boolean
		local entry = record(); local asset = Catalog.Assets[id]; local bodyEntry = entry and Catalog.Bodies[entry.draft.bodyPresetId]
		local p = policy()
		if not asset or not bodyEntry or not p.AllowedAssets or p.AllowedAssets[id] ~= true then return false end
		if asset.raceId ~= "ALL" and asset.raceId ~= entry.draft.raceId then return false end
		if asset.fitProfile ~= "PRESET_SPECIFIC" and asset.fitProfile ~= bodyEntry.fitProfile then return false end
		local fits = p.ApprovedFits and p.ApprovedFits[entry.draft.bodyPresetId]
		return fits ~= nil and fits[id] == true
	end
	local function mutate(change: (any) -> ())
		if not editable() or not record() then return end
		change(record().draft); comparing = false; messageCode = "AppearanceUnsaved"; api.Render()
	end
	local function heading(key: string)
		local object = label(choices, T(key)); object.TextColor3 = Colors.Accent; object.Font = Enum.Font.GothamBold; object.TextSize = 17
	end
	local function choose(id: string, titleKey: string, selected: boolean, available: boolean, change: (any) -> ())
		button(choices, "AppearanceChoice_" .. id, (if selected then "✓ " else "") .. T(titleKey) .. (if available then "" else " · " .. T("Unavailable")), available and editable(), function() mutate(change) end, selected)
	end
	local function assetName(id: string, slot: string): string
		if names[id] then return T(names[id]) end
		local suffix = id:match("_(%d+)$") or ""
		return T(if slot == "HEAD" then "Head preset" elseif slot == "HAIR" then "Hair style" elseif slot == "BEARD" then "Beard style" else names[slot] or slot) .. " " .. suffix
	end
	local function assetsFor(slot: string)
		local entry = record(); local selection = entry.draft
		heading(if slot == "HEAD" then "Head" elseif slot == "HAIR" then "Hair" elseif slot == "BEARD" then "Beard" else names[slot] or slot)
		if slot ~= "HEAD" then
			choose("REMOVE_" .. slot, "None", (if slot == "HAIR" then selection.hairAssetId elseif slot == "BEARD" then selection.beardAssetId else selection.outfitSlots[slot]) == nil, true, function(nextSelection)
				if slot == "HAIR" then nextSelection.hairAssetId = nil elseif slot == "BEARD" then nextSelection.beardAssetId = nil else nextSelection.outfitSlots[slot] = nil end
			end)
		end
		for _, id in ipairs(sortedKeys(Catalog.Assets)) do
			local asset = Catalog.Assets[id]
			if asset.slot ~= slot or (asset.raceId ~= "ALL" and asset.raceId ~= selection.raceId) then continue end
			local current = if slot == "HEAD" then selection.headPresetId elseif slot == "HAIR" then selection.hairAssetId elseif slot == "BEARD" then selection.beardAssetId else selection.outfitSlots[slot]
			local hint = if asset.technology == "LAYERED" then T("Planned layered garment · fit pending") else T("Separate accessory · fit pending")
			choose(id, assetName(id, slot) .. "\n" .. hint, current == id, allowedAsset(id), function(nextSelection)
				if slot == "HEAD" then nextSelection.headPresetId = id elseif slot == "HAIR" then nextSelection.hairAssetId = id elseif slot == "BEARD" then nextSelection.beardAssetId = id else nextSelection.outfitSlots[slot] = id end
			end)
		end
	end
	local function featuresFor()
		local selection = record().draft
		local feature = if selection.raceId == "ELF" then "EARS" elseif selection.raceId == "ORC" then "TUSKS" else nil
		if not feature then return end
		heading(if feature == "EARS" then "Ears" else "Tusks")
		choose("REMOVE_" .. feature, "None", selection.raceFeatures[feature] == nil, true, function(nextSelection) nextSelection.raceFeatures = {} end)
		for _, id in ipairs(sortedKeys(Catalog.Assets)) do
			local asset = Catalog.Assets[id]
			if asset.slot ~= "RACE_FEATURE" or asset.raceId ~= selection.raceId then continue end
			choose(id, T(if feature == "EARS" then "Ears" else "Tusks") .. " " .. (id:match("_(%d+)$") or ""), selection.raceFeatures[feature] == id, allowedAsset(id), function(nextSelection) nextSelection.raceFeatures = {[feature] = id} end)
		end
	end
	local function showWarning(nextAction: () -> (), unconfirmed: boolean?)
		warningAction = nextAction; warning.Visible = true
		warningText.Text = T(if unconfirmed then (if compactLayout then "Request sent. Closing will not cancel it." else "The appearance request was sent. Closing the preview does not cancel it.") else (if compactLayout then "Discard this appearance draft?" else "Discard unsaved appearance changes?"))
		keep.Text = T(if unconfirmed then "Keep waiting" else "Keep editing")
		discard.Text = T(if unconfirmed then "Close preview" else "Discard draft"); GuiService.SelectedObject = keep
	end
	function api.Discard()
		local entry = record()
		if entry and entry.latest then
			entry.base = Rules.copy(entry.latest); entry.draft = Rules.copy(entry.latest); entry.revision = entry.latestRevision
		end
		comparing = false; messageCode = "AppearancePreviewOnly"; api.Render()
	end
	local function close()
		closing = true; root.Visible = false; closing = false
		preview.Clear(); lastPreview = nil; warning.Visible = false; warningAction = nil; onClose()
	end
	function api.RequestClose()
		if pending then
			if pending.timedOut or pending.uncertain or os.clock() - pending.sentAt >= 12 then showWarning(close, true)
			else messageCode = "AppearancePending"; api.Render() end
			return
		end
		if dirty(record()) then showWarning(close) else api.Discard(); close() end
	end
	local function selectActor(id: string)
		if pending or busy or id == actorId then return end
		local function switch() actorId = id; comparing = false; messageCode = "AppearancePreviewOnly"; api.Render(true); preview.ResetView() end
		if dirty(record()) then showWarning(switch) else switch() end
	end
	function api.Apply()
		local entry = record()
		if not editable() or not entry or not needsApply() or not previewReady then return end
		local submitted = {actorId = actorId, revision = entry.revision, selection = Rules.copy(entry.draft), sentAt = os.clock(), timedOut = false, requestId = nil :: string?}
		pending = submitted
		messageCode = "AppearancePending"; api.Render()
		local requestId = send("CommitAppearance", {actorId = actorId, selection = Rules.copy(submitted.selection), appearanceRevision = submitted.revision})
		if requestId then submitted.requestId = requestId
		elseif pending == submitted then pending = nil; messageCode = "AppearanceRequestRefused" end
		api.Render()
	end
	function api.Render(resetScroll: boolean?)
		if destroyed or not root.Visible then return end
		local entry, source = record(), actor(actorId)
		title.Text = T("Character appearance"); closeButton.Text = T("Back")
		for _, child in ipairs(actors:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
		local ids = {"player"}; for _, id in ipairs(sortedKeys(snapshot and snapshot.data and snapshot.data.adventurers or {})) do table.insert(ids, id) end
		for index, id in ipairs(ids) do
			local owner = actor(id)
			local control = button(actors, "AppearanceActor_" .. id, if id == "player" then T("Your character") else T(owner.name or owner.classId or id), not busy and not pending, function() selectActor(id) end, actorId == id)
			control.Size = UDim2.fromOffset(154, 44); control.LayoutOrder = index
		end
		dossier.Text = if source then T("{class} · Level {level} · Cosmetic changes only", {class = T(source.classId or "Novice"), level = source.level or 1}) else T("AppearanceActorUnavailable")
		for name, control in pairs(orbitButtons) do control.Text = T(if name == "Back" then "Back view" else name) end
		for name, control in pairs(categoryButtons) do
			control.Text = T(name); control.BackgroundColor3 = if name == category then Colors.Accent else Colors.Card; control.TextColor3 = if name == category then Colors.Background else Colors.Text
		end
		local scrollPosition = if resetScroll then Vector2.zero else choices.CanvasPosition
		for _, child in ipairs(choices:GetChildren()) do if child:IsA("GuiObject") and child ~= actors then child:Destroy() end end
		if compactLayout then
			-- Actor choice and identity remain reachable without consuming the short viewport's header.
			local identity = label(choices, dossier.Text); identity.LayoutOrder = -90; identity.TextColor3 = Colors.Muted; identity.TextSize = 13
			if messageCode ~= "AppearancePreviewOnly" and messageCode ~= "AppearanceUnsaved" and messageCode ~= "AppearancePending" and messageCode ~= "AppearanceCommitted" then
				local detail = label(choices, T(messageCode)); detail.LayoutOrder = -80; detail.TextSize = 13
			end
		end
		if entry then
			local selection = entry.draft
			if category == "Body" then
				heading("Race"); label(choices, T("Every race supports Knight, Warrior, Archer, Mage and Priest."))
				for _, race in ipairs({"HUMAN", "ELF", "ORC", "DWARF"}) do
					local p = policy(); local defaultId = Catalog.Defaults[race]; local available = p.AllowedPresets and p.AllowedPresets[defaultId] == true
					choose(race, names[race], selection.raceId == race, available, function(nextSelection)
						if nextSelection.raceId == race then return end
						nextSelection.raceId = race; nextSelection.bodyPresetId = defaultId; nextSelection.headPresetId = "CHR_HEAD_" .. race .. "_01"
						nextSelection.skinPaletteId = "SKIN_" .. race .. "_03"; nextSelection.hairAssetId = nil; nextSelection.beardAssetId = nil; nextSelection.raceFeatures = {}; nextSelection.outfitSlots = {}
					end)
				end
				heading("Body preset")
				for _, id in ipairs(sortedKeys(Catalog.Bodies)) do
					if Catalog.Bodies[id].raceId ~= selection.raceId then continue end
					local p = policy(); local available = p.AllowedPresets and p.AllowedPresets[id] == true
					choose(id, names[id] or id, selection.bodyPresetId == id, available, function(nextSelection) nextSelection.bodyPresetId = id end)
				end
				heading("Skin tone")
				for _, id in ipairs(sortedKeys(Catalog.SkinPalettes)) do
					local skin = Catalog.SkinPalettes[id]; if skin.raceId ~= selection.raceId then continue end
					local swatch = button(choices, "AppearanceSkin_" .. id, (if selection.skinPaletteId == id then "✓ " else "") .. T(skin.label), editable(), function() mutate(function(nextSelection) nextSelection.skinPaletteId = id end) end)
					swatch.TextXAlignment = Enum.TextXAlignment.Left
					local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 60); pad.Parent = swatch
					local chip = Instance.new("Frame"); chip.Name = "SkinSwatch"; chip.Size = UDim2.fromOffset(36, 36); chip.Position = UDim2.fromOffset(-52, 6); chip.BackgroundColor3 = Color3.fromHex(skin.colorHex); chip.Parent = swatch; decorate(chip)
				end
			elseif category == "Head / Hair" then
				assetsFor("HEAD"); assetsFor("HAIR"); heading("Hair color")
				for _, id in ipairs(sortedKeys(Catalog.HairColors)) do choose(id, id:gsub("HAIR_", ""):gsub("_", " "), selection.hairColorId == id, true, function(nextSelection) nextSelection.hairColorId = id end) end
				assetsFor("BEARD"); featuresFor()
			else
				label(choices, T("Base covering stays on when clothing is removed. Equipment is managed in Inventory."))
				for _, slot in ipairs(Catalog.SlotOrder) do if slot ~= "HAIR" and slot ~= "BEARD" and slot ~= "RACE_FEATURE" then assetsFor(slot) end end
			end
			local shownSelection = if comparing then entry.base else entry.draft
			if not equal(shownSelection, lastPreview) then previewReady = preview.SetSelection(Rules.copy(shownSelection)); lastPreview = Rules.copy(shownSelection) end
		else
			label(choices, T("AppearanceActorUnavailable")); preview.Clear(); previewReady = false; lastPreview = nil
		end
		choices.CanvasPosition = scrollPosition
		previewStatus.Text = T(if not previewReady then (if compactLayout then "Preview unavailable" else "AppearancePreviewUnavailable") elseif policy().AllowPlaceholders == true then (if compactLayout then "Placeholder · fit pending" else "Preview substitute · production meshes and clothing fit pending") else "Appearance preview")
		local compactMessages = {
			AppearancePreviewOnly="AppearanceCompactPreviewOnly", AppearanceUnsaved="AppearanceCompactUnsaved", AppearancePending="AppearanceCompactPending",
			AppearanceOutcomeUnconfirmed="AppearanceCompactUnconfirmed", AppearanceCommitted="AppearanceCompactCommitted", AppearanceRequestRefused="AppearanceCompactRefused",
			AppearanceDraftStale="AppearanceCompactStale", AppearanceRevisionConflict="AppearanceCompactStale",
		}
		status.Text = T(if compactLayout then compactMessages[messageCode] or "AppearanceCompactRejected" else messageCode)
		if entry and dirty(entry) and messageCode ~= "AppearanceUnsaved" and not pending and not compactLayout then status.Text ..= " · " .. T("AppearanceUnsaved") end
		root:SetAttribute("AppearanceActorId", actorId); root:SetAttribute("AppearanceDirty", dirty(entry)); root:SetAttribute("AppearancePending", pending ~= nil)
		root:SetAttribute("AppearancePendingRequestId", if pending then pending.requestId else nil)
		compare.Text = T(if comparing then "Show after" else "Compare before"); compare.Active = entry ~= nil; compare.Selectable = compare.Active
		cancel.Text = T(if pending and pending.timedOut then "Close preview" else "Cancel")
		cancel.Active = pending == nil or pending.timedOut == true; cancel.Selectable = cancel.Active
		apply.Text = T(if pending then "Applying…" else "Apply"); apply.Active = editable() and needsApply() and previewReady; apply.Selectable = apply.Active
		apply.AutoButtonColor = apply.Active; apply.BackgroundColor3 = if apply.Active then Colors.Button else Colors.Card; apply.TextColor3 = if apply.Active then Colors.Text else Colors.Muted
	end
	local terminalResponses = {
		Busy=true, StaleRevision=true, InvalidRequest=true, ProfileNotReady=true, Closing=true,
		LeaseExpiring=true, LeaseLost=true, RequestConflict=true, RevisionConflict=true, AuditBacklog=true, RateLimited=true,
		HeroUnavailable=true, LeaveTowerFirst=true, InvalidBodyPreset=true, InvalidSkinPalette=true, InvalidHairColor=true,
		InvalidRaceFeature=true, UnknownAppearanceAsset=true, GameplayEquipmentSlot=true,
	}
	local function response(view: any)
		if not pending or not pending.requestId or view.requestId ~= pending.requestId or type(view.code) ~= "string" then return end
		if view.code == "OK" or view.code == "AlreadyCommitted" then return end
		-- PlayerDataService retains its candidate when commit retries exhaust (SavePending).
		-- StorageUnavailable and unfamiliar failures also lack proof that this request failed.
		if view.code == "SavePending" or view.code == "StorageUnavailable" then
			pending.uncertain = true; pending.timedOut = true; messageCode = "AppearanceOutcomeUnconfirmed"
		elseif terminalResponses[view.code] or view.code:match("^Appearance") or view.code:match("^InvalidAppearance") then
			pending = nil; messageCode = view.code
		else
			pending.uncertain = true; pending.timedOut = true; messageCode = "AppearanceOutcomeUnconfirmed"
		end
	end
	function api.Update(view: any, _message: string?, _responseToAction: boolean?)
		if destroyed then return end
		if snapshot and type(view.revision) == "number" and type(snapshot.revision) == "number" and view.revision < snapshot.revision then
			response(view); api.Render(); return
		end
		snapshot = view; language = view.data and view.data.language or language
		local ids = {"player"}; for id in pairs(view.data and view.data.adventurers or {}) do table.insert(ids, id) end
		for _, id in ipairs(ids) do
			local source = actor(id)
			if not source or not source.appearance then continue end
			local entry = records[id]
			if entry and (source.appearanceRevision or 0) >= entry.latestRevision then
				entry.latest = Rules.copy(source.appearance); entry.latestRevision = source.appearanceRevision or 0
			end
			if not entry then records[id] = {base = Rules.copy(source.appearance), draft = Rules.copy(source.appearance), revision = source.appearanceRevision or 0, latest = Rules.copy(source.appearance), latestRevision = source.appearanceRevision or 0}
			elseif pending and pending.actorId == id and (source.appearanceRevision or 0) > pending.revision and equal(source.appearance, pending.selection) then
				entry.base = Rules.copy(source.appearance); entry.draft = Rules.copy(source.appearance); entry.revision = source.appearanceRevision
				pending = nil; comparing = false; messageCode = "AppearanceCommitted"
			elseif (source.appearanceRevision or 0) > entry.revision then
				if not dirty(entry) then entry.base = Rules.copy(source.appearance); entry.draft = Rules.copy(source.appearance); entry.revision = source.appearanceRevision or 0
				elseif id == actorId then messageCode = "AppearanceDraftStale" end
			end
		end
		-- Only the submitted request's definite rejection can release its pending state.
		-- Polls and other commands cannot erase it; a matching authoritative actor revision
		-- above remains sufficient confirmation after RetrySave or a lost original response.
		response(view)
		api.Render()
	end
	function api.Open(view: any, id: string?)
		api.Update(view)
		if not view.catalog or view.catalog.AppearanceAvailable ~= true then return end
		actorId = if pending then pending.actorId else id or actorId
		if pending and records[actorId] then records[actorId].draft = Rules.copy(pending.selection) end
		category = "Body"; comparing = false; root.Visible = true; api.Render(true); preview.ResetView(); MenuRouter.focusCurrent()
	end
	function api.SetBusy(value: boolean) busy = value; api.Render() end
	function api.Tick()
		if pending and not pending.timedOut and os.clock() - pending.sentAt >= 12 then
			pending.timedOut = true; messageCode = "AppearanceOutcomeUnconfirmed"; api.Render()
		end
	end
	function api.IsOpen(): boolean return root.Visible end
	local function responsive()
		local compact = root.AbsoluteSize.Y < 500
		local changed = compactLayout ~= compact
		compactLayout = compact
		dossier.Visible = not compact
		-- At a 734x308 safe modal, compact body=164, choices=116 and viewport=80.
		-- Actor/dossier controls move into the choices canvas instead of shrinking both panes.
		actors.Parent = if compact then choices else root
		actors.LayoutOrder = -100
		actors.Position = UDim2.fromOffset(if compact then 0 else 12, if compact then 0 else 52)
		actors.Size = UDim2.new(1, if compact then -4 else -24, 0, 48)
		body.Position = UDim2.fromOffset(12, if compact then 52 else 146)
		body.Size = UDim2.new(1, -24, 1, if compact then -144 else -274)
		choices.Position = UDim2.fromOffset(0, if compact then 48 else 52)
		choices.Size = UDim2.new(1, 0, 1, if compact then -48 else -52)
		viewport.Size = UDim2.new(1, -8, 1, if compact then -84 else -100)
		previewStatus.Position = UDim2.new(0, 8, 1, if compact then -76 else -96)
		previewStatus.Size = UDim2.new(1, -16, 0, if compact then 28 else 44)
		previewStatus.TextSize = if compact then 12 else 13
		orbit.Position = UDim2.new(0, 4, 1, if compact then -44 else -48)
		orbit.Size = UDim2.new(1, -8, 0, if compact then 44 else 48)
		status.Position = UDim2.new(0, 12, 1, if compact then -80 else -124)
		status.Size = UDim2.new(1, -24, 0, if compact then 28 else 56)
		status.TextSize = if compact then 12 else 14
		footer.Position = UDim2.new(0, 12, 1, if compact then -48 else -60)
		footer.Size = UDim2.new(1, -24, 0, if compact then 44 else 52)
		warningBox.Size = UDim2.new(1, -24, 0, if compact then 168 else 204)
		warningText.Size = UDim2.new(1, -24, 0, if compact then 56 else 80)
		keep.Position = UDim2.fromOffset(12, if compact then 64 else 88)
		keep.Size = UDim2.new(1, -24, 0, if compact then 44 else 48)
		discard.Position = UDim2.fromOffset(12, if compact then 112 else 144)
		discard.Size = UDim2.new(1, -24, 0, if compact then 44 else 48)
		local wide = compact or root.AbsoluteSize.X >= 680 or root.AbsoluteSize.X > root.AbsoluteSize.Y * 1.35
		if wide then
			previewPanel.Position = UDim2.new(); previewPanel.Size = UDim2.new(.43, -8, 1, 0)
			options.Position = UDim2.fromScale(.43, 0); options.Size = UDim2.new(.57, 0, 1, 0)
		else
			local previewHeight = math.clamp(math.max(0, root.AbsoluteSize.Y - 274) * .44, 144, 230)
			previewPanel.Position = UDim2.new(); previewPanel.Size = UDim2.new(1, 0, 0, previewHeight)
			options.Position = UDim2.fromOffset(0, previewHeight + 8); options.Size = UDim2.new(1, 0, 1, -previewHeight - 8)
		end
		if changed then api.Render() end
	end
	table.insert(connections, root:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive))
	table.insert(connections, root:GetPropertyChangedSignal("Visible"):Connect(function()
		if root.Visible or closing or destroyed then return end
		if pending or dirty(record()) then
			task.defer(function() if not destroyed then root.Visible = true; api.RequestClose() end end)
		else preview.Clear(); lastPreview = nil end
	end))
	function api.Destroy()
		if destroyed then return end
		destroyed = true; preview.Destroy()
		for _, connection in ipairs(connections) do connection:Disconnect() end
		table.clear(connections); table.clear(records); pending = nil; root:Destroy()
	end
	table.insert(connections, root.Destroying:Connect(api.Destroy))
	MenuRouter.register("CharacterCustomization", root)
	responsive()
	return api
end
