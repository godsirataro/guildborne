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
   return {Parent=true,attributes={},GetAttribute=function(self:any,k:string)return self.attributes[k]end,IsA=function(_self:any,k:string)return k=="Model"end}
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
  local config:any={Destinations={City={X=0,Y=5,Z=0,FallbackX=0,FallbackZ=1},Greenwood={X=100,Y=5,Z=0,FallbackX=100,FallbackZ=1},Guild={X=-100,Y=5,Z=0,FallbackX=-100,FallbackZ=1}},Regions={},GuildPortalStops={},contains=function(x:number,z:number)return x>=-10 and x<=10 and math.abs(z)<=10 end,region=function(x:number,z:number)return if x>=90 and x<=110 and math.abs(z)<=10 then "Greenwood" else nil end,
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
  local route={id="city_greenwood",fromZone="City",toZone="Greenwood",geometry=geometry,volumes={box(50,110)},entries={City=box(0,10),Greenwood=box(100,10)},safeRecovery={City=cf(0,5,0),Greenwood=cf(100,5,0)},isReady=function()return f.ready end}
  local walking={Routes={route},Session=function(_p:any)return f.session end,Gate=function(_p:any,_s:any,from:string,to:string)
   f.lastGate={from,to};if f.gateThrow then error("fixture gate failure") end;if f.gateYield then coroutine.yield() end;return f.gate
  end}
  local city={town=town,spawn="city",regions={Greenwood={model=forest,spawn="forest"}},guildAccessPortals={}}
  local heroes={Travel=function(_p:any)f.heroMoves+=1 end}
  local localTravel={Session=walking.Session,Gate=function()return nil end,Geometry=geometry,Entry={Position=v(0,5,0),Parent=true},Exit={Position=v(50,5,0),Parent=true},Landing=v(50,5,0),Fallback=v(51,5,0),Contains=function()return true end}
  local service=Service(city,plots,heroes,localTravel,platform,if disabled then nil else walking)
  f.service=service;f.player=player;f.root=root;f.character=character;f.humanoid=humanoid;f.plotModel=plotModel;f.route=route;f.v=v;f.cf=cf;f.plots=plots;f.town=town;f.forest=forest;f.box=box
  function f.resetCounters()f.moves=0;f.velocities=0;f.heroMoves=0 end
  function f.step(x:number?,y:number?)if x then root.Position=v(x,y or 5,0)end;now+=.5;step(.5)end
  function f.follow():boolean return service.CanFollowWalking(player,root.Position) end
  function f.source(zone:string)assert(service.Travel(player,zone));f.step();f.resetCounters()end
  f.source("City")
  return f
 end
 test("walking commits both directions in place with source respawn retained in corridor",function()
  local f=adapter();f.step(0);eq(f.follow(),true)
  for _,x in ipairs({25,50,75})do f.step(x);eq(f.player.attributes.CurrentZone,"City");eq(f.player.RespawnLocation,"city")end
  f.step(100);eq(f.player.attributes.CurrentZone,"Greenwood");eq(f.player.RespawnLocation,"forest")
  f.step(100);f.step(100);for _,x in ipairs({75,50,25,0})do f.step(x)end
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
 test("normal walking admits on first entry sample without stopping inside the entry",function()
  local f=adapter()
  f.step(-6);eq(f.follow(),false) -- Source-side approach, outside the ten-stud entry.
  f.step(2);eq(f.follow(),true) -- Eight studs per half-second: WalkSpeed 16.
  f.step(10);eq(f.follow(),true) -- Only one observation was inside entry; keep moving.
  for _,x in ipairs({35,60,85,100})do f.step(x)end
  eq(f.player.attributes.CurrentZone,"Greenwood");eq(f.moves,0);eq(f.heroMoves,0);eq(f.velocities,0)
 end)
 test("nonfinite admitted root movement cannot commit or reach segment interpolation",function()
  for _,bad in ipairs({0/0,math.huge,-math.huge})do
   local f=adapter();f.step(0);f.step(25);f.step(bad)
   eq(f.player.attributes.CurrentZone,"City");eq(f.player.RespawnLocation,"city");eq(f.follow(),false)
   eq(f.root.Position.X,0);eq(f.moves,1)
  end
 end)
end
