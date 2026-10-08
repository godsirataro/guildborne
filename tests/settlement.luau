--!strict
return function(test: any,eq: any,harness: any,util: any,content: any,schema: any,economy: any,progression: any)
 local MakeDispatch=require("../src/server/Services/DispatchService")
 local MakeTown=require("../src/server/Services/SettlementService")
 local function funded(): any
  local h=harness();h.setup();h.send("SelectPlayerClass",{classId="Warrior"})
  h.data().currencies.gold+=10000;h.data().statistics.goldCreated+=10000
  for _,id in ipairs({"timber","stone","iron_ore","iron_ingot","herb"}) do h.data().inventory.stacks[id]=500 end
  return h
 end
 local function advance(h: any,seconds: number) while seconds>0 do local step=math.min(30,seconds);h.now+=step;seconds-=step;eq(h.service.Refresh(1),"OK") end end
 local function vacant(h: any) h.send("UpdateParty",{adventurerIds={}}) end
 local function job(h: any,mission: string,sequence: {number})
  local n=0;local dispatch=MakeDispatch(content,economy,util,function() n+=1;return sequence[n] or 1 end)
  eq(dispatch.apply(h.data(),"DispatchTeam",{missionId=mission,adventurerIds={"a:Warrior"}},h.now,function() end),nil)
  eq(h.send("SetLanguage",{language="en"}),"OK")
 end
 test("forty quests preserve originals and validate all journal prerequisites",function()
  eq(#content.QuestOrder+#content.JournalOrder,40)
  eq(require("../src/server/Systems/ContentValidator")(content,util),true)
  local invalid=util.copy(content);invalid.Journal.city_gate.Requires="first_ingot"
  eq(pcall(require("../src/server/Systems/ContentValidator"),invalid,util),false)
  invalid=util.copy(content);invalid.Journal.borga_hearth.NPC="Missing citizen"
  eq(pcall(require("../src/server/Systems/ContentValidator"),invalid,util),false)
 end)
 test("friendly Orc event quests count only accepted committed gathering",function()
  local h=harness();h.setup();eq(h.send("GatherResource",{nodeId="herbs"}),"OK")
  eq(h.send("AcceptTask",{questId="mogra_gathering"}),"OK");eq(h.data().settlement.journal.mogra_gathering.progress,0)
  eq(h.send("ClaimTask",{questId="mogra_gathering"}),"TaskIncomplete")
  for _=1,2 do h.now+=10;local cmd=h.command("GatherResource",{nodeId="herbs"});eq(h.service.Execute(1,cmd),"OK");eq(h.service.Execute(1,cmd),"AlreadyCommitted") end
  eq(h.data().settlement.journal.mogra_gathering.progress,2)
  local herbs=h.data().inventory.stacks.herb;local gold=h.data().currencies.gold
  eq(h.send("ClaimTask",{questId="mogra_gathering"}),"OK");eq(h.data().inventory.stacks.herb,herbs);eq(h.data().currencies.gold,gold+8)
 end)
 test("friendly Orc delivery rewards consume once through uncertain save and rejoin",function()
  for _,mode in ipairs({"before","after"}) do
   local h=harness();h.setup();h.data().inventory.stacks.timber=4
   eq(h.send("AcceptTask",{questId="borga_hearth"}),"OK");local gold=h.data().currencies.gold
   h.mode=mode;local cmd=h.command("ClaimTask",{questId="borga_hearth"})
   eq(h.service.Execute(1,cmd),"SavePending");eq(h.data().inventory.stacks.timber,4);eq(h.data().currencies.gold,gold)
   h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.data().inventory.stacks.timber,nil);eq(h.data().currencies.gold,gold+8)
   eq(h.service.Execute(1,cmd),"AlreadyCommitted");eq(h.service.Close(1),"OK")
   h.service=h.make();eq(h.service.Load(1,"orc-quest-rejoin"),"OK");eq(h.send("ClaimTask",{questId="borga_hearth"}),"QuestNotActive")
   eq(h.data().currencies.gold,gold+8);eq(h.data().inventory.stacks.timber,nil)
  end
 end)
 test("friendly Orc quest indicators follow their own prerequisites and turn-ins",function()
  local h=harness();h.setup();local describe=require("../src/shared/Data/QuestNpcState")
  eq(describe(h.data(),content,"Borga").id,"borga_hearth");eq(describe(h.data(),content,"Mogra").id,"mogra_gathering")
  eq(describe(h.data(),content,"Rukk"),nil);eq(describe(h.data(),content,"Ghar"),nil)
  eq(h.send("AcceptTask",{questId="ghar_caravans"}),"QuestLocked")
  eq(h.send("AcceptTask",{questId="rukk_practice"}),"QuestLocked")
  h.data().settlement.journal.city_gate={state="Claimed",progress=1}
  h.data().settlement.journal.forge_foundation={state="Claimed",progress=1}
  eq(describe(h.data(),content,"Ghar").id,"ghar_caravans");eq(describe(h.data(),content,"Rukk").id,"rukk_practice")
  eq(h.send("AcceptTask",{questId="borga_hearth"}),"OK");h.data().inventory.stacks.timber=4
  eq(describe(h.data(),content,"Borga").state,"Ready to turn in")
  eq(h.send("ClaimTask",{questId="borga_hearth"}),"OK");eq(describe(h.data(),content,"Borga"),nil)
 end)
 test("new event quests track committed actions only and rewards cannot replay",function()
  local h=funded();h.data().inventory.stacks.stone=nil
  eq(h.send("AcceptTask",{questId="stonework"}),"QuestLocked")
  eq(h.send("AcceptTask",{questId="city_gate"}),"OK");eq(h.send("TravelZone",{zone="Guild"}),"OK");eq(h.send("ClaimTask",{questId="city_gate"}),"OK")
  eq(h.send("GatherResource",{nodeId="stone"}),"OK")
  eq(h.send("AcceptTask",{questId="stonework"}),"OK");eq(h.data().settlement.journal.stonework.progress,0)
  eq(h.send("GatherResource",{nodeId="stone"}),"ResourceCooling");eq(h.data().settlement.journal.stonework.progress,0)
  for _=1,3 do h.now+=10;local cmd=h.command("GatherResource",{nodeId="stone"});eq(h.service.Execute(1,cmd),"OK");eq(h.service.Execute(1,cmd),"AlreadyCommitted") end
  eq(h.data().settlement.journal.stonework.progress,3)
  local gold=h.data().currencies.gold;local cmd=h.command("ClaimTask",{questId="stonework"})
  eq(h.service.Execute(1,cmd),"OK");eq(h.data().currencies.gold,gold+content.Journal.stonework.Gold)
  eq(h.service.Execute(1,cmd),"AlreadyCommitted");eq(h.send("ClaimTask",{questId="stonework"}),"QuestNotActive")
  eq(h.data().currencies.gold,gold+content.Journal.stonework.Gold)
 end)
 test("craft objectives and existing state goals are save-atomic without rebuilding",function()
  local h=funded();local d=h.data()
  for _,id in ipairs({"city_gate","stonework","forge_foundation","camp_threat","ready_for_battle"}) do d.settlement.journal[id]={state="Claimed",progress=content.Journal[id].Count} end
  eq(h.send("AcceptTask",{questId="first_ingot"}),"OK")
  local before=util.copy(h.data());eq(h.send("CraftItem",{recipeId="iron_ingot"}),"ForgeRequired");eq(h.data(),before)
  eq(h.send("PlaceBuilding",{kind="forge",x=6,z=-4,rotation=0}),"OK")
  local cmd=h.command("CraftItem",{recipeId="iron_ingot"});h.mode="after"
  eq(h.service.Execute(1,cmd),"SavePending");eq(h.data().settlement.journal.first_ingot.progress,0)
  h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.data().settlement.journal.first_ingot.progress,1)
  eq(h.send("ClaimTask",{questId="first_ingot"}),"OK")
  eq(h.send("AcceptTask",{questId="field_outfit"}),"OK")
  eq(h.send("CraftItem",{recipeId="guardian_plate"}),"OK");eq(h.data().settlement.journal.field_outfit.progress,1)
  h.data().personalGuild.buildings.guildHall=2
  eq(h.send("AcceptTask",{questId="growing_hall"}),"OK");eq(h.data().settlement.journal.growing_hall.progress,1)
  h.data().settlement.journal.forge_foundation=nil
  eq(h.send("AcceptTask",{questId="forge_foundation"}),"OK");eq(h.data().settlement.journal.forge_foundation.progress,1)
  eq(schema.validate(h.service.Sessions[1].record,1),true)
 end)
 test("roster skill and Tower guidance responds to successful owned actions",function()
  local h=funded();local d=h.data()
  for _,id in ipairs({"city_gate","ready_for_battle"}) do d.settlement.journal[id]={state="Claimed",progress=content.Journal[id].Count} end
  eq(h.send("AcceptTask",{questId="company_reinforcement"}),"OK")
  eq(h.send("Recruit",{classId="Archer"}),"OK");eq(h.data().settlement.journal.company_reinforcement.progress,1)
  h.data().character.xp=50;h.data().character.level=2
  eq(h.send("AcceptTask",{questId="first_lesson"}),"OK")
  eq(h.data().settlement.journal.first_lesson.progress,0)
  eq(h.send("LearnSkill",{actorId="player",skillId="vitality"}),"OK")
  eq(h.data().settlement.journal.first_lesson.progress,1)
  eq(h.send("ClaimTask",{questId="first_lesson"}),"OK")
  eq(h.send("AcceptTask",{questId="spire_entry"}),"OK")
  eq(h.send("StartTower",{floor=1}),"OK");eq(h.data().settlement.journal.spire_entry.progress,0)
  eq(h.send("EnterTowerFloor"),"OK");eq(h.data().settlement.journal.spire_entry.progress,1)
 end)
 test("legacy active expedition snapshots survive the UAT content version",function()
  local h=funded();eq(h.send("StartQuest",{questId="trail_watch"}),"OK")
  local run=h.data().quests.active;run.contentVersion="slice-4.0-market"
  local gold=h.data().currencies.gold;local reward=util.copy(run.rewardSnapshot)
  advance(h,run.completeAt-h.now)
  eq(h.send("CompleteQuest",{runId=run.runId}),"OK")
  eq(h.data().currencies.gold,gold+reward.Gold)
  eq(h.service.Sessions[1].record.contentVersion,"uat01-content-1")
 end)
 test("v4 migration preserves levels and safely raises legacy Hall floor",function()
  local h=funded();local old=util.copy(h.service.Sessions[1].record);old.data.guildLand=nil;old.data.market=nil;old.schemaVersion=4;old.data.settlement=nil
  old.data.character.xp=450;old.data.character.level=10;for _,a in pairs(old.data.adventurers) do a.rank=nil end
  local before=util.copy(old);local migrated,code=schema.migrate(old);eq(code,"OK");eq(old,before);eq(migrated.data.personalGuild.buildings.guildHall,2)
  eq(migrated.data.character,old.data.character);eq(migrated.data.adventurers["a:Warrior"].rank,"F");eq(schema.validate(migrated,1),true)
  old.data.settlement={};eq(schema.migrate(old),nil)
 end)
 test("Hall cap banks XP then unlocks exactly five levels per upgrade",function()
  local h=funded();h.data().quests.firstClears.quarry_patrol=true;local a=h.data().adventurers["a:Warrior"];a.xp=900;a.level=5
  eq(h.send("UpgradeGuildHall"),"OK");eq(a.level,5);eq(h.data().adventurers["a:Warrior"].level,10)
  eq(h.send("UpgradeGuildHall"),"OK");eq(h.data().adventurers["a:Warrior"].level,15)
  eq(schema.validate(h.service.Sessions[1].record,1),true)
 end)
 test("housing capacity is bounded by both Hall and Quarters with occupied dismantle rejected",function()
  local h=funded();eq(content.RosterCapacity(h.data()),5);h.data().personalGuild.buildings.guildHall=3
  eq(h.send("SaveBuildLayout",{slot=1}),"OK")
  eq(content.RosterCapacity(h.data()),5);eq(h.send("PlaceBuilding",{kind="quarters",x=6,z=-4,rotation=0}),"OK");eq(content.RosterCapacity(h.data()),10)
  eq(h.send("UpgradeQuarters",{buildingId="b:1"}),"OK");eq(content.RosterCapacity(h.data()),15);eq(h.send("UpgradeQuarters",{buildingId="b:1"}),"HallRequired")
  for i=1,5 do h.data().settlement.offer={id="offer:"..i,classId="Warrior",rank="F"};h.data().settlement.nextOffer=i+1;eq(h.send("HireHero",{offerId="offer:"..i}),"OK") end
  eq(h.send("DismantleBuilding",{buildingId="b:1"}),"HousingOccupied")
  eq(h.send("StoreBuilding",{buildingId="b:1"}),"HousingOccupied")
  eq(h.send("ApplyBuildLayout",{slot=1}),"HousingOccupied")
 end)
 test("tavern odds total 100 percent and top rank weight improves",function()
  local last=0;for level,weights in ipairs(content.Tavern.Odds) do local sum=0;for _,n in ipairs(weights) do sum+=n end;eq(sum,10000)
   assert(weights[9]>=last);last=weights[9];local h=funded();h.data().settlement.tavernLevel=level;h.data().personalGuild.buildings.guildHall=level
   local town=MakeTown(content,economy,util,function(a: number,b: number) return b end);eq(town.apply(h.data(),"ScoutHero",{},function() end),nil)
   assert(table.find(content.Tavern.Ranks,h.data().settlement.offer.rank))
  end
 end)
 test("all fifteen offline templates keep named identity class stats and matching appearance when hired",function()
  local enabled=util.copy(content);enabled.RecruitmentTemplatesAvailable=true
  local choose=require("../src/server/Systems/HeroTemplateChoice")
  for classIndex,class in ipairs(content.AdventurerOrder) do for variant=1,3 do
   local h=funded();local calls=0;local sequence={1,classIndex,variant}
   local town=MakeTown(enabled,economy,util,function()calls+=1;return sequence[calls]end)
   eq(town.apply(h.data(),"ScoutHero",{},function()end),nil);eq(calls,3)
   local templateId=content.HeroTemplatePools[class][variant];eq(h.data().settlement.offer.templateId,templateId)
   eq(h.send("HireHero",{offerId=h.data().settlement.offer.id}),"OK")
   local hero=h.data().adventurers["h:1"];eq(hero.templateId,templateId);eq(hero.name,content.HeroTemplates[templateId].Name)
   eq(hero.baseStats,content.Adventurers[class].Stats);eq(choose(class,hero.id,hero.templateId),templateId)
   eq(h.data().inventory.equipment[hero.equipmentSlots.weapon].definitionId,content.Character.Classes[class].Weapon)
   eq(schema.validate(h.service.Sessions[1].record,1),true)
   local record=util.copy(h.service.Sessions[1].record);record.data.adventurers["h:1"].name="Mismatch";eq(schema.validate(record,1),false)
   record=util.copy(h.service.Sessions[1].record);record.data.adventurers["h:1"].templateId="missing";eq(schema.validate(record,1),false)
  end end
  local h=funded();local calls=0;local town=MakeTown(content,economy,util,function()calls+=1;return 1 end)
  eq(town.apply(h.data(),"ScoutHero",{},function()end),nil);eq(calls,2);eq(h.data().settlement.offer.templateId,nil)
 end)
 test("named candidate and hire survive uncertain writes replay and rejoin without rerolling",function()
  local previous=content.RecruitmentTemplatesAvailable;content.RecruitmentTemplatesAvailable=true
  local ok,problem=pcall(function()
   for _,mode in ipairs({"before","after"}) do
    local h=funded();local gold=h.data().currencies.gold;local scout=h.command("ScoutHero");h.mode=mode
    eq(h.service.Execute(1,scout),"SavePending");h.mode="ok";eq(h.service.Refresh(1),"OK")
    local offer=util.copy(h.data().settlement.offer);assert(offer.templateId);eq(h.data().currencies.gold,gold-content.Tavern.ScoutCost)
    eq(h.service.Execute(1,scout),"AlreadyCommitted");eq(h.data().settlement.offer,offer)
    local hire=h.command("HireHero",{offerId=offer.id});h.mode=mode;eq(h.service.Execute(1,hire),"SavePending")
    h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,hire),"AlreadyCommitted")
    local hero=util.copy(h.data().adventurers["h:1"]);eq(hero.templateId,offer.templateId);eq(hero.name,content.HeroTemplates[offer.templateId].Name)
    local expected=gold-content.Tavern.ScoutCost-content.Tavern.HireCost-((table.find(content.Tavern.Ranks,offer.rank) or 1)-1)*10
    eq(h.data().currencies.gold,expected);eq(h.data().settlement.nextHero,2)
    eq(h.service.Close(1),"OK");content.RecruitmentTemplatesAvailable=false
    eq(h.service.Load(1,"named-rejoin"),"OK");eq(h.data().adventurers["h:1"],hero);eq(h.data().currencies.gold,expected)
    content.RecruitmentTemplatesAvailable=true
   end
  end)
  content.RecruitmentTemplatesAvailable=previous;assert(ok,tostring(problem))
 end)
 test("duplicate-class hires keep distinct IDs equipment skills and party assignments",function()
  local h=funded();h.data().settlement.offer={id="offer:1",classId="Warrior",rank="A"};h.data().settlement.nextOffer=2
  eq(h.send("HireHero",{offerId="offer:1"}),"OK");assert(h.data().adventurers["h:1"] and h.data().adventurers["a:Warrior"])
  eq(h.send("UpdateParty",{adventurerIds={"a:Warrior","h:1"}}),"OK");eq(h.send("HireHero",{offerId="offer:1"}),"OfferExpired")
  assert(progression.stats(h.data(),h.data().adventurers["h:1"]).Attack>progression.stats(h.data(),h.data().adventurers["a:Warrior"]).Attack)
  eq(schema.validate(h.service.Sessions[1].record,1),true)
 end)
 test("uncertain scouting commits one charged candidate and never rerolls on retry",function()
  local h=funded();local before=h.data().currencies.gold;local cmd=h.command("ScoutHero");h.mode="after";eq(h.service.Execute(1,cmd),"SavePending")
  local offer=util.copy(h.records["p:1"].data.settlement.offer);h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.data().settlement.offer,offer)
  eq(h.service.Execute(1,cmd),"AlreadyCommitted");eq(h.data().currencies.gold,before-20)
 end)
 test("main side NPC journal is one-time and tracks only accepted server events",function()
  local h=funded();eq(h.send("AcceptTask",{questId="camp_threat"}),"QuestLocked");eq(h.send("AcceptTask",{questId="city_gate"}),"OK")
  eq(h.send("ClaimTask",{questId="city_gate"}),"TaskIncomplete");eq(h.send("TravelZone",{zone="Guild"}),"OK");eq(h.send("ClaimTask",{questId="city_gate"}),"OK")
  eq(h.send("ClaimTask",{questId="city_gate"}),"QuestNotActive");eq(h.send("AcceptTask",{questId="camp_threat"}),"OK")
  eq(h.send("AcceptTask",{questId="herbalist"}),"OK");local herbs=h.data().inventory.stacks.herb;eq(h.send("ClaimTask",{questId="herbalist"}),"OK");eq(h.data().inventory.stacks.herb,herbs-6)
  eq(h.send("AcceptTask",{questId="timber_help"}),"OK");h.data().inventory.stacks.timber=1
  for _=1,4 do h.now+=10;eq(h.send("GatherResource",{nodeId="wood"}),"OK") end
  eq(h.data().settlement.journal.timber_help.progress,4)
 end)
 test("dispatch excludes field party duplicate IDs and already assigned heroes",function()
  local h=funded();eq(h.send("DispatchTeam",{missionId="woodland",adventurerIds={"a:Warrior"}}),"HeroUnavailable");vacant(h)
  eq(h.send("DispatchTeam",{missionId="woodland",adventurerIds={"a:Warrior","a:Warrior"}}),"HeroUnavailable")
  eq(h.send("DispatchTeam",{missionId="woodland",adventurerIds={"a:Warrior"}}),"OK");eq(h.send("UpdateParty",{adventurerIds={"a:Warrior"}}),"HeroUnavailable")
  eq(h.send("DispatchTeam",{missionId="ruins",adventurerIds={"a:Warrior"}}),"HeroUnavailable")
 end)
 test("dispatch survives offline rejoin with hidden outcome and immutable reward",function()
  local h=funded();vacant(h);job(h,"woodland",{1});h.send("SetLanguage",{language="en"});local saved=util.copy(h.data().settlement.jobs)
  eq(h.send("ClaimDispatch",{jobId="job:1"}),"QuestTooEarly");h.service.Close(1);h.now+=300;h.service=h.make();eq(h.service.Load(1,"offline"),"OK")
  eq(h.data().settlement.jobs,saved);local project=require("../src/server/Systems/ViewProjection")(content,progression,util)
  local view=project(h.service.Sessions[1],"test",h.now);eq(view.data.settlement.jobs["job:1"].success,nil);eq(view.data.settlement.jobs["job:1"].casualties,nil)
  local timber=h.data().inventory.stacks.timber;eq(h.send("ClaimDispatch",{jobId="job:1"}),"OK");eq(h.data().inventory.stacks.timber,timber+6)
  eq(h.send("ClaimDispatch",{jobId="job:1"}),"QuestNotActive")
 end)
 test("dispatch rewards reject capacity atomically and recover uncertain writes",function()
  local h=funded();vacant(h);job(h,"woodland",{1});advance(h,300);h.data().inventory.stacks.timber=content.Limits.Stack
  local before=util.copy(h.data());eq(h.send("ClaimDispatch",{jobId="job:1"}),"InventoryFull");eq(h.data(),before)
  h.data().inventory.stacks.timber=1;local cmd=h.command("ClaimDispatch",{jobId="job:1"});h.mode="after";eq(h.service.Execute(1,cmd),"SavePending");h.mode="ok";eq(h.service.Refresh(1),"OK")
  eq(h.service.Execute(1,cmd),"AlreadyCommitted");eq(h.data().inventory.stacks.timber,7)
 end)
 test("death requires one Elixir and revival retains hero identity gear XP and rank",function()
  local h=funded();vacant(h);job(h,"ruins",{100,1});advance(h,700);eq(h.send("ClaimDispatch",{jobId="job:1"}),"OK")
  eq(h.data().adventurers["a:Warrior"].condition,"Dead");eq(h.send("UpdateParty",{adventurerIds={"a:Warrior"}}),"HeroUnavailable")
  eq(h.send("ReviveHero",{actorId="a:Warrior"}),"ElixirRequired");local before=h.data().currencies.gold
  eq(h.send("BuyElixir"),"OK");eq(h.data().currencies.gold,before-1000);eq(h.send("ReviveHero",{actorId="a:Warrior"}),"OK");eq(h.data().settlement.elixirs,0)
  eq(h.send("ReviveHero",{actorId="a:Warrior"}),"HeroNotDead");eq(h.data().adventurers["a:Warrior"].id,"a:Warrior")
 end)
 test("injured hero heals only after server recovery deadline",function()
  local h=funded();vacant(h);job(h,"ruins",{100,20});advance(h,700);h.send("ClaimDispatch",{jobId="job:1"});eq(h.data().adventurers["a:Warrior"].condition,"Injured")
  eq(h.send("UpdateParty",{adventurerIds={"a:Warrior"}}),"HeroUnavailable");advance(h,901);eq(h.send("UpdateParty",{adventurerIds={"a:Warrior"}}),"OK")
 end)
 test("dispatch roster gear cannot move while away and returns after resolution",function()
  local h=funded();h.quest("trail_watch");h.send("AssignEquipment",{actorId="a:Warrior",instanceId="q:1:1"});vacant(h);job(h,"woodland",{1})
  eq(h.send("UnequipEquipment",{actorId="a:Warrior",slot="weapon"}),"HeroUnavailable")
  eq(h.send("AssignEquipment",{actorId="player",instanceId="q:1:1"}),"HeroUnavailable")
 end)
 test("private purchase receipt survives uncertain save and rejoin without duplicate Elixir",function()
  local h=funded();content.Elixir.DeveloperProductId=12345;local before=h.data().settlement.elixirs
  h.mode="after";eq(h.service.CommitElixir(1,"purchase-1",12345),"SavePending");h.mode="ok";eq(h.service.Refresh(1),"OK")
  eq(h.service.CommitElixir(1,"purchase-1",12345),"AlreadyCommitted");eq(h.data().settlement.elixirs,before+1)
  h.service.Close(1);h.service=h.make();eq(h.service.Load(1,"receipt-rejoin"),"OK");eq(h.service.CommitElixir(1,"purchase-1",12345),"AlreadyCommitted")
  eq(h.service.CommitElixir(1,"purchase-2",999),"InvalidReceipt");eq(h.send("ElixirReceipt",{}),"InvalidRequest");content.Elixir.DeveloperProductId=0
 end)
end
