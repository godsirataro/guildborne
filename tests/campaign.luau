--!strict
-- Synthetic domain progression. Does not establish playable world bindings.
return function(test:any,eq:any,harness:any?)
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local config=require("../src/server/Config/ChapterOne")
 local service=require("../src/server/Services/CampaignService")(content,util,require("../src/server/Services/EconomyService")(content,util),config)
 local function fresh():any
  return {progression={ruleset=content.ProgressionRulesets.Novice,novice={claimed=6,founderHero="a:Warrior"},campaign=service.new(),recruitedClasses={Warrior=true}},personalGuild={buildings={guildHall=1}},
   character={classId="Mage",level=10,xp=450},adventurers={["a:Warrior"]={classId="Warrior",xp=450,level=10}},party={adventurerIds={"a:Warrior"}},
   inventory={equipment={},stacks={}},currencies={gold=0},statistics={goldCreated=0,goldDestroyed=0},settlement={nextHero=1},quests={firstClears={}},expansion={buildings={},tower={}}}
 end
 local function observe(data:any,index:number,branch:string?)
  for _,id in ipairs(config.Chapters[index].Objectives)do
   local choice=if id=="allocate_timber"then branch or "workers"elseif id=="choose_motto"then "together"elseif id=="choose_crest"then "compass"else nil
   eq(service.observe(data,id,choice),nil);service.validate(data)
  end
 end
 local noop=function()end
 test("Campaign tracker prioritizes current ordered objective and every objective has bilingual guidance",function()
  local tracker=require("../src/shared/Data/QuestTracker");local data=fresh();data.settlement.journal={}
  local catalog={CampaignChapter=config,Journal={},JournalOrder={}}
  for _,chapter in ipairs(config.Chapters)do for _,id in ipairs(chapter.Objectives)do
   assert(#config.Guidance[id][1]>20 and #config.Guidance[id][2]>20)
  end end
  for _,language in ipairs({"en","th"})do
   data.language=language;local view=tracker(data,catalog,nil);eq(view.kind,"Campaign");eq(view.tab,"Guild");eq(view.name,config.ObjectiveLabels.meet_founder[if language=="th"then 2 else 1])
  end
  observe(data,1);eq(tracker(data,catalog,nil).ready,true)
  for i,c in ipairs(config.Chapters)do if i>1 then observe(data,i)end;eq(service.claim(data,c.Id,if c.Recruit then "Priest"else nil,noop),nil)end
  eq(tracker(data,catalog,nil).kind,"CampaignComplete")
 end)
 test("Campaign Hall permits gate novice upgrades including unselected future arcs",function()
  local economy=require("../src/server/Services/EconomyService")(content,util)
  local enabled=require("../src/server/Services/PersonalGuildService")(content,economy,true)
  local legacy=require("../src/server/Services/PersonalGuildService")(content,economy)
  local data=fresh();data.quests.firstClears.quarry_patrol=true
  eq(enabled(data,noop),"CampaignHallLocked")
  data.quests.firstClears={}
  for i,c in ipairs(config.Chapters)do observe(data,i);eq(service.claim(data,c.Id,if c.Recruit then "Mage"else nil,noop),nil)end
  local before=util.copy(data);eq(legacy(data,noop),"HallLocked");eq(data,before)
  eq(enabled(data,noop),nil);eq(data.personalGuild.buildings.guildHall,2);eq(data.currencies.gold,20);eq(data.inventory.stacks,{})
  eq(data.statistics.goldDestroyed,80);eq(content.ProfileLevelCap(data),25)
  eq(enabled(data,noop),"CampaignHallLocked")
  data.quests.firstClears.quarry_patrol=true;local future=util.copy(data)
  eq(enabled(data,noop),"CampaignHallLocked");eq(data,future)
  data=fresh();data.progression.ruleset=content.ProgressionRulesets.Legacy;eq(enabled(data,noop),"HallLocked")
 end)
 test("Campaign view exposes ordered bilingual guidance and blocks busy capacity level and expedition claims",function()
  local describe=require("../src/shared/Data/CampaignViewState")
  local catalog={CampaignChapter=config,EquipmentLimit=content.Limits.Equipment}
  local data=fresh();data.rosterCapacity=10;data.hallLevel=1
  eq(describe(data,catalog,false).nextObjective,"meet_founder")
  for _,language in ipairs({"en","th"})do
   data.language=language
   local view=describe(data,catalog,false);eq(view.canClaim,false);eq(view.title,if language=="th"then config.Chapters[1].Thai else config.Chapters[1].Title)
   eq(view.objectives[1].text,config.ObjectiveLabels.meet_founder[if language=="th"then 2 else 1])
  end
  observe(data,1);eq(describe(data,catalog,false).canClaim,true);eq(describe(data,catalog,true).canClaim,false)
  data.quests.active={};eq(describe(data,catalog,false).canClaim,false);data.quests.active=nil
  eq(service.claim(data,"MAIN_01_01",nil,noop),nil);observe(data,2)
  local view=describe(data,catalog,false);eq(view.stage,"Recruit");eq(view.canClaim,true)
  data.rosterCapacity=1;eq(describe(data,catalog,false).room,false);data.rosterCapacity=10
  for i=1,content.Limits.Equipment do data.inventory.equipment[tostring(i)]={}end
  eq(describe(data,catalog,false).canClaim,false);data.inventory.equipment={}
  data.character.level=10;eq(describe(data,catalog,false).levelReady,false)
  eq(describe(data,{},false).stage,"Unavailable")
 end)
 test("Chapter01 all five guaranteed choices and both allocations reach level20 without duplicate founder or paid gates",function()
  for _,hero in ipairs(content.AdventurerOrder)do for _,branch in ipairs({"workers","town"})do
   local data=fresh();service.validate(data)
   for i,c in ipairs(config.Chapters)do
    observe(data,i,branch);eq(service.claim(data,c.Id,if c.Recruit then hero else nil,noop),nil);service.validate(data)
    local saved=util.copy(data);eq(service.claim(data,c.Id,if c.Recruit then hero else nil,noop),"ChapterNotActive");eq(data,saved)
    if i==1 then eq(util.count(data.adventurers),1)end
   end
   eq(data.character.xp,950);eq(data.character.level,20);eq(data.adventurers["a:Warrior"].xp,950)
   eq(util.count(data.adventurers),2);eq(data.adventurers["h:1"].classId,hero);eq(data.adventurers["h:1"].level,10);eq(data.adventurers["h:1"].xp,450)
   eq(data.currencies.gold,100);eq(data.statistics.goldCreated,100);eq(data.statistics.goldDestroyed,0)
   eq(data.progression.campaign.hallPermit,2);eq(data.personalGuild.buildings.guildHall,1);eq(data.quests.firstClears,{})
   eq(data.inventory.stacks,{timber=6,iron_ore=6,iron_ingot=1,herb=2});eq(util.count(data.inventory.equipment),1)
  end end
 end)
 test("Chapter01 rejects skipped repeated invalid choices and legacy or unfounded access",function()
  local data=fresh();eq(service.observe(data,"regroup_companion"),"PreviousObjectiveRequired")
  eq(service.observe(data,"meet_founder","town"),"InvalidCampaignChoice");eq(service.observe(data,"missing"),"WrongObjective")
  eq(service.claim(data,"MAIN_01_01",nil,noop),"ChapterIncomplete")
  eq(service.observe(data,"meet_founder"),nil);local before=util.copy(data);eq(service.observe(data,"meet_founder"),"AlreadyObserved");eq(data,before)
  data=fresh();data.progression.novice.claimed=5;eq(service.observe(data,"meet_founder"),"CampaignLocked")
  data=fresh();data.progression.ruleset=content.ProgressionRulesets.Legacy;eq(service.claim(data,"MAIN_01_01",nil,noop),"CampaignLocked")
  data=fresh();data.character.level=9;eq(service.observe(data,"meet_founder"),"CampaignLevelRequired")
 end)
 test("Chapter01 receipt copies source and rejects client-shaped extra fields",function()
  local record={data=fresh()};local before=util.copy(record)
  local changed,result=service.receipt(record,{action="CampaignObjective",args={objective="meet_founder"}});eq(result.code,"OK");eq(record,before);assert(changed.data.progression.campaign.objectives.meet_founder)
  changed,result=service.receipt(record,{action="CampaignObjective",args={objective="meet_founder",xp=999}});eq(changed,nil);eq(result.code,"InvalidRequest");eq(record,before)
  changed,result=service.receipt(record,{action="ClaimCampaignChapter",args={}});eq(changed,nil);eq(result.code,"InvalidAction")
 end)
 test("Chapter01 invalid persisted fields permits and missing recruit cannot validate",function()
  local base=fresh()
  for _,mutate in ipairs({function(d:any)d.progression.campaign.hallPermit=2 end,function(d:any)d.progression.campaign.objectives.regroup_companion=true end,function(d:any)d.progression.campaign.choices.choose_crest="sun"end,function(d:any)d.progression.campaign.unknown=true end,function(d:any)d.progression.campaign.claimed=2 end})do
   local data=util.copy(base);mutate(data);eq(pcall(service.validate,data),false)
  end
 end)
 test("Chapter01 capacity and running expedition failures discard the entire candidate",function()
  local data=fresh();observe(data,1);eq(service.claim(data,"MAIN_01_01",nil,noop),nil);observe(data,2)
  for i=1,content.Limits.Equipment do data.inventory.equipment[tostring(i)]={definitionId="training_sword"}end
  local before=util.copy(data);local candidate=util.copy(data);eq(service.claim(candidate,"MAIN_01_02","Mage",noop),"InventoryFull");eq(data,before)
  data.inventory.equipment={};data.quests.active={};before=util.copy(data);eq(service.claim(data,"MAIN_01_02","Mage",noop),"FinishExpedition");eq(data,before)
  data.quests.active=nil;data.party.adventurerIds={"a:Warrior","a:Warrior"};eq(service.claim(data,"MAIN_01_02","Mage",noop),"AdventurerNotOwned")
 end)
 test("Chapter01 state and grants remain valid in the full optional schema8 profile",function()
  local c=require("./novice_context")();local r=c.Schema.new(1,1000);eq(c.Schema.validate(r,1),true)
  for i,chapter in ipairs(c.Config.Chapters)do
   if i==6 then eq(c.Story.trialWon(r.data,"Mage"),nil);eq(c.Story.selectClass(r.data,"Mage",noop),nil)end
   for _,id in ipairs(chapter.Objectives)do eq(c.Story.observe(r.data,id,if id=="caravan_choice"then "supplies"else nil),nil)end
   eq(c.Story.claim(r.data,chapter.Id,if i==6 then "Priest"else nil,noop),nil);eq(c.Schema.validate(r,1),true)
  end
  for i,chapter in ipairs(config.Chapters)do
   observe(r.data,i);eq(c.Campaign.claim(r.data,chapter.Id,if chapter.Recruit then "Priest"else nil,noop),nil);eq(c.Schema.validate(r,1),true)
  end
  eq(util.count(r.data.adventurers),2);eq(r.data.adventurers["h:1"].classId,"Priest");eq(r.data.progression.campaign.hallPermit,2)
 end)
 test("Campaign objective remains private and claim payloads cannot contain rewards",function()
  local protocol=require("../src/shared/Network/Protocol")
  local function packet(action:string,args:any):any return {version=1,requestId="campaign:test",revision=0,action=action,args=args}end
  eq(protocol.validate(packet("CampaignObjective",{objective="meet_founder"})),false)
  eq(protocol.validate(packet("ClaimCampaignChapter",{chapterId="MAIN_01_01"})),true)
  eq(protocol.validate(packet("ClaimCampaignRecruit",{chapterId="MAIN_01_02",heroClass="Knight"})),true)
  eq(protocol.validate(packet("ClaimCampaignChapter",{chapterId="MAIN_01_01",xp=100})),false)
 end)
 if harness then test("Campaign private receipts and rewards survive lost acknowledgments replay and reconnect",function()
  local c=require("./novice_context")();local h=harness(c.Schema,c.Story,c.Campaign);eq(h.service.Load(1,"campaign-session"),"OK")
  for i,chapter in ipairs(c.Config.Chapters)do
   if i==6 then eq(h.service.CommitNovice(1,h.command("NoviceTrial",{classId="Mage"})),"OK");eq(h.send("SelectPlayerClass",{classId="Mage"}),"OK")end
   for _,objective in ipairs(chapter.Objectives)do eq(h.service.CommitNovice(1,h.command("NoviceObjective",{objective=objective,branch=if objective=="caravan_choice"then "rescue"else nil})),"OK")end
   eq(h.send(if i==6 then "FoundNoviceGuild"else "ClaimNoviceChapter",if i==6 then {heroClass="Knight"}else {chapterId=chapter.Id}),"OK");eq(h.service.FlushAudit(1),"OK")
  end
  for _,chapter in ipairs(config.Chapters)do
   for _,objective in ipairs(chapter.Objectives)do
    local choice=if objective=="allocate_timber"then "town"elseif objective=="choose_motto"then "courage"elseif objective=="choose_crest"then "sun"else nil
    local receipt={owner=1,requestId="campaign:"..objective,action="CampaignObjective",args={objective=objective,choice=choice}}
    local send=require("../src/server/Services/NoviceReceiptAdapter")(h.service,1,receipt,util,c.Config,content,config)
    h.mode="after";eq(send(),"Retry");h.mode="ok";h.replayCallback=true;eq(send(),"Committed");local revision=h.service.Sessions[1].record.revision;eq(send(),"Committed");eq(h.service.Sessions[1].record.revision,revision)
   end
   local command=h.command(if chapter.Recruit then "ClaimCampaignRecruit"else "ClaimCampaignChapter",{chapterId=chapter.Id,heroClass=if chapter.Recruit then "Archer"else nil})
   h.mode="after";eq(h.service.Execute(1,command),"SavePending");h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted");eq(h.service.FlushAudit(1),"OK")
   eq(c.Schema.validate(h.service.Sessions[1].record,1),true)
  end
  eq(h.data().currencies.gold,100);eq(h.data().character.xp,950);eq(util.count(h.data().adventurers),2);eq(h.data().progression.campaign.hallPermit,2)
  local upgrade=h.command("UpgradeGuildHall",{});h.mode="after";eq(h.service.Execute(1,upgrade),"SavePending")
  h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,upgrade),"AlreadyCommitted");eq(h.service.FlushAudit(1),"OK")
  eq(h.data().personalGuild.buildings.guildHall,2);eq(h.data().currencies.gold,20);eq(h.data().inventory.stacks,{});eq(c.Schema.validate(h.service.Sessions[1].record,1),true)
  local before=util.copy(h.data());eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"campaign-rejoin"),"OK");eq(h.data(),before)
 end)end
end
