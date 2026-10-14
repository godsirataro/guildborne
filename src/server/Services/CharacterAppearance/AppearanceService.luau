--!strict
-- Cosmetic extension through existing Commands/PlayerDataService transaction and receipts.
return function(catalog: any,rules: any,policy: any?)
	local Service = {}
	local activePolicy=policy or {}
	local legacyRaces={Human="HUMAN",Elf="ELF",Orc="ORC",Dwarf="DWARF"}
	function Service.default(actor: any?): any
		local race=if actor then legacyRaces[actor.raceId] or "HUMAN" else "HUMAN"
		local outfit={}
		if race=="HUMAN" or race=="ELF" then outfit={INNER_TOP="CLO_TUNIC_TRAVELER_01",INNER_BOTTOM="CLO_TROUSERS_TRAVELER_01"}
		elseif race=="ORC" then outfit={INNER_TOP="CLO_TUNIC_ORC_01",INNER_BOTTOM="CLO_TROUSERS_ORC_01"}
		else outfit={INNER_TOP="CLO_TUNIC_DWARF_01",INNER_BOTTOM="CLO_TROUSERS_DWARF_01"} end
		return {appearanceVersion=1,raceId=race,bodyPresetId=catalog.Defaults[race],skinPaletteId="SKIN_"..race.."_03",headPresetId="CHR_HEAD_"..race.."_01",hairAssetId="ACC_HAIR_"..race.."_01",hairColorId="HAIR_DARK_BROWN",raceFeatures={},outfitSlots=outfit}
	end
	function Service.read(actor: any): (any,number,boolean)
		return rules.copy(actor.appearance or Service.default(actor)),actor.appearanceRevision or 0,actor.appearanceEnabled==true
	end
	function Service.validateStored(actor: any): boolean
		if actor.appearanceEnabled~=nil and type(actor.appearanceEnabled)~="boolean" then return false end
		if actor.appearance==nil then return actor.appearanceRevision==nil and actor.appearanceEnabled~=true end
		if not rules.validRevision(actor.appearanceRevision) then return false end
		local normalized=rules.validateSelection(actor.appearance,catalog)
		-- Stored IDs must already be canonical; normalize aliases only at the command boundary.
		return normalized~=nil and normalized.headPresetId==actor.appearance.headPresetId
	end
	function Service.migrate(data: any): (boolean,string?)
		local actors={data.character}
		for _,actor in pairs(data.adventurers) do table.insert(actors,actor) end
		-- Validate before any mutation, including actors later in the roster.
		for _,actor in ipairs(actors) do if not Service.validateStored(actor) then return false,"CorruptAppearance" end end
		for _,actor in ipairs(actors) do
			if actor.appearance==nil then actor.appearance=Service.default(actor);actor.appearanceRevision=0;actor.appearanceEnabled=false end
		end
		return true,nil
	end
	function Service.apply(data: any,args: any,emit: any): string?
		if type(args)~="table" or type(args.actorId)~="string" or not rules.validRevision(args.appearanceRevision) then return "InvalidAppearance" end
		for key in pairs(args) do if key~="actorId" and key~="selection" and key~="appearanceRevision" then return "InvalidAppearance" end end
		local actor=if args.actorId=="player" then data.character else data.adventurers[args.actorId]
		if not actor then return "AppearanceActorNotOwned" end
		if (actor.appearanceRevision or 0)~=args.appearanceRevision then return "AppearanceRevisionConflict" end
		if args.appearanceRevision>=1000000000 then return "AppearanceRevisionLimit" end
		if actor.condition=="Dead" or actor.condition=="Injured" then return "HeroUnavailable" end
		for _,job in pairs(data.settlement and data.settlement.jobs or {}) do if table.find(job.members,args.actorId) then return "HeroUnavailable" end end
		local expedition=data.quests and data.quests.active
		if expedition and expedition.state=="Running" then
			for _,member in ipairs(expedition.partySnapshot or {}) do if member.id==args.actorId then return "HeroUnavailable" end end
		end
		if data.expansion and data.expansion.tower.active and data.expansion.tower.active.state=="Fighting" then return "LeaveTowerFirst" end
		local selection,problem=rules.validateSelection(args.selection,catalog,activePolicy,data,args.actorId)
		if not selection then return problem end
		actor.appearance=selection
		actor.appearanceRevision=args.appearanceRevision+1
		actor.appearanceEnabled=true
		emit("appearance_committed",{actorId=args.actorId,appearanceVersion=1,appearanceRevision=actor.appearanceRevision})
		return nil
	end
	return Service
end
