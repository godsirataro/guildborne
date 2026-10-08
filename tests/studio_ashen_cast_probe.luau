--!strict
-- Client-only local rigs and an isolated tag provider. No profile changes.
return function(make:any,animate:any):any
 local folder=make(true);folder.Name="AshenCastFixture";folder.Parent=workspace
 local added=Instance.new("BindableEvent");local removed=Instance.new("BindableEvent")
 local collection={GetTagged=function()return folder:GetChildren()end,GetInstanceAddedSignal=function()return added.Event end,GetInstanceRemovedSignal=function()return removed.Event end}
 local controller:any=nil;local parts=0;local motors=0;local moved=0;local base:{[Motor6D]:CFrame}={}
 local ok,result=pcall(function():any
  local camera=assert(workspace.CurrentCamera)
  for i,m in ipairs(folder:GetChildren())do
   assert(m:IsA("Model")and m.PrimaryPart and m.PrimaryPart.Anchored)
   m:PivotTo(camera.CFrame*CFrame.new(i*5,0,-15));m:SetAttribute("EscortMoving",true)
   for _,v in ipairs(m:GetDescendants())do
    if v:IsA("BasePart")then assert(not v.CanCollide and not v.CanQuery and not v.CanTouch);if v.Transparency<1 then parts+=1 end
    elseif v:IsA("Motor6D")then assert(v.Part0 and v.Part1);base[v]=v.C0;motors+=1 end
   end
  end
  controller=animate(collection);task.wait(.35)
  for motor,cf in pairs(base)do if motor.Name=="LeftUpperLeg"or motor.Name=="RightUpperLeg"or motor.Name=="LeftUpperArm"or motor.Name=="RightUpperArm"then assert(motor.C0~=cf,"Static walk limb "..motor.Name);moved+=1 end end
  for _,m in ipairs(folder:GetChildren())do m:SetAttribute("EscortMoving",false)end
  task.wait(.1)
  for motor,cf in pairs(base)do if motor.Name=="LeftUpperLeg"or motor.Name=="RightUpperLeg"then assert(motor.C0==cf,"Walk pose not reset")end end
  controller.Destroy();controller=nil
  for motor,cf in pairs(base)do assert(motor.C0==cf,"Destroy did not restore pose")end
  assert(parts==140 and moved==16)
  return {rigs=4,visibleParts=parts,motors=motors,walkingLimbs=moved,walkStopRestored=true,destroyRestored=true,profileWrites=0}
 end)
 if controller then controller.Destroy()end;folder:Destroy();added:Destroy();removed:Destroy()
 if not ok then error(result)end;return result
end
