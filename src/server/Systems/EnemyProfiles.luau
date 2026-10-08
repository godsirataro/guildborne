--!strict
-- Shared calculation for spawned encounters and their read-only field guide.
return function(config: any)
	local profiles = {}
	function profiles.resolve(floor: number?, index: number): (any, boolean, string)
		local stats = table.clone(config.Goblin)
		local boss = floor ~= nil and floor % 5 == 0 and index == 1
		if floor then
			stats.MaxHealth = (65 + floor * 18) * (if boss then 2.4 else 1)
			stats.Attack = 5 + floor * 1.3; stats.Defense = floor
			if floor % 2 == 0 and not boss then stats.AttackRange = 18; stats.MoveSpeed = 8 end
			if boss then stats.Attack *= 1.5; stats.AttackInterval = 3 end
		end
		local name = if not floor then "Goblin Scout" elseif boss then "Spire Warden" elseif stats.AttackRange > 5 then "Echo Archer" else "Echo Guard"
		return stats, boss, name
	end
	function profiles.catalog(content: any): any
		local function entry(floor: number?, index: number): any
			local stats, boss, name = profiles.resolve(floor, index)
			return {Name = name, Boss = boss, Health = stats.MaxHealth, Attack = stats.Attack, Defense = stats.Defense,
				Range = stats.AttackRange, Interval = stats.AttackInterval}
		end
		local floors = {}
		for floor = 1, 10 do
			local enemies = {entry(floor, 1)}
			if floor % 5 == 0 then table.insert(enemies, entry(floor, 2)) end
			floors[floor] = enemies
		end
		local scout = content.Enemies.goblin_scout
		return {Camp = entry(nil, 1), Floors = floors, Expedition = {Name = scout.Name, Health = scout.Health, Attack = scout.Attack}}
	end
	return profiles
end
