--!strict
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local expansion=require("../src/shared/Data/Expansion");local base=require("../src/server/Config/Combat")
 local makeSession=require("../src/server/Systems/BorrowedPathSession");local makeTrial=require("../src/server/Systems/NoviceTrialSession")
 local gear=require("../src/shared/Data/Equipment")(content,expansion,require("../src/shared/Data/StatusPoints"))
 local function data(class:string):any return {character={classId=class,level=70},personalGuild={buildings={guildHall=11}},progression={campaign={claimed=24,objectives={meet_crosshaven_mentor=true}}},party={adventurerIds={"existing_companion"}},quests={},expansion={tower={}}}end
 local proof=require("../src/server/Systems/Class3Proof")(expansion,util)
 local function qualified(pathId:string):any
  local path=expansion.Paths[pathId];local d=data(path.Class)
  d.profile={userId=1};d.progression.ruleset=content.ProgressionRulesets.Novice;d.adventurers={}
  local parents={commander="berserker",rune_knight="guardian",bard="cleric",shadow_dancer="ranger"}
  d.expansion.actors={player={tier=2,path=path.Parent or parents[pathId],skills={}}}
  d.expansion.buildings={q={kind="quarters"}};d.expansion.gathered={wood=true,stone=true,ore=true,herbs=true};d.expansion.tower.highest=path.Floor
  d.quests.firstClears={quarry_patrol=true};return d
 end
 local function simulate(d:any,pathId:string,currentData:any?):any
  local path=expansion.Paths[pathId];local config=util.copy(base);config.Classes[path.Class].Ability=path.Skill;config.Abilities[path.Skill]=util.copy(expansion.Abilities[path.Skill])
  local trials=makeSession(expansion,util,makeTrial,pathId,true,proof,currentData)
  local create=trials.combatFactory(require("../src/server/Systems/NoviceTrialCombat"),{Util=util,Content=content,Combat=config,Trials=trials,Tuning={Level=70,EnemyHealth=3200},AbilityLessons=true,
   Stats=require("../src/server/Systems/CombatStats")(content,config,gear),Targeting=require("../src/server/Systems/CombatTargeting"),Damage=require("../src/server/Systems/CombatDamage"),Abilities=require("../src/server/Systems/CombatAbilities")})
  return assert(create(d,1,path.Class,"proof:"..pathId,100))
 end
 local function win(sim:any,pathId:string,guardHit:boolean?):number
  local class=expansion.Paths[pathId].Class
  local z=if class=="Warrior"or class=="Knight"or pathId=="arcane_knight"then 4 else 12
  for tick=1,880 do
   local now=100+tick*.2;local s=sim.snapshot();if s.status=="Won" or s.status=="Failed"then return now end
   eq(s.status,"Active")
   local takeHit=guardHit~=false and expansion.Abilities[expansion.Paths[pathId].Skill].Effect=="Guard" and s.playerHealth==s.playerMaxHealth
   local p=if s.warning and not takeHit then {x=s.warning.x+8,y=0,z=s.warning.z}else {x=0,y=0,z=z}
   sim.step(now,p,true,true);s=sim.snapshot();if s.status~="Active"then continue end
   if expansion.Abilities[expansion.Paths[pathId].Skill].Effect~="Guard" or s.warning or (s.progress.skill_used or 0)>0 then sim.input("Ability",now)end
   if (s.progress.skill_used or 0)>=1 and (s.progress.dodge or 0)>=2 then sim.input("Basic",now)end
  end
  error("Trial did not win: "..pathId)
 end
 test("Class3 player all fourteen actual abilities emit latched combined or poststory proof-only receipts",function()
  local count=0
  for pathId,path in pairs(expansion.Paths)do if path.Tier==3 then
   count+=1
   for _,repeatMode in ipairs({false,true})do
    local d=qualified(pathId);if repeatMode then d.progression.campaign.claimed=30;d.progression.campaign.objectives={}end
    local before=util.copy(d);local sim=simulate(d,pathId,function()return d end);local at=win(sim,pathId)
    local receipt=assert(sim.receipt(at));eq(receipt.action,"Class3Proof");eq(receipt.owner,1);eq(receipt.args.actorId,"player");eq(receipt.args.pathId,pathId)
    eq(receipt.args.sourceKind,if repeatMode then "actor_mastery" else "crosshaven_mastery")
    eq(receipt.args.storyObjective,if repeatMode then nil else "complete_borrowed_mastery");eq(d,before);eq(sim.receipt(at+.1),receipt)
   end
  end end;eq(count,14)
 end)
 test("Class3 player retains real story-only completion for Tier1 earnedTier3 and missingTower Tier2",function()
  for _,kind in ipairs({"tier1","tier3","tower"})do
   local d=qualified("warlord")
   if kind=="tier1"then d.expansion.actors.player={tier=1,skills={}}
   elseif kind=="tier3"then d.expansion.actors.player={tier=3,path="warlord",skills={}}
   else d.expansion.tower.highest=4 end
   local before=util.copy(d);local sim=simulate(d,"warlord",function()return d end);local at=win(sim,"warlord")
   eq(assert(sim.receipt(at)).action,"CampaignObjective");eq(d,before)
  end
 end)
 test("Class3 player Guard must reduce a real hit rather than cast safely and win with basics",function()
  for _,pathId in ipairs({"fortress","commander"})do
   local d=qualified(pathId);local sim=simulate(d,pathId,function()return d end);local at=win(sim,pathId,false)
   eq(sim.snapshot().status,"Failed");eq(sim.snapshot().problem,"TrialLessonsIncomplete");eq(sim.receipt(at),nil)
   -- Proof-ineligible earned builds keep their old story completion criteria.
   d=qualified(pathId);d.expansion.actors.player={tier=3,path=pathId,skills={}}
   sim=simulate(d,pathId,function()return d end);at=win(sim,pathId,false)
   eq(assert(sim.receipt(at)).action,"CampaignObjective")
  end
 end)
 test("Class3 player admission refuses foreign identity premature repeat and unqualified repeated lesson",function()
  local s=makeSession(expansion,util,makeTrial,"warlord",true,proof);local d=qualified("warlord")
  eq(select(2,s.start(d,2,"Warrior","x",100)),"InvalidTrial")
  d.progression.campaign.objectives.meet_crosshaven_mentor=nil;eq(select(2,s.start(d,1,"Warrior","x",100)),"WrongObjective")
  d.progression.campaign.claimed=30;d.expansion.tower.highest=4;eq(select(2,s.start(d,1,"Warrior","x",100)),"AdvancementLocked")
  d.expansion.tower.highest=5;d.quests.active={};eq(select(2,s.start(d,1,"Warrior","x",100)),"FinishExpedition")
  d.quests.active=nil;eq(select(2,s.start(d,1,"Warrior",string.rep("a",49),100)),"InvalidReceipt")
 end)
 test("Class3 player cannot emit proof from forgedWon cancelled dead expired or replaced context",function()
  local d=qualified("warlord");local live:any=d
  local s=makeSession(expansion,util,makeTrial,"warlord",true,proof,function()return live end)
  local run=assert(s.start(d,1,"Warrior","x",100));run.status="Won"
  eq(select(2,s.receipt(run,101,{owner=1,runId="x",alone=true,health=100,distance=4})),"TrialIncomplete")
  for _,kind in ipairs({"cancel","dead","expired","context","snapshot"})do
   d=qualified("warlord");live=d;local sim=simulate(d,"warlord",function()return live end)
   if kind=="cancel"then sim.cancel()
   elseif kind=="dead"then sim.step(101,{x=0,y=0,z=4},true,false)
   elseif kind=="expired"then sim.step(280,{x=0,y=0,z=4},true,true)
   elseif kind=="context"then live=nil;sim.step(101,{x=0,y=0,z=4},true,true)
   else d.character.level=71;sim.step(101,{x=0,y=0,z=4},true,true)end
   eq(sim.receipt(281),nil)
  end
 end)
 test("All fourteen borrowed Class3 paths use their real ability and win without changing saved builds",function()
  local count=0
  for id,path in pairs(expansion.Paths)do if path.Tier==3 then
   count+=1;local config=util.copy(base);config.Classes[path.Class].Ability=path.Skill;config.Abilities[path.Skill]=util.copy(expansion.Abilities[path.Skill])
   local trials=makeSession(expansion,util,makeTrial,id,true)
   local create=require("../src/server/Systems/NoviceTrialCombat")({Util=util,Content=content,Combat=config,Trials=trials,Tuning={Level=70,EnemyHealth=3200},AbilityLessons=true,
    Stats=require("../src/server/Systems/CombatStats")(content,config,gear),Targeting=require("../src/server/Systems/CombatTargeting"),Damage=require("../src/server/Systems/CombatDamage"),Abilities=require("../src/server/Systems/CombatAbilities")})
   local profile=data(path.Class);local before=util.copy(profile);local sim:any=create(profile,1,path.Class,"borrow:"..id,100)
   local z=if path.Class=="Warrior"or path.Class=="Knight"or id=="arcane_knight"then 4 else 12
   local finishAt=0
   for tick=1,880 do
    local now=100+tick*.2;local s=sim.snapshot()
    if s.status~="Active"then eq(s.status,"Won");finishAt=now;break end
    local p=if s.warning then {x=s.warning.x+8,y=0,z=s.warning.z}else {x=0,y=0,z=z}
    eq(sim.step(now,p,true,true),nil);s=sim.snapshot();if s.status~="Active"then continue end
    sim.input("Ability",now)
    if (s.progress.skill_used or 0)>=1 and (s.progress.dodge or 0)>=2 then sim.input("Basic",now)end
   end
   assert(finishAt>0,id.." did not complete")
   local receipt,problem=sim.receipt(finishAt);eq(problem,nil);eq(receipt.action,"CampaignObjective");eq(receipt.args,{objective="complete_borrowed_mastery"})
   eq(sim.receipt(finishAt+.1),receipt);eq(profile,before)
  end end
  eq(count,14)
 end)
 test("Borrowed mastery admission rejects wrong class stage Hall level or active expeditions",function()
  local s=makeSession(expansion,util,makeTrial,"prophet",true);local profile=data("Priest")
  eq(select(2,s.start(profile,1,"Mage","test",100)),"InvalidClassPath")
  for _,mutate in ipairs({function(d:any)d.progression.campaign.claimed=23 end,function(d:any)d.progression.campaign.objectives.meet_crosshaven_mentor=nil end,function(d:any)d.progression.campaign.objectives.complete_borrowed_mastery=true end})do
   local d=util.copy(profile);mutate(d);eq(select(2,s.start(d,1,"Priest","test",100)),"WrongObjective")
  end
  local d=util.copy(profile);d.personalGuild.buildings.guildHall=10;eq(select(2,s.start(d,1,"Priest","test",100)),"ClassTrialLocked")
  d=util.copy(profile);d.character.level=69;eq(select(2,s.start(d,1,"Priest","test",100)),"ClassTrialLocked")
  d=util.copy(profile);d.quests.active={};eq(select(2,s.start(d,1,"Priest","test",100)),"FinishExpedition")
  assert(not pcall(function()makeSession(expansion,util,makeTrial,"oracle",true)end))
 end)
end
