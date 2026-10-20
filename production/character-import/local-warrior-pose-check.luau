--!nocheck
-- Offline fixed profile checks. Native contact, rendered motion and fit remain pending.
local P=require("../../src/shared/Presentation/ModularAppearance/LocalWarriorBasicPose")
local T=require("../../src/shared/Presentation/ActionTimeline")
local count=0
local names={"Waist","RightShoulder","RightElbow"}
local function check(name,fn) fn();count+=1;print("PASS "..name) end
local function near(a,b,epsilon) assert(math.abs(a-b)<(epsilon or 1e-9),tostring(a).." ~= "..tostring(b)) end
local function equal(a,b,epsilon)
	for _,field in ipairs({"translation","angles"}) do
		for i=1,3 do near(a[field][i],b[field][i],epsilon) end
	end
end
local zero={translation={0,0,0},angles={0,0,0}}
check("finite bounded poses over the entire existing timeline",function()
	for i=0,1000 do for _,name in ipairs(names) do
		local pose=P.Sample(T.Duration*i/1000,name,T);assert(pose)
		for _,field in ipairs({"translation","angles"}) do for _,value in ipairs(pose[field]) do
			assert(value==value and math.abs(value)<math.huge and math.abs(value)<=1.9)
		end end
	end end
end)
check("exact rest at beginning and existing duration",function()
	for _,name in ipairs(names) do
		equal(P.Sample(0,name,T),zero);equal(P.Sample(T.Duration,name,T),zero)
	end
end)
check("fixed anticipation matches approved coefficients",function()
	equal(P.Sample(T.Release,"Waist",T),{translation={0,-.23,0},angles={.12,-.25,0}})
	equal(P.Sample(T.Release,"RightShoulder",T),{translation={0,0,0},angles={1.9,-.2,.2}})
	equal(P.Sample(T.Release,"RightElbow",T),{translation={0,0,0},angles={-.6,0,0}})
end)
check("contact and recovery onset preserve approved fixed pose",function()
	for _,age in ipairs({T.Contact,T.Recovery}) do
		equal(P.Sample(age,"Waist",T),{translation={0,0,-.18},angles={-.10,0,0}})
		equal(P.Sample(age,"RightShoulder",T),{translation={0,0,0},angles={1.15,0,-.3}})
		equal(P.Sample(age,"RightElbow",T),{translation={0,0,0},angles={-.3,0,0}})
	end
end)
check("phase boundaries are continuous with smooth endpoint velocity",function()
	local dt=1e-6
	for _,name in ipairs(names) do
		for _,age in ipairs({T.Release,T.Contact,T.Recovery}) do
			local at=P.Sample(age,name,T)
			equal(P.Sample(age-dt,name,T),at,1e-7)
			equal(P.Sample(age+dt,name,T),at,1e-7)
		end
		equal(P.Sample(dt,name,T),zero,1e-7)
		equal(P.Sample(T.Duration-dt,name,T),zero,1e-7)
	end
end)
check("only intended joints override and fallback identity is preserved",function()
	local sentinel={untouched=true}
	for _,name in ipairs({"Root","RootJoint","Neck","LeftShoulder","LeftElbow","RightWrist","LeftWrist","RightHip","LeftHip","RightKnee","LeftKnee","RightAnkle","LeftAnkle","Unknown"}) do
		assert(P.Sample(T.Contact,name,T)==nil)
		assert(P.Apply(T.Contact,name,sentinel,T)==sentinel)
		assert(P.Apply(T.Contact,name,nil,T)==nil)
	end
end)
check("inactive invalid and nonfinite ages preserve fallback",function()
	local sentinel={untouched=true}
	for _,age in ipairs({-1,T.Duration+1e-6,0/0,math.huge,-math.huge,"invalid",false}) do
		for _,name in ipairs(names) do
			assert(P.Sample(age,name,T)==nil)
			assert(P.Apply(age,name,sentinel,T)==sentinel)
		end
	end
end)
check("all timing derives from injected existing timeline fields",function()
	local scaled={Release=T.Release*2,Contact=T.Contact*2,Recovery=T.Recovery*2,Duration=T.Duration*2}
	function scaled.active(age) return T.active(age/2) end
	for i=0,100 do for _,name in ipairs(names) do
		local age=T.Duration*i/100
		equal(P.Sample(age,name,T),P.Sample(age*2,name,scaled))
	end end
end)
check("sampling has no accumulation or mutable shared output",function()
	local first=P.Sample(T.Contact,"Waist",T);first.translation[1]=999;first.angles[1]=999
	equal(P.Sample(T.Contact,"Waist",T),{translation={0,0,-.18},angles={-.10,0,0}})
	for _=1,20 do equal(P.Sample(T.Duration,"Waist",T),zero) end
end)
print("Local Warrior pose checks passed: "..count)
