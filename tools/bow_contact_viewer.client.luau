-- Isolated contact-art playback; no combat, profile or damage APIs.
local player=game.Players.LocalPlayer;local root=game.ReplicatedStorage.BowReview
local gui=Instance.new("ScreenGui");gui.Name="BowContactViewer";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local label=Instance.new("TextLabel");label.Name="Status";label.Size=UDim2.new(1,0,0,42);label.TextWrapped=true;label.BackgroundColor3=Color3.fromRGB(23,35,47);label.TextColor3=Color3.new(1,1,1);label.TextSize=13;label.Font=Enum.Font.Gotham;label.Text="Loading bow contact study…";label.Parent=gui
local row=Instance.new("Frame");row.Name="Controls";row.BackgroundTransparency=1;row.Size=UDim2.new(1,-24,0,44);row.Position=UDim2.new(0,12,1,-56);row.Parent=gui
local review=require(root.NativeReview);local elapsed=0;local playing=true;local loaded=false
local buttons={}
for i,entry in ipairs({{"Play","Pause"},{"Ready","Ready"},{"Draw","Draw"},{"Release","Release"},{"Pickup","Pickup"},{"Nock","Nock"}})do
 local b=Instance.new("TextButton");b.Name=entry[1];b.Text=entry[2];b.Size=UDim2.new(1/6,-6,0,44);b.Position=UDim2.new((i-1)/6,0,0,0);b.Font=Enum.Font.GothamMedium;b.TextSize=14;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(43,67,77);b.Parent=row;buttons[entry[1]]=b
 b.Activated:Connect(function()
  if not loaded then return end
  if entry[1]=="Play"then playing=not playing else playing=false;elapsed=if entry[1]=="Draw"then .2 elseif entry[1]=="Release"then 8/30 elseif entry[1]=="Pickup"then 1.1 elseif entry[1]=="Nock"then 1.85 else 0 end
  buttons.Play.Text=if playing then"Pause"else"Play"
 end)
end
local timeline=Instance.new("TextLabel");timeline.Name="Timeline";timeline.BackgroundTransparency=1;timeline.Position=UDim2.fromOffset(0,-22);timeline.Size=UDim2.new(1,0,0,20);timeline.TextColor3=Color3.new(1,1,1);timeline.TextSize=13;timeline.Text="";timeline.Parent=row
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=38
local connection=game:GetService("RunService").RenderStepped:Connect(function(dt)
 local viewport=camera.ViewportSize;local inset=game:GetService("GuiService"):GetGuiInset()
 local top=inset.Y+50;local bottom=viewport.Y-70;local tangent=math.tan(math.rad(camera.FieldOfView*.5))
 local fit=6.8*viewport.Y/(2*tangent*math.max(100,bottom-top))+2;local focus=Vector3.new(0,1002.8,.5)
 local base=CFrame.lookAt(focus+Vector3.new(8,5.2,12.5).Unit*fit,focus)
 camera.CFrame=base+base.UpVector*(((top+bottom)*.5-viewport.Y*.5)/math.max(1,viewport.Y)*fit*2*tangent)
 if loaded then if playing then elapsed=(elapsed+math.min(dt,.1))%2 end;review:Frame(elapsed);timeline.Text=string.format("%.2f / 2 s",elapsed)end
end)
local ok,err=pcall(function()
 for _,id in ipairs({"bow","StringUpper","StringLower","Arrow"})do review:Add(id,Vector3.new(0,1000,0),require(root.Data[id]));task.wait()end
end)
if ok then loaded=true;label.Text="Bow contact study · 18 rig + 5 cosmetic bones · local playback, sound/platform/game binding pending"
else label.Text="Preview failed: "..tostring(err);review:Destroy()end
script.Destroying:Connect(function()connection:Disconnect();review:Destroy();gui:Destroy()end)
