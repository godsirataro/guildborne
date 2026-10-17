--!strict
-- Coordinator-run isolated fixture; not executed by the source worker.
-- No rewards, profiles, imports, uploads or publishing. Builds disposable original native kit.
local function clientFixture(animator:any):any
 local Players=game:GetService("Players");local Lighting=game:GetService("Lighting")
 local player=assert(Players.LocalPlayer,"client fixture requires LocalPlayer")
 local characterRoot=assert(player.Character and player.Character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local gui=assert(player:FindFirstChild("PlayerGui"));local camera=assert(workspace.CurrentCamera)
 local Motion=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
 local savedClock=Lighting.ClockTime;local savedCamera=camera.CFrame;local savedType=camera.CameraType
 local savedReduced=workspace:GetAttribute(Motion.ReducedMotionAttribute)
 local model=Instance.new("Model");model.Name="S17StationaryFixture";model:SetAttribute("NpcId","cartographer_nyra")
 model:SetAttribute("WorkMotionIdentity","cartographer_nyra")
 local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Anchored=true;root.CanCollide=false;root.Transparency=1
 root.CFrame=characterRoot.CFrame*CFrame.new(3,0,0);root.Parent=model;model.PrimaryPart=root
 local arm=Instance.new("Part");arm.Name="RightUpperArm";arm.CanCollide=false;arm.Massless=true;arm.Parent=model
 local motor=Instance.new("Motor6D");motor.Name="RightUpperArm";motor.Part0=root;motor.Part1=arm;motor.C0=CFrame.new(1,0,0);motor.Parent=root
 local originalRoot=root.CFrame;local originalMotor=motor.C0
 local screen=Instance.new("ScreenGui");screen.Name="S17DialogueFixture";screen.Parent=gui
 local dialogue=Instance.new("Frame");dialogue.Name="FriendlyDialogue_cartographer_nyra";dialogue.Visible=false;dialogue.Parent=screen
 local added=Instance.new("BindableEvent");local removed=Instance.new("BindableEvent")
 local collection={GetTagged=function()return {model}end,GetInstanceAddedSignal=function()return added.Event end,GetInstanceRemovedSignal=function()return removed.Event end}
 local controller:any=nil;local result:any=nil
 local ok,err=pcall(function()
  model.Parent=workspace;Lighting.ClockTime=10.5;workspace:SetAttribute(Motion.ReducedMotionAttribute,false)
  camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(root.Position+Vector3.new(0,4,12),root.Position)
  controller=animator(collection)
  local function waitFor(check:()->boolean,label:string)
   local deadline=os.clock()+4
   repeat if check()then return end;task.wait(.05) until os.clock()>deadline
   error("stationary fixture timed out: "..label)
  end
  waitFor(function()return (model:GetAttribute("NpcLifeWorkWeight") or 0)>.99 end,"day work")
  dialogue.Visible=true
  waitFor(function()return model:GetAttribute("NpcLifeActivity")=="Interact" and (model:GetAttribute("NpcLifeWorkWeight") or 1)<.01 end,"visible dialogue pauses work")
  dialogue.Visible=false
  waitFor(function()return model:GetAttribute("NpcLifeActivity")=="Work" and (model:GetAttribute("NpcLifeWorkWeight") or 0)>.99 end,"dialogue close resumes")
  Lighting.ClockTime=23
  waitFor(function()return model:GetAttribute("NpcLifeActivity")=="Rest" and (model:GetAttribute("NpcLifeWorkWeight") or 1)<.01 end,"night rests")
  Lighting.ClockTime=10.5;workspace:SetAttribute(Motion.ReducedMotionAttribute,true)
  waitFor(function()return motor.C0==originalMotor end,"reduced motion restores joints")
  workspace:SetAttribute(Motion.ReducedMotionAttribute,false)
  camera.CFrame=CFrame.lookAt(root.Position+Vector3.new(0,4,300),root.Position)
  waitFor(function()return model:GetAttribute("NpcLifeTier")=="Far" and motor.C0==originalMotor end,"far restores joints")
  assert(root.CFrame==originalRoot,"stationary NPC moved")
  controller.Destroy();controller=nil;assert(motor.C0==originalMotor,"destroy did not restore")
  result={status="PASS_CLIENT_FIXTURE_ONLY",npcId="cartographer_nyra",dialogueFixture=true,rootPreserved=true,restored=true,questJourneyTested=false,multiplayerTested=false}
 end)
 if controller then controller.Destroy()end
 model:Destroy();screen:Destroy();added:Destroy();removed:Destroy()
 Lighting.ClockTime=savedClock;workspace:SetAttribute(Motion.ReducedMotionAttribute,savedReduced)
 camera.CFrame=savedCamera;camera.CameraType=savedType
 if not ok then error(err)end
 return result
end
return function(options:any?):any
 if options and options.animator then return clientFixture(options.animator)end
 local Shared=game.ReplicatedStorage.Shared
 local B=require(Shared.Presentation.BorinPresentation)
 local Motion=require(Shared.Presentation.BorinWorkMotion)
 local kit=require(game.ServerScriptService.Server.Services.CityCharacterKit)(true,"smith_borin")
 local model=assert(kit:FindFirstChild("smith_borin")) :: Model
 model:SetAttribute("NpcId","smith_borin");model.Parent=workspace;kit:Destroy()
 local result:any=nil
 local ok,err=pcall(function()
  local root=assert(model.PrimaryPart);local original=root.CFrame
  assert(B.attach(model));assert(B.attach(model));assert(#model:GetChildren()>0)
  local stations=0;for _,child in ipairs(model:GetChildren()) do if child.Name=="BorinWorkstation" then stations+=1 end end;assert(stations==1)
  local motors:{[Motor6D]:CFrame}={};for _,v in ipairs(model:GetDescendants()) do if v:IsA("Motor6D") then motors[v]=v.C0 end end
  local target=model:FindFirstChild("BorinContactTarget",true) :: Attachment
  local tip=model:FindFirstChild("BorinHammerContact",true) :: Attachment
  local maximum=0
  for _,clock in ipairs({1,3,5}) do
   assert(B.apply(model,motors,{weight=1,lift=Motion.lift(clock),contact=true}))
   task.wait(.1);local error=(target.WorldPosition-tip.WorldPosition).Magnitude;maximum=math.max(maximum,error);assert(error<.025,tostring(error))
   assert(root.CFrame==original,"authoritative root moved")
  end
  B.apply(model,motors,{weight=0});for m,base in pairs(motors) do assert(m.C0==base) end
  for _,v in ipairs(assert(model:FindFirstChild("BorinWorkstation")):GetDescendants()) do if v:IsA("BasePart") then assert(not v.CanCollide and not v.CanTouch and not v.CanQuery and v.Massless) end end
  result={status="PASS_NATIVE_FIXTURE_ONLY",contactSamples=3,maxContactError=maximum,rootPreserved=true,restored=true,importedArt=false,questJourneyTested=false}
 end)
 model:Destroy();if not ok then error(err) end
 return result
end
