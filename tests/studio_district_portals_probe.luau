--!strict
-- Read-only landing, prompt registration and no-jump route checks.
return function():any
 local config=require(game.ReplicatedStorage.Shared.Config.City);local town=workspace.GuildborneWorld.City
 local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={town};params.RespectCanCollide=true;params.CollisionGroup="GuildborneCharacters"
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={town};ray.RespectCanCollide=true;ray.CollisionGroup="GuildborneCharacters"
 local gates={};for _,p in ipairs(town:GetDescendants())do if p:IsA("BasePart")and p:GetAttribute("CityReturnStop")then gates[p:GetAttribute("CityReturnStop")]=p end end
 local landings=0;local paths=0
 for id,definition in pairs(config.GuildPortalStops)do
  local d:any=definition
  local gate=assert(gates[id],id);assert(gate:GetAttribute("TravelDestination")=="Guild")
  local prompts=0;for _,p in ipairs(gate:GetChildren())do if p:IsA("ProximityPrompt")then prompts+=1 end end;assert(prompts==2)
  for _,p in ipairs({Vector3.new(d.ReturnX,5,d.ReturnZ),Vector3.new(d.FallbackX,5,d.FallbackZ)})do
   assert(#workspace:GetPartBoundsInBox(CFrame.new(p),Vector3.new(4,5,4),params)==0,"Blocked landing "..id)
   local hit=workspace:Raycast(p+Vector3.new(0,8,0),Vector3.new(0,-20,0),ray);assert(hit and math.abs(hit.Position.Y-.5)<2,"No landing ground "..id);landings+=1
   local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=4})
   path:ComputeAsync(p,Vector3.new(d.X,4,d.Z+3));assert(path.Status==Enum.PathStatus.Success,"No gate route "..id);paths+=1
  end
 end
 return {stops=4,landings=landings,paths=paths,profileWrites=0,readOnly=true}
end
