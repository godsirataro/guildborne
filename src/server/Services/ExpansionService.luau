--!strict
-- Candidate-only mutations. Spatial authorization is checked by the world gateway.
return function(content: any,util: any,economy: any,rules: any,landPlacement:any?,themes:any?)
	local S: any={}
	local function xp(data: any,actor: any,amount: number): string?
		if actor.xp+amount>content.Limits.XP then return "XPCap" end
		actor.xp+=amount;actor.level=content:LevelFromXP(actor.xp,content.ProfileLevelCap(data));return nil
	end
	function S.apply(data: any,action: string,a: any,now: number,emit: any): string?
		local e=data.expansion
		if action=="UnlockBuildingTheme" or action=="ApplyBuildingTheme" then
			if not themes then return "ThemeUnavailable" end
			local code=if action=="UnlockBuildingTheme" then themes.unlock(data,a.themeId) else themes.apply(data,a.themeId,a.buildingId)
			if code~="OK" then return code end
		elseif action=="CraftFurniture" then
			local def=rules.Furniture[a.kind];if not def then return "InvalidFurniture" end
			local nextId=e.nextFurniture or 1
			if util.count(e.furniture or {})>=rules.FurnitureLimit or nextId>=1000000000 then return "FurnitureLimit" end
			local problem=economy.consume(data,def.Cost,"FurnitureCrafting",emit);if problem then return problem end
			e.furniture=e.furniture or {};e.furniture["f:"..nextId]={kind=a.kind,stored=true,x=6,z=-4,rotation=0};e.nextFurniture=nextId+1
		elseif action=="PlaceFurniture" then
			local b=e.furniture and e.furniture[a.furnitureId];if not b or not landPlacement then return "InvalidFurniture" end
			local valid,reason=landPlacement(data,b.kind,a.x,a.z,a.rotation,if b.stored then nil else a.furnitureId)
			if not valid then return reason end
			b.x=a.x;b.z=a.z;b.rotation=a.rotation;b.stored=false
		elseif action=="StoreFurniture" then
			local b=e.furniture and e.furniture[a.furnitureId];if not b then return "InvalidFurniture" end
			if b.stored then return "FurnitureAlreadyStored" end;b.stored=true
		elseif action=="DismantleFurniture" then
			local b=e.furniture and e.furniture[a.furnitureId];if not b then return "InvalidFurniture" end
			local items={};for id,n in pairs(rules.Furniture[b.kind].Cost) do if math.floor(n/2)>0 then table.insert(items,{Id=id,Quantity=math.floor(n/2)}) end end
			local problem=economy.items(data,items,"furniture_dismantle",emit);if problem then return problem end
			e.furniture[a.furnitureId]=nil
		elseif action=="GatherResource" then
			local node=rules.Nodes[a.nodeId];if not node then return "InvalidResource" end
			if (e.gatherReady[a.nodeId] or 0)>now then return "ResourceCooling" end
			local limit=if S.has(e,"warehouse") then 200 else 100
			if (data.inventory.stacks[node.Item] or 0)+2>limit then return "WarehouseFull" end
			local problem=economy.items(data,{{Id=node.Item,Quantity=2}},"gather",emit);if problem then return problem end
			e.gatherReady[a.nodeId]=now+node.Seconds;e.gathered[a.nodeId]=true
			if node.QuestNode then emit("regional_resource_gathered",{nodeId=a.nodeId,questNode=node.QuestNode}) end
		elseif action=="MoveGuildHall" then
			if not landPlacement then return "InvalidPlacement" end
			local valid,reason=landPlacement(data,"guildHall",a.x,a.z,a.rotation)
			if not valid then return reason end
			e.hallPosition=if a.x==-2 and a.z==-4.5 and a.rotation==0 then nil else {x=a.x,z=a.z,rotation=a.rotation}
		elseif action=="PlaceBuilding" or action=="MoveBuilding" or action=="RestoreBuilding" then
			local restoring=action=="RestoreBuilding"
			local b=if restoring then e.storage and e.storage[a.buildingId] else e.buildings[a.buildingId]
			local kind=if action~="PlaceBuilding" then b and b.kind else a.kind
			if not kind or not rules.Buildings[kind] then return "InvalidBuilding" end
			local valid,placementProblem
			local ignore=if b and not restoring then a.buildingId else nil
			if landPlacement then valid,placementProblem=landPlacement(data,kind,a.x,a.z,a.rotation,ignore)
			else valid=rules.placement(e.buildings,kind,a.x,a.z,a.rotation,ignore) end
			if not valid then return placementProblem or "InvalidPlacement" end
			if action=="PlaceBuilding" then
				local stored=false;for _,item in pairs(e.storage or {}) do if item.kind==kind then stored=true end end
				if S.has(e,kind) or stored or util.count(e.buildings)+util.count(e.storage or {})>=8 or e.nextBuilding>=1000000000 then return "BuildingLimit" end
				local problem=economy.consume(data,rules.Buildings[kind].Cost,"Construction",emit);if problem then return problem end
				local id="b:"..e.nextBuilding;e.nextBuilding+=1;e.buildings[id]={kind=kind,x=a.x,z=a.z,rotation=a.rotation}
			else
				b.x=a.x;b.z=a.z;b.rotation=a.rotation
				if restoring then e.buildings[a.buildingId]=b;e.storage[a.buildingId]=nil end
			end
		elseif action=="StoreBuilding" then
			local b=e.buildings[a.buildingId];if not b then return "InvalidBuilding" end
			if b.kind=="quarters" and util.count(data.adventurers)>5 then return "HousingOccupied" end
			e.storage=e.storage or {};e.storage[a.buildingId]=b;e.buildings[a.buildingId]=nil
		elseif action=="SaveBuildLayout" or action=="ApplyBuildLayout" or action=="DeleteBuildLayout" then
			if not util.integer(a.slot,1,3) then return "InvalidLayoutSlot" end
			local slot=tostring(a.slot);local layouts=e.layouts or {}
			if action=="SaveBuildLayout" then
				local placements={};for id,b in pairs(e.buildings) do placements[id]={x=b.x,z=b.z,rotation=b.rotation} end
				layouts[slot]=placements;e.layouts=layouts
				local furnishings={};for id,b in pairs(e.furniture or {}) do if not b.stored then furnishings[id]={x=b.x,z=b.z,rotation=b.rotation} end end
				e.layoutFurniture=e.layoutFurniture or {};e.layoutFurniture[slot]=furnishings
				e.layoutHalls=e.layoutHalls or {};e.layoutHalls[slot]=if e.hallPosition then util.copy(e.hallPosition) else false
			elseif not layouts[slot] then return "LayoutNotFound"
			elseif action=="DeleteBuildLayout" then layouts[slot]=nil;if e.layoutHalls then e.layoutHalls[slot]=nil end;if e.layoutFurniture then e.layoutFurniture[slot]=nil end
			else
				local placed,stored={},{}
				for id,b in pairs(e.buildings) do stored[id]=util.copy(b) end
				for id,b in pairs(e.storage or {}) do stored[id]=util.copy(b) end
				for id,position in pairs(layouts[slot]) do
					local b=stored[id];if not b then return "LayoutBuildingMissing" end
					b.x=position.x;b.z=position.z;b.rotation=position.rotation;placed[id]=b;stored[id]=nil
				end
				if util.count(data.adventurers)>5 then
					local housing=false;for _,b in pairs(placed) do if b.kind=="quarters" then housing=true end end
					if not housing then return "HousingOccupied" end
				end
				local hall=e.hallPosition
				if e.layoutHalls and e.layoutHalls[slot]~=nil then hall=if e.layoutHalls[slot]==false then nil else util.copy(e.layoutHalls[slot]) end
				local furniture=util.copy(e.furniture or {})
				local saved=e.layoutFurniture and e.layoutFurniture[slot]
				if saved then
					for _,b in pairs(furniture) do b.stored=true end
					for id,p in pairs(saved) do
						local b=furniture[id];if not b then return "LayoutFurnitureMissing" end
						b.x=p.x;b.z=p.z;b.rotation=p.rotation;b.stored=false
					end
				end
				local candidate={expansion={buildings=placed,hallPosition=hall,furniture=furniture},guildLand=data.guildLand}
				if hall and landPlacement then local valid,reason=landPlacement(candidate,"guildHall",hall.x,hall.z,hall.rotation);if not valid then return reason end end
				for id,b in pairs(placed) do
					local valid,reason
					if landPlacement then valid,reason=landPlacement(candidate,b.kind,b.x,b.z,b.rotation,id)
					else valid=rules.placement(placed,b.kind,b.x,b.z,b.rotation,id) end
					if not valid then return reason or "InvalidPlacement" end
				end
				local valid,reason=rules.furniturePlacement(candidate,landPlacement);if not valid then return reason end
				e.buildings=placed;e.storage=stored;e.hallPosition=hall
				if e.furniture or saved then e.furniture=furniture end
			end
		elseif action=="DismantleBuilding" then
			local b=e.buildings[a.buildingId];if not b then return "InvalidBuilding" end
			if b.kind=="quarters" and util.count(data.adventurers)>5 then return "HousingOccupied" end
			local items={};for id,n in pairs(rules.Buildings[b.kind].Cost) do if math.floor(n/2)>0 then table.insert(items,{Id=id,Quantity=math.floor(n/2)}) end end
			local problem=economy.items(data,items,"dismantle",emit);if problem then return problem end
			e.buildings[a.buildingId]=nil
		elseif action=="CraftItem" then
			local recipe=rules.Recipes[a.recipeId];if not recipe then return "InvalidRecipe" end
			if not S.has(e,"forge") then return "ForgeRequired" end
			if data.personalGuild.buildings.guildHall<(recipe.HallLevel or 1) then return "HallRequired" end
			local problem=economy.consume(data,recipe.Cost,"Crafting",emit);if problem then return problem end
			local sequence=data.inventory.nextEquipmentSequence
			if sequence>=1000000000 then return "InventoryFull" end
			problem=economy.items(data,{{Id=recipe.Item,Quantity=1}},"craft:"..sequence,emit);if problem then return problem end
			data.inventory.nextEquipmentSequence+=1
			emit("item_crafted",{itemId=recipe.Item,equipment=content.Items[recipe.Item].Kind~="Material"})
		elseif action=="SelectRace" then
			if not rules.Races[a.raceId] then return "InvalidRace" end
			if e.raceChosen then return "RaceAlreadyChosen" end
			data.character.raceId=a.raceId;e.raceChosen=true
		elseif action=="StartTower" then
			if not data.character.classId then return "ActorNotReady" end
			if data.quests.active then return "FinishExpedition" end
			if e.tower.active then return "TowerActive" end
			if a.floor~=1 and a.floor~=6 then return "InvalidFloor" end
			if a.floor==6 and e.tower.checkpoint<5 then return "FloorLocked" end
			if e.tower.nextRun>=1000000000 then return "RunLimit" end
			e.tower.active={id="tower:"..e.tower.nextRun,floor=a.floor,state="Ready"};e.tower.nextRun+=1
		elseif action=="EnterTowerFloor" then
			local run=e.tower.active;if not run or run.state~="Ready" then return "TowerNotReady" end
			run.state="Fighting"
		elseif action=="LeaveTower" then
			if not e.tower.active then return "TowerNotReady" end
			e.tower.active=nil
		elseif action=="AdvanceClass" or action=="LearnSkill" or action=="EquipSkill" or action=="ResetSkills" then
			if e.tower.active and e.tower.active.state=="Fighting" then return "LeaveTowerFirst" end
			local actor=rules.actor(data,a.actorId);if not actor or not actor.classId then return "ActorNotReady" end
			local build=e.actors[a.actorId] or {tier=1,skills={}};e.actors[a.actorId]=build
			if action=="AdvanceClass" then
				local problem=rules.advanceProblem(data,actor,build,a.pathId);if problem then return problem end
				local path=rules.Paths[a.pathId]
				build.path=a.pathId;build.tier=path.Tier;build.equipped=nil
				if content.StatusAllocationAvailable then build.skills={};actor.statusAllocations=nil end
				if a.actorId=="player" then actor.tier=build.tier;actor.classPathId=a.pathId end
			elseif action=="LearnSkill" then
				local problem=rules.learnProblem(build,actor.level,a.skillId);if problem then return problem end
				build.skills[a.skillId]=true
			elseif action=="EquipSkill" then
				if not table.find(rules.allowedSkills(build,content.Character.Classes[actor.classId].SkillId),a.skillId) then return "SkillNotLearned" end
				build.equipped=a.skillId
			else
				if content.StatusAllocationAvailable then return "UseBuildPointReset" end
				if not next(build.skills) then return "NoSkillsToReset" end
				local problem=economy.gold(data,-10,"SkillReset",emit);if problem then return problem end
				build.skills={};build.equipped=nil
			end
		else return "InvalidAction" end
		emit("expansion_action",{action=action});return nil
	end
	function S.has(e: any,kind: string): boolean for _,b in pairs(e.buildings) do if b.kind==kind then return true end end;return false end
	-- Private server completion only. Clients can never declare a cleared floor.
	function S.finish(record: any,runId: string,floor: number,success: boolean): (any,any,any)
		local copy=util.copy(record);local data=copy.data;local tower=data.expansion.tower;local run=tower.active
		if not run or run.id~=runId or run.floor~=floor or run.state~="Fighting" then return nil,{code="StaleTowerRun"},{} end
		local events={};local function emit(name: string,payload: any) table.insert(events,{name=name,payload=payload}) end
		if not success then run.state="Failed";return copy,{code="OK"},{{name="tower_failed",payload={floor=floor}}} end
		local first=floor>tower.highest;local rewardXP=if first then 40+floor*10 else 8+floor*2
		local problem=economy.gold(data,if first then 15+floor*3 else 4+floor,"Tower",emit);if problem then return nil,{code=problem},{} end
		problem=economy.items(data,{{Id="stone",Quantity=if first then 4 else 1},{Id="iron_ore",Quantity=2}},"tower",emit);if problem then return nil,{code=problem},{} end
		for _,id in ipairs(data.party.adventurerIds) do problem=xp(data,data.adventurers[id],rewardXP);if problem then return nil,{code=problem},{} end end
		problem=xp(data,data.character,rewardXP);if problem then return nil,{code=problem},{} end
		tower.highest=math.max(tower.highest,floor);if floor>=5 then tower.checkpoint=5 end
		if floor==10 then tower.active=nil else run.floor+=1;run.state="Ready" end
		emit("tower_clear",{floor=floor,first=first});return copy,{code="OK"},events
	end
	return S
end
