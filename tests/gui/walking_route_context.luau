--!strict
-- Pure behavior suite; mocked Instance reads are not Studio evidence.
local W=require("../../src/client/UI/Components/WalkingRouteContext")
return function(test:any,_eq:any)
local function route():any
 return {routeId="city_greenwood_west",fromZone="City",toZone="Greenwood",width=24,below=4,above=14,pointKind="FloorCenter",
  points={{index=1,x=0,y=0,z=0},{index=2,x=0,y=2,z=100},{index=3,x=-100,y=2,z=100},{index=4,x=-100,y=4,z=200}}}
end
local forward=W.parse("city_greenwood_west|City|Greenwood")
local reverse=W.parse("city_greenwood_west|Greenwood|City")
test("exact atomic context only",function()
 assert(forward.fromZone=="City" and reverse.fromZone=="Greenwood")
 local invalid:{any}={false,{},"", "city_greenwood_west|City", "city_greenwood_west|City|City", "city_greenwood_west|City|Greenwood ", "other|City|Greenwood", "city_greenwood_west|City|Greenwood|extra"}
 for _,value in ipairs(invalid)do assert(W.parse(value)==nil)end
 assert(W.parse(nil)==nil)
end)
test("strict metadata and ordered finite points",function()
 assert(W.validate(route()))
 for key,value in pairs({routeId="other",fromZone="Greenwood",toZone="City",width=25,below=3,above=15,pointKind="PartCenter"})do local r=route();r[key]=value;assert(not W.validate(r))end
 for _,value in ipairs({math.huge,0/0,1000000})do local r=route();r.points[2].x=value;assert(not W.validate(r))end
 local r=route();r.points[2].index=3;assert(not W.validate(r))
 r=route();r.points[2]=table.clone(r.points[1]);r.points[2].index=2;assert(not W.validate(r))
 r=route();r.points.extra={};assert(not W.validate(r))
 r=route();r.points={r.points[1]};assert(not W.validate(r))
end)
test("both directions follow actual bends",function()
 local r=route()
 assert(W.next(r,forward,0,4,30).index==2)
 assert(W.next(r,forward,-40,4,100).index==3)
 assert(W.next(r,forward,-100,6,150).index==4)
 assert(W.next(r,reverse,-100,6,150).index==3)
 assert(W.next(r,reverse,-40,4,100).index==2)
 assert(W.next(r,reverse,0,4,30).index==1)
 assert(W.next(r,forward,0,4,98).index==3)
 assert(W.next(r,reverse,-98,4,100).index==2)
 assert(W.next(r,forward,-100,4,200).final==false)
end)
test("no membership admission or stale malformed context",function()
 local r=route()
 assert(not W.next(r,nil,0,4,30))
 assert(not W.next(r,{routeId="other",fromZone="City",toZone="Greenwood"},0,4,30))
 assert(not W.next(nil,forward,0,4,30))
 assert(not W.next(r,{routeId=r.routeId,fromZone="City",toZone="City"},0,4,30))
end)
test("off lane height end plane and nonfinite rejected",function()
 local r=route()
 assert(not W.next(r,forward,13,4,30))
 assert(not W.next(r,forward,0,15,30))
 assert(not W.next(r,forward,0,-4,30))
 assert(not W.next(r,forward,0,4,-1))
 assert(not W.next(r,forward,0/0,4,30))
 assert(W.next(r,forward,12,4,30))
end)
local function instance(name:string,class:string,attrs:any,children:any):any
 local o:any={Name=name,attrs=attrs or {},children=children or {}}
 function o:IsA(c:string):boolean return class==c end
 function o:GetAttribute(k:string):any return self.attrs[k] end
 function o:GetChildren():any return self.children end
 function o:FindFirstChild(k:string):any for _,rawChild in ipairs(self.children)do local child:any=rawChild;if child.Name==k then return child end end;return nil end
 function o:FindFirstChildOfClass(k:string):any for _,rawChild in ipairs(self.children)do local child:any=rawChild;if child:IsA(k) then return child end end;return nil end
 return o
end
local function fixture(): (any,any,any,any)
 local r=route();local nodes={}
 for i,p in ipairs(r.points)do local node=instance(string.format("%03d",i),"Vector3Value",{Index=i},{});node.Value={X=p.x,Y=p.y,Z=p.z};table.insert(nodes,node)end
 local folder=instance("NavigationNodes","Folder",{},nodes)
 local model=instance("CityGreenwoodCorridor","Model",{RouteId=r.routeId,FromZone=r.fromZone,ToZone=r.toZone,WalkWidth=24,NavigationBelowFloor=4,NavigationAboveFloor=14,NavigationPointKind="FloorCenter"},{folder})
 local world=instance("GuildborneWorld","Model",{},{model})
 local h=instance("Humanoid","Humanoid",{},{});h.Health=100
 local character=instance("Character","Model",{WalkingRouteContext="city_greenwood_west|City|Greenwood"},{h})
 return world,character,model,folder
