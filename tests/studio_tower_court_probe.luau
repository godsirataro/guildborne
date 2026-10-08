--!strict
-- Isolated assembled-scene fixture. No player movement or profile changes.
return function(make:any):any
 local court=make(-101,1);court.model.Name="TowerCourtFixture";court.model.Parent=workspace
 local other:any=nil
 local ok,result=pcall(function():any
  assert(not pcall(make,1,0)and not pcall(make,1,9)and not pcall(make,1,1.5))
  local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include
  overlap.FilterDescendantsInstances={court.model};overlap.RespectCanCollide=true
  local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include
  ray.FilterDescendantsInstances={court.model};ray.RespectCanCollide=true
  local checks=0;local routes=0
  for key,marker in pairs(court.markers)do
   local pos=marker.Position;local y=court.origin.Y
   local blockers=workspace:GetPartBoundsInBox(CFrame.new(pos.X,y+3.3,pos.Z),Vector3.new(3.8,5.5,3.8),overlap)
   assert(#blockers==0,key.." blocked by "..(blockers[1]and blockers[1].Name or ""));checks+=1
   assert(workspace:Raycast(Vector3.new(pos.X,y+1,pos.Z),Vector3.new(0,-3,0),ray),key.." missing floor");checks+=1
   local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=3})
   path:ComputeAsync(court.entry,Vector3.new(pos.X,y+2,pos.Z))
   assert(path.Status==Enum.PathStatus.Success,key.." unreachable from shared entrance");routes+=1
  end
  assert(routes==47)
  other=make(-102,2);other.model.Parent=workspace
  local firstCf,firstSize=court.model:GetBoundingBox();local secondCf,secondSize=other.model:GetBoundingBox()
  assert(secondCf.Y-secondSize.Y/2>firstCf.Y+firstSize.Y/2+5,"Private slots overlap")
  assert(other.origin.Y-court.origin.Y==80)
  local count=0;for _ in pairs(court.scenes)do count+=1 end;assert(count==6)
  return {scenes=count,entryRoutes=routes,bodyFloorChecks=checks,slotSeparation=80,invalidSlotRejections=3,actualPlayerWalk=false,questBinding=false}
 end)
 court.model:Destroy();if other then other.model:Destroy()end
 if not ok then error(result)end;return result
end
