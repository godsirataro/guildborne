--!strict
-- Disposable native fixture. All identities, health and portraits are simulated.
local Players=game:GetService("Players")
local Chrome=require(game.StarterPlayer.StarterPlayerScripts.Client.UI.Components.CombatChrome)
local Theme=require(game.StarterPlayer.StarterPlayerScripts.Client.UI.DesignSystem.Theme)
local Layout=require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
local gui=Instance.new("ScreenGui")
gui.Name="PartyRosterReview";gui.ResetOnSpawn=false;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui")
local host=Instance.new("Frame");host.Size=UDim2.fromScale(1,1);host.BackgroundColor3=Color3.fromRGB(7,10,17);host.Parent=gui
local canvas=Instance.new("Frame");canvas.Name="SimulatedSafeArea";canvas.Position=UDim2.fromOffset(0,82);canvas.BackgroundColor3=Theme.Colors.Background;canvas.ClipsDescendants=true;canvas.Parent=host
local scale=Instance.new("UIScale");scale.Parent=canvas
local sizes={Vector2.new(796,400),Vector2.new(390,449),Vector2.new(320,240),Vector2.new(600,320),Vector2.new(390,844),Vector2.new(1366,768)}
local preset=1;local fit=true
local render: () -> ()
local en={"Alexandra Dawnwarden", "Rowan of the Silver Forest", "Sage Emberlight", "Theodore Stormwatch", "Eleanor Brightshield", "Cassian Nightwarden"}
local th={"นักผจญภัยแห่งรุ่งอรุณ", "โรแวนผู้พิทักษ์พงไพร", "เซจจอมเวทแสงอรุณ", "ธีโอดอร์แห่งพายุ", "เอเลนอร์โล่ประกายแสง", "แคสเซียนผู้เฝ้าราตรี"}
local cards:any={};local selected=1;local thai=false
local hp={127,102,96,18,0,144}
local info=Instance.new("TextLabel");info.Size=UDim2.new(1,-16,0,34);info.Position=UDim2.fromOffset(8,46);info.BackgroundTransparency=1;info.TextColor3=Theme.Colors.Text;info.TextWrapped=true;info.TextSize=12;info.Font=Theme.Fonts.Body;info.Parent=host
local function region(name:string,text:string):TextLabel
 local label=Instance.new("TextLabel");label.Name=name;label.Text=text;label.BackgroundColor3=Theme.Colors.Surface;label.BackgroundTransparency=.2;label.TextColor3=Theme.Colors.Text;label.Font=Theme.Fonts.Body;label.TextSize=13;label.TextWrapped=true;label.Parent=canvas
 Chrome.surface(label);label:SetAttribute("SyntheticHUDReservation",true)
 return label
end
local top=region("TopBarReservation","SYNTHETIC HUD • Gold / Quest / Menu")
local function action(parent:Instance,name:string,text:string):TextButton
 local button=Instance.new("TextButton");button.Name=name;button.Text=text;button.TextWrapped=true;button.BackgroundColor3=Theme.Colors.Surface;button.TextColor3=Theme.Colors.Text;button.Font=Theme.Fonts.Body;button.TextSize=12;button.Parent=parent
 button.Activated:Connect(function()
  local count=button:GetAttribute("FixtureActivations")
  button:SetAttribute("FixtureActivations",(if type(count)=="number" then count else 0)+1)
  print("SYNTHETIC_HUD_CLICK",name,button:GetAttribute("FixtureActivations"))
 end)
 return button
end
local map=action(canvas,"MapReservation","Map (simulated)");Chrome.surface(map)
local cycle=action(canvas,"CycleActor","Next hero");cycle.Size=UDim2.fromOffset(96,44);cycle.Position=UDim2.fromOffset(8,112)
cycle.Activated:Connect(function() selected=selected%6+1;render() end)
local orders=Instance.new("ScrollingFrame");orders.Name="OrdersReservation";orders.BackgroundTransparency=1;orders.BorderSizePixel=0;orders.ScrollingDirection=Enum.ScrollingDirection.X;orders.ScrollBarThickness=4;orders.CanvasSize=UDim2.fromOffset(660,0);orders.Parent=canvas
for i,name in ipairs({"Focus","Regroup","Retreat","Hold","Balanced","Defensive"}) do
 local button=action(orders,"Order"..i,name);button.Size=UDim2.fromOffset(106,40);button.Position=UDim2.fromOffset((i-1)*110,0)
end
local selectedHealth=region("SelectedHealthReservation","SIMULATED selected actor • 127 / 160 HP")
local worldLabel=region("DistrictNameReservation","Simulated location")
local directionLabel=region("WaypointDirectionReservation","↑")
local healthBar=Chrome.health(selectedHealth)
local function refreshHealth()
 selectedHealth.Text=string.format("SIMULATED actor %d • %d / 160 HP",selected,hp[selected])
 healthBar.update(hp[selected],160)
end
local pad=Instance.new("Frame");pad.Name="CombatPadReservation";pad.BackgroundTransparency=1;pad.Parent=canvas
local skills:{TextButton}={}
for i=1,4 do
 local button=action(pad,"SyntheticSkill"..i,if i==1 then "Attack" else "Skill "..(i-1));button.BackgroundColor3=Theme.Colors.Primary;button.TextSize=14
 Chrome.skill(button,i-1).update(true,0,true);skills[i]=button
