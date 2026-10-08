--!strict
-- Synthetic continuation contract, separate from actual preview journey evidence.
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local arcs:{any}={require("../src/server/Config/ChapterOne"),require("../src/server/Config/ChapterTwo"),require("../src/server/Config/ChapterThree")}
 local compose=require("../src/server/Config/CampaignSequence");local config=compose(arcs)
 local economy=require("../src/server/Services/EconomyService")(content,util)
 local upgrade=require("../src/server/Services/PersonalGuildService")(content,economy,true,config)
 local oldConfig=compose({arcs[1],arcs[2]});local prior=require("../src/server/Services/CampaignService")(content,util,economy,oldConfig)
 local noop=function()end
 local function fresh(class:string):any
  local c=require("./novice_context")(config);local record=c.Schema.new(1,1000)
  for i,chapter in ipairs(c.Config.Chapters)do
   if i==6 then eq(c.Story.trialWon(record.data,class),nil);eq(c.Story.selectClass(record.data,class,noop),nil)end
   for _,id in ipairs(chapter.Objectives)do eq(c.Story.observe(record.data,id,if id=="caravan_choice"then "supplies"else nil),nil)end
   eq(c.Story.claim(record.data,chapter.Id,if i==6 then "Knight"else nil,noop),nil)
  end
  return {context=c,record=record}
 end
 local function finish(f:any,index:number,bridge:string?,witness:string?)
  local c=config.Chapters[index];local data=f.record.data
  for _,id in ipairs(c.Objectives)do
   local choices={allocate_timber="town",choose_motto="together",choose_crest="sun",choose_joint_review="workers",choose_bridge_route=bridge or "sheltered",choose_witness_route=witness or "trust"}
   eq(f.context.Campaign.observe(data,id,choices[id]),nil)
  end
  eq(f.context.Campaign.claim(data,c.Id,if c.Recruit then "Priest"else nil,noop),nil);eq(f.context.Schema.validate(f.record,1),true)
 end
 local function ironveil(class:string):any
  local f=fresh(class)
  for i=1,12 do if i==7 or i==10 or i==12 then eq(upgrade(f.record.data,noop),nil)end;finish(f,i)end
  return f
 end
 test("Ashen composition preserves all Chapter01-02 checkpoints and definitions",function()
  local before=util.copy(arcs);local f=fresh("Mage")
  for i=0,12 do
   local d=f.record.data;local saved=util.copy(d);prior.validate(d);f.context.Campaign.validate(d);eq(d,saved)
   if i<12 then if i+1==7 or i+1==10 or i+1==12 then eq(upgrade(d,noop),nil)end;finish(f,i+1)end
  end
  eq(arcs,before);eq(#config.Chapters,18);eq(#oldConfig.Chapters,12)
 end)
 test("Ashen all classes and route choices reach Hall7 level50 with earned resources only",function()
  for _,class in ipairs(content.AdventurerOrder)do for _,bridge in ipairs({"sheltered","direct"})do for _,witness in ipairs({"trust","guard"})do
   local f=ironveil(class);local d=f.record.data;local recruit=d.progression.campaign.recruitHero
   eq(d.currencies.gold,40);eq(d.character.xp,1700)
   finish(f,13);eq(d.character.level,35);eq(d.character.xp,1850);eq(upgrade(d,noop),nil);eq(d.character.level,38)
   finish(f,14);eq(d.character.level,40)
   finish(f,15,bridge);eq(d.character.level,40);eq(d.character.xp,2100);eq(upgrade(d,noop),nil);eq(d.character.level,43)
   finish(f,16,bridge,witness);eq(d.character.level,45)
   finish(f,17);eq(d.character.level,45);eq(d.character.xp,2450);eq(upgrade(d,noop),nil);eq(d.character.level,50)
   finish(f,18);eq(d.character.xp,2450);eq(d.currencies.gold,140);eq(d.inventory.stacks,{})
   eq(d.personalGuild.buildings.guildHall,7);eq(d.character.classId,class);eq(d.progression.campaign.recruitHero,recruit)
   eq(d.progression.campaign.choices.choose_bridge_route,bridge);eq(d.progression.campaign.choices.choose_witness_route,witness)
   eq(util.count(d.adventurers),2);eq(f.context.Schema.validate(f.record,1),true)
  end end end
 end)
 test("Ashen refuses skipped objectives forged choices premature Hall permits and repeated rewards",function()
  local f=ironveil("Knight");local d=f.record.data;local before=util.copy(d)
  eq(f.context.Campaign.observe(d,"request_ashen_charter"),"PreviousObjectiveRequired");eq(d,before)
  eq(upgrade(d,noop),"CampaignHallLocked")
  finish(f,13);local bad=util.copy(d);bad.progression.campaign.hallPermit=7;assert(not pcall(function()f.context.Campaign.validate(bad)end))
  eq(f.context.Campaign.observe(d,"preserve_hearth_traces"),"CampaignHallRequired")
  eq(f.context.Campaign.claim(d,"MAIN_03_01",nil,noop),"ChapterNotActive")
  eq(upgrade(d,noop),nil);finish(f,14)
  eq(f.context.Campaign.observe(d,"secure_bridge_supports"),nil);before=util.copy(d)
  eq(f.context.Campaign.observe(d,"choose_bridge_route","paid_shortcut"),"InvalidCampaignChoice");eq(d,before)
 end)
 test("Ashen metadata presents every objective and Hall gate bilingually",function()
  local f=ironveil("Archer");finish(f,13);local d=f.record.data;d.hallLevel=4;d.rosterCapacity=10
  local describe=require("../src/shared/Data/CampaignViewState");local track=require("../src/shared/Data/QuestTracker")
  for _,language in ipairs({"en","th"})do
   d.language=language;local catalog={CampaignChapter=config,EquipmentLimit=50}
   local s=describe(d,catalog,false);eq(s.hall,5);eq(s.hallReady,false);eq(s.canClaim,false);eq(s.total,18)
   assert(string.find(track(d,catalog,nil).name,"5",1,true))
  end
  for _,chapter in ipairs(arcs[3].Chapters)do for _,id in ipairs(chapter.Objectives)do for i=1,2 do assert(#config.ObjectiveLabels[id][i]>0 and #config.Guidance[id][i]>0)end end end
 end)
end
