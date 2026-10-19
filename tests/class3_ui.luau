--!strict
return function(test:any,eq:any,gui:any?)
 local U=require("../src/shared/Util/TableUtil")
 local C=require("../src/server/Config/Content")
 local E=require("../src/shared/Data/Expansion")
 local P=require("../src/server/Systems/Class3Proof")(E,U)
 local H=require("../src/server/Systems/HeroMentorTrial")(E,U,P)
 local L=require("../src/shared/Config/Localization")
 local gear=require("../src/shared/Data/Equipment")(C,E,require("../src/shared/Data/StatusPoints"))
 local schema=require("../src/server/Systems/ProfileSchema")(C,U,gear,E,require("../src/server/Systems/ExpansionSchema")(C,U,E))
 local makeView=require("../src/server/Systems/ViewProjection")
 local function fixture():any
  local r=schema.new(1,1000);local d=r.data
  d.progression.ruleset=C.ProgressionRulesets.Novice;d.personalGuild.buildings.guildHall=11
  d.character.classId="Warrior";d.character.level=70;d.character.xp=3450;d.character.classPathId="berserker";d.character.skillId="power_strike"
  d.expansion.actors.player={tier=2,path="berserker",skills={}}
  for _,id in ipairs({"h:1","h:2"})do
   d.adventurers[id]={id=id,name="Hero "..id,classId="Warrior",rank="F",level=70,xp=3450,baseStats=U.copy(C.Adventurers.Warrior.Stats),equipmentSlots={}}
   d.expansion.actors[id]={tier=2,path="berserker",skills={}}
  end
  d.party.adventurerIds={"h:1","h:2"};d.quests.firstClears.quarry_patrol=true
  d.expansion.tower.highest=10;d.expansion.buildings.q={kind="quarters",x=6,z=-4,rotation=0}
  d.expansion.gathered={wood=true,stone=true,ore=true,herbs=true}
  return r
 end
 local function saved(actorId:string,pathId:string):any return {version=1,actorId=actorId,pathId=pathId,trialId="private:trial",sourceKind="actor_mastery"}end
 local function project(r:any,bundle:any?,release:any?):any
  return makeView(C,{stats=function()return {}end},U,E,nil,nil,nil,nil,nil,nil,release,bundle)({state="Ready",record=r},"Memory",10)
 end
 local bundle={Proof=P,Trial=H}
 test("Class3 projection redacts private proofs without policy and never mutates source",function()
  local r=fixture();for id,b in pairs(r.data.expansion.actors)do b.class3Proof=saved(id,"warlord");b.mentorProof={version=1,pathId="berserker",trialId="private:mentor"}end
  local before=U.copy(r);local v=project(r)
  eq(v.data.class3Proofs,nil)
  for _,b in pairs(v.data.expansion.actors)do eq(b.class3Proof,nil);eq(b.mentorProof,nil)end
  eq(r,before)
 end)
 test("Class3 projection keeps exact owned actor and selected path proof separate",function()
  local r=fixture();r.data.expansion.actors["h:1"].class3Proof=saved("h:1","warlord")
  r.data.expansion.actors["not-owned"]={tier=2,path="berserker",skills={},class3Proof=saved("not-owned","warlord")}
  local before=U.copy(r);local v=project(r,bundle).data.class3Proofs
  eq(v["h:1"].warlord,{proven=true});eq(v["h:2"].warlord,{proven=false,advanceProblem="Class3ProofRequired"})
  eq(v.player.warlord.proven,false);eq(v["h:1"].commander.proven,false);eq(v["not-owned"],nil);eq(v.player.sword_saint,nil)
  eq(r,before)
 end)
 test("Class3 projection delegates own level activity and route qualification independently",function()
  local r=fixture();r.data.character.level=100;r.data.adventurers["h:1"].level=69
  local custom={Proof=P,Trial=H,PlayerProblem=function()return "ReturnToCrosshaven"end}
  local v=project(r,custom).data.class3Proofs
  eq(v["h:1"].warlord.trialProblem,"AdvancementLocked");eq(v.player.warlord.trialProblem,"ReturnToCrosshaven")
  eq(v.player.warlord.advanceProblem,"Class3ProofRequired")
  r.data.adventurers["h:1"].level=70;r.data.party.adventurerIds={"h:2"}
  v=project(r,custom).data.class3Proofs;eq(v["h:1"].warlord.trialProblem,"PartyRequired")
  eq(v["h:1"].warlord.advanceProblem,"Class3ProofRequired")
 end)
 test("Class3 projection callback cannot bypass domain and malformed callback fails closed",function()
  local r=fixture();local calls=0
  local custom={Proof=P,PlayerProblem=function()calls+=1;return {token="never-project"}end}
  r.data.character.level=69;local v=project(r,custom).data.class3Proofs
  eq(v.player.warlord.trialProblem,"AdvancementLocked");eq(calls,0)
  r.data.character.level=70;v=project(r,custom).data.class3Proofs
  eq(v.player.warlord.trialProblem,"Class3TrialUnavailable")
 end)
 test("Class3 projection preserves legacy earned Tier3 and normal parent restrictions",function()
  local r=fixture();r.data.progression.ruleset=C.ProgressionRulesets.Legacy
  eq(project(r,bundle).data.class3Proofs,nil)
  r.data.progression.ruleset=C.ProgressionRulesets.Novice;r.data.expansion.actors.player={tier=3,path="warlord",skills={}}
  local v=project(r,bundle);eq(v.data.class3Proofs.player,nil);eq(v.data.expansion.actors.player.tier,3)
  r.data.expansion.actors["h:1"].path="duelist";v=project(r,bundle)
  eq(v.data.class3Proofs["h:1"].warlord,nil);eq(v.data.class3Proofs["h:1"].sword_saint.proven,false)
 end)
 test("Class3 projection supports all fourteen exact paths without widening prerequisites",function()
  local count=0;local parents={commander="berserker",rune_knight="guardian",bard="cleric",shadow_dancer="ranger"}
  for id,path in pairs(E.Paths)do if path.Tier==3 then
   local r=fixture();r.data.character.classId=path.Class;r.data.expansion.actors.player.path=path.Parent or parents[id]
   local v=project(r,bundle).data.class3Proofs.player;eq(v[id],{proven=false,advanceProblem="Class3ProofRequired"});count+=1
  end end;eq(count,14)
 end)
 test("Class3 projection release restriction outranks saved proof and route readiness",function()
  local r=fixture();r.data.expansion.actors.player.class3Proof=saved("player","warlord")
  local release={Release={Enabled=true,Id="test",MaxLevel=35,MaxHall=4,problem=function()return "ReleaseContentUnavailable"end}}
  local v=project(r,bundle,release).data.class3Proofs.player.warlord
  eq(v,{proven=true,trialProblem="ReleaseContentUnavailable",advanceProblem="ReleaseContentUnavailable"})
 end)
 if gui then gui(test,eq,{fixture=fixture,project=project,bundle=bundle,Rules=E,Localization=L,
  Copy=require("../src/shared/Config/ClassAdvancementCopy"),
  Points=require("../src/shared/Data/StatusPoints")})end
end
