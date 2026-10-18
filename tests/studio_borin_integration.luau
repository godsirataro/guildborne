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
 root.CFrame=characterRoot.CFrame*CFrame.new(3,0,4);root.Parent=model;model.PrimaryPart=root
 local arm=Instance.new("Part");arm.Name="RightUpperArm";arm.CanCollide=false;arm.Massless=true;arm.Parent=model
 local motor=Instance.new("Motor6D");motor.Name="RightUpperArm";motor.Part0=root;motor.Part1=arm;motor.C0=CFrame.new(1,0,0);motor.Parent=root
 local originalRoot=root.CFrame;local originalMotor=motor.C0
 local head=Instance.new("Part");head.Name="Head";head.CanCollide=false;head.Massless=true;head.Parent=model
 local neck=Instance.new("Motor6D");neck.Name="Head";neck.Part0=root;neck.Part1=head;neck.C0=CFrame.new(0,2,0);neck.Parent=root
 local originalNeck=neck.C0
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
  local function waitForActivePose(label:string)
   waitFor(function()
    return model:GetAttribute("NpcLifeActivity")=="Work"
     and (model:GetAttribute("NpcLifeWorkWeight") or 0)>.99 and motor.C0~=originalMotor
   end,label)
  end
  waitFor(function()return (model:GetAttribute("NpcLifeWorkWeight") or 0)>.99 end,"day work")
  local function yaw():number local _,y,_=(originalNeck:Inverse()*neck.C0):ToOrientation();return y end
  local function attention()
   -- Synthetic client presentation hints only, NOT proof of a server acceptance.
   model:SetAttribute("NpcInteractor",player.UserId);model:SetAttribute("NpcInteractUntil",workspace:GetServerTimeNow()+12)
   waitFor(function()return yaw()>.3 end,"head faces front-left accepted-hint fixture")
  end
  attention()
  dialogue.Visible=true
  model:SetAttribute("NpcInteractor",-987654321)
  waitFor(function()return math.abs(yaw())<.04 end,"stale local panel cannot override newer speaker")
  dialogue.Visible=false;attention()
  model:SetAttribute("NpcInteractUntil",workspace:GetServerTimeNow()-1)
  waitFor(function()return math.abs(yaw())<.04 end,"expired hint releases head")
  dialogue.Visible=true
  waitFor(function()return model:GetAttribute("NpcLifeActivity")=="Interact" and (model:GetAttribute("NpcLifeWorkWeight") or 1)<.01 end,"visible dialogue pauses work")
  dialogue.Visible=false
  waitFor(function()return model:GetAttribute("NpcLifeActivity")=="Work" and (model:GetAttribute("NpcLifeWorkWeight") or 0)>.99 end,"dialogue close resumes")
  Lighting.ClockTime=23
  waitFor(function()return model:GetAttribute("NpcLifeActivity")=="Rest" and (model:GetAttribute("NpcLifeWorkWeight") or 1)<.01 end,"night rests")
  Lighting.ClockTime=10.5
  waitForActivePose("active work before reduced motion")
  workspace:SetAttribute(Motion.ReducedMotionAttribute,true)
  waitFor(function()return motor.C0==originalMotor end,"reduced motion restores joints")
  workspace:SetAttribute(Motion.ReducedMotionAttribute,false)
  waitForActivePose("active work before far culling")
  camera.CFrame=CFrame.lookAt(root.Position+Vector3.new(0,4,300),root.Position)
  waitFor(function()return model:GetAttribute("NpcLifeTier")=="Far" and motor.C0==originalMotor end,"far restores joints")
  camera.CFrame=CFrame.lookAt(root.Position+Vector3.new(0,4,12),root.Position)
  waitForActivePose("active near work before destroy")
  attention()
  assert(root.CFrame==originalRoot,"stationary NPC moved")
  controller.Destroy();controller=nil;assert(motor.C0==originalMotor and neck.C0==originalNeck,"destroy did not restore")
  result={status="PASS_CLIENT_FIXTURE_ONLY",npcId="cartographer_nyra",dialogueFixture=true,attentionHintFixture=true,rootPreserved=true,restored=true,activeRestorePreconditions=3,questJourneyTested=false,multiplayerTested=false}
 end)
 if controller then controller.Destroy()end
 model:Destroy();screen:Destroy();added:Destroy();removed:Destroy()
 Lighting.ClockTime=savedClock;workspace:SetAttribute(Motion.ReducedMotionAttribute,savedReduced)
 camera.CFrame=savedCamera;camera.CameraType=savedType
 if not ok then error(err)end
 return result
