--!strict
return function(content: any, util: any, gear: any, expansion: any?, validateExpansion: any?, market: any?, land: any?,noviceProfiles:boolean?,noviceStory:any?,campaign:any?)
	assert(not land or market,"Land schema requires market schema")
	assert(not noviceProfiles or land,"Novice schema requires full profile services")
	assert(not campaign or (noviceProfiles and noviceStory),"Campaign schema requires Novice story")
	local Schema = { Version = if noviceProfiles then 8 elseif land then 7 elseif market then 6 else 5 }
	local function character(): any
		return { definitionVersion = content.Character.Version, raceId = "Human", tier = 1, level = 1, xp = 0, equipmentSlots = {} }
	end
	function Schema.new(userId: number, now: number): any
		local record:any = {
			schemaVersion = Schema.Version, revision = 0, contentVersion = content.Version, createdAt = now, updatedAt = now,
			session = { epoch = 0, leaseExpiresAt = 0 },
			data = {
				guildLand = if land then land.new() else nil,
				market = if market then market.new() else nil,
				settlement = {tavernLevel=1,nextHero=1,nextOffer=1,journal={},jobs={},nextJob=1,elixirs=0,purchases={}}, expansion = if expansion then expansion.new() else nil, character = character(), profile = { userId = userId }, currencies = { gold = 0 }, adventurers = {},
				inventory = { stacks = {}, equipment = {}, nextEquipmentSequence = 1 }, personalGuild = { buildings = { guildHall = 1 } },
				party = { adventurerIds = {} }, progression = { welcomeSeen = false, tutorialStep = "welcome", recruitedClasses = {}, everEquipped = false, tutorialCompleted = false },
				quests = { nextRunSequence = 1, claimedThrough = 0, firstClears = {} },
				statistics = { questsCompleted = 0, goldCreated = 0, goldDestroyed = 0 },
				settings = { musicEnabled = true, reducedMotion = false, language = "en" },
			},
			operations = { lastCommittedSequence = 0, recentResults = {} },
			audit = { nextSequence = 1, exportedThrough = 0, outbox = {} },
		}
		if noviceProfiles then
			record.data.progression.ruleset=content.ProgressionRulesets.Novice
			record.data.personalGuild.buildings.guildHall=0
			if noviceStory then record.data.progression.novice=noviceStory.new() end
			if campaign then record.data.progression.campaign=campaign.new()end
		end
		return record
	end

	local steps = { welcome = true, recruit = true, party = true, quest = true, claim = true, equip = true, roster = true, supplies = true, upgrade = true, complete = true }
	local function validate(record: any, userId: number, version: number): (boolean, string)
		local ok = pcall(function()
			assert(type(record) == "table" and record.schemaVersion == version)
			assert(util.integer(record.revision, 0, 1000000000) and type(record.contentVersion) == "string")
			assert(util.integer(record.createdAt, 0, 100000000000) and util.integer(record.updatedAt, 0, 100000000000))
			assert(util.integer(record.session.epoch, 0, 1000000000) and util.integer(record.session.leaseExpiresAt, 0, 100000000000))
			assert(record.session.ownerToken == nil or type(record.session.ownerToken) == "string")
			local d = record.data
			local mode=content.ProgressionMode(d)
			if version>=8 then assert(d.progression.ruleset==content.ProgressionRulesets.Legacy or d.progression.ruleset==content.ProgressionRulesets.Novice)
			else assert(d.progression.ruleset==nil,"Ruleset marker requires schema8") end
			local novice=mode==content.ProgressionRulesets.Novice
			if d.progression.novice~=nil then assert(novice and noviceStory,"Story validator required");noviceStory.validate(d)
			elseif novice and noviceStory then error("Missing novice story") end
			if d.progression.campaign~=nil then assert(novice and campaign,"Campaign validator required");campaign.validate(d)end
			local maxLevel=if version>=5 then content.ProfileLevelCap(d) else 10
			if version>=5 then
				assert(util.count(d.adventurers)<=content.RosterCapacity(d))
				local town=d.settlement;assert(type(town)=="table" and util.integer(town.tavernLevel,1,5) and town.tavernLevel<=(if novice then math.max(1,d.personalGuild.buildings.guildHall) else d.personalGuild.buildings.guildHall))
				assert(util.integer(town.nextHero,1,1000000000) and util.integer(town.nextOffer,1,1000000000) and util.integer(town.nextJob,1,1000000000) and util.integer(town.elixirs,0,99))
				assert(util.count(town.purchases)<=1000);for id,product in pairs(town.purchases) do assert(type(id)=="string" and #id>0 and #id<=128 and util.integer(product,1,100000000000)) end
				if town.offer then
					assert(town.offer.id=="offer:"..(town.nextOffer-1) and content.Adventurers[town.offer.classId] and table.find(content.Tavern.Ranks,town.offer.rank))
					if town.offer.templateId~=nil then local template=content.HeroTemplates[town.offer.templateId];assert(template and template.Class==town.offer.classId,"Invalid offer template") end
				end
				for id,task in pairs(town.journal) do local def=content.Journal[id];assert(def and (task.state=="Active" or task.state=="Claimed") and util.integer(task.progress,0,def.Count)) end
				assert(util.count(town.jobs)<=3);local assigned={}
				for id,job in pairs(town.jobs) do
					assert(job.id==id and id:match("^job:%d+$") and tonumber(id:sub(5))<town.nextJob and content.Dispatch[job.missionId])
					assert(util.integer(job.startAt,0,100000000000) and util.integer(job.completeAt,job.startAt+1,job.startAt+3600) and util.integer(job.chance,5,100) and type(job.success)=="boolean")
					assert(#job.members>=1 and #job.members<=5 and util.count(job.members)==#job.members)
					for _,heroId in ipairs(job.members) do assert(d.adventurers[heroId] and not assigned[heroId] and not table.find(d.party.adventurerIds,heroId));assigned[heroId]=true end
					for heroId,condition in pairs(job.casualties) do assert(table.find(job.members,heroId) and (condition=="Healthy" or condition=="Injured" or condition=="Dead")) end
					assert(util.integer(job.reward.Gold,0,content.Limits.Gold) and util.integer(job.reward.XP,0,content.Limits.XP) and #job.reward.Items<=8)
					for _,item in ipairs(job.reward.Items) do assert(content.Items[item.Id] and util.integer(item.Quantity,1,100)) end
				end
			end
			if version>=4 then assert(validateExpansion);validateExpansion(d) end
			if version >= 2 then
				local c = d.character
				assert(gear.validStatus(c),"Invalid character status allocation")
				assert(c.definitionVersion == content.Character.Version and (version>=4 or (c.raceId == "Human" and c.tier == 1)))
				assert(util.integer(c.xp, 0, content.Limits.XP) and c.level == content:LevelFromXP(c.xp,maxLevel))
				if c.classId then
					local def = content.Character.Classes[c.classId]
					assert(def and (version>=4 or c.classPathId == def.PathId) and c.skillId == def.SkillId)
					if novice then assert(c.level>=10,"Class1 requires level10") end
				else
					assert(c.classPathId == nil and c.skillId == nil)
					if novice then assert(c.level<=10 and d.personalGuild.buildings.guildHall==0)
					else assert(c.xp==0 and c.level==1) end
				end
			end
			assert(d.profile.userId == userId and util.integer(d.currencies.gold, 0, content.Limits.Gold))
			assert(util.count(d.adventurers) <= content.Limits.Roster and util.count(d.inventory.equipment) <= content.Limits.Equipment)
			local classes, equipped = {}, {}
			local function slots(actor: any)
				assert(type(actor.equipmentSlots)=="table")
				for slot,id in pairs(actor.equipmentSlots) do
					assert(table.find(gear.Slots,slot) and type(id)=="string")
					local item=d.inventory.equipment[id]; local def=item and content.Items[item.definitionId]
					assert(def and def.Slot==slot and gear.compatible(def,actor.classId) and not equipped[id])
					equipped[id]=true
				end
			end
			if version>=3 then
				assert(util.integer(d.inventory.nextEquipmentSequence,1,1000000000))
				slots(d.character)
			end
			for id, adventurer in pairs(d.adventurers) do
				assert(gear.validStatus(adventurer),"Invalid hero status allocation")
				assert(type(id) == "string" and #id <= 64 and adventurer.id == id and type(adventurer.name) == "string")
				local def = content.Adventurers[adventurer.classId]
				assert(def and (version>=5 or not classes[adventurer.classId])); classes[adventurer.classId] = true
				if adventurer.templateId~=nil then
					local template=content.HeroTemplates[adventurer.templateId]
					assert(template and template.Class==adventurer.classId and adventurer.name==template.Name,"Invalid hero template")
				end
				assert(util.integer(adventurer.xp, 0, content.Limits.XP) and util.integer(adventurer.level, 1, content.Limits.Level))
				assert(adventurer.level == content:LevelFromXP(adventurer.xp,maxLevel))
				if novice then assert(adventurer.level>=10,"Novice heroes start at level10") end
				assert(util.equal(adventurer.baseStats, def.Stats))
				if version>=5 then
					assert(table.find(content.Tavern.Ranks,adventurer.rank))
					assert(id=="a:"..adventurer.classId or (id:match("^h:%d+$") and tonumber(id:sub(3))<d.settlement.nextHero))
					assert(adventurer.condition==nil or adventurer.condition=="Healthy" or adventurer.condition=="Injured" or adventurer.condition=="Dead")
					if adventurer.condition=="Injured" then assert(util.integer(adventurer.injuredUntil,0,100000000000)) end
				end
				if version>=3 then slots(adventurer) else
				local weapon = adventurer.equipmentSlots.weapon
				if weapon then
					local item = d.inventory.equipment[weapon]
					assert(item and not equipped[weapon] and content.Items[item.definitionId].Class == adventurer.classId)
					equipped[weapon] = true
				end
				end
			end
			for itemId, quantity in pairs(d.inventory.stacks) do
				assert(content.Items[itemId] and content.Items[itemId].Kind == "Material" and util.integer(quantity, 1, content.Limits.Stack))
			end
			for id, item in pairs(d.inventory.equipment) do
				assert(type(id) == "string" and #id <= 64 and (if version>=3 then content.Items[item.definitionId].Slot~=nil else content.Items[item.definitionId].Kind == "Weapon"))
				assert(item.upgradeLevel == 0 and item.binding == "Account")
			end
			local members = {}
			assert(#d.party.adventurerIds <= content.Limits.Party and util.count(d.party.adventurerIds) == #d.party.adventurerIds)
			for _, id in ipairs(d.party.adventurerIds) do assert(d.adventurers[id] and not members[id]); members[id] = true end
			assert(util.integer(d.personalGuild.buildings.guildHall,if novice then 0 else 1,if version>=5 then 20 else 2))
			assert(steps[d.progression.tutorialStep] and type(d.progression.welcomeSeen) == "boolean")
			assert(type(d.progression.everEquipped) == "boolean" and type(d.progression.tutorialCompleted) == "boolean")
			assert(util.equal(d.progression.recruitedClasses, classes))
			assert(util.integer(d.quests.nextRunSequence, 1, 1000000000) and util.integer(d.quests.claimedThrough, 0, d.quests.nextRunSequence - 1))
			for questId, cleared in pairs(d.quests.firstClears) do assert(content.Quests[questId] and cleared == true) end
			local active = d.quests.active
			if active then
				assert(content.Quests[active.questId] and active.state == "Running" and type(active.runId) == "string")
				assert(active.sequence == d.quests.nextRunSequence - 1 and active.sequence > d.quests.claimedThrough)
				assert(util.integer(active.startAt, 0, 100000000000) and util.integer(active.completeAt, active.startAt, active.startAt + 3600))
				assert(type(active.contentVersion) == "string" and type(active.firstClear) == "boolean")
				assert(#active.partySnapshot >= 1 and #active.partySnapshot <= content.Limits.Party)
				local runMembers = {}
				for _, member in ipairs(active.partySnapshot) do assert(d.adventurers[member.id] and not runMembers[member.id]); runMembers[member.id] = true end
				local reward = active.rewardSnapshot
				assert(util.integer(reward.Gold, 0, content.Limits.Gold) and util.integer(reward.XP, 0, content.Limits.XP))
				assert(#reward.Items <= 8)
				for _, item in ipairs(reward.Items) do assert(content.Items[item.Id] and util.integer(item.Quantity, 1, 100)) end
			end
			for _, total in pairs(d.statistics) do assert(util.integer(total, 0, 9007199254740991)) end
			if version>=6 then assert(market);market.validate(d.market) end
			if version>=7 then assert(land and land.validate(d.guildLand),"Invalid guild land") end
			assert(d.statistics.goldCreated - d.statistics.goldDestroyed + (if version>=6 then d.market.goldIn-d.market.goldOut else 0) == d.currencies.gold)
			assert(type(d.settings.musicEnabled) == "boolean" and type(d.settings.reducedMotion) == "boolean")
			-- Optional v1 extension: older profiles retain their data and display English.
			assert(d.settings.language == nil or d.settings.language == "en" or d.settings.language == "th")
			assert(util.integer(record.operations.lastCommittedSequence, 0, 1000000000) and #record.operations.recentResults <= content.Limits.RecentResults)
			for _, operation in ipairs(record.operations.recentResults) do
				assert(type(operation.id) == "string" and type(operation.command) == "table" and type(operation.result.code) == "string")
			end
			assert(util.integer(record.audit.nextSequence, 1, 1000000000) and util.integer(record.audit.exportedThrough, 0, record.audit.nextSequence - 1))
			assert(#record.audit.outbox <= content.Limits.Audit)
			local sequence = record.audit.exportedThrough
			for _, event in ipairs(record.audit.outbox) do
				assert(event.sequence == sequence + 1 and type(event.name) == "string" and type(event.payload) == "table")
				sequence = event.sequence
			end
			assert(sequence == record.audit.nextSequence - 1)
		end)
		return ok, if ok then "OK" else "CorruptProfile"
	end

	function Schema.validate(record: any, userId: number): (boolean, string)
		return validate(record, userId, Schema.Version)
	end
	local defaults = { [1] = function(record: any): any
		assert(validate(record, record.data.profile.userId, 1), "Corrupt legacy profile")
		assert(record.data.character == nil, "Unexpected legacy character")
		record.data.character = character(); record.data.character.equipmentSlots=nil; record.schemaVersion = 2
		return record
	end, [2] = function(record: any): any
		assert(validate(record,record.data.profile.userId,2),"Corrupt v2 profile")
		assert(record.data.character.equipmentSlots==nil and record.data.inventory.nextEquipmentSequence==nil,"Unexpected v2 equipment fields")
		record.data.character.equipmentSlots={}; record.data.inventory.nextEquipmentSequence=1; record.schemaVersion=3
		return record
	end, [3]=function(record: any): any
		assert(validate(record,record.data.profile.userId,3),"Corrupt v3 profile")
		assert(record.data.expansion==nil and expansion,"Unexpected expansion")
		record.data.expansion=expansion.new();record.schemaVersion=4;return record
	end, [4]=function(record: any): any
		assert(validate(record,record.data.profile.userId,4),"Corrupt v4 profile")
		local d=record.data;assert(d.settlement==nil,"Unexpected settlement")
		d.settlement={tavernLevel=1,nextHero=1,nextOffer=1,journal={},jobs={},nextJob=1,elixirs=0,purchases={}}
		local highest=d.character.level
		for _,hero in pairs(d.adventurers) do assert(hero.rank==nil,"Unexpected rank");hero.rank="F";highest=math.max(highest,hero.level) end
		d.personalGuild.buildings.guildHall=math.max(d.personalGuild.buildings.guildHall,math.ceil(highest/5))
		record.schemaVersion=5;return record
	end, [5]=function(record: any): any
		assert(validate(record,record.data.profile.userId,5),"Corrupt v5 profile")
		assert(record.data.market==nil and market,"Unexpected market fields")
		record.data.market=market.new();record.schemaVersion=6;return record
	end, [6]=function(record: any): any
		assert(validate(record,record.data.profile.userId,6),"Corrupt v6 profile")
		assert(record.data.guildLand==nil and land,"Unexpected guild land")
		record.data.guildLand=land.new();record.schemaVersion=7;return record
	end, [7]=function(record:any):any
		assert(noviceProfiles,"Schema8 creation disabled")
		assert(validate(record,record.data.profile.userId,7),"Corrupt v7 profile")
		-- Keep existing characters on their original XP/Hall rules. No level uplift.
		record.data.progression.ruleset=content.ProgressionRulesets.Legacy
		record.schemaVersion=8;return record
	end }
	-- Explicit additive migration; validation occurs before introducing new fields.
	function Schema.migrate(raw: any, targetVersion: number?, migrations: any?): (any, string)
		local target = targetVersion or Schema.Version
		if type(raw) ~= "table" or not util.integer(raw.schemaVersion, 1, 1000000) then return nil, "CorruptProfile" end
		if raw.schemaVersion > target then return nil, "UnsupportedVersion" end
		local copy = util.copy(raw)
		while copy.schemaVersion < target do
			local version = copy.schemaVersion
			local step = (migrations or defaults)[version]
			if not step then return nil, "MigrationMissing" end
			local ok, migrated = pcall(step, copy)
			if not ok or type(migrated) ~= "table" or migrated.schemaVersion ~= version + 1 then return nil, "MigrationFailed" end
			copy = migrated
		end
		return copy, "OK"
	end
	return Schema
end
