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
test("stationary daily non-work phase fades Borin without contacts and resumes recovery",function()
 local s=M.new();advance(s,0,2)
 local heldClock=s.clock;local faded=M.step(s,2.001,nil,true,false,false,false)
 equal(s.clock,heldClock);assert(faded.weight>0 and faded.weight<1 and not faded.contact)
 for i=121,150 do local r=M.step(s,i/60,nil,true,false,false,false);assert(not r.contact) end
 equal(s.weight,0);equal(s.clock,0);equal(s.mode,"Idle")
 local r=M.step(s,2.52,nil,true,false,false,true);equal(r.mode,"Recover");assert(r.weight>0 and r.weight<1 and not r.contact)
 r=M.step(s,2.54,5,true,false,false,false);equal(r.mode,"Interact");assert(not r.contact)
end)
test("generic activity fade recovers without strike clock and bounds suspension and stalls",function()
 local weight=0
 for _=1,60 do weight=M.activityWeight(weight,1/60,true,false) end;equal(weight,1)
 local fade=M.activityWeight(weight,1/60,false,false);assert(fade>0 and fade<1)
 for _=1,30 do weight=M.activityWeight(weight,1/60,false,false) end;equal(weight,0)
 local recovery=M.activityWeight(weight,1/60,true,false);assert(recovery>0 and recovery<1)
 equal(M.activityWeight(1,.1,true,true),0)
 assert(M.activityWeight(0,100,true,false)<1)
 equal(M.activityWeight(1,0/0,true,false),0);equal(M.activityWeight(0,math.huge,true,false),0)
 equal(M.activityWeight(.5,-1,true,false),.5)
end)
test("speaker attention turns toward each front side without overshoot or rear seam twitch",function()
 local right,left=0,0
 for _=1,120 do right=M.lookYaw(right,1/60,10,-1);left=M.lookYaw(left,1/60,-10,-1) end
 assert(right<-.9 and left>.9 and math.abs(right)<=math.rad(55))
 assert(math.abs(left+right)<1e-10)
 local rear=M.lookYaw(right,1/60,10,1);assert(rear>right and rear<0)
 local switched=M.lookYaw(right,1/60,-10,-1);assert(switched>right and switched<0)
end)
test("speaker expiry or missing target releases smoothly and bounded frames cannot snap",function()
 local yaw=.8
 local first=M.lookYaw(yaw,1/60,nil,nil);assert(first>0 and first<yaw)
 for _=1,180 do yaw=M.lookYaw(yaw,1/60,nil,nil) end;equal(yaw,0)
 assert(M.lookYaw(0,100,10,-1)>-math.rad(55))
 equal(M.lookYaw(.4,-1,10,-1),.4)
 equal(M.lookYaw(0/0,.1,10,-1),0);equal(M.lookYaw(.4,math.huge,10,-1),0)
 assert(M.lookYaw(.4,.1,math.huge,-1)<.4)
 local a,b=0,0
 for _=1,60 do a=M.lookYaw(a,1/60,3,-5) end
 for _=1,30 do b=M.lookYaw(b,1/30,3,-5) end
 assert(math.abs(a-b)<1e-10)
end)
print(string.format("%d Borin presentation tests passed (pure lifecycle only).",count))
return true
