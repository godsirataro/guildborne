--!strict
-- Offline data checks; this does not certify Studio meshes, seam fit or animation.
local Partition=require("../../src/shared/Presentation/ModularAppearance/LocalGarmentPartition")
local Geometry=require("../../src/shared/Presentation/ModularAppearance/GeneratedGeometry")
local Rig=require("../../src/shared/Presentation/ModularAppearance/GeneratedRig")
local count=0
local function test(name: string,callback: () -> ())
	callback();count+=1;print("PASS "..name)
end
local function copy(value: any): any
	if type(value)~="table" then return value end
	local result={}
	for key,child in pairs(value) do result[key]=copy(child) end
	return result
end
local top="CLO_TUNIC_TRAVELER_01"
local bottom="CLO_TROUSERS_TRAVELER_01"
for _,id in ipairs({top,bottom}) do
	test(id.." preserves each original vertex, triangle, UV, normal and material exactly once",function()
		local geometry=Geometry.Assets[id]
		local source=geometry.meshes[1]
		local result=Partition.Build(id,"HUMAN_STANDARD",geometry,Rig.Assets[id])
		local seenFaces: {[number]: boolean}={}
		local seenVertices: {[number]: boolean}={}
		local faceCount=0
		assert(#result==(if id==top then 4 else 5))
		local previous=""
		for _,mesh in ipairs(result) do
			assert(mesh.bindBone>previous);previous=mesh.bindBone
			assert(not mesh.coreBodyPart and not mesh.skinTintable)
			assert(mesh.materials==source.materials)
			for i,vertex in ipairs(mesh.vertices) do
				local original=mesh.sourceVertexIndices[i]
				assert(not seenVertices[original]);seenVertices[original]=true
				assert(vertex==source.vertices[original])
				assert(Rig.Assets[id].meshes[1].vertexWeights[original][1].bone==mesh.bindBone)
			end
			for i,triangle in ipairs(mesh.triangles) do
				local original=mesh.sourceFaceIndices[i]
				assert(not seenFaces[original]);seenFaces[original]=true
				for corner=1,3 do assert(mesh.sourceVertexIndices[triangle[corner]]==source.triangles[original][corner]) end
				assert(mesh.faceUVs[i]==source.faceUVs[original])
				assert(mesh.faceNormals[i]==source.faceNormals[original])
				assert(mesh.faceMaterials[i]==source.faceMaterials[original])
				faceCount+=1
			end
		end
		assert(faceCount==geometry.triangleCount)
		for i=1,#source.vertices do assert(seenVertices[i]) end
	end)
end
local function reject(name: string,expected: string,mutate: (any,any) -> (),id: string?,preset: string?)
	test(name,function()
		local geometry=copy(Geometry.Assets[top])
		local rig=copy(Rig.Assets[top])
		mutate(geometry,rig)
		local ok,err=pcall(Partition.Build,id or top,preset or "HUMAN_STANDARD",geometry,rig)
		assert(not ok and tostring(err):find(expected,1,true),tostring(err))
	end)
end
reject("Heavy fit rejects before allocation","ARTICULATED_GARMENT_PRESET_UNSUPPORTED",function() end,nil,"HUMAN_HEAVY")
reject("robe unsupported rather than silently omitted","ARTICULATED_GARMENT_UNAVAILABLE",function() end,"CLO_ROBE_WIZARD_01")
reject("hash mismatch","GARMENT_SOURCE_HASH_MISMATCH",function(_,rig) rig.sourceSha256=string.rep("0",64) end)
reject("missing hash","GARMENT_SOURCE_HASH_MISMATCH",function(geometry,rig) geometry.sourceSha256=nil;rig.sourceSha256=nil end)
reject("authored fit mismatch","GARMENT_AUTHORED_PRESET_MISMATCH",function(_,rig) rig.authoredPreset="HUMAN_HEAVY" end)
reject("vertex count mismatch","GARMENT_VERTEX_MAPPING_MISMATCH",function(_,rig) rig.meshes[1].vertexCount+=1 end)
reject("mesh identity mismatch","GARMENT_VERTEX_MAPPING_MISMATCH",function(_,rig) rig.meshes[1].name="wrong" end)
reject("mixed vertex influences","GARMENT_MIXED_VERTEX_WEIGHTS",function(_,rig)
	rig.meshes[1].vertexWeights[1]={{bone="UpperTorso",weight=.5},{bone="LowerTorso",weight=.5}}
end)
reject("unnormalized weight","GARMENT_MIXED_VERTEX_WEIGHTS",function(_,rig) rig.meshes[1].vertexWeights[1][1].weight=.9 end)
reject("NaN weight","GARMENT_MIXED_VERTEX_WEIGHTS",function(_,rig) rig.meshes[1].vertexWeights[1][1].weight=0/0 end)
reject("root cannot own a garment segment","GARMENT_BONE_UNSUPPORTED",function(_,rig) rig.meshes[1].vertexWeights[1][1].bone="HumanoidRootPart" end)
reject("triangle crosses bone groups","GARMENT_MIXED_TRIANGLE_BONES",function(geometry,rig)
	local index=geometry.meshes[1].triangles[1][1]
	rig.meshes[1].vertexWeights[index][1].bone="LowerTorso"
end)
reject("out of range index","GARMENT_VERTEX_INDEX_INVALID",function(geometry) geometry.meshes[1].triangles[1][1]=100000 end)
reject("fractional index","GARMENT_VERTEX_INDEX_INVALID",function(geometry) geometry.meshes[1].triangles[1][1]=1.5 end)
reject("NaN index","GARMENT_VERTEX_INDEX_INVALID",function(geometry) geometry.meshes[1].triangles[1][1]=0/0 end)
reject("missing UV mapping","GARMENT_FACE_MAPPING_MISMATCH",function(geometry) table.remove(geometry.meshes[1].faceUVs) end)

local MakePool=require("../../src/shared/Presentation/ModularAppearance/LocalMeshBackingPool")
local function poolFixture()
	local disposed=0
	local pool=MakePool(function() coroutine.yield() end,function(resource: any)
		assert(not resource.destroyed);resource.destroyed=true;disposed+=1
	end)
	local function owner()
		local active=true
		local entries={}
		return {
			register=function(entry: any) table.insert(entries,entry) end,
			alive=function() return active end,
			cancel=function()
				if not active then return end
				active=false
				for _,entry in ipairs(entries) do pool.Release(entry) end
			end,
		}
	end
	return pool,owner,function() return disposed end
end
test("shared backing is retained until last owner, then rebuilt without a permanent cache",function()
	local pool,owner,disposed=poolFixture()
	local a,b=owner(),owner();local creates=0
	local function create() creates+=1;return {} end
	local first=pool.Acquire("same",a.register,a.alive,create)
	local second=pool.Acquire("same",b.register,b.alive,create)
	assert(first==second and creates==1 and pool.Count()==1)
	a.cancel();assert(not second.destroyed and disposed()==0)
	b.cancel();assert(second.destroyed and disposed()==1 and pool.Count()==0)
	local c=owner();assert(pool.Acquire("same",c.register,c.alive,create)~=second and creates==2)
	c.cancel();assert(disposed()==2 and pool.Count()==0)
end)
test("concurrent callers share exactly one in-flight creation",function()
	local pool,owner,disposed=poolFixture();local a,b=owner(),owner()
	local creates=0;local first,second
	local co1=coroutine.create(function()
		first=pool.Acquire("same",a.register,a.alive,function() creates+=1;coroutine.yield();return {} end)
	end)
	local co2=coroutine.create(function()
		second=pool.Acquire("same",b.register,b.alive,function() error("DUPLICATE_CREATION") end)
	end)
	assert(coroutine.resume(co1));assert(coroutine.resume(co2))
	assert(creates==1 and pool.PendingCount()==1 and pool.Count()==0)
	assert(coroutine.resume(co1));assert(coroutine.resume(co2))
	assert(first==second and pool.PendingCount()==0 and pool.Count()==1)
	a.cancel();b.cancel();assert(disposed()==1 and pool.Count()==0)
end)
test("all owners cancelled during creation dispose the eventual backing",function()
	local pool,owner,disposed=poolFixture();local a=owner()
	local accepted,problem
	local co=coroutine.create(function()
		accepted,problem=pcall(pool.Acquire,"same",a.register,a.alive,function() coroutine.yield();return {} end)
	end)
	assert(coroutine.resume(co));a.cancel();assert(coroutine.resume(co))
	assert(not accepted and tostring(problem):find("LOCAL_PREVIEW_CANCELLED",1,true))
	assert(disposed()==1 and pool.Count()==0 and pool.PendingCount()==0)
end)
test("cancelled creator cannot destroy a surviving waiter's backing",function()
	local pool,owner,disposed=poolFixture();local a,b=owner(),owner()
	local accepted;local second
	local co1=coroutine.create(function()
		accepted=pcall(pool.Acquire,"same",a.register,a.alive,function() coroutine.yield();return {} end)
	end)
	local co2=coroutine.create(function()
		second=pool.Acquire("same",b.register,b.alive,function() error("DUPLICATE_CREATION") end)
	end)
	assert(coroutine.resume(co1));assert(coroutine.resume(co2));a.cancel()
	assert(coroutine.resume(co1));assert(coroutine.resume(co2))
	assert(not accepted and second and not second.destroyed and disposed()==0)
	b.cancel();assert(disposed()==1 and pool.Count()==0)
end)
test("cancelled waiter exits and leaves the creator's backing intact",function()
	local pool,owner,disposed=poolFixture();local a,b=owner(),owner()
	local first,accepted
	local co1=coroutine.create(function()
		first=pool.Acquire("same",a.register,a.alive,function() coroutine.yield();return {} end)
	end)
	local co2=coroutine.create(function()
		accepted=pcall(pool.Acquire,"same",b.register,b.alive,function() error("DUPLICATE_CREATION") end)
	end)
	assert(coroutine.resume(co1));assert(coroutine.resume(co2));b.cancel()
	assert(coroutine.resume(co2));assert(not accepted);assert(coroutine.resume(co1))
	assert(first and not first.destroyed and pool.Count()==1)
	a.cancel();assert(disposed()==1 and pool.Count()==0)
end)
test("creation failure reaches all waiters and does not poison retries",function()
	local pool,owner,disposed=poolFixture();local a,b=owner(),owner()
	local first,second,problem1,problem2
	local co1=coroutine.create(function()
		first,problem1=pcall(pool.Acquire,"same",a.register,a.alive,function() coroutine.yield();error("INJECTED_FAILURE") end)
	end)
	local co2=coroutine.create(function()
		second,problem2=pcall(pool.Acquire,"same",b.register,b.alive,function() error("DUPLICATE_CREATION") end)
	end)
	assert(coroutine.resume(co1));assert(coroutine.resume(co2))
	assert(coroutine.resume(co1));assert(coroutine.resume(co2))
	assert(not first and not second and tostring(problem1):find("INJECTED_FAILURE",1,true) and tostring(problem2):find("INJECTED_FAILURE",1,true))
	a.cancel();b.cancel();assert(pool.Count()==0 and pool.PendingCount()==0 and disposed()==0)
	local c=owner();pool.Acquire("same",c.register,c.alive,function() return {} end);c.cancel();assert(disposed()==1)
end)
test("different backing keys never share resources",function()
	local pool,owner,disposed=poolFixture();local a,b=owner(),owner()
	local first=pool.Acquire("source",a.register,a.alive,function() return {} end)
	local second=pool.Acquire("tint",b.register,b.alive,function() return {} end)
	assert(first~=second and pool.Count()==2)
	a.cancel();b.cancel();assert(disposed()==2)
end)
print("PASS "..count.." local garment/backing lifecycle checks; Studio/fit acceptance remains pending")
