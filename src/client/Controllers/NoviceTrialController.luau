--!strict
-- Presentation for server-owned solo arenas. Buttons send bounded attack intents;
-- this controller never sends damage, progress or a completion result.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local MenuRouter=require(script.Parent.Parent.UI.MenuRouter)
local Colors=require(game.ReplicatedStorage.Shared.Config.Art).UI
local Audio=require(script.Parent.AudioController)
local AudioConfig=require(game.ReplicatedStorage.Shared.Config.AudioConfig)
return function()
 local player=Players.LocalPlayer
 local gui=Instance.new("ScreenGui");gui.Name="NoviceTrialHUD";gui.ResetOnSpawn=false;gui.DisplayOrder=60
 gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Enabled=false;gui.Parent=player:WaitForChild("PlayerGui")
 local panel=Instance.new("Frame");panel.Name="Status";panel.Position=UDim2.fromOffset(8,58)
 panel.Size=UDim2.new(.31,0,0,148);panel.BackgroundColor3=Colors.Background;panel.BackgroundTransparency=.08;panel.Parent=gui
 local size=Instance.new("UISizeConstraint");size.MaxSize=Vector2.new(250,148);size.MinSize=Vector2.new(180,148);size.Parent=panel
 Instance.new("UICorner",panel)
 local labels:{TextLabel}={}
 for i,key in ipairs({"DisplayTitle","DisplayHealth","DisplayGoals","DisplayHint"})do
  local label=Instance.new("TextLabel");label.Name=key;label.BackgroundTransparency=1;label.TextColor3=if i==1 then Colors.Accent else Colors.Text
  label.Font=if i==1 then Enum.Font.GothamBold else Enum.Font.GothamMedium;label.TextSize=if i==1 then 16 else 13
  label.TextWrapped=true;label.Position=UDim2.fromOffset(8,if i==1 then 4 elseif i==2 then 26 elseif i==3 then 59 else 108)
  label.Size=UDim2.new(1,-16,0,if i==3 then 48 elseif i==4 then 38 elseif i==2 then 32 else 22);label.Parent=panel;table.insert(labels,label)
 end
 local arena:Model?=nil
 local presented:Model?=nil;local proxy:Model?=nil;local lastAction:any=nil;local lastWarning:any=nil
 local effect=require(script.Parent.SkillEffects)()
 local function clearPresentation()
  if proxy then proxy:Destroy();proxy=nil end
  presented=nil;lastAction=nil;lastWarning=nil
 end
 local buttons:{TextButton}={}
 local function send(action:string)
  local current=arena;if not current or (action~="Return"and current:GetAttribute("TrialStatus")~="Active")or MenuRouter.isBlocking()or Input:GetFocusedTextBox()then return end
  local remote=current:FindFirstChild("TrialInput")
  if remote and remote:IsA("RemoteEvent")then remote:FireServer(action)end
 end
 local keyboard=Input.InputBegan:Connect(function(key,processed)
  if processed then return end
  if key.KeyCode==Enum.KeyCode.F or key.KeyCode==Enum.KeyCode.ButtonR2 then send("Basic")
  elseif key.KeyCode==Enum.KeyCode.Q or key.KeyCode==Enum.KeyCode.ButtonR1 then send("Ability")end
 end)
 local leave=Instance.new("TextButton");leave.Name="LeaveTrial";leave.AnchorPoint=Vector2.new(.5,1);leave.Position=UDim2.new(.5,0,1,-8)
 leave.Size=UDim2.fromOffset(160,44);leave.BackgroundColor3=Colors.Card;leave.TextColor3=Colors.Text;leave.Font=Enum.Font.GothamMedium;leave.TextSize=14;leave.Parent=gui
 Instance.new("UICorner",leave);leave.Activated:Connect(function()send("Return")end)
 for index,action in ipairs({"Basic","Ability"})do
  local button=Instance.new("TextButton");button.Name="Trial"..action;button.AnchorPoint=Vector2.new(1,1)
  button.Position=UDim2.new(1,-12,1,-68-(index-1)*56);button.Size=UDim2.fromOffset(140,50)
  button.BackgroundColor3=Colors.Button;button.TextColor3=Colors.Text;button.TextWrapped=true;button.TextSize=14;button.Font=Enum.Font.GothamBold
  button.Parent=gui;Instance.new("UICorner",button);table.insert(buttons,button)
  button.Activated:Connect(function()
   send(action)
  end)
 end
 local elapsed=0
 local connection=Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.1 then return end;elapsed=0
  local candidate=workspace:FindFirstChild("NoviceTrial_"..player.UserId)or workspace:FindFirstChild("ArchiveEncounter_"..player.UserId)
  arena=if candidate and candidate:IsA("Model")and (candidate:GetAttribute("NoviceTrialArena")==true or candidate:GetAttribute("ArchiveHeartArena")==true)and candidate:GetAttribute("OwnerUserId")==player.UserId then candidate else nil
  gui.Enabled=arena~=nil and not MenuRouter.isBlocking()
  player:SetAttribute("NoviceTrialHUDActive",arena~=nil)
  local current=arena;if not current then clearPresentation();return end
  leave.Text=tostring(current:GetAttribute("ReturnLabel")or "Leave trial")
  leave.Active=current:GetAttribute("TrialStatus")~="Won"or current:GetAttribute("ReceiptDelivered")==true
  leave.AutoButtonColor=leave.Active
  if presented~=current then
   clearPresentation();presented=current
   local m=Instance.new("Model");m.Name="NoviceTrialCastVisual";m:SetAttribute("OwnerUserId",player.UserId)
   local root=Instance.new("Part");root.Name="VisualOrigin";root.Size=Vector3.one*.1;root.Transparency=1;root.Anchored=true
   root.CanCollide=false;root.CanQuery=false;root.CanTouch=false;root.Parent=m;m.PrimaryPart=root;m.Parent=workspace;proxy=m
  end
  local stamp=current:GetAttribute("ActionAt")
  if stamp and stamp~=lastAction then
   lastAction=stamp
   local origin=current:GetAttribute("ActionOriginPosition");local target=current:GetAttribute("ActionTargetPosition")
   if type(stamp)=="number"and workspace:GetServerTimeNow()-stamp<.6 and typeof(origin)=="Vector3"and typeof(target)=="Vector3"and proxy and proxy.PrimaryPart then
    proxy.PrimaryPart.CFrame=if (target-origin).Magnitude>.01 then CFrame.lookAt(origin,target)else CFrame.new(origin)
    for _,key in ipairs({"ClassId","ActionEffect","ActionAbilityId","ActionTargetPosition"})do proxy:SetAttribute(key,current:GetAttribute(key))end
    effect(proxy);Audio.Play(AudioConfig.actionCue(tostring(current:GetAttribute("ClassId")),tostring(current:GetAttribute("ActionEffect"))),origin)
   end
  end
  local warning=current:GetAttribute("WarningToken")
  if warning and warning~=lastWarning then lastWarning=warning;local marker=current:FindFirstChild("CommittedWarning");local anchor=if marker and marker:IsA("Folder")then marker:FindFirstChildWhichIsA("BasePart")else marker;if anchor and anchor:IsA("BasePart")then Audio.Play("enemy_warning",anchor.Position)end end
  for _,label in ipairs(labels)do label.Text=tostring(current:GetAttribute(label.Name)or "")end
  for index,button in ipairs(buttons)do
   local action=if index==1 then "Basic"else "Ability"
   local untilAt=current:GetAttribute("Next"..action.."At")
   local waitFor=if type(untilAt)=="number"then math.max(0,untilAt-workspace:GetServerTimeNow())else 0
   local active=current:GetAttribute("TrialStatus")=="Active"
   button.Visible=active;button.Active=active and waitFor<=0;button.AutoButtonColor=button.Active
   button.BackgroundColor3=if waitFor>0 then Colors.Card else Colors.Button
   local key=if Input:GetLastInputType().Name:find("Gamepad")then (if index==1 then "R2"else "R1")else (if index==1 then "F"else "Q")
   button.Text=key.." · "..tostring(current:GetAttribute(action.."Label")or "")..(if waitFor>.05 then string.format(" · %.1fs",waitFor)else "")
  end
 end)
 gui.Destroying:Connect(function()connection:Disconnect();keyboard:Disconnect();clearPresentation();player:SetAttribute("NoviceTrialHUDActive",false)end)
end
