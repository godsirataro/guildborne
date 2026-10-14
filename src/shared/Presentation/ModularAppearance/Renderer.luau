--!strict
-- Private vertical-slice renderer. Generated Parts are explicitly PLACEHOLDER, never imported MeshParts.
local Catalog = require(script.Parent.Parent.Parent.Data.AppearanceCatalog)
local Skeleton = require(script.Parent.Skeleton)
local Renderer = {}
local V = Vector3.new
local C = Color3.fromRGB
local OVERLAY = "GuildborneModularAppearance"
local SAVED = "ModularPreviousTransparency"
local cloth = C(203,185,153)
local modesty = C(76,66,58)
local hairColors: {[string]: Color3} = {}
for id,hex in pairs(Catalog.HairColors) do hairColors[id]=Color3.fromHex(hex) end
local implementedSlots = {INNER_TOP="CLO_TUNIC_TRAVELER_01",INNER_BOTTOM="CLO_TROUSERS_TRAVELER_01",OUTER_TOP="CLO_ROBE_WIZARD_01",HEADWEAR="CLO_HAT_WIZARD_01"}

local function validate(s: any): (boolean,string?)
	if type(s)~="table" or s.raceId~="HUMAN" then return false,"BODY_UNAVAILABLE" end
	if s.bodyPresetId~="HUMAN_STANDARD" and s.bodyPresetId~="HUMAN_HEAVY" then return false,"BODY_UNAVAILABLE" end
	local palette=Catalog.SkinPalettes[s.skinPaletteId]
	if not palette or palette.raceId~="HUMAN" then return false,"INVALID_SKIN" end
	if s.headPresetId~="CHR_HEAD_HUMAN_01" then return false,"HEAD_UNAVAILABLE" end
	if s.hairAssetId and s.hairAssetId~="ACC_HAIR_HUMAN_01" then return false,"HAIR_UNAVAILABLE" end
	if s.beardAssetId then return false,"BEARD_UNAVAILABLE" end
	if s.raceFeatures and next(s.raceFeatures) then return false,"FEATURE_UNAVAILABLE" end
	if s.hairColorId and not hairColors[s.hairColorId] then return false,"INVALID_HAIR_COLOR" end
	if s.outfitSlots~=nil and type(s.outfitSlots)~="table" then return false,"INVALID_OUTFIT" end
	for slot,id in pairs(s.outfitSlots or {}) do if implementedSlots[slot]~=id then return false,"OUTFIT_UNAVAILABLE" end end
	return true,nil
end
Renderer.Validate = validate

local function part(parent: Instance,name: string,size: Vector3,cf: CFrame,color: Color3): Part
	local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
	p.Material=Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
	p.Anchored=false;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true
	p:SetAttribute("AssetStatus","PLACEHOLDER");p.Parent=parent;return p
end
local function weld(a: BasePart,b: BasePart)
	local w=Instance.new("WeldConstraint");w.Name="AppearanceWeld";w.Part0=a;w.Part1=b;w.Parent=b
end
local function garment(parent: Instance,body: BasePart,name: string,size: Vector3,offset: CFrame,color: Color3,assetId: string,layer: number)
	local p=part(parent,name,size,body.CFrame*offset,color);p:SetAttribute("AssetId",assetId);p:SetAttribute("LayerOrder",layer)
	p:SetAttribute("FitStatus","PRESET_SPECIFIC_PLACEHOLDER_UNTESTED");p:SetAttribute("ClothingTechnology","RIGID_FALLBACK_PLACEHOLDER")
	weld(body,p);return p
end

