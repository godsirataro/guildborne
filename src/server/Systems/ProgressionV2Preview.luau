--!strict
-- Isolated design/migration preview. Never loaded by bootstrap, never writes a save.
-- Runtime schema, rewards and recruitment retain their existing rules until cutover.
return function(content: any, legacyRules: any)
	local P = { Ruleset = "GUILD-PROGRESSION-DESIGN-2.0", RuntimeEnabled = false }
	local function integer(value: any, low: number, high: number): boolean
		return type(value) == "number" and value == value and value % 1 == 0 and value >= low and value <= high
	end
	function P.hallCap(hall: number): number
		assert(integer(hall, 0, 20), "InvalidHall")
		return content.HallLevelCap(hall,content.ProgressionRulesets.Novice)
	end
	function P.budget(level: number): (number, number)
		assert(integer(level, 1, 100), "InvalidLevel")
		return level - 1, 3 * (level - 1)
	end
	function P.effectiveStat(points: number): number
		assert(integer(points, 0, 150), "InvalidAllocation")
		return math.min(points, 40) + .6 * math.min(math.max(points - 40, 0), 40) + .3 * math.max(points - 80, 0)
	end
	function P.validateStatus(level: number, allocated: any): (boolean, string?, number)
		local _, budget = P.budget(level)
		if type(allocated) ~= "table" then return false, "InvalidAllocation", budget end
		local keys = { STR = true, DEX = true, INT = true, VIT = true, WIS = true }
		local spent = 0
		for key, points in pairs(allocated) do
			if not keys[key] or not integer(points, 0, 150) then return false, "InvalidAllocation", budget end
			spent += points
		end
		if spent > budget then return false, "Overspent", budget - spent end
		return true, nil, budget - spent
	end
	function P.canRecruit(tier: number, hall: number, hallStoryComplete: boolean): boolean
		return integer(tier, 1, 3) and integer(hall, 1, 20) and hallStoryComplete == true
	end
	function P.canPromote(level: number, currentTier: number, targetTier: number, trialComplete: boolean): boolean
		if not integer(level, 1, 100) or not integer(currentTier, 0, 3) or not integer(targetTier, 1, 3) then return false end
		local required = {10, 35, 70}
		return targetTier == currentTier + 1 and level >= required[targetTier] and trialComplete == true
	end
	-- A preview reset returns the same available budget on every call. It does not
	-- grant points, clear real allocations, reset cooldowns or write promotion receipts.
	function P.respecPreview(level: number, inSafeZone: boolean, inCombat: boolean, onExpedition: boolean): (any?, string?)
		if not inSafeZone or inCombat or onExpedition then return nil, "UnsafeRespec" end
		local sp, ap = P.budget(level)
		return { skillPoints = sp, statusPoints = ap, allocations = {}, skills = {} }, nil
	end
	function P.migrationReport(data: any): any
		assert(type(data) == "table" and type(data.character) == "table" and type(data.adventurers) == "table", "InvalidProfile")
		local hall = data.personalGuild.buildings.guildHall
		local cap = P.hallCap(hall)
		local report: any = { ruleset = P.Ruleset, appliesChanges = false, requiresReview = true,
			hallLevel = hall, proposedHallCap = cap, actors = {}, issues = {},
			preserveFields = { "inventory", "currencies", "market", "quests", "settlement", "party", "operations", "audit" } }
		local function inspect(id: string, actor: any)
			local issues = {}
			local levelValid = integer(actor.level, 1, 100)
			local xpValid = integer(actor.xp, 0, content.Limits.XP)
			if not levelValid then table.insert(issues, "InvalidLevel") end
			if not xpValid then table.insert(issues, "InvalidXP") end
			if levelValid and xpValid and actor.level ~= content:LevelFromXP(actor.xp,content.HallLevelCap(hall)) then
				table.insert(issues, "LegacyXPLevelMismatch")
			end
			if actor.classId and not content.Character.Classes[actor.classId] then table.insert(issues, "UnknownClass") end
			if id ~= "player" and not actor.classId then table.insert(issues, "MissingHeroClass") end
			local build = data.expansion and data.expansion.actors and data.expansion.actors[id]
			local tier = if build then build.tier elseif actor.classId then 1 else 0
			local path = build and build.path
			local legacy = path and legacyRules.Paths[path]
			if not integer(tier, 0, 3) then table.insert(issues, "InvalidTier") end
			if path and (not legacy or legacy.Class ~= actor.classId or legacy.Tier ~= tier) then table.insert(issues, "UnmappedLegacyPath") end
			if type(tier) == "number" and tier > 1 and not path then table.insert(issues, "MissingLegacyPath") end
			local spent = 0
			for skill, value in pairs(build and build.skills or {}) do
				local def = legacyRules.Skills[skill]
				if not def or value ~= true then table.insert(issues, "UnknownLegacySkill") else spent += def.Cost end
			end
			local sp, ap = 0, 0
			if levelValid then
				sp, ap = P.budget(actor.level)
				if spent > sp then table.insert(issues, "LegacySkillOverspend") end
			end
			-- Never derive a replacement XP value or clamp a level here. An uplift is
			-- a review proposal, not a new point budget or an applied save mutation.
			local entry = { id = id, savedLevel = actor.level, savedXP = actor.xp,
				preservedLevel = actor.level, preservedXP = actor.xp, preservedClass = actor.classId,
				preservedTier = tier, preservedPath = path,
				proposedCap = cap, retainLevelAboveCap = levelValid and actor.level > cap,
				proposedHeroUplift = if id ~= "player" and levelValid and actor.level < 10 then 10 else nil,
				skillBudgetAtSavedLevel = sp, statusBudgetAtSavedLevel = ap, legacySkillSpent = spent,
				quarantine = #issues > 0, issues = issues }
			table.insert(report.actors, entry)
			for _, issue in ipairs(issues) do table.insert(report.issues, {actorId=id, code=issue}) end
		end
		inspect("player", data.character)
		local ids = {}; for id in pairs(data.adventurers) do table.insert(ids, id) end; table.sort(ids)
		for _, id in ipairs(ids) do inspect(id, data.adventurers[id]) end
		return report
	end
	return P
end
