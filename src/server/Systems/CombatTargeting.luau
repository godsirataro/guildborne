--!strict
-- Distances come from server entity positions through the injected distance function.
return function(distance: any,hostileSpace: any?,lineOfSight:any?)
	local T = {}
	function T.alive(e: any): boolean return e~=nil and e.active==true and e.health>0 and e.state~="Downed" and e.state~="Dead" end
	function T.valid(a: any, b: any, range: number, ally: boolean?): boolean
		return T.alive(a) and T.alive(b) and a.owner==b.owner and (if ally then a.kind==b.kind else a.kind~=b.kind)
			and (ally==true or hostileSpace==nil or hostileSpace(a,b))
			and distance(a,b)<=range
			and (lineOfSight==nil or lineOfSight(a,b))
	end
	function T.enemy(actor: any, candidates: {any}, existing: any, range: number, now: number): any
		if actor.tauntUntil and actor.tauntUntil>now and T.valid(actor,actor.tauntTarget,range) then return actor.tauntTarget end
		local best,score=nil,-math.huge
		for _,e in ipairs(candidates) do
			if T.valid(actor,e,range) then
				local threat=(actor.threat and actor.threat[e.id]) or 0
				local value=threat*100+(if e==existing then 20 else 0)+(if e.target==actor then 10 else 0)-distance(actor,e)
				if value>score then best=e; score=value end
			end
		end
		return best
	end
	function T.heal(actor: any, allies: {any}, range: number): any
		local best,deficit=nil,0
		for _,e in ipairs(allies) do
			local missing=e.stats.MaxHealth-e.health
			if T.valid(actor,e,range,true) and missing>=math.max(5,e.stats.MaxHealth*.2) and missing>deficit then best=e; deficit=missing end
		end
		return best
	end
	return T
end
