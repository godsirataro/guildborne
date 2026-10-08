--!strict
return function(content: any,config: any,stats: any): boolean
	for class in pairs(content.Adventurers) do
		local role=config.Classes[class]; assert(role and config.Abilities[role.Ability],"Missing combat class/ability")
		assert(stats.hero(class,1,nil),"Invalid base stats")
		local player=content.Character.Classes[class]
		assert(player and player.SkillId==role.Ability and type(player.PathId)=="string" and stats.hero(class,1,player.Weapon),"Invalid player kit")
		assert(stats.valid(role.Speed) and role.Speed>0 and stats.valid(role.Interval) and role.Interval>0 and stats.valid(role.Range) and role.Range>0)
	end
	for id,ability in pairs(config.Abilities) do
		assert(ability.Id==id and stats.valid(ability.Cooldown) and ability.Cooldown>0 and stats.valid(ability.Range) and ability.Range>0)
		assert(ability.TargetType=="Enemy" or ability.TargetType=="Ally")
		assert(ability.Effect=="Taunt" or ability.Effect=="Heal" or ability.Effect=="Physical" or ability.Effect=="Magic" or ability.Effect=="Area" or ability.Effect=="Guard" or ability.Effect=="Drain" or ability.Effect=="Slow")
		if ability.Effect=="Taunt" then assert(stats.valid(ability.Duration) and ability.Duration>0)
		else assert(stats.valid(ability.Multiplier) and ability.Multiplier>0) end
	end
	for _,key in ipairs({"MaxHealth","Attack","Defense","MoveSpeed","AttackRange","AttackInterval","DetectionRange","RespawnSeconds"}) do
		assert(stats.valid(config.Goblin[key]) and config.Goblin[key]>0,"Invalid Goblin stat")
	end
	for _,value in pairs(config.Goblin.Reward) do assert(stats.valid(value) and value%1==0) end
	return true
end
