--!strict
-- Manual Studio CLIENT Command Bar probe. Never mapped into the shipped place.
-- Requires a fresh memory or isolated QA DataStore profile. Uses only public intents.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
assert(RunService:IsStudio() and RunService:IsClient(), "Run from Studio's CLIENT Command Bar")
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("GuildborneRemotes")
local command = remotes:WaitForChild("Command") :: RemoteEvent
local state = remotes:WaitForChild("State") :: RemoteEvent
local latest: any = nil
local waiting: string? = nil
local answer: any = nil
local connection = state.OnClientEvent:Connect(function(view: any)
	latest = view
	if waiting and (view.requestId == waiting or (view.code == "InvalidRequest" and view.requestId == nil)) then answer = view end
end)
local function transmit(packet: any, expected: string?): any
	task.wait(0.65)
	for _ = 1, 8 do
		answer = nil; waiting = packet.requestId
		command:FireServer(packet)
		local deadline = os.clock() + 30
		while not answer and os.clock() < deadline do task.wait(0.05) end
		if not answer or answer.code ~= "Busy" then break end
		task.wait(1)
	end
	waiting = nil
	assert(answer, "No response: " .. packet.action)
	assert(answer.code == expected, packet.action .. " expected " .. tostring(expected) .. ", got " .. tostring(answer.code))
	print("GBQA PASS", packet.action, expected, "revision", answer.revision, "gold", answer.data and answer.data.gold)
	return packet
end
local function send(action: string, args: any?, expected: string?): any
	return transmit({ version = 1, requestId = HttpService:GenerateGUID(false), revision = if latest then latest.revision else 0,
		action = action, args = args or {} }, expected or "OK")
end
_G.GBBaselineDone=false; _G.GBBaselineError=nil
task.spawn(function()
	local ok, problem = pcall(function()
		transmit({ version = 1, requestId = HttpService:GenerateGUID(false), revision = 0, action = "GetState", args = {} }, nil)
		assert(latest.status == "Active" and latest.data.gold == 0 and next(latest.data.adventurers) == nil, "Fresh profile required")
		send("SetLanguage", { language = "th" }); assert(latest.data.language == "th")
		send("SetLanguage", { language = "fr" }, "InvalidRequest")
		send("BeginTutorial"); send("Recruit", { classId = "Warrior" })
		send("UpdateParty", { adventurerIds = { "a:Warrior", "a:Warrior" } }, "InvalidParty")
		send("UpdateParty", { adventurerIds = { "a:Foreign" } }, "InvalidParty")
		local partyPacket = send("UpdateParty", { adventurerIds = { "a:Warrior" } })
		local revision = latest.revision
		transmit(partyPacket, "AlreadyCommitted"); assert(latest.revision == revision)
		partyPacket.args.adventurerIds = {}; transmit(partyPacket, "RequestConflict")
		send("UpgradeGuildHall", {}, "HallLocked")
		send("StartQuest", { questId = "missing" }, "InvalidQuest")
		send("CompleteQuest", { runId = "q:999999" }, "QuestNotActive")
		send("CompleteQuest", { runId = "q:999999", gold = 1000000 }, "InvalidRequest")
		send("EquipItem", { instanceId = "foreign:weapon", adventurerId = "a:Warrior" }, "ItemNotOwned")
		for _, questId in ipairs({ "trail_watch", "timber_escort", "quarry_patrol" }) do
			send("StartQuest", { questId = questId })
			local run = latest.data.quests.active
			local beforeGold, beforeRevision = latest.data.gold, latest.revision
			send("CompleteQuest", { runId = run.runId }, "QuestTooEarly")
			assert(latest.data.gold == beforeGold and latest.revision == beforeRevision)
			send("UpdateParty", { adventurerIds = { "a:Warrior" } }, "QuestActive")
			task.wait(math.max(0, run.completeAt - latest.serverTime) + 1)
			local claim = send("CompleteQuest", { runId = run.runId })
			local gold, committedRevision = latest.data.gold, latest.revision
			transmit(claim, "AlreadyCommitted"); assert(latest.data.gold == gold and latest.revision == committedRevision)
			send("CompleteQuest", { runId = run.runId }, "QuestNotActive"); assert(latest.data.gold == gold)
			if questId == "trail_watch" then
				send("EquipItem", { instanceId = "q:1:1", adventurerId = "a:Warrior" })
				send("Recruit", { classId = "Archer" })
				send("EquipItem", { instanceId = "q:1:1", adventurerId = "a:Archer" }, "IncompatibleWeapon")
			elseif questId == "timber_escort" then send("Recruit", { classId = "Priest" }) end
		end
		assert(latest.data.gold == 90 and latest.data.adventurers["a:Warrior"].xp == 90)
		local hall = send("UpgradeGuildHall")
		assert(latest.data.gold == 10 and latest.data.hallLevel == 2 and latest.data.progression.tutorialCompleted)
		transmit(hall, "AlreadyCommitted"); send("UpgradeGuildHall", {}, "HallAlreadyUpgraded")
		assert(latest.data.gold == 10)
		local ui = Players.LocalPlayer.PlayerGui:FindFirstChild("GuildborneUI")
		assert(ui, "UI missing")
		print("GBQA FINAL", HttpService:JSONEncode(latest.data))
		print("GBQA NATIVE LOOP AND REJECTION TESTS PASSED")
		_G.GBBaselineDone=true
	end)
	connection:Disconnect()
	if not ok then _G.GBBaselineError=tostring(problem); warn("GBQA FAILED", problem) end
end)
