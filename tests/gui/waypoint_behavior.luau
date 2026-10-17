--!nocheck
-- Actual WaypointBeacon source, simulated state and callbacks only; no rendered pixels.
local UI=getfenv().UI
local Beacon=require(UI.Components.WaypointBeacon)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local CombatLayout=require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
local passed=0
local function test(name,run) run();passed+=1;print("PASS waypoint GUI "..name) end
local function fixture(width,height)
 local gui=Instance.new("ScreenGui");gui.AbsoluteSize={X=width or 796,Y=height or 617}
 local api=Beacon(gui)
 return {gui=gui,api=api,card=gui:FindFirstChild("NextWaypoint"),marker=gui:FindFirstChild("WaypointBeacon")}
end
local function target()
 local world=Instance.new("Folder");local anchor=Instance.new("Part")
 anchor.Position=Vector3.new(10,20,30);anchor.Parent=world
 return {anchor=anchor,x=14,y=25,z=36,name="Guild",destinationName="Guild",stepLabel="Next waypoint"}
end
test("inactive and unavailable routes show no false anchored marker",function()
 local f=fixture();f.api.update(nil,nil,false,"en")
 assert(not f.card.Visible and not f.marker.Enabled and f.marker.Adornee==nil)
 f.api.update(nil,nil,true,"en")
 assert(f.card.Visible and not f.marker.Enabled and f.marker.Adornee==nil)
 assert(f.card:FindFirstChild("NextInstruction").Text==Locale.translate("en","Route unavailable"))
 assert(f.card:FindFirstChild("NextDistance").Text=="");f.api.destroy()
end)
test("actual anchor receives world-relative coordinates and live labels",function()
 local f=fixture();local t=target();f.api.update(t,42,false,"en")
 assert(f.card.Visible and f.marker.Enabled and f.marker.Adornee==t.anchor)
 local offset=f.marker.StudsOffsetWorldSpace
 assert(offset.X==4 and offset.Y==8.5 and offset.Z==6)
 assert(f.card:FindFirstChild("FinalDestination").Text==Locale.translate("en","Guild"))
 assert(f.card:FindFirstChild("NextDistance").Text==Locale.translate("en","{distance} studs",{distance=42}))
 assert(t.anchor.Position.X==10 and t.anchor.Position.Y==20 and #t.anchor.Parent:GetChildren()==1,"Presentation cannot mutate or create world parts")
 f.api.destroy()
end)
test("replacement missing and removed anchors never retain previous marker",function()
 local f=fixture();local first=target();f.api.update(first,12,false,"en")
 local next=target();next.x=21;f.api.update(next,8,false,"en")
 assert(f.marker.Adornee==next.anchor and f.marker.Adornee~=first.anchor and f.marker.StudsOffsetWorldSpace.X==11)
 next.anchor=nil;f.api.update(next,nil,false,"en")
 assert(not f.marker.Enabled and f.marker.Adornee==nil and f.card:FindFirstChild("NextDistance").Text=="")
 next=target();next.anchor.Parent=nil;f.api.update(next,3,false,"en")
 assert(not f.marker.Enabled and f.marker.Adornee==nil)
 f.api.update(first,12,false,"en");f.api.update(first,12,true,"en")
 assert(not f.marker.Enabled and f.marker.Adornee==nil)
 f.api.update(nil,nil,false,"en");assert(not f.card.Visible);f.api.destroy()
end)
test("Thai instructions and distances use actual localization",function()
 local f=fixture();local t=target();f.api.update(t,0,false,"th")
 assert(f.card:FindFirstChild("NextInstruction").Text==Locale.translate("th","Next waypoint"))
 assert(f.card:FindFirstChild("FinalDestination").Text==Locale.translate("th","Guild"))
 assert(f.card:FindFirstChild("NextDistance").Text==Locale.translate("th","{distance} studs",{distance=0}))
 f.api.update(nil,nil,true,"th")
 assert(f.card:FindFirstChild("NextInstruction").Text==Locale.translate("th","Route unavailable"))
 f.api.destroy()
end)
test("waypoint placement avoids actual combat regions or hides when no safe card space exists",function()
 local f=fixture()
 f.api.update(target(),12,false,"en")
 local function separate(a,b)
  return a.x+a.w<=b.x or b.x+b.w<=a.x or a.y+a.h<=b.y or b.y+b.h<=a.y
 end
 for _,size in ipairs({{320,280},{390,844},{599,449},{500,600},{500,640},{599,570},{600,400},{796,400},{600,450},{796,674},{796,617},{1366,768}}) do
  local w,h=size[1],size[2];f.gui.AbsoluteSize={X=w,Y=h};f.gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
  if f.card:GetAttribute("LayoutUnavailable")==true then
   assert(not f.card.Visible,"Unavailable card layout must not cover existing controls")
   continue
  end
  assert(f.card.Visible,"An active route must return when safe layout space exists")
  local p,s=f.card.Position,f.card.Size;local bw,bh=s[1]*w+s[2],s[3]*h+s[4]
  local x=p[1]*w+p[2]-bw*f.card.AnchorPoint.X;local y=p[3]*h+p[4]-bh*f.card.AnchorPoint.Y
  assert(x>=0 and y>=58 and x+bw<=w and y+bh<=h)
  assert(f.card:FindFirstChild("FinalDestination").Visible==(h>=450))
  assert(f.card:FindFirstChild("NextDistance").Visible==(h>=450))
  assert(f.card:FindFirstChild("NextInstruction").TextSize==(if w<600 or h<450 then 13 else 15))
  local layout=CombatLayout(w,h)
  local beacon={x=x,y=y,w=bw,h=bh}
  local roster={x=8,y=64,w=layout.selectionWidth,h=layout.selectionHeight}
  local mapButton={x=w-138,y=60,w=130,h=48}
  local pad={x=w-8-layout.padWidth,y=if layout.topAligned then 64 else h*.5-layout.padHeight*.5,w=layout.padWidth,h=layout.padHeight}
  local health={x=w*(1-layout.healthScale)/2,y=h-layout.healthBottom-layout.healthHeight,w=w*layout.healthScale,h=layout.healthHeight}
  local ordersWidth=math.min(w*.9,360)
  local orders={x=(w-ordersWidth)/2,y=h-layout.ordersBottom-44,w=ordersWidth,h=44}
  assert(separate(beacon,roster),"Waypoint overlaps actual combat roster at "..w.."x"..h)
  assert(separate(beacon,mapButton),"Waypoint overlaps map button at "..w.."x"..h)
  assert(separate(beacon,pad),"Waypoint overlaps combat skill pad at "..w.."x"..h)
  assert(separate(beacon,health),"Waypoint overlaps actor health at "..w.."x"..h)
  assert(separate(beacon,orders),"Waypoint overlaps companion orders at "..w.."x"..h)
 end
 f.api.destroy()
end)
test("no-space layout hides only card and restores route visibility on resize",function()
 local f=fixture(320,280);f.api.update(target(),12,false,"en")
 assert(f.card:GetAttribute("LayoutUnavailable")==true and not f.card.Visible)
 assert(f.marker.Enabled,"Authored world marker remains valid when card has no safe screen space")
 f.gui.AbsoluteSize={X=796,Y=674};f.gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 assert(f.card:GetAttribute("LayoutUnavailable")==false and f.card.Visible)
 f.api.update(nil,nil,false,"en")
 f.gui.AbsoluteSize={X=1366,Y=768};f.gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 assert(not f.card.Visible and not f.marker.Enabled,"Resize cannot resurrect an inactive route")
 f.api.destroy()
end)
test("explicit destroy stops resize and later updates with idempotent cleanup",function()
 local f=fixture();f.api.update(target(),5,false,"en")
 local size=f.card.Size;local instruction=f.card:FindFirstChild("NextInstruction").Text
 f.api.destroy();f.api.destroy()
 assert(f.card.destroyed and f.marker.destroyed)
 f.gui.AbsoluteSize={X=320,Y=280};f.gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 f.api.update(nil,nil,true,"th")
 assert(f.card.Size==size and f.card:FindFirstChild("NextInstruction").Text==instruction)
 f.gui:Destroy()
end)
test("GUI destruction stops resize and late route updates",function()
 local f=fixture();f.api.update(target(),5,false,"en")
 local size=f.card.Size;local instruction=f.card:FindFirstChild("NextInstruction").Text
 f.gui:Destroy();assert(f.card.destroyed and f.marker.destroyed)
 f.gui.AbsoluteSize={X=320,Y=280};f.gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 f.api.update(nil,nil,true,"th");f.api.destroy()
 assert(f.card.Size==size and f.card:FindFirstChild("NextInstruction").Text==instruction)
end)
test("destination hints cannot claim a safe next waypoint or retain a world beacon",function()
 local f=fixture();local t=target();f.api.update(t,12,false,"en")
 assert(f.marker.Enabled)
 t.guidance="destination";t.stepLabel="Next waypoint"
 for _,language in ipairs({"en","th"})do
  f.api.update(t,12,false,language)
  assert(f.card.Visible and not f.marker.Enabled and f.marker.Adornee==nil)
  assert(f.card:FindFirstChild("NextInstruction").Text==Locale.translate(language,"Destination direction — follow paths"))
 end
 for _,viewport in ipairs({{360,640},{600,400},{796,400},{796,674},{1280,720}})do
  f.gui.AbsoluteSize={X=viewport[1],Y=viewport[2]};f.gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
  f.api.update(t,12,false,"en",146)
  local hintKey=if viewport[1]<600 then "Bearing only\nUse paths" else "Destination direction — follow paths"
  assert(f.card:FindFirstChild("NextInstruction").Text==Locale.translate("en",hintKey))
  local compass=assert(f.card:FindFirstChild("DestinationCompass"))
  assert(compass.Parent==f.card and compass.Visible and compass.Rotation==146)
  assert(not f.marker.Enabled and f.marker.Adornee==nil,"Destination hint must never create a world beacon")
  local cw,ch=f.card.Size[2],f.card.Size[4]
  local p,s=compass.Position,compass.Size
  local aw,ah=s[1]*cw+s[2],s[3]*ch+s[4]
  local x=p[1]*cw+p[2]-aw*compass.AnchorPoint.X
  local y=p[3]*ch+p[4]-ah*compass.AnchorPoint.Y
  local radius=math.sqrt(aw*aw+ah*ah)/2
  local centerX,centerY=x+aw/2,y+ah/2
  assert(centerX-radius>=0 and centerX+radius<=cw and centerY-radius>=0 and centerY+radius<=ch,"Rotated compass must remain entirely inside card")
  for _,name in ipairs({"NextInstruction","FinalDestination","NextDistance"})do
   local label=f.card:FindFirstChild(name)
   local textRight=label.Position[1]*cw+label.Position[2]+label.Size[1]*cw+label.Size[2]
   assert(textRight<=centerX-radius,"Text must reserve the rotating compass lane")
  end
  f.api.update(t,12,false,"th",146)
  assert(f.card:FindFirstChild("NextInstruction").Text==Locale.translate("th",hintKey))
 end
 t.guidance=nil;f.api.update(t,12,false,"en");assert(f.marker.Enabled)
 assert(not f.card:FindFirstChild("DestinationCompass").Visible)
 for _,name in ipairs({"NextInstruction","FinalDestination","NextDistance"}) do
  assert(f.card:FindFirstChild(name).Size[2]==-20,"Authored route must regain unused compass text lane")
 end
 f.api.destroy()
end)
test("destination compass hides stale directions for missing nonfinite inactive and unavailable states",function()
 local f=fixture();local t=target();t.guidance="destination"
 for _,heading in ipairs({math.huge,-math.huge,0/0}) do
  f.api.update(t,12,false,"en",146);assert(f.card:FindFirstChild("DestinationCompass").Visible)
  f.api.update(t,12,false,"en",heading);assert(not f.card:FindFirstChild("DestinationCompass").Visible)
 end
 f.api.update(t,12,false,"en",146);f.api.update(t,12,false,"en",nil)
 assert(not f.card:FindFirstChild("DestinationCompass").Visible)
 f.api.update(t,12,false,"en",146);f.api.update(nil,nil,false,"en",146)
 assert(not f.card.Visible and not f.card:FindFirstChild("DestinationCompass").Visible)
 f.api.update(t,12,false,"en",146);f.api.update(t,12,true,"en",146)
 assert(not f.card:FindFirstChild("DestinationCompass").Visible and not f.marker.Enabled)
 f.api.destroy()
end)
test("default global ordering keeps card copy above its fill and marker uses native bars",function()
 local f=fixture();f.api.update(target(),12,false,"en")
 for _,name in ipairs({"NextInstruction","FinalDestination","NextDistance"})do
  assert(f.card:FindFirstChild(name).ZIndex>f.card.ZIndex,"Global ordering requires labels above card fill")
 end
 for index=1,2 do
  local bar=f.marker:FindFirstChild("GroundPointer"..index)
  assert(bar and bar.ClassName=="Frame" and bar.Size[2]>0 and bar.Size[4]>0)
 end
 assert(f.marker:FindFirstChild("GroundPointer")==nil,"No font-dependent pointer")
 f.api.destroy()
end)
print(passed.." waypoint GUI behavior tests passed (simulation only).")
