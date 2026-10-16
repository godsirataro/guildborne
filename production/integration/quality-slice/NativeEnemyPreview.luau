--!strict
-- Local inspection only. Input must pass validate_enemy before packaging.
-- No attack markers, animation scheduler, gameplay state or uploaded asset IDs.
local Assets = game:GetService("AssetService")
local Preview = {}
local function vector(v: {number}): Vector3 return Vector3.new(v[1], v[2], v[3]) end
local function transform(v: {number}): CFrame return CFrame.new(table.unpack(v)) end
function Preview.create(data: any, parent: Instance, origin: CFrame, onAllocated: ((any) -> ())?): any
	assert(game:GetService("RunService"):IsStudio() and game.PlaceId == 0 and game.GameId == 0, "Local Studio only")
	assert(data.schemaVersion == 1 and typeof(origin) == "CFrame", "Validated enemy data and origin CFrame required")
	local folder = Instance.new("Folder")
	folder.Name = "QualityEnemyReview"; folder:SetAttribute("LocalPreviewOnly", true); folder.Parent = parent
	local meshes: {EditableMesh} = {}
	local bones: {Bone} = {}
	local part: MeshPart? = nil
	local closed = false
	local result: any = {folder=folder, bones=bones, meshes=meshes, ready=false}
	function result.destroy()
		closed = true; result.ready = false
		folder:Destroy()
		if part then part:Destroy(); part=nil end
		for _, mesh in ipairs(meshes) do mesh:Destroy() end
		table.clear(meshes); table.clear(bones)
	end
	local function check() assert(not closed, "Enemy construction cancelled") end
	-- nil selects the exact bind/rest pose. Nonlooping clips hold their last sample.
	-- Endpoint samples are retained for interpolation, not repeated as a loop frame.
	function result.frame(clipName: string?, seconds: number)
		check(); assert(result.ready, "Enemy construction incomplete")
		assert(seconds == seconds and math.abs(seconds) < math.huge and seconds >= 0, "Finite nonnegative time required")
		if clipName == nil then
			for _, bone in ipairs(bones) do bone.Transform = CFrame.identity end
			return
		end
		local clip = assert(data.clips[clipName], "Unknown source clip")
		local time = if clip.looped then seconds % clip.seconds else math.min(seconds, clip.seconds)
		local sample = time / clip.seconds * (#clip.frames - 1)
		local first = math.min(math.floor(sample) + 1, #clip.frames)
		local second = math.min(first + 1, #clip.frames)
		local alpha = sample - math.floor(sample)
		for i, bone in ipairs(bones) do
			bone.Transform = transform(clip.frames[first][i]):Lerp(transform(clip.frames[second][i]), alpha)
		end
	end
	local ok, problem = pcall(function()
		if onAllocated then onAllocated(result) end
		check()
		local lower, upper = vector(data.vertices[1]), vector(data.vertices[1])
		for _, v in ipairs(data.vertices) do lower=lower:Min(vector(v)); upper=upper:Max(vector(v)) end
		local center = (lower + upper) * .5
		local shift = CFrame.new(-center)
		result.sourceCenter = center
		local mesh = assert(Assets:CreateEditableMesh(), "Editable mesh memory unavailable")
		table.insert(meshes, mesh)
		local boneIds, vertices, colors = {}, {}, {}
		for i, b in ipairs(data.bones) do
			local options: any = {Name=b.name, CFrame=shift * transform(b.bind), Virtual=false}
			if b.parent > 0 then options.ParentId=boneIds[b.parent] end
			boneIds[i] = mesh:AddBone(options)
		end
		for i, v in ipairs(data.vertices) do
			local vertex = mesh:AddVertex(vector(v) - center); vertices[i]=vertex
			local influences, weights = {}, {}
			for _, influence in ipairs(data.weights[i]) do
				table.insert(influences, boneIds[influence[1]]); table.insert(weights, influence[2])
			end
			mesh:SetVertexBones(vertex, influences); mesh:SetVertexBoneWeights(vertex, weights)
			if i % 750 == 0 then task.wait(); check() end
		end
		for i, color in ipairs(data.colors) do colors[i]=mesh:AddColor(Color3.new(color[1],color[2],color[3]),1) end
		for i, face in ipairs(data.triangles) do
			local id = mesh:AddTriangle(vertices[face[1]],vertices[face[2]],vertices[face[3]])
			local color = colors[data.faceColors[i]]; mesh:SetFaceColors(id,{color,color,color})
			local a,b,c = vector(data.vertices[face[1]]),vector(data.vertices[face[2]]),vector(data.vertices[face[3]])
			local cross=(b-a):Cross(c-a)
			if cross.Magnitude > .000001 then
				local normal=mesh:AddNormal(cross.Unit); mesh:SetFaceNormals(id,{normal,normal,normal})
			end
			if i % 750 == 0 then task.wait(); check() end
		end
		local fixed=assert(Assets:CreateEditableMeshAsync(Content.fromObject(mesh),{FixedSize=true}),"Fixed mesh memory unavailable")
		table.insert(meshes,fixed); check(); mesh:Destroy(); mesh=fixed
		part=Assets:CreateMeshPartAsync(Content.fromObject(mesh)); check()
		local actor=assert(part)
		actor.Name=data.id; actor.Anchored=true; actor.CanCollide=false; actor.CanTouch=false; actor.CanQuery=false
		actor.Color=Color3.new(1,1,1); actor.Material=Enum.Material.SmoothPlastic
		-- Mesh coordinates and model-space binds share a centered basis. Restore
		-- the source offset outside the skinning transform and rotate everything together.
		local remainingCenter=mesh:GetCenter()
		actor.CFrame=origin * CFrame.Angles(0,math.rad(data.recommendedRootYawDegrees or 180),0) * CFrame.new(center + remainingCenter)
		actor.Parent=folder; result.part=actor
		for i,b in ipairs(data.bones) do
			local bone=Instance.new("Bone"); bone.Name=b.name
			bone.CFrame=if b.parent>0 then transform(b.localBind) else CFrame.new(-remainingCenter)*shift*transform(b.localBind)
			bone.Parent=if b.parent>0 then bones[b.parent] else actor; bones[i]=bone
		end
		result.ready=true; result.frame(nil,0)
	end)
	if not ok then result.destroy(); error(tostring(problem)) end
	return result
end
return Preview
