--!strict
local Util = require("../src/shared/Util/TableUtil")
local Content = require("../src/server/Config/Content")
local Config = require("../src/server/Config/Runtime")
local Protocol = require("../src/shared/Network/Protocol")
local Localization = require("../src/shared/Config/Localization")
local ValidateContent = require("../src/server/Systems/ContentValidator")
local Expansion=require("../src/shared/Data/Expansion")
local LandPlacement=require("../src/shared/Data/LandBuildingPlacement")(Expansion,require("../src/shared/Data/IslandPlacement"),require("../src/shared/Config/GuildIslandLayout"))
local BuildingThemes=require("../src/shared/Data/BuildingThemeRights")(require("../src/shared/Config/BuildingThemes"))
local ValidateExpansion=require("../src/server/Systems/ExpansionSchema")(Content, Util, Expansion,LandPlacement,BuildingThemes)
local StatusPoints=require("../src/shared/Data/StatusPoints")
local Gear = require("../src/shared/Data/Equipment")(Content,Expansion,StatusPoints)
local LegacySchema = require("../src/server/Systems/ProfileSchema")(Content, Util, Gear, Expansion, ValidateExpansion)
local MarketConfig=require("../src/server/Config/Market")
local MarketEscrow=require("../src/server/Systems/MarketEscrow")(MarketConfig,Util,Content,require("../src/server/Systems/MarketOrders")(MarketConfig,Util))
local GuildLand=require("../src/shared/Data/GuildLand")(require("../src/server/Config/GuildLand"))
local Schema = require("../src/server/Systems/ProfileSchema")(Content, Util, Gear, Expansion, ValidateExpansion,MarketEscrow,GuildLand)
local Economy = require("../src/server/Services/EconomyService")(Content, Util)
local Progression = require("../src/server/Systems/Progression")(Content, Gear)
local CombatConfig=require("../src/server/Config/Combat")
for id,ability in pairs(Expansion.Abilities) do CombatConfig.Abilities[id]=ability end
local CombatRewards=require("../src/server/Systems/CombatRewards")(Content,CombatConfig,Util,Economy,require("../src/server/Config/AdventureRewards"))
local ExpansionService=require("../src/server/Services/ExpansionService")(Content,Util,Economy,Expansion,LandPlacement,BuildingThemes)
local Commands = require("../src/server/Systems/Commands")({ Content=Content, Status=require("../src/server/Services/StatusPointService")(Content,StatusPoints,Expansion), GuildLand=require("../src/server/Services/GuildLandService")(GuildLand), Dispatch=require("../src/server/Services/DispatchService")(Content,Economy,Util), Settlement=require("../src/server/Services/SettlementService")(Content,Economy,Util), Expansion=ExpansionService, Protocol = Protocol, Util = Util, Progression = Progression,
	Equipment = require("../src/server/Services/EquipmentService")(Content, Economy, Gear),
	Character = require("../src/server/Systems/PlayerCharacter")(Content),
	Adventurers = require("../src/server/Services/AdventurerService")(Content, Economy, Util),
	Party = require("../src/server/Services/PartyService")(Content.Limits.Party),
	Quests = require("../src/server/Services/QuestService")(Content, Economy, Progression, Util),
	Guild = require("../src/server/Services/PersonalGuildService")(Content, Economy) })
local MakeService = require("../src/server/Services/PlayerDataService")
local passed = 0
local function test(name: string, callback: any)
	local ok, problem = pcall(callback)
	assert(ok, name .. ": " .. tostring(problem))
	passed += 1
	print("PASS " .. name)
