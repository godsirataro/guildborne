--!strict
-- Unpublished client inspection of the actual HeroRig.Equip training sword.
-- ArtKit IronSword fallback, scaled .65; deliberately NOT ItemVisuals inventory art.
-- Source sword +Y points along the blade. The local Human Standard fit rotates
-- it out of the palm, not back along the forearm; socket center/geometry stay fixed.
-- This procedural inspection fit is not final art or general-race acceptance.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Weapon = {}
local active: {[Model]: any} = {}
local names = {"Grip","Guard","Blade","Point","Pommel"}
local V = Vector3.new
local gripFitAngle = math.pi + .45
local gripFit = CFrame.Angles(gripFitAngle,0,0)
local shapes = {
	Grip={class="Part",size=V(.3,1,.3)*.65,relative=CFrame.identity},
	Guard={class="Part",size=V(1.5,.22,.4)*.65,relative=CFrame.new(0,.6*.65,0)},
	Blade={class="Part",size=V(.5,2.6,.16)*.65,relative=CFrame.new(0,2*.65,0)},
	Point={class="WedgePart",size=V(.16,.6,.5)*.65,relative=CFrame.new(0,3.6*.65,0)*CFrame.Angles(0,math.pi/2,0)},
	Pommel={class="Part",size=V(.45,.3,.4)*.65,relative=CFrame.new(0,-.65*.65,0)},
}

local function available(): boolean
	return RunService:IsStudio() and RunService:IsClient() and game.PlaceId == 0 and game.GameId == 0
end

local function owned(actor: Model): boolean
	local player = Players.LocalPlayer
	if not player then return false end
	local characterOwner = Players:GetPlayerFromCharacter(actor)
	if characterOwner then return characterOwner == player and player.Character == actor end
	return actor:GetAttribute("GuildborneHero") == true and actor:GetAttribute("OwnerUserId") == player.UserId
end

local function finite(value: number): boolean
	return value == value and math.abs(value) < math.huge
end

local function finiteFrame(frame: CFrame): boolean
	for _, value in ipairs({frame:GetComponents()}) do if not finite(value) then return false end end
	return true
end

local function sourcePayload(actor: Model): (Model?, any?, string)
	if actor:GetAttribute("WeaponId") == nil then return nil,nil,"NO_WEAPON" end
	if actor:GetAttribute("WeaponId") ~= "training_sword" then return nil,nil,"UNSUPPORTED_WEAPON" end
	local gear: Model? = nil
	for _, child in ipairs(actor:GetChildren()) do
		if child.Name == "EquippedWeapon" then
			if gear or not child:IsA("Model") then return nil,nil,"MALFORMED_WEAPON_MODEL" end
			gear = child
		end
	end
	if not gear then return nil,nil,"NO_WEAPON" end
	if #gear:GetChildren() ~= 5 then return nil,nil,"UNREVIEWED_WEAPON_CONTENTS" end
	local grip = gear:FindFirstChild("Grip")
	local arm = actor:FindFirstChild("RightHand") or actor:FindFirstChild("Right Arm")
	if not grip or not grip:IsA("BasePart") or not arm or not arm:IsA("BasePart")
		or not finiteFrame(grip.CFrame) then return nil,nil,"WEAPON_GRIP_OR_ARM_MISSING" end
	local payload = {}
	for _, name in ipairs(names) do
		local part = gear:FindFirstChild(name)
		local spec = shapes[name]
		if not part or not part:IsA("BasePart") or part.ClassName ~= spec.class
			or (part:IsA("Part") and part.Shape ~= Enum.PartType.Block)
			or part.MaterialVariant ~= ""
			or part.Anchored or not part.Massless or part.CanCollide or part.CanTouch or part.CanQuery then
			return nil,nil,"UNSUPPORTED_WEAPON_PART:"..name
		end
		if not finiteFrame(part.CFrame) or not finite(part.Size.Magnitude)
			or (part.Size-spec.size).Magnitude > .001 then return nil,nil,"WEAPON_SOURCE_SIZE_CHANGED:"..name end
		local children = part:GetChildren()
		local weld = children[1]
		if #children ~= 1 or not weld or not weld:IsA("WeldConstraint")
			or not weld.Enabled or weld.Part0 ~= arm or weld.Part1 ~= part then
			return nil,nil,"WEAPON_SOURCE_WELD_INVALID:"..name
		end
		local relative = grip.CFrame:ToObjectSpace(part.CFrame)
		local _, angle = spec.relative.Rotation:ToObjectSpace(relative.Rotation):ToAxisAngle()
		if (relative.Position-spec.relative.Position).Magnitude > .02 or math.abs(angle) > .01 then
			return nil,nil,"WEAPON_SOURCE_LAYOUT_CHANGED:"..name
		end
		if not finite(part.Transparency) or not finite(part.Reflectance) or not finite(part.LocalTransparencyModifier)
			or not finite(part.Color.R) or not finite(part.Color.G) or not finite(part.Color.B) then
			return nil,nil,"WEAPON_SOURCE_VISUAL_INVALID:"..name
		end
		payload[name] = {part=part,weld=weld,relative=relative}
	end
	return gear,payload,"READY"
