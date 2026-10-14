--!strict
return function(test:any,eq:any,harness:any?)
 local U=require("../src/shared/Util/TableUtil")
 local C=require("../src/server/Config/Content")
 local E=require("../src/shared/Data/Expansion")
 local T=require("../src/server/Systems/HeroMentorTrial")(E,U)
 local G=require("../src/shared/Data/Equipment")(C,E,require("../src/shared/Data/StatusPoints"))
 local config=U.copy(require("../src/server/Config/Combat"));for id,def in pairs(E.Abilities)do config.Abilities[id]=def end
 local stats=require("../src/server/Systems/CombatStats")(C,config,G)
 local validateExpansion=require("../src/server/Systems/ExpansionSchema")(C,U,E)
 local marketConfig=require("../src/server/Config/Market")
 local market=require("../src/server/Systems/MarketEscrow")(marketConfig,U,C,require("../src/server/Systems/MarketOrders")(marketConfig,U))
 local land=require("../src/shared/Data/GuildLand")(require("../src/server/Config/GuildLand"))
 local schema=require("../src/server/Systems/ProfileSchema")(C,U,G,E,validateExpansion,market,land,true)
 local function fixture(class:string?):any
  class=class or "Warrior"
  local r=schema.new(1,1000);local d=r.data
  d.progression.ruleset=C.ProgressionRulesets.Novice;d.personalGuild.buildings.guildHall=4
  d.character.classId="Warrior";d.character.level=35;d.character.xp=1700;d.character.classPathId="warrior:1";d.character.skillId="power_strike"
  d.adventurers["h:1"]={id="h:1",name="Hero",classId=class,rank="F",level=35,xp=1700,baseStats=U.copy(C.Adventurers[class].Stats),equipmentSlots={}}
  d.progression.recruitedClasses={[class]=true};d.settlement.nextHero=2;d.party.adventurerIds={"h:1"};d.quests.firstClears.quarry_patrol=true
  return r
 end
 local function combat(r:any,path:string,emit:any?):(any,any)
  local run=assert(T.start(r.data,1,"h:1",path,"trial-a",0))
  local s=stats.hero(run.hero.classId,35,nil,nil,nil,G.extras(r.data,run.hero))
  return run,T.combat(run,{stats=s,Stats=stats,config=config,Targeting=require("../src/server/Systems/CombatTargeting"),Damage=require("../src/server/Systems/CombatDamage"),Abilities=require("../src/server/Systems/CombatAbilities"),emit=emit})
 end
 test("mentor presentation follows saved proof and current party dispatch eligibility",function()
  local r=fixture();local d=r.data;local before=U.copy(r)
  eq(T.presentation(d)["h:1"].berserker,{ready=false,advanceProblem="HeroMentorRequired"})
  eq(r,before)
  d.expansion.actors["h:1"]={tier=1,skills={},mentorProof={version=1,pathId="berserker",trialId="private-trial"}}
  local view=T.presentation(d);eq(view["h:1"].berserker,{ready=true});eq(view["h:1"].duelist.ready,false)
  d.party.adventurerIds={};view=T.presentation(d)
  eq(view["h:1"].berserker.ready,true);eq(view["h:1"].berserker.advanceProblem,"PartyRequired")
  d.party.adventurerIds={"h:1"};d.settlement.jobs.job={members={"h:1"}}
  eq(T.presentation(d)["h:1"].berserker.advanceProblem,"HeroUnavailable")
  d.settlement.jobs={};eq(T.presentation(d)["h:1"].berserker.advanceProblem,nil)
  d.progression.ruleset=C.ProgressionRulesets.Legacy
  eq(T.presentation(d),{})
 end)
 test("mentor ephemeral projection exposes only actor path phase and no receipt authority",function()
  eq(T.sessionView(nil),nil)
  local e={run={actorId="h:1",pathId="berserker",id="secret",owner=42},token="secret",epoch=9}
  eq(T.sessionView(e),{actorId="h:1",pathId="berserker",status="Active"})
  e.delivery=function()return "Pending"end
  local saving:any=assert(T.sessionView(e));eq(saving,{actorId="h:1",pathId="berserker",status="Saving"})
  saving.actorId="spoof";eq(e.run.actorId,"h:1");eq(T.sessionView(nil),nil)
 end)
 test("mentor eligibility and lifecycle messages have friendly English and Thai text",function()
  local L=require("../src/shared/Config/Localization")
  for _,code in ipairs({"PartyRequired","AdvancementLocked","InvalidClassPath","FinishExpedition","HeroUnavailable","ClassTrialLocked","HeroMentorUnavailable","HeroMentorRequired","HeroMentorActive","HeroMentorStarted","HeroMentorSaving","HeroMentorComplete","HeroMentorCancelled","HeroMentorFailed","HeroChanged","HeroMentorCleanupFailed","InvalidTrial","ReturnToGuild","ProfileNotReady","ActorNotReady","SavePending"})do
   for _,language in ipairs({"en","th"})do local value=L.translate(language,code);assert(value~=code,language.." missing "..code)end
  end
 end)
 test("hero mentor all ten paths require real effects and solo victory",function()
  local count=0
  for path,def in pairs(E.Paths)do if def.Tier~=2 then continue end
   local r=fixture(def.Class);local before=U.copy(r);local run,sim=combat(r,path)
   for tick=0,1790 do if sim.step(tick/10,{x=0,y=0,z=4})~="Active"then break end end
   eq(run.status,"Won");local snap=sim.snapshot();eq(snap.used,true);eq(snap.effect,true);assert(snap.hits>=3)
   local proof=T.receipt(run);eq(proof.args.actorId,"h:1");eq(proof.args.pathId,path);eq(r,before);count+=1
  end
  eq(count,10)
 end)
 test("hero trial rejects ownership path level condition job and first-clear bypass",function()
  local r=fixture();local d=r.data
  eq(T.problem(d,"player","berserker"),"HeroUnavailable");eq(T.problem(d,"h:2","berserker"),"HeroUnavailable")
  eq(T.problem(d,"h:1","cleric"),"InvalidClassPath")
  d.adventurers["h:1"].level=34;eq(T.problem(d,"h:1","berserker"),"ClassTrialLocked");d.adventurers["h:1"].level=35
  for _,condition in ipairs({"Dead","Injured"})do d.adventurers["h:1"].condition=condition;eq(T.problem(d,"h:1","berserker"),"HeroUnavailable")end
  d.adventurers["h:1"].condition=nil;d.settlement.jobs.job={members={"h:1"}};eq(T.problem(d,"h:1","berserker"),"HeroUnavailable");d.settlement.jobs={}
  d.quests.firstClears={};eq(T.problem(d,"h:1","berserker"),"AdvancementLocked")
 end)
 test("hero trial timeout bounds and unfinished runs never issue receipts",function()
  local r=fixture();local run,sim=combat(r,"berserker")
  eq(T.receipt(run),nil);eq(sim.step(180,{x=0,y=0,z=4}),"Failed");eq(T.receipt(run),nil)
  run,sim=combat(r,"berserker");eq(sim.step(0,{x=0/0,y=0,z=4}),"Failed")
 end)
 test("hero high attack builds and lethal cast event order remain finishable",function()
  for path,def in pairs(E.Paths)do if def.Tier~=2 then continue end
   local r=fixture(def.Class);local run=assert(T.start(r.data,1,"h:1",path,"strong",0))
   local s=stats.hero(def.Class,100,nil,nil,nil,G.extras(r.data,r.data.adventurers["h:1"]));s.Attack=10000;s.MaxHealth=10000
   local sim=T.combat(run,{stats=s,Stats=stats,config=config,Targeting=require("../src/server/Systems/CombatTargeting"),Damage=require("../src/server/Systems/CombatDamage"),Abilities=require("../src/server/Systems/CombatAbilities")})
   for tick=0,1790 do if sim.step(tick/10,{x=0,y=0,z=4})~="Active"then break end end
   eq(run.status,"Won")
  end
 end)
 test("healer needs actual restoration and guardian needs a guarded received hit",function()
  local r=fixture("Priest");local run,sim=combat(r,"cleric");sim.patient.health=100
  sim.step(0,{x=0,y=0,z=4});eq(sim.snapshot().used,false);eq(sim.snapshot().effect,false);eq(T.receipt(run),nil)
  sim.patient.health=20;sim.step(1,{x=0,y=0,z=4});eq(sim.snapshot().effect,true)
  r=fixture("Knight");run,sim=combat(r,"guardian");sim.step(0,{x=0,y=0,z=4});eq(sim.snapshot().used,true);eq(sim.snapshot().effect,false)
  sim.step(2,{x=0,y=0,z=4});eq(sim.snapshot().effect,true);assert(sim.actor.health<sim.actor.stats.MaxHealth)
 end)
 test("first lethal art counts cast event emitted after enemy defeat",function()
  local r=fixture();local run,sim=combat(r,"berserker")
  for _,t in ipairs({0,2,5,8})do sim.step(t,{x=0,y=0,z=39})end
  eq(sim.snapshot().used,false);eq(sim.snapshot().hits,3)
  sim.enemy.health=1;eq(sim.step(9,{x=0,y=0,z=4}),"Won");eq(sim.snapshot().used,true);assert(T.receipt(run))
 end)
 test("mentor choice can be retrained but another hero or path cannot spend proof",function()
  local r=fixture();local run,sim=combat(r,"berserker");for t=0,179 do sim.step(t,{x=0,y=0,z=4})end
  local copy=assert(T.commit(r,T.receipt(run)))
  local policy=require("../src/server/Systems/ReleasePolicy")(require("../src/server/Config/ReleaseContent")).resolve({LaunchCandidate=true,StudioPersistence="Memory"},{isStudio=true,placeId=0,gameId=0})
  eq(policy.problem(copy.data,"AdvanceClass",{actorId="h:1",pathId="berserker"}),nil)
  eq(policy.problem(copy.data,"AdvanceClass",{actorId="h:1",pathId="duelist"}),"HeroMentorRequired")
  eq(policy.problem(copy.data,"AdvanceClass",{actorId="h:2",pathId="berserker"}),"HeroMentorRequired")
  run,sim=combat(copy,"duelist");for t=0,179 do sim.step(t,{x=0,y=0,z=4})end
  local newer,result=T.commit(copy,T.receipt(run));eq(result.code,"OK");eq(newer.data.expansion.actors["h:1"].mentorProof.pathId,"duelist")
 end)
 test("hero proof commits only matching hero snapshot and path without touching player",function()
  local r=fixture();local run,sim=combat(r,"berserker")
  for t=0,179 do sim.step(t,{x=0,y=0,z=4})end
  local receipt=T.receipt(run);assert(receipt);local before=U.copy(r)
  local copy,result=T.commit(r,receipt);eq(result.code,"OK");eq(r,before);eq(copy.data.character,r.data.character)
  eq(copy.data.expansion.actors["h:1"].mentorProof.pathId,"berserker")
  r.data.adventurers["h:1"].xp+=1;eq(select(2,T.commit(r,receipt)).code,"HeroChanged")
  r=fixture();r.data.quests.firstClears={};eq(select(2,T.commit(r,receipt)).code,"AdvancementLocked")
  r=fixture();r.data.adventurers["h:1"].condition="Dead";eq(select(2,T.commit(r,receipt)).code,"HeroUnavailable")
 end)
 test("optional mentor proof validates with flags off and preserves legacy earned builds",function()
  local r=fixture();assert(schema.validate(r,1));r.data.expansion.actors["h:1"]={tier=2,path="berserker",skills={}}
  assert(schema.validate(r,1));local b=r.data.expansion.actors["h:1"]
  b.mentorProof={version=1,pathId="berserker",trialId="abc"};assert(schema.validate(r,1))
  for _,proof in ipairs({{version=2,pathId="berserker",trialId="abc"},{version=1,pathId="cleric",trialId="abc"},{version=1,pathId="berserker",trialId=""},{version=1,pathId="berserker",trialId="abc",granted=true}})do b.mentorProof=proof;eq(schema.validate(r,1),false)end
 end)
 test("mentor integration preserves already earned hero promotion to Class3",function()
  local r=fixture();local d=r.data;local hero=d.adventurers["h:1"]
  hero.level=70;hero.xp=3450;d.personalGuild.buildings.guildHall=11;d.expansion.tower.highest=5
  d.expansion.actors["h:1"]={tier=2,path="berserker",skills={}}
  local service=require("../src/server/Services/ExpansionService")(C,U,require("../src/server/Services/EconomyService")(C,U),E,nil,nil,T)
  eq(service.apply(d,"AdvanceClass",{actorId="h:1",pathId="warlord"},1000,function()end),nil)
  eq(d.expansion.actors["h:1"].tier,3)
 end)
 test("public protocol accepts only start cancel and rejects private mentor receipt",function()
  local P=require("../src/shared/Network/Protocol")
  local p={version=1,requestId="start",revision=1,action="StartHeroMentor",args={actorId="h:1",pathId="berserker"}}
  eq(P.validate(p),true);p.action="HeroMentorProof";eq(P.validate(p),false)
  p.action="StartHeroMentor";p.args.damage=600;eq(P.validate(p),false)
 end)
 test("hero receipt adapter fences start session and freezes uncertain command",function()
  local adapter=require("../src/server/Services/HeroMentorReceiptAdapter")
  local r=fixture();local run,sim=combat(r,"berserker");for t=0,179 do sim.step(t,{x=0,y=0,z=4})end
  local commands={};local data:any={Sessions={[1]={epoch=1,token="a",state="Active",record={revision=5}}},CommitHeroMentor=function(_id:any,c:any)table.insert(commands,U.copy(c));return if #commands==1 then "SavePending" else "AlreadyCommitted"end}
  local deliver=adapter(data,1,T.receipt(run),U,1,"a");eq(deliver(),"Retry");data.Sessions[1].record.revision=6;eq(deliver(),"Committed");eq(commands[1],commands[2])
  deliver=adapter(data,1,T.receipt(run),U,1,"a");data.Sessions[1].token="b";eq(deliver(),"Rejected");eq(#commands,2)
 end)
 if harness then
  test("hero proof transaction recovers uncertain saves and replay once",function()
   for _,mode in ipairs({"before","after"})do
    local h=harness(schema,nil,nil,nil,nil,T);eq(h.service.Load(1,"hero-session"),"OK")
    local session=h.service.Sessions[1];local r=fixture();session.record.data=r.data;h.records["p:1"]=U.copy(session.record)
    local run,sim=combat(r,"berserker");for t=0,179 do sim.step(t,{x=0,y=0,z=4})end
    local deliver=require("../src/server/Services/HeroMentorReceiptAdapter")(h.service,1,T.receipt(run),U,session.epoch,session.token)
    h.mode=mode;h.replayCallback=true;eq(deliver(),"Retry");h.mode="ok";eq(h.service.Refresh(1),"OK");eq(deliver(),"Committed")
    eq(h.data().expansion.actors["h:1"].mentorProof.trialId,"trial-a");local rev=session.record.revision;eq(deliver(),"Committed");eq(session.record.revision,rev)
    eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"rejoin"),"OK");eq(h.data().expansion.actors["h:1"].mentorProof.pathId,"berserker")
   end
  end)
 end
end
