--!strict
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local expansion=require("../src/shared/Data/Expansion");local base=require("../src/server/Config/Combat")
 local makeSession=require("../src/server/Systems/BorrowedPathSession");local makeTrial=require("../src/server/Systems/NoviceTrialSession")
 local gear=require("../src/shared/Data/Equipment")(content,expansion,require("../src/shared/Data/StatusPoints"))
 local function data(class:string):any return {character={classId=class,level=35},personalGuild={buildings={guildHall=4}},progression={campaign={claimed=11,objectives={meet_class_mentor=true}}},party={adventurerIds={"existing_companion"}},quests={},expansion={tower={}}}end
 test("All ten borrowed Class2 paths use their real ability and win without changing saved builds",function()
  local count=0
  for id,path in pairs(expansion.Paths)do if path.Tier==2 then
   count+=1;local config=util.copy(base);config.Classes[path.Class].Ability=path.Skill;config.Abilities[path.Skill]=util.copy(expansion.Abilities[path.Skill])
   local trials=makeSession(expansion,util,makeTrial,id)
   local create=require("../src/server/Systems/NoviceTrialCombat")({Util=util,Content=content,Combat=config,Trials=trials,Tuning={Level=35,EnemyHealth=1600},AbilityLessons=true,
    Stats=require("../src/server/Systems/CombatStats")(content,config,gear),Targeting=require("../src/server/Systems/CombatTargeting"),Damage=require("../src/server/Systems/CombatDamage"),Abilities=require("../src/server/Systems/CombatAbilities")})
   local profile=data(path.Class);local before=util.copy(profile);local sim:any=create(profile,1,path.Class,"borrow:"..id,100)
   local z=if path.Class=="Warrior"or path.Class=="Knight"or id=="spellblade"then 4 else 12
   local finishAt=0
   for tick=1,880 do
    local now=100+tick*.2;local s=sim.snapshot()
    if s.status~="Active"then eq(s.status,"Won");finishAt=now;break end
    local p=if s.warning then {x=s.warning.x+8,y=0,z=s.warning.z}else {x=0,y=0,z=z}
    eq(sim.step(now,p,true,true),nil);s=sim.snapshot();if s.status~="Active"then continue end
    sim.input("Ability",now)
    if (s.progress.skill_used or 0)>=1 and (s.progress.dodge or 0)>=1 then sim.input("Basic",now)end
   end
   assert(finishAt>0,id.." did not complete")
   local receipt,problem=sim.receipt(finishAt);eq(problem,nil);eq(receipt.action,"CampaignObjective");eq(receipt.args,{objective="complete_borrowed_path"})
   eq(sim.receipt(finishAt+.1),receipt);eq(profile,before)
  end end
  eq(count,10)
 end)
 test("Borrowed path admission rejects wrong class stage Hall level or active expeditions",function()
  local s=makeSession(expansion,util,makeTrial,"oracle");local profile=data("Priest")
  eq(select(2,s.start(profile,1,"Mage","test",100)),"InvalidClassPath")
  for _,mutate in ipairs({function(d:any)d.progression.campaign.claimed=10 end,function(d:any)d.progression.campaign.objectives.meet_class_mentor=nil end,function(d:any)d.progression.campaign.objectives.complete_borrowed_path=true end})do
   local d=util.copy(profile);mutate(d);eq(select(2,s.start(d,1,"Priest","test",100)),"WrongObjective")
  end
  local d=util.copy(profile);d.personalGuild.buildings.guildHall=3;eq(select(2,s.start(d,1,"Priest","test",100)),"ClassTrialLocked")
  d=util.copy(profile);d.character.level=34;eq(select(2,s.start(d,1,"Priest","test",100)),"ClassTrialLocked")
  d=util.copy(profile);d.quests.active={};eq(select(2,s.start(d,1,"Priest","test",100)),"FinishExpedition")
  assert(not pcall(function()makeSession(expansion,util,makeTrial,"prophet")end))
 end)
end
