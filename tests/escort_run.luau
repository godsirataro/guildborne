--!strict
return function(test:any,eq:any)
 local make=require("../src/server/Systems/EscortRun")
 local function evidence():any return {ownerAlive=true,ownerDistance=5,npcAlive=true,blocked=false,sessionCurrent=true}end
 local function route():any return {{x=0,y=0,z=0},{x=10,y=0,z=0},{x=10,y=0,z=10}}end
 test("Escort walks the complete ordered route at capped server speed",function()
  local s=make(route(),5);local e=evidence()
  local first=s.step(100,e);eq(first.traveled,1.25);eq(first.status,"Walking")
  for _=1,15 do s.step(.25,e)end
  local done=s.snapshot();eq(done.status,"Completed");eq(done.position,{x=10,y=0,z=10});eq(done.traveled,20)
  eq(s.step(10,e),done);s.cancel();eq(s.snapshot(),done)
 end)
 test("Escort waits for its owner and resumes without skipping distance",function()
  local s=make(route());local e=evidence();e.ownerDistance=25
  for _=1,40 do s.step(.25,e)end
  eq(s.snapshot().status,"Paused");eq(s.snapshot().traveled,0)
  e.ownerDistance=24;s.step(.25,e);eq(s.snapshot().status,"Walking");eq(s.snapshot().traveled,1.25)
  e.ownerDistance=50;for _=1,120 do s.step(.25,e)end
  eq(s.snapshot().status,"Failed");eq(s.snapshot().reason,"OwnerLeft")
 end)
 test("Escort arrival waits until the owner also reaches the safe exit",function()
  local s=make(route());local e=evidence();e.exitDistance=21
  for _=1,16 do s.step(.25,e)end
  eq(s.snapshot().status,"Paused");eq(s.snapshot().reason,"MeetAtExit");eq(s.snapshot().traveled,20)
  e.exitDistance=8.1;s.step(.25,e);eq(s.snapshot().status,"Paused")
  e.exitDistance=8;s.step(.25,e);eq(s.snapshot().status,"Completed")
 end)
 test("Escort fails on defeat or sustained obstruction and cancels stale sessions",function()
  for _,case in ipairs({{field="ownerAlive",value=false,reason="OwnerDefeated",status="Failed"},{field="npcAlive",value=false,reason="NpcDefeated",status="Failed"},{field="sessionCurrent",value=false,reason="SessionChanged",status="Cancelled"}})do
   local s=make(route());local e=evidence();e[case.field]=case.value;s.step(.1,e)
   eq(s.snapshot().status,case.status);eq(s.snapshot().reason,case.reason);eq(s.snapshot().traveled,0)
  end
  local s=make(route());local e=evidence();e.blocked=true
  for _=1,20 do s.step(.25,e)end
  eq(s.snapshot().status,"Failed");eq(s.snapshot().reason,"PathBlocked");eq(s.snapshot().traveled,0)
 end)
 test("Escort isolates mutable input and snapshots and rejects malformed routes",function()
  local r=route();local s=make(r);r[2].x=999
  local snapshot=s.snapshot();snapshot.position.x=999;eq(s.snapshot().position.x,0)
  for _=1,16 do s.step(.25,evidence())end;eq(s.snapshot().position.x,10)
  for _,invalid in ipairs({{},{{x=0,y=0,z=0}},{{x=0,y=0,z=0},{x=0,y=0,z=0}},{{x=0,y=0,z=0},{x=101,y=0,z=0}},{{x=0,y=0,z=0},{x=0/0,y=0,z=0}}})do assert(not pcall(function()make(invalid)end))end
  assert(not pcall(function()make(route(),100)end));assert(not pcall(function()s.step(-1,evidence())end))
 end)
end