end
return function(options:any?):any
 assert(game:GetService("RunService"):IsStudio(),"fixture requires Roblox Studio")
 assert(game.PlaceId==0 and game.GameId==0,"fixture requires an unpublished isolated PlaceId=0/GameId=0 candidate")
 if options and options.animator then return clientFixture(options.animator)end
 local Shared=game.ReplicatedStorage.Shared
 local B=require(Shared.Presentation.BorinPresentation)
 local Motion=require(Shared.Presentation.BorinWorkMotion)
 local npcId=if options and options.npcId then options.npcId else "smith_borin"
 assert(npcId=="smith_borin" or npcId=="host_deepforge","unsupported native fixture identity")
 local kit=require(game.ServerScriptService.Server.Services.CityCharacterKit)(true,"smith_borin")
 local model=assert(kit:FindFirstChild("smith_borin")) :: Model
 model.Name=npcId;model:SetAttribute("NpcId",npcId)
 if npcId=="host_deepforge" then model:SetAttribute("WorkMotionIdentity","smith_borin") end
 model.Parent=workspace;kit:Destroy()
 local result:any=nil
 local ok,err=pcall(function()
  local root=assert(model.PrimaryPart);local original=root.CFrame
  local designId=model:GetAttribute("DesignId")
  assert(B.attach(model));assert(B.attach(model));assert(#model:GetChildren()>0)
  local stations=0;for _,child in ipairs(model:GetChildren()) do if child.Name=="BorinWorkstation" then stations+=1 end end;assert(stations==1)
  local motors:{[Motor6D]:CFrame}={};for _,v in ipairs(model:GetDescendants()) do if v:IsA("Motor6D") then motors[v]=v.C0 end end
  local target=model:FindFirstChild("BorinContactTarget",true) :: Attachment
  local tip=model:FindFirstChild("BorinHammerContact",true) :: Attachment
  local tips=0;for _,v in ipairs(model:GetDescendants())do if v.Name=="BorinHammerContact" then tips+=1 end end;assert(tips==1)
  local maximum=0
  for _,clock in ipairs({1,3,5}) do
   assert(B.apply(model,motors,{weight=1,lift=Motion.lift(clock),contact=true}))
   task.wait(.1);local error=(target.WorldPosition-tip.WorldPosition).Magnitude;maximum=math.max(maximum,error);assert(error<.025,tostring(error))
   assert(root.CFrame==original,"authoritative root moved")
  end
  B.apply(model,motors,{weight=0});for m,base in pairs(motors) do assert(m.C0==base) end
  for _,v in ipairs(assert(model:FindFirstChild("BorinWorkstation")):GetDescendants()) do if v:IsA("BasePart") then assert(not v.CanCollide and not v.CanTouch and not v.CanQuery and v.Massless) end end
  assert(model.Name==npcId and model:GetAttribute("NpcId")==npcId and model:GetAttribute("DesignId")==designId)
  assert(model:GetAttribute("BorinInteractUntil")==nil and model:GetAttribute("BorinInteractor")==nil,"attach wrote legacy interaction hints")
  result={status="PASS_NATIVE_FIXTURE_ONLY",npcId=npcId,contactSamples=3,maxContactError=maximum,rootPreserved=true,restored=true,importedArt=false,questJourneyTested=false}
 end)
 model:Destroy();if not ok then error(err) end
 return result
end
