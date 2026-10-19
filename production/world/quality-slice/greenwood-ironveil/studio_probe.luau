--!strict
-- Controller-only, explicitly activated Memory preview. No movement/profile writes.
-- NOT_RUN: this file is a probe recipe, not native test evidence.
return function(world: Instance): any
 assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0,"Memory Studio preview only")
 local model=world:FindFirstChild("GreenwoodIronveilCorridor")
 assert(model and model:IsA("Model"),"Missing explicitly activated second route")
 assert(model:GetAttribute("RouteId")=="greenwood_ironveil_south","Wrong route identity")
 assert(model:GetAttribute("FromZone")=="Greenwood" and model:GetAttribute("ToZone")=="Ironveil","Wrong endpoint metadata")
 assert(model:GetAttribute("WalkWidth")==24 and model:GetAttribute("NavigationPointKind")=="FloorCenter","Wrong navigation convention")
 assert(model:GetAttribute("NavigationBelowFloor")==4 and model:GetAttribute("NavigationAboveFloor")==14,"Wrong height metadata")
 local folder=model:FindFirstChild("NavigationNodes");assert(folder,"Missing floor navigation")
 local nodes={}
 for _,v in ipairs(folder:GetChildren())do if v:IsA("Vector3Value")then table.insert(nodes,v)end end
 table.sort(nodes,function(a,b)return (a:GetAttribute("Index") :: number)<(b:GetAttribute("Index") :: number)end)
 assert(#nodes==10,"Unexpected floor node count")
 local colliders=0
 for _,part in ipairs(model:GetChildren())do
  if part:IsA("BasePart")and string.sub(part.Name,1,5)=="Road_"then
   assert(part.Anchored and part.CanCollide and part.CanQuery and not part.CanTouch,"Bad road flags")
   colliders+=1
  end
 end
 assert(colliders==36,"Unexpected collider count")
 local rays={};local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={model}
 for i,v in ipairs(nodes)do
  assert(v:GetAttribute("Index")==i,"Nonconsecutive navigation index")
  local tangent=(nodes[math.min(#nodes,i+1)].Value-nodes[math.max(1,i-1)].Value).Unit
  local side=Vector3.new(tangent.Z,0,-tangent.X)
  for _,offset in ipairs({-11.5,0,11.5})do
   local position=v.Value+side*offset
   local hit=workspace:Raycast(position+Vector3.new(0,4,0),Vector3.new(0,-8,0),params)
   table.insert(rays,{index=i,offset=offset,ok=hit~=nil and math.abs((hit :: RaycastResult).Position.Y-v.Value.Y)<0.02,expectedY=v.Value.Y,actualY=if hit then hit.Position.Y else nil})
  end
 end
 local points={Vector3.new(60,7,1495)}
 for _,node in ipairs(nodes)do table.insert(points,node.Value+Vector3.new(0,3,0))end
 table.insert(points,Vector3.new(400,7,1500))
 local paths={}
 for direction=1,2 do
  for i=1,#points-1 do
   local a,b=points[i],points[i+1];if direction==2 then a,b=b,a end
   local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=8})
   local ok,err=pcall(function()path:ComputeAsync(a,b)end)
   table.insert(paths,{index=i,direction=direction,ok=ok and path.Status==Enum.PathStatus.Success,status=if ok then tostring(path.Status)else tostring(err),waypoints=if ok then #path:GetWaypoints()else 0})
   path:Destroy()
  end
 end
 return {scope="ENGINE_FLOOR_AND_PATHS_ONLY_NOT_ACTUAL_PLAYER_OR_PARTY_ACCEPTANCE",colliders=colliders,nodes=#nodes,rays=rays,paths=paths}
end
