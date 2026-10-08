--!strict
-- Read-only directions for the owner's current campaign court. No gameplay requests.
local Players=game:GetService("Players");local Run=game:GetService("RunService");local TextService=game:GetService("TextService")
local Menu=require(script.Parent.Parent.UI.MenuRouter)
local Colors=require(game.ReplicatedStorage.Shared.Config.Art).UI
local heading=require(game.ReplicatedStorage.Shared.Data.CityWaypoint).heading
return function(scope:Instance?,manual:boolean?):any
 local player=Players.LocalPlayer;local world=scope or workspace
 local gui=Instance.new("ScreenGui");gui.Name="CampaignDirections";gui.ResetOnSpawn=false;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.DisplayOrder=25;gui.Enabled=false;gui.Parent=player:WaitForChild("PlayerGui")
 local panel=Instance.new("Frame");panel.Name="DirectionPanel";panel.AnchorPoint=Vector2.new(.5,1);panel.Position=UDim2.new(.5,0,1,-66);panel.Size=UDim2.new(.92,0,0,76);panel.BackgroundColor3=Colors.Background;panel.BackgroundTransparency=.08;panel.Parent=gui
 local limit=Instance.new("UISizeConstraint");limit.MaxSize=Vector2.new(480,148);limit.Parent=panel;Instance.new("UICorner",panel)
 local arrow=Instance.new("TextLabel");arrow.Name="Heading";arrow.BackgroundTransparency=1;arrow.Size=UDim2.fromOffset(32,32);arrow.Position=UDim2.new(0,7,.5,-16);arrow.Text="▲";arrow.TextSize=25;arrow.TextColor3=Colors.Accent;arrow.Parent=panel
 local label=Instance.new("TextLabel");label.Name="Destination";label.BackgroundTransparency=1;label.Position=UDim2.fromOffset(46,6);label.Size=UDim2.new(1,-54,1,-12);label.Font=Enum.Font.GothamMedium;label.TextSize=14;label.TextWrapped=true;label.TextColor3=Colors.Text;label.Parent=panel
 local S={};local connection:RBXScriptConnection?=nil;local closed=false;local cached:Model?=nil
 function S.Step(position:Vector3?,look:Vector3?,blocked:boolean?)
  if closed then return end
  if not cached or not cached:IsDescendantOf(world)then
   local m=world:FindFirstChild("ArchiveHeartCourt_"..player.UserId,true)or world:FindFirstChild("CrosshavenCourt_"..player.UserId,true)
   cached=if m and m:IsA("Model")and m:GetAttribute("CampaignOwner")==player.UserId then m else nil
  end
  local model=cached;local text=model and model:GetAttribute("NavigationText");local target:any=model and model:GetAttribute("NavigationPosition")
  gui.Enabled=not blocked and model~=nil and model:GetAttribute("NavigationVisible")==true and type(text)=="string"and position~=nil
  if not gui.Enabled then return end
  local hasTarget=typeof(target)=="Vector3"and target.Magnitude<1e7
  arrow.Visible=hasTarget
  label.Position=UDim2.fromOffset(if hasTarget then 46 else 8,6);label.Size=UDim2.new(1,if hasTarget then -54 else -16,1,-12)
  local distance=if hasTarget and position then (target-position).Magnitude else 0
  label.Text=tostring(text)..(if hasTarget then "\n"..tostring(math.floor(distance+.5))..(if model and model:GetAttribute("NavigationThai")then " studs · ตามทางเดิน"else " studs · follow the walkways")else "")
  local measured=TextService:GetTextSize(label.Text,14,label.Font,Vector2.new(math.max(100,panel.AbsoluteSize.X-(if hasTarget then 54 else 16)),1000))
  panel.Size=UDim2.new(.92,0,0,math.clamp(measured.Y+16,76,148))
  if hasTarget and position and look then
   local forward=Vector3.new(look.X,0,look.Z)
   if forward.Magnitude>.001 then forward=forward.Unit;local delta=target-position;arrow.Rotation=heading(delta:Dot(forward:Cross(Vector3.yAxis)),-delta:Dot(forward))end
  end
 end
 function S.Destroy()if closed then return end;closed=true;if connection then connection:Disconnect()end;gui:Destroy()end
 if not manual then local elapsed=0;connection=Run.RenderStepped:Connect(function(dt)
  elapsed+=dt;if elapsed<.2 then return end;elapsed=0
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
  local camera=workspace.CurrentCamera
  S.Step(root and root.Position,camera and camera.CFrame.LookVector,Menu.isBlocking()or player:GetAttribute("NoviceTrialHUDActive")==true)
 end)end
 return S
end
