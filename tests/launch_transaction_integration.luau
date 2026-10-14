--!strict
return function(test:any,eq:any,harness:any)
 local U=require("../src/shared/Util/TableUtil")
 local C=require("../src/server/Config/Content")
 local E=require("../src/shared/Data/Expansion")
 local G=require("../src/shared/Data/Equipment")(C,E,require("../src/shared/Data/StatusPoints"))
 local economy=require("../src/server/Services/EconomyService")(C,U)
 local rewards=require("../src/server/Systems/LaunchRewards")(C,U,economy,require("../src/server/Config/LaunchRewards"))
 local schema=require("../src/server/Systems/ProfileSchema")(C,U,G,E,require("../src/server/Systems/ExpansionSchema")(C,U,E),nil,nil,nil,nil,nil,nil,rewards)
 local progression=require("../src/server/Systems/Progression")(C,G)
 local commands=require("../src/server/Systems/Commands")({Content=C,Util=U,Protocol=require("../src/shared/Network/Protocol"),Progression=progression,Settlement=require("../src/server/Services/SettlementService")(C,economy,U),LaunchRewards=rewards})
 local function make():any local h=harness(schema,nil,nil,nil,commands);eq(h.service.Load(1,"launch"),"OK");return h end
 test("launch daily uncertain commits recover exactly once before and after write",function()
  for _,mode in ipairs({"before","after"})do
   local h=make();local before=h.data().inventory.stacks.herb or 0;h.mode=mode
   eq(h.send("ClaimDailyReward"),"SavePending");eq(h.data().launchRewards,nil)
   h.mode="ok";eq(h.service.Refresh(1),"OK")
   eq(h.data().inventory.stacks.herb,before+2);eq(h.data().launchRewards.daily.claims,1)
   eq(h.send("ClaimDailyReward"),"DailyAlreadyClaimed")
   eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"rejoined"),"OK")
   eq(h.send("ClaimDailyReward"),"DailyAlreadyClaimed");eq(h.data().inventory.stacks.herb,before+2)
  end
 end)
 test("launch daily callback replay and simulated crash retain one award",function()
  local h=make();h.replayCallback=true;h.mode="after"
  eq(h.send("ClaimDailyReward"),"SavePending");h.now+=181;h.mode="ok";h.service=h.make()
  eq(h.service.Load(1,"replacement"),"OK");eq(h.data().launchRewards.daily.claims,1)
  eq(h.send("ClaimDailyReward"),"DailyAlreadyClaimed")
 end)
 test("launch corrupt receipts reject load without resetting data",function()
  local h=make();eq(h.send("ClaimDailyReward"),"OK");eq(h.service.Close(1),"OK")
  h.records["p:1"].data.launchRewards.daily.claims=-1
  local before=U.copy(h.records["p:1"]);h.service=h.make()
  assert(h.service.Load(1,"corrupt")~="OK");eq(h.records["p:1"],before)
 end)
 test("launch projection exposes display rewards without stored claim receipts",function()
  local h=make();eq(h.send("ClaimDailyReward"),"OK")
  local project=require("../src/server/Systems/ViewProjection")(C,progression,U,nil,nil,nil,nil,nil,nil,nil,{Release={Enabled=false},Rewards=rewards})
  local v=project(h.service.Sessions[1],"Memory",h.now)
  eq(v.data.launchRewards.season,nil);eq(v.data.launchRewards.daily.lastClaimDay,nil);eq(v.data.launchRewards.daily.claimable,false)
  eq(v.data.settlement.purchases,nil)
 end)
 test("release projection derives actor-specific gates and retains the full catalog",function()
  local h=make();local d=h.data();d.character.classId="Warrior"
  d.progression.ruleset=C.ProgressionRulesets.Novice;d.progression.campaign={claimed=0}
  d.adventurers["h:fixture"]={classId="Warrior"}
  local before=U.copy(d)
  local release=require("../src/server/Systems/ReleasePolicy")(require("../src/server/Config/ReleaseContent")).resolve({LaunchCandidate=true,StudioPersistence="Memory"},{isStudio=true,placeId=0,gameId=0})
  local project=require("../src/server/Systems/ViewProjection")(C,{stats=function()return {}end},U,E,nil,nil,nil,nil,nil,nil,{Release=release})
  local v=project(h.service.Sessions[1],"Memory",h.now)
  eq(v.data.releaseAdvancementProblems.player.berserker,"ClassMentorRequired")
  eq(v.data.releaseAdvancementProblems["h:fixture"].berserker,"HeroMentorRequired")
  eq(v.data.releaseAdvancementProblems.player.warlord,"ReleaseContentUnavailable")
  eq(v.catalog.ReleaseContent.BlockedTasks.ashen_watch,true);eq(v.catalog.ReleaseContent.TowerUnavailable,true)
  eq(v.catalog.ReleaseContent.BlockedZones.Ashen,true);eq(v.catalog.ReleaseContent.BlockedZones.Greenwood,nil)
  eq(v.catalog.ReleaseContent.BlockedNodes.ashen_stone,true);eq(v.catalog.ReleaseContent.BlockedNodes.ore,nil)
  assert(v.catalog.Journal.ashen_watch and v.catalog.Expansion.Paths.warlord)
  eq(d,before)
 end)
 test("historical story progress beyond active release displays completion without mutation",function()
  local chapter=require("../src/server/Config/CampaignSequence")({require("../src/server/Config/ChapterOne"),require("../src/server/Config/ChapterTwo")})
  local data={progression={novice={claimed=6},campaign={claimed=18,hallPermit=6}},language="en"}
  data.settlement={journal={}};data.progression.tutorialStep="complete";data.hallLevel=6
  local before=U.copy(data)
  eq(require("../src/shared/Data/CampaignViewState")(data,{CampaignChapter=chapter},false).stage,"Complete");eq(data,before)
  eq(require("../src/shared/Data/QuestTracker")(data,{CampaignChapter=chapter,Journal={},JournalOrder={}},nil).kind,"CampaignComplete");eq(data,before)
 end)
end
