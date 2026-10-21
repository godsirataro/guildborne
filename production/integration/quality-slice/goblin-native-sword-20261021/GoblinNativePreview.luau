--!strict
-- Disposable source-art review. Manual anchored Edit FK is SYNTHETIC_EDIT_POSE,
-- never runtime animation, hit/contact evidence, an accepted fit, or an upload.
local A = game:GetService("AssetService")
local R = game:GetService("RunService")
local P = game:GetService("PhysicsService")
local M: any = {}
local NAME = "GoblinSwordNativeReview"
local GROUP = "GuildborneHeroes"
local MAPS = {"ColorMap", "NormalMap", "RoughnessMap", "MetalnessMap"}
local FITS: {[string]: CFrame} = {
	identity = CFrame.identity,
	rx_neg90 = CFrame.Angles(-math.pi/2, 0, 0),
	rx_180 = CFrame.Angles(math.pi, 0, 0),
}
local function finite(n: any): boolean
	return type(n) == "number" and n == n and math.abs(n) < 1000000
end
local function vec(a: any): Vector3
	assert(type(a) == "table" and #a == 3 and finite(a[1]) and finite(a[2]) and finite(a[3]), "INVALID_VECTOR")
	return Vector3.new(a[1], a[2], a[3])
end
local function xyz(v: Vector3): {number} return {v.X, v.Y, v.Z} end
local function guard()
	assert(R:IsStudio() and not R:IsRunning() and game.PlaceId == 0 and game.GameId == 0, "LOCAL_UNPUBLISHED_EDIT_ONLY")
end
local function child(parent: Instance, name: string): Instance
	return assert(parent:FindFirstChild(name), "MISSING_SOURCE:" .. name)
end

-- Ownership of all supplied EditableImages transfers immediately, including
-- on guard/validation failure. The caller must not reuse them after New.
function M.New(data: any, images: any, externalAlive: (() -> ())?): any
	local h: any = {model=nil, rig=nil, part=nil, center=nil, samples={}}
	local owned: {any} = {}
	local seen: {[any]: boolean} = {}
	local connections: {RBXScriptConnection} = {}
	local closed, groupOwned = false, false
	local cleanup: any = nil
	local function own(resource: any): any
		assert(typeof(resource)=="Instance" or (typeof(resource)=="Object"
			and (resource:IsA("EditableImage") or resource:IsA("EditableMesh"))), "RESOURCE_ALLOCATION_FAILED")
		-- Folder destruction can close the handle while an async API is yielding.
		-- Its late return is not in the already-drained ownership array.
		if closed then
			local disposed,err=pcall(function() (resource :: any):Destroy() end)
			if disposed then cleanup.lateDestroyed=(cleanup.lateDestroyed or 0)+1
			else table.insert(cleanup.errors,tostring(err)) end
			error("PREVIEW_CLOSED_DURING_ALLOCATION",0)
		end
		if not seen[resource] then seen[resource]=true; table.insert(owned,resource) end
		return resource
	end
	function h:Destroy(): any
		if closed then return cleanup end
		closed = true
		cleanup = {closed=true, destroyed=0, images=0, meshes=0, connections=#connections,
			groupOwned=groupOwned, groupRemoved=false, errors={}}
		for _, connection in ipairs(connections) do connection:Disconnect() end
		table.clear(connections)
		-- Consumers are registered after their mesh/image backing; reverse order
		-- disposes consumers first. Repeated Instance:Destroy is harmless.
		for i=#owned,1,-1 do
			local resource=owned[i]
			local ok,err=pcall(function()
				if resource:IsA("EditableImage") then cleanup.images+=1 end
				if resource:IsA("EditableMesh") then cleanup.meshes+=1 end
				resource:Destroy()
			end)
			if ok then cleanup.destroyed+=1 else table.insert(cleanup.errors,tostring(err)) end
		end
		table.clear(owned); table.clear(seen)
		if groupOwned then
			local ok,err=pcall(function()
				-- Do not unregister if another scene object adopted our group.
				for _,item in ipairs(workspace:GetDescendants()) do
					assert(not (item:IsA("BasePart") and item.CollisionGroup==GROUP), "GROUP_NOW_USED_BY_EXTERNAL_PART")
				end
				P:UnregisterCollisionGroup(GROUP); cleanup.groupRemoved=true
			end)
			if not ok then table.insert(cleanup.errors,tostring(err)) end
		end
		h.model=nil; h.rig=nil; h.part=nil
		return cleanup
	end
	local function alive()
		assert(not closed, "PREVIEW_CLOSED")
		guard()
		if externalAlive then externalAlive() end
		assert(not closed, "PREVIEW_CANCELLED")
	end
	local ok, problem = xpcall(function()
		if type(images)=="table" then
			for _,image in pairs(images) do
				if (typeof(image)=="Object" or typeof(image)=="Instance") and image:IsA("EditableImage") then own(image) end
			end
		end
		alive()
		assert(type(data)=="table" and data.id=="goblin_warrior_sword" and data.units=="stud", "UNREVIEWED_MESH")
		assert(type(data.positions)=="table" and #data.positions==983 and type(data.triangles)=="table" and #data.triangles==1666, "UNREVIEWED_TOPOLOGY")
		local pivot=vec(data.pivot)
		assert(pivot==Vector3.zero, "UNREVIEWED_SOURCE_GRIP")
		assert(type(images)=="table", "MISSING_MAPS")
		for _,name in ipairs(MAPS) do
			assert((typeof(images[name])=="Object" or typeof(images[name])=="Instance") and images[name]:IsA("EditableImage"), "MISSING_MAP:"..name)
		end
		assert(not workspace:FindFirstChild(NAME), "PRIOR_PREVIEW_EXISTS")
		local folder=own(Instance.new("Model")) :: Model
		folder.Name=NAME
		folder:SetAttribute("LOCAL_TEST_ONLY",true)
		folder:SetAttribute("PoseEvidence","SYNTHETIC_EDIT_POSE")
		folder:SetAttribute("FitStatus","UNVALIDATED")
		folder.Parent=workspace; h.model=folder
		table.insert(connections,folder.Destroying:Connect(function() h:Destroy() end))
		local points: {Vector3} = {}
		local low, high=vec(data.positions[1]), vec(data.positions[1])
		for _,position in ipairs(data.positions) do
			local v=vec(position); table.insert(points,v); low=low:Min(v); high=high:Max(v)
		end
		local size=high-low
		assert(size.X>0 and size.Y>0 and size.Z>0 and size.Magnitude<10, "INVALID_SOURCE_BOUNDS")
		local center=(low+high)/2; h.center=center
		local dynamic=own((assert(A:CreateEditableMesh(),"MESH_BUDGET"))) :: EditableMesh
		local ids: {number}={}
		for i,v in ipairs(points) do ids[i]=dynamic:AddVertex(v-center) end
		for i,triangle in ipairs(data.triangles) do
			assert(type(triangle)=="table" and triangle.material==0 and #triangle.vertices==3 and #triangle.uv==3 and #triangle.normals==3,"INVALID_FACE")
			local corners: {number}={}
			local uvIds: {number}={}
			local normalIds: {number}={}
			for j=1,3 do
				local index=triangle.vertices[j]
				assert(finite(index) and index%1==0 and index>=0 and index<#points,"INVALID_VERTEX_INDEX")
				corners[j]=ids[index+1]
				local uv=triangle.uv[j]
				assert(type(uv)=="table" and #uv==2 and finite(uv[1]) and finite(uv[2]) and uv[1]>=0 and uv[1]<=1 and uv[2]>=0 and uv[2]<=1,"INVALID_UV")
				uvIds[j]=dynamic:AddUV(Vector2.new(uv[1],1-uv[2]))
				local normal=vec(triangle.normals[j])
				assert(math.abs(normal.Magnitude-1)<0.00001,"INVALID_CORNER_NORMAL")
				normalIds[j]=dynamic:AddNormal(normal)
			end
			assert(corners[1]~=corners[2] and corners[2]~=corners[3] and corners[1]~=corners[3],"DEGENERATE_INDICES")
			local face=dynamic:AddTriangle(corners[1],corners[2],corners[3])
			dynamic:SetFaceUVs(face,uvIds); dynamic:SetFaceNormals(face,normalIds)
			if i%500==0 then task.wait(); alive() end
		end
		dynamic:RemoveUnused()
		local fixed=own((assert(A:CreateEditableMeshAsync(Content.fromObject(dynamic),{FixedSize=true}),"FIXED_MESH_BUDGET"))) :: EditableMesh
		alive()
		assert(fixed.FixedSize and #fixed:GetVertices()==#points and #fixed:GetFaces()==#data.triangles,"FIXED_TOPOLOGY_MISMATCH")
		assert(fixed:GetCenter().Magnitude<0.0001,"CENTERING_MISMATCH")
		dynamic:Destroy()
		local part=own(A:CreateMeshPartAsync(Content.fromObject(fixed))) :: MeshPart
		alive()
		part.Name="GoblinWarriorSword_SourceScale1"
		part.Size=size; part.CFrame=CFrame.new(center)
		part.Anchored=true; part.Massless=true
		part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
		part.Color=Color3.new(1,1,1); part.Material=Enum.Material.SmoothPlastic
		part:SetAttribute("LOCAL_TEST_ONLY",true); part:SetAttribute("FitStatus","UNVALIDATED")
		local maps: {[string]: any}={}
		for _,name in ipairs(MAPS) do maps[name]=Content.fromObject(images[name]) end
		local surface=own(A:CreateSurfaceAppearanceAsync(maps)) :: SurfaceAppearance
		alive(); surface.Name="ReviewedFourMapSurface"; surface.Parent=part
		part.Parent=folder; h.part=part
		local server=child(game:GetService("ServerScriptService"),"Server")
		local heroModule=child(child(server,"Services"),"HeroRig") :: ModuleScript
		local controllers=child(child(child(game:GetService("StarterPlayer"),"StarterPlayerScripts"),"Client"),"Controllers")
		local actionModule=child(controllers,"ActionPose") :: ModuleScript
		local heroRig: any=(require :: any)(heroModule)
		local actionPose: any=(require :: any)(actionModule)
		alive()
		if not P:IsCollisionGroupRegistered(GROUP) then
			P:RegisterCollisionGroup(GROUP); groupOwned=true
		end
		local rig=own(heroRig.Build("Warrior")) :: Model
		rig.Name="SyntheticWarrior_EditFK"; h.rig=rig
		rig:SetAttribute("PoseEvidence","SYNTHETIC_EDIT_POSE")
		rig:SetAttribute("LOCAL_TEST_ONLY",true)
		local root=assert(rig.PrimaryPart,"MISSING_RIG_ROOT")
		local rootBase=root.CFrame
		local motors: {any}={}
		local details: {any}={}
		local hand: BasePart?=nil
		local rightArm=child(rig,"Right Arm")
		for _,item in ipairs(rig:GetDescendants()) do
			assert(not item:IsA("LuaSourceContainer"),"UNEXPECTED_RIG_SCRIPT")
			if item:IsA("BasePart") then
				item.Anchored=true; item.CanCollide=false; item.CanTouch=false; item.CanQuery=false
			elseif item:IsA("Motor6D") then
				assert(item.Part0 and item.Part1,"INCOMPLETE_MOTOR")
				table.insert(motors,{joint=item,a=item.Part0,b=item.Part1,c0=item.C0,c1=item.C1})
			elseif item:IsA("WeldConstraint") then
				local a,b=item.Part0,item.Part1
				assert(a and b,"INCOMPLETE_DETAIL_WELD")
				table.insert(details,{a=a,b=b,offset=a.CFrame:ToObjectSpace(b.CFrame)})
				if a==rightArm and b.Name=="Hand" then assert(not hand,"DUPLICATE_RIGHT_HAND"); hand=b end
			end
		end
		assert(#motors==6 and hand,"UNEXPECTED_R6_RIG")
		-- Explicit topological FK order; never rely on GetDescendants ordering.
		local ordered: {any}={}
		local reached: {[BasePart]: boolean}={[root]=true}
		for _=1,#motors do
			for _,entry in ipairs(motors) do
				if reached[entry.a] and not reached[entry.b] then
					reached[entry.b]=true; table.insert(ordered,entry)
				end
			end
		end
		assert(#ordered==#motors,"NON_TREE_RIG")
		rig.Parent=folder; alive()
		local rightHand=hand :: BasePart
		local current: any=nil
		function h:Pose(age: number?, gaitPhase: number?, fitName: string?): any
			local poseOK,result=xpcall(function()
				alive()
				assert(folder.Parent==workspace and rig.Parent==folder and part.Parent==folder,"PREVIEW_REMOVED")
				assert(age==nil or (finite(age) and age>=0 and age<=0.62),"ACTION_AGE_OUTSIDE_REVIEW_RANGE")
				assert(gaitPhase==nil or finite(gaitPhase),"INVALID_GAIT_PHASE")
				local fit=fitName or "identity"
				local rotation=assert(FITS[fit],"UNKNOWN_FIT")
				root.CFrame=rootBase
				local swing=if gaitPhase then math.sin(gaitPhase)*0.45 else 0
				for _,entry in ipairs(ordered) do
					assert(entry.joint:IsDescendantOf(rig) and entry.a:IsDescendantOf(rig) and entry.b:IsDescendantOf(rig),"RIG_JOINT_REMOVED")
					local name=entry.joint.Name
					local limb=name:find("Shoulder") or name:find("Hip")
					local sign=if name=="Left Shoulder" or name=="Right Hip" then 1 else -1
					local base=if limb then CFrame.Angles(swing*sign*(if name=="Right Shoulder" then 0.3 else 1),0,0) else CFrame.identity
					local action=if age then actionPose("Warrior","Slash",age,name) else nil
					entry.b.CFrame=entry.a.CFrame*entry.c0*base*(action or CFrame.identity)*entry.c1:Inverse()
				end
				for _,entry in ipairs(details) do
					assert(entry.a:IsDescendantOf(rig) and entry.b:IsDescendantOf(rig),"RIG_DETAIL_REMOVED")
					entry.b.CFrame=entry.a.CFrame*entry.offset
				end
				part.CFrame=rightHand.CFrame*rotation*CFrame.new(center-pivot)
				local grip=part.CFrame:PointToWorldSpace(pivot-center)
				local inHand=rightHand.CFrame:PointToObjectSpace(grip)
				local half=rightHand.Size/2
				local nearest=Vector3.new(math.clamp(inHand.X,-half.X,half.X),math.clamp(inHand.Y,-half.Y,half.Y),math.clamp(inHand.Z,-half.Z,half.Z))
				local worldLow=Vector3.new(math.huge,math.huge,math.huge)
				local worldHigh=-worldLow
				for _,point in ipairs(points) do
					local world=part.CFrame:PointToWorldSpace(point-center)
					worldLow=worldLow:Min(world); worldHigh=worldHigh:Max(world)
				end
				current={scope="SYNTHETIC_EDIT_POSE",fitStatus="UNVALIDATED",fit=fit,age=age,gaitPhase=gaitPhase,
					sourceScale=1,vertices=#points,triangles=#data.triangles,motors=#ordered,detailWelds=#details,
					swordCenter=xyz(part.Position),gripOrigin=xyz(grip),handOrigin=xyz(rightHand.Position),
					gripToHandCenterGap=(grip-rightHand.Position).Magnitude,
					gripToHandSolidGap=(inHand-nearest).Magnitude,
					gripDistanceMeaning="POINT_TO_SOLID_OBB_NOT_SURFACE_CONTACT",
					lowestVertexY=worldLow.Y,worldVertexBounds={min=xyz(worldLow),max=xyz(worldHigh)},
					sourceBounds={min=xyz(low),max=xyz(high),size=xyz(size),center=xyz(center),pivot=xyz(pivot)},
					uvConvention="CORNER_U_1_MINUS_V",actionSource="ActionPose:Warrior:Slash",gaitSource="HeroAnimator_EQUIPPED_WALK_FORMULA"}
				table.insert(h.samples,current)
				if #h.samples>128 then table.remove(h.samples,1) end
				return current
			end,debug.traceback)
			if not poseOK then h:Destroy(); error(tostring(result),0) end
			return result
		end
		function h:Get(): any
			alive(); assert(current,"NO_POSE"); return current
		end
		h:Pose(nil,nil,"identity")
	end,debug.traceback)
	if not ok then
		M.LastFailureCleanup=h:Destroy()
		error(tostring(problem),0)
	end
	return h
end
return M
