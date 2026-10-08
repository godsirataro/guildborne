--!strict
return function(content: any,gear: any)
	local Progression = {}
	function Progression.stats(data: any, adventurer: any): any
		local bonus=gear.bonuses(gear.loadout(data,adventurer),adventurer.classId)
		local extra=gear.extras(data,adventurer)
		local base=content.Adventurers[adventurer.classId].Stats
		return {Health=base.Health+(adventurer.level-1)*content.Progression.HealthPerLevel+bonus.Health+extra.Health,
			Attack=base.Attack+(adventurer.level-1)*content.Progression.AttackPerLevel+bonus.Attack+extra.Attack,
			Defense=base.Defense+bonus.Defense+extra.Defense,WeaponBonus=bonus.WeaponBonus}
	end
	function Progression.tutorial(data: any): string
		if data.progression.tutorialCompleted then return "complete" end
		if not data.progression.welcomeSeen then return "welcome" end
		if not next(data.adventurers) then return "recruit" end
		if #data.party.adventurerIds == 0 then return "party" end
		if data.quests.active then return "claim" end
		if not data.quests.firstClears.trail_watch then return "quest" end
		if not data.progression.everEquipped then return "equip" end
		if not data.progression.recruitedClasses.Archer or not data.progression.recruitedClasses.Priest then return "roster" end
		if not data.quests.firstClears.quarry_patrol then return "supplies" end
		if data.personalGuild.buildings.guildHall == 1 then return "upgrade" end
		return "complete"
	end
	return Progression
end