end
local function eq(actual: any, expected: any)
	assert(Util.equal(actual, expected), "expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
test("companion intent accepts only bounded actor IDs and server-derived actions",function()
 local input=require("../src/server/Systems/PlayerCombatInput")
 eq(input.valid({action="Ability2",actorId="h:1"}),true);eq(input.valid({action="Basic"}),true)
 eq(input.valid({action="Ability3",actorId="a:Warrior"}),true)
 eq(input.valid({action="Ability1",actorId=""}),false);eq(input.valid({action="Ability1",actorId=1}),false)
 eq(input.valid({action="Ability1",actorId=string.rep("a",65)}),false)
 for _,key in ipairs({"target","damage","position","cooldown","owner","abilityId"}) do
  local packet: any={action="Ability1",actorId="h:1"};packet[key]=1;eq(input.valid(packet),false)
 end
 eq(input.valid({action="Ability4",actorId="h:1"}),false)
end)
test("v2 preview Hall and point boundaries preserve maximums",function()
 local p=require("../src/server/Systems/ProgressionV2Preview")(Content,Expansion)
 eq(p.RuntimeEnabled,false);eq(p.hallCap(0),10);eq(p.hallCap(1),20);eq(p.hallCap(4),35);eq(p.hallCap(11),70)
 for hall=17,20 do eq(p.hallCap(hall),100) end
 for level=1,100 do local sp,ap=p.budget(level);eq(sp,level-1);eq(ap,3*(level-1)) end
 for _,hall in ipairs({-1,21,1.5,math.huge}) do eq(pcall(p.hallCap,hall),false) end
 eq(pcall(p.budget,0/0),false)
end)
test("v2 status allocation rejects invalid keys overspend and nonfinite points",function()
 local p=require("../src/server/Systems/ProgressionV2Preview")(Content,Expansion)
 local ok,code,left=p.validateStatus(10,{STR=16,VIT=8,DEX=3});eq(ok,true);eq(code,nil);eq(left,0)
 eq(p.validateStatus(10,{STR=28}),false);eq(p.validateStatus(100,{STR=151}),false)
 eq(p.validateStatus(100,{Luck=1}),false);eq(p.validateStatus(100,{STR=-1}),false)
 eq(p.validateStatus(100,{STR=.5}),false);eq(p.validateStatus(100,{STR=0/0}),false)
 eq(p.effectiveStat(40),40);eq(p.effectiveStat(80),64);eq(p.effectiveStat(150),85)
end)
test("v2 gates require sequential solo trials and earned Hall",function()
 local p=require("../src/server/Systems/ProgressionV2Preview")(Content,Expansion)
 eq(p.canPromote(9,0,1,true),false);eq(p.canPromote(10,0,1,false),false);eq(p.canPromote(10,0,1,true),true)
 eq(p.canPromote(34,1,2,true),false);eq(p.canPromote(35,1,2,true),true)
 eq(p.canPromote(70,1,3,true),false);eq(p.canPromote(70,2,3,true),true);eq(p.canPromote(100,3,4,true),false)
 eq(p.canRecruit(0,1,true),false);eq(p.canRecruit(1,0,true),false);eq(p.canRecruit(1,1,false),false);eq(p.canRecruit(1,1,true),true)
end)
test("v2 respec preview conserves budgets repeatedly and rejects unsafe contexts",function()
 local p=require("../src/server/Systems/ProgressionV2Preview")(Content,Expansion)
 local first=p.respecPreview(35,true,false,false)
 for _=1,20 do eq(p.respecPreview(35,true,false,false),first) end
 eq(first.skillPoints,34);eq(first.statusPoints,102)
 eq(p.respecPreview(35,false,false,false),nil);eq(p.respecPreview(35,true,true,false),nil);eq(p.respecPreview(35,true,false,true),nil)
end)
test("v2 migration report never mutates saves or demotes legacy promotions",function()
 local p=require("../src/server/Systems/ProgressionV2Preview")(Content,Expansion)
 local data=Schema.new(99,100).data
 data.character.classId="Warrior";data.character.level=32;data.character.xp=12345
 data.expansion.actors.player={tier=2,path="berserker",skills={vitality=true}}
 data.adventurers["h:1"]={id="h:1",classId="Priest",level=3,xp=22}
 local before=Util.copy(data);local report=p.migrationReport(data)
 eq(data,before);eq(report.appliesChanges,false);eq(report.actors[1].preservedLevel,32);eq(report.actors[1].preservedXP,12345)
 eq(report.actors[1].preservedTier,2);eq(report.actors[1].preservedPath,"berserker");eq(report.actors[1].retainLevelAboveCap,true)
 eq(report.actors[2].proposedHeroUplift,10);eq(report.actors[2].skillBudgetAtSavedLevel,2)
 eq(p.migrationReport(data),report);eq(data,before)
end)
test("v2 migration preserves high Halls and quarantines unknown builds",function()
 local p=require("../src/server/Systems/ProgressionV2Preview")(Content,Expansion)
 local data=Schema.new(99,100).data;data.personalGuild.buildings.guildHall=20
 data.character.classId="Priest";data.character.level=100;data.character.xp=9999
 data.expansion.actors.player={tier=2,path="oracle",skills={vitality=true}}
 local report=p.migrationReport(data);eq(report.hallLevel,20);eq(report.actors[1].preservedTier,2);eq(report.actors[1].preservedPath,"oracle")
 data.expansion.actors.player.path="invented";eq(p.migrationReport(data).actors[1].quarantine,true)
 data.expansion.actors.player={tier=1,skills={fake=true}};eq(p.migrationReport(data).actors[1].quarantine,true)
 data.expansion.actors.player={tier=1,skills={vitality=true}};data.character.level=1;eq(p.migrationReport(data).actors[1].quarantine,true)
end)

test("enemy field guide preserves existing camp and all ten floor combat values",function()
 local profiles=require("../src/server/Systems/EnemyProfiles")(CombatConfig)
 local guide=profiles.catalog(Content)
 eq(guide.Camp.Health,135);eq(guide.Expedition.Health,12)
 for floor=1,10 do
  for index=1,4 do
   local stats,boss,name=profiles.resolve(floor,index)
   local expectedBoss=floor%5==0 and index==1
   eq(boss,expectedBoss)
   eq(stats.MaxHealth,(65+floor*18)*(if expectedBoss then 2.4 else 1))
   eq(stats.Attack,(5+floor*1.3)*(if expectedBoss then 1.5 else 1))
   eq(stats.Defense,floor)
   eq(stats.AttackRange,if floor%2==0 and not expectedBoss then 18 else 5)
   eq(stats.MoveSpeed,if floor%2==0 and not expectedBoss then 8 else 12)
   eq(stats.AttackInterval,if expectedBoss then 3 else 1.6)
   local display=guide.Floors[floor][if expectedBoss or floor%5~=0 then 1 else 2]
   eq(display.Name,name);eq(display.Health,stats.MaxHealth);eq(display.Attack,stats.Attack)
  end
 end
 local original=CombatConfig.Goblin.MaxHealth
 profiles.resolve(10,1).MaxHealth=1
 eq(CombatConfig.Goblin.MaxHealth,original)
 local project=require("../src/server/Systems/ViewProjection")(Content,Progression,Util,Expansion,guide)
 guide.Camp.Health=0
 eq(project(nil,"test",1000).catalog.Bestiary.Camp.Health,135)
end)
local function harness(schemaOverride:any?,noviceStory:any?,campaign:any?,permanentEntitlements:any?): any
	local h: any = { now = 1000, records = {}, audit = {}, mode = "ok", notifications = 0, serial = 0 }
	local store = { Update = function(key: string, transform: any, _userId: number?): any
		if h.mode == "before" then error("Injected unavailable before write") end
		if h.replayCallback then transform(Util.copy(h.records[key])) end
		local value = transform(Util.copy(h.records[key]))
		if value then h.records[key] = Util.copy(value) end
		if h.mode == "after" then error("Injected lost response after write") end
		return Util.copy(value)
	end }
	local archive = { Update = function(key: string, transform: any, _userId: number?): any
		if h.auditFailure then error("Injected archive failure") end
		local value = transform(Util.copy(h.audit[key])); h.audit[key] = Util.copy(value); return value
	end }
	function h.make()
		return MakeService({ PermanentEntitlements=permanentEntitlements,Campaign=campaign,NoviceStory=noviceStory, MarketEscrow=MarketEscrow, Util = Util, Content = Content, Config = Config, Schema = schemaOverride or Schema, Protocol = Protocol, CombatRewards = CombatRewards, Expansion=ExpansionService,
			Commands = if noviceStory then require("../src/server/Systems/Commands")({Guild=require("../src/server/Services/PersonalGuildService")(Content,Economy,campaign~=nil),Campaign=campaign,Content=Content,NoviceStory=noviceStory,Protocol=Protocol,Util=Util,Progression=Progression,Settlement=require("../src/server/Services/SettlementService")(Content,Economy,Util)}) else Commands, Store = store, AuditStore = archive, Now = function() return h.now end,
			Wait = function(_seconds: number) end, Jitter = function() return 0 end,
			Log = function(_name: string, _fields: any) end,
			OnCommitted = function(_userId: number, _events: any)
				if h.analyticsFailure then error("Injected analytics outage") end
				h.notifications += 1
			end })
	end
	h.service = h.make()
	function h.command(action: string, args: any?): any
		h.serial += 1
		local s = h.service.Sessions[1]
		return { version = 1, requestId = "r" .. tostring(h.serial), action = action, revision = if s and s.record then s.record.revision else 0, args = args or {} }
	end
	function h.send(action: string, args: any?): (string, any)
		return h.service.Execute(1, h.command(action, args))
	end
	function h.data(): any return h.service.Sessions[1].record.data end
	function h.setup()
		eq(h.service.Load(1, "session-a"), "OK")
		eq(h.send("BeginTutorial"), "OK")
		eq(h.send("Recruit", { classId = "Warrior" }), "OK")
		eq(h.send("UpdateParty", { adventurerIds = { "a:Warrior" } }), "OK")
	end
	function h.quest(id: string)
		eq(h.send("StartQuest", { questId = id }), "OK")
		h.now = h.data().quests.active.completeAt
		eq(h.send("CompleteQuest", { runId = h.data().quests.active.runId }), "OK")
	end
	return h
end

test("exact catalogs and references", function() eq(ValidateContent(Content, Util), true) end)
test("Thai translation coverage and interpolation preserve every placeholder", function()
	local function placeholders(value: string): any
		local result = {}; for name in string.gmatch(value, "{([%w_]+)}") do result[name] = true end; return result
	end
	for english, thai in pairs(Localization.Thai) do
		assert(#thai > 0); eq(placeholders(english), placeholders(thai))
	end
	for _, group in ipairs({ Content.Items, Content.Quests, Content.Adventurers, Content.Enemies }) do
		for _, definition in pairs(group) do
			assert(Localization.Thai[definition.Name], definition.Name)
			if definition.Description then assert(Localization.Thai[definition.Description], definition.Description) end
		end
	end
	eq(Localization.translate("th", "{amount} Gold", { amount = 30 }), "30 ทอง")
	eq(Localization.translate("en", "{amount} Gold", { amount = 30 }), "30 Gold")
end)
test("language preference persists without changing progression and rejects unsupported input", function()
	local h = harness(); h.setup(); local before = Util.copy(h.data())
	eq(h.send("SetLanguage", { language = "th" }), "OK")
	before.settings.language = "th"; eq(h.data(), before)
	eq(h.send("SetLanguage", { language = "fr" }), "InvalidRequest")
	eq(h.send("SetLanguage", { language = "en", gold = 10 }), "InvalidRequest")
	eq(h.service.Close(1), "OK"); h.service = h.make(); eq(h.service.Load(1, "thai-rejoin"), "OK")
	eq(h.data().settings.language, "th"); eq(h.send("SetLanguage", { language = "en" }), "OK")
	eq(h.data().settings.language, "en")
end)
test("v1 profile without optional language remains valid and projects English", function()
	local record = Schema.new(1, 1000); record.data.settings.language = nil
	eq(Schema.validate(record, 1), true)
	local project = require("../src/server/Systems/ViewProjection")(Content, Progression, Util)
	eq(project({ state = "Active", record = record }, "test", 1000).data.language, "en")
	record.data.settings.language = "bad"; eq(Schema.validate(record, 1), false)
end)
test("duplicate item, quest, and adventurer IDs rejected", function()
	for _, key in ipairs({ "Items", "Quests", "Adventurers" }) do
		local copy = Util.copy(Content); local _, entry = next(copy[key]); entry.Id = "invalid"
		eq(pcall(ValidateContent, copy, Util), false)
	end
end)
test("dangling reward and equipment references rejected", function()
	local copy = Util.copy(Content); copy.Quests.trail_watch.First.Items[1].Id = "missing"; eq(pcall(ValidateContent, copy, Util), false)
	copy = Util.copy(Content); copy.Adventurers.Archer.Weapon = "missing"; eq(pcall(ValidateContent, copy, Util), false)
end)
test("default profile is valid and independently allocated", function()
	local a, b = Schema.new(1, 1000), Schema.new(2, 1000); a.data.currencies.gold = 20
	eq(b.data.currencies.gold, 0); eq(Schema.validate(b, 2), true)
end)
test("malformed payloads and forged reward fields rejected", function()
	local h = harness(); h.setup()
	local badPayloads: { any } = { false, 42, "StartQuest", {}, { version = 1 } }
	for _, value in ipairs(badPayloads) do eq(Protocol.validate(value), false) end
	local c = h.command("CompleteQuest", { runId = "q:1", reward = 1000000 }); eq(h.service.Execute(1, c), "InvalidRequest")
	c = h.command("UpgradeGuildHall"); c.gold = 100; eq(Protocol.validate(c), false)
	c = h.command("StartQuest", { questId = "trail_watch" }); c.revision = 0 / 0; eq(Protocol.validate(c), false)
	c.revision = math.huge; eq(Protocol.validate(c), false)
end)
test("sparse oversized and duplicate party validation", function()
	local h = harness(); h.setup()
	eq(h.send("UpdateParty", { adventurerIds = { "a:Warrior", "a:Warrior" } }), "InvalidParty")
	eq(h.send("UpdateParty", { adventurerIds = { "a:Other" } }), "InvalidParty")
	eq(Protocol.validate(h.command("UpdateParty", { adventurerIds = { [2] = "a:Warrior" } })), false)
	eq(Protocol.validate(h.command("UpdateParty", { adventurerIds = { "a", "b", "c", "d", "e", "f" } })), false)
end)
test("invalid quest and never-started completion rejected", function()
	local h = harness(); h.setup(); eq(h.send("StartQuest", { questId = "missing" }), "InvalidQuest")
	eq(h.send("CompleteQuest", { runId = "q:1" }), "QuestNotActive")
	eq(h.send("StartQuest", { questId = "quarry_patrol" }), "QuestLocked")
end)
test("early completion and wrong run rejected without mutation", function()
	local h = harness(); h.setup(); eq(h.send("StartQuest", { questId = "trail_watch" }), "OK")
	local before = Util.copy(h.data())
	eq(h.send("CompleteQuest", { runId = "q:1" }), "QuestTooEarly"); eq(h.data(), before)
	eq(h.send("CompleteQuest", { runId = "q:500" }), "QuestNotActive"); eq(h.data(), before)
end)
test("duplicate completion and exact request replay cannot duplicate rewards", function()
	local h = harness(); h.setup(); eq(h.send("StartQuest", { questId = "trail_watch" }), "OK"); h.now += 15
	local c = h.command("CompleteQuest", { runId = "q:1" }); eq(h.service.Execute(1, c), "OK")
	eq(h.service.Execute(1, c), "AlreadyCommitted"); eq(h.data().currencies.gold, 30)
	eq(h.send("CompleteQuest", { runId = "q:1" }), "QuestNotActive"); eq(h.data().adventurers["a:Warrior"].xp, 20)
end)
test("request ID payload conflict and stale revision rejected", function()
	local h = harness(); h.setup(); local c = h.command("StartQuest", { questId = "trail_watch" }); eq(h.service.Execute(1, c), "OK")
	c.args.questId = "timber_escort"; eq(h.service.Execute(1, c), "RequestConflict")
	local stale = h.command("Recruit", { classId = "Archer" }); stale.revision = 0; eq(h.service.Execute(1, stale), "StaleRevision")
end)
test("unowned nonexistent and incompatible equipment rejected", function()
	local h = harness(); h.setup(); h.quest("trail_watch")
	eq(h.send("EquipItem", { instanceId = "missing", adventurerId = "a:Warrior" }), "ItemNotOwned")
	eq(h.send("EquipItem", { instanceId = "q:1:1", adventurerId = "a:Other" }), "AdventurerNotOwned")
	eq(h.send("Recruit", { classId = "Archer" }), "OK")
	eq(h.send("EquipItem", { instanceId = "q:1:1", adventurerId = "a:Archer" }), "IncompatibleWeapon")
	eq(h.send("EquipItem", { instanceId = "q:1:1", adventurerId = "a:Warrior" }), "OK")
end)
test("Gold never negative and invalid Hall upgrade has no effects", function()
	local h = harness(); h.setup(); local before = Util.copy(h.data())
	eq(h.send("Recruit", { classId = "Archer" }), "InsufficientGold")
	eq(h.send("UpgradeGuildHall"), "HallLocked"); eq(h.data(), before)
end)
test("complete onboarding, eight obtainable items, Hall and rejoin", function()
	local h = harness(); h.setup(); h.quest("trail_watch")
	eq(h.send("EquipItem", { instanceId = "q:1:1", adventurerId = "a:Warrior" }), "OK")
	eq(h.send("Recruit", { classId = "Archer" }), "OK"); h.quest("timber_escort")
	eq(h.send("Recruit", { classId = "Priest" }), "OK")
	eq(h.send("UpdateParty", { adventurerIds = { "a:Warrior", "a:Archer", "a:Priest" } }), "OK")
	h.quest("quarry_patrol")
	eq(Util.count(h.data().inventory.stacks), 4); eq(Util.count(h.data().inventory.equipment), 4)
	eq(h.send("UpgradeGuildHall"), "OK"); eq(h.data().currencies.gold, 10)
	eq(h.data().progression.tutorialCompleted, true)
	eq(h.send("UpgradeGuildHall"), "MissingMaterials"); eq(h.data().currencies.gold, 10)
	local expected = Util.copy(h.data()); eq(h.service.Close(1), "OK")
	eq(h.service.Load(1, "session-b"), "OK"); eq(h.data(), expected)
	eq(Schema.validate(h.service.Sessions[1].record, 1), true)
end)
test("active quest and reward snapshot survive rejoin", function()
	local h = harness(); h.setup(); h.send("StartQuest", { questId = "trail_watch" })
	local run = Util.copy(h.data().quests.active); h.service.Close(1); h.service.Load(1, "session-b")
	eq(h.data().quests.active, run); h.now = run.completeAt
	eq(h.send("CompleteQuest", { runId = run.runId }), "OK")
	eq(h.data().currencies.gold, run.rewardSnapshot.Gold)
end)
test("full inventory blocks all reward components atomically", function()
	local h = harness(); h.setup(); h.send("StartQuest", { questId = "trail_watch" }); h.now += 15
	for index = 1, 50 do h.service.Sessions[1].record.data.inventory.equipment["test:" .. index] = { definitionId = "training_sword", upgradeLevel = 0, binding = "Account" } end
	local before = Util.copy(h.data()); eq(h.send("CompleteQuest", { runId = "q:1" }), "InventoryFull"); eq(h.data(), before)
end)
test("failed load never writes defaults", function()
	local h = harness(); h.mode = "before"; eq(h.service.Load(1, "session-a"), "StorageUnavailable")
	eq(h.records["p:1"], nil); h.mode = "ok"; eq(h.service.Load(1, "session-a"), "OK")
end)
test("unknown acquisition retries same token without changing epoch", function()
	local h = harness(); h.mode = "after"; eq(h.service.Load(1, "session-a"), "StorageUnavailable")
	eq(h.records["p:1"].session.epoch, 1); h.mode = "ok"; eq(h.service.Load(1, "ignored-new-token"), "OK")
	eq(h.service.Sessions[1].epoch, 1)
end)
test("failed save exposes no candidate and blocks further spending", function()
	local h = harness(); h.setup(); h.mode = "before"
	eq(h.send("StartQuest", { questId = "trail_watch" }), "SavePending")
	eq(h.data().quests.active, nil); eq(h.send("Recruit", { classId = "Archer" }), "SavePending")
	h.mode = "ok"; eq(h.service.Refresh(1), "OK"); eq(h.data().quests.active.runId, "q:1")
end)
test("write committed with lost response recovers without duplicate reward", function()
	local h = harness(); h.setup(); h.send("StartQuest", { questId = "trail_watch" }); h.now += 15; h.mode = "after"
	eq(h.send("CompleteQuest", { runId = "q:1" }), "SavePending")
	eq(h.data().currencies.gold, 0); eq(h.records["p:1"].data.currencies.gold, 30)
	h.mode = "ok"; eq(h.service.Refresh(1), "OK"); eq(h.data().currencies.gold, 30)
	eq(h.send("CompleteQuest", { runId = "q:1" }), "QuestNotActive")
end)
test("server crash after uncertain commit restores committed value", function()
	local h = harness(); h.setup(); h.send("StartQuest", { questId = "trail_watch" }); h.now += 15; h.mode = "after"
	h.send("CompleteQuest", { runId = "q:1" }); h.now += 181; h.mode = "ok"; h.service = h.make()
	eq(h.service.Load(1, "new-server"), "OK"); eq(h.data().currencies.gold, 30)
	eq(h.send("CompleteQuest", { runId = "q:1" }), "QuestNotActive")
end)
test("two servers, lease takeover and stale writer after release", function()
	local h = harness(); h.setup(); local other = h.make()
	eq(other.Load(1, "session-b"), "ProfileInUse"); h.now += 181
	eq(other.Load(1, "session-b"), "OK"); eq(other.Close(1), "OK")
	eq(h.service.Refresh(1), "LeaseLost"); eq(h.send("StartQuest", { questId = "trail_watch" }), "LeaseLost")
end)
test("closing during save preserves committed progression", function()
	local h = harness(); h.setup(); h.mode = "after"; h.send("StartQuest", { questId = "trail_watch" })
	eq(h.service.Close(1), "SavePending"); h.mode = "ok"; eq(h.service.Close(1), "OK")
	eq(h.service.Load(1, "next"), "OK"); eq(h.data().quests.active.runId, "q:1")
end)
test("archive failure retains evidence and successful retry drains once", function()
	local h = harness(); h.setup(); local count = #h.service.Sessions[1].record.audit.outbox
	h.auditFailure = true; eq(h.service.FlushAudit(1), "AuditUnavailable")
	eq(#h.service.Sessions[1].record.audit.outbox, count)
	h.auditFailure = false; eq(h.service.FlushAudit(1), "OK"); eq(h.service.FlushAudit(1), "OK")
	eq(Util.count(h.audit["p:1:0"].events), count); eq(#h.service.Sessions[1].record.audit.outbox, 0)
end)
test("corrupt and future-version data preserved without reset", function()
	for _, raw in ipairs({ { schemaVersion = 99 }, { schemaVersion = 1, data = false } }) do
		local h = harness(); h.records["p:1"] = Util.copy(raw)
		local status = h.service.Load(1, "session-a"); assert(status ~= "OK"); eq(h.records["p:1"], raw)
	end
end)
test("explicit migration is additive and repeatable", function()
	local original = Schema.new(1, 1000); original.schemaVersion = 1; original.data.character = nil
	local steps = { [1] = function(record: any) record.schemaVersion = 2; record.example = true; return record end }
	local migrated = Schema.migrate(original, 2, steps)
	eq(migrated.schemaVersion, 2); eq(migrated.data, original.data); eq(original.schemaVersion, 1)
	eq(Schema.migrate(migrated, 2, steps), migrated)
end)
test("semantic replay survives recent-result eviction", function()
	local h = harness(); h.setup(); h.quest("trail_watch")
	for _ = 1, 40 do h.send("UpdateParty", { adventurerIds = { "a:Warrior" } }); h.service.FlushAudit(1) end
	eq(#h.service.Sessions[1].record.operations.recentResults, 32)
	eq(h.send("CompleteQuest", { runId = "q:1" }), "QuestNotActive"); eq(h.data().currencies.gold, 30)
end)
test("rerun UpdateAsync callback produces one reward and one committed event batch", function()
	local h = harness(); h.replayCallback = true; h.setup(); local before = h.notifications
	h.quest("trail_watch"); eq(h.data().currencies.gold, 30); eq(h.notifications - before, 2)
	eq(h.data().statistics.questsCompleted, 1)
end)
test("analytics failure cannot strand a committed save", function()
	local h = harness(); h.setup(); h.analyticsFailure = true; h.quest("trail_watch")
	eq(h.data().currencies.gold, 30); eq(h.service.Sessions[1].busy, false)
	eq(h.service.Sessions[1].state, "Active")
end)
test("partial-fill item capacity rejection does not consume Gold or XP", function()
	local h = harness(); h.setup(); h.send("StartQuest", { questId = "trail_watch" }); h.now += 15
	h.service.Sessions[1].record.data.inventory.stacks.herb = Content.Limits.Stack
	local before = Util.copy(h.data()); eq(h.send("CompleteQuest", { runId = "q:1" }), "InventoryFull"); eq(h.data(), before)
end)
test("repeated completed runs use repeat rewards and never duplicate first-clear weapon", function()
	local h = harness(); h.setup(); h.quest("trail_watch"); h.quest("trail_watch")
	eq(h.data().currencies.gold, 40); eq(Util.count(h.data().inventory.equipment), 1)
	eq(h.data().quests.claimedThrough, 2); eq(h.data().inventory.stacks.timber, 1)
end)
test("audit capacity pauses admission without destroying history", function()
	local h = harness(); h.setup()
	for _ = 1, 150 do h.send("UpdateParty", { adventurerIds = { "a:Warrior" } }) end
	eq(#h.service.Sessions[1].record.audit.outbox, Content.Limits.Audit)
	eq(h.send("UpdateParty", { adventurerIds = { "a:Warrior" } }), "AuditBacklog")
	eq(h.service.FlushAudit(1), "OK"); eq(h.send("UpdateParty", { adventurerIds = { "a:Warrior" } }), "OK")
end)
test("lease safety margin blocks mutation before expiry and heartbeat restores admission", function()
	local h = harness(); h.setup(); h.now += Config.LeaseSeconds - Config.LeaseSafetySeconds
	eq(h.send("StartQuest", { questId = "trail_watch" }), "LeaseExpiring")
	eq(h.service.Refresh(1), "OK"); eq(h.send("StartQuest", { questId = "trail_watch" }), "OK")
end)
test("owned weapon shortens only the next expedition and snapshots party", function()
	local h = harness(); h.setup(); h.quest("trail_watch"); h.send("EquipItem", { instanceId = "q:1:1", adventurerId = "a:Warrior" })
	h.send("StartQuest", { questId = "timber_escort" })
	eq(h.data().quests.active.completeAt - h.now, 24)
	eq(h.send("UpdateParty", { adventurerIds = { "a:Warrior" } }), "QuestActive")
end)
test("deterministic adversarial command sequence preserves profile invariants", function()
	local h = harness(); h.setup()
	local actions = { "BeginTutorial", "Recruit", "UpdateParty", "StartQuest", "CompleteQuest", "UpgradeGuildHall", "EquipItem" }
	for index = 1, 400 do
		local action = actions[(index * 13) % #actions + 1]
		local args: any = {}
		if action == "Recruit" then args.classId = Content.AdventurerOrder[index % #Content.AdventurerOrder + 1]
		elseif action == "UpdateParty" then args.adventurerIds = { "a:Warrior" }
		elseif action == "StartQuest" then args.questId = Content.QuestOrder[index % 3 + 1]
		elseif action == "CompleteQuest" then args.runId = if h.data().quests.active then h.data().quests.active.runId else "q:1"
		elseif action == "EquipItem" then args.instanceId = "q:1:1"; args.adventurerId = "a:Warrior" end
		h.send(action, args); h.now += 2; h.service.FlushAudit(1); h.service.Refresh(1)
		eq(Schema.validate(h.service.Sessions[1].record, 1), true)
		assert(h.data().currencies.gold >= 0)
	end
end)
test("five-member roster and active snapshot survive commit and rejoin", function()
	local h=harness(); h.setup(); h.quest("trail_watch"); h.quest("timber_escort"); h.quest("quarry_patrol")
	local ids={}
	for _,class in ipairs(Content.AdventurerOrder) do
		if class~="Warrior" then eq(h.send("Recruit",{classId=class}),"OK") end
		table.insert(ids,"a:"..class)
	end
	eq(Protocol.MaxPartySize,Content.Limits.Party)
	eq(h.send("UpdateParty",{adventurerIds=ids}),"OK")
	eq(h.send("EquipItem",{instanceId="recruit:Knight:1",adventurerId="a:Knight"}),"OK")
	eq(h.send("EquipItem",{instanceId="recruit:Mage:1",adventurerId="a:Mage"}),"OK")
	eq(h.send("EquipItem",{instanceId="recruit:Knight:1",adventurerId="a:Mage"}),"IncompatibleWeapon")
	eq(h.send("StartQuest",{questId="trail_watch"}),"OK")
	eq(#h.data().quests.active.partySnapshot,5)
	local saved=Util.copy(h.data()); eq(h.service.Close(1),"OK"); h.service=h.make(); eq(h.service.Load(1,"five-rejoin"),"OK")
	eq(h.data(),saved); eq(Schema.validate(h.service.Sessions[1].record,1),true)
	h.now=h.data().quests.active.completeAt
	eq(h.send("CompleteQuest",{runId=h.data().quests.active.runId}),"OK")
	for _,class in ipairs({"Knight","Mage","Archer","Priest"}) do eq(h.data().adventurers["a:"..class].xp,5) end
	local six=Util.copy(ids); table.insert(six,"a:Sixth")
	eq(h.send("UpdateParty",{adventurerIds=six}),"InvalidRequest")
end)
test("hero presentation follows only committed owned members and equipped weapons", function()
	local h=harness(); h.setup(); h.quest("trail_watch"); h.send("Recruit",{classId="Archer"})
	local project=require("../src/server/Systems/ViewProjection")(Content,Progression,Util)
	local present=require("../src/server/Systems/HeroPresentation")(Content,Gear)
	local function read() return present(project(h.service.Sessions[1],"test",h.now).data) end
	local before=Util.copy(h.data()); local heroes=read()
	eq(#heroes,5); eq(heroes[1].state,"Following"); eq(heroes[1].weapon,nil)
	eq(heroes[2].state,"Resting at guild"); eq(heroes[3].state,"Available"); eq(h.data(),before)
	h.send("EquipItem",{instanceId="q:1:1",adventurerId="a:Warrior"}); eq(read()[1].weapon,"training_sword")
	h.send("StartQuest",{questId="timber_escort"}); eq(read()[1].state,"On expedition"); eq(read()[2].state,"Resting at guild")
	h.now=h.data().quests.active.completeAt; h.send("CompleteQuest",{runId=h.data().quests.active.runId}); eq(read()[1].state,"Following")
end)
test("legacy content snapshots remain valid with additive class expansion", function()
	local h=harness(); h.setup(); h.send("StartQuest",{questId="trail_watch"})
	local record=Util.copy(h.service.Sessions[1].record); record.contentVersion="slice-1.0"; record.data.quests.active.contentVersion="slice-1.0"
	eq(Schema.validate(record,1),true)
	local migrated,code=Schema.migrate(record); eq(code,"OK"); eq(migrated,record)
	for _,key in ipairs({"Knight","Mage","Tank","Magic","Following","Available","On expedition","Resting at guild"}) do assert(Localization.Thai[key]) end
end)
require("./boss_patterns")(test,eq)
require("./adventure_patterns")(test,eq)
require("./adventure_brain")(test,eq)
require("./adventure_lifecycle")(test,eq)
require("./adventure_reward_adapter")(test,eq,harness,Util)
require("./regional_contracts")(test,eq,harness,Util,Content)
require("./civic_envoys")(test,eq,harness,Util,Content)
require("./adventure_evasion")(test,eq)
require("./adventure_field_guide")(test,eq)
require("./hero_templates")(test,eq)
require("./combat_bindings")(test,eq)
require("./combat_hud_layout")(test,eq)
require("./audio_budget")(test,eq)
require("./music_transition")(test,eq)
require("./guild_land")(test,eq)
require("./permanent_passes")(test,eq,harness,Util,Schema,Protocol)
require("./island_placement")(test,eq)
require("./guild_land_integration")(test,eq,harness,Util,Schema,GuildLand,Content,Progression)
require("./building_storage")(test,eq,harness,Util,Schema)
require("./building_layouts")(test,eq,harness,Util,Schema)
require("./building_themes")(test,eq,harness,Util,Schema,Content,Progression)
require("./hall_placement")(test,eq,harness,Util,Schema)
require("./furniture")(test,eq,harness,Util,Schema)
require("./land_building_placement")(test,eq)
require("./island_access")(test,eq)
require("./combat_space")(test,eq)
require("./request_window")(test,eq)
require("./quest_tracker")(test,eq)
require("./island_directory_state")(test,eq)
require("./guild_identity_summary")(test,eq)
require("./player_guild_membership")(test,eq)
require("./player_guild_recovery")(test,eq)
require("./player_guild_roster")(test,eq)
require("./player_guild_schema")(test,eq)
require("./player_guild_coordinator")(test,eq)
require("./player_guild_removal")(test,eq)
require("./player_guild_founder")(test,eq)
require("./player_guild_operations")(test,eq)
require("./player_guild_store")(test,eq)
require("./journal_view_state")(test,eq)
require("./quest_npc_state")(test,eq)
require("./city_waypoint")(test,eq)
require("./tavern_view_state")(test,eq)
require("./crafting_view_state")(test,eq)
require("./novice_story")(test,eq,harness)
require("./novice_trials")(test,eq)
require("./novice_trial_combat")(test,eq)
require("./novice_receipt_adapter")(test,eq)
require("./novice_trial_manager")(test,eq)
require("./novice_trial_input")(test,eq)
require("./novice_lessons")(test,eq)
require("./archive_story_memory")(test,eq)
require("./civic_work_motion")(test,eq)
require("./archive_ending_motion")(test,eq)
require("./campaign_conclusion")(test,eq)
require("./campaign")(test,eq,harness)
require("./campaign_continuation")(test,eq)
require("./ashen_campaign")(test,eq)
require("./tower_campaign")(test,eq)
require("./crosshaven_campaign")(test,eq)
require("./archive_heart_campaign")(test,eq)
require("./archive_heart_encounters")(test,eq)
require("./archive_heart_combat")(test,eq)
require("./tower_lessons")(test,eq)
require("./tower_guardian")(test,eq)
require("./region_annexes")(test,eq)
require("./escort_run")(test,eq)
require("./ironveil_tasks")(test,eq)
require("./borrowed_paths")(test,eq)
require("./borrowed_mastery")(test,eq)
require("./progression_rulesets")(test,eq,harness,{Content=Content,Util=Util,Schema=Schema,Gear=Gear,Expansion=Expansion,ValidateExpansion=ValidateExpansion,MarketEscrow=MarketEscrow,GuildLand=GuildLand,Economy=Economy,Progression=Progression,CombatConfig=CombatConfig,ExpansionService=ExpansionService})
require("./combat")(test,eq,harness,Util,Content,CombatConfig,Protocol,Schema,Localization)
require("./player_character")(test,eq,harness,Util,Content,CombatConfig,Schema)
require("./equipment")(test,eq,harness,Util,Content,Schema,Gear,Progression)
require("./status_points")(test,eq,harness,Util,Content,Schema,Gear,Progression,CombatConfig)
require("./expansion")(test,eq,harness,Util,Content,Schema,Expansion,Gear,Progression,CombatConfig)
require("./settlement")(test,eq,harness,Util,Content,Schema,Economy,Progression)
require("./civic_cities")(test,eq,harness,Content,Util,Localization)
require("./city")(test,eq,harness,Util,Content,Schema,Localization,Protocol)
require("./market")(test,eq,Util,Content,LegacySchema)
require("./market_hardening")(test,eq,Util,Content,LegacySchema)
print(string.format("\n%d tests passed.", passed))
