--!strict
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil")
 local content=require("../src/server/Config/Content")
 local config=require("../src/server/Config/ReleaseContent")
 local policy=require("../src/server/Systems/ReleasePolicy")(config)
 local runtime={LaunchCandidate=true,StudioPersistence="Memory"}
 local context={isStudio=true,placeId=0,gameId=0}
 local release=policy.resolve(runtime,context)
 local function data(mode:string?):any
  return {progression={ruleset=mode or content.ProgressionRulesets.Novice,campaign={claimed=12}},personalGuild={buildings={guildHall=4}},character={level=35,xp=1700},expansion={actors={player={tier=1}}}}
 end
 test("Launch flag cannot enable a published or persistent environment",function()
  eq(release.Enabled,true);eq(release.MaxLevel,35);eq(release.CampaignChapters,12)
  local invalidContexts:{any}={{isStudio=false,placeId=0,gameId=0},{isStudio=true,placeId=1,gameId=0},{isStudio=true,placeId=0,gameId=1},{}}
  for _,change in ipairs(invalidContexts)do
   local disabled=policy.resolve(runtime,change);eq(disabled.Enabled,false);eq(disabled.problem(data(),"StartTower",{}),nil)
  end
  eq(policy.resolve({LaunchCandidate=true,StudioPersistence="DataStore"},context).Enabled,false)
  eq(policy.resolve({LaunchCandidate=false,StudioPersistence="Memory"},context).Enabled,false)
  eq(policy.resolve({StudioPersistence="Memory"},context).Enabled,false)
 end)
 test("Release prevents future entry and new objectives but allows recovery and earned claims",function()
  local d=data();local before=util.copy(d)
  for _,action in ipairs({"StartTower","EnterTowerFloor"})do eq(release.problem(d,action,{}),"ReleaseContentUnavailable")end
  eq(release.problem(d,"LeaveTower",{}),nil)
  for _,zone in ipairs({"City","Guild","Greenwood","Ironveil","Deepforge"})do eq(release.problem(d,"TravelZone",{zone=zone}),nil)end
  for _,zone in ipairs({"Ashen","UnknownFuture"})do eq(release.problem(d,"TravelZone",{zone=zone}),"ReleaseContentUnavailable")end
  for id in pairs(config.BlockedTasks)do
   eq(release.problem(d,"AcceptTask",{questId=id}),"ReleaseContentUnavailable")
   eq(release.problem(d,"ClaimTask",{questId=id}),nil)
  end
  eq(release.problem(d,"AcceptTask",{questId="borin_castings"}),nil)
  eq(release.problem(d,"GatherResource",{nodeId="ashen_stone"}),"ReleaseContentUnavailable")
  eq(release.problem(d,"GatherResource",{nodeId="ironveil_ore"}),nil)
  eq(release.problem(d,"UpgradeGuildHall",{}),"ReleaseHallCap")
  eq(d,before);d.personalGuild.buildings.guildHall=3;eq(release.problem(d,"UpgradeGuildHall",{}),nil)
 end)
 test("Player Class2 needs completed mentor story and hero proof is never borrowed",function()
  local d=data();d.progression.campaign.claimed=11
  eq(release.problem(d,"AdvanceClass",{actorId="player",pathId="berserker"}),"ClassMentorRequired")
  d.progression.campaign.claimed=12
  eq(release.problem(d,"AdvanceClass",{actorId="player",pathId="berserker"}),nil)
  eq(release.problem(d,"AdvanceClass",{actorId="h:1",pathId="berserker"}),"HeroMentorRequired")
  eq(release.problem(d,"AdvanceClass",{actorId="player",pathId="warlord"}),"ReleaseContentUnavailable")
  local rules=require("../src/shared/Data/Expansion")
  for id in pairs(config.Class2Paths)do eq(rules.Paths[id].Tier,2)end
  for id,path in pairs(rules.Paths)do if path.Tier==2 then eq(config.Class2Paths[id],true)end end
 end)
 test("Policy preserves legacy advancement and elevated earned levels without global recapping",function()
  local d=data(content.ProgressionRulesets.Legacy);d.personalGuild.buildings.guildHall=20;d.character={level=100,xp=4950}
  local before=util.copy(d)
  eq(release.problem(d,"AdvanceClass",{actorId="h:1",pathId="berserker"}),nil)
  eq(release.problem(d,"EquipSkill",{actorId="player",skillId="cleave_master"}),nil)
  eq(release.problem(d,"UpgradeGuildHall",{}),"ReleaseHallCap")
  eq(content.ProfileLevelCap(d),100);eq(content:LevelFromXP(d.character.xp,content.ProfileLevelCap(d)),100);eq(d,before)
 end)
 local arcs:{any}={require("../src/server/Config/ChapterOne"),require("../src/server/Config/ChapterTwo"),require("../src/server/Config/ChapterThree"),require("../src/server/Config/ChapterFour"),require("../src/server/Config/ChapterFive"),require("../src/server/Config/ChapterSix")}
 local compose=require("../src/server/Config/CampaignSequence")
 local active=compose({arcs[1],arcs[2]});local full=compose(arcs)
 local economy=require("../src/server/Services/EconomyService")(content,util)
 local make=require("../src/server/Services/CampaignService")
 local launch=make(content,util,economy,active,full)
 test("Validation catalog cannot substitute active rewards or choice semantics",function()
  local wrong=util.copy(full);wrong.Chapters[1].XP+=1
  eq(pcall(function()make(content,util,economy,active,wrong)end),false)
  wrong=util.copy(full);wrong.Choices.allocate_timber.workers=nil
  eq(pcall(function()make(content,util,economy,active,wrong)end),false)
 end)
 test("Full historical campaign checkpoints remain valid under a two-chapter launch",function()
  local c=require("./novice_context")(full);local r=c.Schema.new(1,1000);local d=r.data
  local noop=function()end
  for i,chapter in ipairs(c.Config.Chapters)do
   if i==6 then eq(c.Story.trialWon(d,"Mage"),nil);eq(c.Story.selectClass(d,"Mage",noop),nil)end
   for _,id in ipairs(chapter.Objectives)do eq(c.Story.observe(d,id,if id=="caravan_choice"then "supplies"else nil),nil)end
   eq(c.Story.claim(d,chapter.Id,if i==6 then "Knight"else nil,noop),nil)
  end
  local upgrade=require("../src/server/Services/PersonalGuildService")(content,economy,true,full)
  for i=1,18 do
   local chapter=full.Chapters[i]
   while d.personalGuild.buildings.guildHall<(chapter.Hall or 1)do eq(upgrade(d,noop),nil)end
   for _,id in ipairs(chapter.Objectives)do
    local choice=if full.Choices[id]then next(full.Choices[id])else nil
    eq(c.Campaign.observe(d,id,choice),nil)
    local before=util.copy(d);launch.validate(d);eq(d,before)
   end
   eq(c.Campaign.claim(d,chapter.Id,if chapter.Recruit then "Priest"else nil,noop),nil)
   local before=util.copy(d);launch.validate(d);eq(d,before);eq(c.Schema.validate(r,1),true)
   if i>=12 then
    eq(launch.claim(d,full.Chapters[i+1].Id,nil,noop),"ChapterNotActive")
    eq(launch.observe(d,full.Chapters[i+1].Objectives[1],nil),"WrongObjective");eq(d,before)
   end
  end
  eq(d.character.level,50);eq(d.progression.campaign.claimed,18)
  assert(d.progression.campaign.choices.choose_bridge_route and d.progression.campaign.choices.choose_witness_route)
  local corrupt=util.copy(d);corrupt.progression.campaign.hallPermit=20
  eq(pcall(function()launch.validate(corrupt)end),false)
 end)
end
