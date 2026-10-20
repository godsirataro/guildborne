--!nocheck
-- Actual source callbacks and rectangle arithmetic; mock hit lists are not engine pixels.
local Orders=require(getfenv().UI.Components.CompanionOrders)
local Gate=require(getfenv().UI.Components.CombatPointerGate)
local Layout=require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
local Bindings=require(game.ReplicatedStorage.Shared.Config.CombatBindings)
local passed=0
local function test(name,run) run();passed+=1;print("PASS companion orders "..name) end
local function identity(s)return s end
local function fixture()
 local calls={};local gui=Instance.new("ScreenGui")
 local orders=Orders(gui,function(action)table.insert(calls,action)end)
 orders.frame.Visible=true;orders.update(Layout(1210,740),identity,"Keyboard",true,"Hold","Balanced")
 return orders,calls
end
test("six exact actions dispatch once without additional Basic",function()
 local o,calls=fixture()
 local expected={"Focus","Regroup","Retreat","Hold","TacticBalanced","TacticDefensive"}
 assert(#o.buttons==6)
 for i,b in ipairs(o.buttons)do assert(b.Name==expected[i]);b.Activated:Fire();assert(calls[i]==expected[i]);assert(b.BackgroundColor3~=nil)end
 assert(#calls==6);for _,action in ipairs(calls)do assert(action~="Basic")end;o.Destroy()
end)
test("disabled and hidden controls reject activation",function()
 local o,calls=fixture();o.update(Layout(390,844),identity,"Touch",false,nil,nil)
 for _,b in ipairs(o.buttons)do assert(not b.Active and not b.Selectable);b.Activated:Fire()end
 assert(#calls==0);o.update(Layout(390,844),identity,"Touch",true,nil,nil);o.frame.Visible=false
 for _,b in ipairs(o.buttons)do b.Activated:Fire()end;assert(#calls==0);o.Destroy()
end)
test("destroy blocks queued callbacks and further updates",function()
 local o,calls=fixture();local label=o.buttons[1]:FindFirstChild("OrderLabel");local old=label.Text;o.Destroy();o.Destroy()
 for _,b in ipairs(o.buttons)do b.Activated:Fire();b.SelectionGained:Fire()end
 o.update(Layout(320,640),function()return "Changed"end,"Touch",true,"Focus","Defensive")
 assert(#calls==0 and label.Text==old)
end)
test("external frame destruction cleans callbacks",function()
 local o,calls=fixture();o.frame:Destroy();o.buttons[1].Activated:Fire();assert(#calls==0);o.Destroy()
end)
test("selection follows received order and preset without optimistic click selection",function()
 local o=fixture()
 for i,b in ipairs(o.buttons)do assert(b:GetAttribute("SelectedOrder")== (i==4 or i==5))end
 o.buttons[1].Activated:Fire();assert(not o.buttons[1]:GetAttribute("SelectedOrder"))
 o.update(Layout(1210,740),identity,"Keyboard",true,"Regroup","Defensive")
 for i,b in ipairs(o.buttons)do
  local selected=i==2 or i==6;assert(b:GetAttribute("SelectedOrder")==selected)
  assert(b:FindFirstChild("SelectedOrder").Visible==selected)
 end
 o.update(Layout(1210,740),identity,"Keyboard",true,nil,nil)
 for _,b in ipairs(o.buttons)do assert(not b:GetAttribute("SelectedOrder"))end;o.Destroy()
end)
test("hints match real keyboard gamepad and touch bindings",function()
 local o=fixture()
 for _,mode in ipairs({"Keyboard","Gamepad","Touch"})do
  o.update(Layout(390,844),identity,mode,true,nil,nil)
  for _,b in ipairs(o.buttons)do
   local hint=b:FindFirstChild("BindingHint");assert(hint.Text==Bindings.hint(b.Name,mode));assert(hint.Visible==(hint.Text~=""))
   local label=b:FindFirstChild("OrderLabel");assert(label.Size[4]==(if hint.Visible then -19 else -8))
   assert(label.TextScaled and label.TextWrapped and label.TextSize==14)
   local fit=label:FindFirstChild("UITextSizeConstraint");assert(fit.MinTextSize==10 and fit.MaxTextSize==14)
  end
 end;o.Destroy()
end)
test("translated action text is used without changing action IDs",function()
 local o,calls=fixture();o.update(Layout(390,844),function(key)return "TH:"..key end,"Touch",true,nil,nil)
 for _,b in ipairs(o.buttons)do assert(b:FindFirstChild("OrderLabel").Text=="TH:"..b.Name);b.Activated:Fire();assert(calls[#calls]==b.Name)end;o.Destroy()
end)
test("focus neighbours follow three-column and six-column resizing",function()
 local o=fixture()
 for _,size in ipairs({{390,844},{1210,740},{320,640},{1920,1080}})do
  local l=Layout(size[1],size[2]);o.update(l,identity,"Gamepad",true,nil,nil)
  local c=l.orderColumns
  for i,b in ipairs(o.buttons)do
   local col=(i-1)%c;local row=math.floor((i-1)/c)
   assert(b.NextSelectionLeft==(if col>0 then o.buttons[i-1] else nil))
   assert(b.NextSelectionRight==(if col<c-1 and i<6 then o.buttons[i+1] else nil))
   assert(b.NextSelectionUp==(if row>0 then o.buttons[i-c] else nil))
   assert(b.NextSelectionDown==(if i+c<=6 then o.buttons[i+c] else nil))
  end
 end;o.Destroy()
end)
for _,size in ipairs({{320,640},{390,844},{1210,740},{1920,1080},{844,390}})do
 test("all six targets within dock and at least 44px at "..size[1].."x"..size[2],function()
  local o=fixture();local l=Layout(size[1],size[2]);o.update(l,identity,"Keyboard",true,nil,nil)
  local r=l.ordersRect;assert(r.x>=0 and r.y>=0 and r.x+r.w<=size[1]+.001 and r.y+r.h<=size[2]+.001)
  for i,b in ipairs(o.buttons)do
   local x,y,w,h=b.Position[2],b.Position[4],b.Size[2],b.Size[4]
   assert(w>=44 and h>=44,"small target "..b.Name)
   assert(x>=0 and y>=0 and x+w<=r.w+.001 and y+h<=r.h+.001,"outside dock")
   local hint=b:FindFirstChild("BindingHint")
   local hy=hint.Position[3]*h+hint.Position[4]-hint.AnchorPoint.Y*hint.Size[4]
   assert(hy>=0 and hy+hint.Size[4]<=h,"hint outside button")
   local label=b:FindFirstChild("OrderLabel");local ly=label.Position[4];local lh=label.Size[3]*h+label.Size[4]
   assert(ly>=0 and ly+lh<=h,"action text outside button")
   if hint.Visible then assert(ly+lh<=hy,"action text overlaps keyboard hint")end
   for j=1,i-1 do local a=o.buttons[j];assert(not(x<a.Position[2]+a.Size[2] and a.Position[2]<x+w and y<a.Position[4]+a.Size[4] and a.Position[4]<y+h),"targets overlap")end
  end;o.Destroy()
 end)
end
test("processed input returns before accessing GUI or position",function()
 assert(Gate(nil,{},true))
end)
test("pointer hit lists block active UI and permit ornaments and world",function()
 local hits={};local queries=0
 local gui={GetGuiObjectsAtPosition=function(_,x,y)queries+=1;assert(x==42 and y==24);return hits end}
 for _,kind in ipairs({Enum.UserInputType.MouseButton1,Enum.UserInputType.Touch})do
  local input={UserInputType=kind,Position={X=42,Y=24}}
  hits={{Active=false},{Active=true}};assert(Gate(gui,input,false))
  hits={{Active=false}};assert(not Gate(gui,input,false))
  hits={};assert(not Gate(gui,input,false))
 end;assert(queries==6)
end)
test("unprocessed keyboard and gamepad bypass pointer queries",function()
 for _,kind in ipairs({Enum.UserInputType.Keyboard,Enum.UserInputType.Gamepad1})do
  assert(not Gate(nil,{UserInputType=kind},false))
 end
end)
test("attribute change signal fires only on changed values",function()
 local n=Instance.new("Frame");local count=0;local c=n:GetAttributeChangedSignal("SelectedOrder"):Connect(function()count+=1 end)
 n:SetAttribute("SelectedOrder",false);n:SetAttribute("SelectedOrder",false);n:SetAttribute("SelectedOrder",true);assert(count==2)
 c:Disconnect();n:SetAttribute("SelectedOrder",false);assert(count==2);n:Destroy()
end)
print("COMPANION_ORDERS_TESTS "..passed.." passed; simulation only")
