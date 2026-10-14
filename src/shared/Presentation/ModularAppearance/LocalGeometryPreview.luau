--!strict
-- Isolated, static no-upload inspection of actual Blender candidate geometry.
-- This module is never called by the live appearance renderer or import registry.
local AssetService=game:GetService("AssetService")
local RunService=game:GetService("RunService")
local Catalog=require(script.Parent.Parent.Parent.Data.AppearanceCatalog)
local Geometry=require(script.Parent.GeneratedGeometry)
local LocalRig=require(script.Parent.LocalGeometryRig)
local Preview={}
local resources: {[Model]: {EditableMesh}}={}
local connections: {[Model]: RBXScriptConnection}={}
local V=Vector3.new

local function available(): boolean
	return RunService:IsStudio() and game.PlaceId==0 and game.GameId==0
end
Preview.IsAvailable=available

local function release(model: Model)
	local connection=connections[model];if connection then connection:Disconnect();connections[model]=nil end
	local retained=resources[model];resources[model]=nil
	if retained then for _,editable in ipairs(retained) do editable:Destroy() end end
end

function Preview.ResourceCount(model: Model?): number
	if model then return #(resources[model] or {}) end
	local count=0;for _,retained in pairs(resources) do count+=#retained end;return count
end
function Preview.Destroy(model: Model)
	release(model);model:Destroy()
end

local function blank(name: string): Model
	local model=Instance.new("Model");model.Name=name
	model:SetAttribute("AssetStatus","LOCAL_EDITABLE_MESH_PREVIEW_ONLY")
	model:SetAttribute("GeometryOrigin","HASHED_BLENDER_SOURCE_CANDIDATE")
	model:SetAttribute("RigStatus","STATIC_UNRIGGED_PREVIEW")
	model:SetAttribute("CageStatus","UNAVAILABLE")
	model:SetAttribute("ProductionImported",false);model:SetAttribute("ProductionTested",false)
	model.WorldPivot=CFrame.identity
	resources[model]={};connections[model]=model.Destroying:Connect(function() release(model) end)
	return model
end

