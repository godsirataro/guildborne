--!strict
-- Disposable native fixture. All identities, health and portraits are simulated.
local Players=game:GetService("Players")
local Chrome=require(script.Parent.UI.Components.CombatChrome)
local Theme=require(script.Parent.UI.DesignSystem.Theme)
local Layout=require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
local gui=Instance.new("ScreenGui")
gui.Name="PartyRosterReview";gui.ResetOnSpawn=false;gui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui")
local canvas=Instance.new("Frame");canvas.Size=UDim2.fromScale(1,1);canvas.BackgroundColor3=Theme.Colors.Background;canvas.Parent=gui
local en={"Alexandra Dawnwarden", "Rowan of the Silver Forest", "Sage Emberlight", "Theodore Stormwatch", "Eleanor Brightshield", "Cassian Nightwarden"}
local th={"นักผจญภัยแห่งรุ่งอรุณ", "โรแวนผู้พิทักษ์พงไพร", "เซจจอมเวทแสงอรุณ", "ธีโอดอร์แห่งพายุ", "เอเลนอร์โล่ประกายแสง", "แคสเซียนผู้เฝ้าราตรี"}
local cards:any={};local selected=1;local thai=false
local hp={127,102,96,18,0,144}
local info=Instance.new("TextLabel");info.Size=UDim2.new(1,-16,0,56);info.Position=UDim2.fromOffset(8,0);info.BackgroundTransparency=1;info.TextColor3=Theme.Colors.Text;info.TextWrapped=true;info.TextSize=13;info.Font=Theme.Fonts.Body;info.Parent=canvas
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
  for j,entry in ipairs(cards) do
   entry.chrome.update(j==selected,j,hp[j],160)
   entry.button.BackgroundColor3=if j==selected then Theme.Colors.Primary else Theme.Colors.Surface
  end
 end)
end
local language=Instance.new("TextButton");language.Size=UDim2.new(1,-16,0,48);language.Position=UDim2.new(0,8,1,-56);language.Text="EN / ไทย — inspect TextFits in Output";language.TextSize=14;language.TextColor3=Theme.Colors.Text;language.BackgroundColor3=Theme.Colors.Primary;language.Parent=canvas
local function render()
 local size=canvas.AbsoluteSize;local layout=Layout(size.X,size.Y)
 info.Text=string.format("SIMULATED PARTY • %d × %d safe area\nSix actors • click to select • Studio emulator is not device proof",size.X,size.Y)
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
 thai=not thai;render()
 task.delay(.2,function()
  for i,entry in ipairs(cards) do print("PARTY_TEXT_FITS",canvas.AbsoluteSize,i,entry.chrome.name.Text,entry.chrome.name.TextFits) end
 end)
end)
canvas:GetPropertyChangedSignal("AbsoluteSize"):Connect(render)
render()
