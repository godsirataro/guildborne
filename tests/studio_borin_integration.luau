--!strict
-- Coordinator-run isolated fixture; not executed by the source worker.
-- No rewards, profiles, imports, uploads or publishing. Builds disposable original native kit.
return function():any
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