local function append(model: Model,parent: Instance,assetId: string,options: any)
	local asset=Geometry.Assets[assetId];assert(asset,"SOURCE_GEOMETRY_UNAVAILABLE:"..assetId)
	for _,source in ipairs(asset.meshes) do
		local low=V(math.huge,math.huge,math.huge);local high=V(-math.huge,-math.huge,-math.huge)
		for _,coordinates in ipairs(source.vertices) do
			local point=V(coordinates[1],coordinates[2],coordinates[3]);low=low:Min(point);high=high:Max(point)
		end
		local center=(low+high)/2
		local editable=AssetService:CreateEditableMesh();assert(editable,"EDITABLE_MESH_MEMORY_UNAVAILABLE")
		local retained=resources[model];table.insert(retained,editable);local dynamicIndex=#retained
		local vertexIds: {number}={}
		for _,coordinates in ipairs(source.vertices) do table.insert(vertexIds,editable:AddVertex(V(coordinates[1],coordinates[2],coordinates[3])-center)) end
		local materialIds: {number}={}
		local skin=source.skinTintable and options.skinPaletteId and Catalog.SkinPalettes[options.skinPaletteId]
		local hair=assetId=="ACC_HAIR_HUMAN_01" and options.hairColorId and Catalog.HairColors[options.hairColorId]
		for _,material in ipairs(source.materials) do
			local rgb=material.colorRGB
			local color=if skin or hair then Color3.new(1,1,1) else Color3.fromRGB(rgb[1],rgb[2],rgb[3])
			table.insert(materialIds,editable:AddColor(color,material.alpha))
		end
		for index,triangle in ipairs(source.triangles) do
			local faceId=editable:AddTriangle(vertexIds[triangle[1]],vertexIds[triangle[2]],vertexIds[triangle[3]])
			local uvs=source.faceUVs[index]
			local uvIds: {number}={}
			for _,uv in ipairs(uvs) do table.insert(uvIds,editable:AddUV(Vector2.new(uv[1],uv[2]))) end
			editable:SetFaceUVs(faceId,uvIds)
			local normal=source.faceNormals[index];local normalId=editable:AddNormal(V(normal[1],normal[2],normal[3]))
			editable:SetFaceNormals(faceId,{normalId,normalId,normalId})
			local colorId=materialIds[source.faceMaterials[index]]
			editable:SetFaceColors(faceId,{colorId,colorId,colorId})
		end
		-- A dynamic mesh reserves much more client memory than this small source geometry.
		-- Keep both resources in cleanup until the compact copy has its linked MeshPart.
		editable:RemoveUnused()
		local compact=AssetService:CreateEditableMeshAsync(Content.fromObject(editable),{FixedSize=true})
		assert(compact,"FIXED_EDITABLE_MESH_MEMORY_UNAVAILABLE");table.insert(retained,compact)
		assert(compact.FixedSize,"FIXED_EDITABLE_MESH_REQUIRED")
		assert(#compact:GetVertices()==#source.vertices and #compact:GetFaces()==#source.triangles,"COMPACT_SOURCE_GEOMETRY_COUNT_CHANGED")
		local meshPart=AssetService:CreateMeshPartAsync(Content.fromObject(compact))
		meshPart.Parent=parent -- Enroll the part in model cleanup before any further property assignment.
		editable:Destroy();retained[dynamicIndex]=compact;table.remove(retained,#retained)
		meshPart.Name=source.runtimePart;meshPart.Size=high-low;meshPart.CFrame=CFrame.new(center)
		meshPart.Color=if skin then Color3.fromHex(skin.colorHex) elseif hair then Color3.fromHex(hair) else Color3.new(1,1,1)
		meshPart.Material=Enum.Material.SmoothPlastic;meshPart.Transparency=0
		meshPart.Anchored=true;meshPart.Massless=true;meshPart.CanCollide=false;meshPart.CanTouch=false;meshPart.CanQuery=false
		meshPart:SetAttribute("AssetId",assetId);meshPart:SetAttribute("AssetStatus","LOCAL_EDITABLE_MESH_PREVIEW_ONLY")
		meshPart:SetAttribute("SourceSha256",asset.sourceSha256);meshPart:SetAttribute("SourcePath",asset.sourcePath)
		meshPart:SetAttribute("CoreBodyPart",source.coreBodyPart);meshPart:SetAttribute("SkinTintable",source.skinTintable)
		meshPart:SetAttribute("SourceVertexCount",#source.vertices);meshPart:SetAttribute("SourceTriangleCount",#source.triangles)
		meshPart:SetAttribute("EditableMeshFixedSize",true)
		meshPart:SetAttribute("RigStatus","STATIC_UNRIGGED_PREVIEW");meshPart:SetAttribute("CageStatus","UNAVAILABLE")
	end
end

local function optionsValid(options: any): boolean
	if type(options)~="table" then return false end
	local skin=options.skinPaletteId and Catalog.SkinPalettes[options.skinPaletteId]
	if options.skinPaletteId and (not skin or skin.raceId~="HUMAN") then return false end
	if options.hairColorId and not Catalog.HairColors[options.hairColorId] then return false end
	return true
end

function Preview.BuildAsset(assetId: string,options: any?): (Model?,string?)
	if not available() then return nil,"LOCAL_UNPUBLISHED_STUDIO_ONLY" end
	if type(assetId)~="string" or not Geometry.Assets[assetId] then return nil,"SOURCE_GEOMETRY_UNAVAILABLE" end
	local selected=options or {};if not optionsValid(selected) then return nil,"INVALID_PREVIEW_COLOR" end
	local model=blank(assetId.."_LocalMeshPreview")
	model:SetAttribute("AssetId",assetId);model:SetAttribute("SourceSha256",Geometry.Assets[assetId].sourceSha256)
	model:SetAttribute("SourceTriangleCount",Geometry.Assets[assetId].triangleCount)
	local ok,err=pcall(function() append(model,model,assetId,selected);return true end)
	if not ok then Preview.Destroy(model);return nil,"LOCAL_MESH_CREATION_FAILED:"..tostring(err) end
	return model,nil
end

function Preview.Build(selection: any): (Model?,string?)
	if not available() then return nil,"LOCAL_UNPUBLISHED_STUDIO_ONLY" end
	if type(selection)~="table" or selection.raceId~="HUMAN" or not optionsValid(selection) then return nil,"INVALID_PREVIEW_SELECTION" end
	local body=Catalog.Bodies[selection.bodyPresetId]
	if not body or not Geometry.Assets[body.assetId] then return nil,"SOURCE_BODY_UNAVAILABLE" end
	if selection.outfitSlots~=nil and type(selection.outfitSlots)~="table" then return nil,"INVALID_PREVIEW_OUTFIT" end
	local assetIds={}
	if selection.hairAssetId then
		if selection.hairAssetId~="ACC_HAIR_HUMAN_01" then return nil,"SOURCE_HAIR_UNAVAILABLE" end
		table.insert(assetIds,selection.hairAssetId)
	end
	for _,slot in ipairs(Catalog.SlotOrder) do
		local id=(selection.outfitSlots or {})[slot]
		if id then
			local asset=Catalog.Assets[id]
			if not asset or asset.slot~=slot or not Geometry.Assets[id] then return nil,"SOURCE_OUTFIT_UNAVAILABLE" end
			table.insert(assetIds,id)
		end
	end
	local model=blank(selection.bodyPresetId.."_LocalMeshPreview")
	model:SetAttribute("BodyPresetId",selection.bodyPresetId);model:SetAttribute("SkinPaletteId",selection.skinPaletteId)
	model:SetAttribute("BodyAssetId",body.assetId);model:SetAttribute("BodySourceSha256",Geometry.Assets[body.assetId].sourceSha256)
	model:SetAttribute("ClothingFit","SOURCE_CANDIDATE_UNTESTED")
	local ok,err=pcall(function()
		append(model,model,body.assetId,selection)
		local garments=Instance.new("Model");garments.Name="SeparateClothesAndAccessories";garments.Parent=model
		for _,id in ipairs(assetIds) do append(model,garments,id,selection) end
		return true
	end)
	if not ok then Preview.Destroy(model);return nil,"LOCAL_MESH_CREATION_FAILED:"..tostring(err) end
	return model,nil
end

function Preview.BuildRig(selection: any): (Model?,string?)
	if not available() then return nil,"LOCAL_UNPUBLISHED_STUDIO_ONLY" end
	if type(selection)~="table" or selection.raceId~="HUMAN" or not optionsValid(selection) then return nil,"INVALID_PREVIEW_SELECTION" end
	if selection.outfitSlots~=nil and type(selection.outfitSlots)~="table" then return nil,"INVALID_PREVIEW_OUTFIT" end
	local articulated={}
	for key,value in pairs(selection) do articulated[key]=value end
	articulated.outfitSlots={};local omitted={}
	for slot,id in pairs(selection.outfitSlots or {}) do
		local asset=Catalog.Assets[id]
		if not asset or asset.slot~=slot or not Geometry.Assets[id] then return nil,"SOURCE_OUTFIT_UNAVAILABLE" end
		if id=="CLO_HAT_WIZARD_01" then articulated.outfitSlots[slot]=id
		elseif asset.technology=="LAYERED" then table.insert(omitted,id)
		else return nil,"ARTICULATED_ACCESSORY_UNAVAILABLE" end
	end
	table.sort(omitted)
	local model,err=Preview.Build(articulated);if not model then return nil,err end
	local body=Catalog.Bodies[selection.bodyPresetId]
	local ok,rigError=pcall(function() LocalRig.Assemble(model,body.assetId);return true end)
	if not ok then Preview.Destroy(model);return nil,"LOCAL_RIG_CREATION_FAILED:"..tostring(rigError) end
	model:SetAttribute("OmittedUnskinnedGarments",table.concat(omitted,","))
	return model,nil
end

return Preview
