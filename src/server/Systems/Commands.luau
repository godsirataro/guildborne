--!strict
-- Only this dispatcher composes domain mutations, always against a disposable copy.
return function(deps: any)
	local Commands = {}
	function Commands.apply(record: any, command: any, now: number): (any, any, any)
		local valid, code = deps.Protocol.validate(command)
		if not valid then return nil, { code = code }, {} end
		if deps.Content then local gate=deps.Content.NoviceActionProblem(record.data,command.action);if gate then return nil,{code=gate},{} end end
		local copy = deps.Util.copy(record)
		local data = copy.data
		for _,hero in pairs(data.adventurers) do if hero.condition=="Injured" and now>=(hero.injuredUntil or math.huge) then hero.condition="Healthy";hero.injuredUntil=nil end end
		if data.expansion and data.expansion.tower.active and data.expansion.tower.active.state=="Fighting" and ({AssignEquipment=true,UnequipEquipment=true,EquipItem=true})[command.action] then return nil,{code="LeaveTowerFirst"},{} end
		local edits={AssignEquipment=true,UnequipEquipment=true,EquipItem=true,AdvanceClass=true,LearnSkill=true,EquipSkill=true,ResetSkills=true}
		if edits[command.action] and data.settlement then
			local id=command.args.actorId or command.args.adventurerId
			for _,job in pairs(data.settlement.jobs) do for _,member in ipairs(job.members) do
				if member==id then return nil,{code="HeroUnavailable"},{} end
				if command.args.instanceId then for _,owned in pairs(data.adventurers[member].equipmentSlots) do if owned==command.args.instanceId then return nil,{code="HeroUnavailable"},{} end end end
			end end
		end
		local events = {}
		local function emit(name: string, payload: any) table.insert(events, { name = name, payload = payload }) end
		local problem: string? = nil
		local result: any = { code = "OK" }
		if command.action=="AllocateStatus" or command.action=="ResetBuildPoints" then
			problem=if deps.Status then deps.Status.apply(data,command.action,command.args,emit) else "StatusUnavailable"
		elseif ({SetGuildAccess=true,UnlockGuildPlot=true,ContributeGuildPlot=true,OpenGuildPlot=true})[command.action] then
			problem=if deps.GuildLand then deps.GuildLand.apply(data,command.action,command.args,emit) else "LandUnavailable"
		elseif command.action == "SetLanguage" then
			data.settings.language = command.args.language
		elseif command.action == "BeginTutorial" then
			if not data.progression.welcomeSeen then data.progression.welcomeSeen = true; emit("tutorial_started", {}) end
		elseif command.action == "ClaimCampaignChapter" or command.action == "ClaimCampaignRecruit" then
			problem=if deps.Campaign then deps.Campaign.claim(data,command.args.chapterId,command.args.heroClass,emit)else "CampaignUnavailable"
		elseif command.action == "ClaimNoviceChapter" or command.action == "FoundNoviceGuild" then
			problem=if deps.NoviceStory then deps.NoviceStory.claim(data,if command.action=="FoundNoviceGuild" then "MAIN_00_06" else command.args.chapterId,command.args.heroClass,emit) else "NoviceUnavailable"
		elseif command.action == "SelectPlayerClass" then
			if data.progression.novice then problem=if deps.NoviceStory then deps.NoviceStory.selectClass(data,command.args.classId,emit) else "NoviceUnavailable"
			else problem = deps.Character(data, command.args, emit) end
		elseif ({DispatchTeam=true,ClaimDispatch=true,BuyElixir=true,ReviveHero=true})[command.action] then problem=deps.Dispatch.apply(data,command.action,command.args,now,emit)
		elseif ({TravelZone=true,UpgradeQuarters=true,UpgradeTavern=true,ScoutHero=true,HireHero=true,AcceptTask=true,ClaimTask=true})[command.action] then problem=deps.Settlement.apply(data,command.action,command.args,emit)
		elseif command.action == "Recruit" then problem = deps.Adventurers.recruit(data, command.args, emit)
		elseif command.action == "UpdateParty" and data.expansion and data.expansion.tower.active then problem="LeaveTowerFirst"
		elseif command.action == "UpdateParty" then problem = deps.Party(data, command.args, emit)
		elseif command.action == "StartQuest" and data.expansion and data.expansion.tower.active then problem="LeaveTowerFirst"
		elseif command.action == "StartQuest" then problem = deps.Quests.start(data, command.args, now, emit)
		elseif command.action == "CompleteQuest" then
			local extra
			problem, extra = deps.Quests.complete(data, command.args, now, emit)
			if extra then result.reward = extra.reward; result.questName = extra.questName end
		elseif command.action == "AssignEquipment" then problem = deps.Equipment.assign(data,command.args,emit)
		elseif command.action == "UnequipEquipment" then problem = deps.Equipment.unequip(data,command.args,emit)
		elseif command.action == "SellEquipment" then problem = deps.Equipment.sell(data,command.args,emit)
		elseif command.action == "BuyEquipment" then problem = deps.Equipment.buy(data,command.args,emit)
		elseif command.action == "EquipItem" then
			-- Compatibility adapter for the original weapon-only intent.
			local owned=data.inventory.equipment[command.args.instanceId]
			if not owned then problem="ItemNotOwned"
			elseif not data.adventurers[command.args.adventurerId] then problem="AdventurerNotOwned"
			else problem=deps.Equipment.assign(data,{instanceId=command.args.instanceId,actorId=command.args.adventurerId},emit)
				if problem=="IncompatibleEquipment" then problem="IncompatibleWeapon" end
			end
		elseif command.action == "UpgradeGuildHall" then problem = deps.Guild(data, emit)
		else problem = if deps.Expansion then deps.Expansion.apply(data,command.action,command.args,now,emit) else "InvalidAction" end
		if problem then return nil, { code = problem }, {} end
		if command.action=="GatherResource" then deps.Settlement.progress(data,"Gather:"..command.args.nodeId) end
		for _,event in ipairs(events) do if event.name=="regional_resource_gathered" then
			deps.Settlement.progress(data,"Gather:"..event.payload.questNode)
		end end
		if command.action=="AssignEquipment" or command.action=="EquipItem" then deps.Settlement.progress(data,"Equip") end
		if command.action=="EnterTowerFloor" then deps.Settlement.progress(data,"EnterTower") end
		for _,event in ipairs(events) do if event.name=="item_crafted" then
			deps.Settlement.progress(data,"Craft:"..event.payload.itemId)
			if event.payload.equipment then deps.Settlement.progress(data,"CraftEquipment") end
		end end
		deps.Settlement.refreshGoals(data)
		data.progression.tutorialStep = deps.Progression.tutorial(data)
		if data.progression.tutorialStep == "complete" and not data.progression.tutorialCompleted then
			data.progression.tutorialCompleted = true; emit("tutorial_completed", {})
		end
		return copy, result, events
	end
	return Commands
end
