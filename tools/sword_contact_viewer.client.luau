-- Local art fixture: no damage, profile, animation upload or commerce operations.
local player=game.Players.LocalPlayer;local root=game.ReplicatedStorage.SwordReview;local review=require(root.NativeReview)
local gui=Instance.new("ScreenGui");gui.Name="SwordContactViewer";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local title=Instance.new("TextLabel");title.Size=UDim2.new(1,0,0,42);title.TextWrapped=true;title.Text="Watchblade · guard / windup / cut / recovery · local art, gameplay binding pending";title.TextColor3=Color3.new(1,1,1);title.BackgroundColor3=Color3.fromRGB(23,35,47);title.TextSize=13;title.Parent=gui
local row=Instance.new("Frame");row.Name="Controls";row.Size=UDim2.new(1,-24,0,44);row.Position=UDim2.new(0,12,1,-56);row.BackgroundTransparency=1;row.Parent=gui
local elapsed=0;local playing=true;local loaded=false;local buttons={}
for i,entry in ipairs({{"Play","Pause",0},{"Guard","Guard",0},{"Windup","Windup",.2},{"Cut","Cut",.3},{"Follow","Follow",.6},{"Recover","Recover",.95}})do
 local b=Instance.new("TextButton");b.Name=entry[1];b.Text=entry[2];b.Size=UDim2.new(1/6,-6,0,44);b.Position=UDim2.new((i-1)/6,0,0,0);b.TextSize=14;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(43,67,77);b.Parent=row;buttons[entry[1]]=b
 b.Activated:Connect(function()if not loaded then return end;if entry[1]=="Play"then playing=not playing else playing=false;elapsed=entry[3]end;buttons.Play.Text=if playing then"Pause"else"Play"end)
end
local timeline=Instance.new("TextLabel");timeline.Name="Timeline";timeline.Position=UDim2.fromOffset(0,-22);timeline.Size=UDim2.new(1,0,0,20);timeline.BackgroundTransparency=1;timeline.TextColor3=Color3.new(1,1,1);timeline.TextSize=13;timeline.Parent=row
review:Add("sword",Vector3.new(0,1000,0),require(root.Data));local effects=require(root.Effects)(review.actors[1]);loaded=true
local trailEnabled=true;local trailButton=Instance.new("TextButton");trailButton.Name="TrailToggle";trailButton.Text="Trail: On";trailButton.Size=UDim2.fromOffset(130,28);trailButton.Position=UDim2.fromOffset(12,46);trailButton.TextSize=13;trailButton.TextColor3=Color3.new(1,1,1);trailButton.BackgroundColor3=Color3.fromRGB(43,67,77);trailButton.Parent=gui
trailButton.Activated:Connect(function()trailEnabled=not trailEnabled;trailButton.Text=if trailEnabled then"Trail: On"else"Trail: Off"end)
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=38
local connection=game:GetService("RunService").RenderStepped:Connect(function(dt)
 local viewport=camera.ViewportSize;local inset=game:GetService("GuiService"):GetGuiInset();local top=inset.Y+50;local bottom=viewport.Y-90
 local tangent=math.tan(math.rad(camera.FieldOfView*.5));local fit=7.2*viewport.Y/(2*tangent*math.max(100,bottom-top))+2;local focus=Vector3.new(0,1002.8,.7)
 local base=CFrame.lookAt(focus+Vector3.new(8,5.2,12.5).Unit*fit,focus);camera.CFrame=base+base.UpVector*(((top+bottom)*.5-viewport.Y*.5)/math.max(1,viewport.Y)*fit*2*tangent)
 if playing then elapsed=(elapsed+math.min(dt,.1))%2 end;review:Frame(elapsed);effects:Update(elapsed,playing,trailEnabled);timeline.Text=string.format("%.2f / 2 s",elapsed)
 gui:SetAttribute("Elapsed",elapsed);gui:SetAttribute("Playing",playing);gui:SetAttribute("TrailEnabled",trailEnabled)
end)
script.Destroying:Connect(function()connection:Disconnect();review:Destroy();gui:Destroy()end)
