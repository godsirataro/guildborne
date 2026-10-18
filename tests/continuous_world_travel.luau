--!strict
-- Actual TravelService with deterministic platform doubles; no Studio acceptance.
return function(test:any,eq:any)
 local Service=require("../src/server/Services/TravelService")
 local City=require("../src/shared/Config/City")
 test("walking OBB respects rotation height and rejects malformed nonfinite dimensions",function()
  -- Ninety-degree yaw around a translated center: local X is world Z, local Z is -world X.
  local frame={PointToObjectSpace=function(_self:any,p:any)return {X=p.Z-20,Y=p.Y-5,Z=-(p.X-10)}end}
  local volume:any={cframe=frame,size={X=12,Y=8,Z=4}}
  eq(City.walkingContains(volume,{X=11,Y=5,Z=25}),true)
  eq(City.walkingContains(volume,{X=13,Y=5,Z=20}),false)
  eq(City.walkingContains(volume,{X=10,Y=10,Z=20}),false)
  eq(City.walkingContains(volume,{X=12,Y=9,Z=26}),true)
  for _,axis in ipairs({"X","Y","Z"})do
   for _,bad in ipairs({0,-1,0/0,math.huge,-math.huge,4097})do
    local size:any={X=12,Y=8,Z=4};size[axis]=bad
    eq(City.walkingContains({cframe=frame,size=size},{X=10,Y=5,Z=20}),false)
   end
   local point:any={X=10,Y=5,Z=20};point[axis]=0/0;eq(City.walkingContains(volume,point),false)
  end
  eq(City.walkingContains(nil,{X=10,Y=5,Z=20}),false)
  eq(City.walkingContains({cframe={},size=volume.size},{X=10,Y=5,Z=20}),false)
  eq(City.walkingContains(volume,nil),false)
 end)
 local function adapter(disabled:boolean?):any
  local vm:any={};vm.__index=function(v:any,k:string):any if k=="Magnitude" then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end;return nil end
  local function v(x:number,y:number,z:number):any return setmetatable({X=x,Y=y,Z=z},vm) end
  vm.__add=function(a:any,b:any)return v(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
  vm.__sub=function(a:any,b:any)return v(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
  vm.__mul=function(a:any,b:number)return v(a.X*b,a.Y*b,a.Z*b)end
  local function cf(a:any,b:any,c:any):any
   local frame:any={Position=if type(a)=="number" then v(a,b,c) else a}
   function frame:PointToObjectSpace(point:any)return point-self.Position end
   return frame
  end
  local function model():any
   return {Parent=true,attributes={},GetAttribute=function(self:any,k:string)return self.attributes[k]end,SetAttribute=function(self:any,k:string,value:any)self.attributes[k]=value end,IsA=function(_self:any,k:string)return k=="Model"end}
  end
  local f:any={moves=0,velocities=0,heroMoves=0,blocked=false,headBlocked=false,ready=true,session={state="Active",record={},epoch=1,token="a"}}
  local backing:any={Position=v(0,5,0)}
  local root:any=setmetatable({}, {__index=function(_self:any,key:any)if key=="IsA" then return function(_r:any,k:string)return k=="BasePart"end end;return backing[key]end,
   __newindex=function(_self:any,key:any,value:any)backing[key]=value;if key=="AssemblyLinearVelocity" or key=="AssemblyAngularVelocity" then f.velocities+=1 end end})
  local humanoid={Health=100};local character=model()
  function character:FindFirstChild(name:string)return if name=="HumanoidRootPart" then root else nil end
  function character:FindFirstChildOfClass(_name:string)return humanoid end
  function character:GetPivot()return cf(root.Position)end
  function character:PivotTo(target:any)root.Position=target.Position;f.moves+=1 end
  local player:any={Character=character,RespawnLocation="home",attributes={}}
  function player:SetAttribute(key:string,value:any)self.attributes[key]=value end
  function player:GetAttribute(key:string)return self.attributes[key]end
  local town=model();local forest=model();local geometry=model();local plotModel=model()
  local plots={[player]={model=plotModel,origin=v(0,0,0),spawn="home"}}
  local config:any={Destinations={City={X=0,Y=5,Z=0,FallbackX=0,FallbackZ=1},Greenwood={X=100,Y=5,Z=0,FallbackX=100,FallbackZ=1},Guild={X=-100,Y=5,Z=0,FallbackX=-100,FallbackZ=1}},Regions={Greenwood={X=100,Z=0,HalfWidth=10,Back=10,Front=10}},GuildPortalStops={},contains=function(x:number,z:number)return x>=-10 and x<=10 and math.abs(z)<=10 end,region=function(x:number,z:number)return if x>=90 and x<=110 and math.abs(z)<=10 then "Greenwood" else nil end,
   walkingContains=function(volume:any,position:any)return City.walkingContains(volume,position)end}
  local step:any;local now=0
  local world:any={}
  function world:Raycast(target:any,_delta:any,params:any)
   f.lastRayFilter=params.FilterDescendantsInstances
   local supported=not f.blocked
   if f.floorOnly then supported=supported and table.find(params.FilterDescendantsInstances,f.floorOnly)~=nil end
   return if supported then {Position=v(target.X,0,target.Z)} else nil
  end
  function world:GetPartBoundsInBox(_frame:any,_size:any,params:any)
   f.lastHeadFilter=params.FilterDescendantsInstances
   return if f.headBlocked or (f.obstruction and table.find(params.FilterDescendantsInstances,f.obstruction)) then {{}} else {}
  end
  local platform={Config=config,Civic={Definitions={}},Rules=require("../src/server/Systems/TravelRules")(config),Vector3={new=v,zero=v(0,0,0)},CFrame={new=cf,lookAt=function(a:any,_b:any)return cf(a)end},
   RaycastParams={new=function()return {}end},OverlapParams={new=function()return {}end},Enum={RaycastFilterType={Include=1}},Workspace=world,RunService={Heartbeat={Connect=function(_self:any,callback:any)step=callback end}},Now=function()return now end}
  local function box(x:number,width:number):any return {cframe=cf(x,5,0),size=v(width,8,12)}end
  local route={id="city_greenwood_west",fromZone="City",toZone="Greenwood",geometry=geometry,volumes={box(50,110)},entries={City=box(0,10),Greenwood=box(100,10)},safeRecovery={City=cf(0,5,0),Greenwood=cf(100,5,0)},isReady=function()return f.ready end}
  local walking={Routes={route},Session=function(_p:any)return f.session end,Gate=function(_p:any,_s:any,from:string,to:string)
   f.lastGate={from,to};if f.gateThrow then error("fixture gate failure") end;if f.gateYield then coroutine.yield() end;return f.gate
  end}
  local city={town=town,spawn="city",regions={Greenwood={model=forest,spawn="forest"}},guildAccessPortals={}}
  local heroes={Travel=function(_p:any)f.heroMoves+=1 end}
  local localTravel={Session=walking.Session,Gate=function()return nil end,Geometry=geometry,Entry={Position=v(0,5,0),Parent=true},Exit={Position=v(50,5,0),Parent=true},Landing=v(50,5,0),Fallback=v(51,5,0),Contains=function()return true end}
  local service=Service(city,plots,heroes,localTravel,platform,if disabled then nil else walking)
  f.service=service;f.player=player;f.root=root;f.character=character;f.humanoid=humanoid;f.plotModel=plotModel;f.route=route;f.v=v;f.cf=cf;f.plots=plots;f.town=town;f.forest=forest;f.box=box
  function f.resetCounters()f.moves=0;f.velocities=0;f.heroMoves=0 end
  f.config=config;f.city=city;f.walking=walking;f.civic=platform.Civic
  function f.step(x:number?,y:number?,z:number?)if x then root.Position=v(x,y or 5,z or 0)end;now+=.5;step(.5)end
  function f.follow():boolean return service.CanFollowWalking(player,root.Position) end
  function f.source(zone:string)assert(service.Travel(player,zone));f.step();f.resetCounters()end
  f.source("City")
  return f
 end
 test("walking commits both directions in place with source respawn retained in corridor",function()
  local f=adapter();f.step(0);eq(f.follow(),true)
  for _,x in ipairs({25,50,75})do f.step(x);eq(f.player.attributes.CurrentZone,"City");eq(f.player.RespawnLocation,"city")end
  f.step(100);eq(f.player.attributes.CurrentZone,"Greenwood");eq(f.player.RespawnLocation,"forest")
  f.step(100);f.step(98);for _,x in ipairs({75,50,25,0})do f.step(x)end
  eq(f.player.attributes.CurrentZone,"City");eq(f.player.RespawnLocation,"city")
  eq(f.moves,0);eq(f.velocities,0);eq(f.heroMoves,0)
 end)
 test("walking gate refusals readiness busy combat tower and downed fail closed",function()
  for _,reason in ipairs({"gate","ready","busy","combat","tower","downed","wrongSource"})do
   local f=adapter()
   if reason=="gate" then f.gate="MentorActive" elseif reason=="ready" then f.ready=false elseif reason=="busy" then f.session.busy=true
   elseif reason=="combat" then f.plotModel.attributes.InCombat=true elseif reason=="tower" then f.plotModel.attributes.TowerState="Active"
   elseif reason=="downed" then f.character.attributes.CombatHealth=0 else f.source("Guild")end
   f.step(0);eq(f.follow(),false);eq(f.moves,0);eq(f.heroMoves,0)
  end
 end)
 test("walking gate errors and yields cannot admit or strand heartbeat",function()
  for _,mode in ipairs({"gateThrow","gateYield"})do
   local f=adapter();f[mode]=true
   local thread=coroutine.create(function()f.step(0)end);local ok,err=coroutine.resume(thread);assert(ok,tostring(err))
   eq(coroutine.status(thread),"dead");eq(f.follow(),false);eq(f.moves,0)
  end
 end)
 test("walking context invalidates epoch token session or character without snapshot correction",function()
  for _,mode in ipairs({"epoch","token","session","character"})do
   local f=adapter();f.step(0);f.step(25);eq(f.follow(),true)
   if mode=="epoch" then f.session.epoch+=1 elseif mode=="token" then f.session.token="b"
   elseif mode=="session" then f.session=table.clone(f.session) else f.player.Character=table.clone(f.character)end
   f.step(30);eq(f.follow(),false);eq(f.moves,0);eq(f.heroMoves,0);eq(f.root.Position.X,30)
  end
 end)
 test("unadmitted far jump cannot claim destination and admitted jump recovers source",function()
  local f=adapter();f.step(100);eq(f.player.attributes.CurrentZone,"City");eq(f.follow(),false);eq(f.root.Position.X,0)
  f.resetCounters();f.step(0);f.step(0);eq(f.follow(),true);f.step(100)
  eq(f.player.attributes.CurrentZone,"City");eq(f.root.Position.X,0);eq(f.moves,1);eq(f.heroMoves,1)
 end)
 test("vertical escape and removed corridor geometry recover only to verified source",function()
  for _,mode in ipairs({"height","geometry"})do
   local f=adapter();f.step(0);f.step(25)
   if mode=="geometry" then f.route.geometry.Parent=nil end
   f.step(30,if mode=="height" then 30 else 5)
   eq(f.player.attributes.CurrentZone,"City");eq(f.root.Position.X,0);eq(f.moves,1)
  end
 end)
 test("blocked floor or head clearance forbids recovery movement",function()
  for _,mode in ipairs({"blocked","headBlocked"})do
   local f=adapter();f.step(0);f.step(25);f[mode]=true;f.step(90)
   eq(f.moves,0);eq(f.heroMoves,0);eq(f.root.Position.X,90);eq(f.player.attributes.CurrentZone,"City")
  end
 end)
 test("death waits for respawn and remove portal visit local entry clear walking",function()
  local dead=adapter();dead.step(0);dead.step(25);dead.humanoid.Health=0;dead.step(30)
  eq(dead.moves,0);eq(dead.follow(),false);dead.humanoid.Health=100;dead.service.Respawn(dead.player)
  eq(dead.player.attributes.CurrentZone,"City");eq(dead.root.Position.X,0)
  for _,mode in ipairs({"remove","portal","visit","local"})do
   local f=adapter();f.step(0);eq(f.follow(),true)
   if mode=="remove" then f.service.Remove(f.player)
   elseif mode=="portal" then assert(f.service.Travel(f.player,"Guild"))
   elseif mode=="visit" then assert(f.service.Visit(f.player,f.v(-100,5,0)))
   else assert(f.service.EnterLocal(f.player))end
   eq(f.follow(),false)
  end
 end)
 test("optional walking descriptor preserves portal travel and rejects corridor following",function()
  local f=adapter(true);f.step(0);eq(f.follow(),false);assert(f.service.Travel(f.player,"Greenwood"))
  eq(f.player.attributes.CurrentZone,"Greenwood");eq(f.moves,1);eq(f.heroMoves,1)
 end)
 test("walking segment rejects a short unsupported gap even with both endpoints inside",function()
  local f=adapter();f.route.volumes={f.box(10,30),f.box(70,60)}
  f.step(0);f.step(20);eq(f.follow(),true)
  f.step(45) -- 25 studs, but the segment crosses an uncovered gap from x25 to x40.
  eq(f.root.Position.X,0);eq(f.moves,1);eq(f.player.attributes.CurrentZone,"City")
 end)
 test("entry jitter never commits and malformed or unready routes never admit",function()
  local f=adapter();f.step(0)
  for _,x in ipairs({4,-4,3,-3,0})do f.step(x);eq(f.player.attributes.CurrentZone,"City");eq(f.player.RespawnLocation,"city")end
  eq(f.moves,0);eq(f.heroMoves,0)
  for _,mode in ipairs({"unready","empty","wrongZone","missingEntries"})do
   local a=adapter()
   if mode=="unready" then a.ready=false elseif mode=="empty" then a.route.volumes={}
   elseif mode=="wrongZone" then a.route.toZone="Unknown" else a.route.entries=nil end
   a.step(0);eq(a.follow(),false);eq(a.moves,0)
  end
 end)
 test("shared local visit pauses walking and returns without altering the profile record",function()
  local f=adapter();local record=f.session.record;record.marker="unchanged"
  f.step(0);eq(f.follow(),true);assert(f.service.EnterLocal(f.player));f.resetCounters()
  f.step(50);eq(f.service.IsLocal(f.player),true);eq(f.follow(),false);eq(f.moves,0)
  assert(f.service.ReturnLocal(f.player));eq(f.player.attributes.CurrentZone,"City");eq(f.root.Position.X,0)
  eq(f.session.record,record);eq(record.marker,"unchanged");eq(next(record,"marker"),nil)
 end)
 test("walking recovery checks source floor and both source and corridor obstruction filters",function()
  local f=adapter();f.step(0);f.step(25);f.floorOnly=f.town;f.step(90)
  eq(f.root.Position.X,0);eq(f.moves,1)
  eq(table.find(f.lastRayFilter,f.town)~=nil,true)
  for _,owner in ipairs({"town","route"})do
   local a=adapter();a.step(0);a.step(25);a.floorOnly=a.town
   a.obstruction=if owner=="town" then a.town else a.route.geometry
   a.step(90);eq(a.moves,0);eq(a.root.Position.X,90)
   eq(table.find(a.lastHeadFilter,a.town)~=nil,true);eq(table.find(a.lastHeadFilter,a.route.geometry)~=nil,true)
  end
 end)
 test("revoked gate or busy session before destination prevents commit and recovers source",function()
  for _,reason in ipairs({"NoviceJourneyRequired","ReleaseContentUnavailable","FinishExpedition","CivicRouteLocked","busy"})do
   local f=adapter();f.step(0);for _,x in ipairs({25,50,75})do f.step(x)end
   eq(f.follow(),true)
   if reason=="busy" then f.session.busy=true else f.gate=reason end
   f.step(100);eq(f.player.attributes.CurrentZone,"City");eq(f.player.RespawnLocation,"city")
   eq(f.root.Position.X,0);eq(f.moves,1);eq(f.heroMoves,1);eq(f.follow(),false)
  end
 end)
 test("walking display uses only canonical unambiguous route and direction strings",function()
  local rules=require("../src/server/Systems/TravelRules")(City)
  eq(rules.walkingContext("city_greenwood_west","City","Greenwood"),"city_greenwood_west|City|Greenwood")
  eq(rules.walkingContext("city_greenwood_west","Greenwood","City"),"city_greenwood_west|Greenwood|City")
  for _,id in ipairs({"unknown","city_greenwood_west|City","city_greenwood"})do eq(rules.walkingContext(id,"City","Greenwood"),nil)end
  eq(rules.walkingContext("city_greenwood_west","City|Guild","Greenwood"),nil)
  eq(rules.walkingContext("city_greenwood_west","City","City"),nil)
  local f=adapter();eq(f.character:GetAttribute("WalkingRouteContext"),nil)
  f.character:SetAttribute("WalkingRouteContext","city_greenwood_west|City|Greenwood")
  eq(f.follow(),false) -- A presentation attribute never grants admission.
  f.step(0);eq(f.character:GetAttribute("WalkingRouteContext"),"city_greenwood_west|City|Greenwood")
  f.character:SetAttribute("WalkingRouteContext","untrusted|Guild|City")
  for _,x in ipairs({25,50,75,100})do f.step(x)end
  eq(f.player.attributes.CurrentZone,"Greenwood");eq(f.character:GetAttribute("WalkingRouteContext"),nil)
  f.step(100);f.step(98);eq(f.character:GetAttribute("WalkingRouteContext"),"city_greenwood_west|Greenwood|City")
 end)
 test("walking display clears every successful exit and immediately on blocked recovery",function()
  for _,mode in ipairs({"remove","portal","visit","local","respawn","death","recovery","cancel"})do
   local f=adapter();f.step(0);assert(f.character:GetAttribute("WalkingRouteContext"))
   if mode=="remove"then f.service.Remove(f.player)
   elseif mode=="portal"then assert(f.service.Travel(f.player,"Guild"))
   elseif mode=="visit"then assert(f.service.Visit(f.player,f.v(-100,5,0)))
   elseif mode=="local"then assert(f.service.EnterLocal(f.player))
   elseif mode=="respawn"then f.service.Respawn(f.player)
   elseif mode=="death"then f.humanoid.Health=0;f.step()
   elseif mode=="cancel"then f.step(-8) -- Supported source zone, outside entry/corridor.
   else f.step(25);f.blocked=true;f.step(90);eq(f.moves,0)end
   eq(f.character:GetAttribute("WalkingRouteContext"),nil)
  end
 end)
 test("walking replacement clears both old and new character without moving either",function()
  for _,mode in ipairs({"replacement","missing","session"})do
   local f=adapter();f.step(0);f.step(25);local old=f.character
   local replacement=table.clone(old);replacement.attributes={WalkingRouteContext="stale"}
   if mode=="replacement"then f.player.Character=replacement elseif mode=="missing"then f.player.Character=nil else f.session.token="replacement-token"end
   f.step();eq(old:GetAttribute("WalkingRouteContext"),nil)
   if mode=="replacement"then eq(replacement:GetAttribute("WalkingRouteContext"),nil)end
   eq(f.moves,0);eq(f.heroMoves,0)
  end
 end)
 test("normal walking admits on first entry sample without stopping inside the entry",function()
  local f=adapter()
  f.step(-6);eq(f.follow(),false) -- Source-side approach, outside the ten-stud entry.
  f.step(2);eq(f.follow(),true) -- Eight studs per half-second: WalkSpeed 16.
  f.step(10);eq(f.follow(),true) -- Only one observation was inside entry; keep moving.
  for _,x in ipairs({35,60,85,100})do f.step(x)end
  eq(f.player.attributes.CurrentZone,"Greenwood");eq(f.moves,0);eq(f.heroMoves,0);eq(f.velocities,0)
 end)
 test("arrival stays unadmitted while stationary or jittering and permits immediate purposeful return",function()
  for _,reverse in ipairs({false,true})do
   local f=adapter();local destination=if reverse then "City"else "Greenwood"
   if reverse then f.source("Greenwood")end
   local origin=if reverse then 100 else 0;local target=100-origin;local sign=if reverse then -1 else 1
   f.step(origin)
   for _,distance in ipairs({25,50,75,100})do f.step(origin+sign*distance)end
   for _,offset in ipairs({0,0,.4,-.4,.3,-.3,0,0,0})do
    f.step(target+offset);eq(f.character:GetAttribute("WalkingRouteContext"),nil)
    eq(f.follow(),false);eq(f.player.attributes.CurrentZone,destination)
   end
   f.step(target-sign*3);eq(f.follow(),true)
   eq(f.character:GetAttribute("WalkingRouteContext"),"city_greenwood_west|"..destination.."|"..(if reverse then "Greenwood"else "City"))
   eq(f.moves,0);eq(f.velocities,0);eq(f.heroMoves,0)
   -- Recreate arrival, then turn immediately on the next sample without entry exit.
   for _,distance in ipairs({25,50,75,100})do f.step(target-sign*distance)end
   eq(f.character:GetAttribute("WalkingRouteContext"),nil)
   f.route.entries[if reverse then "Greenwood"else "City"]=f.box(origin,30)
   f.step(origin+sign*8);eq(f.follow(),true);eq(f.moves,0) -- Immediate WalkSpeed 16 turnaround.
  end
 end)
 test("nonfinite admitted root movement cannot commit or reach segment interpolation",function()
  for _,bad in ipairs({0/0,math.huge,-math.huge})do
   local f=adapter();f.step(0);f.step(25);f.step(bad)
   eq(f.player.attributes.CurrentZone,"City");eq(f.player.RespawnLocation,"city");eq(f.follow(),false)
   eq(f.root.Position.X,0);eq(f.moves,1)
  end
 end)
 test("arrival at corridor-facing entry edge permits immediate normal-speed reversal across edge",function()
  for _,reverse in ipairs({false,true})do
   local f=adapter();if reverse then f.source("Greenwood")end
   local origin=if reverse then 100 else 0;local sign=if reverse then -1 else 1
   f.step(origin)
   for _,distance in ipairs({25,50,75,95})do f.step(origin+sign*distance)end
   eq(f.character:GetAttribute("WalkingRouteContext"),nil)
   f.step(origin+sign*87);eq(f.follow(),true)
   eq(f.moves,0);eq(f.heroMoves,0);eq(f.velocities,0)
   for _,distance in ipairs({62,37,12,0})do f.step(origin+sign*distance)end
   eq(f.player.attributes.CurrentZone,if reverse then "Greenwood"else "City");eq(f.moves,0)
  end
 end)
 test("boundary jitter and slow turnaround retain validated arrival continuity",function()
  for _,reverse in ipairs({false,true})do
   for _,offsets in ipairs({{.4,.2,.4,3},{1,2}})do
    local f=adapter();if reverse then f.source("Greenwood")end
    local origin=if reverse then 100 else 0;local sign=if reverse then -1 else 1
    f.step(origin);for _,d in ipairs({25,50,75,95})do f.step(origin+sign*d)end
    for _,offset in ipairs(offsets)do
     f.step(origin+sign*(95-offset))
     eq(f.follow(),offset>=2)
     if offset<2 then eq(f.character:GetAttribute("WalkingRouteContext"),nil)end
    end
    f.step(origin+sign*87);eq(f.follow(),true);eq(f.moves,0);eq(f.heroMoves,0)
   end
  end
 end)
 test("hairpin Greenwood approach uses local incoming direction not entry-center axis",function()
  for _,immediate in ipairs({false,true})do
   local f=adapter()
   f.config.contains=function(x:number,z:number)return math.abs(x)<=10 and z>=-680 and z<=-620 end
   f.config.region=function(x:number,z:number)return if math.abs(x)<=10 and z>=1480 and z<=1528 then "Greenwood"else nil end
   f.config.Regions.Greenwood={X=0,Z=1504,HalfWidth=10,Back=24,Front=24}
   f.config.Destinations.City={X=0,Y=5,Z=-650,FallbackX=0,FallbackZ=-649}
   local function box(x:number,z:number,w:number,d:number):any return {cframe=f.cf(x,5,z),size=f.v(w,8,d)}end
   f.route.entries={City=box(0,-650,20,40),Greenwood=box(0,1510,20,40)}
   f.route.volumes={box(25,-650,70,20),box(50,450,20,2220),box(25,1550,70,20),box(0,1525,20,70)}
   f.route.safeRecovery.City=f.cf(0,5,-650);f.route.safeRecovery.Greenwood=f.cf(0,5,1505)
   f.source("City");f.step(0,5,-650);eq(f.follow(),true)
   f.step(25,5,-650);f.step(50,5,-650)
   for z=-625,1550,25 do f.step(50,5,z)end
   f.step(25,5,1550);f.step(0,5,1550)
   -- Actual endpoint shape: incoming -Z is opposite the global City→Greenwood axis.
   f.step(0,5,1526);eq(f.player.attributes.CurrentZone,"Greenwood")
   eq(f.character:GetAttribute("WalkingRouteContext"),nil)
   if immediate then
    f.step(0,5,1534) -- Turn back immediately beyond the entry and zone edge.
   else
    for _,z in ipairs({1518,1515.38,1510,1505,1505,1505})do
     f.step(0,5,z);eq(f.player.attributes.CurrentZone,"Greenwood")
     eq(f.character:GetAttribute("WalkingRouteContext"),nil);eq(f.follow(),false)
    end
    f.step(0,5,1513)
   end
   eq(f.character:GetAttribute("WalkingRouteContext"),"city_greenwood_west|Greenwood|City")
   eq(f.follow(),true);eq(f.moves,0);eq(f.velocities,0);eq(f.heroMoves,0)
  end
 end)
 local function secondRoute(f:any):any
  f.config.Regions.Greenwood.HalfWidth=30
  f.config.Regions.Ironveil={X=200,Z=0,HalfWidth=10,Back=10,Front=10}
  f.config.Destinations.Ironveil={X=200,Y=5,Z=0,FallbackX=200,FallbackZ=1}
  f.config.region=function(x:number,z:number):string?
   if math.abs(z)>10 then return nil end
   return if x>=70 and x<=130 then "Greenwood"else if x>=190 and x<=210 then "Ironveil"else nil
  end
  f.city.regions.Ironveil={model=table.clone(f.forest),spawn="ironveil"}
  local route={id="greenwood_ironveil_south",fromZone="Greenwood",toZone="Ironveil",geometry=table.clone(f.route.geometry),
   volumes={f.box(155,100)},entries={Greenwood=f.box(122,10),Ironveil=f.box(200,10)},
   safeRecovery={Greenwood=f.cf(120,5,0),Ironveil=f.cf(200,5,0)},isReady=function()return true end}
  table.insert(f.walking.Routes,route);return route
 end
 test("two supplied reviewed edges chain through shared zone without stationary readmission",function()
  local f=adapter();secondRoute(f);f.step(0)
  for _,x in ipairs({25,50,75,100})do f.step(x)end
  for _=1,4 do f.step(100);eq(f.character:GetAttribute("WalkingRouteContext"),nil);eq(f.player.attributes.CurrentZone,"Greenwood")end
  f.step(108);f.step(122);eq(f.character:GetAttribute("WalkingRouteContext"),"greenwood_ironveil_south|Greenwood|Ironveil")
  for _,x in ipairs({140,165,190,200})do f.step(x)end
  eq(f.player.attributes.CurrentZone,"Ironveil");eq(f.player.RespawnLocation,"ironveil")
  f.step(198);eq(f.character:GetAttribute("WalkingRouteContext"),"greenwood_ironveil_south|Ironveil|Greenwood")
  for _,x in ipairs({175,150,125})do f.step(x)end
  eq(f.player.attributes.CurrentZone,"Greenwood");eq(f.player.RespawnLocation,"forest")
  f.step(108);f.step(100);eq(f.character:GetAttribute("WalkingRouteContext"),"city_greenwood_west|Greenwood|City")
  for _,x in ipairs({75,50,25,0})do f.step(x)end
  eq(f.player.attributes.CurrentZone,"City");eq(f.moves,0);eq(f.heroMoves,0);eq(f.velocities,0)
 end)
 test("known second edge still requires descriptor and controller eligibility",function()
  local f=adapter();secondRoute(f)
  f.walking.Gate=function(_p:any,_s:any,_from:string,to:string)return if to=="Ironveil"then "InvalidZone"else nil end
  f.step(0);for _,x in ipairs({25,50,75,100,108,122})do f.step(x)end
  eq(f.player.attributes.CurrentZone,"Greenwood");eq(f.player.RespawnLocation,"forest");eq(f.follow(),false)
  eq(f.root.Position.X,120);eq(f.character:GetAttribute("WalkingRouteContext"),nil)
  local g=adapter();secondRoute(g);table.remove(g.walking.Routes,2);g.source("Greenwood");g.step(108);g.step(122)
  eq(g.follow(),false);eq(g.player.attributes.CurrentZone,"Greenwood");eq(g.moves,0)
 end)
 test("unknown duplicate and mismatched route registries fail closed independent of order",function()
  for _,mode in ipairs({"unknown","duplicate","reverseDuplicate","wrongPair","sparse"})do
   for _,reverse in ipairs({false,true})do
    local f=adapter();local second=secondRoute(f)
    if mode=="unknown"then second.id="unknown"
    elseif mode=="duplicate"then f.walking.Routes[2]=f.route
    elseif mode=="reverseDuplicate"then second.id=f.route.id;second.fromZone="Greenwood";second.toZone="City"
    elseif mode=="wrongPair"then second.toZone="Guild"
    else f.walking.Routes[4]=second end
    if reverse then f.walking.Routes[1],f.walking.Routes[2]=f.walking.Routes[2],f.walking.Routes[1]end
    f.step(0);eq(f.follow(),false);eq(f.character:GetAttribute("WalkingRouteContext"),nil);eq(f.moves,0)
   end
  end
 end)
 test("overlapping shared-zone entries reject both orders including just-arrived stationary actor",function()
  for _,reverse in ipairs({false,true})do
   local f=adapter();local second=secondRoute(f);second.entries.Greenwood=f.box(100,10)
   if reverse then f.walking.Routes={second,f.route}end
   f.step(0);for _,x in ipairs({25,50,75,100})do f.step(x)end
   for _,x in ipairs({100,100,102,98})do
    f.step(x);eq(f.follow(),false);eq(f.character:GetAttribute("WalkingRouteContext"),nil)
    eq(f.player.attributes.CurrentZone,"Greenwood");eq(f.player.RespawnLocation,"forest")
   end
   eq(f.moves,0);eq(f.heroMoves,0)
  end
 end)
 test("walking surface resolver supports canonical civic models and excludes private pockets",function()
  local civic=require("../src/shared/Config/CivicCities");local rules:any=require("../src/server/Systems/TravelRules")(City)
  local city:any={town={},spawn="city",regions={Ironveil={model={},spawn="iron"}},civicRegions={}}
  eq(rules.walkingZone(city,civic,"City").model,city.town)
  eq(rules.walkingZone(city,civic,"Ironveil").spawn,"iron")
  for _,id in ipairs(civic.Order)do
   local d=(civic.Definitions :: any)[id];local region={model={},spawn=id};city.civicRegions[id]=region
   eq(rules.walkingZone(city,civic,id),region);eq(rules.walkingSurface(civic,id,{X=d.X,Y=5,Z=d.Z}),true)
   eq(rules.walkingSurface(civic,id,{X=d.X,Y=100,Z=d.Z}),false)
   city.civicRegions[id]=nil;eq(rules.walkingZone(city,civic,id),nil)
  end
  eq(rules.walkingZone(city,civic,"Guild"),nil);eq(rules.walkingZone(city,civic,"Unknown"),nil)
  eq(rules.walkingSurface(civic,"Ironveil",{X=500,Y=5,Z=1400}),true)
  eq(rules.walkingSurface(civic,"Ironveil",{X=500,Y=100,Z=1400}),false)
  eq(rules.walkingSurface(civic,"Ashen",{X=2000,Y=5,Z=1400}),false) -- Private annex excluded even at surface height.
  eq(rules.walkingContext("city_crownford","City","Crownford"),nil) -- Resolver does not approve civic routes.
 end)
 test("elevated mine cannot admit or follow even with injected overlapping route volumes",function()
  local f=adapter();local second=secondRoute(f);f.source("Ironveil")
  second.entries.Ironveil={cframe=f.cf(200,100,0),size=f.v(10,20,12)}
  second.volumes={{cframe=f.cf(155,100,0),size=f.v(110,20,12)}}
  f.step(200,100);f.step(200,100);eq(f.follow(),false)
  eq(f.character:GetAttribute("WalkingRouteContext"),nil);eq(f.player.attributes.CurrentZone,"Ironveil")
  eq(f.moves,0);eq(f.heroMoves,0)
 end)
 test("removing or duplicating an admitted descriptor revokes following and recovers source",function()
  for _,duplicate in ipairs({false,true})do
   local f=adapter();secondRoute(f);f.source("Greenwood");f.step(108);f.step(122);f.step(140);eq(f.follow(),true)
   if duplicate then table.insert(f.walking.Routes,f.walking.Routes[2])else table.remove(f.walking.Routes,2)end
   eq(f.follow(),false);f.step(145)
   eq(f.player.attributes.CurrentZone,"Greenwood");eq(f.root.Position.X,120);eq(f.character:GetAttribute("WalkingRouteContext"),nil)
   eq(f.moves,1);eq(f.heroMoves,1)
  end
 end)
 test("jump into ambiguous entries cannot seed subsequent unique entry admission",function()
  for _,arrived in ipairs({false,true})do
   for _,reverse in ipairs({false,true})do
    local f=adapter();local second=secondRoute(f)
    if arrived then f.step(0);for _,x in ipairs({25,50,75,100})do f.step(x)end else f.source("Greenwood")end
    f.config.Regions.Greenwood.HalfWidth=100
    f.route.entries.Greenwood=f.box(160,20);f.route.volumes={f.box(85,170)}
    second.entries.Greenwood=f.box(160,10)
    if reverse then f.walking.Routes={second,f.route}end
    f.step(160);eq(f.follow(),false) -- 60-stud jump into ambiguity.
    f.step(168);eq(f.follow(),false) -- Only first entry now; prior jump must not count.
    eq(f.character:GetAttribute("WalkingRouteContext"),nil);eq(f.player.attributes.CurrentZone,"Greenwood")
    eq(f.moves,0);eq(f.heroMoves,0)
   end
  end
 end)
end
