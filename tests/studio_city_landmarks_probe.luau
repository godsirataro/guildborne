--!strict
-- Supply the generated review factory; isolated world geometry, no player movement.
return function(make:any):any
 local folder=make();folder.Name="CityLandmarkFixture";folder.Parent=workspace
 local checks=0;local parts=0;local routes=0
 local ok,result=pcall(function():any
  for i,model in ipairs(folder:GetChildren())do
   local x=3000+i*70;model:PivotTo(CFrame.new(x,0,3000))
   local floor=Instance.new("Part");floor.Name="FixtureGround";floor.Anchored=true;floor.Size=Vector3.new(60,1,60);floor.Position=Vector3.new(x,-.5,3000);floor.Parent=folder
   local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={model};params.RespectCanCollide=true
   local depth=model:GetAttribute("FootprintDepth")
   for z=depth/2+4,0,-2 do
    local blockers=workspace:GetPartBoundsInBox(CFrame.new(x,3.6,3000+z),Vector3.new(4,4.8,2),params)
    assert(#blockers==0,model.Name.." blocked entrance at "..z);checks+=1
   end
   for _,p in ipairs(model:GetDescendants())do if p:IsA("BasePart")then assert(p.Anchored and not p.CanTouch);parts+=1 end end
   local _,size=model:GetBoundingBox();assert(size.X<=44 and size.Z<=38 and size.Y<50,model.Name.." bounds")
   task.wait(.1)
   local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true})
   path:ComputeAsync(Vector3.new(x,3,3000+depth/2+4),Vector3.new(x,4,3000))
   assert(path.Status==Enum.PathStatus.Success and #path:GetWaypoints()>1,model.Name.." entrance navigation")
   path:Destroy();routes+=1
  end
  return {models=routes,parts=parts,entryClearanceSamples=checks,pathfindingRoutes=routes,width=4,height=4.8,synthetic=true,profileWrites=0,actualPlayerTraversal=false}
 end)
 folder:Destroy();assert(ok,tostring(result));return result
end
