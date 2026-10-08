--!strict
-- Complete assembled interior geometry only. No player movement or quest grants.
return function(make:any):any
 local art=make(101,1);art.model.Parent=workspace
 local routes=0;local points=0
 local ok,result=pcall(function():any
  local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={art.model};overlap.RespectCanCollide=true
  assert(#workspace:GetPartBoundsInBox(CFrame.new(art.entry),Vector3.new(4,5,4),overlap)==0,"Blocked court arrival")
  for name,p in pairs(art.markers)do
   assert(#workspace:GetPartBoundsInBox(CFrame.new(p.Position+Vector3.new(0,3,0)),Vector3.new(3.8,5.5,3.8),overlap)==0,"Blocked court marker "..name);points+=1
   local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=3})
   path:ComputeAsync(art.entry,p.Position+Vector3.new(0,2,0));assert(path.Status==Enum.PathStatus.Success,"No court route "..name);routes+=1
  end
  return {scenes=6,markers=points,pathsFromEntry=routes,actualPlayerWalk=false,worldBinding=false}
 end)
 art.model:Destroy();if not ok then error(result)end;return result
end
