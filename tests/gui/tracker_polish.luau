--!nocheck
-- Native instance/state contracts only; not a renderer or glyph-fit assertion.
local Tracker=require(getfenv().UI.QuestTrackerView)
local passed=0
local function test(name,run)run();passed+=1;print("PASS tracker polish "..name)end
local function fixture(w,h)
 local gui=Instance.new("ScreenGui");gui.AbsoluteSize={X=w or 1024,Y=h or 768}
 local tracker=Tracker(gui)
 return gui,tracker,function(name)return assert(tracker.button:FindFirstChild(name),name)end
end
test("native seal remains meaningful without images and ready state changes its silhouette",function()
 local gui,t,find=fixture()
 t.update({ready=false,progress=2,count=5},"Tracked quest","Woodland Debt 2/5",true)
 assert(find("QuestSeal").Visible and find("QuestMarkStem").Visible and find("QuestMarkDot").Visible)
 assert(find("QuestRibbon").Visible and not find("ReadyCheckLeft").Visible)
 local image=find("Quality_questIcon");image.IsLoaded=true;image:GetPropertyChangedSignal("IsLoaded"):Fire()
 assert(not find("QuestMarkStem").Visible and image.Visible)
 t.update({ready=true,progress=5,count=5},"Ready to claim","Woodland Debt 5/5",true)
 assert(find("ReadyCheckLeft").Visible and find("ReadyCheckRight").Visible and not image.Visible)
 assert(find("TrackedProgress"):GetChildren()[1].Size[1]==1)
 t.update(nil,"Quest journal","Open journal",true)
 assert(not find("ReadyCheckLeft").Visible and not find("TrackedProgress").Visible)
 gui:Destroy()
end)
test("focus is visible only for enabled controls and callbacks detach on destruction",function()
 local gui,t,find=fixture();local rim=find("TrackerRim")
 t.update({},"Tracked quest","Objective",true);t.button.SelectionGained:Fire();assert(rim.Thickness==2)
 t.update({},"Tracked quest","Objective",false);assert(rim.Thickness==1 and not t.button.Active and not t.button.Selectable)
 t.button.MouseEnter:Fire();assert(rim.Thickness==1)
 t.button:Destroy();local thickness=rim.Thickness
 t.button.SelectionLost:Fire();t.button.MouseLeave:Fire();assert(rim.Thickness==thickness)
 gui:Destroy()
end)
test("796 compact has quest clasp heading and open affordance within the existing header",function()
 local gui,t,find=fixture(796,674)
 for _,copy in ipairs({"Defeat the Greenwood Archer","กำจัดพลธนูกรีนวูด"})do
  t.update({ready=false},"Tracked quest",copy,true)
  assert(find("TrackerObjective").Text==copy and find("TrackerObjective").TextSize==14)
  assert(find("TrackerHeading").Visible and find("TrackerObjective").Position[2]==42)
  assert(find("QuestSeal").Visible and find("QuestRibbon").Visible and find("QuestMarkStem").Visible)
  assert(find("CompactHeadingRule").Visible and find("OpenQuestUpper").Visible)
  assert(t.button.Size[4]==50 and t.button.Position[4]==7)
 end
 gui:Destroy()
end)

test("minimum phone gives both text lines priority while retaining native state silhouettes",function()
 local gui,t,find=fixture(320,568)
 local value="ตามร่องรอยเสบียงทั้งสามจุด"
 t.update({progress=1,count=3},"Tracked quest",value,true)
 assert(not find("TrackerHeading").Visible and find("QuestSeal").Visible and find("QuestRibbon").Visible)
 assert(find("TrackerObjective").Position[2]==6 and find("TrackerObjective").Size[2]==-12)
 assert(find("TrackerObjective").Size[4]==38 and find("TrackerObjective").TextSize==13)
 assert(find("TrackerObjective").Text==value and find("QuestMarkStem").Visible)
 assert(not find("OpenQuestUpper").Visible and not find("Quality_questIcon").Visible)
 local ratio=find("TrackedProgress"):GetChildren()[1].Size[1];assert(ratio==1/3)
 t.update({ready=true},"Ready to claim",value,true)
 assert(find("ReadyCheckLeft").Visible and not find("QuestMarkStem").Visible and not find("TrackedProgress").Visible)
 t.update({},"Tracked quest",value,false)
 assert(find("QuestDisabledMark").Visible and not t.button.Active and not t.button.Selectable)
 assert(not find("ReadyCheckLeft").Visible and find("TrackerObjective").Text==value)
 t.update({},"Tracked quest",value,true)
 assert(not find("QuestDisabledMark").Visible and find("QuestMarkStem").Visible)
 gui:Destroy()
end)

test("compact to phone to wide reflow preserves state copy and native fallback",function()
 local gui,t,find=fixture(796,674)
 t.update({progress=3,count=5,ready=true},"Ready", "Actual objective 3/5",true)
 for _,size in ipairs({{320,240},{390,844},{796,674},{1366,768}})do
  gui.AbsoluteSize={X=size[1],Y=size[2]};gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
  assert(find("ReadyCheckLeft").Visible and not find("QuestMarkStem").Visible)
  assert(find("TrackerObjective").Text=="Actual objective 3/5")
  assert(find("TrackedProgress"):GetChildren()[1].Size[1]==.6)
 end
 gui:Destroy()
end)
test("nonfinite progress never renders an invented completion bar",function()
 local gui,t,find=fixture()
 for _,state in ipairs({{progress=0/0,count=5},{progress=2,count=math.huge},{progress=math.huge,count=5}})do
  t.update(state,"Tracked quest","Objective",true)
  assert(not find("TrackedProgress").Visible and find("TrackedProgress"):GetChildren()[1].Size[1]==0)
 end
 gui:Destroy()
end)
print(passed.." tracker polish cases passed (simulation only).")
