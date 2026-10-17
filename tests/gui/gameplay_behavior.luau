--!nocheck
-- Executes actual GUI modules in the callback simulation; no pixel/layout claims.
local UI=getfenv().UI
local Journal=require(UI.Components.JournalPane)
local Asset=require(UI.Components.QualityAsset)
local Tracker=require(UI.QuestTrackerView)
local passed=0
local function test(name,run) run();passed+=1;print("PASS gameplay GUI "..name) end
local function find(parent,name)
 if parent.Name==name then return parent end
 for _,child in ipairs(parent:GetChildren()) do local result=find(child,name);if result then return result end end
 return nil
end
local function definition(id,extra)
 local def={Name=id,Description="A real objective",Category="Main",Count=3,Gold=12,XP=9}
 for k,v in pairs(extra or {}) do def[k]=v end
 return def
end
local function fixture(defs,order,tasks,busy,focus)
 local data={settlement={journal=tasks or {}},inventory={stacks={}}}
 local catalog={Journal=defs,JournalOrder=order}
 local calls,tracked={},{}
 local ui={scroll=Instance.new("Frame"),T=function(value) return value end,language=function()return "en"end,
  journalFocus=function() return focus end,isTracked=function()return false end,
  trackQuest=function(id)table.insert(tracked,id)end,act=function(action,args)table.insert(calls,{action=action,args=args})end}
 local draw=Journal(ui)
 local function render()
  ui.scroll:Destroy();ui.scroll=Instance.new("Frame");draw(data,catalog,busy)
 end
 ui.render=render
 render()
 return {ui=ui,data=data,catalog=catalog,calls=calls,tracked=tracked,render=render,destroy=function()ui.scroll:Destroy()end}
