--!strict
-- Server-owned, fixed ground footprints. No client target or damage input.
local B={}
function B.begin(actor: any,target: any,now: number): any
	if actor.health<=0 or actor.pendingPattern or now<(actor.nextAttack or 0) then return nil end
	local pulse=actor.health<=actor.stats.MaxHealth*.5 and (actor.patternCount or 0)%2==1
	local center=if pulse then actor.root.Position else target.root.Position
	local p={name=if pulse then "Warden Pulse" else "Warden Slam",x=center.X,y=center.Y,z=center.Z,
		radius=if pulse then 10 else 5,duration=if pulse then 1.8 else 1.2,multiplier=if pulse then .8 else 1}
	p.due=now+p.duration
	actor.pendingPattern=p
	actor.patternCount=(actor.patternCount or 0)+1
	return p
end
function B.contains(p: any,position: any): boolean
	local dx,dz=position.X-p.x,position.Z-p.z
	return dx*dx+dz*dz<=p.radius*p.radius and math.abs(position.Y-p.y)<=8
end
function B.take(actor: any,now: number): any
	local p=actor.pendingPattern
	if not p or now<p.due then return nil end
	actor.pendingPattern=nil
	actor.nextAttack=now+actor.stats.AttackInterval
	-- A stalled server must not release an attack after its warning has long expired.
	-- Allow one normal combat tick plus scheduling jitter, then enter recovery.
	if actor.health<=0 or now-p.due>.5 then return nil end
	return p
end
function B.cancel(actor: any,now: number)
	if actor.pendingPattern then actor.nextAttack=math.max(actor.nextAttack or 0,now+actor.stats.AttackInterval) end
	actor.pendingPattern=nil
end
return B
