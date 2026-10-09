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

end
