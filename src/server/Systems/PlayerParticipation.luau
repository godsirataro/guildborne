--!strict
-- Called only after a successful domain effect; observation alone grants no XP.
return function(event: string,a: any,b: any,value: any,enemies: {any},now: number)
	if a.id~="player" then return end
	local function credit(e: any)
		if e and e.kind=="Enemy" and e.owner==a.owner then e.playerParticipated=true end
	end
	if event=="damage_dealt" then credit(b)
	elseif event=="healing_done" then
		for _,e in ipairs(enemies) do
			if e.health>0 and (e.target==b or (e.threat and e.threat[b.id])) then credit(e) end
		end
	elseif event=="hero_ability_used" and value=="taunt" then
		for _,e in ipairs(enemies) do
			if e.health>0 and e.tauntTarget==a and (e.tauntUntil or 0)>now then credit(e) end
		end
	end
end
