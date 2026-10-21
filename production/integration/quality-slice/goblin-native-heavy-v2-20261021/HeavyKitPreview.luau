--!strict
-- Disposable six-part authored R6 kit. Original block-style prototypes, not
-- provider art parity. Follows existing Edit FK only; no joint/contact claims.
local A=game:GetService("AssetService")
local R=game:GetService("RunService")
local M: any={}
local NAME="AuthoredR6KitReview"
local MAPS={ColorMap="color.png",RoughnessMap="roughness.png",MetalnessMap="metalness.png"}
local BODY: {[string]: any}={
	Torso={size=Vector3.new(2,2,1),rest=Vector3.new(0,3,0)},
	Head={size=Vector3.new(1.25,1.15,1.15),rest=Vector3.new(0,4.6,0)},
	["Left Arm"]={size=Vector3.new(.65,1.9,.75),rest=Vector3.new(-1.4,3,0)},
	["Right Arm"]={size=Vector3.new(.65,1.9,.75),rest=Vector3.new(1.4,3,0)},
	["Left Leg"]={size=Vector3.new(.8,2,.8),rest=Vector3.new(-.5,1,0)},
	["Right Leg"]={size=Vector3.new(.8,2,.8),rest=Vector3.new(.5,1,0)},
}
local COUNTS: {[string]: any}={
	heavy={Torso={784,1516},Head={392,760},Arm={476,920},Leg={476,924}},
	scout={Torso={616,1188},Head={112,216},Arm={336,648},Leg={224,432}},
	ritual={Torso={952,1836},Head={448,864},Arm={392,756},Leg={504,972}},
}
-- Only exact direct HeroRig Warrior decorative parts, never the body/Hand/Eye,
-- equipment containers or unknown descendants. Endpoint and size corroborate name.
local OVERLAYS: {[string]: any}={
	Belt={limbs={Torso=true},size=Vector3.new(2.08,.22,1.08)},
	GuildClasp={limbs={Torso=true},size=Vector3.new(.32,.4,.12)},
	Breastplate={limbs={Torso=true},size=Vector3.new(1.5,1.2,.24)},
	Pauldron={limbs={["Left Arm"]=true,["Right Arm"]=true},size=Vector3.new(.95,.55,1)},
	Helmet={limbs={Head=true},size=Vector3.new(1.4,.4,1.3)},
	HelmetRidge={limbs={Head=true},size=Vector3.new(.22,.25,1.35)},
	Boot={limbs={["Left Leg"]=true,["Right Leg"]=true},size=Vector3.new(.86,.48,1)},
}
local function finite(n: any): boolean
	return type(n)=="number" and n==n and math.abs(n)<1000
