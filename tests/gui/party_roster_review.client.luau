--!strict
-- Disposable native fixture. All identities, health and portraits are simulated.
local Players=game:GetService("Players")
local Chrome=require(script.Parent.UI.Components.CombatChrome)
local Theme=require(script.Parent.UI.DesignSystem.Theme)
local Layout=require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
local gui=Instance.new("ScreenGui")
gui.Name="PartyRosterReview";gui.ResetOnSpawn=false;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui")
local host=Instance.new("Frame");host.Size=UDim2.fromScale(1,1);host.BackgroundColor3=Color3.fromRGB(7,10,17);host.Parent=gui
local canvas=Instance.new("Frame");canvas.Name="SimulatedSafeArea";canvas.Position=UDim2.fromOffset(0,82);canvas.BackgroundColor3=Theme.Colors.Background;canvas.ClipsDescendants=true;canvas.Parent=host
local scale=Instance.new("UIScale");scale.Parent=canvas
local sizes={Vector2.new(390,844),Vector2.new(320,760),Vector2.new(1366,768)}
local preset=1
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
local map=region("MapReservation","Map reservation")
map.BackgroundTransparency=.65;map.ZIndex=6
local orders=region("OrdersReservation","Focus / Regroup / Retreat — reserved")
local selectedHealth=region("SelectedHealthReservation","SIMULATED selected actor • 127 / 160 HP")
local healthBar=Chrome.health(selectedHealth)
local function refreshHealth()
 selectedHealth.Text=string.format("SIMULATED actor %d • %d / 160 HP",selected,hp[selected])
 healthBar.update(hp[selected],160)
end
local pad=Instance.new("Frame");pad.Name="CombatPadReservation";pad.BackgroundTransparency=1;pad.Parent=canvas
local skills:{TextButton}={}
for i=1,4 do
 local button=Instance.new("TextButton");button.Name="SyntheticSkill"..i;button.Text=if i==1 then "Attack" else "Skill "..(i-1);button.BackgroundColor3=Theme.Colors.Primary;button.TextColor3=Theme.Colors.Text;button.TextSize=14;button.Font=Theme.Fonts.Body;button.Active=false;button.Selectable=false;button.AutoButtonColor=false;button.Parent=pad
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
  refreshHealth()
  for j,entry in ipairs(cards) do
   entry.chrome.update(j==selected,j,hp[j],160)
   entry.button.BackgroundColor3=if j==selected then Theme.Colors.Primary else Theme.Colors.Surface
  end
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
local function render()
 local size=sizes[preset];local layout=Layout(size.X,size.Y)
 canvas.Size=UDim2.fromOffset(size.X,size.Y)
 scale.Scale=math.max(.01,math.min(1,host.AbsoluteSize.X/size.X,(host.AbsoluteSize.Y-82)/size.Y))
 info.Text=string.format("SIMULATED %d × %d • %.0f%% display scale\nEN/TH logs TextFits • scaled canvas ≠ device proof",size.X,size.Y,scale.Scale*100)
 top.Position=UDim2.fromOffset(8,8);top.Size=UDim2.fromOffset(size.X-16,44)
 map.Position=UDim2.fromOffset(size.X-138,60);map.Size=UDim2.fromOffset(130,48)
 local padY=if layout.topAligned then layout.padTop else (size.Y-layout.padHeight)/2
 pad.Position=UDim2.fromOffset(size.X-8-layout.padWidth,padY);pad.Size=UDim2.fromOffset(layout.padWidth,layout.padHeight)
 for i,button in ipairs(skills) do button.Size=UDim2.fromOffset(layout.buttonWidth,52);button.Position=UDim2.fromOffset(0,(i-1)*60) end
 local ordersWidth=math.min(size.X*.9,360)
 orders.Position=UDim2.fromOffset((size.X-ordersWidth)/2,size.Y-layout.ordersBottom-44);orders.Size=UDim2.fromOffset(ordersWidth,44)
 selectedHealth.Position=UDim2.fromOffset(size.X*(1-layout.healthScale)/2,size.Y-layout.healthBottom-layout.healthHeight);selectedHealth.Size=UDim2.fromOffset(size.X*layout.healthScale,layout.healthHeight)
 refreshHealth()
 -- Keep the concurrent reservations visible so a future overlap stays detectable.
 local mapPadOverlap=padY<108 and padY+layout.padHeight>60
 map.Text=if mapPadOverlap then "Map / skill overlap\nconcurrent reservations" else "Map reservation"
 map.TextColor3=if mapPadOverlap then Color3.fromRGB(255,160,140) else Theme.Colors.Text
 map:SetAttribute("OverlapsSkillReservation",mapPadOverlap)
 for i,entry in ipairs(cards) do
  entry.button.Size=UDim2.fromOffset(layout.cardWidth,layout.cardHeight)
  entry.button.Position=UDim2.fromOffset(8,64+(i-1)*layout.cardStride)
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
for index,size in ipairs(sizes) do
 tool(index,string.format("%d×%d",size.X,size.Y)).Activated:Connect(function() preset=index;render();inspect() end)
end
host:GetPropertyChangedSignal("AbsoluteSize"):Connect(render)
render()
