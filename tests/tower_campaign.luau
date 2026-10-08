--!strict
-- Synthetic staged Chapter04 balance; no actual player grants or runtime activation.
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local compose=require("../src/server/Config/CampaignSequence")
 local arcs:{any}={require("../src/server/Config/ChapterOne"),require("../src/server/Config/ChapterTwo"),require("../src/server/Config/ChapterThree"),require("../src/server/Config/ChapterFour")}
 local config=compose(arcs);local prior=compose({arcs[1],arcs[2],arcs[3]})
 local economy=require("../src/server/Services/EconomyService")(content,util)
 local upgrade=require("../src/server/Services/PersonalGuildService")(content,economy,true,config);local noop=function()end
 local function fresh(class:string):any
  local context=require("./novice_context")(config);local record=context.Schema.new(1,1000)
  for i,c in ipairs(context.Config.Chapters)do
   if i==6 then eq(context.Story.trialWon(record.data,class),nil);eq(context.Story.selectClass(record.data,class,noop),nil)end
   for _,id in ipairs(c.Objectives)do eq(context.Story.observe(record.data,id,if id=="caravan_choice"then "rescue"else nil),nil)end
   eq(context.Story.claim(record.data,c.Id,if i==6 then "Knight"else nil,noop),nil)
  end
  return {context=context,record=record}
 end
 local function finish(f:any,index:number,oath:string?,door:string?)
  local c=config.Chapters[index];local d=f.record.data
  local choices={allocate_timber="workers",choose_motto="discovery",choose_crest="compass",choose_joint_review="council",choose_bridge_route="direct",choose_witness_route="guard",renew_tower_oath=oath or "courage",choose_tower_door=door or "sun"}
  for _,id in ipairs(c.Objectives)do eq(f.context.Campaign.observe(d,id,choices[id]),nil)end
  eq(f.context.Campaign.claim(d,c.Id,if c.Recruit then "Priest"else nil,noop),nil);eq(f.context.Schema.validate(f.record,1),true)
 end
 local function ashen(class:string):any
  local f=fresh(class)
  for i=1,18 do
   local hall=config.Chapters[i].Hall
   if hall and f.record.data.personalGuild.buildings.guildHall<hall then eq(upgrade(f.record.data,noop),nil)end
   finish(f,i)
  end
  return f
 end
 test("Tower composition preserves every previous campaign definition and checkpoint",function()
  local before=util.copy(arcs);local f=fresh("Mage")
  local old=require("../src/server/Services/CampaignService")(content,util,economy,prior)
  for i=0,18 do
   local d=f.record.data;local saved=util.copy(d);old.validate(d);f.context.Campaign.validate(d);eq(d,saved)
   if i<18 then local c=config.Chapters[i+1];if c.Hall and d.personalGuild.buildings.guildHall<c.Hall then eq(upgrade(d,noop),nil)end;finish(f,i+1)end
  end
  eq(arcs,before);eq(#config.Chapters,24);eq(#prior.Chapters,18)
 end)
 test("Tower all root classes and oath-door routes reach Hall11 level70 without extra rewards",function()
  for _,class in ipairs(content.AdventurerOrder)do for _,oath in ipairs({"courage","compassion"})do for _,door in ipairs({"sun","moon"})do
   local f=ashen(class);local d=f.record.data;eq(d.character.xp,2450);eq(d.currencies.gold,140)
   local before=util.copy(d.progression.campaign.choices);local savedClass=util.copy(d.character)
   finish(f,19);eq(d.character.level,50);eq(d.character.xp,2600);eq(upgrade(d,noop),nil);eq(d.character.level,53)
   finish(f,20);eq(d.character.level,55)
   finish(f,21);eq(d.character.xp,2950);eq(d.character.level,55);eq(upgrade(d,noop),nil);eq(d.character.level,60)
   finish(f,22,oath);eq(d.character.xp,3100);eq(upgrade(d,noop),nil);eq(d.character.level,63)
   finish(f,23,oath,door);eq(d.character.level,65)
   finish(f,24);eq(d.character.xp,3450);eq(d.character.level,65);eq(upgrade(d,noop),nil);eq(d.character.level,70)
   eq(d.currencies.gold,140);eq(d.inventory.stacks,{});eq(d.personalGuild.buildings.guildHall,11)
   eq(d.progression.campaign.choices.renew_tower_oath,oath);eq(d.progression.campaign.choices.choose_tower_door,door)
   for id,value in pairs(before)do eq(d.progression.campaign.choices[id],value)end
   eq(d.character.classId,savedClass.classId);eq(d.character.classPathId,savedClass.classPathId);eq(d.character.skillId,savedClass.skillId)
   eq(util.count(d.adventurers),2);eq(f.context.Schema.validate(f.record,1),true)
  end end end
 end)
 test("Tower rejects premature permits skipped objectives replay and invalid choices without effects",function()
  local f=ashen("Priest");local d=f.record.data;local before=util.copy(d)
  eq(upgrade(d,noop),"CampaignHallLocked");eq(f.context.Campaign.observe(d,"confirm_tower_charter"),"PreviousObjectiveRequired");eq(d,before)
  finish(f,19);eq(f.context.Campaign.observe(d,"try_guardian_roles"),"CampaignHallRequired")
  before=util.copy(d);eq(f.context.Campaign.claim(d,"MAIN_04_01",nil,noop),"ChapterNotActive");eq(d,before)
  local bad=util.copy(d);bad.progression.campaign.hallPermit=11;assert(not pcall(function()f.context.Campaign.validate(bad)end))
  eq(upgrade(d,noop),nil);finish(f,20);finish(f,21);eq(upgrade(d,noop),nil)
  eq(f.context.Campaign.observe(d,"read_guild_memories"),nil);eq(f.context.Campaign.observe(d,"rescue_memory_echo"),nil);before=util.copy(d)
  eq(f.context.Campaign.observe(d,"renew_tower_oath","rewrite_past"),"InvalidCampaignChoice");eq(d,before)
 end)
 test("Tower bilingual metadata and Hall tracker expose gates for all six quests",function()
  local f=ashen("Archer");finish(f,19);local d=f.record.data;d.hallLevel=7;d.rosterCapacity=10
  local describe=require("../src/shared/Data/CampaignViewState");local track=require("../src/shared/Data/QuestTracker")
  for _,language in ipairs({"en","th"})do
   d.language=language;local catalog={CampaignChapter=config,EquipmentLimit=50};local s=describe(d,catalog,false)
   eq(s.total,24);eq(s.hall,8);eq(s.hallReady,false);eq(s.canClaim,false);assert(string.find(track(d,catalog,nil).name,"8",1,true))
  end
  for _,c in ipairs(arcs[4].Chapters)do for _,id in ipairs(c.Objectives)do for i=1,2 do assert(#config.Guidance[id][i]>0 and #config.ObjectiveLabels[id][i]>0)end end end
 end)
 test("Tower saved midpoint and shield lesson survive full profile reload without duplicate rewards",function()
  local f=ashen("Knight");local d=f.record.data;local balance=util.copy(d.currencies)
  eq(f.context.Campaign.observe(d,"reach_tower_checkpoint_five"),nil)
  local restored=util.copy(f.record);eq(f.context.Schema.validate(restored,1),true)
  local reopened=require("../src/server/Services/CampaignService")(content,util,economy,config)
  reopened.validate(restored.data);eq(reopened.observe(restored.data,"reach_tower_checkpoint_five"),"AlreadyObserved")
  eq(reopened.observe(restored.data,"finish_tower_orientation"),nil);eq(restored.data.currencies,balance)
  eq(reopened.observe(restored.data,"collect_tower_chart"),nil);eq(reopened.observe(restored.data,"confirm_tower_charter"),nil)
  eq(reopened.claim(restored.data,"MAIN_04_01",nil,noop),nil);eq(upgrade(restored.data,noop),nil)
  eq(reopened.observe(restored.data,"try_guardian_guard"),nil)
  restored=util.copy(restored);eq(f.context.Schema.validate(restored,1),true)
  eq(reopened.observe(restored.data,"try_guardian_guard"),"AlreadyObserved")
  eq(reopened.observe(restored.data,"try_guardian_roles"),nil)
  eq(restored.data.progression.campaign.objectives,{try_guardian_guard=true,try_guardian_roles=true})
 end)
end