function Renderer.Build(selection: any): Model
	local ok,err=validate(selection);assert(ok,err)
	local palette=Catalog.SkinPalettes[selection.skinPaletteId]
	local skin=Color3.fromHex(palette.colorHex)
	local heavy=selection.bodyPresetId=="HUMAN_HEAVY"
	local width=if heavy then 1.17 else 1
	local depth=if heavy then 1.2 else 1
	local m=Instance.new("Model");m.Name=OVERLAY;m:SetAttribute("AssetStatus","PLACEHOLDER")
	m:SetAttribute("BodyPresetId",selection.bodyPresetId);m:SetAttribute("SkinPaletteId",selection.skinPaletteId)
	m:SetAttribute("BodyAssetId",Catalog.Bodies[selection.bodyPresetId].assetId)
	m:SetAttribute("ClothingFit","PRESET_SPECIFIC_PLACEHOLDER_UNTESTED");m:SetAttribute("AnimationStatus","UNVALIDATED")
	m:SetAttribute("GeometryKind","15_PARTS_NOT_IMPORTED_MESHPARTS")
	local root=part(m,"HumanoidRootPart",V(1,1,1),CFrame.identity,modesty);root.Transparency=1;m.PrimaryPart=root
	for _,name in ipairs(Skeleton.Names) do
		local spec=Skeleton.Parts[name];local size=spec[1];local position=spec[2]
		if name~="Head" then size=V(size.X*width,size.Y,size.Z*depth);position=V(position.X*width,position.Y,position.Z) end
		-- Safety colors are part of the base body. Removing an outfit can never expose these surfaces.
		local covered=name=="UpperTorso" or name=="LowerTorso" or name:find("UpperLeg")~=nil
		local p=part(m,name,size,CFrame.new(position),if covered then modesty else skin)
		p:SetAttribute("CoreBodyPart",true);p:SetAttribute("SkinTintable",not covered)
		for _,attachmentName in ipairs(Skeleton.Attachments[name] or {}) do
			local a=Instance.new("Attachment");a.Name=attachmentName
			if attachmentName=="HairAttachment" or attachmentName=="HatAttachment" then a.Position=V(0,size.Y/2,0)
			elseif attachmentName=="FaceFrontAttachment" then a.Position=V(0,0,-size.Z/2)
			elseif attachmentName:find("Grip") then a.Position=V(0,-size.Y/2,0) end
			a.Parent=p
		end
	end
	for _,spec in ipairs(Skeleton.Joints) do
		local a=m:FindFirstChild(spec.a) :: BasePart;local b=m:FindFirstChild(spec.b) :: BasePart
		local pos=spec.pivot;local pivot=CFrame.new(V(pos.X*width,pos.Y,pos.Z))
		local joint=Instance.new("Motor6D");joint.Name=spec.name;joint.Part0=a;joint.Part1=b
		joint.C0=a.CFrame:ToObjectSpace(pivot);joint.C1=b.CFrame:ToObjectSpace(pivot);joint.Parent=a
	end
	local covering=Instance.new("Model");covering.Name="AlwaysOnModesty";covering.Parent=m
	for _,name in ipairs({"UpperTorso","LowerTorso","LeftUpperLeg","RightUpperLeg"}) do
		local b=m:FindFirstChild(name) :: BasePart
		local p=garment(covering,b,"Modesty"..name,b.Size+V(.012,.012,.012),CFrame.identity,modesty,"ALWAYS_ON_MODESTY",0)
		p:SetAttribute("AlwaysOnModesty",true)
	end
	local eyes=Instance.new("Model");eyes.Name="FaceDetails";eyes.Parent=m
	local head=m:FindFirstChild("Head") :: BasePart
	for _,side in ipairs({-1,1}) do
		local eye=part(eyes,"Eye",V(.105,.12,.04),head.CFrame*CFrame.new(side*.235,.035,-head.Size.Z/2-.021),C(28,25,23));weld(head,eye)
	end
	local garments=Instance.new("Model");garments.Name="OutfitSlots";garments.Parent=m
	local slots=selection.outfitSlots or {}
	local function wrapBody(name: string,id: string,color: Color3,layer: number,grow: number)
		local b=m:FindFirstChild(name) :: BasePart
		garment(garments,b,id.."_"..name,b.Size+V(grow,grow,grow),CFrame.identity,color,id,layer)
	end
	if slots.INNER_TOP then
		for _,name in ipairs({"UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm"}) do wrapBody(name,slots.INNER_TOP,cloth,1,.045) end
	end
	if slots.INNER_BOTTOM then
		for _,name in ipairs({"LowerTorso","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg"}) do wrapBody(name,slots.INNER_BOTTOM,C(73,57,44),2,.065) end
	end
	if slots.OUTER_TOP then
		for _,name in ipairs({"UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"}) do wrapBody(name,slots.OUTER_TOP,C(60,56,85),3,.11) end
	end
	local accessories=Instance.new("Model");accessories.Name="RigidAccessories";accessories.Parent=m
	if selection.hairAssetId then
		local color=hairColors[selection.hairColorId or "HAIR_DARK_BROWN"]
		garment(accessories,head,"ACC_HAIR_HUMAN_01",V(1.13,.3,1.01),CFrame.new(0,.48,.035),color,"ACC_HAIR_HUMAN_01",4)
		for _,side in ipairs({-1,1}) do garment(accessories,head,"HairSide",V(.19,.46,.75),CFrame.new(side*.49,.2,.08),color,"ACC_HAIR_HUMAN_01",4) end
	end
	if slots.HEADWEAR then
		garment(accessories,head,"HatBrim",V(1.72,.12,1.52),CFrame.new(0,.65,0),C(43,43,60),slots.HEADWEAR,5)
		garment(accessories,head,"HatCrown",V(.88,.62,.83),CFrame.new(0,.99,0),C(43,43,60),slots.HEADWEAR,5)
	end
	return m
end

