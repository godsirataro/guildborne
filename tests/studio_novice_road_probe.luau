--!strict
return function():any
 local root=workspace:FindFirstChild("CrownRoad",true) :: Model;assert(root)
 local arrival=root:FindFirstChild("Arrival") :: BasePart;assert(arrival)
 local navigation=game:GetService("PathfindingService");local routes={};local geometry={};local parts=0
 for _,p in ipairs(root:GetDescendants())do if p:IsA("BasePart")then
  parts+=1;assert(p.Anchored and not p.CanTouch)
  if p:GetAttribute("RouteDestination") and p~=arrival then
   local path=navigation:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=6})
   path:ComputeAsync(arrival.Position,p.Position);assert(path.Status==Enum.PathStatus.Success,"No walk route: "..p.Name)
   local distance=0;local last=arrival.Position
   for _,point in ipairs(path:GetWaypoints())do assert(point.Action~=Enum.PathWaypointAction.Jump);distance+=(point.Position-last).Magnitude;last=point.Position end
   assert(distance<700);table.insert(routes,{name=p.Name,studs=distance,waypoints=#path:GetWaypoints()})
  end
  if p.Transparency<1 then
   local cf=root:GetPivot():ToObjectSpace(p.CFrame);local pos=cf.Position
   table.insert(geometry,{name=p.Name,stage=p:GetAttribute("Stage"),position={pos.X,pos.Y,pos.Z},size={p.Size.X,p.Size.Y,p.Size.Z},color={p.Color.R,p.Color.G,p.Color.B},collision=p.CanCollide})
  end
 end end
 table.sort(routes,function(a,b)return a.name<b.name end)
 return {parts=parts,routes=routes,width=300,depth=450,gameplayBound=false,geometryJSON=game:GetService("HttpService"):JSONEncode(geometry)}
end
