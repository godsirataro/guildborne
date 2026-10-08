--!strict
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local config=require("../src/server/Config/TowerGuardian");local combat=require("../src/server/Config/Combat")
 local make=require("../src/server/Systems/TowerGuardianSession");local base=require("../src/server/Systems/NoviceTrialSession")
 local gear=require("../src/shared/Data/Equipment")(content,require("../src/shared/Data/Expansion"),require("../src/shared/Data/StatusPoints"))
 local function data(class:string):any return {character={classId=class,level=65,classPathId=string.lower(class)..":1",skillId="saved",xp=3200},personalGuild={buildings={guildHall=10}},progression={campaign={claimed=23,objectives={},choices={choose_witness_route="trust"}}},party={adventurerIds={"owned_companion"}},inventory={stacks={herb=3}},quests={},expansion={tower={}}}end
 test("Ledger guardian all five real class abilities win with two dodges and preserve saved profiles",function()
  for _,class in ipairs(content.AdventurerOrder)do
   local trials=make(config,util,base)
   local create=require("../src/server/Systems/NoviceTrialCombat")({Util=util,Content=content,Combat=combat,Trials=trials,Tuning=config,AbilityLessons=true,
    Stats=require("../src/server/Systems/CombatStats")(content,combat,gear),Targeting=require("../src/server/Systems/CombatTargeting"),Damage=require("../src/server/Systems/CombatDamage"),Abilities=require("../src/server/Systems/CombatAbilities")})
   local profile=data(class);local before=util.copy(profile);local sim:any=create(profile,1,class,"ledger:"..class,100);local finishAt=0
   for tick=1,880 do
    local now=100+tick*.2;local s=sim.snapshot()
    if s.status~="Active"then eq(s.status,"Won");finishAt=now;break end
    local z=if class=="Warrior"or class=="Knight"then 4 else 12
    local p=if s.warning then {x=s.warning.x+8,y=0,z=s.warning.z}else {x=0,y=0,z=z}
    eq(sim.step(now,p,true,true),nil);s=sim.snapshot();if s.status~="Active"then continue end
    sim.input("Ability",now)
    if (s.progress.skill_used or 0)>=1 and (s.progress.dodge or 0)>=2 then sim.input("Basic",now)end
   end
   assert(finishAt>0,class.." cannot finish")
   local receipt,problem=sim.receipt(finishAt);eq(problem,nil);eq(receipt.action,"CampaignObjective");eq(receipt.args,{objective=config.Objective});eq(sim.receipt(finishAt+.1),receipt)
   eq(profile,before);eq(sim.snapshot().progress.dodge,2)
  end
 end)
 test("Ledger guardian rejects wrong class checkpoint level Hall and active expeditions",function()
  local s=make(config,util,base);local profile=data("Priest")
  eq(select(2,s.start(profile,1,"Mage","test",100)),"InvalidClass")
  for _,change in ipairs({function(d:any)d.progression.campaign.claimed=22 end,function(d:any)d.progression.campaign.claimed=24 end,function(d:any)d.progression.campaign.objectives[config.Objective]=true end})do
   local d=util.copy(profile);change(d);eq(select(2,s.start(d,1,"Priest","test",100)),"WrongObjective")
  end
  local d=util.copy(profile);d.character.level=64;eq(select(2,s.start(d,1,"Priest","test",100)),"ClassTrialLocked")
  d=util.copy(profile);d.personalGuild.buildings.guildHall=9;eq(select(2,s.start(d,1,"Priest","test",100)),"ClassTrialLocked")
  d=util.copy(profile);d.quests.active={};eq(select(2,s.start(d,1,"Priest","test",100)),"FinishExpedition")
  d=util.copy(profile);d.expansion.tower.active={};eq(select(2,s.start(d,1,"Priest","test",100)),"FinishExpedition")
  for _,now in ipairs({0/0,math.huge,-1})do eq(select(2,s.start(profile,1,"Priest","test",now)),"InvalidTrial")end
  eq(select(2,s.start(profile,0,"Priest","test",100)),"InvalidTrial")
 end)
 test("Ledger receipts require measured skill two dodges and victory with isolation and live health",function()
  local s=make(config,util,base);local p=data("Knight")
  local function run():any return s.start(p,1,"Knight","fixture",100)end
  local condition={owner=1,runId="fixture",alone=true,health=100,distance=4}
  local r=run();eq(select(2,s.receipt(r,101,condition)),"TrialIncomplete")
  local function event(r:any,id:string,kind:string) return s.observe(r,{id=id,kind=kind,actorId="player",owner=1,runId="fixture"},101,condition)end
  eq(event(r,"early","victory"),"TrialLessonsIncomplete");eq(select(2,s.receipt(r,102,condition)),"TrialLessonsIncomplete")
  r=run();eq(event(r,"skill","skill_used"),nil);eq(event(r,"dodge1","dodge"),nil);eq(event(r,"dodge1","dodge"),"AlreadyObserved");eq(r.progress.dodge,1)
  eq(event(r,"dodge2","dodge"),nil);eq(event(r,"victory","victory"),nil)
  local receipt=s.receipt(r,102,condition);eq(receipt.requestId,"ledger:fixture")
  for _,change in ipairs({function(c:any)c.alone=false end,function(c:any)c.health=0 end,function(c:any)c.distance=46 end})do
   local c=util.copy(condition);change(c);local lost=util.copy(r);eq(s.receipt(lost,102,c),nil)
  end
  eq(s.receipt(util.copy(r),280,condition),nil)
  local foreign=util.copy(condition);foreign.owner=2;eq(select(2,s.receipt(r,102,foreign)),"ForeignTrial");eq(r.status,"Won")
 end)
end
