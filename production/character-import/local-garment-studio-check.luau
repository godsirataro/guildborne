--!strict
-- Coordinator-run client probe only in an owned unpublished Studio 0/0 place.
-- No actors, profiles, physics proxies or imported asset registrations are changed.
return function()
	local Preview=require(game.ReplicatedStorage.Shared.Presentation.ModularAppearance.LocalGeometryPreview)
	assert(Preview.IsAvailable(),"LOCAL_UNPUBLISHED_STUDIO_ONLY")
	local selection={
		raceId="HUMAN",bodyPresetId="HUMAN_STANDARD",skinPaletteId="SKIN_HUMAN_03",
		hairAssetId="ACC_HAIR_HUMAN_01",hairColorId="HAIR_DARK_BROWN",
		outfitSlots={INNER_TOP="CLO_TUNIC_TRAVELER_01",INNER_BOTTOM="CLO_TROUSERS_TRAVELER_01"},
	}
	local baseline=Preview.ResourceCount()
	local backingBaseline=Preview.BackingResourceCount()
	local model: Model?=nil
	local second: Model?=nil
	local ok,result=pcall(function()
		local err
		model,err=Preview.BuildRig(selection);assert(model,err)
		local candidate=model :: Model
		assert(candidate:GetAttribute("GarmentSegmentCount")==9)
		assert(candidate:GetAttribute("GarmentRigStatus")=="LOCAL_RIGID_BOUND_CANDIDATE")
		assert(candidate:GetAttribute("OmittedUnskinnedGarments")=="")
		local core,motors,garments,triangles=0,0,0,0
		for _,item in ipairs(candidate:GetDescendants()) do
			if item:IsA("Motor6D") then motors+=1 end
			if item:IsA("MeshPart") and item:GetAttribute("CoreBodyPart")==true then core+=1 end
			if item:IsA("MeshPart") and item:GetAttribute("GarmentRigStatus")=="LOCAL_RIGID_BOUND_CANDIDATE" then
				garments+=1;triangles+=(item:GetAttribute("SourceTriangleCount") :: number)
				local weld=item:FindFirstChild("SourceGarmentWeld") :: Weld
				assert(weld and weld.Part1==item and weld.Part0==candidate:FindFirstChild(item:GetAttribute("SourceBindBone") :: string))
				assert(not item.Anchored and item.Massless and not item.CanCollide and not item.CanTouch and not item.CanQuery)
			end
		end
		assert(core==15 and motors==15 and garments==9 and triangles==556)
		assert(Preview.ResourceCount(candidate)==25) -- 15 body + hair + nine garment partitions.
		local firstBacking=Preview.BackingResourceCount()
		second,err=Preview.BuildRig(selection);assert(second,err)
		local paired=second :: Model
		assert(Preview.ResourceCount(paired)==25 and Preview.ResourceCount()==baseline+50)
		assert(Preview.BackingResourceCount()==firstBacking and Preview.PendingBackingCount()==0)
		if baseline==0 then assert(firstBacking==25) end
		local head=candidate:FindFirstChild("Head") :: MeshPart
		local otherHead=paired:FindFirstChild("Head") :: MeshPart
		assert(head~=otherHead)
		local otherPosition=otherHead.CFrame
		local otherColor=otherHead.Color
		head.CFrame*=CFrame.new(1,0,0);head.Color=Color3.new(1,0,0)
		assert(otherHead.CFrame==otherPosition and otherHead.Color==otherColor)
		Preview.Destroy(candidate);model=nil
		assert(Preview.ResourceCount()==baseline+25 and Preview.BackingResourceCount()==firstBacking)
		assert(paired:FindFirstChild("Head")==otherHead)
		paired:Destroy();second=nil
		assert(Preview.ResourceCount()==baseline)
		assert(Preview.BackingResourceCount()==backingBaseline and Preview.PendingBackingCount()==0)
		selection.bodyPresetId="HUMAN_HEAVY"
		local rejected,reason=Preview.BuildRig(selection)
		if rejected then Preview.Destroy(rejected);error("HEAVY_GARMENT_MUST_REJECT") end
		assert(reason and reason:find("ARTICULATED_GARMENT_PRESET_UNSUPPORTED",1,true))
		assert(Preview.ResourceCount()==baseline)
		selection.bodyPresetId="HUMAN_STANDARD"
		model,err=Preview.BuildRig(selection);assert(model,err)
		local direct=model :: Model
		direct:Destroy();model=nil -- Direct destruction also releases retained meshes.
		assert(Preview.ResourceCount()==baseline)
		return {coreMeshes=core,motors=motors,garmentSegments=garments,garmentTriangles=triangles,
			explicitAndDirectCleanup=true,heavyFitRejected=true,profileWrites=0,pairedLogicalReferences=50,
			pairedUniqueBackings=firstBacking,independentMeshParts=true,
			claims="LOCAL_SOURCE_RIGID_BOUND_ASSEMBLY_ONLY_NOT_FIT_OR_MOTION_ACCEPTANCE"}
	end)
	if model then Preview.Destroy(model) end
	if second then Preview.Destroy(second) end
	assert(Preview.ResourceCount()==baseline,"LOCAL_PREVIEW_RESOURCE_LEAK")
	assert(Preview.BackingResourceCount()==backingBaseline and Preview.PendingBackingCount()==0,"LOCAL_BACKING_RESOURCE_LEAK")
	if not ok then error(result) end
	return result
end
