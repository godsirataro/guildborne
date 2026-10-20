--!nocheck
-- Offline clock + affine algebra checks. Does not claim native CFrame/actor acceptance.
local R=require("../../src/shared/Presentation/ModularAppearance/LocalActionRetarget")
local T=require("../../src/shared/Presentation/ActionTimeline")
local count=0
local function check(name,fn)
	fn();count+=1;print("PASS "..name)
end
local function snapshot(stamp,changes)
	local value={stamp=stamp,classId="Warrior",weaponId="training_sword",action="Basic Attack",effect="Basic"}
	for key,item in pairs(changes or {}) do value[key]=item end
	return value
end
local function fresh() return R.NewClock(99.9,100,T) end
local function near(a,b) assert(math.abs(a-b)<1e-8,tostring(a).." ~= "..tostring(b)) end
check("initial attach never replays existing action",function()
	local c=fresh();assert(c:Step(snapshot(99.9),100)==nil)
	assert(c:GetDiagnostics().starts==0)
end)
check("fresh event starts once and follows existing timeline",function()
	local c=fresh();assert(c:Step(snapshot(100.1),100.12))
	assert(c:GetDiagnostics().status=="Anticipation")
	assert(c:Step(snapshot(100.1),100.25));assert(c:GetDiagnostics().status=="Release")
	assert(c:Step(snapshot(100.1),100.345));assert(c:GetDiagnostics().status=="Contact")
	assert(c:Step(snapshot(100.1),100.5));assert(c:GetDiagnostics().status=="Recovery")
	assert(c:GetDiagnostics().starts==1)
end)
check("expiration cannot replay same stamp",function()
	local c=fresh();assert(c:Step(snapshot(100.1),100.1))
	assert(c:Step(snapshot(100.1),100.8)==nil);assert(c:GetDiagnostics().status=="COMPLETED")
	assert(c:Step(snapshot(100.1),100.9)==nil);assert(c:GetDiagnostics().starts==1)
end)
check("reordered event cancels without starting",function()
	local c=fresh();assert(c:Step(snapshot(100.3),100.3))
	assert(c:Step(snapshot(100.2),100.31)==nil)
	assert(c:GetDiagnostics().status=="PREATTACH_OR_REORDERED_ACTION")
	assert(c:GetDiagnostics().starts==1 and c:GetDiagnostics().cancellations==1)
end)
check("unsupported newer event advances observed cursor",function()
	local c=fresh();assert(c:Step(snapshot(100.3,{effect="PowerStrike"}),100.3)==nil)
	assert(c:GetDiagnostics().lastObservedAt==100.3)
	assert(c:Step(snapshot(100.2),100.31)==nil)
	assert(c:GetDiagnostics().status=="PREATTACH_OR_REORDERED_ACTION" and c:GetDiagnostics().starts==0)
end)
check("future rejection permits later legitimate fresh event",function()
	local c=fresh();assert(c:Step(snapshot(101),100.1)==nil)
	assert(c:GetDiagnostics().status=="FUTURE_ACTION_TIMESTAMP")
	assert(c:Step(snapshot(100.2),100.2));assert(c:GetDiagnostics().starts==1)
end)
check("nonfinite missing and nonnumeric stamps rejected",function()
	for _,value in ipairs({0/0,math.huge,-math.huge,"100.1",false}) do
		local c=fresh();assert(c:Step(snapshot(value),100.1)==nil)
		assert(c:GetDiagnostics().status=="INVALID_ACTION_TIMESTAMP")
	end
	local c=fresh();assert(c:Step(snapshot(nil),100.1)==nil)
	assert(c:GetDiagnostics().status=="INVALID_ACTION_TIMESTAMP")
end)
check("stale and preattach stamps cannot start",function()
	local c=fresh();assert(c:Step(snapshot(100.1),101)==nil)
	assert(c:GetDiagnostics().status=="STALE_ACTION_TIMESTAMP")
	local d=fresh();assert(d:Step(snapshot(99),100.1)==nil)
	assert(d:GetDiagnostics().status=="PREATTACH_OR_REORDERED_ACTION")
end)
check("metadata changes cancel without replay on restoration",function()
	for _,change in ipairs({{classId="Mage"},{weaponId="different"},{action="Skill"},{effect="PowerStrike"},{abilityId="power_strike"}}) do
		local c=fresh();assert(c:Step(snapshot(100.1),100.1))
		assert(c:Step(snapshot(100.1,change),100.2)==nil)
		assert(c:Step(snapshot(100.1),100.3)==nil)
		assert(c:GetDiagnostics().starts==1 and c:GetDiagnostics().cancellations==1)
		assert(c:Step(snapshot(100.4),100.4))
	end
end)
check("death identity and departure problems cancel",function()
	for _,problem in ipairs({"ACTOR_DOWNED","ACTOR_OWNER_CHANGED","ACTOR_DEPARTED_OR_REPLACED","LOCAL_GATE_CLOSED"}) do
		local c=fresh();assert(c:Step(snapshot(100.1),100.1))
		assert(c:Step(snapshot(100.1,{problem=problem}),100.2)==nil)
		assert(c:GetDiagnostics().status==problem)
		assert(c:Step(snapshot(100.1),100.3)==nil)
	end
end)
check("invalid or reversed clock cancels",function()
	for _,now in ipairs({0/0,math.huge,99.5}) do
		local c=fresh();assert(c:Step(snapshot(100.1),100.1))
		assert(c:Step(snapshot(100.1),now)==nil)
		assert(c:GetDiagnostics().status=="INVALID_OR_REVERSED_CLOCK")
	end
end)
check("destroy is terminal and idempotent",function()
	local c=fresh();assert(c:Step(snapshot(100.1),100.1));c:Destroy();c:Destroy()
	assert(c:Step(snapshot(100.2),100.2)==nil)
	assert(c:GetDiagnostics().destroyed and c:GetDiagnostics().cancellations==1)
end)
-- Rigid 2D affine test double: independent component multiplication and inverse.
-- Real CFrame validity/ownership gates remain native Studio checks.
local A={};A.__index=A
local function affine(a,b,c,d,x,y) return setmetatable({a=a,b=b,c=c,d=d,x=x,y=y},A) end
local function frame(angle,x,y)
	return affine(math.cos(angle),-math.sin(angle),math.sin(angle),math.cos(angle),x,y)