end
test("live reads clear death replacement attribute and streaming loss",function()
 local world,char,model,folder=fixture()
 assert(W.read(world,char).route and W.read(world,char).transit)
 char.children[1].Health=0;assert(not W.read(world,char).transit)
 char.children[1].Health=100;char.attrs.WalkingRouteContext=nil;assert(not W.read(world,char).transit)
 assert(not W.read(world,nil).transit)
 world.children={};assert(not W.read(world,char).route)
 world.children={model};folder.children[2].attrs.Index=1;assert(not W.read(world,char).route)
end)
test("collector rejects malformed names classes and partial ordering",function()
 local world,char,_,folder=fixture();folder.children[2].Name="2";assert(not W.read(world,char).route)
 world,char,_,folder=fixture();table.remove(folder.children,2);assert(not W.read(world,char).route)
 world,char,_,folder=fixture();folder.children[2]=instance("002","Part",{Index=2},{});assert(not W.read(world,char).route)
 local wrapper=instance("Workspace","Workspace",{},{select(1,fixture())})
 assert(W.read(wrapper,nil).routes.city_greenwood_west and not W.read(wrapper,nil).route)
end)
test("configured endpoint domains reject a consecutively streamed prefix",function()
 local world,char,_,folder=fixture()
 local city={contains=function(x:number,z:number)return x==0 and z==0 end,
  region=function(x:number,z:number)return if x==-100 and z==200 then "Greenwood" else nil end}
 assert(W.read(world,char,city).route)
 table.remove(folder.children,4)
 assert(not W.read(world,char,city).route)
 assert(W.read(world,char,city).transit) -- Admission survives; guidance does not.
end)
local function twoRoutes(): (any,any,any,any)
 local world,char=fixture()
 local _,_,second,folder=fixture()
 second.Name="GreenwoodIronveilCorridor"
 second.attrs.RouteId="greenwood_ironveil_south";second.attrs.FromZone="Greenwood";second.attrs.ToZone="Ironveil"
 table.insert(world.children,second)
 return world,char,second,folder
end
test("second route exact tuple and both directions",function()
 local r=route();r.routeId="greenwood_ironveil_south";r.fromZone="Greenwood";r.toZone="Ironveil"
 local f=W.parse("greenwood_ironveil_south|Greenwood|Ironveil")
 local b=W.parse("greenwood_ironveil_south|Ironveil|Greenwood")
 assert(f and b and W.validate(r))
 assert(W.next(r,f,0,4,30).index==2 and W.next(r,b,0,4,30).index==1)
 assert(not W.next(r,forward,0,4,30))
 assert(not W.next(route(),f,0,4,30))
 assert(not W.parse("greenwood_ironveil_south|City|Ironveil"))
 assert(not W.parse("city_greenwood_west|Greenwood|Ironveil"))
end)
test("two routes selected solely by exact server context",function()
 local world,char=twoRoutes()
 local read=W.read(world,char)
 assert(read.routes.city_greenwood_west and read.routes.greenwood_ironveil_south)
 assert(read.route==read.routes.city_greenwood_west)
 char.attrs.WalkingRouteContext="greenwood_ironveil_south|Ironveil|Greenwood"
 read=W.read(world,char);assert(read.route==read.routes.greenwood_ironveil_south)
 char.attrs.WalkingRouteContext="greenwood_ironveil_south|City|Ironveil"
 read=W.read(world,char);assert(not read.route and not read.transit and read.routes.city_greenwood_west)
 char.attrs.WalkingRouteContext=nil
 read=W.read(world,char);assert(not read.route and read.routes.greenwood_ironveil_south)
end)
test("malformed second route does not poison valid first",function()
 local world,char,second,folder=twoRoutes()
 folder.children[2].Name="bad"
 local read=W.read(world,char)
 assert(read.route and read.routes.city_greenwood_west and not read.routes.greenwood_ironveil_south)
 char.attrs.WalkingRouteContext="greenwood_ironveil_south|Greenwood|Ironveil"
 read=W.read(world,char);assert(read.transit and not read.route)
 second.attrs.FromZone="City"
 assert(not W.read(world,char).routes.greenwood_ironveil_south)
end)
test("duplicate model names or route identities fail only ambiguous identity",function()
 for _,name in ipairs({"GreenwoodIronveilCorridor","DifferentName"}) do
  local world,char=twoRoutes()
  local duplicate=instance(name,"Model",{RouteId="greenwood_ironveil_south"},{})
  table.insert(world.children,duplicate)
  local read=W.read(world,char)
  assert(read.routes.city_greenwood_west and not read.routes.greenwood_ironveil_south)
 end
 local world,char,second=twoRoutes()
 second.attrs.RouteId="city_greenwood_west"
 local read=W.read(world,char);assert(not read.routes.city_greenwood_west and not read.routes.greenwood_ironveil_south)
end)
test("second route endpoint domains reject prefix and reversed metadata",function()
 local world,char,second,folder=twoRoutes()
 char.attrs.WalkingRouteContext="greenwood_ironveil_south|Greenwood|Ironveil"
 local city={contains=function()return false end,region=function(x:number,z:number)
  return if x==0 and z==0 then "Greenwood" elseif x==-100 and z==200 then "Ironveil" else nil end}
 assert(W.read(world,char,city).route)
 table.remove(folder.children,4)
 assert(not W.read(world,char,city).route)
 assert(W.read(world,char,city).transit)
 world,char,second=twoRoutes();second.attrs.FromZone="Ironveil";second.attrs.ToZone="Greenwood"
 assert(not W.read(world,char,city).routes.greenwood_ironveil_south)
end)
test("duplicate node folders and second route streaming disappearance rejected",function()
 local world,char,second,folder=twoRoutes()
 table.insert(second.children,folder)
 assert(not W.read(world,char).routes.greenwood_ironveil_south)
 world,char=twoRoutes();char.attrs.WalkingRouteContext="greenwood_ironveil_south|Greenwood|Ironveil"
 table.remove(world.children,2)
 local read=W.read(world,char);assert(read.transit and not read.route and read.routes.city_greenwood_west)
end)

end
