--!strict
-- Isolated geometry fixture. Does not move players or modify progression.
return function(make:any):any
 local folder=make();folder.Name="ArchiveHeartStoryFixture";folder.Parent=workspace
 local checks=0;local routes=0;local markers=0;local parts=0
 local ok,result=pcall(function():any
  for i,model in ipairs(folder:GetChildren()) do
   assert(model:IsA("Model"))
   local origin=Vector3.new(5000+i*150,0,5000)
   model:PivotTo(CFrame.new(origin))
   local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={model};overlap.RespectCanCollide=true
   local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={model};ray.RespectCanCollide=true
   for _,part in ipairs(model:GetDescendants()) do
    if part:IsA("BasePart") then
     assert(part.Anchored and not part.CanTouch)
     if part:GetAttribute("StoryMarker") then
      markers+=1
      assert(not part.CanCollide and not part.CanQuery and part.Transparency==1)
      local p=part.Position
      local blockers=workspace:GetPartBoundsInBox(CFrame.new(p.X,origin.Y+3.3,p.Z),Vector3.new(3.8,5.5,3.8),overlap)
      assert(#blockers==0,model.Name.."/"..part.Name.." body blocked by "..(blockers[1] and blockers[1].Name or ""));checks+=1
      local ground=workspace:Raycast(Vector3.new(p.X,origin.Y+1,p.Z),Vector3.new(0,-3,0),ray)
      assert(ground and ground.Instance.Name=="WalkableFloor",model.Name.."/"..part.Name.." missing floor");checks+=1
      local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=3})
      local floor=model:FindFirstChild("WalkableFloor") :: BasePart
      path:ComputeAsync(origin+Vector3.new(0,2,floor.Size.Z/2-3),Vector3.new(p.X,origin.Y+2,p.Z))
      assert(path.Status==Enum.PathStatus.Success,model.Name.."/"..part.Name.." route unavailable");routes+=1
     else parts+=1 end
    end
   end
  end
  assert(markers==52 and parts==236)
  return {models=#folder:GetChildren(),parts=parts,markers=markers,clearanceChecks=checks,pathfindingRoutes=routes,actualPlayerWalk=false,questBinding=false}
 end)
 folder:Destroy()
 if not ok then error(result) end
 return result
end
