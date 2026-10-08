--!strict
-- Manual CLIENT Command Bar only; never shipped. Set _G.GBPersistenceStage to
-- "prepare", "finish", "inspect", or "thai" before pasting this file.
-- Prepare requires an unused staging profile. Never resets or edits stored data.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
assert(RunService:IsStudio() and RunService:IsClient(), "Studio CLIENT Command Bar required")
assert(game.GameId == 10768425213 and game.PlaceId == 86788611613035, "Wrong staging place")
assert(Players.LocalPlayer.UserId > 0, "Real account required")
local stage = _G.GBPersistenceStage or "inspect"
assert(stage == "prepare" or stage == "finish" or stage == "inspect" or stage == "thai", "Invalid probe stage")
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("GuildborneRemotes")
local command = remotes:WaitForChild("Command") :: RemoteEvent
local state = remotes:WaitForChild("State") :: RemoteEvent
local latest: any = nil
local waiting: string? = nil
local answer: any = nil
local connection = state.OnClientEvent:Connect(function(view: any)
	latest = view
	if waiting and view.requestId == waiting then answer = view end
end)
local function send(action: string, args: any?, expected: string?): any
	task.wait(0.8)
	local packet = { version = 1, requestId = HttpService:GenerateGUID(false), revision = if latest then latest.revision else 0,
		action = action, args = args or {} }
	for attempt = 1, 10 do
		answer = nil
		waiting = packet.requestId
		command:FireServer(packet)
		local deadline = os.clock() + 30
		while not answer and os.clock() < deadline do task.wait(0.05) end
		if not answer or answer.code ~= "Busy" then break end
		print("GBPERSIST BUSY RETRY", action, attempt)
		task.wait(2)
	end
	waiting = nil
	assert(answer, "No response: " .. action)
	assert(answer.code == expected, action .. ": expected " .. tostring(expected) .. ", got " .. tostring(answer.code))
	assert(answer.mode == "Persistent · staging" and answer.status == "Active", "Persistent active profile required")
	latest = answer
	print("GBPERSIST PASS", action, "revision", answer.revision, "gold", answer.data.gold)
	return answer
end
local function snapshot(label: string)
	print("GBPERSIST " .. label, HttpService:JSONEncode({ revision = latest.revision, data = latest.data }))
end
task.spawn(function()
	local ok, problem = pcall(function()
		send("GetState", {}, nil)
		snapshot("LOADED")
		if _G.GBPersistenceExpected then
			local expected = HttpService:JSONDecode(_G.GBPersistenceExpected)
			local util = require(game:GetService("ReplicatedStorage").Shared.Util.TableUtil)
			assert(util.equal({ revision = latest.revision, data = latest.data }, expected), "Loaded snapshot differs from saved checkpoint")
			print("GBPERSIST EXACT REJOIN MATCH", latest.revision, latest.data.language)
		end
		if stage == "prepare" then
			assert(latest.data.gold == 0 and next(latest.data.adventurers) == nil and latest.data.quests.nextRunSequence == 1 and latest.data.hallLevel == 1, "Unprogressed profile required; no reset performed")
			send("SetLanguage", { language = "th" }, "OK")
			send("BeginTutorial", {}, "OK")
			send("Recruit", { classId = "Warrior" }, "OK")
			send("UpdateParty", { adventurerIds = { "a:Warrior" } }, "OK")
			send("StartQuest", { questId = "trail_watch" }, "OK")
			assert(latest.data.language == "th" and latest.data.quests.active.runId == "q:1")
		elseif stage == "finish" then
			assert(latest.data.language == "th" and latest.data.gold == 0 and latest.data.quests.active.runId == "q:1", "Expected resumed Thai first quest")
			for index, questId in ipairs({ "trail_watch", "timber_escort", "quarry_patrol" }) do
				if index > 1 then send("StartQuest", { questId = questId }, "OK") end
				local run = latest.data.quests.active
				assert(run.questId == questId)
				task.wait(math.max(0, run.completeAt - latest.serverTime) + 1)
				send("CompleteQuest", { runId = run.runId }, "OK")
				local gold, revision = latest.data.gold, latest.revision
				send("CompleteQuest", { runId = run.runId }, "QuestNotActive")
				assert(latest.data.gold == gold and latest.revision == revision)
				if index == 1 then
					send("EquipItem", { instanceId = "q:1:1", adventurerId = "a:Warrior" }, "OK")
					send("Recruit", { classId = "Archer" }, "OK")
				elseif index == 2 then send("Recruit", { classId = "Priest" }, "OK") end
			end
			send("UpgradeGuildHall", {}, "OK")
			assert(latest.data.gold == 10 and latest.data.hallLevel == 2 and latest.data.adventurers["a:Warrior"].xp == 90)
			assert(latest.data.progression.tutorialCompleted and latest.data.quests.claimedThrough == 3)
			send("SetLanguage", { language = "en" }, "OK")
		elseif stage == "thai" then
			send("SetLanguage", { language = "th" }, "OK")
		end
		snapshot("CHECKPOINT")
		print("GBPERSIST STAGE PASSED", stage)
	end)
	connection:Disconnect()
	if not ok then warn("GBPERSIST FAILED", problem) end
end)
