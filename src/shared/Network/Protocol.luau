--!strict
local Protocol = { Version = 1, MaxPartySize = 5 }
local schemas: { [string]: { [string]: string } } = {
	RequestPermanentPass={kind="id",key="id"},
	ClaimNoviceChapter={chapterId="id"},FoundNoviceGuild={heroClass="id"},
	ClaimCampaignChapter={chapterId="id"},ClaimCampaignRecruit={chapterId="id",heroClass="id"},
	AllocateStatus={actorId="id",stat="id",amount="integer"},ResetBuildPoints={actorId="id"},
	SetGuildAccess={mode="id"},
	VisitIsland={ownerId="id"},
	KickIslandVisitor={visitorId="id"},
	StoreBuilding={buildingId="id"},RestoreBuilding={buildingId="id",x="grid",z="grid",rotation="integer"},
	SaveBuildLayout={slot="integer"},ApplyBuildLayout={slot="integer"},DeleteBuildLayout={slot="integer"},
	UnlockBuildingTheme={themeId="id"},ApplyBuildingTheme={themeId="id",buildingId="id"},
	MoveGuildHall={x="grid",z="grid",rotation="integer"},
	CraftFurniture={kind="id"},PlaceFurniture={furnitureId="id",x="grid",z="grid",rotation="integer"},StoreFurniture={furnitureId="id"},
	DismantleFurniture={furnitureId="id"},
	UnlockGuildPlot={plotId="id"},ContributeGuildPlot={plotId="id",itemId="id",amount="integer"},OpenGuildPlot={plotId="id"},
	GatherResource={nodeId="id"}, PlaceBuilding={kind="id",x="grid",z="grid",rotation="integer"}, MoveBuilding={buildingId="id",x="grid",z="grid",rotation="integer"}, DismantleBuilding={buildingId="id"}, CraftItem={recipeId="id"},
	AdvanceClass={actorId="id",pathId="id"}, LearnSkill={actorId="id",skillId="id"}, EquipSkill={actorId="id",skillId="id"}, ResetSkills={actorId="id"}, SelectRace={raceId="id"}, StartTower={floor="integer"}, EnterTowerFloor={}, LeaveTower={},
	DispatchTeam={missionId="id",adventurerIds="party"}, ClaimDispatch={jobId="id"}, BuyElixir={}, ReviveHero={actorId="id"},
	TravelZone={zone="id"}, UpgradeTavern={}, UpgradeQuarters={buildingId="id"}, ScoutHero={}, HireHero={offerId="id"}, AcceptTask={questId="id"}, ClaimTask={questId="id"},
	GetState = {}, RetryLoad = {}, RetrySave = {}, BeginTutorial = {},
	SelectPlayerClass = { classId = "id" }, Recruit = { classId = "id" }, UpdateParty = { adventurerIds = "party" },
	StartQuest = { questId = "id" }, CompleteQuest = { runId = "id" },
	SellEquipment = { instanceId = "id" }, AssignEquipment = { instanceId = "id", actorId = "id" }, UnequipEquipment = { actorId = "id", slot = "id" }, BuyEquipment = { definitionId = "id" },
	EquipItem = { instanceId = "id", adventurerId = "id" }, UpgradeGuildHall = {},
	SetLanguage = { language = "language" },
}

local function id(value: any): boolean
	return type(value) == "string" and #value > 0 and #value <= 64 and string.match(value, "^[%w_:%-]+$") ~= nil
end

function Protocol.validate(message: any): (boolean, string?)
	if type(message) ~= "table" then return false, "InvalidRequest" end
	for key in pairs(message) do
		if key ~= "version" and key ~= "requestId" and key ~= "action" and key ~= "revision" and key ~= "args" then
			return false, "InvalidRequest"
		end
	end
	if message.version ~= Protocol.Version or not id(message.requestId) or type(message.action) ~= "string" then return false, "InvalidRequest" end
	local shape = schemas[message.action]
	if not shape or type(message.args) ~= "table" then return false, "InvalidRequest" end
	local revision = message.revision
	if type(revision) ~= "number" or revision ~= revision or revision < 0 or revision > 1000000000 or revision % 1 ~= 0 then return false, "InvalidRequest" end
	for key, value in pairs(message.args) do
		local kind = shape[key]
		if not kind then return false, "InvalidRequest" end
		if kind=="integer" and (type(value)~="number" or value~=value or value%1~=0 or math.abs(value)>100) then return false,"InvalidRequest" end
		if kind=="grid" and (type(value)~="number" or value~=value or math.abs(value)>100 or (value*4)%1~=0) then return false,"InvalidRequest" end
		if kind == "id" and not id(value) then return false, "InvalidRequest" end
		if kind == "language" and value ~= "en" and value ~= "th" then return false, "InvalidRequest" end
		if kind == "party" then
			if type(value) ~= "table" then return false, "InvalidRequest" end
			local count = 0
			for index, member in pairs(value) do
				count += 1
				if count > Protocol.MaxPartySize or type(index) ~= "number" or index % 1 ~= 0 or index < 1 or index > Protocol.MaxPartySize or not id(member) then return false, "InvalidRequest" end
			end
			if count ~= #value then return false, "InvalidRequest" end
			for index = 1, count do if value[index] == nil then return false, "InvalidRequest" end end
		end
	end
	for key in pairs(shape) do if message.args[key] == nil then return false, "InvalidRequest" end end
	return true, nil
end

return Protocol
