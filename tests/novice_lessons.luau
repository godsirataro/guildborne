--!strict
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local combat=require("../src/server/Config/Combat");local lessons:any=require("../src/server/Config/NoviceLessons")
 local makeSession=require("../src/server/Systems/NoviceLessonSession");local makeTrial=require("../src/server/Systems/NoviceTrialSession")
 local gear=require("../src/shared/Data/Equipment")(content,require("../src/shared/Data/Expansion"),require("../src/shared/Data/StatusPoints"))
 local stats=require("../src/server/Systems/CombatStats")(content,combat,gear)
 local function data(lesson:any,classId:string):any return {progression={novice={claimed=lesson.Claimed,objectives={}}},character={level=lesson.Level,classId=if lesson.SelectedClass then classId else nil},party={adventurerIds={}},quests={},expansion={tower={}}}end
 test("All eight course lessons produce objective receipts through shared combat without profile grants",function()
  for id,lesson in pairs(lessons)do
   for _,classId in ipairs(if lesson.SelectedClass then content.AdventurerOrder else {lesson.Class})do
    local d=data(lesson,classId);local before=util.copy(d)
    local create=require("../src/server/Systems/NoviceTrialCombat")({Util=util,Content=content,Combat=combat,Stats=stats,Tuning=lesson,AbilityLessons=true,
     Trials=makeSession(id,lesson,util,makeTrial),Targeting=require("../src/server/Systems/CombatTargeting"),Damage=require("../src/server/Systems/CombatDamage"),Abilities=require("../src/server/Systems/CombatAbilities")})
    local sim:any=create(d,1,classId,"lesson1",0);local z=if classId=="Warrior"or classId=="Knight"then 4 elseif classId=="Archer"then 16 else 12
    local finished=false
    for tick=1,1400 do
     local at=tick*.2;local s=sim.snapshot();local p=if s.warning then {x=s.warning.x+8,y=0,z=s.warning.z}else {x=0,y=0,z=z}
     sim.step(at,p,true,true);sim.input("Ability",at);sim.input("Basic",at)
     if sim.snapshot().status=="Won"then local receipt=sim.receipt(at);eq(receipt.action,"NoviceObjective");eq(receipt.args,{objective=id});finished=true;break end
    end
    assert(finished,id..":"..classId);eq(d,before)
    if lesson.Goals.victory then eq(sim.snapshot().enemyHealth,0)else assert(sim.snapshot().enemyHealth>0)end
   end
  end
 end)
 test("Course combat eligibility rejects skipped repeated foreign-class and assisted lessons",function()
  for id,lesson in pairs(lessons)do
   local classId=lesson.Class or "Warrior";local d=data(lesson,classId);local rule=makeSession(id,lesson,util,makeTrial)
   assert(rule.start(d,1,classId,"a",0))
   d.progression.novice.claimed-=1;eq(rule.start(d,1,classId,"a",0),nil);d=data(lesson,classId)
   d.progression.novice.objectives[id]=true;eq(rule.start(d,1,classId,"a",0),nil);d=data(lesson,classId)
   d.party.adventurerIds={"friend"};eq(rule.start(d,1,classId,"a",0),nil);d=data(lesson,classId)
   d.character.level=lesson.Level-1;eq(rule.start(d,1,classId,"a",0),nil);d=data(lesson,classId)
   if lesson.SelectedClass then d.character.classId=nil else d.character.classId=classId end
   eq(rule.start(d,1,classId,"a",0),nil)
  end
 end)
end
