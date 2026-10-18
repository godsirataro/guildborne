--!strict
-- Real presentation modules on a simulated safe-area canvas. No live state/remotes.
local UI=game.StarterPlayer.StarterPlayerScripts.Client.UI
local Current=require(game.StarterPlayer.StarterPlayerScripts.Client.UI.QuestTrackerView)
-- Isolated fixture module, intentionally absent from the live default project.
local fixtureRequire:any=require
local Before=fixtureRequire(UI:WaitForChild("QuestTrackerBefore"))
local Beacon=require(game.StarterPlayer.StarterPlayerScripts.Client.UI.Components.WaypointBeacon)
local Layout=require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
local Theme=require(game.StarterPlayer.StarterPlayerScripts.Client.UI.DesignSystem.Theme)
local gui=Instance.new("ScreenGui");gui.Name="QuestHudReview";gui.ResetOnSpawn=false;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
gui.Parent=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local host=Instance.new("Frame");host.Size=UDim2.fromScale(1,1);host.BackgroundColor3=Theme.Colors.Background;host.Parent=gui
local viewport=Instance.new("ScrollingFrame");viewport.Name="FixtureViewport";viewport.Position=UDim2.fromOffset(0,184);viewport.Size=UDim2.new(1,0,1,-184)
viewport.BackgroundColor3=Color3.fromRGB(30,38,43);viewport.CanvasSize=UDim2.new();viewport.ScrollBarThickness=6;viewport.Parent=host
local sizes={Vector2.new(796,674),Vector2.new(320,568),Vector2.new(320,240),Vector2.new(390,844),Vector2.new(1366,768)}
local modes={"Progress","Ready","Blocked","Empty"}
local sizeIndex,modeIndex=1,1
local before,thai,longCopy,fit,unavailable=false,false,false,false,true
local generation,activationCount=0,0
local alive=true
local canvas:Frame?=nil
local notice=Instance.new("TextLabel");notice.Name="FixtureState";notice.Position=UDim2.fromOffset(6,94);notice.Size=UDim2.new(1,-12,0,86)
notice.BackgroundTransparency=1;notice.TextColor3=Theme.Colors.Text;notice.Font=Theme.Fonts.Body;notice.TextSize=12;notice.TextWrapped=true;notice.Parent=host
local function label(parent:Instance,name:string,text:string,rect:any)
 local item=Instance.new("TextLabel");item.Name=name;item.Text=text;item.Position=UDim2.fromOffset(rect.x,rect.y);item.Size=UDim2.fromOffset(rect.w,rect.h)
 item.BackgroundColor3=Theme.Colors.Surface;item.BackgroundTransparency=.5;item.BorderSizePixel=0;item.TextColor3=Theme.Colors.Muted
 item.Font=Theme.Fonts.Body;item.TextSize=12;item.TextWrapped=true;item.Parent=parent
 local rim=Instance.new("UIStroke");rim.Color=Theme.Colors.Border;rim.Parent=item
