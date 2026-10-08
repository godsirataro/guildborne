--!strict
-- Staged Chapter05 balance using disposable full profiles, never real player grants.
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local compose=require("../src/server/Config/CampaignSequence")
 local arcs:{any}={require("../src/server/Config/ChapterOne"),require("../src/server/Config/ChapterTwo"),require("../src/server/Config/ChapterThree"),require("../src/server/Config/ChapterFour"),require("../src/server/Config/ChapterFive")}
 local config=compose(arcs);local prior=compose({arcs[1],arcs[2],arcs[3],arcs[4]})
 local economy=require("../src/server/Services/EconomyService")(content,util)
 local upgrade=require("../src/server/Services/PersonalGuildService")(content,economy,true,config);local noop=function()end
 local choices={allocate_timber="workers",choose_motto="discovery",choose_crest="compass",choose_joint_review="council",choose_bridge_route="direct",choose_witness_route="guard",renew_tower_oath="compassion",choose_tower_door="moon",choose_reconciliation="shared_table",choose_forger_fate="testify",choose_offer_response="refuse"}
 local function finish(f:any,index:number,selected:any?)
  local c=config.Chapters[index];local d=f.record.data
  for _,id in ipairs(c.Objectives)do eq(f.context.Campaign.observe(d,id,(selected or choices)[id]),nil)end
  eq(f.context.Campaign.claim(d,c.Id,if c.Recruit then "Priest"else nil,noop),nil);eq(f.context.Schema.validate(f.record,1),true)
 end
 local function tower(class:string):any
  local context=require("./novice_context")(config);local record=context.Schema.new(1,1000);local d=record.data
  for i,c in ipairs(context.Config.Chapters)do
   if i==6 then eq(context.Story.trialWon(d,class),nil);eq(context.Story.selectClass(d,class,noop),nil)end
   for _,id in ipairs(c.Objectives)do eq(context.Story.observe(d,id,if id=="caravan_choice"then "rescue"else nil),nil)end
   eq(context.Story.claim(d,c.Id,if i==6 then "Knight"else nil,noop),nil)
  end
  local f={context=context,record=record}
  for i=1,24 do local c=config.Chapters[i];if c.Hall and d.personalGuild.buildings.guildHall<c.Hall then eq(upgrade(d,noop),nil)end;finish(f,i)end
  eq(upgrade(d,noop),nil);eq(d.character.level,70);return f
 end
 test("Crosshaven preserves the completed Tower checkpoint when composing the next arc",function()
  local f=tower("Mage");local before=util.copy(f.record.data)
  require("../src/server/Services/CampaignService")(content,util,economy,prior).validate(f.record.data)
  f.context.Campaign.validate(f.record.data);eq(f.record.data,before);eq(#config.Chapters,30);eq(#prior.Chapters,24)
  for i=1,24 do eq(config.Chapters[i],prior.Chapters[i])end
 end)
 test("Crosshaven five roots and eight story routes reach Hall14 level85 with guaranteed supplies",function()
  for _,class in ipairs(content.AdventurerOrder)do for _,reconcile in ipairs({"shared_table","joint_work"})do for _,fate in ipairs({"testify","guarded_refuge"})do for _,offer in ipairs({"refuse","investigate"})do
   local f=tower(class);local d=f.record.data;local selected=util.copy(choices)
   selected.choose_reconciliation=reconcile;selected.choose_forger_fate=fate;selected.choose_offer_response=offer
   local history=util.copy(d.progression.campaign.choices);local classId=d.character.classId;local path=d.character.classPathId
   finish(f,25,selected);eq(d.character.level,70);eq(upgrade(d,noop),nil);eq(d.character.level,72)
   finish(f,26,selected);eq(d.character.level,75)
   finish(f,27,selected);eq(upgrade(d,noop),nil);eq(d.character.level,78)
   finish(f,28,selected);eq(d.character.level,80)
   finish(f,29,selected);eq(upgrade(d,noop),nil);eq(d.character.level,85)
   finish(f,30,selected)
   eq(d.character.xp,4200);eq(d.currencies.gold,260);eq(d.inventory.stacks,{})
   eq(d.personalGuild.buildings.guildHall,14);eq(d.progression.campaign.claimed,30)
   eq(d.character.classId,classId);eq(d.character.classPathId,path)
   for id,value in pairs(history)do eq(d.progression.campaign.choices[id],value)end
   eq(f.context.Schema.validate(f.record,1),true)
  end end end end
 end)
 test("Crosshaven gates ordered evidence invalid choices repeated claims and unselected Hall15",function()
  local f=tower("Knight");local d=f.record.data;local before=util.copy(d)
  eq(f.context.Campaign.observe(d,"rescue_former_rival"),"PreviousObjectiveRequired");eq(upgrade(d,noop),"CampaignHallLocked");eq(d,before)
  finish(f,25);eq(f.context.Campaign.observe(d,"collect_both_testimonies"),"CampaignHallRequired");eq(upgrade(d,noop),nil)
  eq(f.context.Campaign.observe(d,"collect_both_testimonies"),nil);eq(f.context.Campaign.observe(d,"hold_crosshaven_hearing"),nil)
  before=util.copy(d);eq(f.context.Campaign.observe(d,"choose_reconciliation","exclude_neighbors"),"InvalidCampaignChoice");eq(d,before)
  eq(f.context.Campaign.observe(d,"choose_reconciliation","joint_work"),nil);eq(f.context.Campaign.claim(d,"MAIN_05_02",nil,noop),nil)
  before=util.copy(d);eq(f.context.Campaign.claim(d,"MAIN_05_02",nil,noop),"ChapterNotActive");eq(d,before)
  for i=27,30 do if d.personalGuild.buildings.guildHall<config.Chapters[i].Hall then eq(upgrade(d,noop),nil)end;finish(f,i)end
  d.quests.firstClears.quarry_patrol=true;d.currencies.gold=100000;d.inventory.stacks={timber=1000,stone=1000,iron_ore=1000}
  before=util.copy(d);eq(upgrade(d,noop),"CampaignHallLocked");eq(d,before)
 end)
 test("Crosshaven supplies bilingual guidance and valid deterministic rewards for every objective",function()
  for _,c in ipairs(arcs[5].Chapters)do
   assert(c.XP>=0 and c.Gold>=0)
   for _,item in ipairs(c.Items or {})do assert(content.Items[item.Id]and item.Quantity>0)end
   for _,id in ipairs(c.Objectives)do for i=1,2 do assert(#config.Guidance[id][i]>0 and #config.ObjectiveLabels[id][i]>0)end end
  end
 end)
end
