--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxAnalytics = game:GetService("AnalyticsService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Util = require(Shared.Util.TableUtil)
local Protocol = require(Shared.Network.Protocol)
local Content = require(script.Parent.Config.Content)
local Runtime = require(script.Parent.Config.Runtime)
local noviceEnabled=Runtime.NoviceJourney==true and RunService:IsStudio() and game.PlaceId==0 and game.GameId==0 and Runtime.StudioPersistence=="Memory"
local ironveilEnabled=noviceEnabled and Runtime.IronveilJourney==true
local ashenEnabled=ironveilEnabled and Runtime.AshenJourney==true
local towerEnabled=ashenEnabled and Runtime.TowerJourney==true
local crosshavenEnabled=towerEnabled and Runtime.CrosshavenJourney==true
local archiveHeartEnabled=crosshavenEnabled and Runtime.ArchiveHeartJourney==true
Content.RegionalCombatAvailable=RunService:IsStudio() and game.PlaceId==0 and game.GameId==0 and Runtime.StudioPersistence=="Memory"
Content.StatusAllocationAvailable=Content.RegionalCombatAvailable
Content.RecruitmentTemplatesAvailable=Content.RegionalCombatAvailable
if Runtime.PrivateAcceptance.Enabled and not RunService:IsStudio() and game.PrivateServerId=="" then
	print("[Guildborne] Private acceptance lobby: profile loading disabled")
	return -- Dedicated QA launcher (excluded from default build) owns teleport admission.
end
local acceptanceNamespace=require(script.Parent.Systems.MarketAcceptanceConfig)(Runtime.PrivateAcceptance,Runtime.AllowedDataStoreUniverses[game.GameId],RunService:IsStudio(),game.PrivateServerId~="")
require(script.Parent.Systems.ContentValidator)(Content, Util)
Util.freeze(Content)

local verbose = RunService:IsStudio() and Runtime.VerboseStudioLogs
local function log(name: string, fields: any)
	if not verbose then return end
	local safe = {}
	for _, key in ipairs({ "revision", "action", "questId", "reason", "amount", "level", "classId", "itemId", "quantity", "event" }) do
		if fields[key] ~= nil then safe[key] = fields[key] end
	end
	print("[Guildborne] " .. name .. " " .. HttpService:JSONEncode(safe))
end
local providers: { any } = {}
if Runtime.RobloxAnalyticsEnabled and not RunService:IsStudio() then
	table.insert(providers, function(name: string, _payload: any, player: Player?)
		if player then RobloxAnalytics:LogCustomEvent(player, name, 1) end
	end)
end
local Analytics = require(script.Parent.Services.AnalyticsAdapter)(providers, log)
local Expansion=require(Shared.Data.Expansion)
require(script.Parent.Systems.RecipeValidator)(Content,Expansion,Util)
local LandPlacement=require(Shared.Data.LandBuildingPlacement)(Expansion,require(Shared.Data.IslandPlacement),require(Shared.Config.GuildIslandLayout))
local BuildingThemes=require(Shared.Data.BuildingThemeRights)(require(Shared.Config.BuildingThemes))
local ValidateExpansion=require(script.Parent.Systems.ExpansionSchema)(Content, Util, Expansion,LandPlacement,BuildingThemes)
local StatusPoints=require(Shared.Data.StatusPoints)
local Gear = require(Shared.Data.Equipment)(Content,Expansion,StatusPoints)
local MarketConfig=require(script.Parent.Config.Market)
local MarketOrders=require(script.Parent.Systems.MarketOrders)(MarketConfig,Util)
local MarketEscrow=require(script.Parent.Systems.MarketEscrow)(MarketConfig,Util,Content,MarketOrders)
local MarketMatching=require(script.Parent.Systems.MarketMatching)(MarketConfig,MarketOrders)
local MarketBook=require(script.Parent.Systems.MarketBook)(MarketConfig,Util,MarketOrders,MarketMatching)
local MarketData=require(script.Parent.Systems.MarketData)(MarketConfig,Util,MarketOrders)
local GuildLand=require(Shared.Data.GuildLand)(require(script.Parent.Config.GuildLand))
local PermanentPassCatalog=require(script.Parent.Systems.PermanentPassCatalog)(require(script.Parent.Config.GuildLand),require(Shared.Config.BuildingThemes))
local PermanentEntitlements=if Runtime.PermanentPassesEnabled then require(script.Parent.Systems.PermanentEntitlements)(PermanentPassCatalog,GuildLand,BuildingThemes,Util) else nil
local PermanentPassOffers=require(script.Parent.Systems.PermanentPassOffers)(PermanentPassCatalog,GuildLand,BuildingThemes)
local Economy = require(script.Parent.Services.EconomyService)(Content, Util)
local NoviceChapter=require(script.Parent.Config.NoviceChapter)
local NoviceStory=if noviceEnabled then require(script.Parent.Services.NoviceStoryService)(Content,Util,Economy,NoviceChapter)else nil
local CampaignArcs:{any}={require(script.Parent.Config.ChapterOne)}
if ironveilEnabled then table.insert(CampaignArcs,require(script.Parent.Config.ChapterTwo))end
if ashenEnabled then table.insert(CampaignArcs,require(script.Parent.Config.ChapterThree))end
if towerEnabled then table.insert(CampaignArcs,require(script.Parent.Config.ChapterFour))end
if crosshavenEnabled then table.insert(CampaignArcs,require(script.Parent.Config.ChapterFive))end
if archiveHeartEnabled then table.insert(CampaignArcs,require(script.Parent.Config.ChapterSix))end
local CampaignChapter=require(script.Parent.Config.CampaignSequence)(CampaignArcs)
local Campaign=if noviceEnabled then require(script.Parent.Services.CampaignService)(Content,Util,Economy,CampaignChapter)else nil
local Schema = require(script.Parent.Systems.ProfileSchema)(Content, Util, Gear, Expansion, ValidateExpansion,MarketEscrow,GuildLand,noviceEnabled,NoviceStory,Campaign)
local CombatConfig=require(script.Parent.Config.Combat)
for id,ability in pairs(Expansion.Abilities) do CombatConfig.Abilities[id]=ability end
require(script.Parent.Systems.CombatValidator)(Content,CombatConfig,require(script.Parent.Systems.CombatStats)(Content,CombatConfig,Gear))
Util.freeze(CombatConfig)
local CombatRewards=require(script.Parent.Systems.CombatRewards)(Content,CombatConfig,Util,Economy,require(script.Parent.Config.AdventureRewards))
local Progression = require(script.Parent.Systems.Progression)(Content, Gear)
local ExpansionService=require(script.Parent.Services.ExpansionService)(Content,Util,Economy,Expansion,LandPlacement,BuildingThemes)
local Commands = require(script.Parent.Systems.Commands)({ Content=Content,Campaign=Campaign,NoviceStory=NoviceStory, Status=require(script.Parent.Services.StatusPointService)(Content,StatusPoints,Expansion), GuildLand=require(script.Parent.Services.GuildLandService)(GuildLand), Dispatch=require(script.Parent.Services.DispatchService)(Content,Economy,Util), Settlement=require(script.Parent.Services.SettlementService)(Content,Economy,Util), Expansion=ExpansionService, Protocol = Protocol, Util = Util, Progression = Progression,
	Equipment = require(script.Parent.Services.EquipmentService)(Content, Economy, Gear),
	Character = require(script.Parent.Systems.PlayerCharacter)(Content),
	Adventurers = require(script.Parent.Services.AdventurerService)(Content, Economy, Util),
	Party = require(script.Parent.Services.PartyService)(Content.Limits.Party),
	Quests = require(script.Parent.Services.QuestService)(Content, Economy, Progression, Util),
	Guild = require(script.Parent.Services.PersonalGuildService)(Content, Economy,noviceEnabled,CampaignChapter) })

local mode: string
local store: any
local auditStore: any
if RunService:IsStudio() and Runtime.StudioPersistence == "Memory" then
	mode = "Studio memory · not saved after Stop"
	local makeMemory = require(script.Parent.Persistence.MemoryStore)
	store = makeMemory(Util); auditStore = makeMemory(Util)
else
	local environment: string? = Runtime.AllowedDataStoreUniverses[game.GameId]
	if environment == "dev" or environment == "staging" or environment == "prod" then
		-- Studio is deliberately barred from production even if someone enables API access.
		if RunService:IsStudio() and environment == "prod" then environment = nil end
	else environment = nil end
	if environment then
		environment=acceptanceNamespace or environment
		mode = "Persistent · " .. environment
		local makeStore = require(script.Parent.Persistence.RobloxStore)
		store = makeStore("GB_Player_" .. environment, Content.Limits.ProfileBytes)
		auditStore = makeStore("GB_PlayerAudit_" .. environment, Content.Limits.ProfileBytes)
	else
		mode = "Persistence not configured"
		store = { Update = function() error("PersistenceNotConfigured") end }; auditStore = store
		warn("[Guildborne] Persistence not configured: set a permitted development/staging universe in Config/Runtime.")
	end
end
local Data = require(script.Parent.Services.PlayerDataService)({ PermanentEntitlements=PermanentEntitlements,Campaign=Campaign,NoviceStory=NoviceStory,MarketEscrow=MarketEscrow, Util = Util, Content = Content, Config = Runtime, CombatRewards = CombatRewards, Expansion=ExpansionService,
	Schema = Schema, Protocol = Protocol, Commands = Commands, Store = store, AuditStore = auditStore,
	Now = os.time, Wait = task.wait, Jitter = function() return math.random() * 0.15 end, Log = log,
	OnCommitted = function(userId: number, events: any)
		local player = Players:GetPlayerByUserId(userId)
		for _, event in ipairs(events) do Analytics.Emit(event.name, event.payload, player) end
	end })
local bestiary=require(script.Parent.Systems.EnemyProfiles)(CombatConfig).catalog(Content)
bestiary.Regions=require(script.Parent.Systems.AdventureFieldGuide)(require(script.Parent.Config.AdventureEncounters),require(script.Parent.Config.AdventureEnemyProfiles),require(script.Parent.Config.AdventureRewards),require(script.Parent.Systems.AdventureStats),require(Shared.Config.City).RegionOrder)
bestiary.RegionalCombatAvailable=RunService:IsStudio() and game.PlaceId==0 and game.GameId==0 and Runtime.StudioPersistence=="Memory"
local Project = require(script.Parent.Systems.ViewProjection)(Content, Progression, Util, Expansion, bestiary,{rules=GuildLand,catalog=require(script.Parent.Config.GuildLand)},if noviceEnabled then NoviceChapter else nil,if noviceEnabled then CampaignChapter else nil,{Enabled=Runtime.PermanentPassesEnabled,Catalog=PermanentPassCatalog,Offers=PermanentPassOffers})
local Network: any
local PermanentPassRuntime:any
local campaignWorld:any
local ironveilWorld:any
local ashenWorld:any
local towerWorld:any
local crosshavenWorld:any
local archiveHeartWorld:any
local World = require(script.Parent.Services.WorldService).new(function(player: Player, tab: string)
	if Network then Network.Send(player, nil, nil, nil, tab) end
end, function(player: Player, deathId: string, members: {string},encounterId:string?): boolean
	local command: any=nil
	local deadline=os.clock()+25
	repeat
		local session=Data.Sessions[player.UserId]
		if not session or session.closing or player.Parent~=Players then return false end
		if session.state=="Degraded" then Data.Refresh(player.UserId) end
		if not session.busy and session.state=="Active" then
			if not command then command={version=1,requestId="combat:"..deathId,action="CombatReward",revision=session.record.revision,args={}} end
			local code=Data.CommitCombat(player.UserId,command,members,encounterId)
			if code=="OK" or code=="AlreadyCommitted" then
				Network.Send(player); Data.FlushAudit(player.UserId); return true
			elseif code~="Busy" and code~="SavePending" and code~="AuditBacklog" and code~="LeaseExpiring" then return false end
			if code=="AuditBacklog" then Data.FlushAudit(player.UserId) end
		end
		task.wait(.5)
	until os.clock()>deadline
	return false
end, function(player: Player,runId: string,floor: number,success: boolean): boolean
	local command: any=nil
	for _=1,50 do
		local s=Data.Sessions[player.UserId];if not s or s.closing then return false end
		if s.state=="Degraded" then Data.Refresh(player.UserId) end
		if s.state=="Active" and not s.busy then
			command=command or {version=1,requestId=HttpService:GenerateGUID(false),action="TowerResult",revision=s.record.revision,args={}}
			local code=Data.CommitTower(player.UserId,command,runId,floor,success)
			if code=="OK" or code=="AlreadyCommitted" then Network.Send(player);Data.FlushAudit(player.UserId);return true end
			if code=="StaleRevision" then command=nil elseif code=="AuditBacklog" then Data.FlushAudit(player.UserId) elseif code~="Busy" and code~="SavePending" and code~="LeaseExpiring" then return false end
		end
		task.wait(.5)
	end
	return false
end, function(player: Player,action: string,args: any)
	if Network then Network.Intent(player,action,args) end
end, function(player:Player)
	local adapter=require(script.Parent.Services.AdventureRewardAdapter)(Data,player.UserId,require(script.Parent.Config.AdventureRewards),Util)
	return function(ticket:any):string
		local outcome=adapter(ticket)
		if outcome=="Committed" then if Network then Network.Send(player) end;Data.FlushAudit(player.UserId);if campaignWorld then campaignWorld.Victory(player,ticket)end;if ironveilWorld then ironveilWorld.Victory(player,ticket)end;if ashenWorld then ashenWorld.Victory(player,ticket)end end
		return outcome
	end
end)
local closing = false
local started: { [Player]: boolean } = {}
local function load(player: Player): string
	if closing or player.Parent ~= Players then return "Closing" end
	local code = Data.Load(player.UserId, HttpService:GenerateGUID(false))
	if code == "OK" and not started[player] then
		started[player] = true; Analytics.Emit("session_started", {}, player)
	end
	if player.Parent ~= Players then Data.Close(player.UserId) end
	if code=="OK" and player.Parent==Players and PermanentPassRuntime then PermanentPassRuntime.Joined(player) end
	return code
end
Network = require(script.Parent.Services.NetworkService)({ Content=Content, Data = Data, Protocol = Protocol, Project = Project,
	Mode = mode, World = World, Load = load, Log = log,PermanentPassRequest=function(player:Player,packet:any):string
		return if PermanentPassRuntime then PermanentPassRuntime.Request(player,packet) else "PurchaseUnavailable"
	end })
if noviceEnabled then
 local course=require(script.Parent.Services.NoviceCourseWorld)({Data=Data,Chapter=NoviceChapter,
  MakeReceipt=function(userId:number,receipt:any)return require(script.Parent.Services.NoviceReceiptAdapter)(Data,userId,receipt,Util,NoviceChapter,Content)end,
  Notify=function(player:Player)Network.Send(player)end,
  ReturnToGuild=function(player:Player)World.IntentCommitted(player,"TravelZone",{zone="Guild"})end})
 campaignWorld=require(script.Parent.Services.CampaignWorld)({Data=Data,Config=CampaignChapter,World=World,
  MakeReceipt=function(userId:number,receipt:any)return require(script.Parent.Services.NoviceReceiptAdapter)(Data,userId,receipt,Util,NoviceChapter,Content,CampaignChapter)end,
  Notify=function(player:Player)Network.Send(player)end})
 if ironveilEnabled then ironveilWorld=require(script.Parent.Services.IronveilWorld)({Data=Data,Config=CampaignChapter,World=World,
  MakeReceipt=function(userId:number,receipt:any)return require(script.Parent.Services.NoviceReceiptAdapter)(Data,userId,receipt,Util,NoviceChapter,Content,CampaignChapter)end,
  Notify=function(player:Player)Network.Send(player)end})end
 if ashenEnabled then ashenWorld=require(script.Parent.Services.AshenWorld)({Data=Data,Config=CampaignChapter,World=World,
  MakeReceipt=function(userId:number,receipt:any)return require(script.Parent.Services.NoviceReceiptAdapter)(Data,userId,receipt,Util,NoviceChapter,Content,CampaignChapter)end,
  Notify=function(player:Player,code:string?)Network.Send(player,code)end})end
 if towerEnabled then towerWorld=require(script.Parent.Services.TowerWorld)({Data=Data,Config=CampaignChapter,World=World,
  MakeReceipt=function(userId:number,receipt:any)return require(script.Parent.Services.NoviceReceiptAdapter)(Data,userId,receipt,Util,NoviceChapter,Content,CampaignChapter)end,
  Notify=function(player:Player)Network.Send(player)end})end
 if crosshavenEnabled then crosshavenWorld=require(script.Parent.Services.CrosshavenWorld)({Data=Data,Config=CampaignChapter,World=World,
  MakeReceipt=function(userId:number,receipt:any)return require(script.Parent.Services.NoviceReceiptAdapter)(Data,userId,receipt,Util,NoviceChapter,Content,CampaignChapter)end,
  Notify=function(player:Player)Network.Send(player)end})end
 if archiveHeartEnabled then archiveHeartWorld=require(script.Parent.Services.ArchiveHeartWorld)({Data=Data,Config=CampaignChapter,World=World,
  MakeReceipt=function(userId:number,receipt:any)return require(script.Parent.Services.NoviceReceiptAdapter)(Data,userId,receipt,Util,NoviceChapter,Content,CampaignChapter)end,
  Notify=function(player:Player)Network.Send(player)end})end
 local update,remove=World.Update,World.Remove
 World.Update=function(player:Player,level:number,data:any?,active:boolean?)update(player,level,data,active);course.Update(player);campaignWorld.Update(player);if ironveilWorld then ironveilWorld.Update(player)end;if ashenWorld then ashenWorld.Update(player)end;if towerWorld then towerWorld.Update(player)end;if crosshavenWorld then crosshavenWorld.Update(player)end;if archiveHeartWorld then archiveHeartWorld.Update(player)end end
 World.Remove=function(player:Player)if archiveHeartWorld then archiveHeartWorld.Remove(player)end;if crosshavenWorld then crosshavenWorld.Remove(player)end;if towerWorld then towerWorld.Remove(player)end;if ashenWorld then ashenWorld.Remove(player)end;if ironveilWorld then ironveilWorld.Remove(player)end;campaignWorld.Remove(player);course.Remove(player);remove(player)end
 local intentCommitted,playerAction=World.IntentCommitted,World.PlayerAction
 World.IntentCommitted=function(player:Player,action:string,args:any)intentCommitted(player,action,args);campaignWorld.Command(player,action,args)end
 World.PlayerAction=function(player:Player,action:string,actorId:string?):(boolean,string)
  local ok,code=playerAction(player,action,actorId);if ok then campaignWorld.Order(player,action,actorId)end;return ok,code
 end
end

require(script.Parent.Services.PurchaseService)(Content,Data,Network)
PermanentPassRuntime=require(script.Parent.Services.PermanentPassRuntime)({Enabled=Runtime.PermanentPassesEnabled,Catalog=PermanentPassCatalog,Data=Data,Network=Network,Offers=PermanentPassOffers,World=World,LeaseSafetySeconds=Runtime.LeaseSafetySeconds})
local marketCatalog={}
for _,id in ipairs(Content.ItemOrder) do if Content.Items[id].Tradable then table.insert(marketCatalog,{id=id,name=Content.Items[id].Name,category=Content.Items[id].Kind}) end end
require(script.Parent.Services.MarketRuntime)({Config=MarketConfig,Runtime=Runtime,Util=Util,Data=Data,Network=Network,
	Orders=MarketOrders,Escrow=MarketEscrow,Book=MarketBook,MarketData=MarketData,Catalog=marketCatalog,
	ReadProfile=function(userId: number) return store.Read("p:"..tostring(userId)) end})

local function joined(player: Player)
	if closing then return end
	if acceptanceNamespace and not Runtime.PrivateAcceptance.UserIds[player.UserId] then player:Kick("Private acceptance access only");return end
	World.Add(player)
	local code = load(player)
	Network.Send(player, code)
	if code == "OK" then Data.FlushAudit(player.UserId) end
end
local function drain(player: Player)
	PermanentPassRuntime.Remove(player)
	if started[player] then Analytics.Emit("session_ended", {}, player); started[player] = nil end
	Network.Remove(player); World.Remove(player)
	local deadline = os.clock() + 22
	repeat
		local code = Data.Close(player.UserId)
		if code == "OK" then return end
		task.wait(0.25)
	until os.clock() >= deadline
	log("profile_close_deferred", {}) -- durable checkpoints survive; lease eventually expires
end
Players.PlayerAdded:Connect(function(player) task.spawn(joined, player) end)
Players.PlayerRemoving:Connect(drain)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(joined, player) end
task.spawn(function()
	while not closing do
		task.wait(Runtime.HeartbeatSeconds + math.random())
		for _, player in ipairs(Players:GetPlayers()) do
			task.spawn(function()
				Data.Refresh(player.UserId); Data.FlushAudit(player.UserId); Network.Send(player)
			end)
		end
	end
end)
game:BindToClose(function()
	closing = true
	local remaining = 0
	for _, player in ipairs(Players:GetPlayers()) do
		remaining += 1
		task.spawn(function() drain(player); remaining -= 1 end)
	end
	local deadline = os.clock() + 25
	while remaining > 0 and os.clock() < deadline do task.wait(0.1) end
end)
print("[Guildborne] Phase 1 ready · " .. mode)