end
local function redraw()
 generation+=1;local thisGeneration=generation
 if canvas then canvas:Destroy()end
 local size=sizes[sizeIndex]
 local area=Instance.new("Frame");area.Name="SimulatedSafeArea";area.Size=UDim2.fromOffset(size.X,size.Y);area.BackgroundColor3=Color3.fromRGB(44,56,58);area.BorderSizePixel=0;area.ClipsDescendants=true;area.Parent=viewport;canvas=area
 local scale=Instance.new("UIScale");scale.Scale=if fit then math.max(.01,math.min(1,viewport.AbsoluteSize.X/size.X,viewport.AbsoluteSize.Y/size.Y))else 1;scale.Parent=area
 viewport.CanvasSize=UDim2.fromOffset(size.X*scale.Scale,size.Y*scale.Scale)
 local layout=Layout(size.X,size.Y)
 for name,rect in pairs({Roster=layout.rosterRect,Skills=layout.padRect,Map=layout.mapRect,Orders=layout.ordersRect})do label(area,name,"Reserved · "..name,rect)end
 if layout.showHealth then label(area,"Health","Reserved · Health",layout.healthRect)end
 -- Exact live header allocations; these are reservation labels, not fake funds.
 label(area,"CurrencyReservation",if thai then "เงิน · พื้นที่สงวน"else"Currency · reserved",{x=20,y=6,w=.3*(size.X-16)-8,h=52})
 label(area,"MenuReservation",if thai then "เมนู"else"Menu",{x=size.X-108,y=10,w=96,h=44})
 local tracker=if before then Before(area :: any)else Current(area :: any)
 local mode=modes[modeIndex]
 local enabled=mode~="Blocked"
 local state:any=if mode=="Empty"then nil else{progress=if mode=="Ready"then 3 else 1,count=3,ready=mode=="Ready"}
 local title=if thai then "ภารกิจที่ติดตาม"else"Tracked quest"
 local value=if thai then "สำรวจเส้นทาง 1/3"else"Explore the paths 1/3"
 if mode=="Ready"then value=if thai then "พร้อมรับรางวัล"else"Ready to claim";title=value
 elseif mode=="Blocked"then value=if thai then "กำลังรอข้อมูล"else"Waiting for snapshot"
 elseif mode=="Empty"then value=if thai then "เปิดสมุดภารกิจ"else"Open quest journal"end
 if longCopy then value..=if thai then " — เดินตามเส้นทางพร้อมพวกพ้องไปยังทางแยกอย่างปลอดภัย"else" — follow the marked paths with your companions toward the distant crossroads"end
 tracker.update(state,title,value,enabled)
 tracker.button.Activated:Connect(function()
  if not enabled then return end
  activationCount+=1;gui:SetAttribute("ActivatedCount",activationCount)
  print("QUEST_HUD_ACTIVATED",if before then "BEFORE"else"AFTER",mode,activationCount)
 end)
 local beacon=Beacon(area :: any);beacon.update(nil,nil,unavailable,if thai then "th"else"en")
 notice.Text=string.format("%s · %s · %s · %dx%d · %.0f%% %s · long=%s · route unavailable=%s\nSynthetic state; reservation blocks only; Studio acceptance NOT_RUN until observed",if before then "BEFORE 3279e6d"else"AFTER current source",mode,if thai then "TH"else"EN",size.X,size.Y,scale.Scale*100,if fit then "FIT"else"1:1 (scroll)",tostring(longCopy),tostring(unavailable))
 task.delay(.3,function()
  if not alive or generation~=thisGeneration then return end
  local count,notFit=0,0
  for _,item in ipairs(tracker.button:GetDescendants())do
   if item:IsA("TextLabel")and item.Visible then
    count+=1;if not item.TextFits then notFit+=1;print("QUEST_HUD_TEXT_NOT_FIT",item.Name,item.Text,item.TextBounds,item.AbsoluteSize)end
   end
  end
  local nextWaypoint=area:FindFirstChild("NextWaypoint")
  -- UIScale affects AbsoluteSize and therefore responsive breakpoints. Only
  -- 1:1 is an exact preset test; Fit is a convenience at the observed size.
  if fit then notice.Text..="\nFIT changes responsive width: observed "..tostring(area.AbsoluteSize)..". Use 1:1 for exact preset QA." end
  print("QUEST_HUD_NATIVE_OBSERVATION",if before then "BEFORE"else"AFTER",mode,if thai then "th"else"en","requested",size,"observed",area.AbsoluteSize,"scale",scale.Scale,"text",count,"notFit",notFit,"tracker",tracker.button.AbsolutePosition,tracker.button.AbsoluteSize,"routeLayoutUnavailable",if nextWaypoint then nextWaypoint:GetAttribute("LayoutUnavailable")else nil)
 end)
end
local function control(index:number,text:string,callback:()->())
 local item=Instance.new("TextButton");item.Name="FixtureControl"..index;item.Size=UDim2.new(.25,-4,0,44);item.Position=UDim2.new(((index-1)%4)/4,2,0,math.floor((index-1)/4)*46)
 item.Text=text;item.TextSize=12;item.TextWrapped=true;item.BackgroundColor3=Theme.Colors.Primary;item.TextColor3=Theme.Colors.Text;item.Parent=host
 item.Activated:Connect(function()callback();redraw()end)
end
control(1,"Before / After",function()before=not before end)
control(2,"Size ▶",function()sizeIndex=sizeIndex%#sizes+1 end)
control(3,"EN / ไทย",function()thai=not thai end)
control(4,"State ▶",function()modeIndex=modeIndex%#modes+1 end)
control(5,"Long copy",function()longCopy=not longCopy end)
control(6,"1:1 / Fit",function()fit=not fit end)
control(7,"Route unavailable",function()unavailable=not unavailable end)
control(8,"Focus quest",function()local area=canvas;if area then game:GetService("GuiService").SelectedObject=area:FindFirstChild("QuestTracker") :: GuiObject? end end)
viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(redraw)
gui.Destroying:Connect(function()alive=false end)
redraw()
