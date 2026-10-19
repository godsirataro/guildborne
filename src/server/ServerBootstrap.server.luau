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
local Release=require(script.Parent.Systems.ReleasePolicy)(require(script.Parent.Config.ReleaseContent)).resolve(Runtime,{isStudio=RunService:IsStudio(),placeId=game.PlaceId,gameId=game.GameId})
local launchEnabled=Release.Enabled==true
local sharedLabEnabled=launchEnabled and (Runtime :: any).SharedCombatCandidate==true and RunService:IsStudio() and game.PlaceId==0 and game.GameId==0 and Runtime.StudioPersistence=="Memory"
local noviceEnabled=(Runtime.NoviceJourney==true or launchEnabled) and RunService:IsStudio() and game.PlaceId==0 and game.GameId==0 and Runtime.StudioPersistence=="Memory"
local ironveilEnabled=noviceEnabled and (Runtime.IronveilJourney==true or launchEnabled)
local ashenEnabled=ironveilEnabled and Runtime.AshenJourney==true and not launchEnabled
local towerEnabled=ashenEnabled and Runtime.TowerJourney==true
local crosshavenEnabled=towerEnabled and Runtime.CrosshavenJourney==true
local archiveHeartEnabled=crosshavenEnabled and Runtime.ArchiveHeartJourney==true
-- BEGIN full connected candidate gate: separate from the bounded Lv35 release.
local function fullConnectedCandidate(runtime:any,context:any,fullRoute:boolean,launch:boolean):boolean
 return runtime.FullConnectedWorldCandidate==true and fullRoute and not launch
  and context.isStudio==true and context.placeId==0 and context.gameId==0
  and runtime.StudioPersistence=="Memory" and type(runtime.AllowedDataStoreUniverses)=="table"
  and next(runtime.AllowedDataStoreUniverses)==nil
end
-- END full connected candidate gate.
local fullConnectedEnabled=fullConnectedCandidate(Runtime,{isStudio=RunService:IsStudio(),placeId=game.PlaceId,gameId=game.GameId},archiveHeartEnabled,launchEnabled)
local continuousWorldEnabled=(launchEnabled and (Runtime :: any).ContinuousWorldCandidate==true) or fullConnectedEnabled
-- BEGIN Class3 candidate gate (default absent/off; local Memory acceptance only).
local function class3Candidate(runtime:any,context:any,fullRoute:boolean,launch:boolean):boolean
 return runtime.Class3ProofCandidate==true and fullRoute and not launch and context.isStudio==true
  and context.placeId==0 and context.gameId==0 and runtime.StudioPersistence=="Memory"
end
-- END Class3 candidate gate.
local class3Enabled=class3Candidate(Runtime,{isStudio=RunService:IsStudio(),placeId=game.PlaceId,gameId=game.GameId},crosshavenEnabled,launchEnabled)
Content.RegionalCombatAvailable=RunService:IsStudio() and game.PlaceId==0 and game.GameId==0 and Runtime.StudioPersistence=="Memory"
Content.StatusAllocationAvailable=Content.RegionalCombatAvailable
Content.RecruitmentTemplatesAvailable=Content.RegionalCombatAvailable
Content.AppearanceAvailable=RunService:IsStudio() and game.PlaceId==0 and game.GameId==0 and Runtime.StudioPersistence=="Memory"
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
	for _, key in ipairs({ "revision", "action", "questId", "reason", "amount", "level", "classId", "itemId", "quantity", "event", "version", "milestone", "elapsedSeconds" }) do
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
local Analytics = require(script.Parent.Services.AnalyticsAdapter)(providers, log, require(script.Parent.Systems.AnalyticsContract))
local funnelOwners:{[number]:Player}={}
local Funnel=require(script.Parent.Systems.OnboardingFunnel)({Now=os.clock,
	Emit=function(userId:number,name:string,payload:any)
		Analytics.Product(name,payload,Players:GetPlayerByUserId(userId))
	end})