end
local function vector(t: any): Vector3
	assert(type(t)=="table" and #t==3 and finite(t[1]) and finite(t[2]) and finite(t[3]),"INVALID_VECTOR")
	return Vector3.new(t[1],t[2],t[3])
end
local function isImage(value: any): boolean
	return (typeof(value)=="Object" or typeof(value)=="Instance") and value:IsA("EditableImage")
end
local function guard()
	assert(R:IsStudio() and not R:IsRunning() and game.PlaceId==0 and game.GameId==0,"LOCAL_UNPUBLISHED_EDIT_ONLY")
end

-- data is six decoded *.mesh.json objects, one kit only. images contains only
-- ColorMap/RoughnessMap/MetalnessMap exact decoded 128x16 palette EditableImages.
-- ALL supplied image resources transfer immediately, including failure paths.
-- Parent and rig are borrowed from GoblinNativePreview; never destroyed here.
function M.New(data: any, images: any, parent: Model, rig: Model, externalAlive: (() -> ())?): any
	local h: any={model=nil,parts={},kit=nil}
	local owned: {any}={}
	local seen: {[any]: boolean}={}
	local links: {RBXScriptConnection}={}
	local hidden: {[BasePart]: number}={}
	local bindings: {any}={}
	local closed=false
	local cleanup: any=nil
	local report: any=nil
	local function own(resource: any): any
		assert(typeof(resource)=="Instance" or (typeof(resource)=="Object" and
			(resource:IsA("EditableMesh") or resource:IsA("EditableImage"))),"ALLOCATION_FAILED")
		if closed then
			local ok,err=pcall(function() (resource :: any):Destroy() end)
			if ok then cleanup.lateDestroyed=(cleanup.lateDestroyed or 0)+1 else table.insert(cleanup.errors,tostring(err)) end
			error("CLOSED_DURING_ALLOCATION",0)
		end
		if not seen[resource] then seen[resource]=true; table.insert(owned,resource) end
		return resource
	end
	function h:Destroy(): any
		if closed then return cleanup end
		closed=true
		cleanup={closed=true,destroyed=0,images=0,meshes=0,restored=0,connections=#links,errors={}}
		for _,connection in ipairs(links) do connection:Disconnect() end
		table.clear(links)
		for part,transparency in pairs(hidden) do
			local ok,err=pcall(function() part.Transparency=transparency end)
			if ok then cleanup.restored+=1 else table.insert(cleanup.errors,tostring(err)) end
		end
		table.clear(hidden)
		for i=#owned,1,-1 do
			local object=owned[i]
			local ok,err=pcall(function()
				if object:IsA("EditableImage") then cleanup.images+=1 end
				if object:IsA("EditableMesh") then cleanup.meshes+=1 end
				object:Destroy()
			end)
			if ok then cleanup.destroyed+=1 else table.insert(cleanup.errors,tostring(err)) end
		end
		table.clear(owned); table.clear(seen); table.clear(bindings); table.clear(h.parts)
		h.model=nil
		return cleanup
	end
	local function alive()
		assert(not closed,"PREVIEW_CLOSED"); guard()
		if externalAlive then externalAlive() end
		assert(not closed,"PREVIEW_CANCELLED")
		assert(typeof(parent)=="Instance" and parent:IsA("Model") and parent.Parent==workspace
			and parent.Name=="GoblinSwordNativeReview" and parent:GetAttribute("LOCAL_TEST_ONLY")==true,"UNOWNED_PARENT")
		assert(typeof(rig)=="Instance" and rig:IsA("Model") and rig.Parent==parent
			and rig.Name=="SyntheticWarrior_EditFK" and rig:GetAttribute("LOCAL_TEST_ONLY")==true
			and rig:GetAttribute("PoseEvidence")=="SYNTHETIC_EDIT_POSE","UNOWNED_RIG")
	end
	local ok,problem=xpcall(function()
		if type(images)=="table" then for _,image in pairs(images) do if isImage(image) then own(image) end end end
		alive()
		assert(type(images)=="table","MISSING_MAPS")
		local mapCount=0
		for role,image in pairs(images) do
			assert(MAPS[role] and isImage(image) and image.Size==Vector2.new(128,16),"UNREVIEWED_PALETTE_MAP")
			mapCount+=1
		end
		assert(mapCount==3,"THREE_PALETTE_MAPS_REQUIRED")
		assert(type(data)=="table" and #data==6,"SIX_PIECES_REQUIRED")
		assert(not parent:FindFirstChild(NAME),"PRIOR_KIT_EXISTS")
		local plans: {any}={}
		local limbSeen: {[string]: boolean}={}
		for _,def in ipairs(data) do
			assert(type(def)=="table" and type(def.id)=="string","INVALID_PAYLOAD")
			local kit=def.id:match("^goblin_(%a+)_r6_")
			assert(kit and COUNTS[kit] and (not h.kit or h.kit==kit),"UNREVIEWED_OR_MIXED_KIT")
			h.kit=kit
			local limbName=def.attachmentLimb
			local reference=BODY[limbName]
			assert(reference and not limbSeen[limbName],"INVALID_OR_DUPLICATE_LIMB")
			limbSeen[limbName]=true
			assert(def.id=="goblin_"..kit.."_r6_"..limbName:gsub(" ","_") and def.units=="stud","SOURCE_ID_MISMATCH")
			assert(def.maps.color==MAPS.ColorMap and def.maps.roughness==MAPS.RoughnessMap and def.maps.metalness==MAPS.MetalnessMap,"SOURCE_MAP_MISMATCH")
			assert((vector(def.restLimbCenterRoblox)-reference.rest).Magnitude<0.00001,"REFERENCE_CENTER_MISMATCH")
			local identity={0,0,0,1,0,0,0,1,0,0,0,1}
			assert(type(def.attachmentLocalCFrame)=="table" and #def.attachmentLocalCFrame==12,"INVALID_LOCAL_FRAME")
			for i,value in ipairs(identity) do assert(def.attachmentLocalCFrame[i]==value,"NONIDENTITY_SOURCE_FRAME") end
			local limb=rig:FindFirstChild(limbName)
			assert(limb and limb:IsA("Part") and limb.Shape==Enum.PartType.Block and limb.Anchored
				and (limb.Size-reference.size).Magnitude<0.00001,"R6_BODY_MISMATCH")
			local kind=if limbName:find("Arm") then "Arm" elseif limbName:find("Leg") then "Leg" else limbName
			local counts=COUNTS[kit][kind]
			assert(type(def.positions)=="table" and #def.positions==counts[1] and type(def.triangles)=="table" and #def.triangles==counts[2],"SOURCE_TOPOLOGY_MISMATCH")
			local points: {Vector3}={}
			local low,high=vector(def.positions[1]),vector(def.positions[1])
			for _,position in ipairs(def.positions) do
				local p=vector(position); assert(p.Magnitude<5,"UNREVIEWED_LOCAL_EXTENT")
				table.insert(points,p); low=low:Min(p); high=high:Max(p)
			end
			local size=high-low
			assert(size.X>=.05 and size.Y>=.05 and size.Z>=.05,"UNSUPPORTED_MESH_SIZE")
			table.insert(plans,{def=def,points=points,limb=limb,size=size,center=(low+high)/2})
		end
		local folder=own(Instance.new("Model")) :: Model
		folder.Name=NAME; folder:SetAttribute("LOCAL_TEST_ONLY",true)
		folder:SetAttribute("FitStatus","AUTHORED_CANDIDATE_NATIVE_FIT_PENDING")
		folder:SetAttribute("Kit",h.kit); folder.Parent=parent; h.model=folder
		for _,instance in ipairs({parent,rig,folder}) do
			table.insert(links,instance.Destroying:Connect(function() h:Destroy() end))
		end
		for _,instance in ipairs({parent,rig,folder}) do
			table.insert(links,instance.AncestryChanged:Connect(function()
				if parent.Parent~=workspace or rig.Parent~=parent or folder.Parent~=parent then h:Destroy() end
			end))
		end
		local content: {[string]: any}={}
		for role in pairs(MAPS) do content[role]=Content.fromObject(images[role]) end
		local surface=own(A:CreateSurfaceAppearanceAsync(content)) :: SurfaceAppearance
		alive()
		for _,plan in ipairs(plans) do
			local mesh=own((assert(A:CreateEditableMesh(),"MESH_BUDGET"))) :: EditableMesh
			local ids: {number}={}
			for i,point in ipairs(plan.points) do ids[i]=mesh:AddVertex(point-plan.center) end
			for i,face in ipairs(plan.def.triangles) do
				assert(type(face)=="table" and face.material==0 and #face.vertices==3 and #face.uv==3 and #face.normals==3,"INVALID_TRIANGLE")
				local vertices: {number}={}; local uvs: {number}={}; local normals: {number}={}
				for j=1,3 do
					local index=face.vertices[j]
					assert(finite(index) and index%1==0 and index>=0 and index<#plan.points,"INVALID_INDEX")
					vertices[j]=ids[index+1]
					local uv=face.uv[j]
					assert(type(uv)=="table" and #uv==2 and finite(uv[1]) and finite(uv[2]) and uv[1]>=0 and uv[1]<=1
						and math.abs(uv[2]-.5)<0.00001 and math.abs((uv[1]*8-.5)-math.round(uv[1]*8-.5))<0.00001,"INVALID_PALETTE_UV")
					uvs[j]=mesh:AddUV(Vector2.new(uv[1],1-uv[2]))
					local normal=vector(face.normals[j]); assert(math.abs(normal.Magnitude-1)<0.0001,"INVALID_NORMAL")
					normals[j]=mesh:AddNormal(normal)
				end
				assert(vertices[1]~=vertices[2] and vertices[1]~=vertices[3] and vertices[2]~=vertices[3],"REPEATED_INDEX")
				local id=mesh:AddTriangle(vertices[1],vertices[2],vertices[3])
				mesh:SetFaceUVs(id,uvs); mesh:SetFaceNormals(id,normals)
				if i%500==0 then task.wait(); alive() end
			end
			mesh:RemoveUnused()
			local fixed=own((assert(A:CreateEditableMeshAsync(Content.fromObject(mesh),{FixedSize=true}),"FIXED_MESH_BUDGET"))) :: EditableMesh
			alive()
			assert(fixed.FixedSize and #fixed:GetVertices()==#plan.points and #fixed:GetFaces()==#plan.def.triangles
				and fixed:GetCenter().Magnitude<0.0001,"FIXED_MESH_MISMATCH")
			mesh:Destroy()
			local part=own(A:CreateMeshPartAsync(Content.fromObject(fixed))) :: MeshPart
			alive()
			part.Name=plan.def.id; part.Size=plan.size; part.Anchored=true; part.Massless=true
			part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
			part.Material=Enum.Material.SmoothPlastic; part.Color=Color3.new(1,1,1)
			part:SetAttribute("LOCAL_TEST_ONLY",true); part:SetAttribute("SourceLimb",plan.limb.Name)
			local appearance=own(surface:Clone()) :: SurfaceAppearance
			appearance.Parent=part; part.CFrame=plan.limb.CFrame*CFrame.new(plan.center); part.Parent=folder
			table.insert(bindings,{part=part,limb=plan.limb,center=plan.center,size=plan.size})
			table.insert(h.parts,part)
		end
		local function eligible(part: BasePart): boolean
			local spec=OVERLAYS[part.Name]
			if not spec or part.Parent~=rig or part.ClassName~="Part" or (part.Size-spec.size).Magnitude>.00001 then return false end
			local children=part:GetChildren()
			if #children~=1 or not children[1]:IsA("WeldConstraint") then return false end
			local weld=children[1] :: WeldConstraint
			local limb: BasePart?=weld.Part0
			if not limb then return false end
			return weld.Enabled and weld.Part1==part and limb.Parent==rig
				and spec.limbs[limb.Name]==true and rig:FindFirstChild(limb.Name)==limb
		end
		function h:Pose(): any
			local poseOK,result=xpcall(function()
				alive(); assert(folder.Parent==parent,"KIT_REMOVED")
				for _,binding in ipairs(bindings) do
					assert(binding.limb.Parent==rig and rig:FindFirstChild(binding.limb.Name)==binding.limb
						and binding.limb.Anchored and (binding.limb.Size-BODY[binding.limb.Name].size).Magnitude<.00001
						and binding.part.Parent==folder,"KIT_BINDING_CHANGED")
					binding.part.CFrame=binding.limb.CFrame*CFrame.new(binding.center)
				end
				local hiddenCount=0
				for part in pairs(hidden) do
					assert(eligible(part),"LEGACY_OVERLAY_CHANGED"); part.Transparency=1; hiddenCount+=1
				end
				report={scope="SYNTHETIC_EDIT_FOLLOW",kit=h.kit,parts=#bindings,hiddenLegacyOverlays=hiddenCount,
					fitStatus="UNVALIDATED",scale=1,uvConvention="CORNER_U_1_MINUS_V",maps=3,
					bodyLimbsUnmodified=true,geometry="ORIGINAL_BLOCK_STYLE_ADAPTATION"}
				return report
			end,debug.traceback)
			if not poseOK then h:Destroy(); error(tostring(result),0) end
			return result
		end
		h:Pose() -- All six must be valid before hiding even one original overlay.
		for _,part in ipairs(rig:GetChildren()) do
			if part:IsA("BasePart") and eligible(part) then hidden[part]=part.Transparency; part.Transparency=1 end
		end
		table.insert(links,rig.DescendantRemoving:Connect(function(item)
			if hidden[item :: any]~=nil then h:Destroy(); return end
			for _,binding in ipairs(bindings) do if item==binding.limb then h:Destroy(); return end end
		end))
		h:Pose()
	end,debug.traceback)
	if not ok then M.LastFailureCleanup=h:Destroy(); error(tostring(problem),0) end
	return h
end
return M
