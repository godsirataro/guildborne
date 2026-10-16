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