function Renderer.clear(character: Model)
	local old=character:FindFirstChild(OVERLAY);if old then old:Destroy() end
	for _,instance in ipairs(character:GetDescendants()) do
		local transparency=instance:GetAttribute(SAVED)
		if instance:IsA("BasePart") and type(transparency)=="number" then instance.Transparency=transparency;instance:SetAttribute(SAVED,nil) end
	end
	character:SetAttribute("ModularAppearanceActive",nil);character:SetAttribute("ModularAppearanceKey",nil)
end

local function appearanceKey(s: any): string
	local fields={s.bodyPresetId,s.skinPaletteId,s.headPresetId,s.hairAssetId or "",s.hairColorId or ""}
	for _,slot in ipairs({"INNER_TOP","INNER_BOTTOM","OUTER_TOP","HEADWEAR"}) do table.insert(fields,(s.outfitSlots or {})[slot] or "") end
	return table.concat(fields,"|")
end

function Renderer.apply(character: Model,selection: any): (boolean,string?)
	local valid,err=validate(selection);if not valid then return false,err end
	local key=appearanceKey(selection)
	if character:GetAttribute("ModularAppearanceKey")==key and character:FindFirstChild(OVERLAY) then return true,nil end
	local root=character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then return false,"RIG_ROOT_MISSING" end
	local r15=character:FindFirstChild("UpperTorso")~=nil
	local targets: {[string]: BasePart}={}
	local r6={Head="Head",UpperTorso="Torso",LowerTorso="Torso",LeftUpperArm="Left Arm",LeftLowerArm="Left Arm",LeftHand="Left Arm",RightUpperArm="Right Arm",RightLowerArm="Right Arm",RightHand="Right Arm",LeftUpperLeg="Left Leg",LeftLowerLeg="Left Leg",LeftFoot="Left Leg",RightUpperLeg="Right Leg",RightLowerLeg="Right Leg",RightFoot="Right Leg"}
	for _,name in ipairs(Skeleton.Names) do
		local target=character:FindFirstChild(if r15 then name else r6[name])
		if not target or not target:IsA("BasePart") then return false,"RIG_PART_MISSING:"..name end
		targets[name]=target
	end
	local overlay: Model?=nil
	local built,buildError=pcall(function()
		overlay=Renderer.Build(selection)
		local candidate=overlay :: Model
		for _,item in ipairs(candidate:GetDescendants()) do if item:IsA("Motor6D") then item:Destroy() end end
		candidate:PivotTo(root.CFrame)
		for _,name in ipairs(Skeleton.Names) do
			local p=candidate:FindFirstChild(name) :: BasePart;local target=targets[name]
			local newCf: CFrame
			if r15 then newCf=target.CFrame
			else
				local spec=Skeleton.Parts[name];local targetName=r6[name];local center: Vector3
				if targetName=="Torso" then center=V(0,.69,0)
				elseif targetName=="Head" then center=Skeleton.Parts.Head[2]
				elseif targetName:find("Arm") then center=V(spec[2].X,.69,0)
				else center=V(spec[2].X,-1.58,0) end
				newCf=target.CFrame*CFrame.new(spec[2]-center)
			end
			local delta=newCf*p.CFrame:Inverse()
			-- Garments are welded to their visual segment; move each weld-owned item before parenting.
			for _,item in ipairs(candidate:GetDescendants()) do
				if item:IsA("BasePart") and item~=p then local w=item:FindFirstChild("AppearanceWeld");if w and w:IsA("WeldConstraint") and w.Part0==p then item.CFrame=delta*item.CFrame end end
			end
			p.CFrame=newCf;p.CollisionGroup=target.CollisionGroup;weld(target,p)
		end
		local visualRoot=candidate.PrimaryPart :: BasePart;visualRoot.CFrame=root.CFrame;weld(root,visualRoot)
		candidate:SetAttribute("RigAdapter",if r15 then "R15_SEGMENT_OVERLAY" else "R6_PROXY_SEGMENT_OVERLAY_NO_ELBOW_KNEE_ANIMATION")
	end)
	if not built then if overlay then overlay:Destroy() end;return false,"RENDER_FAILED:"..tostring(buildError) end
	Renderer.clear(character)
	-- Preserve physics, joints, root and authoritative equipment. Only visibility of legacy body cosmetics changes.
	for _,item in ipairs(character:GetDescendants()) do
		if not item:IsA("BasePart") or item==root then continue end
		local cursor: Instance?=item;local preserved=false
		while cursor and cursor~=character do
			-- CityNpcAppearance owns these existing profession cues and work tools.
			-- Appearance may hide the old body, but must retain their original weld targets.
			if cursor.Name:sub(1,8)=="Equipped" or cursor.Name=="CityRoleVisual" then preserved=true;break end
			cursor=cursor.Parent
		end
		if not preserved then item:SetAttribute(SAVED,item.Transparency);item.Transparency=1 end
	end
	(overlay :: Model).Parent=character;character:SetAttribute("ModularAppearanceActive",true);character:SetAttribute("ModularAppearanceKey",key)
	return true,nil
end
return Renderer
