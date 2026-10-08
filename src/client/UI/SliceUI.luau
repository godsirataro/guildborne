--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local MenuRouter = require(script.Parent.MenuRouter)
local Localization = require(game:GetService("ReplicatedStorage").Shared.Config.Localization)
local Art = require(game:GetService("ReplicatedStorage").Shared.Config.Art)
local ClassBadge=require(script.Parent.ClassBadge)
local ProjectTracker = require(game:GetService("ReplicatedStorage").Shared.Data.QuestTracker)

return function(send: (string, any) -> ())
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "GuildborneUI"; gui.ResetOnSpawn = false
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = player:WaitForChild("PlayerGui")
	local colors = Art.UI
	local worldNotice=Instance.new("TextLabel");worldNotice.Name="WorldActionNotice"
	worldNotice.AnchorPoint=Vector2.new(.5,0);worldNotice.Position=UDim2.new(.5,0,.25,0);worldNotice.Size=UDim2.new(.7,0,0,72)
	worldNotice.BackgroundColor3=colors.Background;worldNotice.TextColor3=colors.Text;worldNotice.Font=Enum.Font.GothamMedium
	worldNotice.TextSize=16;worldNotice.TextWrapped=true;worldNotice.BorderSizePixel=0;worldNotice.Visible=false;worldNotice.ZIndex=30;worldNotice.Parent=gui
	local noticeLimit=Instance.new("UISizeConstraint");noticeLimit.MaxSize=Vector2.new(560,72);noticeLimit.Parent=worldNotice
	local noticeCorner=Instance.new("UICorner");noticeCorner.CornerRadius=UDim.new(0,8);noticeCorner.Parent=worldNotice
	local worldNoticeUntil=0
	local snapshot: any = nil
	local tab = "Guild"
	local busy = false
	local selected: { [string]: boolean } = {}
	local partyDirty = false
	local countdown: TextLabel? = nil
	local activeButton: TextButton? = nil
	local receivedAt = os.clock()
	local notice = "Welcome to Guildborne."
 local noticeCode: string?=nil
	local UI: any = {}
	local language = "en"
	local friendlyNpc:string?=nil
	local friendlyNpcs=require(game:GetService("ReplicatedStorage").Shared.Config.FriendlyNpcs)
	local classChoice: string? = nil
	local pinnedQuest: string?=nil;local journalFocus: string?=nil;local tracked: any=nil
	local inventoryFocus: string?=nil
	local function T(key: string, values: { [string]: any }?): string
		return Localization.translate(language, key, values)
	end

	local function corner(parent: GuiObject)
		local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = parent
		parent.BorderSizePixel = 0
		local stroke = Instance.new("UIStroke"); stroke.Color = colors.Border; stroke.Transparency = .35
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Thickness = 1; stroke.Parent = parent
	end
	local function padding(parent: Instance, amount: number)
		local p = Instance.new("UIPadding"); p.PaddingTop = UDim.new(0, amount); p.PaddingBottom = UDim.new(0, amount)
		p.PaddingLeft = UDim.new(0, amount); p.PaddingRight = UDim.new(0, amount); p.Parent = parent
	end
	local function layout(parent: Instance, amount: number)
		local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, amount); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = parent
	end
	local function text(parent: Instance, value: string, size: number?, color: Color3?): TextLabel
		local label = Instance.new("TextLabel"); label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 0, 0); label.AutomaticSize = Enum.AutomaticSize.Y
		label.TextSize = size or 18; label.Font = Enum.Font.Gotham; label.TextColor3 = color or colors.Text
		label.TextXAlignment = Enum.TextXAlignment.Left; label.TextYAlignment = Enum.TextYAlignment.Top
		label.TextWrapped = true; label.Text = T(value); label.Parent = parent
		return label
	end
	local function button(parent: Instance, label: string, enabled: boolean, callback: () -> ()): TextButton
		local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 52)
		b.BackgroundColor3 = if enabled then colors.Button else colors.Card
		b.TextColor3 = if enabled then colors.Text else colors.Muted
		b.Font = Enum.Font.GothamMedium; b.TextSize = 17; b.TextWrapped = true; b.Text = T(label)
		b.AutoButtonColor = enabled; b.Active = enabled; b.Selectable = enabled; b.Parent = parent; corner(b)
		b.Activated:Connect(function() if enabled and b.Active and not busy then callback() end end)
		return b
	end
	local function card(parent: Instance, title: string): Frame
		local frame = Instance.new("Frame"); frame.Size = UDim2.new(1, -4, 0, 0); frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.BackgroundColor3 = colors.Card; frame.Parent = parent; corner(frame); padding(frame, 12); layout(frame, 10)
		local titleLabel = text(frame, title, 20, colors.Accent); titleLabel.Font = Enum.Font.GothamBold
		return frame
	end

	local hud = Instance.new("Frame"); hud.Size = UDim2.new(1, -16, 0, 52); hud.Position = UDim2.fromOffset(8, 6)
	hud.BackgroundColor3 = colors.Background; hud.Parent = gui; corner(hud)
	local gold = Instance.new("TextLabel"); gold.Size = UDim2.new(1, -114, 1, 0); gold.Position = UDim2.fromOffset(12, 0)
	gold.BackgroundTransparency = 1; gold.Font = Enum.Font.GothamBold; gold.TextSize = 18; gold.TextXAlignment = Enum.TextXAlignment.Left
	gold.TextColor3 = colors.Accent; gold.Text = T("Guildborne · Loading"); gold.TextWrapped = true; gold.Parent = hud
	local toggle = Instance.new("TextButton"); toggle.Size = UDim2.fromOffset(96, 48); toggle.Position = UDim2.new(1, -100, 0, 2)
	toggle.Text = "Explore"; toggle.TextSize = 16; toggle.Font = Enum.Font.GothamMedium; toggle.TextColor3 = colors.Text; toggle.BackgroundColor3 = colors.Button; toggle.Parent = hud; corner(toggle)
	gold.Size=UDim2.new(.3,-8,1,0);gold.TextSize=15
	local tracker=Instance.new("TextButton");tracker.Name="QuestTracker";tracker.Size=UDim2.new(.42,-8,0,44);tracker.Position=UDim2.new(.32,0,0,4)
	tracker.BackgroundColor3=colors.Card;tracker.TextColor3=colors.Text;tracker.Font=Enum.Font.GothamMedium;tracker.TextSize=14
	tracker.TextWrapped=true;tracker.TextTruncate=Enum.TextTruncate.AtEnd;tracker.Parent=hud;corner(tracker)
	local panel = Instance.new("Frame"); panel.Name = "ManagementPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0); panel.Position = UDim2.new(0.5, 0, 0, 64)
	panel.Size = UDim2.new(1, -16, 1, -72); panel.BackgroundColor3 = colors.Background; panel.Parent = gui; corner(panel)
	MenuRouter.register("Management",panel)
	local constraint = Instance.new("UISizeConstraint"); constraint.MaxSize = Vector2.new(720, 1000); constraint.Parent = panel
	local tutorial = Instance.new("TextLabel"); tutorial.Size = UDim2.new(1, -24, 0, 66); tutorial.Position = UDim2.fromOffset(12, 8)
	tutorial.BackgroundTransparency = 1; tutorial.TextSize = 16; tutorial.Font = Enum.Font.GothamMedium; tutorial.TextColor3 = colors.Text
	tutorial.TextWrapped = true; tutorial.TextXAlignment = Enum.TextXAlignment.Left; tutorial.TextYAlignment = Enum.TextYAlignment.Center; tutorial.Parent = panel
	local tabs = Instance.new("Frame"); tabs.Size = UDim2.new(1, -16, 0, 48); tabs.Position = UDim2.fromOffset(8, 80); tabs.BackgroundTransparency = 1; tabs.Parent = panel
	local tabButtons: { [string]: TextButton } = {}
	for index, name in ipairs({ "Guild", "Party", "Quests", "Inventory" }) do
		local b = Instance.new("TextButton"); b.Size = UDim2.new(0.25, -4, 1, 0); b.Position = UDim2.new((index - 1) / 4, 2, 0, 0)
		b.Name=name.."Tab"; b.Text = name; b.TextSize = 14; b.Font = Enum.Font.GothamBold; b.TextColor3 = colors.Text; b.BackgroundColor3 = colors.Button; b.Parent = tabs; corner(b)
		tabButtons[name] = b
		b.Activated:Connect(function() tab = name; UI.Render(true) end)
	end
	local scroll = Instance.new("ScrollingFrame"); scroll.Name = "Content"
	scroll.Position = UDim2.fromOffset(8, 140); scroll.Size = UDim2.new(1, -16, 1, -212)
	scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 5; scroll.Active = true
	scroll.CanvasSize = UDim2.new(); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.Parent = panel; padding(scroll, 4); layout(scroll, 12)
	local status = Instance.new("TextLabel"); status.Position = UDim2.new(0, 12, 1, -64); status.Size = UDim2.new(1, -24, 0, 58)
	status.BackgroundTransparency = 1; status.TextSize = 14; status.Font = Enum.Font.Gotham; status.TextColor3 = colors.Muted
	status.TextWrapped = true; status.TextXAlignment = Enum.TextXAlignment.Left; status.Parent = panel
	local compactLayout = false
	local function responsiveLayout()
		local compact = panel.AbsoluteSize.Y < 390
		local changed = compactLayout ~= compact
		compactLayout = compact
		tutorial.Visible = not compact
		tutorial.Size = UDim2.new(1, -24, 0, if compact then 32 else 66)
		tutorial.TextSize = if compact then 14 else 16
		tabs.Position = UDim2.fromOffset(8, if compact then 8 else 80)
		scroll.Position = UDim2.fromOffset(8, if compact then 64 else 140)
		scroll.Size = UDim2.new(1, -16, 1, if compact then -108 else -212)
		status.Position = UDim2.new(0, 12, 1, if compact then -40 else -64)
		status.Size = UDim2.new(1, -24, 0, if compact then 36 else 58)
		if changed and UI.Render then UI.Render(true) end
	end
	panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsiveLayout)
	responsiveLayout()

	local tutorialText: { [string]: string } = {
		welcome = "Build. Trade. Conquer. Begin with your own small adventurer guild.",
		recruit = "1 · Open Party and recruit Rowan the Warrior for free.",
		party = "2 · In Party, select your Warrior and save your party.",
		quest = "3 · Open Quests and start Trail Watch.",
		claim = "4 · Your party is away. When the timer ends, claim its rewards in Quests.",
		equip = "5 · Open Inventory and equip the Training Sword on your Warrior.",
		roster = "6 · Recruit Archer and Priest for 20 Gold each. Complete more quests if you need Gold.",
		supplies = "7 · Complete Timber Escort and Quarry Patrol for Hall supplies. Update your party if you wish.",
		upgrade = "8 · Open Guild and upgrade your Hall to level 2.",
		complete = "Tutorial complete! Your guild is established. Try your new weapons or repeat quests.",
	}
	local function act(action: string, args: any?) send(action, args or {}) end
	local titleView = require(script.Parent.TitleView)(gui, function() panel.Visible = true end, function()
		if not busy then act("SetLanguage", { language = if language == "en" then "th" else "en" }) end
	end)
	local function rewardText(reward: any): string
		local parts = { T("{amount} Gold", { amount = reward.Gold }), T("{amount} XP per party member", { amount = reward.XP }) }
		for _, item in ipairs(reward.Items) do table.insert(parts, T(snapshot.catalog.Items[item.Id].Name) .. " ×" .. tostring(item.Quantity)) end
		return table.concat(parts, " · ")
	end
	local builder=require(script.Parent.BuildView)(send,T,function() panel.Visible=true end)
	local drawExpansion=require(script.Parent.ExpansionView)({scroll=scroll,T=T,card=card,text=text,button=button,act=act,render=function(reset: boolean?) UI.Render(reset) end,
		navigate=function(name: string) tab=name;UI.Render(true) end,explore=function() panel.Visible=false end,
		build=function(data: any,kind: string,id: string?) builder.open(data,kind,id);panel.Visible=false end})
	local drawSettlement=require(script.Parent.SettlementView)({scroll=scroll,T=T,card=card,text=text,button=button,act=act,
		atGuild=function()return player:GetAttribute("CurrentZone")=="Guild"end,
		render=function(reset: boolean?) UI.Render(reset) end,navigate=function(name: string) tab=name;UI.Render(true) end,
		trackQuest=function(id: string) pinnedQuest=if pinnedQuest==id then nil else id;UI.Render() end,
		isTracked=function(id: string) return pinnedQuest==id end,
		journalFocus=function() local id=journalFocus;journalFocus=nil;return id end,
		now=function() return math.floor(snapshot.serverTime+os.clock()-receivedAt) end})
	local drawBestiary=require(script.Parent.BestiaryView)({scroll=scroll,T=T,card=card,text=text,button=button,render=function() UI.Render() end,navigate=function(name: string) tab=name;UI.Render(true) end})
	local drawIslands=require(script.Parent.IslandDirectoryView)({scroll=scroll,T=T,card=card,text=text,button=button,act=act,render=function(reset:boolean?)UI.Render(reset)end,navigate=function(name:string)tab=name;UI.Render(true)end})
	local drawThemes=require(script.Parent.BuildingThemesView)({scroll=scroll,T=T,card=card,text=text,button=button,act=act,render=function(reset:boolean?)UI.Render(reset)end,navigate=function(name:string)tab=name;UI.Render(true)end})
	local drawNovice=require(script.Parent.NoviceJourneyView)({scroll=scroll,T=T,card=card,text=text,button=button,act=act,render=function()UI.Render()end})
	local drawCampaign=require(script.Parent.CampaignView)({scroll=scroll,T=T,card=card,text=text,button=button,act=act,render=function()UI.Render()end})
	local function guildHall(data:any)
		local frame = card(scroll, T("Personal Guild · Hall Lv{level}", { level = data.hallLevel }))
		button(frame, if language == "en" then "ภาษาไทย (TH)" else "English (EN)", not busy, function()
			act("SetLanguage", { language = if language == "en" then "th" else "en" })
		end)
		text(frame, "Manage your adventurers, equip weapons, and send a party on short expeditions.")
		if snapshot.catalog.HallUpgrades[data.hallLevel] then
			local nextHall=snapshot.catalog.HallUpgrades[data.hallLevel]
			text(frame,T("Character level cap")..": "..data.levelCap.." → "..(data.nextHallLevelCap or nextHall.To*5),17)
			local costs = { T("{amount} Gold", { amount = nextHall.Gold }) }
			local enough = data.gold >= nextHall.Gold
			for _, itemId in ipairs(snapshot.catalog.ItemOrder) do
				local need = nextHall.Materials[itemId]
				if need then
					local have = data.inventory.stacks[itemId] or 0
					table.insert(costs, T(snapshot.catalog.Items[itemId].Name) .. " " .. tostring(have) .. "/" .. tostring(need)); enough = enough and have >= need
				end
			end
			text(frame, T("Upgrade cost")..": "..table.concat(costs," · "), 17)
			text(frame,if language=="th"then "อัปเกรดได้เมื่ออยู่บนเกาะกิลด์ของตนเองและออกจากการต่อสู้แล้ว"else "Upgrade on your own guild island after leaving combat.",15,colors.Muted)
			local permitChapter=nil
			if snapshot.catalog.CampaignChapter and data.progression.campaign then for i,c in ipairs(snapshot.catalog.CampaignChapter.Chapters)do if c.HallPermit==nextHall.To then permitChapter=i end end end
			local campaignGate=snapshot.catalog.CampaignChapter~=nil and data.progression.campaign~=nil
			local unlocked = if campaignGate then permitChapter~=nil and data.progression.campaign.claimed>=permitChapter and (data.progression.campaign.hallPermit or 0)>=nextHall.To else data.quests.firstClears[nextHall.RequiredQuest]==true
			if not unlocked then
				if campaignGate and not permitChapter then text(frame,if language=="th"then "Hall ถัดไปต้องมีสิทธิ์จากบทเนื้อเรื่องที่ยังไม่เปิดในรุ่นนี้"else "The next Hall needs a permit from a story chapter not available in this build.",16,colors.Muted)
				else text(frame,if campaignGate then (if language=="th"then "ผ่านเควสกิลด์และรับสิทธิ์อัปเกรด Hall "else "Complete the guild quest and claim the permit for Hall ")..nextHall.To else "Complete Quarry Patrol to unlock the Hall upgrade.", 16, colors.Muted)end
			end
			button(frame, T("Upgrade Hall").." Lv"..nextHall.To.." · "..nextHall.Gold.." Gold", enough and unlocked and not busy, function() act("UpgradeGuildHall") end).Name="UpgradeGuildHall"
		else text(frame,T("Character level cap")..": "..data.levelCap) end
		text(frame, snapshot.mode, 15, colors.Muted)
	end
	local function guild(data: any)
		if data.progression.novice and data.progression.novice.claimed<6 then
			drawNovice(data,snapshot.catalog,busy)
			return
		end
		if snapshot.catalog.CampaignChapter then drawCampaign(data,snapshot.catalog,busy) end
		local priorityHall=snapshot.catalog.CampaignChapter~=nil and data.progression.campaign and (data.progression.campaign.hallPermit or 0)>data.hallLevel
		if priorityHall then guildHall(data) end
		if data.progression.tutorialStep~="complete" then
			local guidance=card(scroll,"Next step")
			if not data.progression.welcomeSeen then
				button(guidance,"Begin tutorial",not busy,function() act("BeginTutorial") end).Name="BeginTutorial"
			else
				button(guidance,"Continue tutorial guidance",not busy,function()
					local step=data.progression.tutorialStep
					tab=if step=="recruit" or step=="party" or step=="roster" then "Party" elseif step=="equip" then "Inventory" elseif step=="quest" or step=="claim" or step=="supplies" then "Quests" else "Guild"
					if step=="equip" then inventoryFocus="a:Warrior" end
					UI.Render(true)
					if step=="upgrade" then task.defer(function()
						local target=scroll:FindFirstChild("UpgradeGuildHall",true)
						if target and target:IsA("GuiObject") then scroll.CanvasPosition=Vector2.new(0,target.AbsolutePosition.Y-scroll.AbsolutePosition.Y+scroll.CanvasPosition.Y) end
					end) end
				end).Name="TutorialNextStep"
			end
		end
		local expansionCard=card(scroll,"Adventures and growth")
		for _,name in ipairs({"Base","Skills","Tower","Tavern","Journal","Dispatch","Bestiary","Settings"}) do button(expansionCard,name,not busy,function() tab=name;UI.Render(true) end).Name="Open"..name end
		if snapshot.catalog.StatusAllocationAvailable then button(expansionCard,"Status points",not busy,function()tab="Status";UI.Render(true)end).Name="OpenStatus" end
		local c=data.character
		if c then
			local characterCard=card(scroll,"Your character")
			if c.classId then
				ClassBadge(characterCard,c.classId,T)
				local path=snapshot.catalog.Expansion.Paths[c.classPathId]
				text(characterCard,T(if path then path.Name else c.classId).." · "..T(c.raceId).." · "..T("Class tier").." "..c.tier.." · Lv"..c.level.." · "..c.xp.." XP")
				if c.stats then text(characterCard,T("HP {hp} / Attack {attack} / Defense {defense}",{hp=c.stats.Health,attack=c.stats.Attack,defense=c.stats.Defense}),16) end
				text(characterCard,"Explore the Goblin Camp. Click or F to attack; Q uses your class skill. Touch buttons work too.",16)
				text(characterCard,"Your class includes a training weapon.",14,colors.Muted)
			else
				text(characterCard,"Choose your starter class. Each class has one skill. This choice cannot be changed.",16)
				for _,id in ipairs(snapshot.catalog.AdventurerOrder) do
					button(characterCard,(if classChoice==id then "✓ " else "")..T(id).." · "..T(snapshot.catalog.Roles[id]),not busy,function() classChoice=id; UI.Render() end).Name="Choose"..id
				end
				if classChoice then
					local names={Warrior="Power Strike",Knight="Taunt",Archer="Piercing Shot",Mage="Fireball",Priest="Heal"}
					text(characterCard,T("Starter skill")..": "..T(names[classChoice]),16)
					button(characterCard,T("Confirm class")..": "..T(classChoice),not busy,function() act("SelectPlayerClass",{classId=classChoice}) end).Name="ConfirmClass"
				end
			end
		end
		if not priorityHall then guildHall(data) end
	end
	local function party(data: any)
		local gear=require(game.ReplicatedStorage.Shared.Data.Equipment)(snapshot.catalog)
		local management = card(scroll, "One expedition party")
		text(management, "Recruit at the tavern. Selected heroes fight alongside you in the Goblin Camp.", 16, colors.Muted)
		text(management, "Select up to five adventurers, then save. Your saved team follows you while exploring.", 16)
		local members = {}
		for id in pairs(data.adventurers) do if selected[id] then table.insert(members,id) end end;table.sort(members)
		text(management, T("Selected: {count}/{limit}", { count = #members, limit = snapshot.catalog.PartyLimit }), 17)
		if #members==0 then require(script.Parent.EmptyState)(management,"empty_party",T) end
		button(management, if data.quests.active then "Party locked during expedition" else "Save selected party", (#members > 0 or (data.character and data.character.classId ~= nil)) and not data.quests.active and not busy, function()
			partyDirty = false; act("UpdateParty", { adventurerIds = members })
		end)
		local entries={}
		local ids={};for id in pairs(data.adventurers) do table.insert(ids,id) end;table.sort(ids)
		for _,id in ipairs(ids) do table.insert(entries,{id=id,class=data.adventurers[id].classId}) end
		for _,classId in ipairs(snapshot.catalog.AdventurerOrder) do if not data.progression.recruitedClasses[classId] then table.insert(entries,{id="a:"..classId,class=classId}) end end
		for _,entry in ipairs(entries) do
			local classId,id=entry.class,entry.id;local definition=snapshot.catalog.Adventurers[classId]
			local adventurer=data.adventurers[id]
			local frame = card(scroll, T(if adventurer then adventurer.name else definition.Name) .. " · " .. T(classId))
			frame.Name="PartyMember_"..id
			ClassBadge(frame,classId,T)
			text(frame, snapshot.catalog.Roles[classId], 16, colors.Accent)
			if adventurer then
				text(frame,T("Rank")..": "..adventurer.rank.." · "..id.." · "..T(adventurer.condition or "Healthy"),16)
				local build=data.expansion.actors[id]
				if build and build.path then text(frame,snapshot.catalog.Expansion.Paths[build.path].Name,16,colors.Accent) end
				local onRun = false
				if data.quests.active then
					for _, member in ipairs(data.quests.active.partySnapshot) do if member.id == id then onRun = true end end
				end
				for _,job in pairs(data.settlement.jobs) do if table.find(job.members,id) then onRun=true end end
				text(frame, if onRun then "On expedition" elseif table.find(data.party.adventurerIds,id) then "Following" else "Resting at guild", 16, colors.Muted)
				text(frame, T("Level {level} · {xp} total XP", { level = adventurer.level, xp = adventurer.xp }), 17)
				text(frame, T("HP {hp} / Attack {attack} / Defense {defense}", { hp = adventurer.stats.Health, attack = adventurer.stats.Attack, defense = adventurer.stats.Defense }), 16, colors.Muted)
				local weaponId=adventurer.equipmentSlots and adventurer.equipmentSlots.weapon
				local weapon=weaponId and data.inventory.equipment[weaponId]
				text(frame,if weapon then T("weapon")..": "..T(snapshot.catalog.Items[weapon.definitionId].Name) else T(gear.weaponHint(data,adventurer) or "Empty"),16,if weapon then colors.Muted else colors.Accent)
				button(frame,"Manage equipment",not busy,function() inventoryFocus=id;tab="Inventory";UI.Render(true) end).Name="PartyEquipment_"..id
				local recovered=adventurer.condition=="Injured" and snapshot.serverTime+os.clock()-receivedAt>=(adventurer.injuredUntil or math.huge)
				button(frame, if selected[id] then "Selected · tap to remove" else "Add to party", not onRun and (not adventurer.condition or adventurer.condition=="Healthy" or recovered) and not data.quests.active and not busy and (selected[id] or #members<5), function()
					selected[id] = not selected[id]; partyDirty = true; UI.Render()
				end)
			else
				text(frame, T("Recruitment: {amount} Gold", { amount = definition.Cost }), 17)
				if definition.Weapon then text(frame,"Includes a training weapon. Equip it after recruitment.",14,colors.Muted) end
				button(frame, T("Recruit {class}", { class = T(classId) }), data.gold >= definition.Cost and not busy, function() act("Recruit", { classId = classId }) end)
			end
		end
	end
	local function quests(data: any)
		local navigation=card(scroll,"Quest journal");button(navigation,"Main / Side / NPC quests",not busy,function() tab="Journal";UI.Render(true) end);button(navigation,"Map Overview",not busy,function() tab="Dispatch";UI.Render(true) end)
		local run = data.quests.active
		if run then
			local frame = card(scroll, T("Active · {quest}", { quest = T(snapshot.catalog.Quests[run.questId].Name) }))
			countdown = text(frame, "Your party is on its way.")
			text(frame, "Your party faces Goblin Scouts. Return here when the expedition ends.", 16, colors.Muted)
			activeButton = button(frame, "Claim rewards when ready", not busy, function() act("CompleteQuest", { runId = run.runId }) end)
		end
		if data.quests.lastResult then
			local result = data.quests.lastResult
			local frame = card(scroll, T("Last result · {quest}", { quest = T(result.questName) }))
			text(frame, rewardText(result.reward), 17)
			text(frame, "Rewards added to your guild. Prepare your party for the next expedition.", 15, colors.Muted)
		end
		for _, questId in ipairs(snapshot.catalog.QuestOrder) do
			local quest = snapshot.catalog.Quests[questId]
			local frame = card(scroll, quest.Name)
			text(frame, quest.Description, 17)
			text(frame, T("{seconds} sec base · {count} Goblin Scout(s). Equipped weapons shorten the timer.", { seconds = quest.Duration, count = quest.EnemyCount }), 15, colors.Muted)
			text(frame, rewardText(if data.quests.firstClears[questId] then quest.Repeat else quest.First), 16)
			local reason = nil
			if #data.party.adventurerIds < quest.Requirements.PartySize then reason = "Create a party first"
			elseif quest.Requirements.FirstClear and not data.quests.firstClears[quest.Requirements.FirstClear] then reason = T("Complete {quest} first", { quest = T(snapshot.catalog.Quests[quest.Requirements.FirstClear].Name) })
			elseif run then reason = "Finish your active expedition" end
			button(frame, reason or "Start expedition", reason == nil and not busy, function() act("StartQuest", { questId = questId }) end)
		end
	end
	local drawInventory=require(script.Parent.InventoryView)({scroll=scroll,T=T,card=card,text=text,button=button,act=act,render=function(reset: boolean?) UI.Render(reset) end,
		focusActor=function() local id=inventoryFocus;inventoryFocus=nil;return id end})
	local function inventory(data: any) drawInventory(data,snapshot.catalog,busy) end

	local dispatchRefresh=0
	function UI.Tick()
		worldNotice.Visible=os.clock()<worldNoticeUntil and not MenuRouter.isBlocking() and not titleView.isOpen()
		if (tab=="Dispatch" or tab=="Tavern") and snapshot and snapshot.data and not busy and panel.Visible and os.clock()-dispatchRefresh>5 then dispatchRefresh=os.clock();UI.Render() end
		if countdown and snapshot and snapshot.data and snapshot.data.quests.active then
			local left = math.max(0, math.ceil(snapshot.data.quests.active.completeAt - (snapshot.serverTime + os.clock() - receivedAt)))
			countdown.Text = if left > 0 then T("Returning in {seconds} seconds", { seconds = left }) else T("Expedition complete. Your rewards are ready.")
			if activeButton then
				activeButton.Text = if left > 0 then T("Returning in {seconds}s", { seconds = left }) else T("Claim Gold, XP and items")
				activeButton.Active = left == 0 and not busy
				activeButton.Selectable = activeButton.Active
				activeButton.AutoButtonColor = activeButton.Active
				activeButton.BackgroundColor3 = if activeButton.Active then colors.Button else colors.Card
				activeButton.TextColor3 = if activeButton.Active then colors.Text else colors.Muted
			end
		end
	end
	local retainScroll=require(script.Parent.ScrollRetention)(scroll)
	function UI.Render(resetScroll: boolean?, focusName:string?)
		retainScroll(resetScroll,focusName)
		countdown = nil; activeButton = nil
		if resetScroll then scroll.CanvasPosition = Vector2.zero end
		for _, child in ipairs(scroll:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
		for name, b in pairs(tabButtons) do
			b.BackgroundColor3 = if name == tab then colors.Accent else colors.Card
			b.TextColor3 = if name == tab then colors.Background else colors.Muted
			b.Text = T(name)
		end
		local data = snapshot and snapshot.data
		tracked=ProjectTracker(data,snapshot and snapshot.catalog,pinnedQuest)
		player.PlayerGui:SetAttribute("GuildbornePinnedQuest",pinnedQuest)
		tracker.Active=not busy and snapshot~=nil and snapshot.status=="Active";tracker.Selectable=tracker.Active
		local inputName=UserInputService:GetLastInputType().Name
		local hint=if inputName=="Touch" or string.sub(inputName,1,7)=="Gamepad" then "" else " [J]"
		if tracked and tracked.kind=="Tutorial" then tracker.Text=T("Next step")..hint.."\n"..T(tracked.tab)
		elseif tracked then
			tracker.Text=T(if tracked.kind=="CampaignComplete" then "Journey complete" elseif tracked.kind=="Available" then "Next quest" elseif tracked.ready then "Ready to claim" else "Tracked quest")..hint.."\n"..T(tracked.name)..(if tracked.kind=="Active" then " "..tracked.progress.."/"..tracked.count else "")
		else tracker.Text=T("Quest journal")..hint end
		toggle.Text = T(if panel.Visible then "Explore" else "Guild menu")
		gold.Text = if data then T("{gold} Gold · Hall Lv{level}", { gold = data.gold, level = data.hallLevel }) else T("Guildborne · Loading")
		tutorial.Text = T(if tracked and (tracked.kind=="Novice"or tracked.kind=="Campaign"or tracked.kind=="CampaignComplete")then tracked.name elseif data then tutorialText[data.progression.tutorialStep] or "Choose your next guild task." else "Preparing your Personal Guild…")
		if compactLayout then text(scroll, tutorial.Text, 14) end
		local saveLabel = if busy then "Saving…" elseif snapshot and snapshot.status == "Active" then (if string.find(snapshot.mode, "memory") then "Session only" else "Saved") else (snapshot and snapshot.status or "Loading")
		status.Text = T(saveLabel) .. " · " .. T(notice)
		if not snapshot or not data then
			local frame = card(scroll, "Loading your guild")
			text(frame, if snapshot and snapshot.problem then T("Your profile could not load: {reason}. No default data has replaced it.", { reason = T(snapshot.problem) }) else "Waiting for the server. Please keep this window open.", 17)
			button(frame, if language == "en" then "ภาษาไทย (TH)" else "English (EN)", not busy, function()
				language = if language == "en" then "th" else "en"; UI.Render()
			end)
			if snapshot then text(frame, snapshot.mode, 15, colors.Muted) end
			button(frame, "Retry loading", snapshot ~= nil and snapshot.status == "LoadFailed" and not busy, function() act("RetryLoad") end).Name="RetryLoad"
			return
		end
		if snapshot.status ~= "Active" then
			local frame = card(scroll, "Progression temporarily paused")
			text(frame, "The server is resolving your saved state. Further progression is blocked to protect your guild.", 17)
			text(frame, snapshot.problem or snapshot.status, 16, colors.Muted)
			button(frame, "Retry save / recovery", snapshot.status == "Degraded" and not busy, function() act("RetrySave") end).Name="RetrySave"
			if snapshot.status == "LeaseLost" then text(frame, "Rejoin to reload the authoritative profile.", 16) end
			return
		end
		if tab == "Dialogue" and friendlyNpc and friendlyNpcs[friendlyNpc] then
			local entry=friendlyNpcs[friendlyNpc]
			local frame=card(scroll,if language=="th" then entry.nameTh.." · "..entry.roleTh else entry.name.." · "..entry.role)
			frame.Name="FriendlyDialogue_"..friendlyNpc
			local portraitSize=if scroll.AbsoluteSize.Y<180 then 64 else 108
			local row=Instance.new("Frame");row.Name="Speaker";row.BackgroundTransparency=1;row.Size=UDim2.new(1,0,0,portraitSize);row.AutomaticSize=Enum.AutomaticSize.Y;row.Parent=frame
			local portrait=require(script.Parent.ActorPortrait)(row)
			local source:Model?=nil
			for _,model in ipairs(game:GetService("CollectionService"):GetTagged("GuildborneFriendlyNPC")) do
				if model:IsA("Model") and model:GetAttribute("NpcId")==friendlyNpc then source=model;break end
			end
			portrait.update(source)
			local view=row:FindFirstChild("Portrait") :: ViewportFrame;view.Size=UDim2.fromOffset(portraitSize,portraitSize);view.Position=UDim2.fromOffset(0,0)
			view.BackgroundColor3=colors.Background;view.BackgroundTransparency=0;corner(view)
			local speech=text(row,if language=="th" then entry.th else entry.en,18)
			if source then speech.Size=UDim2.new(1,-portraitSize-12,0,0);speech.Position=UDim2.fromOffset(portraitSize+12,0) end
			local taskStates=require(game:GetService("ReplicatedStorage").Shared.Data.QuestNpcState)(data,snapshot.catalog,entry.name,true)
			if #taskStates>0 then
				for index,taskState in ipairs(taskStates) do
					text(frame,taskState.state,16)
					button(frame,T(snapshot.catalog.Journal[taskState.id].Name),not busy,function()
						UI.OpenJournalQuest(taskState.id)
					end).Name=if index==1 then "NpcWork" else "NpcWork_"..taskState.id
				end
			else
				for _,id in ipairs(snapshot.catalog.JournalOrder) do
					local def=snapshot.catalog.Journal[id]
					if def.RequiresRegionalCombat and snapshot.catalog.RegionalCombatAvailable~=true then continue end
					if def.NPC==entry.name and not data.settlement.journal[id] and def.Requires then
						text(frame,T("Complete {quest} first",{quest=T(snapshot.catalog.Journal[def.Requires].Name)}),16)
					end
				end
			end
			button(frame,if language=="th" then "ไว้คุยกันใหม่" else "See you soon",true,function()panel.Visible=false end).Name="CloseDialogue"
		elseif tab=="Islands" then drawIslands(snapshot.islands or {},busy,snapshot.islandVisitors or {})
		elseif tab=="Themes" then drawThemes(data,busy)
		elseif tab == "Land" then require(script.Parent.GuildLandView)({scroll=scroll,T=T,card=card,text=text,button=button,act=act,navigate=function(name: string)tab=name;UI.Render(true)end},data,snapshot.catalog,busy)
		elseif tab == "Bestiary" then drawBestiary(snapshot.catalog,busy)
		elseif tab == "Settings" then
			local settingsCard = card(scroll, "Settings")
			settingsCard.Name="PresentationSettingsCard"
			button(settingsCard, "Back to Guild", true, function() tab = "Guild"; UI.Render(true) end)
			require(script.Parent.SettingsControls)(settingsCard, T)
			local collectionCard=card(scroll,"Cosmetic collection preview")
			collectionCard.Name="CosmeticCollection"
			require(script.Parent.CosmeticPreview)(collectionCard,T)
		elseif tab == "Guild" then guild(data) elseif tab == "Party" then party(data) elseif tab == "Quests" then quests(data) elseif tab=="Inventory" then inventory(data) elseif tab=="Tavern" or tab=="Journal" or tab=="Dispatch" then drawSettlement(tab,data,snapshot.catalog,busy) else drawExpansion(tab,data,snapshot.catalog,busy) end
		UI.Tick()
	end
	function UI.Update(view: any, message: string?)
		local changed = not snapshot or snapshot.revision ~= view.revision or snapshot.status ~= view.status
			or snapshot.problem ~= view.problem or snapshot.mode ~= view.mode or message ~= nil or view.navigate ~= nil
  local oldCampaign=snapshot and snapshot.data and snapshot.data.progression and snapshot.data.progression.campaign
  local newCampaign=view.data and view.data.progression and view.data.progression.campaign
  if not message and noticeCode and string.sub(noticeCode,1,17)=="CampaignCompanion" and oldCampaign and newCampaign then
   local advanced=newCampaign.claimed>oldCampaign.claimed
   for id,done in pairs(newCampaign.objectives)do if done and not oldCampaign.objectives[id]then advanced=true end end
   if advanced then notice="Story progress saved.";noticeCode=nil;worldNoticeUntil=0;changed=true end
  end
		snapshot = view; receivedAt = os.clock()
		titleView.update(view)
		if view.data then language = view.data.language or "en";builder.update(view.data) end
		-- Polls refresh the clock without replacing controls while the player is tapping/scrolling.
		if not changed then UI.Tick(); return end
		if view.status~="Active" and view.status~="Loading" then panel.Visible=true end
		if message then notice = message;noticeCode=view.code end
		if message and view.code and view.code~="OK" and view.code~="AlreadyCommitted" and not panel.Visible and not titleView.isOpen() then
			worldNotice.Text=T(message);worldNoticeUntil=os.clock()+6
		end
		local navigateQuest: string?=nil
		if type(view.navigate)=="string" and string.sub(view.navigate,1,12)=="FriendlyNPC:" then
			local id=string.sub(view.navigate,13)
			if friendlyNpcs[id] then friendlyNpc=id;tab="Dialogue";panel.Visible=true;scroll.CanvasPosition=Vector2.zero end
		end
		if type(view.navigate)=="string" and string.sub(view.navigate,1,11)=="JournalNPC:" then
			local npc=string.sub(view.navigate,12)
			local state=require(game:GetService("ReplicatedStorage").Shared.Data.QuestNpcState)(view.data,view.catalog,npc)
			journalFocus=state and state.id;navigateQuest=journalFocus;tab="Journal";panel.Visible=true;scroll.CanvasPosition=Vector2.zero
		end
		if view.navigate and (tabButtons[view.navigate] or view.navigate=="Islands" or view.navigate=="Base" or view.navigate=="Skills" or view.navigate=="Tower" or view.navigate=="Tavern" or view.navigate=="Journal" or view.navigate=="Dispatch") then tab = view.navigate; panel.Visible = true; scroll.CanvasPosition = Vector2.zero end
		if view.data and not partyDirty then
			table.clear(selected)
			for _, id in ipairs(view.data.party.adventurerIds) do selected[id] = true end
		end
		UI.Render(nil,if navigateQuest then "Journal_"..navigateQuest else nil)
		if tab=="Dialogue" and view.navigate and friendlyNpc then
			local id=friendlyNpc
			task.defer(function()
				game:GetService("RunService").RenderStepped:Wait()
				local target=scroll:FindFirstChild("FriendlyDialogue_"..id)
				if tab=="Dialogue" and target and target:IsA("GuiObject") then scroll.CanvasPosition=Vector2.new(0,math.max(0,scroll.CanvasPosition.Y+target.AbsolutePosition.Y-scroll.AbsolutePosition.Y-8)) end
			end)
		end
	end
	function UI.OpenJournalQuest(id:string)
		journalFocus=id;tab="Journal";panel.Visible=true;UI.Render(true,"Journal_"..id)
	end
	function UI.SetBusy(value: boolean) busy = value; UI.Render() end
	toggle.Activated:Connect(function() panel.Visible = not panel.Visible; toggle.Text = T(if panel.Visible then "Explore" else "Guild menu") end)
	local function openTracked()
		if busy or titleView.isOpen() or not snapshot or snapshot.status~="Active" then return end
		journalFocus=tracked and tracked.id;tab=if tracked then tracked.tab else "Journal";panel.Visible=true
		UI.Render(true,if tab=="Guild"and tracked then tracked.focus elseif tab=="Journal"and tracked then "Journal_"..tracked.id else nil)
	end
	tracker.Activated:Connect(openTracked)
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and not titleView.isOpen() and input.KeyCode == Enum.KeyCode.M then panel.Visible = not panel.Visible; toggle.Text = T(if panel.Visible then "Explore" else "Guild menu") end
		if not processed and input.KeyCode==Enum.KeyCode.J then openTracked() end
	end)
	panel:GetPropertyChangedSignal("Visible"):Connect(function() toggle.Text=T(if panel.Visible then "Explore" else "Guild menu") end)
	UI.Render()
	return UI
end
