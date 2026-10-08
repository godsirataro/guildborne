-- Standalone local art viewer; no profile, rewards, purchases or publication.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")
local player=Players.LocalPlayer
local root=game.ReplicatedStorage:WaitForChild("CivicReview")
local gui=Instance.new("ScreenGui");gui.Name="CivicContactViewer";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local title=Instance.new("TextLabel");title.Name="ReviewStatus";title.BackgroundColor3=Color3.fromRGB(23,35,47);title.TextColor3=Color3.new(1,1,1);title.Font=Enum.Font.Gotham;title.TextSize=14;title.TextWrapped=true;title.Size=UDim2.new(1,0,0,44);title.Text="Loading six civic art studies…";title.Parent=gui
local function button(name,text,x,width,parent)
 local b=Instance.new("TextButton");b.Name=name;b.Text=text;b.Font=Enum.Font.GothamMedium;b.TextSize=14;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(43,67,77);b.Size=UDim2.new(0,width,0,44);b.Position=UDim2.fromOffset(x,0);b.Parent=parent;return b
end
local controls=Instance.new("Frame");controls.Name="Controls";controls.BackgroundTransparency=1;controls.Position=UDim2.new(0,12,1,-56);controls.Size=UDim2.new(1,-24,0,44);controls.Parent=gui
local pause=button("Pause","Pause",0,112,controls);local reset=button("Reset","Reset pose",120,112,controls)
local status=Instance.new("TextLabel");status.Name="Timeline";status.BackgroundTransparency=1;status.TextColor3=Color3.new(1,1,1);status.TextStrokeTransparency=.35;status.Font=Enum.Font.Gotham;status.TextSize=13;status.TextXAlignment=Enum.TextXAlignment.Left;status.Position=UDim2.fromOffset(244,0);status.Size=UDim2.new(1,-244,1,0);status.Text="";status.Parent=controls
local picker=Instance.new("ScrollingFrame");picker.Name="ActorPicker";picker.BackgroundTransparency=1;picker.BorderSizePixel=0;picker.Position=UDim2.fromOffset(12,52);picker.Size=UDim2.new(1,-24,0,54);picker.CanvasSize=UDim2.fromOffset(704,0);picker.ScrollBarThickness=4;picker.ScrollingDirection=Enum.ScrollingDirection.X;picker.Parent=gui
local loaded=false;local playing=true;local elapsed=0;local camera=workspace.CurrentCamera
while not camera do task.wait();camera=workspace.CurrentCamera end
camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=40
local focus=Vector3.new(0,1002.7,0);local width=38;local zoom=1;local yaw=0;local pitch=.16;local selected=nil
local entries={{"elian","Elian",-15},{"vaela","Vaela",-9},{"borin","Borin",-3},{"nyra","Nyra",3},{"sela","Sela",9},{"roka","Roka",15}}
local function all()selected=nil;focus=Vector3.new(0,1002.7,0);width=38;zoom=1;yaw=0;pitch=.16 end
button("All","All six",0,92,picker).Activated:Connect(all)
for i,e in ipairs(entries)do
 button(e[1],e[2],i*100,92,picker).Activated:Connect(function()selected=e[1];focus=Vector3.new(e[3],1002.8,0);width=5.5;zoom=1;yaw=.35;pitch=.18 end)
end
local review=require(root.NativeReview)
pause.Activated:Connect(function()playing=not playing;pause.Text=if playing then"Pause"else"Play"end)
reset.Activated:Connect(function()elapsed=0;review:Frame(0)end)
local dragging=false
local began=UserInputService.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.UserInputType==Enum.UserInputType.MouseButton2 then dragging=true end
 if input.KeyCode==Enum.KeyCode.Space then playing=not playing;pause.Text=if playing then"Pause"else"Play"end
end)
local ended=UserInputService.InputEnded:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton2 then dragging=false end end)
local changed=UserInputService.InputChanged:Connect(function(input,processed)
 if processed then return end
 if input.UserInputType==Enum.UserInputType.MouseWheel then zoom=math.clamp(zoom-input.Position.Z*.08,.60,2.5)
 elseif dragging and input.UserInputType==Enum.UserInputType.MouseMovement then yaw-=input.Delta.X*.008;pitch=math.clamp(pitch+input.Delta.Y*.006,-.1,.85)end
end)
local frameConnection=RunService.RenderStepped:Connect(function(dt)
 local viewport=camera.ViewportSize;local inset=GuiService:GetGuiInset()
 local top=inset.Y+112;local bottom=viewport.Y-70
 local available=math.max(80,bottom-top);local tangent=math.tan(math.rad(camera.FieldOfView*.5))
 local fit=math.max(6.7*viewport.Y/(2*tangent*available),width*viewport.Y/(2*tangent*math.max(200,viewport.X-32)))+2
 local distance=fit*zoom
 local base=CFrame.lookAt(focus+Vector3.new(math.sin(yaw)*distance,math.sin(pitch)*distance,math.cos(yaw)*distance),focus)
 local shift=((top+bottom)*.5-viewport.Y*.5)/math.max(1,viewport.Y)*distance*2*tangent
 camera.CFrame=base+base.UpVector*shift
 if loaded then
  if playing then elapsed=(elapsed+math.min(dt,.1))%6 end
  review:Frame(elapsed)
  for _,actor in ipairs(review.actors)do
   local visible=selected==nil or selected==actor.id
   actor.part.LocalTransparencyModifier=if visible then 0 else 1
   local effect=review.effects and review.effects[actor.id]
   if effect then
    for _,part in ipairs(effect.parts)do part.LocalTransparencyModifier=if visible then 0 else 1 end
    if effect.light then effect.light.Enabled=visible end
   end
  end
  status.Text=string.format("%.2f / 6 s · right-drag orbit · wheel zoom",elapsed)
 end
end)
local ok,err=pcall(function()
 for _,e in ipairs(entries)do review:Add(e[1],Vector3.new(e[3],1000,0),require(root.Data[e[1]]));title.Text="Loading "..e[2].."…";task.wait()end
 require(root.Effects)(review)
end)
if ok then loaded=true;title.Text="Civic art review · 6 rigs / 96 bones · final likeness, sound and game binding pending"
else title.Text="Art preview could not load: "..tostring(err);playing=false;review:Destroy()end
script.Destroying:Connect(function()frameConnection:Disconnect();began:Disconnect();ended:Disconnect();changed:Disconnect();review:Destroy();gui:Destroy()end)
