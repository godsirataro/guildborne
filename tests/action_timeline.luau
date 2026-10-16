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
