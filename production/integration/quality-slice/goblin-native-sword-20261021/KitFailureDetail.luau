--!strict
-- Executable template: root replaces __FRAMES_JSON__ with selected sweep rows.
-- Native vertex containment diagnostics only, never triangle/contact proof.
local H=game:GetService("HttpService")
local E=game:GetService("EncodingService")
local R=game:GetService("RunService")
assert(R:IsStudio() and not R:IsRunning() and game.PlaceId==0 and game.GameId==0,"LOCAL_EDIT_ONLY")
local FRAMES: any=H:JSONDecode([==[__FRAMES_JSON__]==])
assert(type(FRAMES)=="table" and #FRAMES>=1 and #FRAMES<=16,"SELECT_1_TO_16_FRAMES")
local function finite(n: any): boolean return type(n)=="number" and n==n and math.abs(n)<1000 end
for _,frame in ipairs(FRAMES) do
	assert(type(frame)=="table" and type(frame.label)=="string" and #frame.label<=128,"INVALID_FRAME")
	assert(frame.age==nil or (finite(frame.age) and frame.age>=0 and frame.age<=.62),"INVALID_AGE")
	assert(frame.phase==nil or finite(frame.phase),"INVALID_PHASE")
	assert(frame.forwardDegrees==nil or frame.forwardDegrees==65 or frame.forwardDegrees==100,"INVALID_FORWARD_REACH")
end
local runner=assert(game:GetService("ReplicatedStorage"):FindFirstChild("GoblinSwordReviewRunner"),"NO_REVIEW_RUNNER")
local s: any=(require :: any)(assert(runner:FindFirstChild("ReviewTransport"))).Get()
local k: any=(require :: any)(assert(runner:FindFirstChild("KitTransport"))).Get()
local function xyz(v: Vector3): {number} return {v.X,v.Y,v.Z} end
local function minimumBoxY(part: BasePart): number
	local low=math.huge
	local half=part.Size/2
	for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
		low=math.min(low,part.CFrame:PointToWorldSpace(Vector3.new(x*half.X,y*half.Y,z*half.Z)).Y)
	end end end
	return low
end
local rows: {any}={}
local body: {any}={}
local meshes: {any}={}
local ok,problem=xpcall(function()
	assert(s.rig.Parent==s.model and s.model.Parent==workspace and #k.parts==6,"REVIEW_HANDLES_CHANGED")
	for _,part in ipairs(s.rig:GetDescendants()) do
		if part:IsA("Part") and part.Shape==Enum.PartType.Block and part.Transparency==0 and part.LocalTransparencyModifier==0 then
			table.insert(body,{part=part,id=part.Name.."#"..tostring(#body+1),path=part:GetFullName()})
		end
	end
	assert(#body>=6 and #body<=32,"UNEXPECTED_BARE_BODY_CENSUS")
	for _,part in ipairs(k.parts) do
		local mesh=part.MeshContent.Object
		assert(mesh and mesh:IsA("EditableMesh"),"NO_NATIVE_EDITABLE_MESH")
		local limb=s.rig:FindFirstChild(part:GetAttribute("SourceLimb"))
		assert(limb and limb:IsA("Part") and limb.Shape==Enum.PartType.Block and limb.Transparency==0,"MISSING_OPAQUE_SOURCE_LIMB")
		local vertices={}
		for _,id in ipairs(mesh:GetVertices()) do table.insert(vertices,{id=id,point=mesh:GetPosition(id)}) end
		assert(#vertices>0 and #vertices<=1000,"VERTEX_BUDGET")
		table.insert(meshes,{part=part,mesh=mesh,limb=limb,vertices=vertices,faces=#mesh:GetFaces()})
	end
	for _,frame in ipairs(FRAMES) do
		s:Pose(frame.age,frame.phase,"rx_neg90")
		-- Identical synthetic forward override to KitFitSweep: preserve all
		-- decorative weld offsets, apply shoulders, then move their details.
		if frame.forwardDegrees then
			local details={}
			for _,w in ipairs(s.rig:GetDescendants()) do
				if w:IsA("WeldConstraint") and w.Part0 and w.Part1 then
					table.insert(details,{a=w.Part0,b=w.Part1,cf=w.Part0.CFrame:ToObjectSpace(w.Part1.CFrame)})
				end
			end
			for _,motor in ipairs(s.rig:GetDescendants()) do
				if motor:IsA("Motor6D") and motor.Name:find("Shoulder") then
					motor.Part1.CFrame=motor.Part0.CFrame*motor.C0*CFrame.Angles(math.rad(frame.forwardDegrees),0,0)*motor.C1:Inverse()
				end
			end
			for _,w in ipairs(details) do w.b.CFrame=w.a.CFrame*w.cf end
		end
		k:Pose(); task.wait()
		assert(not R:IsRunning() and s.model.Parent==workspace,"EDIT_SCENE_CHANGED")
		local bodyRows={}
		local bareMinY=math.huge
		for _,item in ipairs(body) do
			local part=item.part
			assert(part:IsDescendantOf(s.rig) and part.Transparency==0 and part.LocalTransparencyModifier==0,"BODY_CENSUS_CHANGED")
			local low=minimumBoxY(part); bareMinY=math.min(bareMinY,low)
			table.insert(bodyRows,{id=item.id,name=part.Name,path=item.path,size=xyz(part.Size),minY=low,cframe={part.CFrame:GetComponents()}})
		end
		local core: {BasePart}={}
		for _,name in ipairs({"Torso","Head","Left Arm","Right Arm","Left Leg","Right Leg"}) do
			local part=s.rig:FindFirstChild(name)
			assert(part and part:IsA("Part") and part.Shape==Enum.PartType.Block and part.Transparency==0,"CORE_BASELINE_CHANGED")
			table.insert(core,part)
		end
		local cornerHits={}; local pairCounts: {[string]: number}={}
		for _,part in ipairs(core) do
			local half=part.Size/2
			for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
				local world=part.CFrame:PointToWorldSpace(Vector3.new(x*half.X,y*half.Y,z*half.Z))
				local matches={}
				for _,other in ipairs(core) do
					if other~=part then
						local q=other.CFrame:PointToObjectSpace(world); local bounds=other.Size/2
						if math.abs(q.X)<bounds.X-.00001 and math.abs(q.Y)<bounds.Y-.00001 and math.abs(q.Z)<bounds.Z-.00001 then
							table.insert(matches,other.Name)
							local key=part.Name.." -> "..other.Name; pairCounts[key]=(pairCounts[key] or 0)+1
						end
					end
				end
				if #matches>0 then table.insert(cornerHits,{sourceLimb=part.Name,cornerSigns={x,y,z},world=xyz(world),insideLimbs=matches}) end
			end end end
		end
		local parts={}
		local totalInside,totalMinimum=0,math.huge
		for _,entry in ipairs(meshes) do
			local part,limb,mesh=entry.part,entry.limb,entry.mesh
			local function matchingBodies(world: Vector3): {any}
				local matches={}
				for _,item in ipairs(body) do
					local q=item.part.CFrame:PointToObjectSpace(world); local half=item.part.Size/2
					if math.abs(q.X)<half.X-.00001 and math.abs(q.Y)<half.Y-.00001 and math.abs(q.Z)<half.Z-.00001 then
						table.insert(matches,{bodyId=item.id,name=item.part.Name,bodyLocal=xyz(q),
							nearestBoxBoundaryDistance=math.min(half.X-math.abs(q.X),half.Y-math.abs(q.Y),half.Z-math.abs(q.Z))})
					end
				end
				return matches
			end
			local function detail(vertex: any, matches: {any}): any
				local world=part.CFrame:PointToWorldSpace(vertex.point)
				local faces={}
				local faceIds=mesh:GetVertexFaces(vertex.id)
				assert(#faceIds<=128,"INCIDENT_FACE_BUDGET")
				for _,faceId in ipairs(faceIds) do
					local ids=mesh:GetFaceVertices(faceId); local localPoints={}
					for _,id in ipairs(ids) do
						table.insert(localPoints,xyz(limb.CFrame:PointToObjectSpace(part.CFrame:PointToWorldSpace(mesh:GetPosition(id)))))
					end
					table.insert(faces,{nativeFaceId=faceId,nativeVertexIds=ids,sourceLimbLocalVertices=localPoints})
				end
				return {nativeVertexId=vertex.id,centeredMeshLocal=xyz(vertex.point),
					sourceLimbLocal=xyz(limb.CFrame:PointToObjectSpace(world)),world=xyz(world),
					matchingBodies=matches,incidentNativeFaceIds=faceIds,incidentTriangles=faces}
			end
			local examples={}; local grouped: {[string]: number}={}
			local inside=0; local low=math.huge; local minimum: any=nil
			for _,vertex in ipairs(entry.vertices) do
				local world=part.CFrame:PointToWorldSpace(vertex.point)
				if world.Y<low then low=world.Y; minimum=vertex end
				local matches=matchingBodies(world)
				if #matches>0 then
					inside+=1
					for _,match in ipairs(matches) do grouped[match.bodyId]=(grouped[match.bodyId] or 0)+1 end
					if #examples<8 then table.insert(examples,detail(vertex,matches)) end
				end
			end
			local sameLimbMinY=minimumBoxY(limb)
			totalInside+=inside; totalMinimum=math.min(totalMinimum,low)
			local minimumWorld=part.CFrame:PointToWorldSpace(minimum.point)
			table.insert(parts,{name=part.Name,sourceLimb=limb.Name,vertices=#entry.vertices,faces=entry.faces,
				verticesInsideBody=inside,insideCountsByBody=grouped,examples=examples,examplesOmitted=math.max(0,inside-#examples),
				minimumVertex=detail(minimum,matchingBodies(minimumWorld)),minY=low,
				sameLimbBareBodyMinY=sameLimbMinY,totalBareRigMinY=bareMinY,
				minYMinusSameLimbBodyMinY=low-sameLimbMinY,minYMinusBareRigMinY=low-bareMinY,
				belowWorldZeroBy=math.max(0,-low),sourceLocalReconstruction="LIMB_INVERSE_X_PART_X_CENTERED_VERTEX"})
		end
		table.insert(rows,{label=frame.label,age=frame.age,phase=frame.phase,forwardDegrees=frame.forwardDegrees,
			verticesInsideBody=totalInside,minY=totalMinimum,totalBareRigMinY=bareMinY,bodies=bodyRows,parts=parts,
			coreBodyCornerBaseline={coreLimbs=6,cornersTested=48,uniqueCornersInsideOtherCoreLimbs=#cornerHits,
				pairCounts=pairCounts,corners=cornerHits,limitation="CORNER_CONTAINMENT_ONLY; ZERO_IS_NOT_OBB_CLEARANCE_PROOF"}})
	end
end,debug.traceback)
-- Reset even if extraction fails. A failed reset is reported, never hidden.
local resetOK,resetError=pcall(function() s:Pose(nil,nil,"rx_neg90"); k:Pose() end)
local payload={scope="SYNTHETIC_EDIT_ARMOR_VERTEX_DETAIL",kit=k.kit,success=ok,resetToIdle=resetOK,
	error=if ok then nil else tostring(problem),resetError=if resetOK then nil else tostring(resetError),
	vertexIdMeaning="NATIVE_EDITABLE_IDS_NOT_SOURCE_JSON_INDICES",containmentEpsilon=.00001,
	countMeaning="UNIQUE_VERTICES_PER_PIECE; PER_BODY_COUNTS_MAY_OVERLAP",belowFloorMeaning="WORLD_Y_ZERO_DIAGNOSTIC_NO_FLOOR_COLLISION_TEST",
	limitations="Vertex sampling is not triangle intersection or native animation/contact acceptance.",frames=rows}
local raw=H:JSONEncode(payload)
local encoded=buffer.tostring(E:Base64Encode(E:CompressBuffer(buffer.fromstring(raw),Enum.CompressionAlgorithm.Zstd,3)))
return H:JSONEncode({scope=payload.scope,kit=k.kit,success=ok,resetToIdle=resetOK,frames=#rows,bytes=#raw,
	encodedBytes=#encoded,zstdBase64=encoded})
