--!strict
-- Staged Chapter06 balance using disposable full profiles, never real player grants.
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local compose=require("../src/server/Config/CampaignSequence")
 local arcs:{any}={require("../src/server/Config/ChapterOne"),require("../src/server/Config/ChapterTwo"),require("../src/server/Config/ChapterThree"),require("../src/server/Config/ChapterFour"),require("../src/server/Config/ChapterFive"),require("../src/server/Config/ChapterSix")}
 local config=compose(arcs);local prior=compose({arcs[1],arcs[2],arcs[3],arcs[4],arcs[5]})
 local economy=require("../src/server/Services/EconomyService")(content,util)
 local upgrade=require("../src/server/Services/PersonalGuildService")(content,economy,true,config);local noop=function()end
 local choices={allocate_timber="workers",choose_motto="discovery",choose_crest="compass",choose_joint_review="council",choose_bridge_route="direct",choose_witness_route="guard",renew_tower_oath="compassion",choose_tower_door="moon",choose_reconciliation="shared_table",choose_forger_fate="testify",choose_offer_response="refuse",choose_citadel_approach="guard",choose_warden_release="release",choose_tower_future="transform"}
 local function finish(f:any,index:number,selected:any?)
  local c=config.Chapters[index];local d=f.record.data
  for _,id in ipairs(c.Objectives)do eq(f.context.Campaign.observe(d,id,(selected or choices)[id]),nil)end
  eq(f.context.Campaign.claim(d,c.Id,if c.Recruit then "Priest"else nil,noop),nil);eq(f.context.Schema.validate(f.record,1),true)
 end
 local function crosshaven(class:string):any
  local context=require("./novice_context")(config);local record=context.Schema.new(1,1000);local d=record.data
  for i,c in ipairs(context.Config.Chapters)do
   if i==6 then eq(context.Story.trialWon(d,class),nil);eq(context.Story.selectClass(d,class,noop),nil)end
   for _,id in ipairs(c.Objectives)do eq(context.Story.observe(d,id,if id=="caravan_choice"then "rescue"else nil),nil)end
   eq(context.Story.claim(d,c.Id,if i==6 then "Knight"else nil,noop),nil)
  end
  local f={context=context,record=record}
  for i=1,30 do local c=config.Chapters[i];if c.Hall and d.personalGuild.buildings.guildHall<c.Hall then eq(upgrade(d,noop),nil)end;finish(f,i)end
  eq(d.character.level,85);eq(d.personalGuild.buildings.guildHall,14);return f
 end
 test("Archive Heart preserves the completed Crosshaven record and earlier chapter definitions",function()
  local f=crosshaven("Mage");local before=util.copy(f.record.data)
  require("../src/server/Services/CampaignService")(content,util,economy,prior).validate(f.record.data)
  f.context.Campaign.validate(f.record.data);eq(f.record.data,before);eq(#config.Chapters,36);eq(#prior.Chapters,30)
  for i=1,30 do eq(config.Chapters[i],prior.Chapters[i])end
 end)
 test("Archive Heart ninety class choice routes reach level100 Hall17 with guaranteed upgrades",function()
  local count=0
  for _,class in ipairs(content.AdventurerOrder)do for _,approach in ipairs({"guard","stealth","puzzle"})do for _,oath in ipairs({"release","renew"})do for _,ending in ipairs({"preserve","transform","dismantle"})do
   local f=crosshaven(class);local d=f.record.data;local selected=util.copy(choices)
   selected.choose_citadel_approach=approach;selected.choose_warden_release=oath;selected.choose_tower_future=ending
   local history=util.copy(d.progression.campaign.choices);local builds=util.copy(d.expansion.actors)
   -- Prior Gold may already have been spent; finale guarantees its own required costs.
   eq(economy.gold(d,-d.currencies.gold,"fixture_prior_spending",noop),nil)
   finish(f,31,selected);eq(d.character.level,85);eq(upgrade(d,noop),nil);eq(d.character.level,88)
   finish(f,32,selected);eq(d.character.level,90)
   finish(f,33,selected);eq(upgrade(d,noop),nil);eq(d.character.level,93)
   finish(f,34,selected);eq(d.character.level,95)
   finish(f,35,selected);eq(upgrade(d,noop),nil);eq(d.character.level,100)
   finish(f,36,selected)
   eq(d.character.xp,4950);eq(d.currencies.gold,200);eq(d.inventory.stacks,{})
   eq(d.personalGuild.buildings.guildHall,17);eq(d.progression.campaign.claimed,36)
   eq(d.character.classId,class);eq(d.expansion.actors,builds)
   eq(require("../src/shared/Data/StatusPoints").budget(d.character.level),297)
   for id,value in pairs(history)do eq(d.progression.campaign.choices[id],value)end
   eq(f.context.Schema.validate(f.record,1),true);count+=1
  end end end end
  eq(count,90)
 end)
 test("Archive Heart rejects skipped backup invalid endings replay and unselected Hall18 without spending",function()
  local f=crosshaven("Priest");local d=f.record.data;local before=util.copy(d)
  eq(f.context.Campaign.observe(d,"establish_heart_command"),"PreviousObjectiveRequired")
  eq(f.context.Campaign.observe(d,"choose_citadel_approach","buy_entry"),"InvalidCampaignChoice");eq(d,before)
  for i=31,33 do if d.personalGuild.buildings.guildHall<config.Chapters[i].Hall then eq(upgrade(d,noop),nil)end;finish(f,i)end
  eq(upgrade(d,noop),nil);eq(f.context.Campaign.observe(d,"recover_named_ledgers"),nil)
  before=util.copy(d);eq(f.context.Campaign.observe(d,"disconnect_ledger_engine"),"PreviousObjectiveRequired");eq(d,before)
  eq(f.context.Campaign.observe(d,"duplicate_named_ledgers"),nil);eq(f.context.Campaign.observe(d,"disconnect_ledger_engine"),nil)
  eq(f.context.Campaign.claim(d,"MAIN_06_04",nil,noop),nil)
  for i=35,36 do if d.personalGuild.buildings.guildHall<config.Chapters[i].Hall then eq(upgrade(d,noop),nil)end;finish(f,i)end
  before=util.copy(d);eq(f.context.Campaign.claim(d,"MAIN_06_06",nil,noop),"ChapterNotActive");eq(d,before)
  d.quests.firstClears.quarry_patrol=true;d.currencies.gold=100000;d.inventory.stacks={timber=1000,stone=1000,iron_ore=1000}
  before=util.copy(d);eq(upgrade(d,noop),"CampaignHallLocked");eq(d,before)
 end)
 test("Archive Heart uses existing rewards and bilingual guidance for all eighteen objectives",function()
  local count=0
  for _,c in ipairs(arcs[6].Chapters)do
   assert(c.XP>=0 and c.Gold>=0)
   for _,item in ipairs(c.Items or {})do assert(content.Items[item.Id]and item.Quantity>0)end
   for _,id in ipairs(c.Objectives)do for i=1,2 do assert(#config.Guidance[id][i]>0 and #config.ObjectiveLabels[id][i]>0)end;count+=1 end
  end
  eq(count,18)
 end)
end
