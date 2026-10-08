--!strict
local M=require("../src/shared/Presentation/ArchiveEndingMotion")
return function(test:any,eq:any)
 test("ending storyboard is bounded and rests at both endpoints",function()
  for _,id in ipairs({"preserve","transform","dismantle","unknown"})do
   for i=0,480 do local s=M.sample(id,i/60,false);assert(math.abs(s.orbit)<=.09 and math.abs(s.ring)<=.075 and math.abs(s.leaves)<=.035 and math.abs(s.pages)<=.055)end
   for _,t in ipairs({0,8})do local s=M.sample(id,t,false);assert(math.abs(s.orbit)<1e-12 and math.abs(s.ring)<1e-12 and math.abs(s.leaves)<1e-12 and math.abs(s.pages)<1e-12)end
  end
 end)
 test("ending reduced motion disables every moving channel without suppressing completion",function()
  for _,id in ipairs({"preserve","transform","dismantle"})do for i=0,16 do
   local s=M.sample(id,i/2,true);eq(s.orbit,0);eq(s.ring,0);eq(s.leaves,0);eq(s.pages,0);eq(s.finished,i==16)
  end end
 end)
 test("ending storyboard rejects nonfinite times and keeps scene-specific motions distinct",function()
  for _,t in ipairs({0/0,math.huge,-math.huge,-2})do eq(M.sample("preserve",t,false).time,0)end
  eq(M.sample("dismantle",20,false).finished,true)
  eq(M.sample("preserve",3,false).leaves,0);eq(M.sample("transform",3,false).pages,0);eq(M.sample("dismantle",3,false).ring,0)
  local unknown=M.sample("unknown",3,false);eq(unknown.orbit,0);eq(unknown.ring,0)
 end)
end
