-- Buttons select isolated art-review destinations; ordinary movement remains native.
local player=game.Players.LocalPlayer;local remote=game.ReplicatedStorage:WaitForChild("ArchitectureReviewDestination")
local input=game:GetService("UserInputService");local run=game:GetService("RunService")
local yaw=0;local pitch=.32;local distance=22;local dragging=false
local selectedCity="Crownford";local selectedService="Market"
input.InputBegan:Connect(function(event,processed)if not processed and event.UserInputType==Enum.UserInputType.MouseButton2 then dragging=true;input.MouseBehavior=Enum.MouseBehavior.LockCurrentPosition end end)
input.InputEnded:Connect(function(event)if event.UserInputType==Enum.UserInputType.MouseButton2 then dragging=false;input.MouseBehavior=Enum.MouseBehavior.Default end end)
input.InputChanged:Connect(function(event,processed)
 if processed then return end
 if event.UserInputType==Enum.UserInputType.MouseWheel then distance=math.clamp(distance-event.Position.Z*2,8,40)
 elseif dragging and event.UserInputType==Enum.UserInputType.MouseMovement then yaw-=event.Delta.X*.006;pitch=math.clamp(pitch+event.Delta.Y*.006,.05,1.15)end
end)
run.RenderStepped:Connect(function()
 local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart");local camera=workspace.CurrentCamera
 if root and camera then
  local focus=root.Position+Vector3.new(0,2,0);local delta=Vector3.new(math.sin(yaw)*distance,math.sin(pitch)*distance,math.cos(yaw)*distance)
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={c};params.IgnoreWater=true
  local hit=workspace:Raycast(focus,delta,params)
  if hit then delta=delta.Unit*math.max(.5,hit.Distance-.6)end
  camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(focus+delta,focus)
 end
end)
local gui=Instance.new("ScreenGui");gui.Name="CivicArchitectureReview";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local title=Instance.new("TextLabel");title.Size=UDim2.new(1,0,0,40);title.BackgroundColor3=Color3.fromRGB(23,35,47);title.TextColor3=Color3.new(1,1,1);title.TextSize=13;title.Font=Enum.Font.Gotham;title.TextWrapped=true;title.Text="Architecture review · Crownford · select a city, then walk with WASD · no gameplay profile";title.Parent=gui
local strip=Instance.new("ScrollingFrame");strip.Size=UDim2.new(1,-16,0,44);strip.Position=UDim2.fromOffset(8,44);strip.BackgroundTransparency=1;strip.BorderSizePixel=0;strip.ScrollBarThickness=3;strip.ScrollingDirection=Enum.ScrollingDirection.X;strip.CanvasSize=UDim2.fromOffset(684,0);strip.Parent=gui
for i,name in ipairs({"Crownford","Sylvaris","Deepforge","Astralis","Crosshaven","Ironroot"})do
 local b=Instance.new("TextButton");b.Name=name;b.Size=UDim2.fromOffset(108,36);b.Position=UDim2.fromOffset((i-1)*114,0);b.BackgroundColor3=Color3.fromRGB(43,67,77);b.TextColor3=Color3.new(1,1,1);b.TextSize=13;b.Font=Enum.Font.GothamMedium;b.Text=name;b.Parent=strip
 b.Activated:Connect(function()remote:FireServer(name,selectedService)end)
end
local services=Instance.new("Frame");services.Name="Services";services.BackgroundTransparency=1;services.Position=UDim2.fromOffset(8,88);services.Size=UDim2.new(1,-16,0,32);services.Parent=gui
for i,name in ipairs({"Market","Forge","Tavern","QuestHall"})do
 local b=Instance.new("TextButton");b.Name=name;b.Text=name;b.Size=UDim2.fromOffset(108,30);b.Position=UDim2.fromOffset((i-1)*114,0);b.TextSize=13;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(43,67,77);b.Parent=services
 b.Activated:Connect(function()remote:FireServer(selectedCity,name)end)
end
remote.OnClientEvent:Connect(function(name,position,service)
 selectedCity=name;selectedService=service or "Market"
 title.Text="Architecture review · "..name.." · "..selectedService.." ahead · no gameplay profile"
 yaw=0;pitch=.32;distance=22
end)