end

function Weapon.New(actor: Model, preview: Model): (any?, string?)
	if not available() then return nil,"LOCAL_UNPUBLISHED_CLIENT_STUDIO_ONLY" end
	if typeof(actor) ~= "Instance" or not actor:IsA("Model")
		or typeof(preview) ~= "Instance" or not preview:IsA("Model") then return nil,"ACTOR_AND_PREVIEW_REQUIRED" end
	if not owned(actor) then return nil,"LOCAL_PLAYER_OR_OWNED_HERO_REQUIRED" end
	local humanoid = actor:FindFirstChildOfClass("Humanoid")
	local root = actor:FindFirstChild("HumanoidRootPart")
	local hand = preview:FindFirstChild("RightHand")
	local socket = if hand then hand:FindFirstChild("RightGripAttachment") else nil
	if not actor:IsDescendantOf(workspace) or not preview:IsDescendantOf(workspace)
		or preview:GetAttribute("LOCAL_TEST_ONLY") ~= true or preview:GetAttribute("BodyPresetId") ~= "HUMAN_STANDARD"
		or not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
		or not hand or not hand:IsA("BasePart") or hand:GetAttribute("CoreBodyPart") ~= true
		or not socket or not socket:IsA("Attachment") or socket:GetAttribute("SourceDerived") ~= true
		or socket:GetAttribute("SourceBone") ~= "RightHand" then return nil,"LIVE_SOURCE_SOCKET_PREVIEW_REQUIRED" end
	local old = active[actor]; if old then old:Destroy() end
	local player = Players:GetPlayerFromCharacter(actor)
	local state = {}
	local model: Model? = nil
	local source: Model? = nil
	local copied: {[string]: BasePart} = {}
	local originals: {[BasePart]: number} = {}
	local connections: {RBXScriptConnection} = {}
	local destroyed, builds, restores, restoreFailures, syncs = false,0,0,0,0
	local status, lastError = "PENDING", ""
	local function clear()
		for part, prior in pairs(originals) do
			local ok = pcall(function() part.LocalTransparencyModifier = prior end)
			if ok then restores += 1 else restoreFailures += 1 end
		end
		table.clear(originals)
		local priorModel = model; model = nil; source = nil; table.clear(copied)
		if priorModel then priorModel:Destroy() end
	end
	function state:Destroy()
		if destroyed then return end
		destroyed = true; status = "DESTROYED"
		if active[actor] == self then active[actor] = nil end
		for _, connection in ipairs(connections) do connection:Disconnect() end
		table.clear(connections); clear()
	end
	function state:GetModel(): Model? return model end
	function state:GetDiagnostics(): any
		local count = 0; for _ in pairs(originals) do count += 1 end
		return {status=status,lastError=lastError,destroyed=destroyed,hiddenOriginalParts=count,
			visualParts=if model then #model:GetChildren() else 0,builds=builds,syncs=syncs,
			restores=restores,restoreFailures=restoreFailures,connections=#connections,
			orientation="SOURCE_SOCKET_CENTER_FIXED_HUMAN_SWORD_FIT",gripFitAngle=gripFitAngle,
			gripFitAccepted=false,combatRetargetAccepted=false}
	end
	function state:Sync(): (boolean,string?)
		if destroyed then return false,"WEAPON_STATE_DESTROYED" end
		if not available() or not owned(actor) or not actor:IsDescendantOf(workspace) or not preview:IsDescendantOf(workspace)
			or humanoid.Parent ~= actor or humanoid.Health <= 0 or root.Parent ~= actor
			or hand.Parent ~= preview or socket.Parent ~= hand or (player and player.Character ~= actor) then
			self:Destroy(); return false,"ACTOR_OR_PREVIEW_LOST"
		end
		local ok, err = pcall(function()
			assert(preview:GetAttribute("LOCAL_TEST_ONLY") == true and preview:GetAttribute("BodyPresetId") == "HUMAN_STANDARD"
				and hand:GetAttribute("CoreBodyPart") == true and socket.Name == "RightGripAttachment"
				and socket:GetAttribute("SourceDerived") == true and socket:GetAttribute("SourceBone") == "RightHand"
				and finiteFrame(socket.WorldCFrame),"SOURCE_SOCKET_INVALID")
			local gear, payload, result = sourcePayload(actor)
			status = result
			if not gear or not payload then clear(); syncs += 1; return true end
			if gear ~= source then clear() end
			if model then
				assert(model.Parent == workspace and #model:GetChildren() == 5,"LOCAL_WEAPON_COPY_CHANGED")
				for _, name in ipairs(names) do
					local copy = copied[name]
					assert(copy and copy.Parent == model and #copy:GetChildren() == 0,"LOCAL_WEAPON_COPY_CHANGED")
					if originals[payload[name].part] == nil then clear(); break end
				end
			end
			if not model then
				-- Enroll the unparented candidate in cleanup before populating it. Never Clone.
				local candidate = Instance.new("Model"); model = candidate; candidate.Name = "LocalTrainingSwordInspection"
				candidate:SetAttribute("LOCAL_TEST_ONLY",true); candidate:SetAttribute("AssetStatus","LOCAL_EXISTING_GEOMETRY_COPY")
				candidate:SetAttribute("SourceWeaponId","training_sword"); candidate:SetAttribute("GripFitAccepted",false)
				candidate:SetAttribute("GripOrientation","BLADE_OUT_OF_HAND_RX_PI_PLUS_0_45")
				for _, name in ipairs(names) do
					local copy = Instance.new(shapes[name].class) :: BasePart
					copy.Name = name; copy.Parent = candidate; copied[name] = copy
				end
				candidate.PrimaryPart = copied.Grip; source = gear; builds += 1
			end
			for _, name in ipairs(names) do
				local original = payload[name].part :: BasePart
				local copy = copied[name]
				copy.Size = original.Size; copy.Color = original.Color; copy.Material = original.Material
				copy.Transparency = original.Transparency; copy.Reflectance = original.Reflectance
				copy.CastShadow = original.CastShadow; copy.TopSurface = original.TopSurface; copy.BottomSurface = original.BottomSurface
				copy.LeftSurface = original.LeftSurface; copy.RightSurface = original.RightSurface
				copy.FrontSurface = original.FrontSurface; copy.BackSurface = original.BackSurface
				copy.Anchored = true; copy.Massless = true; copy.CanCollide = false; copy.CanTouch = false; copy.CanQuery = false
				copy.CFrame = socket.WorldCFrame * gripFit * payload[name].relative
			end
			(model :: Model).Parent = workspace
			-- All five visual parts exist and are positioned before hiding any original.
			for _, name in ipairs(names) do
				local original = payload[name].part :: BasePart
				if originals[original] == nil then originals[original] = original.LocalTransparencyModifier end
				original.LocalTransparencyModifier = 1
			end
			syncs += 1; return true
		end)
		if not ok then lastError = tostring(err); self:Destroy(); return false,lastError end
		return true,nil
	end
	active[actor] = state
	table.insert(connections,actor.Destroying:Connect(function() state:Destroy() end))
	table.insert(connections,preview.Destroying:Connect(function() state:Destroy() end))
	table.insert(connections,humanoid.Died:Connect(function() state:Destroy() end))
	table.insert(connections,actor.AncestryChanged:Connect(function() if not actor:IsDescendantOf(workspace) then state:Destroy() end end))
	table.insert(connections,preview.AncestryChanged:Connect(function() if not preview:IsDescendantOf(workspace) then state:Destroy() end end))
	table.insert(connections,actor.DescendantRemoving:Connect(function(item)
		if item == root or item == humanoid then state:Destroy()
		elseif source and (item == source or item:IsDescendantOf(source)) then clear(); status = "SOURCE_REMOVED" end
	end))
	table.insert(connections,preview.DescendantRemoving:Connect(function(item)
		if item == hand or item == socket then state:Destroy() end
	end))
	if player then
		table.insert(connections,player.CharacterRemoving:Connect(function(character: Model) if character == actor then state:Destroy() end end))
		table.insert(connections,player.CharacterAdded:Connect(function(character: Model) if character ~= actor then state:Destroy() end end))
	end
	return state,nil
end

return Weapon
