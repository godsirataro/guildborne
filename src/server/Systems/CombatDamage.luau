--!strict
return function(stats: any, targeting: any, emit: any)
	local D = {}
	function D.hit(a: any, b: any, range: number, multiplier: number, now: number): number
		if not targeting.valid(a,b,range) then return 0 end
		local amount=math.min(b.health,stats.damage(a.stats.Attack,b.stats.Defense,multiplier*(if (b.guardUntil or 0)>now then b.guardMultiplier or .55 else 1)))
		if amount<=0 then return 0 end
		b.health-=amount; b.lastHit=now; a.lastHit=now
		if b.kind=="Enemy" then b.threat[a.id]=(b.threat[a.id] or 0)+amount*(a.threatMultiplier or 1) end
		emit("damage_dealt",a,b,amount)
		if b.health==0 then
			b.state=if b.kind=="Hero" then "Downed" else "Dead"; b.downedAt=now
			emit(if b.kind=="Hero" then "hero_downed" else "enemy_defeated",a,b,amount)
		end
		return amount
	end
	function D.heal(a: any, b: any, range: number, amount: number, now: number): number
		if not stats.valid(amount) or not targeting.valid(a,b,range,true) then return 0 end
		local actual=math.min(amount,b.stats.MaxHealth-b.health)
		if actual<=0 then return 0 end
		b.health+=actual; a.lastHit=now
		emit("healing_done",a,b,actual)
		return actual
	end
	return D
end
