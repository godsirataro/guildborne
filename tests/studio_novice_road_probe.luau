--!strict
-- Read-only Studio probe: pass an explicit live Model or owner UserId.
local V = Vector3.new
local expected: {[string]: Vector3} = {
 Arrival=V(0,3,214), CourierCamp=V(-65,3,153), TrainingYard=V(65,3,90),
 CaravanRescue=V(-84,3,25), CaravanSupplies=V(-46,3,25), CaravanRejoin=V(-65,3,4),
 CrossroadsKeeper=V(65,3,-40), Discipline_Warrior=V(-97,3,-113),
 Discipline_Knight=V(-81,3,-113), Discipline_Archer=V(-65,3,-113),
 Discipline_Mage=V(-49,3,-113), Discipline_Priest=V(-33,3,-113),
 FiveDisciplines=V(-65,3,-98), HallForecourt=V(0,3,-157), HallInterior=V(0,3,-192),
}

return function(target: Model | number): any
 local root: Model
 if typeof(target)=="number" then
  assert(target==target and target>0 and target%1==0,"Expected positive owner UserId")
  local found=workspace:FindFirstChild("NoviceCourse_"..tostring(target))
  assert(found and found:IsA("Model"),"Explicit owner course is not present")
  root=found
  assert(root:GetAttribute("OwnerUserId")==target,"Course ownership mismatch")
 else
  assert(typeof(target)=="Instance" and target:IsA("Model"),"Pass explicit Model or owner UserId")
  root=target
 end
 assert(root:IsDescendantOf(workspace),"Probe requires a live Workspace model")
 local runtime=root:GetAttribute("CoursePrototype")==true
 if runtime then
  assert(root.ModelStreamingMode==Enum.ModelStreamingMode.Atomic,"Runtime course must be Atomic")
  local owner=root:GetAttribute("OwnerUserId")
  assert(typeof(owner)=="number" and root.Name=="NoviceCourse_"..tostring(owner),"Invalid runtime course identity")
 else
  assert(root.Name=="CrownRoad" and root:GetAttribute("ReviewOnly")==true,"Not an explicit Crown Road review model")
 end
 local pivot=root:GetPivot()
 local markers: {[string]: BasePart}={}
 local markerCount=0
 local geometry={}
 local parts,colliders,visible=0,0,0
 for _,p in ipairs(root:GetDescendants()) do
  if p:IsA("BasePart") and p:GetAttribute("Stage")~=nil then
   parts+=1
   assert(p.Anchored and not p.CanTouch,"Art physics flags: "..p.Name)
   if p.CanCollide then colliders+=1 end
   if p.Transparency<1 then visible+=1 end
   local cf=pivot:ToObjectSpace(p.CFrame)
   for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
    -- A wedge omits these two bounding-box corners; check all six real vertices.
    if p:IsA("WedgePart") and y>0 and z<0 then continue end
    local corner=cf:PointToWorldSpace(V(x*p.Size.X/2,y*p.Size.Y/2,z*p.Size.Z/2))
    assert(math.abs(corner.X)<=150.001 and math.abs(corner.Z)<=225.001,"Art exceeds owner plot: "..p.Name)
   end end end
   if p:GetAttribute("RouteDestination")==true then
    assert(p.Parent==root,"Route marker must remain a direct child: "..p.Name)
    local position=expected[p.Name]
    assert(position and not markers[p.Name],"Unexpected or duplicate art marker: "..p.Name)
    assert((cf.Position-position).Magnitude<0.001,"Moved route marker: "..p.Name)
    markers[p.Name]=p;markerCount+=1
   end
   table.insert(geometry,{
    name=p.Name,class=p.ClassName,stage=p:GetAttribute("Stage"),
    routeDestination=p:GetAttribute("RouteDestination")==true,
    position={cf.Position.X,cf.Position.Y,cf.Position.Z},cframe={cf:GetComponents()},
    size={p.Size.X,p.Size.Y,p.Size.Z},color={p.Color.R,p.Color.G,p.Color.B},
    material=p.Material.Name,shape=if p:IsA("Part") then p.Shape.Name else p.ClassName,
    transparency=p.Transparency,collision=p.CanCollide,canQuery=p.CanQuery,
    canTouch=p.CanTouch,anchored=p.Anchored,
   })
  end
 end
 assert(markerCount==15,"Expected exactly 15 authored route markers")
 assert(parts<=650,"Authored art exceeds 650-part budget")
 assert(colliders==61,"Authored art must preserve all 61 baseline colliders")
 for name in pairs(expected) do assert(markers[name],"Missing marker: "..name) end
 local function staticWarning(name: string, position: Vector3, size: Vector3, color: Color3)
  local p=root:FindFirstChild(name)
  assert(p and p:IsA("BasePart"),"Missing static warning: "..name)
  local cf=pivot:ToObjectSpace(p.CFrame)
  local _,angle=cf.Rotation:ToAxisAngle()
  assert((cf.Position-position).Magnitude<0.001 and math.abs(angle)<0.001,"Moved static warning: "..name)
  assert((p.Size-size).Magnitude<0.001 and p.Transparency==0,"Changed visible warning footprint: "..name)
  assert(p.Color==color and not p.CanCollide,"Changed warning appearance/collision: "..name)
 end
 staticWarning("DodgeWarning",V(65,.1,99),V(12,.1,12),Color3.fromRGB(207,95,55))
 staticWarning("KeeperWarning",V(65,.13,-40),V(18,.06,9),Color3.fromRGB(206,102,64))
 local navigation=game:GetService("PathfindingService")
 local routes={}
 local function route(name: string, destination: Vector3, origin: Vector3?)
  local start=origin or markers.Arrival.Position
  local path=navigation:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=6})
  path:ComputeAsync(start,destination)
  assert(path.Status==Enum.PathStatus.Success,"No walk route: "..name)
  local points=path:GetWaypoints()
  assert(#points>0,"Empty walk route: "..name)
  local distance=0;local last=start
  for _,point in ipairs(points) do
   assert(point.Action~=Enum.PathWaypointAction.Jump,"Jump required: "..name)
   distance+=(point.Position-last).Magnitude;last=point.Position
  end
  assert(distance<700,"Route exceeds 700 studs: "..name)
  local localStart=pivot:PointToObjectSpace(start)
  local localEnd=pivot:PointToObjectSpace(destination)
  table.insert(routes,{name=name,studs=distance,waypoints=#points,
   from={localStart.X,localStart.Y,localStart.Z},to={localEnd.X,localEnd.Y,localEnd.Z}})
 end
 for name,p in pairs(markers) do if name~="Arrival" then route(name,p.Position) end end
 local approach=pivot:PointToWorldSpace(V(-65,3,150))
 route("CourierApproach",approach)
 -- Connected corridor checks supplement, rather than replace, the Arrival fan-out.
 local captiveApproach=pivot:PointToWorldSpace(V(80,3,89))
 local tracksApproach=pivot:PointToWorldSpace(V(-65,3,53))
 route("CourierToTraining",markers.TrainingYard.Position,approach)
 route("TrainingToPracticeCaptiveApproach",captiveApproach,markers.TrainingYard.Position)
 route("TrainingToCaravanTracks",tracksApproach,markers.TrainingYard.Position)
 route("TracksToRescue",markers.CaravanRescue.Position,tracksApproach)
 route("TracksToSupplies",markers.CaravanSupplies.Position,tracksApproach)
 route("RescueToRejoin",markers.CaravanRejoin.Position,markers.CaravanRescue.Position)
 route("SuppliesToRejoin",markers.CaravanRejoin.Position,markers.CaravanSupplies.Position)
 local runtimeAnchors={}
 if runtime then
  local function runtimeMarker(name: string, position: Vector3)
   local p=root:FindFirstChild(name)
   assert(p and p:IsA("BasePart"),"Missing runtime marker: "..name)
   assert((pivot:PointToObjectSpace(p.Position)-position).Magnitude<0.001,"Moved runtime marker: "..name)
   assert(not p.CanCollide and p.Anchored,"Changed runtime marker physics: "..name)
   table.insert(runtimeAnchors,{name=name,kind="marker",position={position.X,position.Y,position.Z}})
  end
  runtimeMarker("PracticeCaptive",V(80,3,86))
  runtimeMarker("CaravanTracks",V(-65,.12,53))
  -- These exact direct-child actor names and pivots are authored by NoviceCourseWorld.
  -- Do not assert anchoring of animated NPC body parts or route through actor centers.
  local function actorAnchor(name: string, position: Vector3)
   local actor=root:FindFirstChild(name)
   assert(actor and actor:IsA("Model"),"Missing corridor actor: "..name)
   assert(actor:GetAttribute("OwnerUserId")==root:GetAttribute("OwnerUserId"),"Actor ownership mismatch: "..name)
   assert((pivot:PointToObjectSpace(actor:GetPivot().Position)-position).Magnitude<0.01,"Moved corridor actor pivot: "..name)
   table.insert(runtimeAnchors,{name=name,kind="actor",position={position.X,position.Y,position.Z}})
  end
  actorAnchor("CaravanHelper",V(-79,0,31))
  actorAnchor("dwarf_traveler",V(-87,0,25))
  route("RescueToHelperApproach",pivot:PointToWorldSpace(V(-79,3,35)),markers.CaravanRescue.Position)
  route("RescueToTravelerApproach",pivot:PointToWorldSpace(V(-87,3,29)),markers.CaravanRescue.Position)
  local courier=root:FindFirstChild("Courier")
  assert(courier and courier:IsA("BasePart"),"Missing runtime courier prompt host")
  assert((pivot:PointToObjectSpace(courier.Position)-V(-65,3,149)).Magnitude<0.001,"Moved courier host")
  local prompt=courier:FindFirstChild("CourierInteraction")
  assert(prompt and prompt:IsA("ProximityPrompt"),"Missing courier interaction")
  assert(prompt.MaxActivationDistance==12 and not prompt.RequiresLineOfSight,"Changed courier prompt reach")
  assert((approach-courier.Position).Magnitude<=12,"Approach outside server interaction radius")
  local walk=root:FindFirstChild("CourierPathMarker")
  assert(walk and walk:IsA("BasePart"),"Missing runtime courier walk marker")
  assert((pivot:PointToObjectSpace(walk.Position)-V(0,.12,153)).Magnitude<0.001,"Moved courier walk marker")
  route("CourierPathMarker",pivot:PointToWorldSpace(V(0,3,153)))
 end
 table.sort(routes,function(a,b) return a.name<b.name end)
 return {
  model=root:GetFullName(),ownerUserId=root:GetAttribute("OwnerUserId"),runtime=runtime,
  parts=parts,colliders=colliders,visibleParts=visible,markerCount=markerCount,
  routes=routes,runtimeAnchors=runtimeAnchors,artBudget=650,colliderBudget=61,width=300,depth=450,gameplayBound=false,
  scope="Static Stage-tagged art and read-only navigation; no NPC physics or quest receipt acceptance",
  geometryJSON=game:GetService("HttpService"):JSONEncode(geometry),
 }
end