end
test("accept dispatches canonical intent and disabled busy guards remain closed",function()
 local f=fixture({q=definition("q")},{"q"})
 local accept=assert(find(f.ui.scroll,"Accept_q"));accept.Activated:Fire()
 assert(#f.calls==1 and f.calls[1].action=="AcceptTask" and f.calls[1].args.questId=="q")
 f.destroy();accept.Activated:Fire();assert(#f.calls==1)
 local busy=fixture({q=definition("q")},{"q"},nil,true)
 local blocked=find(busy.ui.scroll,"Accept_q");assert(not blocked.Active and not blocked.Selectable)
 blocked.Activated:Fire();assert(#busy.calls==0);busy.destroy()
end)
test("prerequisite and release locks never dispatch acceptance",function()
 local f=fixture({q=definition("q",{Requires="prior"}),prior=definition("prior")},{"q"})
 local accept=find(f.ui.scroll,"Accept_q");assert(not accept.Active);accept.Activated:Fire();assert(#f.calls==0)
 f.data.settlement.journal.prior={state="Claimed"};f.render();assert(find(f.ui.scroll,"Accept_q").Active)
 f.catalog.ReleaseContent={BlockedTasks={q=true}};f.render()
 accept=find(f.ui.scroll,"Accept_q");assert(not accept.Active);accept.Activated:Fire();assert(#f.calls==0);f.destroy()
end)
test("incomplete claim and busy ready claim stay disabled",function()
 for _,scenario in ipairs({{progress=2,busy=false},{progress=3,busy=true}}) do
  local f=fixture({q=definition("q")},{"q"},{q={state="Active",progress=scenario.progress}},scenario.busy)
  local claim=assert(find(f.ui.scroll,"Claim_q"));assert(not claim.Active);claim.Activated:Fire();assert(#f.calls==0)
  if scenario.busy then find(f.ui.scroll,"Track_q").Activated:Fire();assert(#f.tracked==0) end
  f.destroy()
 end
end)
test("ready claim uses server stock and never mutates inventory locally",function()
 local f=fixture({q=definition("q",{Item="Herb"})},{"q"},{q={state="Active",progress=3}})
 assert(not find(f.ui.scroll,"Claim_q").Active)
 f.data.inventory.stacks.Herb=3;f.render()
 local claim=find(f.ui.scroll,"Claim_q");assert(claim.Active);claim.Activated:Fire()
 assert(#f.calls==1 and f.calls[1].action=="ClaimTask" and f.calls[1].args.questId=="q")
 assert(f.data.inventory.stacks.Herb==3 and f.data.settlement.journal.q.state=="Active")
 find(f.ui.scroll,"Track_q").Activated:Fire();assert(f.tracked[1]=="q");f.destroy()
end)
test("claimed tasks expose no accept or claim controls",function()
 local f=fixture({q=definition("q")},{"q"},{q={state="Claimed"}})
 assert(not find(f.ui.scroll,"Claim_q") and not find(f.ui.scroll,"Accept_q"))
 assert(find(f.ui.scroll,"JournalProgress").Text=="Claimed  ·  3 / 3");f.destroy()
end)
test("empty category renders real empty-state and stale callbacks disconnect",function()
 local f=fixture({q=definition("q")},{"q"})
 local prior=find(f.ui.scroll,"Accept_q")
 find(f.ui.scroll,"Category_Side").Activated:Fire()
 assert(find(f.ui.scroll,"EmptyState_no_quests"));prior.Activated:Fire();assert(#f.calls==0);f.destroy()
end)
test("narrow journal selection and back change list-detail state",function()
 local f=fixture({q=definition("q")},{"q"})
 local body=find(f.ui.scroll,"JournalLayout");body.AbsoluteSize={X=390,Y=400};body:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 assert(find(f.ui.scroll,"QuestList").Visible and not find(f.ui.scroll,"Journal_q").Visible)
 find(f.ui.scroll,"SelectQuest_q").Activated:Fire()
 body=find(f.ui.scroll,"JournalLayout");body.AbsoluteSize={X=390,Y=400};body:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 assert(not find(f.ui.scroll,"QuestList").Visible and find(f.ui.scroll,"Journal_q").Visible)
 find(f.ui.scroll,"JournalBackToList").Activated:Fire()
 body=find(f.ui.scroll,"JournalLayout");body.AbsoluteSize={X=390,Y=400};body:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 assert(find(f.ui.scroll,"QuestList").Visible)
 local size=body.Size;f.destroy();body:GetPropertyChangedSignal("AbsoluteSize"):Fire();assert(body.Size==size)
end)
test("asset key and slice metadata exist at parenting without runtime IDs",function()
 local parent=Instance.new("Frame");local observed=0
 local connection=parent.ChildAdded:Connect(function(child)
  assert(type(child:GetAttribute("QualityAssetKey"))=="string" and child.Image=="")
  if child:GetAttribute("QualityAssetKey")=="panelBorder" then assert(child.SliceCenter and child.ScaleType==Enum.ScaleType.Slice) end
  observed+=1
 end)
 local border=Asset.create(parent,"panelBorder");local icon=Asset.create(parent,"questIcon")
 assert(not border.Active and border.BackgroundTransparency==1 and icon.ScaleType==Enum.ScaleType.Fit and observed==2)
 connection:Disconnect();parent:Destroy()
end)
test("tracker maps progress ready state availability and missing data",function()
 local gui=Instance.new("ScreenGui");local tracker=Tracker(gui)
 tracker.update({progress=2,count=4,ready=false},"Journal","Gather herbs",true)
 local track=find(tracker.button,"TrackedProgress");local fill=track:GetChildren()[1]
 assert(track.Visible and fill.Size[1]==.5 and tracker.button.Active and tracker.button.Selectable)
 assert(find(tracker.button,"TrackerObjective").Text=="Gather herbs")
 tracker.update({progress=8,count=4,ready=true},"Journal","Ready",false)
 assert(fill.Size[1]==1 and not tracker.button.Active and not tracker.button.Selectable)
 tracker.update(nil,"Journal","No objective",true);assert(not track.Visible and fill.Size[1]==0)
 gui:Destroy()
end)
test("tracker resize responds before destruction and disconnects afterwards",function()
 local gui=Instance.new("ScreenGui");gui.AbsoluteSize={X=1024,Y=768};local tracker=Tracker(gui)
 assert(find(tracker.button,"TrackerHeading").Visible)
 gui.AbsoluteSize={X=390,Y=844};gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 assert(not find(tracker.button,"TrackerHeading").Visible)
 local position=tracker.button.Position;tracker.button:Destroy()
 gui.AbsoluteSize={X=1366,Y=768};gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 assert(tracker.button.Position==position);gui:Destroy()
end)
test("796x617 tracker root outranks later HUD subtree with explicit local content layers",function()
 local gui=Instance.new("ScreenGui");gui.AbsoluteSize={X=796,Y=617};gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 local tracker=Tracker(gui)
 local laterHud=Instance.new("Frame");laterHud.ZIndex=1;laterHud.Parent=gui
 local hudBorder=Instance.new("ImageLabel");hudBorder.ZIndex=3;hudBorder.Parent=laterHud
 assert(tracker.button.Parent==gui and tracker.button.ZIndex==5 and tracker.button.ZIndex>laterHud.ZIndex)
 assert(tracker.button.ZIndex<10,"Tracker stays below the management modal contract")
 local border=find(tracker.button,"Quality_panelBorder")
 local objective=find(tracker.button,"TrackerObjective")
 local heading=find(tracker.button,"TrackerHeading")
 local icon=find(tracker.button,"Quality_questIcon")
 local progress=find(tracker.button,"TrackedProgress")
 assert(border.ZIndex==1 and objective.ZIndex>border.ZIndex and heading.ZIndex>border.ZIndex)
 assert(icon.ZIndex>border.ZIndex and progress.ZIndex>border.ZIndex)
 assert(not heading.Visible and tracker.button.Size[4]==44)
 assert(objective.TextSize==14,"Medium-width quest copy must not use phone-size text")
 gui:Destroy()
end)
test("tracker placement reserves gold and menu regions across compact and wide boundaries",function()
 -- Resolve assigned UDim2 geometry only: this does not simulate engine rendering.
 local function pixels(value,w,h) return value[1]*w+value[2],value[3]*h+value[4] end
 for _,size in ipairs({{320,280},{360,640},{390,844},{796,617},{899,617},{900,559},{900,560},{1366,768}}) do
  local w,h=size[1],size[2]
  local gui=Instance.new("ScreenGui");gui.AbsoluteSize={X=w,Y=h};local tracker=Tracker(gui)
  local bw,bh=pixels(tracker.button.Size,w,h)
  local x,y=pixels(tracker.button.Position,w,h)
  x-=tracker.button.AnchorPoint.X*bw;y-=tracker.button.AnchorPoint.Y*bh
  assert(bw>=44 and bh>=44 and x>=0 and y>=0 and x+bw<=w and y+bh<=h)
  local wide=w>=900 and h>=560
  assert(find(tracker.button,"TrackerHeading").Visible==wide)
  if wide then
   assert(y>=58 and bw==300 and bh==96,"Expanded tracker must sit below top bar")
  else
   local goldRight=8+12+.3*(w-16)-8
   local menuLeft=8+(w-16)-100
   assert(x>=goldRight+8-.001 and x+bw<=menuLeft-8+.001,"Compact tracker overlaps HUD controls")
   assert(y==10 and bh==44 and y+bh<=58)
   assert(find(tracker.button,"TrackerObjective").TextSize==(if bw>=200 then 14 else 12))
  end
  gui:Destroy()
 end
end)
test("party identity health and portrait ornament keep separate bounded lanes",function()
 local Chrome=require(UI.Components.CombatChrome)
 for _,size in ipairs({{90,44},{96,44},{138,44},{184,60}}) do
  local w,h=size[1],size[2];local card=Instance.new("TextButton");card.Size=UDim2.fromOffset(w,h)
  local chrome=Chrome.actor(card);chrome.layout(w,h)
  local name=chrome.name;local hp=find(card,"ActorHealth");local mount=find(card,"PortraitMount")
  for _,text in ipairs({"Player","นักผจญภัยแห่งรุ่งอรุณ"}) do
   name.Text=text;chrome.update(true,6,127,200)
   assert(name.Text==text and hp.Text=="127 HP" and not name.TextWrapped)
   assert(name.TextSize==(if w<110 then 12 else 13) and hp.TextSize==10)
   assert(name.ZIndex>mount.ZIndex and hp.ZIndex>mount.ZIndex)
   assert(name.Position[2]>mount.Position[2]+mount.Size[2])
   assert(name.Position[4]+name.Size[4]<=hp.Position[4])
   assert(hp.Position[4]+hp.Size[4]<=h-8)
   assert(name.Position[2]+name.Size[1]*w+name.Size[2]<=w-4)
  end
  assert(find(card,"SelectedActorGem").Visible and find(card,"SelectedActorRibbon").Visible)
  assert(find(card,"ActorSlot").Text=="6" and find(card,"CurrentHealth").Size[1]==127/200)
  chrome.update(false,1,0,200)
  assert(not find(card,"SelectedActorGem").Visible and not find(card,"SelectedActorRail").Visible)
  assert(hp.Text=="0 HP" and find(card,"CurrentHealth").Size[1]==0)
  chrome.update(false,1,nil,nil);assert(not find(card,"HealthTrack").Visible and hp.Text=="– HP")
  card:Destroy()
 end
end)
test("six tall party cards reserve separate name health and control regions",function()
 local layoutFor=require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
 local Chrome=require(UI.Components.CombatChrome)
 for _,size in ipairs({{390,844},{360,800},{320,760},{900,640},{1366,768}}) do
  local w,h=size[1],size[2];local layout=layoutFor(w,h)
  assert(layout.cardHeight==68 and layout.selectionHeight==5*layout.cardStride+layout.cardHeight)
  assert(64+layout.selectionHeight<=h-layout.ordersBottom-44)
  if w<500 then assert(8+layout.cardWidth<w-8-layout.padWidth) end
  for i=1,6 do
   local card=Instance.new("TextButton");local chrome=Chrome.actor(card);chrome.layout(layout.cardWidth,layout.cardHeight)
   local name=chrome.name;local hp=find(card,"ActorHealth")
   for _,text in ipairs({"Rowan of the Silver Forest","โรแวนผู้พิทักษ์พงไพร"}) do
    name.Text=text;chrome.update(i==6,i,18,160)
    assert(name.Text==text and name.TextWrapped and name.TextSize==15 and name.Size[4]==36)
    assert(name.Position[4]+name.Size[4]<=hp.Position[4])
    assert(hp.Position[4]+hp.Size[4]<=layout.cardHeight-8 and hp.TextSize==12)
    assert(find(card,"SelectedActorGem").Visible==(i==6))
   end
   chrome.layout(138,44);assert(not name.TextWrapped and name.TextSize==13 and hp.TextSize==10)
   card:Destroy()
  end
 end
 assert(layoutFor(390,759).cardHeight==44,"Short portraits retain compact roster")
end)
test("portrait combat pad clears map while compact and centered layouts stay unchanged",function()
 local layoutFor=require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
 for _,size in ipairs({{390,844},{320,760},{360,640},{390,570},{499,760}}) do
  local w,h=size[1],size[2];local layout=layoutFor(w,h)
  assert(layout.portrait and not layout.compact and layout.topAligned)
  assert(layout.padTop==116 and layout.padTop>=60+48+8,"Map must clear attack by 8px")
  assert(layout.padTop+layout.padHeight<=h-layout.ordersBottom-44,"Pad must clear orders")
 end
 for _,size in ipairs({{796,400},{844,390},{390,449},{390,569},{600,319}}) do
  local layout=layoutFor(size[1],size[2])
  assert(layout.compact and layout.topAligned and layout.padTop==64)
  assert(layout.padHeight==108,"Compact skill pad geometry changed")
 end
 local desktop=layoutFor(1366,768)
 assert(not desktop.topAligned and desktop.padTop==64 and desktop.padHeight==232)
end)
print(passed.." gameplay GUI behavior tests passed (simulation only).")
