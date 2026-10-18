--!strict
-- Read-only presentation projection. Geometry membership never admits travel.
local Walking = {}
local ID = "city_greenwood_west"
local function finite(n:any):boolean
 return type(n)=="number" and n==n and math.abs(n)<1000000
end
function Walking.parse(value:any):any
 if value==ID.."|City|Greenwood" then return {routeId=ID,fromZone="City",toZone="Greenwood"} end
 if value==ID.."|Greenwood|City" then return {routeId=ID,fromZone="Greenwood",toZone="City"} end
 return nil
end
function Walking.validate(route:any):any
 if type(route)~="table" or route.routeId~=ID or route.fromZone~="City" or route.toZone~="Greenwood"
  or route.width~=24 or route.below~=4 or route.above~=14 or route.pointKind~="FloorCenter" or type(route.points)~="table" then return nil end
 local count=#route.points
 if count<2 or count>256 then return nil end
 local seen=0
 for key in pairs(route.points) do
  if type(key)~="number" or key%1~=0 or key<1 or key>count then return nil end
  seen+=1
 end
 if seen~=count then return nil end
 for i,p in ipairs(route.points) do
  if type(p)~="table" or p.index~=i or not finite(p.x) or not finite(p.y) or not finite(p.z) then return nil end
  for j=1,i-1 do
   local q=route.points[j]
   if (p.x-q.x)^2+(p.z-q.z)^2<0.01 then return nil end
  end
 end
 return route
end
function Walking.read(world:any,character:any,city:any?):any
 local result:any={}
 if character then
  local humanoid=character:FindFirstChildOfClass("Humanoid")
  if humanoid and finite(humanoid.Health) and humanoid.Health>0 then
   result.transit=Walking.parse(character:GetAttribute("WalkingRouteContext"))
  end
 end
 local root=world and (if world.Name=="GuildborneWorld" then world else world:FindFirstChild("GuildborneWorld"))
 local model=root and root:FindFirstChild("CityGreenwoodCorridor")
 if not model or not model:IsA("Model") then return result end
 local nodes=model:FindFirstChild("NavigationNodes")
 if not nodes or not nodes:IsA("Folder") then return result end
 local route:any={routeId=model:GetAttribute("RouteId"),fromZone=model:GetAttribute("FromZone"),toZone=model:GetAttribute("ToZone"),
  width=model:GetAttribute("WalkWidth"),below=model:GetAttribute("NavigationBelowFloor"),above=model:GetAttribute("NavigationAboveFloor"),
  pointKind=model:GetAttribute("NavigationPointKind"),points={}}
 local children=nodes:GetChildren()
 if #children<2 or #children>256 then return result end
 for _,node in ipairs(children) do
  local index=node:GetAttribute("Index")
  if not node:IsA("Vector3Value") or not finite(index) or index%1~=0 or index<1 or index>#children
   or node.Name~=string.format("%03d",index) or route.points[index] then return result end
  local value=node.Value
  route.points[index]={index=index,x=value.X,y=value.Y,z=value.Z}
 end
 result.route=Walking.validate(route)
 -- Streaming may expose a consecutive prefix. Its last node is not a travel
 -- endpoint unless it reaches the actual destination region in the city config.
 if result.route and city then
  local first,last=route.points[1],route.points[#route.points]
  if not city.contains(first.x,first.z) or city.region(last.x,last.z)~="Greenwood" then result.route=nil end
 end
 return result
end
function Walking.next(route:any,transit:any,x:number,y:number,z:number):any
 if not Walking.validate(route) or type(transit)~="table" or transit.routeId~=ID
  or not Walking.parse(ID.."|"..tostring(transit.fromZone).."|"..tostring(transit.toZone))
  or not finite(x) or not finite(y) or not finite(z) then return nil end
 local forward=transit.fromZone=="City"
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
