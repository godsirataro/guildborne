--!strict
return function(test:any,eq:any)
 local U=require("../src/shared/Util/TableUtil")
 local Identity=require("../src/server/Systems/StudioTrialIdentity")
 local Trial=require("../src/server/Systems/NoviceTrialSession")
 local Lesson=require("../src/server/Systems/NoviceLessonSession")
 local Config=require("../src/server/Config/NoviceTrials")
 local Lessons=require("../src/server/Config/NoviceLessons")
 local context={IsStudio=true,PlaceId=0,GameId=0,PersistenceMode="Memory"}
 local function data(claimed:number,level:number):any return {progression={novice={claimed=claimed,objectives={}}},character={level=level},party={adventurerIds={}},quests={},expansion={tower={}}}end
 test("default trial and lesson reject negative zero malformed owners",function()
  local trial=Trial(Config,U);local lesson=Lesson("practice_attack",Lessons.practice_attack,U,Trial)
  local invalid:any={-1,0,1.5,math.huge,0/0};invalid[6]="1"
  for _,id in ipairs(invalid)do eq(trial.start(data(5,10),id,"Warrior","run",0),nil);eq(lesson.start(data(1,3),id,"Warrior","run",0),nil)end
  assert(trial.start(data(5,10),1,"Warrior","run",0));assert(lesson.start(data(1,3),1,"Warrior","run",0))
 end)
 test("negative identity requires every local environment fence and exact current owner",function()
  local valid=Identity(context,-1,function()return true end);eq(valid(-1),true);eq(valid(-2),false);eq(valid(0),false);eq(valid(-1.5),false)
  for key,value in pairs({IsStudio=false,PlaceId=1,GameId=1,PersistenceMode="DataStore"})do local changed=U.copy(context);changed[key]=value;eq(Identity(changed,-1,function()return true end)(-1),false)end
  eq(Identity(nil,-1,function()return true end)(-1),false)
  local callbacks:any={function()return false end,function()error("gone")end,function()coroutine.yield();return true end}
  for _,callback in ipairs(callbacks)do eq(Identity(context,-1,callback)(-1),false)end
  eq(Identity(nil,42,function()return true end)(42),true)
 end)
 test("local trial keeps solo progression and exact receipt ownership",function()
  local current=true;local policy=Identity(context,-7,function()return current end)
  local trial=Trial(Config,U,policy);eq(trial.start(data(4,10),-7,"Warrior","run",0),nil)
  local d=data(5,10);d.party.adventurerIds={"hero"};eq(trial.start(d,-7,"Warrior","run",0),nil)
  local run=assert(trial.start(data(5,10),-7,"Warrior","run",0));local condition={owner=-7,runId="run",alone=true,health=50,distance=4}
  local serial=0;for kind,needed in pairs(Config.Classes.Warrior.Goals)do if kind~="victory"then for _=1,needed do serial+=1;eq(trial.observe(run,{id="e"..serial,owner=-7,runId="run",actorId="player",kind=kind},1,condition),nil)end end end
  eq(trial.observe(run,{id="win",owner=-7,runId="run",actorId="player",kind="victory"},1,condition),nil)
  local receipt=assert(trial.receipt(run,1,condition));eq(receipt.owner,-7);eq(receipt.action,"NoviceTrial")
  condition.owner=7;eq(trial.receipt(run,1,condition),nil);current=false;eq(trial.start(data(5,10),-7,"Warrior","new",2),nil)
 end)
 test("negative practice combat produces real hit receipt and input remains owner bound",function()
  local Content=require("../src/server/Config/Content");local Combat=require("../src/server/Config/Combat")
  local gear=require("../src/shared/Data/Equipment")(Content,require("../src/shared/Data/Expansion"),require("../src/shared/Data/StatusPoints"))
  local policy=Identity(context,-1,function()return true end)
  local create=require("../src/server/Systems/NoviceTrialCombat")({Util=U,Content=Content,Combat=Combat,Tuning=Lessons.practice_attack,AbilityLessons=true,Trials=Lesson("practice_attack",Lessons.practice_attack,U,Trial,policy),Stats=require("../src/server/Systems/CombatStats")(Content,Combat,gear),Targeting=require("../src/server/Systems/CombatTargeting"),Damage=require("../src/server/Systems/CombatDamage"),Abilities=require("../src/server/Systems/CombatAbilities")})
  local sim=assert(create(data(1,3),-1,"Warrior","practice",0));sim.step(.1,{x=0,y=0,z=4},true,true);eq(sim.input("Basic",.1),true)
  local receipt=assert(sim.receipt(.1));eq(receipt.owner,-1);eq(receipt.args.objective,"practice_attack")
  local input=require("../src/server/Systems/NoviceTrialInput")(-1);eq(input(-2,"Basic",1,0),false);eq(input(-1,"Basic",1,0),true);eq(input(-1,"Basic",1,1),false)
 end)
end