local function observeProduct(userId:number,name:string,payload:any,sourcePlayer:Player?)
	-- Telemetry is never part of combat/profile authority or commit success.
	if sourcePlayer and funnelOwners[userId]==sourcePlayer and Players:GetPlayerByUserId(userId)==sourcePlayer then pcall(Funnel.Observe,userId,name,payload) end
end
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
local LaunchRewards=require(script.Parent.Systems.LaunchRewards)(Content,Util,Economy,require(script.Parent.Config.LaunchRewards))
local NoviceChapter=require(script.Parent.Config.NoviceChapter)
local NoviceStory=if noviceEnabled then require(script.Parent.Services.NoviceStoryService)(Content,Util,Economy,NoviceChapter)else nil
local CampaignArcs:{any}={require(script.Parent.Config.ChapterOne)}
if ironveilEnabled then table.insert(CampaignArcs,require(script.Parent.Config.ChapterTwo))end
if ashenEnabled then table.insert(CampaignArcs,require(script.Parent.Config.ChapterThree))end
if towerEnabled then table.insert(CampaignArcs,require(script.Parent.Config.ChapterFour))end
if crosshavenEnabled then table.insert(CampaignArcs,require(script.Parent.Config.ChapterFive))end
if archiveHeartEnabled then table.insert(CampaignArcs,require(script.Parent.Config.ChapterSix))end
local CampaignChapter=require(script.Parent.Config.CampaignSequence)(CampaignArcs)
local FullCampaignChapter=if launchEnabled then require(script.Parent.Config.CampaignSequence)({require(script.Parent.Config.ChapterOne),require(script.Parent.Config.ChapterTwo),require(script.Parent.Config.ChapterThree),require(script.Parent.Config.ChapterFour),require(script.Parent.Config.ChapterFive),require(script.Parent.Config.ChapterSix)}) else nil
local Campaign=if noviceEnabled then require(script.Parent.Services.CampaignService)(Content,Util,Economy,CampaignChapter,FullCampaignChapter)else nil
local AppearancePolicy=if Content.AppearanceAvailable then require(script.Parent.Services.CharacterAppearance.PreviewPolicy) else nil
local Appearance=if AppearancePolicy then require(script.Parent.Services.CharacterAppearance.AppearanceService)(require(Shared.Data.AppearanceCatalog),require(Shared.Data.AppearanceRules),AppearancePolicy) else nil
local Schema = require(script.Parent.Systems.ProfileSchema)(Content, Util, Gear, Expansion, ValidateExpansion,MarketEscrow,GuildLand,noviceEnabled,NoviceStory,Campaign,Appearance,LaunchRewards)
local CombatConfig=require(script.Parent.Config.Combat)
for id,ability in pairs(Expansion.Abilities) do CombatConfig.Abilities[id]=ability end
require(script.Parent.Systems.CombatValidator)(Content,CombatConfig,require(script.Parent.Systems.CombatStats)(Content,CombatConfig,Gear))
Util.freeze(CombatConfig)
local CombatRewards=require(script.Parent.Systems.CombatRewards)(Content,CombatConfig,Util,Economy,require(script.Parent.Config.AdventureRewards))
local Progression = require(script.Parent.Systems.Progression)(Content, Gear)
local Class3Proof=if class3Enabled then require(script.Parent.Systems.Class3Proof)(Expansion,Util,Campaign) else nil
local HeroTrials=if launchEnabled or class3Enabled then require(script.Parent.Systems.HeroMentorTrial)(Expansion,Util,Class3Proof) else nil
local HeroMentor=if launchEnabled then HeroTrials else nil
local ExpansionService=require(script.Parent.Services.ExpansionService)(Content,Util,Economy,Expansion,LandPlacement,BuildingThemes,HeroMentor,Class3Proof)
local function class3PlayerProblem(data:any,_pathId:string):string?
 if data.character.level<70 or data.personalGuild.buildings.guildHall<11 then return "ClassTrialLocked"end
 if data.quests.active or data.expansion.tower.active then return "FinishExpedition"end
 local c=data.progression.campaign
 if not c or c.claimed<24 or (c.claimed==24 and not c.objectives.complete_borrowed_mastery and not c.objectives.meet_crosshaven_mentor) then return "WrongObjective"end
 return nil
