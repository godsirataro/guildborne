--!strict
-- Read-only geometry/access check, not progression acceptance.
return function():any
 local C=require(game.ReplicatedStorage.Shared.Config.CivicCities)
 local City=require(game.ReplicatedStorage.Shared.Config.City)
 local world=workspace.GuildborneWorld;local rows={}
 for _,id in ipairs(C.Order)do
  local model=world:FindFirstChild(id) :: Model;assert(model)
  local d=(City.Destinations :: any)[id];local origins={Vector3.new(d.X,d.Y,d.Z),Vector3.new(d.FallbackX,d.Y,d.FallbackZ)}
  local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={model};overlap.RespectCanCollide=true
  local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={model};ray.RespectCanCollide=true
  for _,v in ipairs(origins)do assert(#workspace:GetPartBoundsInBox(CFrame.new(v),Vector3.new(4,5,4),overlap)==0);assert(workspace:Raycast(v,Vector3.new(0,-10,0),ray))end
  local routes={}
  for _,name in ipairs({"Market","Forge","Tavern","QuestHall","Landmark","GuildIslandPortal","RegionalGate"})do
   local marker=model:FindFirstChild(name) :: BasePart
   local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false})
   path:ComputeAsync(origins[1],marker.Position);assert(path.Status==Enum.PathStatus.Success,id.." "..name)
   table.insert(routes,name)
  end
  local prompts=0;for _,v in ipairs(model:GetDescendants())do if v:IsA("ProximityPrompt")then prompts+=1 end end
  assert(prompts==6)
  for name,service in pairs((C.Services :: any)[id])do
   local station=model:FindFirstChild(name) :: BasePart;assert(station:GetAttribute("CivicService")==name and station:FindFirstChild("OpenCivicService"))
   local def=(C.Definitions :: any)[id];assert(math.abs(station.Position.X-def.X-service.X)<.01 and math.abs(station.Position.Z-def.Z-service.Z)<.01)
  end
  local host=model:FindFirstChild("host_"..string.lower(id)) :: Model;assert(host and host.PrimaryPart)
  local approach=host.PrimaryPart.Position+host.PrimaryPart.CFrame.LookVector*7+Vector3.new(0,3,0)
  assert(#workspace:GetPartBoundsInBox(CFrame.new(approach),Vector3.new(4,5,4),overlap)==0)
  local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false});path:ComputeAsync(origins[1],approach);assert(path.Status==Enum.PathStatus.Success)
  assert((approach-host.PrimaryPart.Position).Magnitude<=10)
  table.insert(rows,{id=id,paths=#routes+1,clearLandings=2,prompts=prompts,hostInRange=true})
 end
 return {cities=rows,profileWrites=0,readOnly=true}
end
