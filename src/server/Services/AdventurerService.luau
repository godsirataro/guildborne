--!strict
return function(content: any, economy: any, util: any)
	local Adventurers = {}
	function Adventurers.recruit(data: any, args: any, emit: any): string?
		local gate=content.NoviceActionProblem(data,"Recruit");if gate then return gate end
		local def = content.Adventurers[args.classId]
		if not def then return "InvalidAdventurer" end
		if data.progression.recruitedClasses[def.Class] then return "AlreadyRecruited" end
		if util.count(data.adventurers) >= content.RosterCapacity(data) then return "RosterFull" end
		local problem = economy.gold(data, -def.Cost, "Recruitment", emit)
		if problem then return problem end
		local id = "a:" .. def.Id
		local xp=content.RecruitmentStartingXP(data)
		data.adventurers[id] = { id = id, name = def.Name, classId = def.Class, rank = "F", level = content:LevelFromXP(xp,content.ProfileLevelCap(data)), xp = xp, baseStats = util.copy(def.Stats), equipmentSlots = {} }
		data.progression.recruitedClasses[def.Class] = true
		if def.Weapon then
			problem = economy.items(data, { { Id = def.Weapon, Quantity = 1 } }, "recruit:" .. def.Id, emit)
			if problem then return problem end
		end
		emit("adventurer_recruited", { classId = def.Class, goldCost = def.Cost })
		return nil
	end
	return Adventurers
end