end
local Commands = require(script.Parent.Systems.Commands)({ Release=Release,LaunchRewards=if launchEnabled then LaunchRewards else nil,Appearance=Appearance,Content=Content,Campaign=Campaign,NoviceStory=NoviceStory, Status=require(script.Parent.Services.StatusPointService)(Content,StatusPoints,Expansion), GuildLand=require(script.Parent.Services.GuildLandService)(GuildLand), Dispatch=require(script.Parent.Services.DispatchService)(Content,Economy,Util), Settlement=require(script.Parent.Services.SettlementService)(Content,Economy,Util), Expansion=ExpansionService, Protocol = Protocol, Util = Util, Progression = Progression,
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
local sharedClaims=if sharedLabEnabled then require(script.Parent.Systems.SharedPvEClaims).new(Content,Util,Economy)else nil
local Data = require(script.Parent.Services.PlayerDataService)({ Class3Proof=Class3Proof,SharedPvEClaims=sharedClaims,HeroMentor=HeroMentor,PermanentEntitlements=PermanentEntitlements,Campaign=Campaign,NoviceStory=NoviceStory,MarketEscrow=MarketEscrow, Util = Util, Content = Content, Config = Runtime, CombatRewards = CombatRewards, Expansion=ExpansionService,
	Schema = Schema, Protocol = Protocol, Commands = Commands, Store = store, AuditStore = auditStore,
	Now = os.time, Wait = task.wait, Jitter = function() return math.random() * 0.15 end, Log = log,
	OnCommitted = function(userId: number, events: any)
		local player = Players:GetPlayerByUserId(userId)
		for _, event in ipairs(events) do observeProduct(userId,event.name,event.payload,player);Analytics.Emit(event.name, event.payload, player) end
	end })
local bestiary=require(script.Parent.Systems.EnemyProfiles)(CombatConfig).catalog(Content)
bestiary.Regions=require(script.Parent.Systems.AdventureFieldGuide)(require(script.Parent.Config.AdventureEncounters),require(script.Parent.Config.AdventureEnemyProfiles),require(script.Parent.Config.AdventureRewards),require(script.Parent.Systems.AdventureStats),require(Shared.Config.City).RegionOrder)
bestiary.RegionalCombatAvailable=RunService:IsStudio() and game.PlaceId==0 and game.GameId==0 and Runtime.StudioPersistence=="Memory"
local Project = require(script.Parent.Systems.ViewProjection)(Content, Progression, Util, Expansion, bestiary,{rules=GuildLand,catalog=require(script.Parent.Config.GuildLand)},if noviceEnabled then NoviceChapter else nil,if noviceEnabled then CampaignChapter else nil,{Enabled=Runtime.PermanentPassesEnabled,Catalog=PermanentPassCatalog,Offers=PermanentPassOffers},{Service=Appearance,Policy=AppearancePolicy},{Release=Release,Mentor=HeroMentor,Rewards=if launchEnabled then LaunchRewards else nil},if Class3Proof then {Proof=Class3Proof,Trial=HeroTrials,PlayerProblem=class3PlayerProblem} else nil)
local Network: any
local PermanentPassRuntime:any
local campaignWorld:any
local ironveilWorld:any
local ashenWorld:any
local towerWorld:any
local crosshavenWorld:any
local archiveHeartWorld:any
-- Explicit local acceptance lab, independent of the ordinary launch candidate.
-- One encounter only. Rewards use actual loaded Memory profiles; no public route.
local sharedCandidateFactory:any=nil
local sharedRewardAdapter:any=nil
local sharedScene:Model?=nil
local sharedMentorActive:(Player)->boolean=function(_player:Player):boolean return false end
if sharedLabEnabled then
	sharedCandidateFactory=function(parent:Instance,templates:Folder):any
		local scene=Instance.new("Model");scene.Name="SharedCombatCandidate";scene.Parent=parent
		local origin=Vector3.new(6000,0,6000)
		local ground=Instance.new("Part");ground.Name="Ground";ground.Anchored=true
		ground.Size=Vector3.new(100,2,150);ground.Position=origin+Vector3.new(0,-1,75);ground.Material=Enum.Material.Grass;ground.Parent=scene
		local spawned=require(script.Parent.Services.EnemyService)(templates).create(scene,origin,0)
		local scout=spawned[1];for i=2,#spawned do spawned[i].model:Destroy()end
		scout.plot=scene
		sharedScene=scene
		scene:SetAttribute("CandidateOnly",true);scene:SetAttribute("RewardsEnabled",true)
		scene:SetAttribute("Origin",origin);scene:SetAttribute("Status","Ready")
		local settlement=require(script.Parent.Systems.SharedPvESettlement)
		local repository=require(script.Parent.Services.SharedPvESettlementStore)(require(script.Parent.Persistence.MemoryStore)(Util),Util,settlement,"shared_lab",2)
		sharedRewardAdapter=require(script.Parent.Services.SharedPvERewardAdapter)({Data=Data,Repository=repository,Claims=sharedClaims,Util=Util,Namespace="shared_lab"})
		local encounterId="scout_"..HttpService:GenerateGUID(false)
		local delivery={Deliver=function(ownerId:number,id:string):(string,string)
			local original=Players:GetPlayerByUserId(ownerId);local session=Data.Sessions[ownerId]
			local outcome,code=sharedRewardAdapter.Deliver(ownerId,id)
			if original and original.Parent==Players and Players:GetPlayerByUserId(ownerId)==original and session and Data.Sessions[ownerId]==session and not session.closing then
				if outcome=="Committed" then if Network then Network.Send(original)end;Data.FlushAudit(ownerId)
				elseif code=="AuditBacklog" then Data.FlushAudit(ownerId)end
			end
			return outcome,code
		end}
		return {
			Scene={plot=scene,origin=origin,enemies={scout}},
			TravelGate=function(player:Player,enter:boolean):string?
				local session=Data.Sessions[player.UserId]
				if player.Parent~=Players or Players:GetPlayerByUserId(player.UserId)~=player or not session or session.closing or session.state~="Active" then return "ActorNotReady" end
				if session.busy then return "SavePending" end
				if sharedMentorActive(player) then return "HeroMentorActive" end
				if enter and (not scene.Parent or scene:GetAttribute("Status")=="Faulted" or scene:GetAttribute("Status")=="Closed") then return "TravelUnavailable" end
				return Content.NoviceActionProblem(session.record.data,"TravelZone")
			end,
			TravelNotify=function(player:Player,code:string)if Network then Network.Send(player,code)end end,
			MakeRewards=function(context:any):any
				return require(script.Parent.Services.SharedCombatRewards)({Policy=context.Policy,EncounterToken=context.EncounterToken,Enemy=context.Enemy,OwnerRoster=context.OwnerRoster,
					Now=os.clock,EncounterId=encounterId,RotationSeed=0,
					Budget={xp=CombatConfig.Goblin.Reward.XP,gold=CombatConfig.Goblin.Reward.Gold,items={}},
					MakeParticipation=require(script.Parent.Systems.SharedEncounterParticipation),Settlement=settlement,Repository=repository,Delivery=delivery,Util=Util})
			end,
			Session=function(player:Player):any
				if player.Parent~=Players or Players:GetPlayerByUserId(player.UserId)~=player then return nil end
				return Data.Sessions[player.UserId]
			end,
			ContainsPosition=function(position:Vector3):boolean
				local p=position-origin
				return math.abs(p.X)<=34 and p.Z>=49 and p.Z<=112 and p.Y>0 and p.Y<30
			end,
			Status=function(status:string,reason:string?)scene:SetAttribute("Status",status);scene:SetAttribute("Failure",reason)end,
			Destroy=function()scene:Destroy()end,
		}
	end
end
-- BEGIN continuous walking eligibility: read-only, synchronous server policy.
local function walkingSession(player:Player):any?
	if player.Parent~=Players or Players:GetPlayerByUserId(player.UserId)~=player then return nil end
	return Data.Sessions[player.UserId]
end
local function walkingGate(player:Player,session:any,fromZone:string,toZone:string):string?
	if not session or walkingSession(player)~=session or session.closing or session.state~="Active" or not session.record or not session.record.data then return "ActorNotReady" end
	if session.busy then return "SavePending" end
	local permittedPair=(fromZone=="City" and toZone=="Greenwood") or (fromZone=="Greenwood" and toZone=="City")
		or (fromZone=="Greenwood" and toZone=="Ironveil") or (fromZone=="Ironveil" and toZone=="Greenwood")
	if not permittedPair then return "InvalidZone" end
	local data=session.record.data
	local problem=Content.NoviceActionProblem(data,"TravelZone");if problem then return problem end
	problem=Release.problem(data,"TravelZone",{zone=toZone});if problem then return problem end
	if data.expansion.tower.active then return "FinishExpedition" end
	local charter=Content.CivicTravel and Content.CivicTravel[toZone]
	if charter and (not data.settlement.journal[charter] or data.settlement.journal[charter].state~="Claimed") then return "CivicRouteLocked" end
	if sharedMentorActive(player) then return "HeroMentorActive" end
	-- These are server-owned active arena models, not client HUD attributes.
	for _,prefix in ipairs({"NoviceTrial_","TowerLesson_","ArchiveEncounter_"}) do
		local arena=workspace:FindFirstChild(prefix..player.UserId,true)
		if arena and arena:GetAttribute("OwnerUserId")==player.UserId then return "FinishExpedition" end
	end
	return nil
end
-- END continuous walking eligibility.
local World:any = require(script.Parent.Services.WorldService).new(function(player: Player, tab: string)
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
end,Release,observeProduct,sharedCandidateFactory,if continuousWorldEnabled then {
	Session=walkingSession,Gate=walkingGate,
	Notify=function(player:Player,code:string)if Network then Network.Send(player,code)end end,
} else nil)
local closing = false
local sharedPumpBusy=false
local function pumpSharedRewards()
	if not sharedRewardAdapter or sharedPumpBusy then return end
	sharedPumpBusy=true
	local ok=pcall(function()
		sharedRewardAdapter.Sweep()
		local state=World.SharedRewardState()
		if state and (state.status=="PendingPreparation" or state.status=="PendingDelivery")then World.PumpSharedRewards()end
		state=World.SharedRewardState()
		if sharedScene and sharedScene.Parent and state then sharedScene:SetAttribute("RewardStatus",state.status)end
	end)
	sharedPumpBusy=false
	if not ok then log("shared_reward_worker_retry",{})end
end
local started: { [Player]: boolean } = {}
local HumanParty=require(script.Parent.Services.HumanPartyRuntime)({Enabled=launchEnabled,Data=Data,
	Notify=function(player:Player)if Network then Network.Send(player)end end})
local function load(player: Player): string
	if closing or player.Parent ~= Players then return "Closing" end
	local code = Data.Load(player.UserId, HttpService:GenerateGUID(false))
	if code == "OK" and not closing and player.Parent==Players and Players:GetPlayerByUserId(player.UserId)==player and not started[player] then
		started[player] = true
		if funnelOwners[player.UserId]~=player then pcall(Funnel.End,player.UserId);funnelOwners[player.UserId]=player;pcall(Funnel.Begin,player.UserId) end
		Analytics.Emit("session_started", {}, player)
	end
	if player.Parent ~= Players then Data.Close(player.UserId) end
	if code=="OK" and player.Parent==Players and PermanentPassRuntime then PermanentPassRuntime.Joined(player) end
	if code=="OK" and player.Parent==Players then HumanParty.Add(player) end
	return code
end
-- BEGIN Class3 routing helpers. Error mapping is one-to-one except named lifecycle aliases.
local function class3Code(code:string?):string?
 if not code or code=="OK" then return code end
 local aliases={HeroMentorStarted="Class3Started",HeroMentorSaving="Class3SavePending",HeroMentorComplete="Class3Complete",HeroMentorCancelled="Class3Cancelled",HeroMentorFailed="Class3Failed",HeroChanged="Class3ActorChanged",HeroMentorUnavailable="Class3TrialUnavailable",ClassTrialLocked="Class3LevelLocked",HeroMentorActive="Class3Busy"}
 if aliases[code] then return aliases[code]end
 if code:sub(1,6)=="Class3" or code=="ReturnToCrosshaven" then return code end
 return "Class3"..code
end
-- END Class3 routing helpers.
local mentorWorld:any=nil
local function class3Notify(player:Player,code:string?)Network.Send(player,class3Code(code))end
local function makeClass3Receipt(userId:number,receipt:any,fence:any,guard:any):any
 return require(script.Parent.Services.Class3ProofReceiptAdapter)(Data,userId,receipt,Util,fence,guard)
end
local function trialAdmission(player:Player,hero:boolean):string?
 if hero and crosshavenWorld and crosshavenWorld.Active(player) then return "HeroMentorActive"end
 if not hero and mentorWorld and mentorWorld.Active(player) then return "HeroMentorActive"end
 local context=World.CampaignContext(player)
 if context and context.model:GetAttribute("InCombat") then return "FinishExpedition"end
 local reward=World.SharedRewardState()
 if reward and (reward.status=="PendingPreparation" or reward.status=="PendingDelivery")then return "SavePending"end
 return nil
end
Network = require(script.Parent.Services.NetworkService)({ HumanParty=HumanParty,Content=Content, Data = Data, Protocol = Protocol, Project = Project,
	Mode = mode, World = World, Load = load, Log = log,PermanentPassRequest=function(player:Player,packet:any):string
		return if PermanentPassRuntime then PermanentPassRuntime.Request(player,packet) else "PurchaseUnavailable"
	end })
if noviceEnabled then
 local course=require(script.Parent.Services.NoviceCourseWorld)({Data=Data,Chapter=NoviceChapter,
  TrialIdentityContext={IsStudio=RunService:IsStudio(),PlaceId=game.PlaceId,GameId=game.GameId,PersistenceMode=Runtime.StudioPersistence},
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
  Class3Proof=Class3Proof,MakeClass3Receipt=if Class3Proof then makeClass3Receipt else nil,Class3Notify=class3Notify,
  AdmissionProblem=if Class3Proof then function(player:Player)return trialAdmission(player,false)end else nil,
  MakeReceipt=function(userId:number,receipt:any)return require(script.Parent.Services.NoviceReceiptAdapter)(Data,userId,receipt,Util,NoviceChapter,Content,CampaignChapter)end,
  Notify=function(player:Player,code:string?)Network.Send(player,code)end})end
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

if HeroTrials then
 mentorWorld=require(script.Parent.Services.HeroMentorWorld)({Data=Data,World=World,Trial=HeroTrials,
  Class3Proof=Class3Proof,MakeClass3Receipt=if Class3Proof then makeClass3Receipt else nil,Class3Notify=class3Notify,
  AdmissionProblem=if Class3Proof then function(player:Player)return trialAdmission(player,true)end else nil,
  Notify=function(player:Player,code:string?)Network.Send(player,code)end,
  MakeReceipt=function(userId:number,receipt:any,epoch:any,token:any)return require(script.Parent.Services.HeroMentorReceiptAdapter)(Data,userId,receipt,Util,epoch,token)end})
 sharedMentorActive=function(player:Player):boolean return mentorWorld.Active(player) or (class3Enabled and crosshavenWorld~=nil and crosshavenWorld.Active(player))end
 World.HeroMentorIntent=if launchEnabled then mentorWorld.Intent else nil
 World.HeroMentorState=if launchEnabled then mentorWorld.State else nil
 local validate,remove=World.ValidateIntent,World.Remove
 World.ValidateIntent=function(player:Player,action:string,args:any):string?
  local proofState=if class3Enabled then (mentorWorld.Class3State(player) or (crosshavenWorld and crosshavenWorld.Class3State(player))) else nil
  if proofState and not ({GetState=true,RetrySave=true,CancelClass3Trial=true})[action] then return "Class3Busy"end
  if class3Enabled and crosshavenWorld and crosshavenWorld.Active(player) and not ({GetState=true,RetrySave=true})[action] and not proofState then return "Class3Busy"end
  if mentorWorld.Active(player) and not proofState and not ({GetState=true,RetrySave=true,CancelHeroMentor=true})[action]then return "HeroMentorActive"end
  return validate(player,action,args)
 end
 World.Remove=function(player:Player)mentorWorld.Remove(player);remove(player)end
end
World.Class3Code=class3Code
if class3Enabled then
 World.Class3State=function(player:Player):any? return mentorWorld.Class3State(player) or (crosshavenWorld and crosshavenWorld.Class3State(player))end
 World.Class3Intent=function(player:Player,action:string,args:any):string
  if action=="CancelClass3Trial"then
   if mentorWorld.Class3State(player) then return mentorWorld.Intent(player,action,args)end
   if crosshavenWorld and crosshavenWorld.Class3State(player) then return crosshavenWorld.Intent(player,action,args)end
   return "InvalidAction"
  end
  if action~="StartClass3Trial"then return "InvalidAction"end
  local s=Data.Sessions[player.UserId]
  if not s or s.state~="Active" or s.busy or s.closing then return "ProfileNotReady"end
  local problem=Release.problem(s.record.data,"AdvanceClass",args);if problem then return problem end
  if not Expansion.usesNoviceProgression(s.record.data)then return "Class3TrialUnavailable"end
  if args.actorId=="player"then return if crosshavenWorld then crosshavenWorld.Intent(player,action,args) else "Class3TrialUnavailable"end
  return mentorWorld.Intent(player,action,args)
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
	local departingSession=Data.Sessions[player.UserId]
	HumanParty.Remove(player)
	PermanentPassRuntime.Remove(player)
	if started[player] then
		if funnelOwners[player.UserId]==player then funnelOwners[player.UserId]=nil;pcall(Funnel.End,player.UserId) end
		Analytics.Emit("session_ended", {}, player); started[player] = nil
	end
	Network.Remove(player); World.Remove(player)
	if sharedRewardAdapter and departingSession then sharedRewardAdapter.Remove(player.UserId,departingSession)end
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
if sharedLabEnabled then task.spawn(function()
	while not closing do task.wait(.5);if closing then break end;pumpSharedRewards()end
end)end
task.spawn(function()
	while not closing do task.wait(1);HumanParty.Step() end
end)
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
	if sharedLabEnabled then World.DestroyHeroRuntime()end
	World.CloseSharedCombat()
	if sharedLabEnabled then
		local untilAt=os.clock()+3
		while sharedPumpBusy and os.clock()<untilAt do task.wait(.05)end
		for _=1,16 do
			if sharedPumpBusy or os.clock()>=untilAt then break end
			local state=World.SharedRewardState();if not state or (state.status~="PendingPreparation" and state.status~="PendingDelivery")then break end
			pumpSharedRewards()
		end
	end
	local remaining = 0
	for _, player in ipairs(Players:GetPlayers()) do
		remaining += 1
		task.spawn(function() drain(player); remaining -= 1 end)
	end
	local deadline = os.clock() + 25
	while remaining > 0 and os.clock() < deadline do task.wait(0.1) end
end)
print("[Guildborne] Phase 1 ready · " .. mode)
