--!strict
return function(test:any,eq:any,harness:any,deps:any)
 local content,util=deps.Content,deps.Util
 local rules=deps.Expansion;local legacy=deps.Schema
 local schema=require("../src/server/Systems/ProfileSchema")(content,util,deps.Gear,rules,deps.ValidateExpansion,deps.MarketEscrow,deps.GuildLand,true)
 local modes=content.ProgressionRulesets
 local story=require("../src/server/Services/NoviceStoryService")(content,util,deps.Economy,require("../src/server/Config/NoviceChapter"))
 local readySchema=require("../src/server/Systems/ProfileSchema")(content,util,deps.Gear,rules,deps.ValidateExpansion,deps.MarketEscrow,deps.GuildLand,true,story)
 local function selected(record:any,xp:number)
  local c=record.data.character;local def=content.Character.Classes.Warrior
  c.classId="Warrior";c.classPathId=def.PathId;c.skillId=def.SkillId;c.xp=xp;c.level=content:LevelFromXP(xp,content.ProfileLevelCap(record.data))
 end
 local function ready():any
  local r=schema.new(1,1000);r.data.personalGuild.buildings.guildHall=1;selected(r,450)
  local def=content.Adventurers.Warrior
  r.data.adventurers["a:Warrior"]={id="a:Warrior",name=def.Name,classId="Warrior",rank="F",level=10,xp=450,baseStats=util.copy(def.Stats),equipmentSlots={}}
  r.data.progression.recruitedClasses.Warrior=true;r.data.party.adventurerIds={"a:Warrior"}
  r.data.progression.novice={version=1,claimed=6,objectives={},branch="rescue",trialClass="Warrior",founderHero="a:Warrior"}
  eq(readySchema.validate(r,1),true);return r
 end
 test("profile rules preserve every legacy Hall and isolate all Novice caps",function()
  eq(legacy.Version,7);eq(schema.Version,8)
  for hall=1,20 do eq(content.HallLevelCap(hall),hall*5);eq(content.HallLevelCap(hall,modes.Legacy),hall*5);eq(content.HallLevelCap(hall,modes.Novice),math.min(100,20+(hall-1)*5)) end
  eq(content.HallLevelCap(0,modes.Novice),10)
  for _,hall in ipairs({-1,21,1.5,math.huge,0/0})do eq(pcall(content.HallLevelCap,hall,modes.Novice),false)end
  eq(pcall(content.HallLevelCap,0,modes.Legacy),false);eq(pcall(content.HallLevelCap,1,"unknown"),false)
  local r=legacy.new(1,1000);eq(content.ProgressionMode(r.data),modes.Legacy);eq(r.data.progression.ruleset,nil)
 end)
 test("schema8 Novice starts Hall0 and validates classless XP without loosening schema7",function()
  local r=schema.new(1,1000);eq(schema.validate(r,1),true);eq(r.data.personalGuild.buildings.guildHall,0);eq(content.ProfileLevelCap(r.data),10)
  for _,xp in ipairs({0,49,50,449,450,600})do r.data.character.xp=xp;r.data.character.level=math.min(10,1+math.floor(xp/50));eq(schema.validate(r,1),true)end
  local before=util.copy(r);r.data.character.level=11;eq(schema.validate(r,1),false);r=before
  r.data.progression.ruleset="unknown";eq(schema.validate(r,1),false);r.data.progression.ruleset=modes.Novice
  r.schemaVersion=7;eq(legacy.validate(r,1),false);r.schemaVersion=8
  selected(r,400);eq(schema.validate(r,1),false);selected(r,450);eq(schema.validate(r,1),true)
  r.data.personalGuild.buildings.guildHall=1;eq(schema.validate(r,1),true);eq(content.ProfileLevelCap(r.data),20)
 end)
 test("schema7 to8 migration copies records and retains old XP levels and Hall rights",function()
  for _,hall in ipairs({1,4,17,20})do
   local r=legacy.new(1,1000);r.data.personalGuild.buildings.guildHall=hall;selected(r,9999);r.data.inventory.stacks.timber=7
   eq(legacy.validate(r,1),true);local before=util.copy(r);local migrated,code=schema.migrate(r)
   eq(code,"OK");eq(r,before);eq(schema.validate(migrated,1),true);eq(migrated.data.progression.ruleset,modes.Legacy)
   local normalized=util.copy(migrated);normalized.schemaVersion=7;normalized.data.progression.ruleset=nil;eq(normalized,r)
   local again=schema.migrate(migrated);eq(again,migrated);local refused,reason=legacy.migrate(migrated);eq(refused,nil);eq(reason,"UnsupportedVersion")
  end
  local r=legacy.new(1,1000);r.data.character.level=4;local failed,reason=schema.migrate(r);eq(failed,nil);eq(reason,"MigrationFailed")
 end)
 test("every XP producer and Hall projection honors the profile ruleset",function()
  local schema=readySchema
  local emit=function()end;local economy=deps.Economy
  local quest=require("../src/server/Services/QuestService")(content,economy,deps.Progression,util)
  local r=ready();eq(quest.start(r.data,{questId="trail_watch"},1000,emit),nil)
  eq(quest.complete(r.data,{runId=r.data.quests.active.runId},2000,emit),nil);eq(r.data.adventurers["a:Warrior"].level,10);eq(schema.validate(r,1),true)
  local settlement=require("../src/server/Services/SettlementService")(content,economy,util)
  r=ready();r.data.settlement.journal.city_gate={state="Active",progress=1};eq(settlement.apply(r.data,"ClaimTask",{questId="city_gate"},emit),nil)
  eq(r.data.character.level,10);eq(r.data.adventurers["a:Warrior"].level,10);eq(schema.validate(r,1),true)
  local dispatch=require("../src/server/Services/DispatchService")(content,economy,util,function()return 1 end)
  r=ready();r.data.party.adventurerIds={};eq(dispatch.apply(r.data,"DispatchTeam",{missionId="woodland",adventurerIds={"a:Warrior"}},1000,emit),nil)
  eq(dispatch.apply(r.data,"ClaimDispatch",{jobId="job:1"},2000,emit),nil);eq(r.data.adventurers["a:Warrior"].level,10);eq(schema.validate(r,1),true)
  local reward=require("../src/server/Systems/CombatRewards")(content,deps.CombatConfig,util,economy)
  r=ready();local rewarded,result=reward(r,{"player","a:Warrior"});eq(result.code,"OK");eq(rewarded.data.character.level,10);eq(schema.validate(rewarded,1),true)
  r=ready();r.data.expansion.tower.active={id="tower:1",floor=1,state="Fighting"};r.data.expansion.tower.nextRun=2
  local won,out=deps.ExpansionService.finish(r,"tower:1",1,true);eq(out.code,"OK");eq(won.data.character.level,11);eq(schema.validate(won,1),true)
  r=ready();r.data.quests.firstClears.quarry_patrol=true;r.data.inventory.stacks=util.copy(content.Hall.Materials)
  r.data.currencies.gold=content.Hall.Gold;r.data.statistics.goldCreated=content.Hall.Gold
  for _,a in ipairs({r.data.character,r.data.adventurers["a:Warrior"]})do a.xp=2000;a.level=20 end
  eq(require("../src/server/Services/PersonalGuildService")(content,economy)(r.data,emit),nil);eq(r.data.character.level,25);eq(r.data.adventurers["a:Warrior"].level,25);eq(schema.validate(r,1),true)
  local project=require("../src/server/Systems/ViewProjection")(content,deps.Progression,util,rules)
  eq(project({state="Active",record=r},"test",1000).data.levelCap,25)
  eq(project({state="Active",record=r},"test",1000).data.nextHallLevelCap,30)
 end)
 test("opt-in schema8 survives uncertain saves replays and rejoin without changing XP",function()
  local h=harness(schema);eq(h.service.Load(1,"novice"),"OK");local request=h.command("SetLanguage",{language="th"});h.mode="after"
  eq(h.service.Execute(1,request),"SavePending");eq(h.data().settings.language,"en");h.mode="ok";h.replayCallback=true
  eq(h.service.Refresh(1),"OK");eq(h.data().settings.language,"th");local revision=h.service.Sessions[1].record.revision
  eq(h.service.Execute(1,request),"AlreadyCommitted");eq(h.service.Sessions[1].record.revision,revision)
  local before=util.copy(h.data());eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"novice-rejoin"),"OK");eq(h.data(),before)
  eq(h.data().character.xp,0);eq(h.data().personalGuild.buildings.guildHall,0);eq(schema.validate(h.service.Sessions[1].record,1),true)
 end)
end
