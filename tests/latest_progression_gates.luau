--!strict
local Rules=require("../src/shared/Data/Expansion")
local Content=require("../src/server/Config/Content")
local Status=require("../src/shared/Data/StatusPoints")
return function(test:any,eq:any)
 local function data(mode:string):any
  return {progression={ruleset=mode},quests={firstClears={quarry_patrol=true}},expansion={tower={highest=5},buildings={},gathered={}}}
 end
 test("latest journey Class2 waits for 35 while legacy gate remains compatible",function()
  local d=data(Content.ProgressionRulesets.Novice);local actor={classId="Warrior",level=34};local build={tier=1,skills={}}
  eq(Rules.advancementLevel(d,2),35);eq(Rules.advanceProblem(d,actor,build,"berserker"),"AdvancementLocked")
  actor.level=35;eq(Rules.advanceProblem(d,actor,build,"berserker"),nil)
  actor.level=30;d.progression.ruleset=Content.ProgressionRulesets.Legacy
  eq(Rules.advancementLevel(d,2),30);eq(Rules.advanceProblem(d,actor,build,"berserker"),nil)
 end)
 test("latest journey gate uses actor level rather than party leader level",function()
  local d=data(Content.ProgressionRulesets.Novice);d.character={level=100}
  eq(Rules.advanceProblem(d,{classId="Knight",level=10},{tier=1,skills={}},"guardian"),"AdvancementLocked")
  eq(Rules.advanceProblem(d,{classId="Knight",level=35},{tier=1,skills={}},"guardian"),nil)
 end)
 test("Class3 and quest prerequisites remain mandatory after level gate update",function()
  local d=data(Content.ProgressionRulesets.Novice);local actor={classId="Warrior",level=69};local build={tier=2,path="berserker",skills={}}
  eq(Rules.advanceProblem(d,actor,build,"warlord"),"AdvancementLocked")
  actor.level=70;eq(Rules.advanceProblem(d,actor,build,"warlord"),nil)
  d.quests.firstClears.quarry_patrol=false;eq(Rules.advanceProblem(d,actor,build,"warlord"),"AdvancementLocked")
 end)
 test("latest Hall and point budgets reuse existing formulas without additive grants",function()
  for _,row in ipairs({{1,20},{4,35},{11,70},{17,100},{20,100}}) do
   eq(Content.HallLevelCap(row[1],Content.ProgressionRulesets.Novice),row[2])
  end
  eq(Status.budget(10),27);eq(Status.budget(35),102);eq(Status.budget(100),297)
 end)
 test("new journey promotion refunds allocation even while status UI feature is disabled",function()
  local d=data(Content.ProgressionRulesets.Novice)
  d.character={classId="Warrior",level=35,xp=1700,statusAllocations={VIT=3}}
  d.expansion.actors={player={tier=1,skills={vitality=true},equipped="power_strike"}}
  d.currencies={gold=50};d.adventurers={}
  local service=require("../src/server/Services/ExpansionService")({StatusAllocationAvailable=false},{},{},Rules)
  eq(service.apply(d,"AdvanceClass",{actorId="player",pathId="berserker"},0,function()end),nil)
  eq(next(d.expansion.actors.player.skills),nil);eq(d.character.statusAllocations,nil)
  eq(d.character.xp,1700);eq(d.character.level,35);eq(d.currencies.gold,50)
  d.character.statusAllocations={VIT=5}
  eq(service.apply(d,"AdvanceClass",{actorId="player",pathId="berserker"},0,function()end),"InvalidClassPath")
  eq(d.character.statusAllocations.VIT,5)
 end)
 test("new journey advancement copy is bilingual and follows readiness threshold",function()
  local copy=require("../src/shared/Config/ClassAdvancementCopy")
  local d=data(Content.ProgressionRulesets.Novice)
  for _,language in ipairs({"en","th"}) do
   local text=copy.header(language,Rules.advancementLevel(d,2))
   eq(string.find(text,"35",1,true)~=nil,true);eq(string.find(text,"30",1,true),nil)
  end
 end)

 test("already earned Class2 at 30 remains schema-valid under new journey readiness",function()
  local d=data(Content.ProgressionRulesets.Novice)
  d.expansion=Rules.new();d.character={classId="Warrior",raceId="Human",level=30,tier=2,classPathId="berserker"}
  d.adventurers={};d.expansion.actors.player={tier=2,path="berserker",skills={vitality=true,path_art=true},equipped="cleave"}
  local validate=require("../src/server/Systems/ExpansionSchema")(Content,require("../src/shared/Util/TableUtil"),Rules)
  validate(d)
  eq(d.expansion.actors.player.path,"berserker");eq(d.character.level,30)
  eq(table.find(Rules.allowedSkills(d.expansion.actors.player,"power_strike"),"cleave")~=nil,true)
 end)
 test("new heroes start at 10 independently of current Hall or leader level",function()
  local d=data(Content.ProgressionRulesets.Novice);d.character={level=100}
  for _,hall in ipairs({1,4,11,17,20}) do
   local initial=Content.RecruitmentStartingXP(d)
   eq(Content:LevelFromXP(initial,Content.HallLevelCap(hall,Content.ProgressionRulesets.Novice)),10)
  end
 end)
 test("hero promotion refunds only that hero allocation and preserves player build",function()
  local d=data(Content.ProgressionRulesets.Novice)
  d.character={classId="Mage",level=70,xp=3450,statusAllocations={INT=9}}
  d.adventurers={owned={classId="Knight",level=35,xp=1700,statusAllocations={VIT=9}}}
  d.expansion.actors={player={tier=1,skills={vitality=true}},owned={tier=1,skills={vitality=true}}}
  d.currencies={gold=50}
  local service=require("../src/server/Services/ExpansionService")({StatusAllocationAvailable=false},{},{},Rules)
  eq(service.apply(d,"AdvanceClass",{actorId="owned",pathId="guardian"},0,function()end),nil)
  eq(d.adventurers.owned.statusAllocations,nil);eq(next(d.expansion.actors.owned.skills),nil)
  eq(d.character.statusAllocations.INT,9);eq(d.expansion.actors.player.skills.vitality,true)
  eq(d.character.xp,3450);eq(d.adventurers.owned.xp,1700);eq(d.currencies.gold,50)
 end)
 test("wrong class parent and direct Class3 jump remain forbidden",function()
  local d=data(Content.ProgressionRulesets.Novice);local actor={classId="Warrior",level=100}
  eq(Rules.advanceProblem(d,actor,{tier=1,skills={}},"guardian"),"InvalidClassPath")
  eq(Rules.advanceProblem(d,actor,{tier=1,skills={}},"warlord"),"InvalidClassPath")
  eq(Rules.advanceProblem(d,actor,{tier=2,path="duelist",skills={}},"warlord"),"InvalidClassPath")
 end)
 test("Class3 still requires Tower5 and prestige still requires quarters",function()
  local d=data(Content.ProgressionRulesets.Novice);local actor={classId="Warrior",level=70}
  local build={tier=2,path="berserker",skills={}}
  d.expansion.tower.highest=4;eq(Rules.advanceProblem(d,actor,build,"warlord"),"AdvancementLocked")
  d.expansion.tower.highest=5;eq(Rules.advanceProblem(d,actor,build,"commander"),"QuartersRequired")
 end)
 test("legacy promotion retains previously compatible allocation behavior",function()
  local d=data(Content.ProgressionRulesets.Legacy)
  d.character={classId="Warrior",level=30,xp=1450,statusAllocations={VIT=3}}
  d.expansion.actors={player={tier=1,skills={vitality=true}}};d.adventurers={}
  local service=require("../src/server/Services/ExpansionService")({StatusAllocationAvailable=false},{},{},Rules)
  eq(service.apply(d,"AdvanceClass",{actorId="player",pathId="berserker"},0,function()end),nil)
  eq(d.expansion.actors.player.skills.vitality,true);eq(d.character.statusAllocations.VIT,3)
 end)

end
