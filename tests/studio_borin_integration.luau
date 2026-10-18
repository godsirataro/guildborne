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
local function durnClientFixture(animator:any):any
 local Run=game:GetService("RunService");local Lighting=game:GetService("Lighting")
 local Collection=game:GetService("CollectionService")
 local player=assert(game:GetService("Players").LocalPlayer,"client required")
 local characterRoot=assert(player.Character and player.Character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local camera=assert(workspace.CurrentCamera)
 local Shared=game.ReplicatedStorage.Shared
 local Motion=require(Shared.Presentation.BorinWorkMotion)
 local Vfx=require(Shared.Config.VFXConfig)
 local source=assert(workspace:FindFirstChild("GuildborneWorld")):FindFirstChild("Deepforge")
 local template=assert(source and source:FindFirstChild("host_deepforge")) :: Model
 assert(template:GetAttribute("NpcId")=="host_deepforge" and template:GetAttribute("WorkMotionIdentity")=="smith_borin")
 -- Capture native bind C0s, not the live animator's currently raised hammer pose.
 assert(template.PrimaryPart and (template.PrimaryPart.Position-camera.CFrame.Position).Magnitude>Motion.CullDistance
  and template:GetAttribute("BorinLocalWorkWeight")==0,"source Durn must be streamed in and culled/restored before cloning")
 local model=template:Clone();assert(model,"native Durn must be archivable")
 local added=Instance.new("BindableEvent");local removed=Instance.new("BindableEvent")
 local savedClock=Lighting.ClockTime;local savedReduced=workspace:GetAttribute(Vfx.ReducedMotionAttribute)
 local savedType=camera.CameraType;local savedCamera=camera.CFrame
 local binding="DurnFixtureCamera_"..game:GetService("HttpService"):GenerateGUID(false)
 local bound=false;local controller:any=nil;local result:any=nil
 local ok,problem=pcall(function()
  -- Clone tags must never enlist the game's global animator or quest systems.
  local instances=model:GetDescendants();table.insert(instances,model)
  for _,instance in ipairs(instances)do
   for _,tag in ipairs(Collection:GetTags(instance))do Collection:RemoveTag(instance,tag)end
   if instance:IsA("ProximityPrompt")then instance.Enabled=false end
  end
  model.Name="S17DurnClientFixture"
  local root=assert(model.PrimaryPart)
  local at=characterRoot.Position+Vector3.new(6,-3,4)
  model:PivotTo(CFrame.lookAt(at,Vector3.new(characterRoot.Position.X,at.Y,characterRoot.Position.Z)))
  local originalRoot=root.CFrame;local originalId=model:GetAttribute("NpcId")
  local motors:{[Motor6D]:CFrame}={}
  local forgeArm:Motor6D?=nil
  for _,instance in ipairs(model:GetDescendants())do if instance:IsA("Motor6D")then
   motors[instance]=instance.C0;if instance.Name=="RightUpperArm"then forgeArm=instance end
  end end
  local activeArm=assert(forgeArm,"native forge arm missing")
  local target=assert(model:FindFirstChild("BorinContactTarget",true)) :: Attachment
  local tip=assert(model:FindFirstChild("BorinHammerContact",true)) :: Attachment
  local flash=assert(model:FindFirstChild("BorinContactFlash",true)) :: PointLight
  local function restored():boolean
   for motor,base in pairs(motors)do if motor.C0~=base then return false end end
   return not flash.Enabled
  end
  local cameraPose=CFrame.lookAt(root.Position+Vector3.new(0,5,14),root.Position+Vector3.new(0,2,0))
  Run:BindToRenderStep(binding,Enum.RenderPriority.Camera.Value+1,function()
   camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=cameraPose
  end);bound=true
  camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=cameraPose
  Lighting.ClockTime=10.5;workspace:SetAttribute(Vfx.ReducedMotionAttribute,false)
  model:SetAttribute("NpcInteractUntil",0);model:SetAttribute("NpcInteractor",player.UserId)
  model:SetAttribute("BorinInteractUntil",workspace:GetServerTimeNow()+120);model:SetAttribute("BorinInteractor",player.UserId)
  model.Parent=workspace
  local collection={GetTagged=function()return {model}end,GetInstanceAddedSignal=function()return added.Event end,GetInstanceRemovedSignal=function()return removed.Event end}
  controller=animator(collection)
  local function waitFor(check:()->boolean,label:string)
   local deadline=os.clock()+8
   repeat
    assert(workspace.CurrentCamera==camera,"camera object replaced")
    assert(root.CFrame==originalRoot and model:GetAttribute("NpcId")==originalId,"fixture root/identity changed")
    if check()then return end
    Run.RenderStepped:Wait()
   until os.clock()>deadline
   error("Durn fixture timed out: "..label)
  end
  local function active(label:string)
   waitFor(function()
    return model:GetAttribute("BorinLocalPresentationState")=="Work"
     and model:GetAttribute("BorinLocalWorkWeight")==1 and activeArm.C0~=motors[activeArm]
   end,label)
  end
  active("generic expired hint ignores future legacy hint")
  local contactError=math.huge
  waitFor(function()
   if flash.Enabled then contactError=math.min(contactError,(tip.WorldPosition-target.WorldPosition).Magnitude)end
   return contactError<.025
  end,"actual animated native hammer contact")
  model:SetAttribute("NpcInteractor",0)
  model:SetAttribute("NpcInteractUntil",workspace:GetServerTimeNow()+12)
  local invalidUntil=os.clock()+.4
  repeat Run.RenderStepped:Wait();assert(model:GetAttribute("BorinLocalPresentationState")=="Work","legacy speaker selected over invalid generic speaker")until os.clock()>=invalidUntil
  model:SetAttribute("NpcInteractor",player.UserId)
  model:SetAttribute("BorinInteractor",0)
  model:SetAttribute("BorinInteractUntil",0)
  model:SetAttribute("NpcInteractUntil",workspace:GetServerTimeNow()+12)
  waitFor(function()
   return model:GetAttribute("BorinLocalPresentationState")=="Interact"
    and model:GetAttribute("BorinLocalWorkWeight")==0 and not flash.Enabled
  end,"generic talk pauses despite expired legacy hint")
  local held=model:GetAttribute("BorinLocalWorkClock")
  local untilQuiet=os.clock()+.3
  repeat Run.RenderStepped:Wait();assert(not flash.Enabled and model:GetAttribute("BorinLocalWorkClock")==held,"paused strike advanced")until os.clock()>=untilQuiet
  model:SetAttribute("BorinInteractUntil",workspace:GetServerTimeNow()+120)
  model:SetAttribute("NpcInteractUntil",workspace:GetServerTimeNow()-1)
  waitFor(function()return model:GetAttribute("BorinLocalPresentationState")=="Recover"end,"generic expiry starts recovery")
  active("generic expiry recovers despite future legacy hint")
  workspace:SetAttribute(Vfx.ReducedMotionAttribute,true)
  waitFor(restored,"reduced restores active joints/flash")
  workspace:SetAttribute(Vfx.ReducedMotionAttribute,false);active("active before far")
  cameraPose=CFrame.lookAt(root.Position+Vector3.new(0,5,300),root.Position)
  waitFor(restored,"far restores active joints/flash")
  cameraPose=CFrame.lookAt(root.Position+Vector3.new(0,5,14),root.Position)
  active("active before collection removal")
  removed:Fire(model);waitFor(restored,"collection removal restores")
  local quietUntil=os.clock()+.3
  repeat Run.RenderStepped:Wait();assert(restored(),"unregistered fixture has another pose writer")until os.clock()>=quietUntil
  added:Fire(model);added:Fire(model) -- Duplicate discovery must not add another actor owner.
  active("re-added active before destroy")
  controller.Destroy();controller=nil;assert(restored(),"Destroy failed restoration")
  quietUntil=os.clock()+.3
  repeat Run.RenderStepped:Wait();assert(restored(),"pose writer survived Destroy")until os.clock()>=quietUntil
  assert(root.CFrame==originalRoot and model:GetAttribute("NpcId")==originalId)
  result={status="PASS_DURN_CLIENT_CLONE_ONLY",npcId=originalId,minimumObservedContactError=contactError,
   genericHintIsolation=true,activeRestorePreconditions=4,rootPreserved=true,
   duplicateDiscoveryCleanup=true,ordinaryInteractionTested=false,multiplayerTested=false}
 end)
 if controller then controller.Destroy()end
 if bound then Run:UnbindFromRenderStep(binding)end
 model:Destroy();added:Destroy();removed:Destroy()
 Lighting.ClockTime=savedClock;workspace:SetAttribute(Vfx.ReducedMotionAttribute,savedReduced)
 camera.CameraType=savedType;camera.CFrame=savedCamera
 if not ok then error(problem)end
 return result
end
return function(options:any?):any
 assert(game:GetService("RunService"):IsStudio(),"fixture requires Roblox Studio")
 assert(game.PlaceId==0 and game.GameId==0,"fixture requires an unpublished isolated PlaceId=0/GameId=0 candidate")
 if options and options.animator then
  if options.npcId=="host_deepforge" then return durnClientFixture(options.animator)end
  return clientFixture(options.animator)
 end
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
