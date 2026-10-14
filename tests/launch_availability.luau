--!strict
return function(test:any,eq:any)
 local U=require("../src/shared/Util/TableUtil")
 local Journal=require("../src/shared/Data/JournalViewState")
 local Npc=require("../src/shared/Data/QuestNpcState")
 local Tracker=require("../src/shared/Data/QuestTracker")
 local function fixture(): (any,any)
  return {settlement={journal={}},inventory={stacks={}},progression={tutorialStep="complete"}},
   {Journal={future={NPC="Guide",Name="Future",Description="Later",Count=2,Item="stone"}},JournalOrder={"future"},RegionalCombatAvailable=true,ReleaseContent={BlockedTasks={future=true}}}
 end
 test("release UI suppresses new future quest offers across journal NPC and tracker",function()
  local d,c=fixture();local before=U.copy(d)
  local j=Journal.describe(d,c,"future");eq(j.locked,true);eq(j.releaseUnavailable,true);eq(Journal.matches(j,"Available"),false)
  eq(Npc(d,c,"Guide"),nil);eq(Tracker(d,c,nil),nil);eq(d,before)
 end)
 test("release UI retains earned future quest turn-in and claimed history",function()
  local d,c=fixture();d.settlement.journal.future={state="Active",progress=0};d.inventory.stacks.stone=2
  local before=U.copy(d);local j=Journal.describe(d,c,"future")
  eq(j.ready,true);eq(j.locked,false);eq(Npc(d,c,"Guide").state,"Ready to turn in");eq(Tracker(d,c,"future").ready,true);eq(d,before)
  d.settlement.journal.future.state="Claimed";d.inventory.stacks={}
  eq(Journal.describe(d,c,"future").state,"Claimed")
 end)
 test("release availability does not change unrestricted previews",function()
  local d,c=fixture();c.ReleaseContent=nil
  eq(Journal.describe(d,c,"future").locked,false);eq(Npc(d,c,"Guide").state,"Quest available");eq(Tracker(d,c,nil).kind,"Available")
 end)
end
