--!strict
-- Pure lifecycle tests; no Roblox instances, imported assets, or Studio acceptance.
local M=require("../src/shared/Presentation/BorinWorkMotion")
local count=0
local function equal(a:any,b:any) assert(a==b,tostring(a).." ~= "..tostring(b)) end
local function test(name:string,callback:()->())
 callback();count+=1;print("PASS "..name)
end
local function advance(s:M.State,from:number,to:number,untilTime:number?,visible:boolean?,reduced:boolean?,moving:boolean?):any
 local result=nil
 for i=math.floor(from*60),math.floor(to*60) do result=M.step(s,i/60,untilTime,visible~=false,reduced==true,moving==true) end
 return result
end
test("Borin authored curve includes anticipation, exact contact and rebound",function()
 assert(M.lift(0)==1 and M.lift(.59)==1 and M.lift(1)==0)
 assert(M.lift(1.1)>0 and M.lift(1.1)<.11)
 for i=0,600 do local v=M.lift(i/60);assert(v>=0 and v<=1);assert(math.abs(v-M.lift(i/60+2))<1e-10) end
 assert(M.lift(-1)==0 and M.lift(math.huge)==0 and M.lift(0/0)==0)
end)
test("Borin interaction fades work, repeated talks extend it, and recovery resumes",function()
 local s=M.new();assert(advance(s,0,1).mode=="Work")
 local r=advance(s,1.02,1.4,3);equal(r.mode,"Interact");equal(r.weight,0)
 r=advance(s,1.42,3.1,4);equal(r.mode,"Interact");equal(r.weight,0)
 r=advance(s,3.12,4.3,4);equal(r.mode,"Recover");assert(r.weight>0 and r.weight<1)
 r=advance(s,4.32,4.8,4);equal(r.mode,"Work");equal(r.weight,1)
end)
test("Borin distance, reduced motion and escort suspend contact with fresh recovery",function()
 for _,mode in ipairs({"distance","reduced","moving"}) do
  local s=M.new();advance(s,0,2)
  local r=M.step(s,2.02,nil,mode~="distance",mode=="reduced",mode=="moving")
  equal(r.mode,"Idle");assert(r.weight==0 and not r.contact and s.clock==0)
  r=M.step(s,2.04,nil,true,false,false);equal(r.mode,"Recover");assert(not r.contact)
 end
end)
test("Borin contact cues occur once per strike and do not replay stalled frames",function()
 local s=M.new();local strikes=0
 for i=0,360 do local r=M.step(s,i/60,nil,true,false,false);if r.contact then strikes+=1 end end
 assert(strikes==3,tostring(strikes))
 s={mode="Work",weight=1,clock=.95,lastTime=0,contactIndex=-1}
 local r=M.step(s,10,nil,true,false,false);assert(not r.contact)
 r=M.step(s,10.02,nil,true,false,false);assert(not r.contact)
end)
test("Borin actors have independent clocks and invalid time cannot create effects",function()
 local a,b=M.new(),M.new();advance(a,0,2);advance(b,0,2,5)
 assert(a.mode=="Work" and b.mode=="Interact" and b.clock==0)
 assert(not M.step(a,0/0,nil,true,false,false).contact)
 assert(not M.step(a,math.huge,nil,true,false,false).contact)
end)
print(string.format("%d Borin presentation tests passed (pure lifecycle only).",count))
return true
