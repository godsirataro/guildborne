--!strict
local M=require("../src/shared/Presentation/CivicWorkMotion")
return function(test:any,eq:any)
 local ids={"marshal_elian","arborist_vaela","smith_borin","cartographer_nyra","harbormaster_sela","steward_roka"}
 test("civic work loops close with stationary roots and finite bounded joints",function()
  for _,id in ipairs(ids)do
   for i=0,480 do local t=i/60;local p=M.sample(id,t,false)
    assert(p.Root==nil and p.LeftUpperLeg==nil and p.RightUpperLeg==nil)
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
 test("six civic professions have distinct peak poses",function()
  local seen={}
  for _,id in ipairs(ids)do local p=M.sample(id,4,false);local h=p.Head;local r=p.RightUpperArm;local key=string.format("%.3f/%.3f/%.3f",h[1],h[2],r[1]);assert(not seen[key]);seen[key]=true end
 end)
end
