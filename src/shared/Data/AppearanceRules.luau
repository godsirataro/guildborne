--!strict
-- Pure bounded validation; no client-provided instance or Roblox asset ID enters the library.
local Rules = {}
local fields = { appearanceVersion=true,raceId=true,bodyPresetId=true,skinPaletteId=true,headPresetId=true,hairAssetId=true,hairColorId=true,beardAssetId=true,raceFeatures=true,outfitSlots=true }
local required = {"raceId","bodyPresetId","skinPaletteId","headPresetId","hairColorId"}
local slots = { INNER_TOP=true,INNER_BOTTOM=true,OUTER_TOP=true,OUTER_BOTTOM=true,CHEST_ARMOR=true,SHOULDERS=true,GLOVES=true,BOOTS=true,BELT=true,CAPE=true,HEADWEAR=true,HAIR=true,BEARD=true,RACE_FEATURE=true,WEAPON=true }
local function id(value: any): boolean
	return type(value)=="string" and #value>0 and #value<=64 and value:match("^[A-Z][A-Z0-9_]*$")~=nil
end
function Rules.validRevision(value: any): boolean
	return type(value)=="number" and value==value and value>=0 and value<=1000000000 and value%1==0
end
local function map(value: any, allowed: any, maximum: number): boolean
	if type(value)~="table" or getmetatable(value)~=nil then return false end
	local count=0
	for key, member in pairs(value) do
		count+=1
		if count>maximum or not id(key) or (allowed and not allowed[key]) or not id(member) then return false end
	end
	return true
end
function Rules.validateShape(selection: any): boolean
	if type(selection)~="table" or getmetatable(selection)~=nil or selection.appearanceVersion~=1 then return false end
	for key in pairs(selection) do if not fields[key] then return false end end
	for _,key in ipairs(required) do if not id(selection[key]) then return false end end
	if selection.hairAssetId~=nil and not id(selection.hairAssetId) then return false end
	if selection.beardAssetId~=nil and not id(selection.beardAssetId) then return false end
	return map(selection.raceFeatures,nil,1) and map(selection.outfitSlots,slots,15)
end
local function copy(value: any): any
	local result={}
	for key,member in pairs(value) do result[key]=if type(member)=="table" then copy(member) else member end
	return result
end
function Rules.copy(value: any): any return copy(value) end

function Rules.validateSelection(selection: any,catalog: any,policy: any?,data: any?,actorId: string?): (any,string?)
	if not Rules.validateShape(selection) then return nil,"InvalidAppearance" end
	local nextSelection=copy(selection)
	nextSelection.headPresetId=catalog.HeadAliases[nextSelection.headPresetId] or nextSelection.headPresetId
	if not catalog.Races[nextSelection.raceId] then return nil,"InvalidAppearanceRace" end
	local body=catalog.Bodies[nextSelection.bodyPresetId]
	if not body or body.raceId~=nextSelection.raceId then return nil,"InvalidBodyPreset" end
	local skin=catalog.SkinPalettes[nextSelection.skinPaletteId]
	if not skin or skin.raceId~=nextSelection.raceId then return nil,"InvalidSkinPalette" end
	if not catalog.HairColors[nextSelection.hairColorId] then return nil,"InvalidHairColor" end
	if nextSelection.outfitSlots.WEAPON~=nil then return nil,"GameplayEquipmentSlot" end
	-- Dedicated appearance channels are exclusive even when the repeated asset is identical.
	if nextSelection.outfitSlots.HAIR or nextSelection.outfitSlots.BEARD or nextSelection.outfitSlots.RACE_FEATURE then return nil,"AppearanceSlotConflict" end
	local selected: any = {}
	local function asset(assetId: string,slot: string): string?
		local entry=catalog.Assets[assetId]
		if not entry then return "UnknownAppearanceAsset" end
		if entry.slot~=slot then return "AppearanceSlotMismatch" end
		if entry.raceId~="ALL" and entry.raceId~=nextSelection.raceId then return "AppearanceRaceMismatch" end
		if entry.fitProfile~="PRESET_SPECIFIC" and entry.fitProfile~=body.fitProfile then return "AppearanceFitMismatch" end
		if selected[assetId] then return "AppearanceSlotConflict" end
		selected[assetId]=true
		return nil
	end
	local problem=asset(body.assetId,"BODY") or asset(nextSelection.headPresetId,"HEAD")
	if problem then return nil,problem end
	if nextSelection.hairAssetId then problem=asset(nextSelection.hairAssetId,"HAIR");if problem then return nil,problem end end
	if nextSelection.beardAssetId then problem=asset(nextSelection.beardAssetId,"BEARD");if problem then return nil,problem end end
	for feature,assetId in pairs(nextSelection.raceFeatures) do
		if feature~="EARS" and feature~="TUSKS" then return nil,"InvalidRaceFeature" end
		if feature=="EARS" then
			if nextSelection.raceId~="ELF" then return nil,"AppearanceRaceMismatch" end
		else
			if nextSelection.raceId~="ORC" then return nil,"AppearanceRaceMismatch" end
		end
		problem=asset(assetId,"RACE_FEATURE");if problem then return nil,problem end
	end
	for slot,assetId in pairs(nextSelection.outfitSlots) do problem=asset(assetId,slot);if problem then return nil,problem end end
	if policy then
		for assetId in pairs(selected) do
			local available=false
			if policy.isAvailable then available=policy.isAvailable(assetId,nextSelection.bodyPresetId)==true
			elseif policy.AllowPlaceholders==true and body.raceId=="HUMAN" then
				available=policy.AllowedAssets and policy.AllowedAssets[assetId]==true and policy.AllowedPresets and policy.AllowedPresets[nextSelection.bodyPresetId]==true
			end
			if not available then return nil,"AppearanceAssetUnavailable" end
			local entitled=false
			if policy.isEntitled then entitled=policy.isEntitled(data,actorId,assetId)==true
			else entitled=policy.StarterEntitlements and policy.StarterEntitlements[assetId]==true end
			if not entitled then return nil,"AppearanceNotOwned" end
			local approved=false
			if policy.isFitApproved then approved=policy.isFitApproved(assetId,nextSelection.bodyPresetId)==true
			else local fits=policy.ApprovedFits and policy.ApprovedFits[nextSelection.bodyPresetId];approved=fits and fits[assetId]==true end
			if not approved then return nil,"AppearanceFitUnverified" end
		end
	end
	return nextSelection,nil
end
return table.freeze(Rules)
