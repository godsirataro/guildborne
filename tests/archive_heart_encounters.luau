--!strict
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local config=require("../src/server/Config/ArchiveHeartEncounters")
 local geometry=require("../src/server/Systems/AdventurePatterns")
 local factory=require("../src/server/Systems/ArchiveHeartEncounter")
 local create=factory(config,util,geometry)
 local function profile(mode:string,class:string):any
  local m=config.Modes[mode]
  return {character={classId=class,level=m.Level},personalGuild={buildings={guildHall=m.Hall}},progression={campaign={claimed=m.Claimed,objectives=if m.Prerequisite then {[m.Prerequisite]=true}else {}}},quests={},expansion={tower={}}}
 end
 local function dodge(s:any,at:number):(number,any)
  local v=s.snapshot();if v.phase=="Ready"then at=v.deadline;eq(s.step(at,{x=0,y=0,z=16},true,true),"Active");v=s.snapshot()end
  eq(v.phase,"Warning");local w=v.warning
  local safe=if w.shape=="Line"then {x=-w.dz*10,y=0,z=w.dx*10}elseif w.shape=="Ring"then {x=0,y=0,z=0}else {x=w.x+9,y=0,z=w.z}
  assert(not geometry.contains(w,safe));at=v.deadline;eq(s.step(at,safe,true,true),"Active");return at,safe
 end
 local function interact(s:any,at:number,action:string):number
  at+=.1;local target=s.snapshot().target;eq(s.step(at,target,true,true),"Active");eq(s.act(action,at),true);return at
 end
 test("Archive encounters admit the exact chapter class Hall and prior evidence without profile mutation",function()
  for _,mode in ipairs({"warden","keeper"})do
   local d=profile(mode,"Knight");local before=util.copy(d);assert(create(d,1,"trial",mode,100));eq(d,before)
   d.character.level-=1;eq(select(2,create(d,1,"trial",mode,100)),"ClassTrialLocked");d=util.copy(before);d.personalGuild.buildings.guildHall-=1;eq(select(2,create(d,1,"trial",mode,100)),"ClassTrialLocked")
   d=util.copy(before);d.progression.campaign.claimed-=1;eq(select(2,create(d,1,"trial",mode,100)),"WrongObjective")
   d=util.copy(before);d.progression.campaign.objectives[config.Modes[mode].Objective]=true;eq(select(2,create(d,1,"trial",mode,100)),"WrongObjective")
   d=util.copy(before);d.quests.active={};eq(select(2,create(d,1,"trial",mode,100)),"FinishExpedition")
  end
  local d=profile("warden","Mage");d.progression.campaign.objectives={};eq(select(2,create(d,1,"trial","warden",100)),"WrongObjective")
  eq(select(2,create(profile("keeper","Mage"),0,"trial","keeper",100)),"InvalidTrial")
 end)
 test("Five root classes finish three distinct warden warnings and all keeper rescue seal combat phases",function()
  local content=require("../src/server/Config/Content");local combat=require("../src/server/Config/Combat")
  local expansion=require("../src/shared/Data/Expansion");local gear=require("../src/shared/Data/Equipment")(content,expansion,require("../src/shared/Data/StatusPoints"))
  local stats=require("../src/server/Systems/CombatStats")(content,combat,gear)
  for _,class in ipairs(content.AdventurerOrder)do for _,mode in ipairs({"warden","keeper"})do
   local data=profile(mode,class);local before=util.copy(data);local s=assert(create(data,1,class..mode,mode,100));local at=100;local hits=0;local shapes={}
   for stage=1,3 do
    eq(s.step(s.snapshot().deadline,{x=0,y=0,z=16},true,true),"Active");table.insert(shapes,s.snapshot().warning.shape)
    at=dodge(s,at)
    if mode=="keeper"then at=interact(s,at,"Rescue")end
    at=interact(s,at,"Release")
    if mode=="keeper"then
     local damage=stats.hero(class,100,content.Character.Classes[class].Weapon).Attack
     while s.snapshot().phase=="Attack"do at+=.5;eq(s.step(at,{x=0,y=0,z=4},true,true),"Active");hits+=1;eq(s.hit("hit:"..hits,damage,at),true)end
    end
    eq(s.snapshot().seals,stage)
   end
   eq(shapes,{"Line","Ring","Circle"});eq(s.snapshot().status,"Won");eq(s.snapshot().mistakes,0)
   eq(s.snapshot().rescues,if mode=="keeper"then 3 else 0)
   local receipt=assert(s.receipt(at,1));eq(receipt.args.objective,config.Modes[mode].Objective);eq(s.receipt(at+.1,1),receipt)
   eq(select(2,s.receipt(at,2)),"ForeignTrial");eq(data,before)
  end end
 end)
 test("Archive warnings are immutable and hits or late world samples cannot grant a safe dodge",function()
  local s=assert(create(profile("warden","Warrior"),1,"fail","warden",100))
  for i=1,3 do
   s.step(s.snapshot().deadline,{x=0,y=0,z=16},true,true);local v=s.snapshot();v.warning.width=0
   eq(s.snapshot().warning.width,6)
   s.step(v.deadline,{x=0,y=0,z=16},true,true);eq(s.snapshot().mistakes,i);eq(s.snapshot().seals,0)
  end
  eq(s.snapshot().status,"Failed");eq(select(2,s.receipt(120,1)),"TrialIncomplete")
  s=assert(create(profile("keeper","Mage"),1,"late","keeper",100));s.step(101,{x=0,y=0,z=16},true,true)
  s.step(105,{x=20,y=0,z=0},true,true);eq(s.snapshot().mistakes,1);eq(s.snapshot().phase,"Ready")
 end)
 test("Archive phases enforce proximity fresh samples time windows and core immunity",function()
  local s=assert(create(profile("keeper","Archer"),1,"gates","keeper",100));s.step(101,{x=0,y=0,z=16},true,true)
  eq(select(2,s.hit("early",999,101)),"CoreShielded");local at=dodge(s,101)
  eq(select(2,s.act("Release",at)),"WrongPhase");eq(select(2,s.act("Rescue",at)),"OutOfRange")
  local target=s.snapshot().target;s.step(at+.1,target,true,true);eq(select(2,s.act("Rescue",at+.7)),"SampleRequired")
  at=interact(s,at+.7,"Rescue");eq(s.snapshot().rescues,1)
  local deadline=s.snapshot().deadline;s.step(deadline,target,true,true);eq(s.snapshot().phase,"Ready");eq(s.snapshot().seals,0)
  at=dodge(s,deadline);at=interact(s,at,"Rescue");eq(s.snapshot().rescues,1);at=interact(s,at,"Release")
  s.step(at+.1,{x=30,y=0,z=0},true,true);eq(select(2,s.hit("far",10,at+.1)),"OutOfRange")
 end)
 test("Archive hit IDs deduplicate conflicts cooldown and bounded event memory",function()
  local bounded=util.copy(config);bounded.MaxHitEvents=2
  local s=assert(factory(bounded,util,geometry)(profile("keeper","Mage"),1,"hits","keeper",100));local at=dodge(s,100)
  at=interact(s,at,"Rescue");at=interact(s,at,"Release");at+=.1;s.step(at,{x=0,y=0,z=4},true,true)
  eq(select(2,s.hit("bad",0/0,at)),"InvalidHit");eq(s.hit("one",1,at),true)
  eq(select(2,s.hit("one",1,at)),"AlreadyObserved");eq(select(2,s.hit("one",2,at)),"HitConflict")
  eq(select(2,s.hit("two",1,at)),"Cooldown");at+=.5;s.step(at,{x=0,y=0,z=4},true,true);eq(s.hit("two",1,at),true)
  at+=.5;s.step(at,{x=0,y=0,z=4},true,true);eq(select(2,s.hit("three",1,at)),"EventLimit");eq(s.snapshot().status,"Failed")
 end)
 test("Archive cancellation death arena bounds and expiry never yield a completion receipt",function()
  for _,kind in ipairs({"session","death","bounds","expiry","cancel"})do
   local s=assert(create(profile("keeper","Priest"),1,kind,"keeper",100))
   eq(s.step(99,{x=0,y=0,z=16},true,true),"InvalidSample");eq(s.step(101,{x=0/0,y=0,z=16},true,true),"InvalidSample")
   if kind=="cancel"then s.cancel()else s.step(if kind=="expiry"then 340 else 101,{x=if kind=="bounds"then 46 else 0,y=0,z=0},kind~="session",kind~="death")end
   assert(s.snapshot().status=="Failed"or s.snapshot().status=="Cancelled");assert(s.receipt(340,1)==nil)
  end
 end)
end
