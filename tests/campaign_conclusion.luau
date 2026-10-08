--!strict
return function(test:any,eq:any)
 local describe=require("../src/shared/Data/CampaignViewState")
 local track=require("../src/shared/Data/QuestTracker")
 local compose=require("../src/server/Config/CampaignSequence")
 local arcs:{any}={require("../src/server/Config/ChapterOne"),require("../src/server/Config/ChapterTwo"),require("../src/server/Config/ChapterThree"),require("../src/server/Config/ChapterFour"),require("../src/server/Config/ChapterFive"),require("../src/server/Config/ChapterSix")}
 test("completed previews name their own milestone and only the actual finale is final",function()
  local selected={}
  for i,arc in ipairs(arcs)do
   table.insert(selected,arc);local config=compose(selected)
   for _,language in ipairs({"en","th"})do
    local d:any={language=language,hallLevel=17,settlement={journal={}},progression={tutorialStep="complete",novice={claimed=6},campaign={claimed=#config.Chapters,objectives={}}}}
    local c={CampaignChapter=config,JournalOrder={"side"},Journal={side={Name="Side quest",Count=1}}}
    local view=describe(d,c,false);eq(view.stage,"Complete");eq(view.total,i*6);eq(view.finale,i==6)
    eq(view.title,if language=="th"then config.Chapters[i*6].Thai else config.Chapters[i*6].Title)
    local tracker=track(d,c,nil);eq(tracker.kind,"CampaignComplete");eq(tracker.name,view.title);eq(tracker.focus,"CampaignJourney");eq(tracker.ready,false)
    d.settlement.journal.side={state="Active",progress=0};eq(track(d,c,"side").id,"side");eq(track(d,c,nil).kind,"Active")
   end
  end
 end)
 test("empty campaign does not claim a completed journey",function()
  eq(describe({progression={novice={claimed=6},campaign={claimed=0}}},{CampaignChapter={Chapters={}}},false).stage,"Unavailable")
 end)
end

