--!strict
return function(test:any,eq:any,harness:any?)
 local util=require("../src/shared/Util/TableUtil")
 local content=require("../src/server/Config/Content")
 local expansion=require("../src/shared/Data/Expansion")
 local placement=require("../src/shared/Data/LandBuildingPlacement")(expansion,require("../src/shared/Data/IslandPlacement"),require("../src/shared/Config/GuildIslandLayout"))
 local themes=require("../src/shared/Data/BuildingThemeRights")(require("../src/shared/Config/BuildingThemes"))
 local validator=require("../src/server/Systems/ExpansionSchema")(content,util,expansion,placement,themes)
 local gear=require("../src/shared/Data/Equipment")(content,expansion,require("../src/shared/Data/StatusPoints"))
 local marketConfig=require("../src/server/Config/Market")
 local market=require("../src/server/Systems/MarketEscrow")(marketConfig,util,content,require("../src/server/Systems/MarketOrders")(marketConfig,util))
 local land=require("../src/shared/Data/GuildLand")(require("../src/server/Config/GuildLand"))
 local economy=require("../src/server/Services/EconomyService")(content,util)
 local config=require("../src/server/Config/NoviceChapter")
 local story=require("../src/server/Services/NoviceStoryService")(content,util,economy,config)
 local makeSchema=require("../src/server/Systems/ProfileSchema")
 local schema=makeSchema(content,util,gear,expansion,validator,market,land,true,story)
 local legacy=makeSchema(content,util,gear,expansion,validator,market,land)
 local emit=function()end
 local function finish(r:any,index:number,branch:string?)
  for _,id in ipairs(config.Chapters[index].Objectives) do eq(story.observe(r.data,id,if id=="caravan_choice" then branch or "rescue" else nil),nil);eq(schema.validate(r,1),true) end
 end
 local function pretrial():any
  local r=schema.new(1,1000)
  for i=1,5 do finish(r,i);eq(story.claim(r.data,config.Chapters[i].Id,nil,emit),nil);eq(schema.validate(r,1),true) end
  return r
 end
 test("Novice six chapters grant free Hall1 and one level10 hero for all 25 class pairs",function()
  for _,classId in ipairs(content.AdventurerOrder) do for _,heroClass in ipairs(content.AdventurerOrder) do
   local r=pretrial();eq(r.data.character.level,10);eq(r.data.character.xp,450);eq(r.data.personalGuild.buildings.guildHall,0)
   eq(story.trialWon(r.data,classId),nil);eq(story.selectClass(r.data,classId,emit),nil);eq(schema.validate(r,1),true)
   finish(r,6);local before=util.copy(r.data.currencies)
   eq(story.claim(r.data,"MAIN_00_06",heroClass,emit),nil);eq(schema.validate(r,1),true)
   eq(r.data.currencies,before);eq(r.data.statistics.goldCreated,0);eq(r.data.statistics.goldDestroyed,0)
   eq(r.data.personalGuild.buildings.guildHall,1);eq(content.ProfileLevelCap(r.data),20);eq(util.count(r.data.adventurers),1)
   local hero=r.data.adventurers[r.data.progression.novice.founderHero];eq(hero.level,10);eq(hero.xp,450);eq(hero.classId,heroClass)
   eq(r.data.party.adventurerIds,{hero.id});eq(util.count(r.data.inventory.equipment),2)
   local done=util.copy(r);eq(story.claim(r.data,"MAIN_00_06",heroClass,emit),"ChapterNotActive");eq(r,done)
  end end
 end)
 test("Novice objectives enforce order and both caravan branches have identical progression",function()
  local finals={}
  for _,branch in ipairs({"rescue","supplies"}) do
   local r=schema.new(1,1000);eq(story.observe(r.data,"dodge_warning"),"PreviousObjectiveRequired")
   eq(story.claim(r.data,"MAIN_00_02",nil,emit),"ChapterNotActive");eq(story.claim(r.data,"MAIN_00_01",nil,emit),"ChapterIncomplete")
   for i=1,3 do
    finish(r,i,branch);local before=util.copy(r)
    eq(story.observe(r.data,config.Chapters[i].Objectives[1]),"AlreadyObserved");eq(r,before)
    eq(story.claim(r.data,config.Chapters[i].Id,nil,emit),nil)
   end
   eq(r.data.progression.novice.branch,branch);eq(r.data.character.level,7);eq(r.data.character.xp,300)
   r.data.progression.novice.branch="rescue";table.insert(finals,r)
  end
  eq(finals[1],finals[2])
 end)
 test("Novice trial receipts cannot bypass lessons level class or Hall gates",function()
  local r=schema.new(1,1000);eq(story.trialWon(r.data,"Warrior"),"ClassTrialLocked")
  eq(story.selectClass(r.data,"Warrior",emit),"ClassTrialRequired")
  r=pretrial();eq(story.observe(r.data,"clear_abandoned_hall"),"ClassTrialRequired")
  eq(story.trialWon(r.data,"fake"),"InvalidClass");eq(story.trialWon(r.data,"Mage"),nil)
  eq(story.selectClass(r.data,"Warrior",emit),"ClassTrialRequired")
  eq(story.trialWon(r.data,"Mage"),"AlreadyObserved");eq(story.trialWon(r.data,"Warrior"),nil)
  eq(story.selectClass(r.data,"Warrior",emit),nil);eq(story.trialWon(r.data,"Mage"),"ClassAlreadySelected")
  eq(story.selectClass(r.data,"Mage",emit),"ClassAlreadySelected");eq(schema.validate(r,1),true)
 end)
 test("Novice schema rejects corrupt skipped unknown legacy or missing story state",function()
  local r=schema.new(1,1000);eq(schema.validate(r,1),true)
  for _,mutate in ipairs({
   function(d:any)d.progression.novice=nil end,
   function(d:any)d.progression.novice.claimed=6 end,
   function(d:any)d.progression.novice.objectives.unknown=true end,
   function(d:any)d.progression.novice.objectives.dodge_warning=true end,
   function(d:any)d.progression.novice.version=2 end,
   function(d:any)d.progression.novice.branch="rescue" end,
   function(d:any)d.progression.novice.trialClass="Warrior" end,
   function(d:any)d.personalGuild.buildings.guildHall=1 end,
   function(d:any)d.progression.novice.freeGold=100 end,
  }) do local copy=util.copy(r);mutate(copy.data);eq(schema.validate(copy,1),false) end
  local old=legacy.new(1,1000);local migrated= schema.migrate(old);eq(schema.validate(migrated,1),true)
  eq(migrated.data.progression.novice,nil);eq(story.observe(migrated.data,"meet_courier"),"NoviceUnavailable")
  old.data.progression.novice=story.new();eq(legacy.validate(old,1),false)
 end)
 test("Novice preview order is flexible and capacity failures leave disposable candidate uncommitted",function()
  local r=schema.new(1,1000)
  for i=1,4 do finish(r,i);eq(story.claim(r.data,config.Chapters[i].Id,nil,emit),nil) end
  for i=5,1,-1 do eq(story.observe(r.data,config.Chapters[5].Objectives[i]),nil) end
  eq(story.claim(r.data,"MAIN_00_05",nil,emit),nil);eq(story.trialWon(r.data,"Warrior"),nil)
  for i=1,content.Limits.Equipment do r.data.inventory.equipment["fixture:"..i]={definitionId="training_sword",upgradeLevel=0,binding="Account"} end
  local before=util.copy(r);eq(story.selectClass(r.data,"Warrior",emit),"InventoryFull");eq(r,before)
  r.data.inventory.equipment["fixture:1"]=nil;eq(story.selectClass(r.data,"Warrior",emit),nil);finish(r,6)
  before=util.copy(r);eq(story.claim(r.data,"MAIN_00_06","Priest",emit),"InventoryFull");eq(r,before)
  eq(r.data.personalGuild.buildings.guildHall,0);eq(util.count(r.data.adventurers),0)
  r.data.inventory.equipment["fixture:2"]=nil;eq(story.claim(r.data,"MAIN_00_06","Priest",emit),nil);eq(schema.validate(r,1),true)
 end)
 test("Novice objective and trial action names cannot enter through the public protocol",function()
  local protocol=require("../src/shared/Network/Protocol")
  for _,action in ipairs({"NoviceObjective","NoviceTrial"}) do eq(protocol.validate({version=1,requestId="x",revision=0,action=action,args={}}),false) end
  eq(protocol.validate({version=1,requestId="x",revision=0,action="ClaimNoviceChapter",args={chapterId="MAIN_00_01"}}),true)
  eq(protocol.validate({version=1,requestId="x",revision=0,action="FoundNoviceGuild",args={heroClass="Priest",xp=450}}),false)
 end)
 test("Novice locks all guild economy actions until founding and preserves legacy access",function()
  local fresh=schema.new(1,1000);local old=legacy.new(1,1000)
  for _,action in ipairs({"Recruit","ScoutHero","HireHero","TravelZone","GatherResource","AcceptTask","ClaimTask","UpgradeGuildHall","PlaceBuilding","DispatchTeam","VisitIsland","MarketReserve","Combat","UnlockGuildPlot","BuyEquipment"})do
   eq(content.NoviceActionProblem(fresh.data,action),"NoviceJourneyRequired");eq(content.NoviceActionProblem(old.data,action),nil)
  end
  for _,action in ipairs({"GetState","RetryLoad","RetrySave","SetLanguage","BeginTutorial","ClaimNoviceChapter","FoundNoviceGuild","SelectPlayerClass"})do eq(content.NoviceActionProblem(fresh.data,action),nil)end
  local before=util.copy(fresh)
  eq(require("../src/server/Services/AdventurerService")(content,economy,util).recruit(fresh.data,{classId="Warrior"},emit),"NoviceJourneyRequired")
  eq(require("../src/server/Services/SettlementService")(content,economy,util).apply(fresh.data,"TravelZone",{zone="Guild"},emit),"NoviceJourneyRequired")
  local candidate,result=market.apply(fresh,"Reserve",{id="blocked",payload={side="BUY",itemId="timber",quantity=1,price=4}})
  eq(candidate,nil);eq(result.code,"NoviceJourneyRequired");eq(fresh,before)
 end)
 test("Novice new recruitment starts level10 while legacy recruitment stays level1",function()
  for _,novice in ipairs({false,true})do
   local r=if novice then pretrial() else legacy.new(1,1000)
   if novice then eq(story.trialWon(r.data,"Mage"),nil);eq(story.selectClass(r.data,"Mage",emit),nil);finish(r,6);eq(story.claim(r.data,"MAIN_00_06","Knight",emit),nil)end
   r.data.currencies.gold=100;r.data.statistics.goldCreated=100
   local recruit=require("../src/server/Services/AdventurerService")(content,economy,util)
   eq(recruit.recruit(r.data,{classId="Archer"},emit),nil)
   eq(r.data.adventurers["a:Archer"].level,if novice then 10 else 1);eq(r.data.adventurers["a:Archer"].xp,if novice then 450 else 0)
   r.data.settlement.offer={id="offer:1",classId="Priest",rank="F"};r.data.settlement.nextOffer=2
   eq(require("../src/server/Services/SettlementService")(content,economy,util).apply(r.data,"HireHero",{offerId="offer:1"},emit),nil)
   eq(r.data.adventurers["h:1"].level,if novice then 10 else 1);eq(r.data.adventurers["h:1"].xp,if novice then 450 else 0)
   eq((if novice then schema else legacy).validate(r,1),true)
   if novice then r.data.adventurers["h:1"].level=1;r.data.adventurers["h:1"].xp=0;eq(schema.validate(r,1),false)end
  end
 end)
 if harness then
  test("Novice receipt adapter resolves a lost write acknowledgment through the real data service",function()
   local h=harness(schema,story);eq(h.service.Load(1,"novice-adapter"),"OK")
   local receipt={owner=1,requestId="objective:first-courier",action="NoviceObjective",args={objective="meet_courier"}}
   local send=require("../src/server/Services/NoviceReceiptAdapter")(h.service,1,receipt,util,config,content)
   h.mode="after";eq(send(),"Retry");h.mode="ok";h.replayCallback=true
   eq(send(),"Committed");local revision=h.service.Sessions[1].record.revision
   eq(send(),"Committed");eq(h.service.Sessions[1].record.revision,revision)
   eq(h.data().progression.novice.objectives.meet_courier,true);eq(h.data().character.xp,0);eq(h.data().currencies.gold,0)
   eq(schema.validate(h.service.Sessions[1].record,1),true)
  end)
  test("Novice committed receipts and rewards survive lost responses replay and reconnect",function()
   local h=harness(schema,story);eq(h.service.Load(1,"novice-story"),"OK")
   for i=1,6 do
    if i==6 then
     local trial=h.command("NoviceTrial",{classId="Mage"});eq(h.service.Execute(1,trial),"InvalidRequest");eq(h.service.CommitNovice(1,trial),"OK")
     eq(h.service.Execute(1,h.command("SelectPlayerClass",{classId="Mage"})),"OK")
    end
    for _,objective in ipairs(config.Chapters[i].Objectives) do
     local command=h.command("NoviceObjective",{objective=objective,branch=if objective=="caravan_choice" then "supplies" else nil})
     h.mode="after";eq(h.service.CommitNovice(1,command),"SavePending");h.mode="ok";h.replayCallback=true
     eq(h.service.Refresh(1),"OK");eq(h.service.CommitNovice(1,command),"AlreadyCommitted")
     local changed=util.copy(command);changed.args.objective="different";eq(h.service.CommitNovice(1,changed),"RequestConflict")
    end
    local command=h.command(if i==6 then "FoundNoviceGuild" else "ClaimNoviceChapter",if i==6 then {heroClass="Knight"} else {chapterId=config.Chapters[i].Id})
    h.mode="after";eq(h.service.Execute(1,command),"SavePending");h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
    eq(h.service.FlushAudit(1),"OK")
   end
   eq(h.data().character.xp,450);eq(h.data().personalGuild.buildings.guildHall,1);eq(util.count(h.data().adventurers),1)
   local before=util.copy(h.data());eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"novice-story-rejoin"),"OK");eq(h.data(),before)
   eq(schema.validate(h.service.Sessions[1].record,1),true)
  end)
 end
end
