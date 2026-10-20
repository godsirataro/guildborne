--!strict
-- Execute the returned function on the Client in an unpublished Studio session,
-- passing require(ReplicatedStorage.Shared.Presentation.ModularAppearance.LocalLegacyCosmetics).
-- Synthetic local Instances exercise visibility/lifecycle policy, not gameplay or art acceptance.
return function(Cosmetics: any): any
	local run = game:GetService("RunService")
	assert(run:IsStudio() and run:IsClient() and game.PlaceId == 0 and game.GameId == 0)
	local holder = Instance.new("Folder"); holder.Name = "LocalCosmeticPolicyCheck"; holder.Parent = workspace
	local actor = Instance.new("Model"); actor.Name = "SyntheticCosmeticActor"; actor.Parent = holder
	actor:SetAttribute("GuildborneHero",true); actor:SetAttribute("VisualTemplateId","warrior_01"); actor:SetAttribute("ClassId","Warrior")
	local states: {any} = {}
	local cases: {string} = {}
	local function check(label: string, condition: boolean)
		assert(condition,label); table.insert(cases,label)
	end
	local function part(parent: Instance, name: string): Part
		local p = Instance.new("Part"); p.Name = name; p.Anchored = true
		p.CanCollide = false; p.CanTouch = false; p.CanQuery = false; p.Massless = true
		p.Transparency = .3; p.LocalTransparencyModifier = .2; p.Parent = parent; return p
	end
	local function welded(parent: Instance, name: string, anchor: BasePart): (Part,WeldConstraint)
		local p = part(parent,name); local w = Instance.new("WeldConstraint")
		w.Part0 = anchor; w.Part1 = p; w.Parent = p; return p,w
	end
	local ok, result = pcall(function()
		local head = part(actor,"Head"); local torso = part(actor,"Torso")
		local originalLTM, originalTransparency = head.LocalTransparencyModifier, head.Transparency
		local eye, eyeWeld = welded(actor,"Eye",head)
		local helmet = welded(actor,"Helmet",head)
		local unknown = welded(actor,"FutureCostume",torso)
		local itemTagged = welded(actor,"Hair",head); itemTagged:SetAttribute("ItemId","future_hat")
		local kit = Instance.new("Model"); kit.Name = "HeroAppearance"; kit.Parent = actor
		kit:SetAttribute("DesignId","ui.heroes.warrior_01"); kit:SetAttribute("ClassId","Warrior"); kit:SetAttribute("RecruitmentBound",false)
		local kitHair = welded(kit,"Hair",head); kitHair:SetAttribute("BindBone","Head")
		local shield = welded(kit,"Shield",head); shield:SetAttribute("BindBone","Head")
		local shieldMark = welded(kit,"ShieldMark",head); shieldMark:SetAttribute("BindBone","Head")
		local futureKit = welded(kit,"FutureHair",head); futureKit:SetAttribute("BindBone","Head")
		local protectedParts: {BasePart} = {shield,shieldMark,futureKit,unknown,itemTagged}
		local equipped: Model? = nil
		for _, name in ipairs({"EquippedWeapon","EquippedArmor","EquippedAccessory","CityRoleVisual"}) do
			local folder = Instance.new("Model"); folder.Name = name; folder.Parent = actor
			local p = welded(folder,"Head",head); table.insert(protectedParts,p)
			if name == "EquippedAccessory" then equipped = folder end
		end
		local tool = Instance.new("Tool"); tool.Name = "LocalUnknownTool"; tool.Parent = actor
		table.insert(protectedParts,part(tool,"Head"))
		local hair = Instance.new("Accessory"); hair.Name = "Pal Hair"; hair.AccessoryType = Enum.AccessoryType.Hair; hair.Parent = actor
		local handle = part(hair,"Handle")
		local hairAttachment = Instance.new("Attachment"); hairAttachment.Name = "HairAttachment"; hairAttachment.Parent = handle
		local accessoryWeld = Instance.new("Weld"); accessoryWeld.Name = "AccessoryWeld"
		accessoryWeld.Part0 = head; accessoryWeld.Part1 = handle; accessoryWeld.Parent = handle
		local face = Instance.new("Decal"); face.Name = "face"; face.Transparency = .35; face.Parent = head
		local faceOriginal = face.Transparency
		local unknownDecal = Instance.new("Decal"); unknownDecal.Name = "OtherMark"; unknownDecal.Transparency = .4; unknownDecal.Parent = head
		local unknownOriginal = unknownDecal.Transparency
		local unknownTexture = Instance.new("Texture"); unknownTexture.Name = "face"; unknownTexture.Transparency = .45; unknownTexture.Parent = head
		local textureOriginal = unknownTexture.Transparency
		local state, err = Cosmetics.New(actor); assert(state,err); table.insert(states,state)
		local function sync() local success, problem = state:Sync(); assert(success,problem) end
		sync()
		check("direct_body_hidden_without_transparency_change",head.LocalTransparencyModifier == 1 and head.Transparency == originalTransparency)
		check("source_welded_details_hidden",eye.LocalTransparencyModifier == 1 and helmet.LocalTransparencyModifier == 1)
		check("source_kit_hair_hidden",kitHair.LocalTransparencyModifier == 1)
		check("typed_avatar_hair_hidden",handle.LocalTransparencyModifier == 1)
		accessoryWeld.Part0 = handle; accessoryWeld.Part1 = head; sync()
		check("reversed_avatar_weld_hidden",handle.LocalTransparencyModifier == 1)
		-- Remove the old weld so it cannot mask invalid rigid-constraint coverage.
		accessoryWeld:Destroy(); sync()
		check("unbound_avatar_hair_restores",handle.LocalTransparencyModifier == originalLTM)
		local headAttachment = Instance.new("Attachment"); headAttachment.Name = "HairAttachment"; headAttachment.Parent = head
		local wrongTarget = Instance.new("Attachment"); wrongTarget.Name = "HairAttachment"; wrongTarget.Parent = torso
		local rigid = Instance.new("RigidConstraint"); rigid.Name = "AccessoryRigidConstraint"; rigid.Enabled = true
		rigid.Attachment0 = hairAttachment; rigid.Attachment1 = headAttachment; rigid.Parent = handle; sync()
		check("exact_avatar_rigid_constraint_hidden",handle.LocalTransparencyModifier == 1)
		rigid.Attachment0 = headAttachment; rigid.Attachment1 = hairAttachment; sync()
		check("reversed_avatar_rigid_constraint_hidden",handle.LocalTransparencyModifier == 1)
		rigid.Enabled = false; sync(); check("disabled_rigid_constraint_restores",handle.LocalTransparencyModifier == originalLTM)
		rigid.Enabled = true; sync(); check("reenabled_rigid_constraint_rehides",handle.LocalTransparencyModifier == 1)
		rigid.Attachment0 = wrongTarget; sync(); check("wrong_rigid_body_target_restores",handle.LocalTransparencyModifier == originalLTM)
		rigid.Attachment0 = headAttachment; headAttachment.Name = "HatAttachment"; sync()
		check("wrong_rigid_attachment_name_restores",handle.LocalTransparencyModifier == originalLTM)
		headAttachment.Name = "HairAttachment"; rigid.Name = "UnknownConstraint"; sync()
		check("unknown_rigid_constraint_name_restores",handle.LocalTransparencyModifier == originalLTM)
		rigid.Name = "AccessoryRigidConstraint"; sync(); check("valid_rigid_binding_return_rehides",handle.LocalTransparencyModifier == 1)
		check("face_decal_only",face.Transparency == 1 and unknownDecal.Transparency == unknownOriginal)
		check("unknown_texture_not_hidden",unknownTexture.Transparency == textureOriginal)
		for index, p in ipairs(protectedParts) do check("protected_or_unknown_"..index,p.LocalTransparencyModifier == originalLTM and p.Transparency == originalTransparency) end
		hair.AccessoryType = Enum.AccessoryType.Unknown; sync()
		check("accessory_type_change_restores",handle.LocalTransparencyModifier == originalLTM)
		hair.AccessoryType = Enum.AccessoryType.Hair; sync(); check("accessory_type_return_rehides",handle.LocalTransparencyModifier == 1)
		hair.Name = "ShieldHair"; sync(); check("shield_name_restores",handle.LocalTransparencyModifier == originalLTM)
		hair.Name = "Pal Hair"; sync(); hair.Parent = equipped; sync()
		check("reparent_into_equipment_restores",handle.LocalTransparencyModifier == originalLTM)
		hair.Parent = actor; sync(); check("reparent_back_rehides",handle.LocalTransparencyModifier == 1)
		face.Parent = protectedParts[6]; sync(); check("decal_reparent_restores",face.Transparency == faceOriginal)
		face.Parent = head; sync(); face.Name = "OtherFace"; sync(); check("decal_rename_restores",face.Transparency == faceOriginal)
		face.Name = "face"; sync()
		eyeWeld.Part0 = torso; sync(); check("weld_target_change_restores",eye.LocalTransparencyModifier == originalLTM)
		eyeWeld.Part0 = head; sync(); check("weld_target_return_rehides",eye.LocalTransparencyModifier == 1)
		kit:SetAttribute("DesignId","future_source"); sync(); check("kit_signature_change_restores",kitHair.LocalTransparencyModifier == originalLTM)
		kit:SetAttribute("DesignId","ui.heroes.warrior_01"); sync(); check("kit_signature_return_rehides",kitHair.LocalTransparencyModifier == 1)
		kitHair:SetAttribute("BindBone","UpperTorso"); sync(); check("source_bone_change_restores",kitHair.LocalTransparencyModifier == originalLTM)
		kitHair:SetAttribute("BindBone","Head"); sync()
		local late = welded(actor,"Eye",head); late.LocalTransparencyModifier = .6; local lateOriginal = late.LocalTransparencyModifier
		sync(); check("late_descendant_hidden",late.LocalTransparencyModifier == 1)
		late.Parent = holder; sync(); check("removed_descendant_restored",late.LocalTransparencyModifier == lateOriginal)
		late.Parent = actor; sync(); late:Destroy(); sync(); check("destroyed_descendant_released",state:GetDiagnostics().restoreFailures == 0)
		local overlay = Instance.new("Model"); overlay.Name = "GuildborneModularAppearance"; overlay.Parent = actor
		overlay:SetAttribute("AssetStatus","PLACEHOLDER"); overlay:SetAttribute("GeometryKind","15_PARTS_NOT_IMPORTED_MESHPARTS")
		local oldHead = part(overlay,"Head"); oldHead:SetAttribute("AssetStatus","PLACEHOLDER"); oldHead:SetAttribute("CoreBodyPart",true)
		local overlayUnknown = part(overlay,"UnknownPart"); overlayUnknown:SetAttribute("AssetStatus","PLACEHOLDER")
		sync(); check("identified_placeholder_hidden",oldHead.LocalTransparencyModifier == 1)
		check("unknown_placeholder_left_visible",overlayUnknown.LocalTransparencyModifier == originalLTM)
		state:Destroy(); state:Destroy()
		check("exact_body_and_face_restore",head.LocalTransparencyModifier == originalLTM and face.Transparency == faceOriginal)
		check("exact_cosmetic_restore",eye.LocalTransparencyModifier == originalLTM and kitHair.LocalTransparencyModifier == originalLTM and handle.LocalTransparencyModifier == originalLTM)
		check("idempotent_cleanup_zero_state",state:GetDiagnostics().hidden == 0 and state:GetDiagnostics().restoreFailures == 0 and state:GetDiagnostics().connections == 0)
		local stopped = state:Sync(); check("destroyed_state_refuses_sync",stopped == false)
		local second, secondError = Cosmetics.New(actor); assert(second,secondError); table.insert(states,second)
		assert(second:Sync()); actor.Parent = nil
		local alive = second:Sync()
		check("actor_removal_restores_and_stops",alive == false and second:GetDiagnostics().destroyed and head.LocalTransparencyModifier == originalLTM)
		actor.Parent = holder
		return {passed=#cases,cases=cases,syntheticLocalInstances=true,actualGameActorAcceptance=false,artAcceptance=false,diagnostics=state:GetDiagnostics()}
	end)
	for _, state in ipairs(states) do state:Destroy() end
	actor:Destroy(); holder:Destroy()
	assert(ok,result)
	return result
end
