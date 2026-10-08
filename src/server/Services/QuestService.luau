--!strict
return function(content: any, economy: any, progression: any, util: any)
	local Quests = {}
	function Quests.start(data: any, args: any, now: number, emit: any): string?
		local quest = content.Quests[args.questId]
		if not quest then return "InvalidQuest" end
		if data.quests.active then return "QuestActive" end
		if #data.party.adventurerIds < quest.Requirements.PartySize then return "PartyRequired" end
		if quest.Requirements.FirstClear and not data.quests.firstClears[quest.Requirements.FirstClear] then return "QuestLocked" end
		local members, bonus = {}, 0
		for _, id in ipairs(data.party.adventurerIds) do
			local stats = progression.stats(data, data.adventurers[id])
			bonus += stats.WeaponBonus
			table.insert(members, { id = id, stats = stats })
		end
		local duration = math.max(content.Progression.MinQuestDuration, quest.Duration - math.floor(bonus / content.Progression.AttackPerSecondSaved))
		local sequence = data.quests.nextRunSequence
		local firstClear = not data.quests.firstClears[quest.Id]
		data.quests.active = { runId = "q:" .. tostring(sequence), sequence = sequence, questId = quest.Id, state = "Running",
			contentVersion = content.Version, partySnapshot = members, startAt = now, completeAt = now + duration,
			firstClear = firstClear, rewardSnapshot = util.copy(if firstClear then quest.First else quest.Repeat) }
		data.quests.nextRunSequence += 1
		emit("quest_started", { questId = quest.Id, runId = data.quests.active.runId, duration = duration })
		return nil
	end
	function Quests.complete(data: any, args: any, now: number, emit: any): (string?, any?)
		local run = data.quests.active
		if not run or run.runId ~= args.runId or run.sequence <= data.quests.claimedThrough then return "QuestNotActive", nil end
		if now < run.completeAt then return "QuestTooEarly", nil end
		local reward = run.rewardSnapshot
		local problem = economy.gold(data, reward.Gold, "QuestReward", emit)
		if problem then return problem, nil end
		problem = economy.items(data, reward.Items, run.runId, emit)
		if problem then return problem, nil end
		for _, member in ipairs(run.partySnapshot) do
			local adventurer = data.adventurers[member.id]
			if adventurer.xp + reward.XP > content.Limits.XP then return "XPCapReached", nil end
			adventurer.xp += reward.XP
			adventurer.level = content:LevelFromXP(adventurer.xp,content.ProfileLevelCap(data))
		end
		data.quests.claimedThrough = run.sequence
		data.quests.firstClears[run.questId] = true
		data.statistics.questsCompleted += 1
		local result = { reward = util.copy(reward), questName = content.Quests[run.questId].Name, runId = run.runId }
		emit("quest_completed", { questId = run.questId, runId = run.runId, gold = reward.Gold, xpPerMember = reward.XP, firstClear = run.firstClear })
		data.quests.lastResult = util.copy(result)
		data.quests.active = nil
		return nil, result
	end
	return Quests
end
