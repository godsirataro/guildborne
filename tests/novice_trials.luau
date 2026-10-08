--!strict
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local config:any=require("../src/server/Config/NoviceTrials")
 local trial=require("../src/server/Systems/NoviceTrialSession")(config,util)
 local data={progression={novice={claimed=5}},character={level=10},party={adventurerIds={}},quests={},expansion={tower={}}}
 local function condition():any return {owner=1,runId="lesson1",alone=true,health=100,distance=10} end
 local function event(kind:string,index:number):any return {id="event:"..index,runId="lesson1",owner=1,actorId="player",kind=kind,distance=20,restoredHP=10}end
 test("all five solo trials require every class lesson before stable completion receipt",function()
  for classId,def in pairs(config.Classes)do
   local run:any,code=trial.start(data,1,classId,"lesson1",100);eq(code,nil)
   local receipt,problem=trial.receipt(run,101,condition());eq(receipt,nil);eq(problem,"TrialIncomplete")
   local serial=0
   for kind,needed in pairs(def.Goals)do if kind=="victory"then continue end;for _=1,(if kind=="heal" then needed/10 else needed)do
    serial+=1;local e=event(kind,serial);eq(trial.observe(run,e,102,condition()),nil)
    local before=util.copy(run);eq(trial.observe(run,e,102,condition()),"AlreadyObserved");eq(run,before)
   end end
   serial+=1;eq(trial.observe(run,event("victory",serial),102,condition()),nil)
   eq(run.status,"Won");receipt,problem=trial.receipt(run,103,condition());eq(problem,nil);eq(receipt.args.classId,classId);eq(receipt.owner,1)
   eq(trial.receipt(run,104,condition()),receipt)
  end
 end)
 test("solo trial rejects foreign duplicate conflicting and unmeasured combat evidence",function()
  local run:any=trial.start(data,1,"Archer","lesson1",100);local e=event("ranged_hit",1)
  e.owner=2;eq(trial.observe(run,e,101,condition()),"InvalidTrialEvent");e.owner=1;e.actorId="h:1";eq(trial.observe(run,e,101,condition()),"InvalidTrialEvent")
  e.actorId="player";e.distance=8;eq(trial.observe(run,e,101,condition()),"RangeLessonRequired");e.distance=20
  eq(trial.observe(run,e,101,condition()),nil);e.distance=21;eq(trial.observe(run,e,101,condition()),"TrialEventConflict")
  local c=condition();c.owner=2;eq(trial.observe(run,event("dodge",2),101,c),"ForeignTrial");eq(run.status,"Active")
  eq(trial.observe(run,event("heal",3),101,condition()),"WrongTrialLesson")
  run=trial.start(data,1,"Priest","lesson1",100);e=event("heal",1);e.restoredHP=math.huge;eq(trial.observe(run,e,101,condition()),"InvalidTrialEvent")
 end)
 test("trial death timeout assist escape and event flood invalidate the run permanently",function()
  for _,mode in ipairs({"death","timeout","assist","escape","flood"})do
   local run:any=trial.start(data,1,"Warrior","lesson1",100);local c=condition();local now=101
   if mode=="death"then c.health=0 elseif mode=="timeout"then now=400 elseif mode=="assist"then c.alone=false elseif mode=="escape"then c.distance=46
   else run.eventCount=config.MaxEvents end
   assert(trial.observe(run,event("basic_hit",1),now,c));eq(run.status,"Failed")
   local receipt=trial.receipt(run,102,condition());eq(receipt,nil)
  end
 end)
 test("trial start requires eligible level10 classless solo profile and bounded identity",function()
  for _,mutate in ipairs({function(d:any)d.character.level=9 end,function(d:any)d.character.classId="Mage"end,function(d:any)d.progression.novice.claimed=4 end,function(d:any)d.party.adventurerIds={"h:1"}end,function(d:any)d.quests.active={}end,function(d:any)d.expansion.tower.active={}end})do
   local d=util.copy(data);mutate(d);eq(trial.start(d,1,"Mage","lesson1",100),nil)
  end
  eq(trial.start(data,1,"Unknown","lesson1",100),nil);eq(trial.start(data,1,"Mage",string.rep("x",65),100),nil)
  eq(trial.start(data,1,"Mage",string.rep("x",59),100),nil)
  local run:any=trial.start(data,1,"Mage",string.rep("x",58),100);assert(run)
 end)
 test("trial victory before lessons fails without awarding a class receipt",function()
  for classId in pairs(config.Classes)do
   local run:any=trial.start(data,1,classId,"lesson1",100)
   eq(trial.observe(run,event("victory",1),101,condition()),"TrialLessonsIncomplete")
   eq(run.status,"Failed");eq(trial.receipt(run,102,condition()),nil)
  end
 end)
end
