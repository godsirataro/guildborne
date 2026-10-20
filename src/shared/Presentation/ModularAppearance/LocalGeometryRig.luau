--!strict
-- Source-positioned articulated preview, isolated from player/hero gameplay rigs.
local RunService=game:GetService("RunService")
local RigData=require(script.Parent.GeneratedRig)
local Geometry=require(script.Parent.GeneratedGeometry)
local Rig={}
local names={"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
local motorNames={LowerTorso="Root",UpperTorso="Waist",Head="Neck",LeftUpperArm="LeftShoulder",LeftLowerArm="LeftElbow",LeftHand="LeftWrist",RightUpperArm="RightShoulder",RightLowerArm="RightElbow",RightHand="RightWrist",LeftUpperLeg="LeftHip",LeftLowerLeg="LeftKnee",LeftFoot="LeftAnkle",RightUpperLeg="RightHip",RightLowerLeg="RightKnee",RightFoot="RightAnkle"}

local function frame(values: {number}): CFrame
	return CFrame.new(values[1],values[2],values[3],values[4],values[5],values[6],values[7],values[8],values[9],values[10],values[11],values[12])
end

local function attachment(parent: BasePart,name: string,worldFrame: CFrame,sourceBone: string): Attachment
	local existing=parent:FindFirstChild(name);assert(not existing,"DUPLICATE_SOURCE_ATTACHMENT:"..name)
	local result=Instance.new("Attachment");result.Name=name;result.CFrame=parent.CFrame:ToObjectSpace(worldFrame)
	result:SetAttribute("SourceDerived",true);result:SetAttribute("SourceBone",sourceBone);result.Parent=parent
	return result
end

local function rigidAccessory(model: Model,part: MeshPart,attachmentName: string)
	local assetId=part:GetAttribute("AssetId") :: string
	local source=RigData.Assets[assetId];assert(source,"SOURCE_ACCESSORY_RIG_MISSING")
	local sourceAttachment=nil
	for _,item in ipairs(source.attachments) do if item.name==attachmentName then sourceAttachment=item;break end end
	assert(sourceAttachment,"SOURCE_ACCESSORY_ATTACHMENT_MISSING")
	local head=model:FindFirstChild("Head") :: MeshPart
	local target=head:FindFirstChild(attachmentName) :: Attachment;assert(target and target:IsA("Attachment"),"BODY_ACCESSORY_ATTACHMENT_MISSING")
	local accessory=Instance.new("Accessory");accessory.Name=assetId;accessory:SetAttribute("AssetId",assetId)
	accessory:SetAttribute("AssetStatus","LOCAL_EDITABLE_MESH_PREVIEW_ONLY");accessory:SetAttribute("FitStatus","SOURCE_STANDARD_CANDIDATE_UNTESTED")
	accessory.AccessoryType=if attachmentName=="HairAttachment" then Enum.AccessoryType.Hair else Enum.AccessoryType.Hat
	accessory.Parent=model
	part:SetAttribute("SourceMeshName",part.Name);part.Name="Handle";part.Anchored=false;part.Parent=accessory
	local localAttachment=attachment(part,attachmentName,frame(sourceAttachment.bindFrame),"Head")
	local weld=Instance.new("Weld");weld.Name="AccessoryWeld";weld.Part0=head;weld.Part1=part
	weld.C0=target.CFrame;weld.C1=localAttachment.CFrame;weld.Parent=part
	part:SetAttribute("RigStatus","SOURCE_RIGID_ATTACHMENT_PREVIEW_UNTESTED")
end

function Rig.Assemble(model: Model,bodyAssetId: string)
	assert(RunService:IsStudio() and game.PlaceId==0 and game.GameId==0,"LOCAL_UNPUBLISHED_STUDIO_ONLY")
	assert(model:GetAttribute("AssetStatus")=="LOCAL_EDITABLE_MESH_PREVIEW_ONLY" and model.Parent==nil,"ISOLATED_PREVIEW_MODEL_REQUIRED")
	local source=RigData.Assets[bodyAssetId];assert(source and bodyAssetId:sub(1,8)=="CHR_BDY_","SOURCE_BODY_RIG_MISSING")
	assert(source.sourceSha256==Geometry.Assets[bodyAssetId].sourceSha256,"SOURCE_GEOMETRY_RIG_HASH_MISMATCH")
	local parts: {[string]: BasePart}={}
	for _,name in ipairs(names) do
		local part=model:FindFirstChild(name);assert(part and part:IsA("MeshPart") and part:GetAttribute("CoreBodyPart")==true,"BODY_MESHPART_REQUIRED:"..name)
		parts[name]=part :: MeshPart
	end
	local rootBone=nil
	for _,bone in ipairs(source.bones) do if bone.name=="HumanoidRootPart" then rootBone=bone;break end end
	assert(rootBone,"SOURCE_ROOT_BONE_MISSING")
	local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Size=Vector3.new(1,1,1)
	root.CFrame=CFrame.new(rootBone.head[1],rootBone.head[2],rootBone.head[3]);root.Transparency=1
	root.Anchored=true;root.Massless=true;root.CanCollide=false;root.CanTouch=false;root.CanQuery=false
	root:SetAttribute("SourceDerived",true);root:SetAttribute("SourceSha256",source.sourceSha256);root:SetAttribute("CoreBodyPart",false)
	root.Parent=model;parts.HumanoidRootPart=root;model.PrimaryPart=root
	local count=0
	for _,bone in ipairs(source.bones) do
		if bone.name=="HumanoidRootPart" then continue end
		local part0=parts[bone.parent];local part1=parts[bone.name];assert(part0 and part1,"SOURCE_BONE_PART_MISSING")
		local pivot=frame(bone.bindFrame);local motorName=motorNames[bone.name]
		local joint=Instance.new("Motor6D");joint.Name=motorName;joint.Part0=part0;joint.Part1=part1
		joint.C0=part0.CFrame:ToObjectSpace(pivot);joint.C1=part1.CFrame:ToObjectSpace(pivot);joint.Transform=CFrame.identity
		joint:SetAttribute("SourceDerived",true);joint:SetAttribute("SourceBone",bone.name);joint:SetAttribute("SourceSha256",source.sourceSha256)
		joint.Parent=part1
		attachment(part0,motorName.."RigAttachment",pivot,bone.name);attachment(part1,motorName.."RigAttachment",pivot,bone.name)
		part1.Anchored=false;part1.Massless=true;part1.CanCollide=false;part1.CanTouch=false;part1.CanQuery=false
		part1:SetAttribute("RigStatus","SOURCE_MOTOR6D_ARTICULATED_PREVIEW_UNTESTED");count+=1
	end
	assert(count==15,"SOURCE_15_JOINTS_REQUIRED")
	for _,item in ipairs(source.attachments) do
		local target=parts[item.target];assert(target,"SOURCE_ATTACHMENT_TARGET_MISSING")
		attachment(target,item.name,frame(item.bindFrame),item.target)
	end
	-- Exact per-bone source shells remain an explicit local fallback, never layered-ready.
	local rigidParts={}
	local garmentCount=0
	for _,item in ipairs(model:GetDescendants()) do
		if not item:IsA("MeshPart") or item:GetAttribute("CoreBodyPart")==true then continue end
		local id=item:GetAttribute("AssetId")
		if id=="CLO_TUNIC_TRAVELER_01" or id=="CLO_TROUSERS_TRAVELER_01" then
			assert(bodyAssetId=="CHR_BDY_HUMAN_STANDARD_V01" and item:GetAttribute("AuthoredPreset")=="HUMAN_STANDARD","ARTICULATED_GARMENT_PRESET_UNSUPPORTED")
			assert(item:GetAttribute("GarmentRigStatus")=="LOCAL_RIGID_BOUND_CANDIDATE","GARMENT_PARTITION_REQUIRED")
			assert(item:GetAttribute("SourceSha256")==RigData.Assets[id].sourceSha256
				and item:GetAttribute("SourceSha256")==Geometry.Assets[id].sourceSha256,"GARMENT_SOURCE_HASH_MISMATCH")
			local bone=item:GetAttribute("SourceBindBone")
			assert(type(bone)=="string" and parts[bone] and bone~="HumanoidRootPart","GARMENT_BIND_BONE_MISSING")
			local joint=Instance.new("Weld");joint.Name="SourceGarmentWeld";joint.Part0=parts[bone];joint.Part1=item
			joint.C0=parts[bone].CFrame:ToObjectSpace(item.CFrame);joint.C1=CFrame.identity;joint.Parent=item
			item.Anchored=false;item.Massless=true;item.CanCollide=false;item.CanTouch=false;item.CanQuery=false
			item:SetAttribute("RigStatus","LOCAL_RIGID_BOUND_CANDIDATE")
			item:SetAttribute("FitStatus","SOURCE_STANDARD_CANDIDATE_UNTESTED")
			garmentCount+=1
			continue
		end
		assert(id=="ACC_HAIR_HUMAN_01" or id=="CLO_HAT_WIZARD_01","UNSKINNED_FLEXIBLE_GARMENT_IN_ARTICULATED_RIG")
		table.insert(rigidParts,item)
	end
	for _,part in ipairs(rigidParts) do rigidAccessory(model,part,if part:GetAttribute("AssetId")=="ACC_HAIR_HUMAN_01" then "HairAttachment" else "HatAttachment") end
	local controller=Instance.new("AnimationController");controller.Name="LocalPreviewAnimationController";controller.Parent=model
	local animator=Instance.new("Animator");animator.Parent=controller
	model.Name=model.Name:gsub("_LocalMeshPreview$","_LocalRigPreview")
	model:SetAttribute("RigStatus","SOURCE_MOTOR6D_ARTICULATED_PREVIEW_UNTESTED")
	model:SetAttribute("JointCount",count);model:SetAttribute("SourceBoneCount",#source.bones);model:SetAttribute("SourceAttachmentCount",#source.attachments)
	model:SetAttribute("RigSourceSha256",source.sourceSha256);model:SetAttribute("AnimationStatus","PLAYBACK_UNTESTED_NO_PUBLISHED_ANIMATION_IDS")
	model:SetAttribute("GarmentRigStatus",if garmentCount>0 then "LOCAL_RIGID_BOUND_CANDIDATE" else "NO_GARMENTS")
	model:SetAttribute("GarmentSegmentCount",garmentCount)
end

return Rig
