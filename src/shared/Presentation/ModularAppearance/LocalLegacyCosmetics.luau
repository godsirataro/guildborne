--!strict
-- Visibility policy for the unpublished local mesh inspection only.
-- Allowlists mirror HeroRig, HeroAppearance/HeroVisualKit and Renderer source.
-- Unknown geometry and authoritative equipment are deliberately left visible.
local RunService = game:GetService("RunService")
local Cosmetics = {}
local bodyNames: {[string]: boolean} = {
	Head=true, Torso=true, ["Left Arm"]=true, ["Right Arm"]=true,
	["Left Leg"]=true, ["Right Leg"]=true, UpperTorso=true, LowerTorso=true,
	LeftUpperArm=true, LeftLowerArm=true, LeftHand=true, RightUpperArm=true,
	RightLowerArm=true, RightHand=true, LeftUpperLeg=true, LeftLowerLeg=true,
	LeftFoot=true, RightUpperLeg=true, RightLowerLeg=true, RightFoot=true,
}
local equipmentNames: {[string]: boolean} = {
	Grip=true, Guard=true, Blade=true, Point=true, Pommel=true, BowLimb=true,
	Bowstring=true, Staff=true, Focus=true, Arrow=true, Quiver=true, Book=true,
}
local templateClasses: {[string]: string} = {
	warrior_01="Warrior", warrior_02="Warrior", warrior_03="Warrior",
	knight_01="Knight", knight_02="Knight", knight_03="Knight",
	archer_01="Archer", archer_02="Archer", archer_03="Archer",
	mage_01="Mage", mage_02="Mage", mage_03="Mage",
	priest_01="Priest", priest_02="Priest", priest_03="Priest",
}
local kitBones: {[string]: string} = {
	Waist="LowerTorso", Chest="UpperTorso", Belt="LowerTorso", Head="Head",
	LeftEye="Head", RightEye="Head", GuildClasp="UpperTorso", Hair="Head",
	LeftUpperArm="LeftUpperArm", LeftLowerArm="LeftLowerArm", LeftHand="LeftHand",
	RightUpperArm="RightUpperArm", RightLowerArm="RightLowerArm", RightHand="RightHand",
	LeftUpperLeg="LeftUpperLeg", LeftLowerLeg="LeftLowerLeg", LeftBoot="LeftFoot",
	RightUpperLeg="RightUpperLeg", RightLowerLeg="RightLowerLeg", RightBoot="RightFoot",
	LeftShoulder="LeftUpperArm", RightShoulder="RightUpperArm", Breastplate="UpperTorso",
	BattleHelm="Head", Beard="Head", Cape="UpperTorso", ChestStrap="UpperTorso",
	Circlet="Head", Cloak="UpperTorso", CowlBack="Head", Crest="Head",
	CrystalCrown="Head", FaceWrap="Head", Feather="Head", FurMantle="UpperTorso",
	GreatHelm="Head", HatBrim="Head", HatCrown="Head", HatTip="Head", Headband="Head",
	HelmWing="Head", Hood="Head", Mantle="UpperTorso", Mitre="Head", OpenHelm="Head",
	Robe="LowerTorso", ScholarHood="Head", Stole="UpperTorso", SunCrest="Head", Visor="Head",
}
-- Direct fixed costume details from HeroRig, distinct from EquippedArmor.
local directAnchors: {[string]: {[string]: boolean}} = {
	Eye={Head=true}, Hand={["Left Arm"]=true,["Right Arm"]=true},
	Boot={["Left Leg"]=true,["Right Leg"]=true}, Belt={Torso=true}, GuildClasp={Torso=true},
	Breastplate={Torso=true}, Pauldron={["Left Arm"]=true,["Right Arm"]=true},
	Helmet={Head=true}, HelmetRidge={Head=true}, GreatHelm={Head=true},
	Tabard={Torso=true}, Mantle={Torso=true}, Hood={Head=true}, HoodBack={Head=true},
	Cloak={Torso=true}, RobeSkirt={Torso=true}, Stole={Torso=true}, Hair={Head=true},
	Circlet={Head=true}, MageRobe={Torso=true}, HatBrim={Head=true}, HatCrown={Head=true},
	HatTip={Head=true}, HatBand={Head=true},
}

local function available(): boolean
	return RunService:IsStudio() and RunService:IsClient() and game.PlaceId == 0 and game.GameId == 0
end

