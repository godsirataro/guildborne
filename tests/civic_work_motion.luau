--!strict
local M=require("../src/shared/Presentation/CivicWorkMotion")
return function(test:any,eq:any)
 local ids={"marshal_elian","arborist_vaela","smith_borin","cartographer_nyra","harbormaster_sela","steward_roka","borga","mogra","rukk","ghar"}
 test("civic work loops close with stationary roots and finite bounded joints",function()
  for _,id in ipairs(ids)do
   for i=0,480 do local t=i/60;local p=M.sample(id,t,false)
    local allowed={Head=true,UpperTorso=true,LeftUpperArm=true,LeftLowerArm=true,LeftHand=true,RightUpperArm=true,RightLowerArm=true,RightHand=true}
    assert(next(p)~=nil)
    for bone in pairs(p) do assert(allowed[bone],"Unexpected animated bone: "..bone) end
    for _,a in pairs(p)do for _,v in ipairs(a)do assert(v==v and math.abs(v)<.7);if i==0 or i==480 then assert(math.abs(v)<1e-12)end end end
   end
   local a=M.sample(id,2,false);local b=M.sample(id,10,false)
   for bone,v in pairs(a)do for axis=1,3 do eq(v[axis],b[bone][axis])end end
  end
 end)
 test("civic work reduced motion and invalid inputs return no animated joints",function()
  for _,id in ipairs(ids)do eq(next(M.sample(id,3,true)),nil)
   for _,t in ipairs({-1,0/0,math.huge,-math.huge})do eq(next(M.sample(id,t,false)),nil)end
  end
  eq(next(M.sample("unknown",3,false)),nil)
 end)
 test("ten civic professions have distinct peak poses",function()
  local seen={}
  for _,id in ipairs(ids)do local p=M.sample(id,4,false);local h=p.Head;local r=p.RightUpperArm;local key=string.format("%.3f/%.3f/%.3f",h[1],h[2],r[1]);assert(not seen[key]);seen[key]=true end
 end)
 test("existing Orc prop gestures animate their bound arm without moving lower body",function()
  local arms={borga="RightUpperArm",mogra="LeftUpperArm",rukk="RightUpperArm",ghar="LeftUpperArm"}
  for id,arm in pairs(arms)do
   local pose=M.sample(id,4,false)
   assert(math.abs(pose[arm][1])>.1)
   assert(pose.Head~=nil and pose.LowerTorso==nil)
   -- Caller blends returned angles; mutating one sample must not corrupt another actor/frame.
   local original=pose[arm][1];pose[arm][1]=999
   eq(M.sample(id,4,false)[arm][1],original)
  end
 end)
 test("work loops have no angle jump at wrap for all ten identities",function()
  for _,id in ipairs(ids)do
   local before=M.sample(id,M.Duration-.001,false)
   local after=M.sample(id,M.Duration+.001,false)
   for bone,angles in pairs(before)do
    for axis=1,3 do assert(math.abs(angles[axis]-after[bone][axis])<.00001) end
   end
  end
 end)
end