end
function A.__mul(l,r)
	return affine(l.a*r.a+l.b*r.c,l.a*r.b+l.b*r.d,l.c*r.a+l.d*r.c,l.c*r.b+l.d*r.d,
		l.a*r.x+l.b*r.y+l.x,l.c*r.x+l.d*r.y+l.y)
end
function A:Inverse()
	return affine(self.a,self.c,self.b,self.d,-self.a*self.x-self.c*self.y,-self.b*self.x-self.d*self.y)
end
local function same(l,r) for _,key in ipairs({"a","b","c","d","x","y"}) do near(l[key],r[key]) end end
check("basis conjugation transforms translation and rotation",function()
	local walking=frame(math.pi/6,3,4)
	local result=R.MapPose(walking,frame(math.pi/2,0,0),frame(math.pi/9,1,0))
	near(result.x,3.5);near(result.y,4-math.sqrt(3)/2)
	near(result.a,math.cos(math.pi/6+math.pi/9));near(result.c,math.sin(math.pi/6+math.pi/9))
end)
check("injected pose overlay follows caller reset and cancels cleanly",function()
	local clock=fresh();local walking=frame(.1,3,4);local basis=frame(math.pi/2,0,0)
	local calls=0
	local function callback(classId,effect,age,name)
		assert(classId=="Warrior" and effect=="Basic" and age>=0 and name=="Waist")
		calls+=1;return frame(.2,1,0)
	end
	local function tick(data,now)
		local c0=walking -- caller resets bind, then applies current walk every frame
		local event=clock:Step(data,now)
		if event then c0=R.MapPose(c0,basis,callback(event.classId,event.effect,event.age,"Waist")) end
		return c0
	end
	local first=tick(snapshot(100.1),100.1)
	same(first,tick(snapshot(100.1),100.2));assert(calls==2)
	same(walking,tick(snapshot(100.1,{problem="ACTOR_DOWNED"}),100.3));assert(calls==2)
	same(walking,tick(snapshot(100.1),100.4));assert(calls==2)
end)
print("Local action checks passed: "..count)