local function protected(actor: Model, item: Instance): boolean
	local cursor: Instance? = item
	while cursor and cursor ~= actor do
		if cursor:IsA("Tool") or cursor.Name:sub(1,8) == "Equipped"
			or cursor.Name == "CityRoleVisual" or equipmentNames[cursor.Name]
			or string.find(string.lower(cursor.Name), "shield", 1, true)
			or cursor:GetAttribute("ItemId") ~= nil then return true end
		cursor = cursor.Parent
	end
	return cursor ~= actor
end

local function sourceWeld(actor: Model, part: BasePart, anchors: {[string]: boolean}): boolean
	for _, joint in ipairs(part:GetChildren()) do
		if joint:IsA("WeldConstraint") and joint.Part1 == part and joint.Part0
			and joint.Part0.Parent == actor and anchors[joint.Part0.Name] then return true end
	end
	return false
end

local function overlayPart(actor: Model, item: BasePart): boolean
	local parent = item.Parent
	if not parent then return false end
	local overlay = if parent.Name == "GuildborneModularAppearance" then parent else parent.Parent
	if not overlay or not overlay:IsA("Model") or overlay.Parent ~= actor
		or overlay.Name ~= "GuildborneModularAppearance"
		or overlay:GetAttribute("AssetStatus") ~= "PLACEHOLDER"
		or overlay:GetAttribute("GeometryKind") ~= "15_PARTS_NOT_IMPORTED_MESHPARTS"
		or item:GetAttribute("AssetStatus") ~= "PLACEHOLDER" then return false end
	if parent == overlay then return bodyNames[item.Name] == true and item:GetAttribute("CoreBodyPart") == true end
	if not parent:IsA("Model") then return false end
	if parent.Name == "FaceDetails" then return item.Name == "Eye" end
	local id = item:GetAttribute("AssetId")
	if parent.Name == "AlwaysOnModesty" then
		return id == "ALWAYS_ON_MODESTY" and item:GetAttribute("AlwaysOnModesty") == true
			and ({ModestyUpperTorso=true,ModestyLowerTorso=true,ModestyLeftUpperLeg=true,ModestyRightUpperLeg=true})[item.Name] == true
	elseif parent.Name == "OutfitSlots" then
		if type(id) ~= "string" then return false end
		local permitted: {[string]: {[string]: boolean}} = {
			CLO_TUNIC_TRAVELER_01={UpperTorso=true,LowerTorso=true,LeftUpperArm=true,RightUpperArm=true},
			CLO_TROUSERS_TRAVELER_01={LowerTorso=true,LeftUpperLeg=true,RightUpperLeg=true,LeftLowerLeg=true,RightLowerLeg=true},
			CLO_ROBE_WIZARD_01={UpperTorso=true,LowerTorso=true,LeftUpperArm=true,RightUpperArm=true,LeftUpperLeg=true,RightUpperLeg=true},
		}
		local names = permitted[id]
		return names ~= nil and item.Name:sub(1,#id+1) == id.."_" and names[item.Name:sub(#id+2)] == true
	elseif parent.Name == "RigidAccessories" then
		return (id == "ACC_HAIR_HUMAN_01" and (item.Name == id or item.Name == "HairSide"))
			or (id == "CLO_HAT_WIZARD_01" and (item.Name == "HatBrim" or item.Name == "HatCrown"))
	end
	return false
end

local function eligible(actor: Model, item: Instance): string?
	if protected(actor,item) then return nil end
	local parent = item.Parent
	if item:IsA("Decal") then
		if item.ClassName == "Decal" and (item.Name == "face" or item.Name == "Face") and parent and parent:IsA("BasePart")
			and parent.Name == "Head" and parent.Parent == actor then return "face" end
		return nil
	end
	if not item:IsA("BasePart") then return nil end
	if parent == actor and bodyNames[item.Name] then return "body" end
	if parent == actor and item.ClassName == "Part" and actor:GetAttribute("GuildborneHero") == true then
		local anchors = directAnchors[item.Name]
		if anchors and sourceWeld(actor,item,anchors) then return "heroDetail" end
	end
	if parent and parent:IsA("Model") and parent.Name == "HeroAppearance" and parent.Parent == actor
		and item.ClassName == "Part" and actor:GetAttribute("GuildborneHero") == true then
		local id = actor:GetAttribute("VisualTemplateId")
		local class = if type(id) == "string" then templateClasses[id] else nil
		local bone = kitBones[item.Name]
		if class and parent:GetAttribute("DesignId") == "ui.heroes."..(id :: string)
			and parent:GetAttribute("ClassId") == class and actor:GetAttribute("ClassId") == class
			and parent:GetAttribute("RecruitmentBound") == false and bone and item:GetAttribute("BindBone") == bone then
			local anchor = if bone == "Head" then "Head" elseif bone:find("Arm") or bone:find("Hand") then
				(if bone:sub(1,4) == "Left" then "Left Arm" else "Right Arm")
				elseif bone:find("Leg") or bone:find("Foot") then
				(if bone:sub(1,4) == "Left" then "Left Leg" else "Right Leg") else "Torso"
			if sourceWeld(actor,item,{[anchor]=true}) then return "heroTemplate" end
		end
	end
	if overlayPart(actor,item) then return "placeholder" end
	if parent and parent:IsA("Accessory") and parent.Parent == actor and item.Name == "Handle" then
		local attachmentName = if parent.AccessoryType == Enum.AccessoryType.Hair then "HairAttachment"
			elseif parent.AccessoryType == Enum.AccessoryType.Hat then "HatAttachment" else nil
		local attachment = if attachmentName then item:FindFirstChild(attachmentName) else nil
		local weld = item:FindFirstChild("AccessoryWeld")
		if attachment and attachment:IsA("Attachment") and weld and weld:IsA("Weld") then
			-- Source-generated hats and Roblox avatar accessories can reverse the edge.
			local target = if weld.Part1 == item then weld.Part0 elseif weld.Part0 == item then weld.Part1 else nil
			if target and target.Parent == actor and target.Name == "Head" then return "avatarHairOrHat" end
		end
	end
	-- AncestryVisual and all unrecognized/future structures remain visible.
	return nil
end

type Saved = { prior: number, kind: string }
function Cosmetics.New(actor: Model): (any?, string?)
	if not available() then return nil,"LOCAL_UNPUBLISHED_CLIENT_STUDIO_ONLY" end
	if typeof(actor) ~= "Instance" or not actor:IsA("Model") or not actor:IsDescendantOf(workspace) then
		return nil,"LOCAL_ACTOR_REQUIRED"
	end
	local saved: {[Instance]: Saved} = {}
	local destroyed, syncs, restores, failures = false, 0, 0, 0
	local state = {}
	local function restore(item: Instance, entry: Saved)
		local ok = pcall(function()
			if item:IsA("BasePart") then item.LocalTransparencyModifier = entry.prior
			elseif item:IsA("Decal") then item.Transparency = entry.prior end
		end)
		if ok then restores += 1 else failures += 1 end
		saved[item] = nil
	end
	function state:Destroy()
		if destroyed then return end
		destroyed = true
		for item, entry in pairs(saved) do restore(item,entry) end
	end
	function state:Sync(): (boolean,string?)
		if destroyed then return false,"COSMETIC_STATE_DESTROYED" end
		if not available() or not actor:IsDescendantOf(workspace) then
			self:Destroy(); return false,"LOCAL_ACTOR_UNAVAILABLE"
		end
		local ok, err = pcall(function()
			-- Restore before evaluating additions. Reparent/name/type/metadata changes
			-- cease eligibility on this next frame; no stale hidden state is retained.
			for item, entry in pairs(saved) do
				if not eligible(actor,item) then restore(item,entry) end
			end
			for _, item in ipairs(actor:GetDescendants()) do
				local kind = eligible(actor,item)
				if not kind then continue end
				if item:IsA("BasePart") then
					if not saved[item] then saved[item] = {prior=item.LocalTransparencyModifier,kind=kind} end
					item.LocalTransparencyModifier = 1
				elseif item:IsA("Decal") then
					if not saved[item] then saved[item] = {prior=item.Transparency,kind=kind} end
					item.Transparency = 1
				end
			end
			syncs += 1
			return true
		end)
		if not ok then self:Destroy(); return false,tostring(err) end
		return true,nil
	end
	function state:GetDiagnostics(): any
		local kinds: {[string]: number} = {}
		local count = 0
		for _, entry in pairs(saved) do count += 1; kinds[entry.kind] = (kinds[entry.kind] or 0)+1 end
		return {hidden=count,kinds=kinds,syncs=syncs,restores=restores,restoreFailures=failures,destroyed=destroyed,connections=0}
	end
	return state,nil
end

return Cosmetics