end
for i=1,6 do
 local card=Instance.new("TextButton");card.Name="Actor"..i;card.Text="";card.BackgroundColor3=Theme.Colors.Surface;card.Parent=canvas
 local chrome=Chrome.actor(card)
 -- Simple native 3D dummy, deliberately not a production hero asset.
 local viewport=Instance.new("ViewportFrame");viewport.Name="SimulatedPortrait";viewport.Position=UDim2.fromOffset(4,3);viewport.BackgroundTransparency=1;viewport.ZIndex=3;viewport.Parent=card
 local world=Instance.new("WorldModel");world.Parent=viewport
 local head=Instance.new("Part");head.Shape=Enum.PartType.Ball;head.Size=Vector3.new(2,2,2);head.Color=Color3.fromHSV(i/7,.35,.8);head.Anchored=true;head.Parent=world
 local camera=Instance.new("Camera");camera.CFrame=CFrame.new(Vector3.new(0,0,4),Vector3.zero);camera.Parent=viewport;viewport.CurrentCamera=camera
 cards[i]={button=card,chrome=chrome,portrait=viewport}
 card.Activated:Connect(function()
  selected=i
  render()
 end)
end
local function tool(index:number,text:string):TextButton
 local button=Instance.new("TextButton");button.Name="ReviewTool"..index;button.Size=UDim2.new(.25,-4,0,44);button.Position=UDim2.new((index-1)*.25,2,0,0);button.Text=text;button.TextSize=12;button.TextColor3=Theme.Colors.Text;button.BackgroundColor3=Theme.Colors.Primary;button.Parent=host;return button
end
local language=tool(4,"EN / ไทย")
local function inspect()
 task.delay(.2,function()
  for i,entry in ipairs(cards) do print("PARTY_TEXT_FITS",sizes[preset],"render scale",scale.Scale,i,entry.chrome.name.Text,entry.chrome.name.TextFits) end
 end)
end
local function place(object:GuiObject,rect:any)
 object.Position=UDim2.fromOffset(rect.x,rect.y);object.Size=UDim2.fromOffset(rect.w,rect.h)
end
render=function()
 local size=sizes[preset];local layout=Layout(size.X,size.Y)
 canvas.Size=UDim2.fromOffset(size.X,size.Y)
 scale.Scale=if fit then math.max(.01,math.min(1,host.AbsoluteSize.X/size.X,(host.AbsoluteSize.Y-82)/size.Y)) else 1
 info.Text=string.format("SIMULATED %d × %d • %.0f%% display scale\nEN/TH logs TextFits • scaled canvas ≠ device proof",size.X,size.Y,scale.Scale*100)
 top.Position=UDim2.fromOffset(8,8);top.Size=UDim2.fromOffset(size.X-16,44)
 place(map,layout.mapRect);place(pad,layout.padRect);place(orders,layout.ordersRect);place(selectedHealth,layout.healthRect)
 selectedHealth.Visible=layout.showHealth;cycle.Visible=layout.collapsed
 worldLabel.Visible=layout.showWorldLabels;directionLabel.Visible=layout.showWorldLabels
 worldLabel.Position=UDim2.fromOffset(size.X-138,112);worldLabel.Size=UDim2.fromOffset(130,64)
 directionLabel.Position=UDim2.fromOffset(size.X-90,180);directionLabel.Size=UDim2.fromOffset(40,40)
 for i,button in ipairs(skills) do
  button.Size=UDim2.fromOffset(layout.buttonWidth,52)
  button.Position=if layout.compact then UDim2.fromOffset(((i-1)%2)*(layout.buttonWidth+8),math.floor((i-1)/2)*56) else UDim2.fromOffset(0,(i-1)*60)
 end
 refreshHealth()
 -- Keep the concurrent reservations visible so a future overlap stays detectable.
 local a,b=layout.mapRect,layout.padRect
 local mapPadOverlap=a.x<b.x+b.w and b.x<a.x+a.w and a.y<b.y+b.h and b.y<a.y+a.h
 map.Text=if mapPadOverlap then "Map / skill overlap" elseif thai then "แผนที่ (จำลอง)" else "Map (simulated)"
 map.TextColor3=if mapPadOverlap then Color3.fromRGB(255,160,140) else Theme.Colors.Text
 map:SetAttribute("OverlapsSkillReservation",mapPadOverlap)
 for i,entry in ipairs(cards) do
  entry.button.Size=UDim2.fromOffset(layout.cardWidth,layout.cardHeight)
  entry.button.Position=if layout.collapsed then UDim2.fromOffset(8,64) elseif layout.grid then UDim2.fromOffset(8+((i-1)%layout.columns)*(layout.cardWidth+6),64+math.floor((i-1)/layout.columns)*layout.cardStride) else UDim2.fromOffset(8,64+(i-1)*layout.cardStride)
  entry.button.Visible=not layout.collapsed or i==selected
  entry.chrome.layout(layout.cardWidth,layout.cardHeight)
  entry.chrome.name.Text=(if thai then th else en)[i]
  entry.chrome.update(i==selected,i,hp[i],160)
  entry.button.BackgroundColor3=if i==selected then Theme.Colors.Primary else Theme.Colors.Surface
  local portraitSize=if layout.cardHeight>44 then 48 elseif layout.cardWidth<110 then 26 else 32
  entry.portrait.Size=UDim2.fromOffset(portraitSize,portraitSize)
 end
end
language.Activated:Connect(function()
 thai=not thai;render();inspect()
end)
tool(1,"Size ◀").Activated:Connect(function() preset=(preset-2)%#sizes+1;render();inspect() end)
tool(2,"Size ▶").Activated:Connect(function() preset=preset%#sizes+1;render();inspect() end)
tool(3,"1:1 / Fit").Activated:Connect(function() fit=not fit;render();inspect() end)
host:GetPropertyChangedSignal("AbsoluteSize"):Connect(render)
render()
