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
print("world_quality: "..count.." contract checks passed; Studio lifecycle NOT_RUN")

-- Optional CLI source-injection harness: execute the actual service with fake
-- Instances/RunService. This tests lifecycle logic, never Studio physics.
return function(source: string)
 local passed=0
 local function check(ok: boolean) assert(ok);passed+=1 end
 local function fixture(): any
  local nodes: {any}={}
  local state: any={server=true,studio=true,created=0,failAt=0}
  local function node(class: string, name: string, parent: any): any
   local n: any={ClassName=class,Name=name,Parent=parent,Transparency=.35,CanCollide=true,CanQuery=false,CanTouch=true,attributes={}}
   function n:IsA(kind: string): boolean return self.ClassName==kind or (kind=="BasePart" and (self.ClassName=="Part" or self.ClassName=="WedgePart")) end
   function n:GetChildren(): {any} local children={};for _,v in ipairs(nodes)do if v.Parent==self then table.insert(children,v)end end;return children end
   function n:FindFirstChild(name: string): any for _,v in ipairs(self:GetChildren())do if v.Name==name then return v end end;return nil end
   function n:SetAttribute(key: string,value: any) self.attributes[key]=value end
   function n:Destroy() for _,v in ipairs(self:GetChildren())do v:Destroy()end;self.Parent=nil;self.destroyed=true end
   table.insert(nodes,n);return n
  end
  local world=node("Folder","GuildborneWorld",{})
  local region=node("Model","Greenwood",world)
  local trunk=node("Part","Trunk",region)
  local canopy=node("Part","Canopy",region)
  local terrain=node("Part","Island",region);terrain.Color="ground";terrain.Material="grass"
  local nested=node("Model","Other",region);local nestedTrunk=node("Part","Trunk",nested)
  local mesh=node("MeshPart","Trunk",region)
  local runtime: any={StudioPersistence="Memory",AllowedDataStoreUniverses={}}
  local rs={IsServer=function()return state.server end,IsStudio=function()return state.studio end}
  local fakeGame: any={PlaceId=0,GameId=0,ReplicatedStorage={Shared={Config={WorldQuality="quality"}}},GetService=function()return rs end}
  local env: any=setmetatable({game=fakeGame,script={Parent={WorldQualityAssets="data",Parent={Config={Runtime="runtime"}}}},
   require=function(key: string): any if key=="quality" then return Q elseif key=="data" then return actual else return runtime end end,
   Instance={new=function(class: string): any state.created+=1;assert(state.created~=state.failAt,"Injected allocation failure");return node(class,class,nil) end},
   Vector3={new=function(...: any): any return {...} end},CFrame={new=function(...: any): any return {...} end}}, {__index=getfenv()})
  local chunk=assert(loadstring(source));setfenv(chunk,env)
  return {init=chunk(),world=world,region=region,trunk=trunk,canopy=canopy,terrain=terrain,nested=nestedTrunk,mesh=mesh,state=state,runtime=runtime,game=fakeGame,node=node}
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
 print("world_quality: "..passed.." mocked server lifecycle checks passed; Studio physics NOT_RUN")
end
