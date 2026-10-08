--!strict
-- Synthetic evidence for a staged arc; not a claim that Chapter02 is playable.
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local first=require("../src/server/Config/ChapterOne");local second=require("../src/server/Config/ChapterTwo")
 local compose=require("../src/server/Config/CampaignSequence");local config=compose({first,second})
 local economy=require("../src/server/Services/EconomyService")(content,util)
 local service=require("../src/server/Services/CampaignService")(content,util,economy,config)
 local prior=require("../src/server/Services/CampaignService")(content,util,economy,first)
 local upgrade=require("../src/server/Services/PersonalGuildService")(content,economy,true,config)
 local noop=function()end
 local function fresh():any
  return {progression={ruleset=content.ProgressionRulesets.Novice,novice={claimed=6,founderHero="a:Warrior"},campaign=service.new(),recruitedClasses={Warrior=true}},personalGuild={buildings={guildHall=1}},
   character={classId="Mage",level=10,xp=450},adventurers={["a:Warrior"]={classId="Warrior",xp=450,level=10}},party={adventurerIds={"a:Warrior"}},
   inventory={equipment={},stacks={}},currencies={gold=0},statistics={goldCreated=0,goldDestroyed=0},settlement={nextHero=1},quests={firstClears={}},expansion={buildings={},tower={}}}
 end
 local function finish(data:any,index:number,branch:string?)
  local c=config.Chapters[index]
  for _,id in ipairs(c.Objectives)do
   local choice=if id=="allocate_timber"then "workers"elseif id=="choose_motto"then "together"elseif id=="choose_crest"then "compass"elseif id=="choose_joint_review"then branch or "workers"else nil
   eq(service.observe(data,id,choice),nil);service.validate(data)
  end
  eq(service.claim(data,c.Id,if c.Recruit then "Priest"else nil,noop),nil);service.validate(data)
 end
 local function founded():any
  local data=fresh();for i=1,6 do finish(data,i)end;return data
 end
 test("Staged continuation accepts every old Chapter01 checkpoint without rewriting it",function()
  local data=fresh()
  for i=0,6 do
   local before=util.copy(data);prior.validate(data);service.validate(data);eq(data,before)
   if i<6 then finish(data,i+1)end
  end
  eq(#first.Chapters,6);eq(#second.Chapters,6);eq(#config.Chapters,12)
  assert(not pcall(function()compose({first,first})end))
 end)
 test("Ironveil Hall gates prevent observations and claims even with excess character level",function()
  local data=founded();data.character.level=100
  local before=util.copy(data)
  eq(service.observe(data,"inspect_ironveil_scales"),"CampaignHallRequired")
  eq(service.claim(data,"MAIN_02_01",nil,noop),"CampaignHallRequired");eq(data,before)
 end)
 test("Ironveil minimum economy reaches Hall4 and level35 without side quests or lost XP",function()
  for _,branch in ipairs({"workers","council"})do
   local data=founded();eq(upgrade(data,noop),nil);eq(data.currencies.gold,20)
   local recruited=data.progression.campaign.recruitHero;local nextHero=data.settlement.nextHero
   finish(data,7);eq(data.character.level,22);eq(data.character.xp,1050)
   finish(data,8);eq(data.character.level,25);eq(data.character.xp,1200)
   eq(upgrade(data,noop),"CampaignHallLocked")
   finish(data,9);eq(data.character.level,25);eq(data.character.xp,1350);eq(data.progression.campaign.hallPermit,3)
   eq(service.observe(data,"collect_reagent"),"CampaignHallRequired")
   eq(upgrade(data,noop),nil);eq(data.character.level,28);eq(data.character.xp,1350);eq(data.currencies.gold,40)
   finish(data,10,branch);eq(data.character.level,30)
   finish(data,11);eq(data.character.level,30);eq(data.character.xp,1700)
   eq(upgrade(data,noop),nil);eq(data.character.level,35);eq(data.character.xp,1700);eq(data.currencies.gold,40)
   local xp=data.character.xp;finish(data,12);eq(data.character.xp,xp)
   eq(data.personalGuild.buildings.guildHall,4);eq(data.inventory.stacks,{})
   eq(data.progression.campaign.recruitHero,recruited);eq(data.settlement.nextHero,nextHero)
   eq(data.progression.campaign.choices.choose_motto,"together");eq(data.progression.campaign.choices.choose_crest,"compass")
   eq(data.statistics.goldDestroyed,480);eq(data.statistics.goldCreated,520)
   eq(service.claim(data,"MAIN_02_06",nil,noop),"ChapterNotActive")
  end
 end)
 test("Ironveil validation rejects forged permits and missing prior identity or recruit",function()
  local data=founded();eq(upgrade(data,noop),nil)
  for i=7,9 do finish(data,i)end
  for _,change in ipairs({function(d:any)d.progression.campaign.hallPermit=4 end,function(d:any)d.progression.campaign.choices.choose_crest=nil end,function(d:any)d.progression.campaign.recruitHero=nil end})do
   local bad=util.copy(data);change(bad);assert(not pcall(function()service.validate(bad)end))
  end
 end)
 test("Staged Ironveil keeps full profiles valid for all five first classes through Hall4",function()
  for _,class in ipairs(content.AdventurerOrder)do
   local context=require("./novice_context")(config);local record=context.Schema.new(1,1000)
   for i,chapter in ipairs(context.Config.Chapters)do
    if i==6 then eq(context.Story.trialWon(record.data,class),nil);eq(context.Story.selectClass(record.data,class,noop),nil)end
    for _,id in ipairs(chapter.Objectives)do eq(context.Story.observe(record.data,id,if id=="caravan_choice"then "rescue"else nil),nil)end
    eq(context.Story.claim(record.data,chapter.Id,if i==6 then "Knight"else nil,noop),nil)
   end
   for i=1,12 do
    if i==7 or i==10 or i==12 then eq(upgrade(record.data,noop),nil)end
    finish(record.data,i);eq(context.Schema.validate(record,1),true)
   end
   eq(record.data.character.classId,class);eq(record.data.character.level,35)
   eq(util.count(record.data.adventurers),2)
  end
 end)
 test("Staged campaign UI and tracker present Hall gates before blocked Ironveil objectives",function()
  local describe=require("../src/shared/Data/CampaignViewState");local tracker=require("../src/shared/Data/QuestTracker")
  local data=founded();data.rosterCapacity=10;data.hallLevel=1;data.settlement.journal={}
  local catalog={CampaignChapter=config,EquipmentLimit=content.Limits.Equipment,Journal={},JournalOrder={}}
  for _,language in ipairs({"en","th"})do
   data.language=language;local view=describe(data,catalog,false)
   eq(view.total,12);eq(view.hallReady,false);eq(view.hall,2);eq(view.canClaim,false)
   local tracking=tracker(data,catalog,nil);assert(string.find(tracking.name,"2",1,true));eq(tracking.ready,false)
  end
  eq(upgrade(data,noop),nil);data.hallLevel=2
  eq(describe(data,catalog,false).hallReady,true)
  eq(tracker(data,catalog,nil).name,config.ObjectiveLabels.inspect_ironveil_scales[2])
 end)
end
