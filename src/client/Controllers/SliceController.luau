--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Localization = require(ReplicatedStorage.Shared.Config.Localization)
local Audio=require(script.Parent.AudioController)

return function(makeUI: any)
	-- The slice has no player-list workflow; keep the guild HUD clear on narrow screens.
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	local remotes = ReplicatedStorage:WaitForChild("GuildborneRemotes")
	local command = remotes:WaitForChild("Command") :: RemoteEvent
	local state = remotes:WaitForChild("State") :: RemoteEvent
	local revision = 0
	local pending: string? = nil
	local sentAt = 0
	local ui: any
	local feedback=require(ReplicatedStorage.Shared.Data.AudioFeedback)()
	local messages: { [string]: string } = {
		OK = "Action completed.", AlreadyCommitted = "This action was already saved.", InvalidRequest = "The server rejected an invalid request.",
		Busy = "Another operation is still running. Try again shortly.", StaleRevision = "Your guild was refreshed. Review it and try again.",
		SavePending = "Save outcome pending. Use Retry save; rewards have not been shown early.", StorageUnavailable = "Storage is unavailable. Retry in a moment.",
		ProfileInUse = "Your previous session is still closing. Wait, then retry loading.", LeaseExpiring = "Refreshing your session. Please retry shortly.",
		LeaseLost = "This session lost ownership. Rejoin to reload your guild.", InsufficientGold = "You need more Gold. Complete a quest first.",
		MissingMaterials = "Collect the remaining Hall materials from quests.", HallLocked = "Complete Quarry Patrol first.",
		HallAlreadyUpgraded = "Your Hall is already level 2.", AlreadyRecruited = "This adventurer is already in your roster.",
		QuestActive = "Finish your active expedition first.", QuestLocked = "Complete the earlier quest first.",
		QuestTooEarly = "Your expedition has not finished yet.", QuestNotActive = "That run is not active or was already claimed.",
		PartyRequired = "Select at least one adventurer and save your party.", InvalidParty = "Choose one to five different owned adventurers.",
		ItemNotOwned = "That weapon is not in your inventory.", IncompatibleWeapon = "That weapon does not fit this class.",
		InventoryFull = "Inventory is full. Your quest remains claimable; no reward was consumed.",
		AuditBacklog = "Your saved history is catching up. Please retry later.", InternalError = "An unexpected error paused this session. Rejoin safely.",
	}
	messages.CampaignHallLocked="Complete the guild quest and claim the required Hall permit first."
	messages.CampaignCompanionParticipation="Combat rewards saved. For this story objective, bring a companion into the fight and defeat the enemy again."
	messages.CampaignCompanionUnavailable="Combat rewards saved. Keep a participating companion alive and nearby, then defeat the enemy again."
	messages.CampaignCompanionTooFar="Combat rewards saved. Stay within 30 studs of a living, participating companion when the enemy falls. Retry when it returns."
	messages.CampaignHallRequired="Upgrade your Hall to the chapter's required level first."
	messages.CampaignLocked="Found your guild before continuing its story."
	messages.CampaignUnavailable="This guild story is not available in this world."
	messages.CampaignLevelRequired="Reach the chapter's required level first."
	messages.ChapterIncomplete="Complete every objective before claiming this chapter."
	messages.ChapterNotActive="That chapter was already claimed or is not available yet."
	messages.UnexpectedRecruitChoice="Review the active chapter and choose your companion again."
	messages.InvalidCampaignChoice="Choose one of the available story options."
	messages.ResourceTooFar="Move closer to the resource."
	messages.InvalidFurniture="Choose furniture from your own collection."
	messages.FurnitureLimit="Furniture limit reached"
	messages.FurnitureAlreadyStored="This furniture is already stored."
	messages.LayoutFurnitureMissing="Furniture in this layout was recycled. Save a new layout."
	messages.ResourceCooling="This resource is still regrowing."
	messages.WarehouseFull="Gathering storage is full. Build a Warehouse."
	messages.InvalidPlacement="This location is blocked or outside the build grid."
	messages.PlotLocked="Open this plot before building here."
	messages.ReservedAccess="Keep the arrival path clear."
	messages.BuildingOverlap="Another building occupies this space."
	messages.EntranceBlocked="Keep the entrance clear"
	messages.AccessBlocked="Keep a walking route open"
	messages.OutsideIsland="This location is blocked or outside the build grid."
	messages.IslandPrivate="This island is private."
	messages.FriendsOnly="This island welcomes the owner's friends only."
	messages.IslandFull="This island has reached its visitor limit."
	messages.IslandUnavailable="This island is temporarily unavailable."
	messages.VisitBusy="Please wait before requesting another island visit."
	messages.FriendshipUnavailable="Friendship could not be checked. Please try again."
	messages.VisitBlocked="The owner has ended your visit."
	messages.VisitorNotPresent="This visitor is no longer on your island."
	messages.InvalidLayoutSlot="Choose layout slot 1, 2 or 3."
	messages.LayoutNotFound="Save a layout in this slot first."
	messages.LayoutBuildingMissing="A building in this layout was dismantled. Save a new layout."
	messages.ThemeNotOwned="Unlock this theme before applying it."
	messages.ThemeQuestRequired="Complete and claim the required quest first."
	messages.ThemePurchaseUnavailable="Robux theme purchase is not available yet. No payment has been taken."
	messages.ThemeAlreadyOwned="This theme is already in your collection."
	messages.BuildingLimit="You already own this building."
	messages.ForgeRequired="Build a Blacksmith first."
	messages.QuartersRequired="Build Hero Quarters first."
	messages.AdvancementLocked="Reach the required level and complete the class trial."
	messages.SecretUndiscovered="The secret conditions are not complete."
	messages.SkillPrerequisite="Learn the prerequisite and reach the required class tier."
	messages.NoSkillPoints="Not enough skill points."
	messages.SkillBranchConflict="Focus and Ward cannot be learned together."
	messages.SkillNotLearned="Learn this art before equipping it."
	messages.AlreadyLearned="This skill is already learned."
	messages.NoSkillsToReset="There are no skills to reset."
	messages.RaceAlreadyChosen="Your ancestry choice is already saved."
	messages.FinishExpedition="Finish your expedition first."
	messages.TowerActive="A tower attempt is already active."
	messages.FloorLocked="Clear the checkpoint first."
	messages.TowerNotReady="The tower is not ready for that action."
	messages.LeaveTowerFirst="Leave the tower before changing your build."
	messages.ReturnToGuild="Return to your guild and leave combat first."
	messages.InvalidClassPath="This path does not match your current class."
	messages.MissingMaterials="Gather or earn the required materials first."
	messages.TravelCooling="Wait a moment before travelling again."
	messages.TravelUnavailable="The destination is obstructed. Please try again shortly."
	messages.VisitStation="Visit the relevant portal or NPC first."
	messages.RosterFull="Housing is full. Upgrade Quarters and Guild Hall."
	messages.HousingOccupied="Quarters cannot be removed while housing more than five heroes."
	messages.HallRequired="Upgrade your Guild Hall first."
	messages.TavernMax="Tavern is already at maximum level."
	messages.OfferExpired="This candidate is no longer available."
	messages.HeroUnavailable="This hero is assigned elsewhere or is not healthy."
	messages.TaskIncomplete="Complete the quest objectives first."
	messages.QuestAlreadyAccepted="This quest is already accepted."
	messages.DispatchFull="Three teams are already dispatched."
	messages.ElixirRequired="You need one revival Elixir."
	messages.HeroNotDead="This hero does not need revival."
	messages.QuestLocked="Complete the required quests first."
	messages.RegionalEncountersUnavailable="Regional encounters are not open yet."
	messages.PurchaseRequired="This plot requires a verified purchase before materials can be delivered."
	messages.MaterialsRequired="Deliver the remaining materials before opening this plot."
	messages.AlreadyUnlocked="Purchase eligibility for this plot is already saved."
	messages.AlreadyOpen="This plot is already open."
	messages.UnknownPlot="This plot is not available."
	messages.LandUnavailable="Land information is unavailable."
	messages.InvalidContribution="Choose a valid material amount."
	messages.ContributionExceedsRemaining="That amount exceeds the materials still required."
	messages.StatusUnavailable="Status allocation is not available in this world."
	messages.ReturnToHallForPoints="Return near your own Guild Hall, outside combat, to change points."
	messages.NotEnoughStatusPoints="Not enough AP, or this stat has reached its limit."
	messages.InvalidAllocation="Choose a valid stat and a positive whole number of points."
	messages.NoPointsToReset="There are no spent SP or AP to reset."
	messages.FinishYourExpedition="Finish your expedition before changing points."
	messages.UseBuildPointReset="Use the free SP and AP reset in Status points."
	local function send(action: string, args: any)
		if pending and action ~= "GetState" then return end
		local requestId = HttpService:GenerateGUID(false)
		if action ~= "GetState" then pending = requestId; sentAt = os.clock(); ui.SetBusy(true) end
		command:FireServer({ version = 1, requestId = requestId, action = action, revision = revision, args = args })
	end
	ui = makeUI(send)
	local questMarkers=require(script.Parent.QuestNpcMarkers)()
	local resourceMarkers=require(script.Parent.ResourceNodeMarkers)()
	state.OnClientEvent:Connect(function(view: any)
		local responseToAction=pending~=nil and view.requestId==pending
		questMarkers.Update(view)
		resourceMarkers.Update(view)
		revision = view.revision
		if pending and (view.requestId == pending or os.clock() - sentAt > 10) then pending = nil; ui.SetBusy(false) end
		local message = if view.code then messages[view.code] or Localization.translate(
			if view.data then view.data.language or "en" else "en", "Please retry or rejoin. Code: {code}", { code = view.code }) else nil
		if view.result and view.result.reward then message = "Rewards saved. Open Quests to review your result." end
		local cue=feedback(view,responseToAction);if cue then Audio.Play(cue) end
		if view.navigate=="CityFuture" or view.navigate=="Market" then view=table.clone(view);view.navigate=nil end
		ui.Update(view, message)
	end)
	send("GetState", {})
	task.spawn(function()
		local lastPoll = os.clock()
		while true do
			task.wait(0.25); ui.Tick()
			if os.clock() - lastPoll >= 5 then lastPoll = os.clock(); send("GetState", {}) end
		end
	end)
	print("[Guildborne] Phase 1 client ready")
end
