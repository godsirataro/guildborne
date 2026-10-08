--!strict
return function(content: any, config: any, equipment: any)
	local Stats = {}
	function Stats.valid(n: any): boolean return type(n)=="number" and n==n and n>=0 and n<1000000 end
	function Stats.hero(class: string, level: number, weapon: string?, armor: string?, accessory: string?, extra: any?): any
		local base, role = content.Adventurers[class], config.Classes[class]
		if not base or not role or not Stats.valid(level) or level%1~=0 or level<1 or level>content.Limits.Level then return nil end
		local gear=weapon and content.Items[weapon]
		if weapon and (not gear or gear.Class~=class or not Stats.valid(gear.Attack)) then return nil end
		local bonus=equipment.bonuses({weapon=weapon,armor=armor,accessory=accessory},class); if not bonus then return nil end
		local b=base.Stats;extra=extra or {Health=0,Attack=0,Defense=0,Speed=0}
		if not Stats.valid(b.Health) or b.Health==0 or not Stats.valid(b.Attack) or not Stats.valid(b.Defense) then return nil end
		return { MaxHealth=b.Health+(level-1)*content.Progression.HealthPerLevel+bonus.Health+extra.Health,
			Attack=b.Attack+(level-1)*content.Progression.AttackPerLevel+bonus.Attack+extra.Attack,
			Defense=b.Defense+bonus.Defense+extra.Defense, MoveSpeed=role.Speed+extra.Speed, AttackRange=role.Range, AttackInterval=role.Interval,
			HealPower=extra.HealPower or 0,GuardBonus=extra.GuardBonus or 0 }
	end
	function Stats.damage(attack: number, defense: number, multiplier: number?): number
		local power=multiplier or 1
		if not Stats.valid(attack) or not Stats.valid(defense) or not Stats.valid(power) then return 0 end
		return math.max(1,math.floor(attack*power*100/(100+defense*8)+.5))
	end
	return Stats
end
