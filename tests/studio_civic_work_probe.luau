--!strict
-- Isolated local models, synthetic presentation only; no gameplay state.
return function(make:any,animate:any):any
 local folder=make(true);folder.Name="CivicWorkFixture";folder.Parent=workspace
 local added=Instance.new("BindableEvent");local removed=Instance.new("BindableEvent")
 local collection={GetTagged=function()return folder:GetChildren()end,GetInstanceAddedSignal=function()return added.Event end,GetInstanceRemovedSignal=function()return removed.Event end}
 local controller:any=nil;local base:{[Motor6D]:CFrame}={};local checks=0
 local attribute=require(game.ReplicatedStorage.Shared.Config.VFXConfig).ReducedMotionAttribute
 local old=workspace:GetAttribute(attribute)
 local ok,result=pcall(function():any
  workspace:SetAttribute(attribute,false)
  local camera=assert(workspace.CurrentCamera)
  local models=folder:GetChildren()
  for i,m in ipairs(models)do
   assert(m:IsA("Model"));m:PivotTo(camera.CFrame*CFrame.new(i*5,0,-20))
   for _,v in ipairs(m:GetDescendants())do if v:IsA("Motor6D")then base[v]=v.C0 end end
  end
  controller=animate(collection);task.wait(.4)
  local moved=0
  for motor,cf in pairs(base)do
   if motor.Name=="RightLowerArm"then assert(motor.C0~=cf);moved+=1 end
   if string.find(motor.Name,"Leg")or string.find(motor.Name,"Foot")then assert(motor.C0==cf);checks+=1 end
  end
  assert(moved==6)
  workspace:SetAttribute(attribute,true);task.wait(.1)
  for motor,cf in pairs(base)do assert(motor.C0==cf,"Reduced motion joint "..motor.Name);checks+=1 end
  workspace:SetAttribute(attribute,false)
  for _,m in ipairs(models)do (m :: Model):PivotTo(camera.CFrame*CFrame.new(0,0,-250))end
  task.wait(.1)
  for motor,cf in pairs(base)do assert(motor.C0==cf,"Distant pose not reset");checks+=1 end
  controller.Destroy();controller=nil
  for motor,cf in pairs(base)do assert(motor.C0==cf);checks+=1 end
  return {rigs=6,workingArms=moved,checks=checks,reducedRestored=true,distantRestored=true,destroyRestored=true,profileWrites=0}
 end)
 if controller then controller.Destroy()end;workspace:SetAttribute(attribute,old);folder:Destroy();added:Destroy();removed:Destroy()
 if not ok then error(result)end;return result
end
