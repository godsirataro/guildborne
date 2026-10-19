--!strict
-- Standalone pure contract tests; these do not claim Studio lifecycle acceptance.
local Q=require("../src/shared/Config/WorldQuality")
local count=0
local function data(): any
	return {schemaVersion=1,sourceMeshSha256=string.rep("a",64),expectedArtNames={"House"},minArtPlacements=1,
		colliders={{name="Floor",kind="Part",size={10,1,10},cframe={0,2,1400,1,0,0,0,1,0,0,0,1}}}}
end
local function reject(change: (any)->())
	local d=data();change(d);assert(not pcall(Q.validate,d));count+=1
end
assert(Q.validate(data()));count+=1
reject(function(d)d.colliders[1].cframe[1]=110 end) -- full extent, not only center
reject(function(d)d.colliders[1].cframe[3]=1527 end)
reject(function(d)d.colliders[1].size[1]=0 end)
reject(function(d)d.colliders[1].cframe[2]=0/0 end)
reject(function(d)d.colliders[1].size[2]=math.huge end)
reject(function(d)d.colliders[1].cframe[4]=2 end)
reject(function(d)d.colliders[1].cframe[4]=-1 end)
reject(function(d)d.colliders[1].kind="MeshPart" end)
reject(function(d)d.expectedArtNames={"House","House"};d.minArtPlacements=2 end)
reject(function(d)d.minArtPlacements=0 end)
reject(function(d)d.sourceMeshSha256="unreviewed" end)
reject(function(d)d.colliders[2]=d.colliders[1] end)
assert(Q.isDecoration("Trunk","Part") and Q.isDecoration("Canopy","Part"));count+=1
assert(not Q.isDecoration("Trunk","MeshPart"));count+=1
for name in pairs(Q.ProtectedNames) do assert(not Q.isDecoration(name,"Part"));count+=1 end
local actual=require("../src/server/Services/WorldQualityAssets")
assert(Q.validate(actual));count+=1
local bodies,roofs=0,0
for _,c in ipairs(actual.colliders)do
 if c.kind=="WedgePart" then
  bodies+=1;if c.cframe[2]>15 then roofs+=1 end
 end
end
assert(bodies>0 and roofs>0,"Source wall/roof surfaces missing");count+=1
local found={}
for _,c in ipairs(actual.colliders)do found[c.name]=c end
assert(found.ArrivalStreet and found.ForestRoad and found.StoneCrossingDeck and found.StableApron);count+=1
assert(found.ArrivalStreet.cframe[2]+found.ArrivalStreet.size[2]/2==2.08);count+=1
assert(found.ForestRoad.cframe[2]+found.ForestRoad.size[2]/2==6.08);count+=1
assert(Q.validateCorridor(Q.ContinuousCorridor));count+=1
local function clone(value: any): any
 if type(value)~="table" then return value end
 local copy={};for k,v in pairs(value) do copy[k]=clone(v) end;return copy
end
local function rejectCorridor(change: (any)->())
 local spec=clone(Q.ContinuousCorridor);change(spec);assert(not pcall(Q.validateCorridor,spec));count+=1
