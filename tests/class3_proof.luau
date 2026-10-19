--!strict
return function(test:any,eq:any)
 local U=require("../src/shared/Util/TableUtil")
 local C=require("../src/server/Config/Content")
 local E=require("../src/shared/Data/Expansion")
 local make=require("../src/server/Systems/Class3Proof")
 local T=make(E,U)
 local validate=require("../src/server/Systems/ExpansionSchema")(C,U,E)
 local economy=require("../src/server/Services/EconomyService")(C,U)
 local service=require("../src/server/Services/ExpansionService")
 local catalog=require("../src/server/Config/CampaignSequence")({require("../src/server/Config/ChapterOne"),require("../src/server/Config/ChapterTwo"),require("../src/server/Config/ChapterThree"),require("../src/server/Config/ChapterFour"),require("../src/server/Config/ChapterFive")})
 local campaign=require("../src/server/Services/CampaignService")(C,U,economy,catalog)
 local combined=make(E,U,campaign)
 local specialParents={commander="berserker",rune_knight="guardian",bard="cleric",shadow_dancer="ranger"}
 local function fixture(pathId:string?,actorId:string?):any
  pathId=pathId or "warlord";actorId=actorId or "player"
  local path=E.Paths[pathId];local parent=path.Parent or specialParents[pathId]
  local character={classId=path.Class,level=70,xp=3450,raceId="Human",tier=2,classPathId=parent,skillId=C.Character.Classes[path.Class].SkillId,statusAllocations={VIT=3},equipmentSlots={}}
  local d:any={profile={userId=1},character=character,adventurers={},currencies={gold=123},inventory={stacks={timber=2}},
   progression={ruleset=C.ProgressionRulesets.Novice,novice={claimed=6},campaign={version=1,claimed=24,objectives={meet_crosshaven_mentor=true},choices={}}},
   personalGuild={buildings={guildHall=11}},quests={firstClears={quarry_patrol=true}},party={adventurerIds={}},settlement={jobs={},nextHero=1},expansion=E.new()}
  local e=d.expansion;e.actors.player={tier=2,path=parent,skills={vitality=true}};e.tower.highest=path.Floor;e.tower.checkpoint=5
  e.buildings["b:1"]={kind="quarters",x=6,z=-4,rotation=0};e.nextBuilding=2
  e.gathered={wood=true,stone=true,ore=true,herbs=true}
  if actorId~="player" then
   d.adventurers[actorId]={id=actorId,name="Hero",classId=path.Class,rank="F",level=70,xp=3450,baseStats=U.copy(C.Adventurers[path.Class].Stats),equipmentSlots={},statusAllocations={VIT=3}}
   d.party.adventurerIds={actorId};d.settlement.nextHero=2;d.progression.recruitedClasses={[path.Class]=true}
   e.actors[actorId]=U.copy(e.actors.player)
  end
  return {data=d,revision=3}
 end
 local function receipt(r:any,actorId:string?,pathId:string?,trialId:string?,source:string?):any
  local run=assert(T.capture(r.data,actorId or "player",pathId or "warlord",trialId or "trial:1",source or "actor_mastery",if source=="crosshaven_mastery" then "complete_borrowed_mastery" else nil))
  run.status="Won";return assert(T.receipt(run))
 end
 test("Class3 all fourteen paths qualify each actor at own70 and preserve exact existing gates",function()
  local count=0
  for pathId,path in pairs(E.Paths)do if path.Tier==3 then
   count+=1
   for _,actorId in ipairs({"player","h:1"})do
    local r=fixture(pathId,actorId);local d=r.data;local before=U.copy(r);local actor=E.actor(d,actorId)
    validate(d);eq(T.problem(d,actorId,pathId),nil);eq(r,before)
    actor.level=69;eq(T.problem(d,actorId,pathId),"AdvancementLocked");actor.level=70
    d.quests.firstClears.quarry_patrol=nil;eq(T.problem(d,actorId,pathId),"AdvancementLocked");d.quests.firstClears.quarry_patrol=true
    d.expansion.tower.highest=path.Floor-1;eq(T.problem(d,actorId,pathId),"AdvancementLocked");d.expansion.tower.highest=path.Floor
    if path.Prestige then local buildings=d.expansion.buildings;d.expansion.buildings={};eq(T.problem(d,actorId,pathId),"QuartersRequired");d.expansion.buildings=buildings end
    if path.Secret then d.expansion.gathered.ore=nil;eq(T.problem(d,actorId,pathId),"SecretUndiscovered");d.expansion.gathered.ore=true end
    local saved=E.build(d,actorId).path;E.build(d,actorId).path="unknown";eq(T.problem(d,actorId,pathId),"InvalidClassPath");E.build(d,actorId).path=saved
    actor.classId="Mage";if path.Class=="Mage" then actor.classId="Knight"end;eq(T.problem(d,actorId,pathId),"InvalidClassPath");actor.classId=path.Class
    local c,result=T.apply(r,receipt(r,actorId,pathId));eq(result.code,"OK");eq(T.hasProof(c.data,actorId,pathId),true);eq(r,before);validate(c.data)
   end
  end end
  eq(count,14)
 end)
 test("Class3 normal parent and direct jump stay forbidden and owner level never substitutes",function()
  local r=fixture(nil,"h:1");local d=r.data
  d.character.level=100;d.adventurers["h:1"].level=69;eq(T.problem(d,"h:1","warlord"),"AdvancementLocked")
  d.adventurers["h:1"].level=70;d.expansion.actors["h:1"].path="duelist";eq(T.problem(d,"h:1","warlord"),"InvalidClassPath")
  d.expansion.actors["h:1"].tier=1;eq(T.problem(d,"h:1","warlord"),"InvalidClassPath")
  eq(T.problem(d,"h:2","warlord"),"ActorNotReady");eq(T.problem(d,{},"warlord"),"ActorNotReady");eq(T.problem(d,"player",{}),"InvalidClassPath")
 end)
 test("Class3 owned instance proofs never transfer between same-class heroes or player",function()
  local r=fixture(nil,"h:1");local d=r.data
  d.adventurers["h:2"]=U.copy(d.adventurers["h:1"]);d.adventurers["h:2"].id="h:2";d.expansion.actors["h:2"]=U.copy(d.expansion.actors["h:1"])
  local command=receipt(r,"h:1");local c=assert(T.apply(r,command))
  eq(T.hasProof(c.data,"h:1","warlord"),true);eq(T.hasProof(c.data,"h:2","warlord"),false);eq(T.hasProof(c.data,"player","warlord"),false)
  c.data.expansion.actors["h:2"].class3Proof=U.copy(c.data.expansion.actors["h:1"].class3Proof)
  eq(T.hasProof(c.data,"h:2","warlord"),false);eq(pcall(validate,c.data),false)
  d.adventurers["h:1"]=nil;eq(select(2,T.apply(r,command)).code,"ActorNotReady")
 end)
 test("Class3 captures and receipts are copies and non-won trials never issue proof",function()
  local r=fixture();local run=assert(T.capture(r.data,"player","warlord","trial:1","actor_mastery"));local before=U.copy(r)
  eq(T.receipt(run),nil);run.status="Failed";eq(T.receipt(run),nil);run.status="Won"
  local command=assert(T.receipt(run));command.args.expectedActor.level=1;eq(run.expectedActor.level,70);eq(r,before)
  r.data.character.level=71;eq(run.expectedActor.level,70)
  local c=assert(T.receipt(run));eq(select(2,T.apply(r,c)).code,"Class3ActorChanged")
 end)
 test("Class3 private envelope rejects forged owner request unknown args and mode combinations",function()
  local r=fixture();local original=receipt(r);local before=U.copy(r)
  for _,mutate in ipairs({
   function(c:any)c.owner=2 end,function(c:any)c.requestId="class3:other"end,function(c:any)c.action="CampaignObjective"end,
   function(c:any)c.args.success=true end,function(c:any)c.args.trialId=string.rep("a",49)end,function(c:any)c.args.trialId="bad space"end,
   function(c:any)c.args.expectedActor=nil end,function(c:any)c.args.sourceKind="other"end,
   function(c:any)c.args.storyObjective="complete_borrowed_mastery"end,
   function(c:any)c.args.sourceKind="crosshaven_mastery"end,
  })do local c=U.copy(original);mutate(c);local candidate,result,events=T.apply(r,c);eq(candidate,nil);eq(result.code,"InvalidReceipt");eq(events,{})end
  eq(r,before)
  eq(select(2,T.capture(r.data,"player","warlord","x","actor_mastery","other")),"InvalidReceipt")
  r=fixture(nil,"h:1");eq(select(2,T.capture(r.data,"h:1","warlord","x","crosshaven_mastery","complete_borrowed_mastery")),"InvalidReceipt")
 end)
 test("Class3 proof schema rejects malformed fields without changing old mentor proof",function()
  local r=fixture(nil,"h:1");local c=assert(T.apply(r,receipt(r,"h:1")));local b=c.data.expansion.actors["h:1"];local valid=U.copy(b.class3Proof)
  b.mentorProof={version=1,pathId="berserker",trialId="old"};validate(c.data)
  for _,mutate in ipairs({function(p:any)p.version=2 end,function(p:any)p.actorId="player"end,function(p:any)p.pathId="berserker"end,
   function(p:any)p.pathId="archmage"end,function(p:any)p.trialId=""end,function(p:any)p.trialId=string.rep("x",49)end,
   function(p:any)p.trialId="a.b"end,function(p:any)p.sourceKind="crosshaven_mastery"end,function(p:any)p.success=true end,
   function(p:any)p.sourceKind=nil end})do
   b.class3Proof=U.copy(valid);mutate(b.class3Proof);eq(pcall(validate,c.data),false);eq(T.hasProof(c.data,"h:1","warlord"),false)
  end
  b.class3Proof=valid;b.class3Proof.trialId=string.rep("a",48);validate(c.data)
  eq(b.mentorProof,{version=1,pathId="berserker",trialId="old"})
 end)
 test("Class3 durable proof survives promotion XP growth and cleared story without snapshot gating",function()
  local r=fixture();local c=assert(combined.apply(r,receipt(r,nil,nil,nil,"crosshaven_mastery")))
  c.data.progression.campaign.claimed=25;c.data.progression.campaign.objectives={}
  c.data.character.xp+=50;c.data.character.level=71
  local s=service(C,U,economy,E,nil,nil,nil,T)
  eq(s.apply(c.data,"AdvanceClass",{actorId="player",pathId="warlord"},0,function()end),nil)
  eq(T.hasProof(c.data,"player","warlord"),true);validate(c.data)
  local rejoined=U.copy(c);eq(T.hasProof(rejoined.data,"player","warlord"),true)
  eq(rejoined.data.character.statusAllocations,nil);eq(rejoined.data.expansion.actors.player.skills,{})
 end)
 test("Class3 absent policy and legacy promotion remain compatible while opted-in promotion requires proof",function()
  for _,actorId in ipairs({"player","h:1"})do
   local r=fixture(nil,actorId);local before=U.copy(r)
   local s=service(C,U,economy,E,nil,nil,nil,T)
   eq(s.apply(r.data,"AdvanceClass",{actorId=actorId,pathId="warlord"},0,function()end),"Class3ProofRequired");eq(r,before)
   r.data.progression.campaign.objectives.complete_borrowed_mastery=true
   if actorId~="player" then r.data.expansion.actors[actorId].mentorProof={version=1,pathId="berserker",trialId="old"}end
   eq(s.apply(r.data,"AdvanceClass",{actorId=actorId,pathId="warlord"},0,function()end),"Class3ProofRequired")
   local old=service(C,U,economy,E);eq(old.apply(r.data,"AdvanceClass",{actorId=actorId,pathId="warlord"},0,function()end),nil);validate(r.data)
   r=fixture(nil,actorId);r.data.progression.ruleset=C.ProgressionRulesets.Legacy
   eq(s.apply(r.data,"AdvanceClass",{actorId=actorId,pathId="warlord"},0,function()end),nil);validate(r.data)
   r.data.character.level=6;E.actor(r.data,actorId).level=6;validate(r.data)
  end
 end)
 test("Class3 optional policy never runs for Class2 and earned Novice Tier3 needs no backfill",function()
  local r=fixture();local d=r.data
  d.character.level=35;d.character.tier=1;d.character.classPathId="warrior:1";d.expansion.actors.player={tier=1,skills={}}
  local policy={advanceProblem=function():string? error("Class3 policy called for Class2")end}
  local s=service(C,U,economy,E,nil,nil,nil,policy)
  eq(s.apply(d,"AdvanceClass",{actorId="player",pathId="berserker"},0,function()end),nil)
  d.character.level=6;d.character.tier=3;d.character.classPathId="warlord";d.expansion.actors.player={tier=3,path="warlord",skills={}}
  validate(d);eq(d.expansion.actors.player.class3Proof,nil)
 end)
 test("Class3 optional proof round-trips through the full profile schema with flags off",function()
  local gear=require("../src/shared/Data/Equipment")(C,E,require("../src/shared/Data/StatusPoints"))
  local marketConfig=require("../src/server/Config/Market")
  local market=require("../src/server/Systems/MarketEscrow")(marketConfig,U,C,require("../src/server/Systems/MarketOrders")(marketConfig,U))
  local land=require("../src/shared/Data/GuildLand")(require("../src/server/Config/GuildLand"))
  local schema=require("../src/server/Systems/ProfileSchema")(C,U,gear,E,validate,market,land,true)
  local r=schema.new(1,1000);local d=r.data
  d.progression.ruleset=C.ProgressionRulesets.Novice;d.personalGuild.buildings.guildHall=11
  d.character.classId="Warrior";d.character.level=70;d.character.xp=3450;d.character.tier=2;d.character.classPathId="berserker";d.character.skillId="power_strike"
  d.expansion.actors.player={tier=2,path="berserker",skills={}};d.expansion.tower.highest=5;d.expansion.tower.checkpoint=5;d.quests.firstClears.quarry_patrol=true
  eq(schema.validate(r,1),true);local c=assert(T.apply(r,receipt(r)));eq(schema.validate(c,1),true)
  local rejoined=U.copy(c);eq(schema.validate(rejoined,1),true);eq(T.hasProof(rejoined.data,"player","warlord"),true)
  rejoined.data.expansion.actors.player.class3Proof.actorId="h:1";eq(schema.validate(rejoined,1),false)
 end)
 test("Class3 proof consumption only resets chosen actor once and grants no budgets or rewards",function()
  local r=fixture(nil,"h:1");local before=U.copy(r);local c=assert(T.apply(r,receipt(r,"h:1")))
  local expected=U.copy(before);expected.data.expansion.actors["h:1"].class3Proof=U.copy(c.data.expansion.actors["h:1"].class3Proof);eq(c,expected)
  local s=service(C,U,economy,E,nil,nil,nil,T)
  eq(s.apply(c.data,"AdvanceClass",{actorId="h:1",pathId="warlord"},0,function()end),nil)
  eq(c.data.character,before.data.character);eq(c.data.adventurers["h:1"].statusAllocations,nil);eq(c.data.currencies,before.data.currencies)
  c.data.adventurers["h:1"].statusAllocations={VIT=5};local after=U.copy(c)
  eq(s.apply(c.data,"AdvanceClass",{actorId="h:1",pathId="warlord"},0,function()end),"InvalidClassPath");eq(c,after)
 end)
 test("Class3 same-trial refusal never guesses exact acknowledgement and stale receipts cannot replace newer proof",function()
  local r=fixture();local first=receipt(r);local c=assert(T.apply(r,first));local before=U.copy(c)
  eq(select(2,T.apply(c,first)).code,"Class3AlreadyProven");eq(c,before)
  local conflict=U.copy(first);conflict.args.pathId="commander";eq(select(2,T.apply(c,conflict)).code,"RequestConflict")
  local second=receipt(c,nil,"commander","trial:2");local newer=assert(T.apply(c,second));eq(T.hasProof(newer.data,"player","commander"),true)
  local oldFresh=receipt(r,nil,nil,"trial:3");eq(select(2,T.apply(newer,oldFresh)).code,"Class3ActorChanged")
  eq(select(2,T.apply(newer,first)).code,"Class3ActorChanged");eq(newer.data.expansion.actors.player.class3Proof.pathId,"commander")
 end)
 test("Class3 combined candidate uses actual campaign validation atomically and proof-only repeats do not replay story",function()
  local r=fixture();local command=receipt(r,nil,nil,nil,"crosshaven_mastery");local before=U.copy(r)
  local c,result,events=combined.apply(r,command);eq(result.code,"OK");eq(#events,2);eq(r,before)
  eq(c.data.progression.campaign.objectives.complete_borrowed_mastery,true);eq(T.hasProof(c.data,"player","warlord"),true)
  local expected=U.copy(before);expected.data.progression.campaign.objectives.complete_borrowed_mastery=true;expected.data.expansion.actors.player.class3Proof=U.copy(c.data.expansion.actors.player.class3Proof);eq(c,expected)
  eq(select(2,T.apply(r,command)).code,"Class3CampaignUnavailable")
  r.data.progression.campaign.objectives.meet_crosshaven_mentor=nil;before=U.copy(r)
  local failed,reason,noEvents=combined.apply(r,command);eq(failed,nil);eq(reason.code,"PreviousObjectiveRequired");eq(noEvents,{});eq(r,before)
  r=fixture();r.data.progression.campaign.objectives.complete_borrowed_mastery=true
  eq(select(2,combined.apply(r,command)).code,"AlreadyObserved");eq(r.data.expansion.actors.player.class3Proof,nil)
  c.data.progression.campaign.claimed=25;c.data.progression.campaign.objectives={};before=U.copy(c)
  local repeatCandidate=assert(combined.apply(c,receipt(c,nil,"commander","trial:repeat")))
  eq(repeatCandidate.data.progression,before.data.progression);eq(repeatCandidate.data.character,before.data.character);eq(repeatCandidate.data.currencies,before.data.currencies)
 end)
 test("Class3 changed current prerequisites and builds reject delivery without partial campaign changes",function()
  local r=fixture();local command=receipt(r,nil,nil,nil,"crosshaven_mastery")
  r.data.expansion.tower.highest=4;local before=U.copy(r)
  eq(select(2,combined.apply(r,command)).code,"AdvancementLocked");eq(r,before)
  r=fixture();r.data.expansion.actors.player.skills.path_art=true;before=U.copy(r)
  eq(select(2,combined.apply(r,command)).code,"Class3ActorChanged");eq(r,before)
  r=fixture();r.data.progression.ruleset=C.ProgressionRulesets.Legacy
  eq(select(2,T.capture(r.data,"player","warlord","x","actor_mastery")),"Class3TrialUnavailable")
  eq(select(2,combined.apply(r,command)).code,"Class3TrialUnavailable")
 end)
end
