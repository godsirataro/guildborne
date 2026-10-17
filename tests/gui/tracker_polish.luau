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
test("compact EN TH copy retains its text rectangle and hides the large ornament",function()
 local gui,t,find=fixture(796,674)
 for _,copy in ipairs({"Defeat the Greenwood Archer","กำจัดพลธนูกรีนวูด"})do
  t.update({ready=false},"Tracked quest",copy,true)
  assert(find("TrackerObjective").Text==copy and find("TrackerObjective").TextSize==14)
  assert(find("TrackerObjective").Position[2]==6 and find("TrackerObjective").Size[2]==-12)
  assert(not find("QuestSeal").Visible and not find("QuestRibbon").Visible and not find("QuestMarkStem").Visible)
  assert(t.button.Size[4]==44 and t.button.Position[4]==10)
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
