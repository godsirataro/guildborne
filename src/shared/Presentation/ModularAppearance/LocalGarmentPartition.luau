--!strict
-- Exact partition of the authored single-influence shells, not layered clothing.
-- Pure data validation runs before allocating any EditableMeshes.
local Partition = {}
local allowed: {[string]: {[string]: boolean}} = {
	CLO_TUNIC_TRAVELER_01={UpperTorso=true,LowerTorso=true,LeftUpperArm=true,RightUpperArm=true},
	CLO_TROUSERS_TRAVELER_01={LowerTorso=true,LeftUpperLeg=true,RightUpperLeg=true,LeftLowerLeg=true,RightLowerLeg=true},
}

function Partition.Build(assetId: string,preset: string,geometry: any,rig: any): {any}
	local bones=allowed[assetId]
	assert(bones,"ARTICULATED_GARMENT_UNAVAILABLE")
	assert(preset=="HUMAN_STANDARD","ARTICULATED_GARMENT_PRESET_UNSUPPORTED")
	assert(type(geometry)=="table" and type(rig)=="table","GARMENT_SOURCE_MISSING")
	assert(type(geometry.sourceSha256)=="string" and #geometry.sourceSha256==64
		and geometry.sourceSha256==rig.sourceSha256,"GARMENT_SOURCE_HASH_MISMATCH")
	assert(geometry.authoredPreset==preset and rig.authoredPreset==preset,"GARMENT_AUTHORED_PRESET_MISMATCH")
	assert(#geometry.meshes==1 and #rig.meshes==1,"GARMENT_SOURCE_MESH_COUNT")
	local source=geometry.meshes[1]
	local weights=rig.meshes[1]
	assert(source.name==weights.name and #source.vertices==weights.vertexCount
		and #weights.vertexWeights==#source.vertices,"GARMENT_VERTEX_MAPPING_MISMATCH")
	assert(#source.faceUVs==#source.triangles and #source.faceNormals==#source.triangles
		and #source.faceMaterials==#source.triangles and geometry.triangleCount==#source.triangles,"GARMENT_FACE_MAPPING_MISMATCH")
	local vertexBones: {string}={}
	for index,influences in ipairs(weights.vertexWeights) do
		assert(#influences==1 and influences[1].weight==1,"GARMENT_MIXED_VERTEX_WEIGHTS")
		local bone=influences[1].bone
		assert(bones[bone],"GARMENT_BONE_UNSUPPORTED")
		vertexBones[index]=bone
	end
	local groups: {[string]: any}={}
	local remaps: {[string]: {[number]: number}}={}
	for faceIndex,triangle in ipairs(source.triangles) do
		assert(#triangle==3,"GARMENT_TRIANGLE_INVALID")
		for _,index in ipairs(triangle) do
			assert(type(index)=="number" and index==index and index%1==0
				and index>=1 and index<=#source.vertices,"GARMENT_VERTEX_INDEX_INVALID")
		end
		local bone=vertexBones[triangle[1]]
		assert(vertexBones[triangle[2]]==bone and vertexBones[triangle[3]]==bone,"GARMENT_MIXED_TRIANGLE_BONES")
		if not groups[bone] then
			groups[bone]={
				name=source.name,runtimePart=assetId.."_"..bone,bindBone=bone,
				vertices={},triangles={},faceUVs={},faceNormals={},faceMaterials={},
				materials=source.materials,skinTintable=false,coreBodyPart=false,
				sourceVertexIndices={},sourceFaceIndices={},
			}
			remaps[bone]={}
		end
		local group=groups[bone]
		local remap=remaps[bone]
		local mapped={}
		for _,index in ipairs(triangle) do
			if not remap[index] then
				table.insert(group.vertices,source.vertices[index])
				table.insert(group.sourceVertexIndices,index)
				remap[index]=#group.vertices
			end
			table.insert(mapped,remap[index])
		end
		table.insert(group.triangles,mapped)
		table.insert(group.faceUVs,source.faceUVs[faceIndex])
		table.insert(group.faceNormals,source.faceNormals[faceIndex])
		table.insert(group.faceMaterials,source.faceMaterials[faceIndex])
		table.insert(group.sourceFaceIndices,faceIndex)
	end
	local order={}
	for bone in pairs(bones) do
		assert(groups[bone],"GARMENT_BONE_GEOMETRY_MISSING")
		table.insert(order,bone)
	end
	table.sort(order)
	local result={}
	for _,bone in ipairs(order) do table.insert(result,groups[bone]) end
	return result
end

return Partition
