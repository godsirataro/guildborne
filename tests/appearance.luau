--!strict
return function(test: any,eq: any)
	local Util=require("../src/shared/Util/TableUtil")
	local Catalog=require("../src/shared/Data/AppearanceCatalog")
	local Rules=require("../src/shared/Data/AppearanceRules")
	local MakeAppearance=require("../src/server/Services/CharacterAppearance/AppearanceService")
	local Protocol=require("../src/shared/Network/Protocol")
	local Content=require("../src/server/Config/Content")
	local Expansion=require("../src/shared/Data/Expansion")
	local StatusPoints=require("../src/shared/Data/StatusPoints")
	local Gear=require("../src/shared/Data/Equipment")(Content,Expansion,StatusPoints)
	local LandPlacement=require("../src/shared/Data/LandBuildingPlacement")(Expansion,require("../src/shared/Data/IslandPlacement"),require("../src/shared/Config/GuildIslandLayout"))
	local BuildingThemes=require("../src/shared/Data/BuildingThemeRights")(require("../src/shared/Config/BuildingThemes"))
	local ValidateExpansion=require("../src/server/Systems/ExpansionSchema")(Content,Util,Expansion,LandPlacement,BuildingThemes)
	local MarketConfig=require("../src/server/Config/Market")
	local Market=require("../src/server/Systems/MarketEscrow")(MarketConfig,Util,Content,require("../src/server/Systems/MarketOrders")(MarketConfig,Util))
	local Land=require("../src/shared/Data/GuildLand")(require("../src/server/Config/GuildLand"))
	local MakeSchema=require("../src/server/Systems/ProfileSchema")
	local plainSchema=MakeSchema(Content,Util,Gear,Expansion,ValidateExpansion,Market,Land)
	local ids={"CHR_BDY_HUMAN_STANDARD_V01","CHR_BDY_HUMAN_HEAVY_V01","CHR_HEAD_HUMAN_01","ACC_HAIR_HUMAN_01","ACC_BEARD_HUMAN_01","CLO_TUNIC_TRAVELER_01","CLO_TROUSERS_TRAVELER_01","CLO_ROBE_MAGE_01","CLO_HAT_WIZARD_01"}
	local function policy(): any
		local allowed={};for _,id in ipairs(ids) do allowed[id]=true end
		return {AllowPlaceholders=true,AllowedAssets=allowed,AllowedPresets={HUMAN_STANDARD=true,HUMAN_HEAVY=true},StarterEntitlements=Util.copy(allowed),ApprovedFits={HUMAN_STANDARD=Util.copy(allowed),HUMAN_HEAVY=Util.copy(allowed)}}
	end
	local service=MakeAppearance(Catalog,Rules,policy())
	local schema=MakeSchema(Content,Util,Gear,Expansion,ValidateExpansion,Market,Land,nil,nil,nil,service)
	local function selection(): any return service.default(nil) end
	local function data(): any return schema.new(1,1000).data end
	local function wire(s: any?): any return {version=1,requestId="appearance:1",revision=0,action="CommitAppearance",args={actorId="player",selection=s or selection(),appearanceRevision=0}} end
	local function strip(d: any): any
		local copy=Util.copy(d)
		local actors={copy.character};for _,hero in pairs(copy.adventurers) do table.insert(actors,hero) end
		for _,actor in ipairs(actors) do actor.appearance=nil;actor.appearanceRevision=nil;actor.appearanceEnabled=nil end
		return copy
	end
	local function apply(s: any,args: any?): (string?,any,any)
		local d=data();local events={};local a=args or {actorId="player",selection=s,appearanceRevision=0}
		return service.apply(d,a,function(name: string,payload: any)table.insert(events,{name=name,payload=payload})end),d,events
	end
	local function harness(): any
		local h: any={records={},now=1000,mode="ok",writes=0,notifications=0}
		local store={Update=function(key: string,transform: any,_userId: number?): any
			if h.mode=="before" then error("Injected pre-write failure") end
			if h.callbackReplay then transform(Util.copy(h.records[key])) end
			local value=transform(Util.copy(h.records[key]))
			if value then h.records[key]=Util.copy(value);h.writes+=1 end
			if h.mode=="after" then error("Injected response loss") end
			return Util.copy(value)
		end}
		local commands=require("../src/server/Systems/Commands")({Util=Util,Protocol=Protocol,Appearance=service})
		function h.make(): any
			return require("../src/server/Services/PlayerDataService")({Util=Util,Content=Content,Config=require("../src/server/Config/Runtime"),Schema=schema,Protocol=Protocol,Commands=commands,Store=store,Now=function()return h.now end,Wait=function(_s: number)end,Jitter=function()return 0 end,Log=function(_name: string,_fields: any)end,OnCommitted=function(_userId: number,_events: any)h.notifications+=1;if h.analyticsFailure then error("Injected analytics failure") end end})
		end
		h.service=h.make()
		eq(h.service.Load(1,"appearance-session"),"OK")
		function h.record(): any return h.service.Sessions[1].record end
		function h.command(s: any?): any
			local command=wire(s);command.revision=h.record().revision;command.args.appearanceRevision=h.record().data.character.appearanceRevision;return command
		end
		return h
	end
	 test("appearance catalog retains all planned original IDs and no imported assets",function()
		eq(Util.count(Catalog.Assets),89);eq(Util.count(Catalog.Bodies),13);eq(Util.count(Catalog.SkinPalettes),20)
		for id,entry in pairs(Catalog.Assets) do eq(entry.id,id);eq(entry.status,"PLANNED");eq(entry.runtimeImported,false);eq(entry.robloxAssetId,nil) end
		eq(table.isfrozen(Catalog.Assets),true);eq(table.isfrozen(Catalog.Assets.CHR_HEAD_HUMAN_01),true)
	end)
	test("appearance canonicalizes documented head aliases without changing client selection",function()
		local s=selection();s.headPresetId="HEAD_HUMAN_01";local result,problem=Rules.validateSelection(s,Catalog,policy(),data(),"player")
		eq(problem,nil);eq(result.headPresetId,"CHR_HEAD_HUMAN_01");eq(s.headPresetId,"HEAD_HUMAN_01")
	end)
	test("appearance wire requires version one full bounded shape",function()
		eq(Protocol.validate(wire()),true)
		for _,key in ipairs({"raceId","bodyPresetId","skinPaletteId","headPresetId","hairColorId","raceFeatures","outfitSlots"}) do local s=selection();s[key]=nil;eq(Protocol.validate(wire(s)),false) end
		local s=selection();s.appearanceVersion=2;eq(Protocol.validate(wire(s)),false)
	end)
	test("appearance wire rejects arbitrary Roblox numeric IDs and injected instances",function()
		local badValues: {any}={12345,"rbxassetid_12345","rbxassetid://12345",{},true,string.rep("A",65)}
		for _,bad in ipairs(badValues) do local s=selection();s.hairAssetId=bad;eq(Protocol.validate(wire(s)),false) end
		local s=selection();s.meshId=123;eq(Protocol.validate(wire(s)),false)
	end)
	test("appearance wire rejects unbounded nested slots and metatables",function()
		local s=selection();for i=1,16 do s.outfitSlots["SLOT_"..i]="ACC_HAIR_HUMAN_01" end;eq(Protocol.validate(wire(s)),false)
		s=selection();s.raceFeatures={EARS="ACC_EAR_ELF_01",TUSKS="ACC_TUSK_ORC_01"};eq(Protocol.validate(wire(s)),false)
		s=selection();s.outfitSlots=setmetatable({},{__index={}});eq(Protocol.validate(wire(s)),false)
	end)
	test("appearance revision rejects negative fractional infinity NaN and overflow",function()
		for _,bad in ipairs({-1,.5,math.huge,0/0,1000000001}) do local command=wire();command.args.appearanceRevision=bad;eq(Protocol.validate(command),false) end
		local command=wire();command.args.appearanceRevision=1000000000;eq(Protocol.validate(command),true)
	end)
	test("appearance wire rejects unknown action arguments and empty actor IDs",function()
		local command=wire();command.args.actorId="";eq(Protocol.validate(command),false);command=wire();command.args.ownerId=2;eq(Protocol.validate(command),false)
	end)
	test("appearance rejects unknown cosmetic race and Wizard pseudo race",function()
		for _,race in ipairs({"WIZARD","ALIEN","Human"}) do local s=selection();s.raceId=race;eq(apply(s),if race=="Human" then "InvalidAppearance" else "InvalidAppearanceRace") end
	end)
	test("appearance rejects a cross-race body preset",function()local s=selection();s.bodyPresetId="ORC_STANDARD";eq(apply(s),"InvalidBodyPreset")end)
	test("appearance rejects cross-race skin palettes",function()local s=selection();s.skinPaletteId="SKIN_ORC_03";eq(apply(s),"InvalidSkinPalette")end)
	test("appearance rejects unknown skin and hair color configuration IDs",function()local s=selection();s.skinPaletteId="SKIN_HUMAN_99";eq(apply(s),"InvalidSkinPalette");s=selection();s.hairColorId="CUSTOM_RED";eq(apply(s),"InvalidHairColor")end)
	test("appearance rejects unknown canonical asset IDs",function()local s=selection();s.hairAssetId="ACC_HAIR_CUSTOM_99";eq(apply(s),"UnknownAppearanceAsset")end)
	test("appearance rejects wrong slot asset even if starter owns it",function()local s=selection();s.outfitSlots.INNER_TOP="CLO_TROUSERS_TRAVELER_01";eq(apply(s),"AppearanceSlotMismatch")end)
	test("appearance rejects cross-race hair without ancestry mutation",function()local s=selection();s.hairAssetId="ACC_HAIR_ELF_01";eq(apply(s),"AppearanceRaceMismatch")end)
	test("appearance fit families do not grant universal garment fit",function()local s=selection();s.outfitSlots.INNER_TOP="CLO_TUNIC_ORC_01";eq(apply(s),"AppearanceFitMismatch")end)
	test("appearance refuses unverified exact preset fit",function()local p=policy();p.ApprovedFits.HUMAN_STANDARD.ACC_HAIR_HUMAN_01=nil;local actor=data();eq(MakeAppearance(Catalog,Rules,p).apply(actor,wire().args,function()end),"AppearanceFitUnverified")end)
	test("appearance refuses assets outside authenticated starter entitlements",function()local p=policy();p.StarterEntitlements.ACC_HAIR_HUMAN_01=nil;eq(MakeAppearance(Catalog,Rules,p).apply(data(),wire().args,function()end),"AppearanceNotOwned")end)
	test("appearance production policy refuses all planned assets",function()eq(MakeAppearance(Catalog,Rules).apply(data(),wire().args,function()end),"AppearanceAssetUnavailable")end)
	test("appearance placeholder flag alone does not grant asset availability",function()local p={AllowPlaceholders=true};eq(MakeAppearance(Catalog,Rules,p).apply(data(),wire().args,function()end),"AppearanceAssetUnavailable")end)
	test("appearance rejects duplicate dedicated hair beard and race feature channels",function()
		for _,slot in ipairs({"HAIR","BEARD","RACE_FEATURE"}) do local s=selection();s.outfitSlots[slot]="ACC_HAIR_HUMAN_01";eq(apply(s),"AppearanceSlotConflict") end
	end)
	test("appearance existing weapon ownership stays outside cosmetic slot",function()local s=selection();s.outfitSlots.WEAPON="ACC_TESTWEAPON_SWORD_01";eq(apply(s),"GameplayEquipmentSlot")end)
	test("appearance rejects foreign actor IDs and preserves every gameplay field",function()
		local d=data();local before=Util.copy(d);local args=wire().args;args.actorId="h:other";eq(service.apply(d,args,function()end),"AppearanceActorNotOwned");eq(d,before)
	end)
	test("appearance stale actor revision and exhaustion fail without mutation",function()
		local d=data();local before=Util.copy(d);local args=wire().args;args.appearanceRevision=1;eq(service.apply(d,args,function()end),"AppearanceRevisionConflict");eq(d,before)
		d.character.appearanceRevision=1000000000;args.appearanceRevision=1000000000;eq(service.apply(d,args,function()end),"AppearanceRevisionLimit")
	end)
	test("appearance dead injured dispatched and fighting actors remain unavailable",function()
		for _,condition in ipairs({"Dead","Injured"}) do local d=data();d.character.condition=condition;eq(service.apply(d,wire().args,function()end),"HeroUnavailable") end
		local d=data();d.settlement.jobs.job={members={"player"}};eq(service.apply(d,wire().args,function()end),"HeroUnavailable")
		d=data();d.expansion.tower.active={state="Fighting"};eq(service.apply(d,wire().args,function()end),"LeaveTowerFirst")
	end)
	test("appearance Standard golden path changes only appearance and emits one receipt",function()
		local d=data();local before=strip(d);local events={};eq(service.apply(d,wire().args,function(name: string,payload: any)table.insert(events,{name=name,payload=payload})end),nil)
		eq(strip(d),before);eq(d.character.raceId,"Human");eq(d.character.appearanceRevision,1);eq(d.character.appearanceEnabled,true);eq(#events,1);eq(events[1].name,"appearance_committed")
	end)
	test("appearance Heavy tint clothing removal and rigid choices preserve gameplay",function()
		local s=selection();s.bodyPresetId="HUMAN_HEAVY";s.skinPaletteId="SKIN_HUMAN_05";s.outfitSlots={OUTER_TOP="CLO_ROBE_MAGE_01",HEADWEAR="CLO_HAT_WIZARD_01"};s.hairAssetId=nil;s.beardAssetId="ACC_BEARD_HUMAN_01"
		local problem,d=apply(s);eq(problem,nil);eq(d.character.appearance,s);eq(strip(d),strip(data()))
	end)
	test("appearance independent heroes retain names templates and equipped inventory",function()
		local d=data();d.adventurers["h:1"]={id="h:1",name="Existing Hero",templateId="existing",raceId="Human",classId="Warrior",equipmentSlots={weapon="owned:1"},level=42,xp=999};local before=strip(d)
		local args=wire().args;args.actorId="h:1";eq(service.apply(d,args,function()end),nil);eq(strip(d),before);eq(d.character.appearanceEnabled,false);eq(d.adventurers["h:1"].appearanceEnabled,true)
	end)
	test("appearance migration is opt-in idempotent and preserves legacy save exactly",function()
		local original=plainSchema.new(1,1000);local before=Util.copy(original);local migrated,problem=schema.migrate(original)
		eq(problem,"OK");eq(original,before);eq(migrated.schemaVersion,original.schemaVersion);eq(strip(migrated.data),original.data);eq(migrated.revision,original.revision);eq(migrated.character,nil)
		eq(migrated.data.character.appearanceEnabled,false);eq(schema.migrate(migrated),migrated);eq(schema.validate(migrated,1),true)
		eq(plainSchema.new(1,1000).data.character.appearance,nil)
	end)
	test("appearance migration maps only existing legacy ancestry without rewriting it",function()
		local d=data();d.character.appearance=nil;d.character.appearanceRevision=nil;d.character.appearanceEnabled=nil;d.character.raceId="Orc";local before=strip(d)
		eq(service.migrate(d),true);eq(d.character.appearance.raceId,"ORC");eq(d.character.raceId,"Orc");eq(strip(d),before);eq(d.character.appearanceEnabled,false)
	end)
	test("appearance migration refuses malformed extension before partial mutation",function()
		local d=data();d.character.appearance=nil;d.character.appearanceRevision=nil;d.character.appearanceEnabled=nil;d.adventurers["h:1"]={appearance={appearanceVersion=900},appearanceRevision=0};local before=Util.copy(d)
		eq(service.migrate(d),false);eq(d,before)
	end)
	test("appearance schema rejects corrupted stored selection and noncanonical alias",function()
		local record=schema.new(1,1000);record.data.character.appearance.headPresetId="HEAD_HUMAN_01";eq(schema.validate(record,1),false)
		record=schema.new(1,1000);record.data.character.appearance.bodyPresetId="ORC_STANDARD";eq(schema.validate(record,1),false);eq(schema.migrate(record),nil)
	end)
	test("appearance read returns an independent default without opting actor in",function()
		local actor: any={raceId="Human"};local s,revision,enabled=service.read(actor);s.outfitSlots={};eq(revision,0);eq(enabled,false);eq(actor.appearance,nil);eq(service.read(actor),selection())
	end)
	test("appearance dispatcher changes no gameplay even if injury healing is due",function()
		local record=schema.new(1,1000);record.data.adventurers.hero={condition="Injured",injuredUntil=500};local before=strip(record.data)
		local commands=require("../src/server/Systems/Commands")({Util=Util,Protocol=Protocol,Appearance=service});local candidate,result,events=commands.apply(record,wire(),1000)
		eq(result.code,"OK");eq(result.appearanceActorId,"player");eq(result.appearanceRevision,1);eq(#events,1);eq(strip(candidate.data),before);eq(record.data.character.appearanceRevision,0)
		commands=require("../src/server/Systems/Commands")({Util=Util,Protocol=Protocol});local absent,outcome=commands.apply(record,wire(),1000);eq(absent,nil);eq(outcome.code,"AppearanceUnavailable")
	end)
	test("appearance active expedition heroes cannot change their saved visual identity",function()
		local d=data();d.adventurers["h:1"]={id="h:1",name="Existing Hero"};d.quests.active={state="Running",partySnapshot={{id="h:1",raceId="Orc",level=20}}};local before=Util.copy(d)
		local args=wire().args;args.actorId="h:1";eq(service.apply(d,args,function()end),"HeroUnavailable");eq(d,before)
	end)
	test("appearance durable commit replay increments revisions only once",function()
		local h=harness();local before=strip(h.record().data);local command=h.command();eq(h.service.Execute(1,command),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
		eq(h.record().data.character.appearanceRevision,1);eq(h.record().revision,1);eq(h.record().operations.lastCommittedSequence,1);eq(#h.record().audit.outbox,1);eq(strip(h.record().data),before)
	end)
	test("appearance uncertain pre-write failure retains old local state and retry commits once",function()
		local h=harness();local before=Util.copy(h.record());local command=h.command();h.mode="before";eq(h.service.Execute(1,command),"SavePending");eq(h.record(),before)
		h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.record().data.character.appearanceRevision,1);eq(h.service.Execute(1,command),"AlreadyCommitted");eq(#h.record().audit.outbox,1)
	end)
	test("appearance uncertain post-write replay and restart retain exact durable choice",function()
		local h=harness();local s=selection();s.skinPaletteId="SKIN_HUMAN_05";s.bodyPresetId="HUMAN_HEAVY";local command=h.command(s);h.mode="after";eq(h.service.Execute(1,command),"SavePending")
		eq(h.records["p:1"].data.character.appearanceRevision,1);eq(h.record().data.character.appearanceRevision,0)
		h.mode="ok";h.service=h.make();eq(h.service.Load(1,"appearance-session"),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted");eq(h.record().data.character.appearance,s);eq(#h.record().audit.outbox,1)
	end)
	test("appearance storage callback replay cannot duplicate receipt or revisions",function()
		local h=harness();h.callbackReplay=true;eq(h.service.Execute(1,h.command()),"OK");eq(h.record().revision,1);eq(h.record().data.character.appearanceRevision,1);eq(#h.record().audit.outbox,1)
	end)
	test("appearance request conflicts stale profile and actor revisions cannot overwrite selection",function()
		local h=harness();local command=h.command();eq(h.service.Execute(1,command),"OK");local conflict=Util.copy(command);conflict.args.selection.skinPaletteId="SKIN_HUMAN_01";eq(h.service.Execute(1,conflict),"RequestConflict")
		conflict.requestId="appearance:2";eq(h.service.Execute(1,conflict),"StaleRevision");conflict.revision=h.record().revision;eq(h.service.Execute(1,conflict),"AppearanceRevisionConflict");eq(h.record().data.character.appearance,selection())
	end)
	test("appearance rejected ownership and storage rollback preserve all profile data",function()
		local h=harness();local before=Util.copy(h.record());local command=h.command();command.args.actorId="h:foreign";eq(h.service.Execute(1,command),"AppearanceActorNotOwned");eq(h.record(),before)
		command=h.command();command.args.selection.outfitSlots.WEAPON="ACC_TESTWEAPON_SWORD_01";eq(h.service.Execute(1,command),"GameplayEquipmentSlot");eq(h.record(),before)
	end)
	test("appearance lease loss cannot commit over a newer owner",function()
		local h=harness();local before=strip(h.record().data);h.records["p:1"].session.ownerToken="foreign-session";eq(h.service.Execute(1,h.command()),"LeaseLost");eq(strip(h.records["p:1"].data),before);eq(h.records["p:1"].data.character.appearanceRevision,0)
	end)
	test("appearance committed storage survives post-commit notification failures",function()
		local h=harness();h.analyticsFailure=true;local command=h.command();eq(h.service.Execute(1,command),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted");eq(h.record().data.character.appearanceRevision,1);eq(h.service.Sessions[1].busy,false)
	end)
end
