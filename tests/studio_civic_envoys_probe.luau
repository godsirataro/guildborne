--!strict
-- Read-only world geometry/metadata and no-jump access checks.
return function():any
 local town=workspace.GuildborneWorld.City;local entries=require(game.ReplicatedStorage.Shared.Config.FriendlyNpcs)
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={town};overlap.RespectCanCollide=true
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={town};ray.RespectCanCollide=true
 local rows={};local count=0
 for id,entry in pairs(entries)do if entry.homeCity then
  count+=1;local m=town:FindFirstChild(id,true) :: Model;assert(m,"Missing civic envoy "..id);local root=assert(m.PrimaryPart)
  assert(m:GetAttribute("HomeCity")==entry.homeCity and m:GetAttribute("NpcId")==id)
  assert(root:GetAttribute("QuestNPC")==entry.name and root:FindFirstChildOfClass("ProximityPrompt"))
  local parts=0;local motors=0;for _,p in ipairs(m:GetDescendants())do if p:IsA("BasePart")then assert(not p.CanCollide and not p.CanTouch and not p.CanQuery);parts+=1 elseif p:IsA("Motor6D")then motors+=1 end end
  local target=root.Position+root.CFrame.LookVector*7;local ground=workspace:Raycast(target+Vector3.new(0,40,0),Vector3.new(0,-80,0),ray)
  local foot=if ground then ground.Position+Vector3.new(0,3,0)else target+Vector3.new(0,3,0)
  local talk=root:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
  assert((root.Position-foot).Magnitude<=talk.MaxActivationDistance,"Envoy out of talk range "..id)
  local blocked={};for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(foot),Vector3.new(4,5,4),overlap))do table.insert(blocked,p:GetFullName())end
  local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=6})
  path:ComputeAsync(Vector3.new(0,5,-720),foot)
  table.insert(rows,{id=id,city=entry.homeCity,parts=parts,motors=motors,ground=ground and ground.Instance:GetFullName(),blocked=blocked,path=path.Status.Name,x=foot.X,y=foot.Y,z=foot.Z})
 end end
 assert(count==6)
 return {envoys=rows,count=count,profileWrites=0,readOnly=true}
end