end
rejectCorridor(function(d)d.parts[1].cframe[1]=0/0 end)
rejectCorridor(function(d)d.parts[1].cframe[4]=2 end)
rejectCorridor(function(d)d.parts[1].size[1]=0 end)
rejectCorridor(function(d)d.parts[1].cframe[3]=0;d.parts[1].cframe[1]=0 end)
rejectCorridor(function(d)d.parts[1].collision=false end)
rejectCorridor(function(d)d.volumes[1].size[3]=2000 end)
rejectCorridor(function(d)d.entries.Greenwood=nil end)
assert(#Q.ContinuousCorridor.parts==444 and Q.ContinuousCorridor.colliderCount==148);count+=1
assert(Q.validateCorridor(Q.GreenwoodIronveilCorridor));count+=1
local function rejectSouth(change: (any)->())
 local spec=clone(Q.GreenwoodIronveilCorridor);change(spec);assert(not pcall(Q.validateCorridor,spec));count+=1
end
rejectSouth(function(d)d.id="invented" end)
rejectSouth(function(d)d.fromZone="City" end)
rejectSouth(function(d)d.toZone="Ashen" end)
rejectSouth(function(d)d.id="city_greenwood_west";d.fromZone="City";d.toZone="Greenwood" end)
rejectCorridor(function(d)d.id="greenwood_ironveil_south";d.fromZone="Greenwood";d.toZone="Ironveil" end)
rejectSouth(function(d)d.parts[1].cframe[1]=0 end)
rejectSouth(function(d)d.parts[1].cframe[2]=100 end)
rejectSouth(function(d)d.parts[1].cframe[3]=1400 end)
rejectSouth(function(d)d.parts[1].collision=not d.parts[1].collision end)
rejectSouth(function(d)d.centerline[1][1]=0 end)
rejectSouth(function(d)d.centerline[1][2]=100 end)
rejectSouth(function(d)d.centerline[1][3]=1400 end)
rejectSouth(function(d)d.volumes[1].size[1]=150 end) -- center still in bounds; corners escape
rejectSouth(function(d)d.volumes[1].cframe[2]=20 end)
rejectSouth(function(d)d.entries.Greenwood=clone(Q.ContinuousCorridor.entries.Greenwood) end)
rejectSouth(function(d)d.entries.Ironveil=nil end)
rejectSouth(function(d)d.entries.City=clone(d.entries.Greenwood) end)
rejectSouth(function(d)d.entries.Greenwood.cframe[1]=81 end)
rejectSouth(function(d)d.safeRecovery=nil end)
rejectSouth(function(d)d.safeRecovery.Ironveil[2]=100 end)
rejectSouth(function(d)d.safeRecovery.Greenwood[1]=0 end)
rejectSouth(function(d)d.safeRecovery.City={0,7,1500} end)
-- Static full-width docking regression. The native Island is defined by
-- AdventureMapKit Ironveil size(240,4,220), translated to(500,0,1400):
-- X380..620, Z1290..1510, floor2. This is source math, not Studio raycasting.
local function dockSupported(points: any): boolean
 local last=points[#points];local previous=points[#points-1]
 local dx,dz=last[1]-previous[1],last[3]-previous[3]
 local length=math.sqrt(dx*dx+dz*dz)
 if length<=0 or last[2]<2 or last[2]>2.2 then return false end
 -- A straight cross-section is convex; both ends bound the entire 24-stud span.
 for _,lateral in ipairs({-12,12}) do
  local x=last[1]-dz/length*lateral
  local z=last[3]+dx/length*lateral
  if x<380 or x>620 or z<1290 or z>1510 then return false end
 end
 return true
end
assert(dockSupported(Q.GreenwoodIronveilCorridor.centerline),"Terminal road width leaves native Ironveil support");count+=1
local oldDock=clone(Q.GreenwoodIronveilCorridor.centerline)
oldDock[#oldDock][3]=1500
assert(not dockSupported(oldDock),"Original endpoint must reproduce unsupported outer edge");count+=1
local dock=Q.GreenwoodIronveilCorridor
assert(dock.centerline[#dock.centerline][1]==390 and dock.centerline[#dock.centerline][3]==1495);count+=1
assert(dock.entries.Ironveil.cframe[3]==1495 and dock.entries.Ironveil.size[1]==24 and dock.entries.Ironveil.size[3]==24);count+=1
assert(dock.safeRecovery.Ironveil[1]==400 and dock.safeRecovery.Ironveil[2]==7 and dock.safeRecovery.Ironveil[3]==1500);count+=1
rejectSouth(function(d)d.entries.Ironveil.cframe[3]=1500 end)
rejectSouth(function(d)d.centerline[#d.centerline][3]=1500 end)
assert(Q.validateCorridor(Q.IronveilAshenCorridor));count+=1
local function rejectThird(change: (any)->())
 local spec=clone(Q.IronveilAshenCorridor);change(spec);assert(not pcall(Q.validateCorridor,spec));count+=1
end
rejectThird(function(d)d.fromZone="Greenwood" end)
rejectThird(function(d)d.parts[1].kind="WedgePart" end)
rejectThird(function(d)d.parts[1].collision=false end)
rejectThird(function(d)table.remove(d.parts,1);d.colliderCount-=1 end)
rejectThird(function(d)d.parts[1].size[3]=17 end) -- missing landing extension
rejectThird(function(d)d.parts[1].cframe[3]=1490 end) -- combat intrusion
rejectThird(function(d)d.parts[1].cframe[4]=-1 end)
rejectThird(function(d)d.parts[2].cframe[2]=100 end)
rejectThird(function(d)d.centerline[1][3]=1495 end)
rejectThird(function(d)d.volumes[1].size[1]=150 end)
rejectThird(function(d)d.entries.Ironveil=clone(Q.GreenwoodIronveilCorridor.entries.Ironveil) end)
rejectThird(function(d)d.entries.City=clone(d.entries.Ironveil) end)
rejectThird(function(d)d.safeRecovery.Ashen={1000,100,1400} end)
rejectThird(function(d)d.safeRecovery.Ashen=nil end)
for _,p in ipairs(Q.IronveilAshenCorridor.parts) do
 assert(p.cframe[3]-p.size[3]/2>=1493 and math.abs(p.cframe[2]+p.size[2]/2-2.1)<1e-6);count+=1
end
print("world_quality: "..count.." contract checks passed; Studio lifecycle NOT_RUN")

-- Optional CLI source-injection harness: execute the actual service with fake
-- Instances/RunService. This tests lifecycle logic, never Studio physics.
return function(source: string)
 local passed=0
 local function check(ok: boolean) assert(ok);passed+=1 end
 local function vec(x: number?,y: number?,z: number?): any
  local a={X=x or 0,Y=y or 0,Z=z or 0}
  return setmetatable(a,{__sub=function(u: any,v: any): any return {Magnitude=math.sqrt((u.X-v.X)^2+(u.Y-v.Y)^2+(u.Z-v.Z)^2)} end})
 end
 local function frame(x: number?,y: number?,z: number?,...: any): any return {Position=vec(x,y,z)} end
 local function fixture(): any
  local nodes: {any}={}
  local state: any={server=true,studio=true,created=0,failAt=0,failPivot=false}
  local function node(class: string, name: string, parent: any): any
   local n: any={ClassName=class,Name=name,Parent=parent,Transparency=.35,CanCollide=true,CanQuery=false,CanTouch=true,attributes={}}
   function n:IsA(kind: string): boolean return self.ClassName==kind or (kind=="BasePart" and (self.ClassName=="Part" or self.ClassName=="WedgePart")) end
   function n:GetChildren(): {any} local children={};for _,v in ipairs(nodes)do if v.Parent==self then table.insert(children,v)end end;return children end
   function n:FindFirstChild(name: string): any for _,v in ipairs(self:GetChildren())do if v.Name==name then return v end end;return nil end
   function n:GetPivot(): any return n.pivot or frame() end
   function n:PivotTo(value: any) assert(not state.failPivot,"Injected pivot failure");n.pivot=value end
   function n:GetDescendants(): {any}
    local result={};for _,child in ipairs(n:GetChildren())do table.insert(result,child);for _,desc in ipairs(child:GetDescendants())do table.insert(result,desc)end end;return result
   end
   function n:Clone(): any
    local copy=node(n.ClassName,n.Name,nil);copy.Anchored=n.Anchored
    for _,child in ipairs(n:GetChildren())do local cloneChild=child:Clone();cloneChild.Parent=copy end;return copy
   end
   function n:SetAttribute(key: string,value: any) self.attributes[key]=value end
   function n:GetAttribute(key: string): any return self.attributes[key] end
   function n:Destroy() for _,v in ipairs(self:GetChildren())do v:Destroy()end;self.Parent=nil;self.destroyed=true end
   table.insert(nodes,n);return n
  end
  local world=node("Folder","GuildborneWorld",{})
  local region=node("Model","Greenwood",world)
  node("Model","Ironveil",world)
  node("Model","Ashen",world)
  local trunk=node("Part","Trunk",region)
  local canopy=node("Part","Canopy",region)
  local terrain=node("Part","Island",region);terrain.Color="ground";terrain.Material="grass"
  local nested=node("Model","Other",region);local nestedTrunk=node("Part","Trunk",nested)
  local mesh=node("MeshPart","Trunk",region)
  local runtime: any={StudioPersistence="Memory",AllowedDataStoreUniverses={}}
  local town=node("Folder","City",world);local wall=node("Model","CityWall",town);wall:PivotTo(frame(0,0,-625))
  local storage=node("Folder","ServerStorage",{});local kit=node("Folder","CityKit",storage);local arch=node("Model","CityArch",kit)
  for i=1,5 do local piece=node("Part","Gate"..i,arch);piece.Anchored=true end
  local rs={IsServer=function()return state.server end,IsStudio=function()return state.studio end}
  local fakeGame: any={PlaceId=0,GameId=0,ReplicatedStorage={Shared={Config={WorldQuality="quality"}}},GetService=function(_self: any,name: string): any return if name=="ServerStorage" then storage else rs end}
  local env: any=setmetatable({game=fakeGame,script={Parent={WorldQualityAssets="data",Parent={Config={Runtime="runtime"}}}},
   require=function(key: string): any if key=="quality" then return Q elseif key=="data" then return actual else return runtime end end,
   Instance={new=function(class: string): any state.created+=1;assert(state.created~=state.failAt,"Injected allocation failure");return node(class,class,nil) end},
   Vector3={new=vec},CFrame={new=frame},Color3={new=function(...: any): any return {...} end},Enum={Material={Ground="Ground",Grass="Grass"},SurfaceType={Smooth="Smooth"}}}, {__index=getfenv()})
  local chunk=assert(loadstring(source));setfenv(chunk,env)
  return {init=chunk(),world=world,region=region,trunk=trunk,canopy=canopy,terrain=terrain,nested=nestedTrunk,mesh=mesh,state=state,runtime=runtime,game=fakeGame,node=node,wall=wall,town=town,nodes=nodes}
 end
 local f=fixture()
 local h=f.init(f.world) -- no imported art folder exists anywhere
 check(h.colliders==413 and h.disabledDecorationPhysics==2)
 check(f.trunk.Transparency==.35 and f.canopy.Transparency==.35)
 check(not f.trunk.CanCollide and not f.trunk.CanQuery and not f.trunk.CanTouch)
 check(f.terrain.CanCollide and f.nested.CanCollide and f.mesh.CanCollide)
 check(f.init(f.world)==h)
 check(table.isfrozen(h.reviewedArt) and table.isfrozen(h.reviewedArt.expectedArt) and table.isfrozen(h.reviewedArt.expectedArt[1].position))
 check(not pcall(function()h.reviewedArt.expectedArt[1].position[1]=999 end))
 -- Client presentation may change while active; server teardown must not undo it.
 f.trunk.Transparency=.7;h.destroy();h.destroy()
 check(f.trunk.CanCollide and not f.trunk.CanQuery and f.trunk.CanTouch and f.trunk.Transparency==.7)
 check(f.region:FindFirstChild("WorldQualityCollision")==nil)
 local nextHandle=f.init(f.world);check(nextHandle~=h);nextHandle.destroy()
 for _,change in ipairs({
  function(x: any)x.state.server=false end,function(x: any)x.state.studio=false end,
  function(x: any)x.game.PlaceId=1 end,function(x: any)x.game.GameId=1 end,
  function(x: any)x.runtime.StudioPersistence="DataStore" end,
  function(x: any)x.runtime.AllowedDataStoreUniverses[1]="production" end,
 })do local x=fixture();change(x);check(not pcall(x.init,x.world) and x.state.created==0 and x.trunk.CanCollide)end
 local x=fixture();local existing=x.node("Folder","WorldQualityCollision",x.region)
 check(not pcall(x.init,x.world) and not existing.destroyed and x.trunk.CanCollide)
 local broken=fixture();broken.state.failAt=4
 check(not pcall(broken.init,broken.world) and broken.region:FindFirstChild("WorldQualityCollision")==nil and broken.trunk.CanCollide)
 broken.state.failAt=0;local recovered=broken.init(broken.world);check(recovered.colliders==413);recovered.destroy()
 local c=fixture();local handle=c.init(c.world)
 check(c.wall.Parent==c.town and c.world:FindFirstChild("CityGreenwoodCorridor")==nil)
 local route=handle.buildContinuousCorridor();check(route.id=="city_greenwood_west" and route.isReady())
 check(route.geometry.Parent==c.world and c.wall.Parent==nil and #route.volumes==37)
 check(handle.buildContinuousCorridor()==route)
 local navigation=route.geometry:FindFirstChild("NavigationNodes");check(#navigation:GetChildren()==38)
 for i,point in ipairs(Q.ContinuousCorridor.centerline) do
  local value=navigation:FindFirstChild(string.format("%03d",i));check(value.Value.X==point[1] and value.Value.Y==point[2] and value.Value.Z==point[3] and value.attributes.Index==i)
 end
 check(route.geometry.attributes.RouteId=="city_greenwood_west" and route.geometry.attributes.WalkWidth==24)
 local road=route.geometry:FindFirstChild("Road_000");road.CanCollide=false;check(not route.isReady());road.CanCollide=true
 road.CanQuery=false;check(not route.isReady());road.CanQuery=true
 local oldFrame=road.CFrame;road.CFrame=frame(100,100,100);check(not route.isReady());road.CFrame=oldFrame
 local oldSize=road.Size;road.Size=vec(1,1,1);check(not route.isReady());road.Size=oldSize
 local gate=route.geometry:FindFirstChild("ContinuousSouthGate");local pier=gate:GetChildren()[1];pier.Parent=nil;check(not route.isReady());pier.Parent=gate
 check(route.isReady())
 handle.destroy();check(c.wall.Parent==c.town and not route.isReady() and c.world:FindFirstChild("CityGreenwoodCorridor")==nil)
 check(not pcall(handle.buildContinuousCorridor))
 local failed=fixture();local pending=failed.init(failed.world);failed.state.failAt=failed.state.created+10
 check(not pcall(pending.buildContinuousCorridor));check(failed.wall.Parent==failed.town and failed.world:FindFirstChild("CityGreenwoodCorridor")==nil)
 failed.state.failAt=0;check(pending.buildContinuousCorridor().isReady());pending.destroy()
 local pivot=fixture();local pivotHandle=pivot.init(pivot.world);pivot.state.failPivot=true
 check(not pcall(pivotHandle.buildContinuousCorridor));check(pivot.wall.Parent==pivot.town)
 for _,node in ipairs(pivot.nodes)do if node.Name=="ContinuousSouthGate" then check(node.destroyed==true)end end
 pivot.state.failPivot=false;check(pivotHandle.buildContinuousCorridor().isReady());pivotHandle.destroy()
 local removed=fixture();local removing=removed.init(removed.world);removing.buildContinuousCorridor();removed.town.Parent=nil;removing.destroy();check(removed.wall.destroyed==true)
 local occupied=fixture();local owner=occupied.init(occupied.world);occupied.node("Model","CityGreenwoodCorridor",occupied.world)
 check(not pcall(owner.buildContinuousCorridor) and occupied.wall.Parent==occupied.town);owner.destroy()
 -- The second edge must work without City or CityKit and never borrow west ownership.
 local second=fixture();local secondHandle=second.init(second.world)
 local south=secondHandle.buildGreenwoodIronveilCorridor()
 check(south.id=="greenwood_ironveil_south" and south.fromZone=="Greenwood" and south.toZone=="Ironveil" and south.isReady())
 check(south.ownedModel==south.geometry and second.wall.Parent==second.town)
 check(secondHandle.buildGreenwoodIronveilCorridor()==south)
 check(south.entries.Greenwood~=nil and south.entries.Ironveil~=nil and south.safeRecovery.Greenwood~=nil and south.safeRecovery.Ironveil~=nil)
 check(south.entries.Ironveil.cframe.Position.Z==1495 and south.entries.Ironveil.size.X==24 and south.entries.Ironveil.size.Z==24)
 check(south.safeRecovery.Ironveil.Position.X==400 and south.safeRecovery.Ironveil.Position.Y==7 and south.safeRecovery.Ironveil.Position.Z==1500)
 local southNodes=south.geometry:FindFirstChild("NavigationNodes")
 check(#southNodes:GetChildren()==#Q.GreenwoodIronveilCorridor.centerline)
 for i,point in ipairs(Q.GreenwoodIronveilCorridor.centerline) do
  local n=southNodes:FindFirstChild(string.format("%03d",i))
  check(n.Value.X==point[1] and n.Value.Y==point[2] and n.Value.Z==point[3] and n:GetAttribute("Index")==i)
 end
 local function mutate(object: any,key: string,bad: any)
  local before=object[key];object[key]=bad;check(not south.isReady());object[key]=before;check(south.isReady())
 end
 local southRoad=south.geometry:FindFirstChild(Q.GreenwoodIronveilCorridor.parts[1].name)
 mutate(southRoad,"Name","Replacement");mutate(southRoad,"Parent",nil);mutate(southRoad,"Anchored",false)
 mutate(southRoad,"CanCollide",not southRoad.CanCollide);mutate(southRoad,"CanQuery",not southRoad.CanQuery);mutate(southRoad,"CanTouch",true)
 mutate(southRoad,"Size",vec(1,1,1));mutate(southRoad,"CFrame",frame(0,0,0))
 mutate(south.geometry,"Name","Unexpected");mutate(south.geometry,"Parent",nil)
 local node1=southNodes:GetChildren()[1]
 mutate(node1,"Name","999");mutate(node1,"Value",vec(0,100,0));mutate(node1.attributes,"Index",99)
 for key in pairs(south.geometry.attributes) do mutate(south.geometry.attributes,key,"Tampered") end
 local unexpected=second.node("Part","InjectedCollider",south.geometry);check(not south.isReady());unexpected:Destroy();check(south.isReady())
 local endpoint=second.world:FindFirstChild("Ironveil");mutate(endpoint,"Parent",nil)
 local west=secondHandle.buildContinuousCorridor();check(west.isReady() and south.isReady() and second.wall.Parent==nil)
 south.destroy();south.destroy();check(not south.isReady() and west.isReady() and second.wall.Parent==nil)
 local rebuilt=secondHandle.buildGreenwoodIronveilCorridor();check(rebuilt~=south and rebuilt.isReady())
 secondHandle.destroy();check(not rebuilt.isReady() and not west.isReady() and second.wall.Parent==second.town)
 check(not pcall(secondHandle.buildGreenwoodIronveilCorridor))
 local noCity=fixture();local noCityHandle=noCity.init(noCity.world);noCity.town.Parent=nil
 local noCityRoute=noCityHandle.buildGreenwoodIronveilCorridor();check(noCityRoute.isReady());noCityHandle.destroy()
 local absent=fixture();local absentHandle=absent.init(absent.world);absent.world:FindFirstChild("Ironveil"):Destroy()
 check(not pcall(absentHandle.buildGreenwoodIronveilCorridor) and absent.world:FindFirstChild("GreenwoodIronveilCorridor")==nil);absentHandle.destroy()
 local taken=fixture();local takenHandle=taken.init(taken.world)
 local existingSouth=taken.node("Model","GreenwoodIronveilCorridor",taken.world)
 check(not pcall(takenHandle.buildGreenwoodIronveilCorridor) and not existingSouth.destroyed);takenHandle.destroy()
 local failure=fixture();local failureHandle=failure.init(failure.world);local other=failureHandle.buildContinuousCorridor()
 failure.state.failAt=failure.state.created+4
 check(not pcall(failureHandle.buildGreenwoodIronveilCorridor) and other.isReady() and failure.wall.Parent==nil)
 check(failure.world:FindFirstChild("GreenwoodIronveilCorridor")==nil)
 failure.state.failAt=0;check(failureHandle.buildGreenwoodIronveilCorridor().isReady());failureHandle.destroy()
 check(failure.wall.Parent==failure.town)
 local third=fixture();local thirdHandle=third.init(third.world)
 check(third.world:FindFirstChild("IronveilAshenCorridor")==nil)
 local ia=thirdHandle.buildIronveilAshenCorridor();check(ia.isReady() and ia.id=="ironveil_ashen_south")
 check(thirdHandle.buildIronveilAshenCorridor()==ia and third.wall.Parent==third.town)
 check(#ia.geometry:GetChildren()==7 and ia.entries.Ashen~=nil and ia.entries.Greenwood==nil)
 local pad=ia.geometry:FindFirstChild("Landing_Ashen")
 local originalSize=pad.Size;pad.Size=vec(28,.4,17);check(not ia.isReady());pad.Size=originalSize
 pad.CanQuery=false;check(not ia.isReady());pad.CanQuery=true;check(ia.isReady())
 local ash=third.world:FindFirstChild("Ashen");ash.Parent=nil;check(not ia.isReady());ash.Parent=third.world
 local gi=thirdHandle.buildGreenwoodIronveilCorridor();check(gi.isReady() and ia.isReady())
 ia.destroy();ia.destroy();check(not ia.isReady() and gi.isReady())
 local again=thirdHandle.buildIronveilAshenCorridor();check(again~=ia and again.isReady())
 thirdHandle.destroy();check(not again.isReady() and not gi.isReady());check(not pcall(thirdHandle.buildIronveilAshenCorridor))
 local missing=fixture();local mh=missing.init(missing.world);missing.world:FindFirstChild("Ashen"):Destroy()
 check(not pcall(mh.buildIronveilAshenCorridor));mh.destroy()
 local occupied=fixture();local oh=occupied.init(occupied.world)
 local external=occupied.node("Model","IronveilAshenCorridor",occupied.world)
 check(not pcall(oh.buildIronveilAshenCorridor) and not external.destroyed);oh.destroy()
 local rollback=fixture();local rh=rollback.init(rollback.world);local retained=rh.buildGreenwoodIronveilCorridor()
 rollback.state.failAt=rollback.state.created+4
 check(not pcall(rh.buildIronveilAshenCorridor) and retained.isReady() and rollback.world:FindFirstChild("IronveilAshenCorridor")==nil)
 rollback.state.failAt=0;check(rh.buildIronveilAshenCorridor().isReady());rh.destroy()
 print("world_quality: "..passed.." mocked server lifecycle checks passed; Studio physics NOT_RUN")
end
