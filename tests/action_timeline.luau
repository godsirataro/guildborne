-- Standalone pure presentation contract; does not simulate server combat.
local T=require("../src/shared/Presentation/ActionTimeline")
assert(not T.active(0/0) and not T.active(math.huge) and not T.active(-.1))
assert(T.phase(0)=="Anticipation" and T.phase(.1)=="Release")
assert(T.phase(.24)=="Contact" and T.phase(.3)=="Recovery" and T.phase(.63)=="Idle")
assert(#T.crossed(.05,.25)==2)
assert(#T.crossed(.25,.25)==0 and #T.crossed(.4,.2)==0)
assert(#T.crossed(.25,.3)==1 and T.crossed(.25,.3)[1]=="recovery")
assert(#T.crossed(.3,10)==0 and #T.crossed(0/0,.3)==0)
print("PASS action timeline: finite input, phase boundaries, skipped frames, replay and stale observations")

assert(T.accept(10,10,nil) and T.accept(10,10.5,9))
local invalidStamps: {any}={false,"10",0/0,math.huge,-math.huge,9,10,11}
for _,stamp in ipairs(invalidStamps) do
	assert(not T.accept(stamp,10.2,10),"Duplicate, reordered, invalid or future stamp accepted")
end
assert(not T.accept(nil,10,nil) and not T.accept(10,0/0,nil))
assert(not T.accept(10,10.63,nil) and T.accept(10.1,10.2,10))
assert(not T.accept(10.1,10.3,10.2),"Still-live reordered action accepted")
print("PASS action observation: missing, duplicate, reordered, expired and future rejected; replacement accepted")

-- Actual server cast module/config with deterministic targeting/damage spies.
-- This checks rejection side effects, not networking, real hit detection or Studio.
local config=require("../src/server/Config/Combat")
local hits,events=0,0
local valid=true
local abilities=require("../src/server/Systems/CombatAbilities")(config,{
	alive=function(actor) return actor.health>0 end,
	valid=function() return valid end,
},{hit=function() hits+=1;return 10 end},function(name,actor,target,id)
	assert(name=="hero_ability_used" and id=="power_strike")
	events+=1
end)
local actor: any={class="Warrior",health=100,cooldowns={},stats={}}
local target={}
local accepted,reason=abilities.cast(actor,"power_strike",target,{},100)
assert(accepted and reason=="OK" and hits==1 and events==1)
assert(actor.cooldowns.power_strike==106 and actor.nextAbility==106)
local function rejected(id,now,expected)
	local beforeHits,beforeEvents=hits,events
	local cooldown,nextAbility=actor.cooldowns.power_strike,actor.nextAbility
	local ok,why=abilities.cast(actor,id,target,{},now)
	assert(not ok and why==expected)
	assert(hits==beforeHits and events==beforeEvents,"Rejected action emitted damage/presentation")
	assert(actor.cooldowns.power_strike==cooldown and actor.nextAbility==nextAbility)
end
rejected("power_strike",100,"Cooldown")
rejected("heal",106,"InvalidAbility")
valid=false;rejected("power_strike",106,"InvalidTarget");valid=true
actor.health=0;rejected("power_strike",106,"Downed");actor.health=100
assert(abilities.cast(actor,"power_strike",target,{},106))
assert(hits==2 and events==2)
print("PASS Power Strike server contract: accepted/recovered casts, cooldown, invalid ability/target, death; no rejected side effects")

-- Exercise the actual injected presentation scheduler, not a second implementation.
local function markerFixture(stamp, observed, marker)
	local now,live,emitted=observed,true,0
	local queue={}
	local scheduled=T.scheduleMarker(stamp,marker,function() return now end,function(delay,callback)
		table.insert(queue,{due=now+delay,callback=callback,delay=delay})
	end,function() return live end,function() emitted+=1 end)
	return {
		accepted=scheduled,queue=queue,
		at=function(value) now=value end,
		cancel=function() live=false end,
		count=function() return emitted end,
	}
end
local timings={Mage={.12,.30},Archer={.12,.26},Knight={.12,.24},Priest={.12,.32},Warrior={.10,.24}}
for class,markers in pairs(timings) do
	for _,marker in ipairs(markers) do
		local f=markerFixture(10,10.05,marker)
		assert(f.accepted and #f.queue==1,class.." did not schedule")
		assert(math.abs(f.queue[1].due-(10+marker))<1e-10,class.." latency shifted absolute marker")
		f.at(10+marker);f.queue[1].callback();f.queue[1].callback()
		assert(f.count()==1,class.." callback was not exactly once")
	end
	assert(not markerFixture(10,10.2,markers[1]).accepted,class.." replayed late release")
	assert(markerFixture(10,10.2,markers[2]).accepted,class.." lost upcoming contact")
	for _,marker in ipairs(markers) do assert(not markerFixture(10,10.5,marker).accepted,class.." replayed expired stage") end
end
assert(T.markerDelay(0,0,0)==0,"Exact zero marker rejected")
assert(T.markerDelay(0,.25,.25)==0,"Exact boundary must be immediately eligible")
assert(T.markerDelay(100,100.12,.12)==0,"Nonzero clock rounding rejected exact marker")
assert(T.markerDelay(0,T.Duration,T.Duration)==0,"Exact final marker rejected")
assert(T.markerDelay(0,T.Duration+.001,T.Duration)==nil)
local invalidMarkerStamps: {any}={false,"stamp",0/0,math.huge,-math.huge,11}
for _,stamp in ipairs(invalidMarkerStamps) do
	assert(T.markerDelay(stamp,10,.24)==nil,"Invalid/future timestamp accepted")
	local f=markerFixture(stamp,10,.24)
	assert(not f.accepted and #f.queue==0,"Invalid timestamp queued work")
end
assert(T.markerDelay(nil,10,.24)==nil)
for _,invalid in ipairs({0/0,math.huge,-math.huge}) do
	assert(T.markerDelay(10,invalid,.24)==nil and T.markerDelay(10,10,invalid)==nil)
end
assert(T.markerDelay(10,10,-.01)==nil and T.markerDelay(10,10,T.Duration+.01)==nil)
-- Volley submarkers remain on the original action clock even when observed late.
for _,observed in ipairs({.3,.5}) do
	local queued,skipped=0,0
	for n=0,4 do
		for _,marker in ipairs({.26+n*.035,.42+n*.035}) do
			local f=markerFixture(0,observed,marker)
			if marker>=observed then
				queued+=1
				assert(f.accepted and #f.queue==1,"Archer Area lost future submarker")
				assert(math.abs(f.queue[1].due-marker)<1e-10,"Archer Area submarker shifted by latency")
				f.at(marker);f.queue[1].callback();assert(f.count()==1)
			else
				skipped+=1
				assert(not f.accepted and #f.queue==0,"Archer Area replayed elapsed submarker")
			end
		end
	end
	assert(queued>0 and skipped>0,"Volley fixture must exercise both retained and elapsed stages")
end
local exact=markerFixture(0,.25,.25)
assert(exact.accepted and exact.queue[1].delay==0)
exact.queue[1].callback();assert(exact.count()==1)
local cancelled=markerFixture(10,10.05,.3)
cancelled.cancel();cancelled.at(10.3);cancelled.queue[1].callback()
assert(cancelled.count()==0,"Cancelled actor emitted stage")
for _,callbackTime in ipairs({10.29,10.501,0/0,math.huge,-math.huge}) do
	local f=markerFixture(10,10.05,.3)
	f.at(callbackTime);f.queue[1].callback()
	assert(f.count()==0,"Early, late or nonfinite callback emitted stage")
end
local grace=markerFixture(0,0,.25)
grace.at(.45);grace.queue[1].callback();assert(grace.count()==1,"Exact callback grace boundary rejected")
-- Five independent actor guards/queues: cancelling one must not suppress peers.
local party={}
for i=1,5 do party[i]=markerFixture(10,10.05,.3) end
party[3].cancel()
for i,f in ipairs(party) do
	f.at(10.3);f.queue[1].callback()
	assert(f.count()==(if i==3 then 0 else 1),"One actor cancellation leaked into another")
end
print("PASS class markers: absolute timing, late skips, finite/boundary checks, callback grace, cancellation, exactly-once and five-actor isolation")

-- Already-scheduled release may execute late: flight uses only the remaining
-- .30 impact window. This is distinct from observing a new cast after release.
for _,callbackAt in ipairs({.20,.30,.31}) do
	local clock=0
	local callback
	local flights={}
	assert(T.scheduleMarker(0,.12,function() return clock end,function(_,fn) callback=fn end,function() return true end,function()
		local remaining=T.markerDelay(0,clock,.30)
		if remaining and remaining>0 then table.insert(flights,remaining) end
	end))
	clock=callbackAt;assert(callback)()
	if callbackAt==.20 then
		assert(#flights==1 and math.abs(flights[1]-.10)<1e-10,"Delayed release failed to shorten flight")
	else assert(#flights==0,"Projectile started at/after impact") end
end
assert(not markerFixture(0,.20,.12).accepted,"Late initial observation replayed release")
print("PASS fireball flight window: delayed release shortens flight; no projectile at/after impact or expired initial release")

-- Basic uses the same absolute markers even when its first observation is late.
for _,case in ipairs({{age=0,release=true,contact=true},{age=.15,release=false,contact=true},{age=.30,release=false,contact=false}}) do
	assert(markerFixture(0,case.age,T.Release).accepted==case.release)
	assert(markerFixture(0,case.age,T.Contact).accepted==case.contact)
end
for _,callbackAt in ipairs({.15,.24,.25}) do
	local now=0;local run;local swings=0
	assert(T.scheduleMarker(0,T.Release,function() return now end,function(_,fn) run=fn end,function() return true end,function()
		local remaining=T.markerDelay(0,now,T.Contact)
		if remaining and remaining>0 then swings+=1 end
	end))
	now=callbackAt;assert(run)();assert(run)()
	assert(swings==(if callbackAt<T.Contact then 1 else 0),"Basic replayed a release at/after contact")
end
print("PASS Basic marker windows: fresh, .15/.30 observations; stalled release skips at/after contact")
