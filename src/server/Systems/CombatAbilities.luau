--!strict
return function(config: any, targeting: any, damage: any, emit: any)
	local A = {}
	function A.cast(actor: any, id: string, target: any, enemies: {any}, now: number): (boolean,string)
		local def=config.Abilities[id]
		local role=config.Classes[actor.class]
		local allowed = role and (if actor.allowedAbilities then table.find(actor.allowedAbilities,id) ~= nil else (actor.ability or role.Ability)==id)
		if not def or not role or (def.Class and def.Class~=actor.class) or not allowed then return false,"InvalidAbility" end
		if not targeting.alive(actor) then return false,"Downed" end
		if math.max(actor.cooldowns[id] or 0,actor.nextAbility or 0)>now then return false,"Cooldown" end
		if not targeting.valid(actor,target,def.Range,def.TargetType=="Ally") then return false,"InvalidTarget" end
		if def.Effect=="Heal" then
			if target.stats.MaxHealth-target.health<math.max(5,target.stats.MaxHealth*.2) then return false,"NoDeficit" end
			local amount=math.floor(actor.stats.Attack*def.Multiplier+def.Flat+(actor.stats.HealPower or 0))
			damage.heal(actor,target,def.Range,amount,now)
			if def.Group then for index,ally in ipairs(actor.allies or {}) do if index<=6 and ally~=target then damage.heal(actor,ally,def.Range,amount,now) end end end
		elseif def.Effect=="Taunt" then
			for _,enemy in ipairs(enemies) do
				if targeting.valid(actor,enemy,def.Range) then enemy.tauntTarget=actor; enemy.tauntUntil=now+def.Duration end
			end
		elseif def.Effect=="Area" then
			local count=0;for _,enemy in ipairs(enemies) do if count<5 and targeting.valid(actor,enemy,def.Range) then damage.hit(actor,enemy,def.Range,def.Multiplier,now);count+=1 end end
		elseif def.Effect=="Guard" then
			actor.guardUntil=now+def.Duration
			actor.guardMultiplier=.55-math.clamp(actor.stats.GuardBonus or 0,0,.1)
			if def.Group then for index,ally in ipairs(actor.allies or {}) do if index<=6 and targeting.valid(actor,ally,def.Range,true) then ally.guardUntil=now+def.Duration;ally.guardMultiplier=actor.guardMultiplier end end end
			for _,enemy in ipairs(enemies) do if targeting.valid(actor,enemy,def.Range) then enemy.tauntTarget=actor;enemy.tauntUntil=now+def.Duration end end
		elseif def.Effect=="Drain" then
			local dealt=damage.hit(actor,target,def.Range,def.Multiplier,now);damage.heal(actor,actor,0,math.floor(dealt*.4),now)
		elseif def.Effect=="Slow" then
			damage.hit(actor,target,def.Range,def.Multiplier,now);target.slowUntil=now+def.Duration
		else damage.hit(actor,target,def.Range,def.Multiplier,now) end
		actor.cooldowns[id]=now+def.Cooldown;actor.nextAbility=now+def.Cooldown
		emit("hero_ability_used",actor,target,id)
		return true,"OK"
	end
	function A.basic(actor: any, target: any, now: number): boolean
		if now<(actor.nextAttack or 0) or not targeting.valid(actor,target,actor.stats.AttackRange) then return false end
		actor.nextAttack=now+actor.stats.AttackInterval
		damage.hit(actor,target,actor.stats.AttackRange,1,now)
		emit(if actor.kind=="Hero" then "hero_basic_attack" else "enemy_basic_attack",actor,target,1)
		return true
	end
	return A
end
