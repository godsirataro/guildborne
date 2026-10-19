--!strict
-- Read-only presentation projection. Geometry membership never admits travel.
local Walking = {}
local DEFINITIONS:any = {
 city_greenwood_west={model="CityGreenwoodCorridor",fromZone="City",toZone="Greenwood"},
 greenwood_ironveil_south={model="GreenwoodIronveilCorridor",fromZone="Greenwood",toZone="Ironveil"},
}
local function finite(n:any):boolean
 return type(n)=="number" and n==n and math.abs(n)<1000000
end
function Walking.parse(value:any):any
 for id,def in pairs(DEFINITIONS) do
  if value==id.."|"..def.fromZone.."|"..def.toZone then return {routeId=id,fromZone=def.fromZone,toZone=def.toZone} end
  if value==id.."|"..def.toZone.."|"..def.fromZone then return {routeId=id,fromZone=def.toZone,toZone=def.fromZone} end
 end
 return nil
end
function Walking.validate(route:any):any
 if type(route)~="table" then return nil end
 local def=DEFINITIONS[route.routeId]
 if not def or route.fromZone~=def.fromZone or route.toZone~=def.toZone
  or route.width~=24 or route.below~=4 or route.above~=14 or route.pointKind~="FloorCenter" or type(route.points)~="table" then return nil end
 local count=#route.points
 if count<2 or count>256 then return nil end
 local seen=0
 for key in pairs(route.points) do
  if type(key)~="number" or key%1~=0 or key<1 or key>count then return nil end
  seen+=1
 end
 if seen~=count then return nil end
 for i,rawPoint in ipairs(route.points) do
  local p:any=rawPoint
  if type(p)~="table" or p.index~=i or not finite(p.x) or not finite(p.y) or not finite(p.z) then return nil end
  for j=1,i-1 do
   local q=route.points[j]
   if (p.x-q.x)^2+(p.z-q.z)^2<0.01 then return nil end
  end
 end
 return route
end
local function readModel(model:any,city:any?):any
 local nodes:any=nil
 for _,rawChild in ipairs(model:GetChildren()) do
  local child:any=rawChild
  if child.Name=="NavigationNodes" then
   if nodes then return nil end
   nodes=child
  end
 end
 if not nodes or not nodes:IsA("Folder") then return nil end
 local route:any={routeId=model:GetAttribute("RouteId"),fromZone=model:GetAttribute("FromZone"),toZone=model:GetAttribute("ToZone"),
  width=model:GetAttribute("WalkWidth"),below=model:GetAttribute("NavigationBelowFloor"),above=model:GetAttribute("NavigationAboveFloor"),
  pointKind=model:GetAttribute("NavigationPointKind"),points={}}
 local children=nodes:GetChildren()
 if #children<2 or #children>256 then return nil end
 for _,rawNode in ipairs(children) do
  local node:any=rawNode
  local index=node:GetAttribute("Index")
  if not node:IsA("Vector3Value") or not finite(index) or index%1~=0 or index<1 or index>#children
   or node.Name~=string.format("%03d",index) or route.points[index] then return nil end
  local value=node.Value
  route.points[index]={index=index,x=value.X,y=value.Y,z=value.Z}
 end
 if not Walking.validate(route) then return nil end
 -- A consecutive streamed prefix is incomplete unless both endpoint domains match.
 if city then
  local function inZone(point:any,zone:string):boolean
   return if zone=="City" then city.contains(point.x,point.z) else city.region(point.x,point.z)==zone
  end
  if not inZone(route.points[1],route.fromZone) or not inZone(route.points[#route.points],route.toZone) then return nil end
 end
 return route
end
function Walking.read(world:any,character:any,city:any?):any
 local result:any={routes={}}
 if character then
  local humanoid=character:FindFirstChildOfClass("Humanoid")
  if humanoid and finite(humanoid.Health) and humanoid.Health>0 then
   result.transit=Walking.parse(character:GetAttribute("WalkingRouteContext"))
  end
 end
 local root=world and (if world.Name=="GuildborneWorld" then world else world:FindFirstChild("GuildborneWorld"))
 if not root then return result end
 local children=root:GetChildren()
 for id,def in pairs(DEFINITIONS) do
  local candidate:any=nil
  local count=0
  for _,rawChild in ipairs(children) do
   local child:any=rawChild
   -- Duplicate names or RouteIds are ambiguous even when one candidate is malformed.
   if child.Name==def.model or child:GetAttribute("RouteId")==id then
    count+=1
    candidate=child
   end
  end
  if count==1 and candidate and candidate:IsA("Model") and candidate.Name==def.model
   and candidate:GetAttribute("RouteId")==id then
   result.routes[id]=readModel(candidate,city)
  end
 end
 -- Geometry proximity never selects transit. Only the exact server tuple does.
 if result.transit then result.route=result.routes[result.transit.routeId] end
 return result
end
function Walking.next(route:any,transit:any,x:number,y:number,z:number):any
 if not Walking.validate(route) or type(transit)~="table" or transit.routeId~=route.routeId
  or not Walking.parse(route.routeId.."|"..tostring(transit.fromZone).."|"..tostring(transit.toZone))
  or not finite(x) or not finite(y) or not finite(z) then return nil end
 local forward=transit.fromZone==route.fromZone
 local bestIndex:any=nil
 local bestDistance=math.huge
 for i=1,#route.points-1 do
  local a,b=route.points[i],route.points[i+1]
  local dx,dz=b.x-a.x,b.z-a.z
  local t=((x-a.x)*dx+(z-a.z)*dz)/(dx*dx+dz*dz)
  -- Flat segment end planes prevent proximity beyond the route granting a leg.
  if t<0 or t>1 then continue end
  local floor=a.y+(b.y-a.y)*t
  local distance=(x-a.x-dx*t)^2+(z-a.z-dz*t)^2
  if distance>(route.width/2)^2 or y<floor-route.below or y>floor+route.above then continue end
  local index=if forward then i+1 else i
  if distance<bestDistance or (distance==bestDistance and bestIndex and (if forward then index>bestIndex else index<bestIndex)) then
   bestIndex=index;bestDistance=distance
  end
 end
 if not bestIndex then return nil end
 local point=route.points[bestIndex]
 -- At an internal bend, expose the following leg only close to the bend itself.
 if (x-point.x)^2+(z-point.z)^2<=4^2 then
  local following=bestIndex+(if forward then 1 else -1)
  if route.points[following] then bestIndex=following;point=route.points[following] end
 end
 return {x=point.x,y=point.y,z=point.z,index=bestIndex,final=false,guidance="walking"}
end
return Walking
