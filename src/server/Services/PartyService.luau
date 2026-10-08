--!strict
return function(maxSize: number)
	return function(data: any, args: any, emit: any): string?
		if data.quests.active then return "QuestActive" end
		if (#args.adventurerIds < 1 and not (data.character and data.character.classId)) or #args.adventurerIds > maxSize then return "InvalidParty" end
		local seen = {}
		for _, id in ipairs(args.adventurerIds) do
			if not data.adventurers[id] or seen[id] then return "InvalidParty" end
			local hero=data.adventurers[id]
			if hero.condition and hero.condition~="Healthy" then return "HeroUnavailable" end
			if data.settlement then for _,job in pairs(data.settlement.jobs) do if table.find(job.members,id) then return "HeroUnavailable" end end end
			seen[id] = true
		end
		local first = #data.party.adventurerIds == 0
		data.party.adventurerIds = table.clone(args.adventurerIds)
		emit(if first then "party_created" else "party_updated", { size = #args.adventurerIds })
		return nil
	end
end
