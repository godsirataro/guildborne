--!strict
-- All mutations target the disposable command candidate. RNG runs once before persistence retries.
return function(content: any,economy: any,util: any,random: any?)
	local S={};local roll=random or math.random
	function S.refreshGoals(data: any)
		local achieved={Hall2=data.personalGuild.buildings.guildHall>=2,Roster2=util.count(data.adventurers)>=2,Forge=false,LearnedSkill=false}
		for _,building in pairs(data.expansion.buildings) do if building.kind=="forge" then achieved.Forge=true end end
		for _,build in pairs(data.expansion.actors) do if next(build.skills)~=nil then achieved.LearnedSkill=true end end
		for id,task in pairs(data.settlement.journal) do
			local goal=content.Journal[id].StateGoal
			if task.state=="Active" and goal and achieved[goal] then task.progress=content.Journal[id].Count end
		end
	end
	function S.progress(data: any,event: string)
		for id,task in pairs(data.settlement.journal) do local def=content.Journal[id]
			if task.state=="Active" and def.Event==event then task.progress=math.min(def.Count,task.progress+1) end
		end
	end
	function S.apply(data: any,action: string,a: any,emit: any): string?
		local gate=content.NoviceActionProblem(data,action);if gate then return gate end
		local s=data.settlement
		if action=="TravelZone" then
			local civic=content.CivicTravel and content.CivicTravel[a.zone]
			if a.zone~="City" and a.zone~="Guild" and a.zone~="Greenwood" and a.zone~="Ironveil" and a.zone~="Ashen" and not civic then return "InvalidZone" end
			if civic and (not s.journal[civic] or s.journal[civic].state~="Claimed")then return "CivicRouteLocked" end
			if data.expansion.tower.active then return "FinishExpedition" end
			if a.zone=="Guild" then S.progress(data,"VisitGuild") end;return nil
		elseif action=="AcceptTask" then
			local def=content.Journal[a.questId];if not def then return "InvalidQuest" end
			if def.RequiresRegionalCombat and content.RegionalCombatAvailable~=true then return "RegionalEncountersUnavailable" end
			if s.journal[a.questId] then return "QuestAlreadyAccepted" end
			if def.Requires and (not s.journal[def.Requires] or s.journal[def.Requires].state~="Claimed") then return "QuestLocked" end
			s.journal[a.questId]={state="Active",progress=0};S.refreshGoals(data);return nil
		elseif action=="ClaimTask" then
			local def=content.Journal[a.questId];local task=s.journal[a.questId]
			if not def or not task or task.state~="Active" then return "QuestNotActive" end
			if def.Item then local problem=economy.consume(data,{[def.Item]=def.Count},"NPCTask",emit);if problem then return problem end
			elseif task.progress<def.Count then return "TaskIncomplete" end
			local problem=economy.gold(data,def.Gold,"JournalReward",emit);if problem then return problem end
			local actors={};if data.character.classId then table.insert(actors,data.character) end
			for _,id in ipairs(data.party.adventurerIds) do table.insert(actors,data.adventurers[id]) end
			for _,actor in ipairs(actors) do if actor.xp+def.XP>content.Limits.XP then return "XPCap" end
				actor.xp+=def.XP;actor.level=content:LevelFromXP(actor.xp,content.ProfileLevelCap(data)) end
			task.state="Claimed";task.progress=def.Count;emit("journal_completed",{questId=a.questId});return nil
		end
		if action=="UpgradeQuarters" then
			local b=data.expansion.buildings[a.buildingId];if not b or b.kind~="quarters" then return "QuartersRequired" end
			local level=b.level or 1;if level>=9 or data.personalGuild.buildings.guildHall<level+2 then return "HallRequired" end
			local problem=economy.consume(data,{timber=8*level,stone=6*level},"HousingUpgrade",emit);if problem then return problem end
			problem=economy.gold(data,-60*level,"HousingUpgrade",emit);if problem then return problem end
			b.level=level+1;return nil
		end
		if action~="UpgradeTavern" and action~="ScoutHero" and action~="HireHero" then return "InvalidAction" end
		if data.quests.active or data.expansion.tower.active then return "FinishExpedition" end
		if action=="UpgradeTavern" then
			local level=s.tavernLevel;if level>=content.Tavern.MaxLevel then return "TavernMax" end
			if data.personalGuild.buildings.guildHall<=level then return "HallRequired" end
			local problem=economy.consume(data,{timber=5*level,stone=3*level},"TavernUpgrade",emit);if problem then return problem end
			problem=economy.gold(data,-100*level,"TavernUpgrade",emit);if problem then return problem end
			s.tavernLevel+=1;emit("tavern_upgraded",{level=s.tavernLevel});return nil
		elseif action=="ScoutHero" then
			if s.nextOffer>=1000000000 then return "SequenceCap" end
			if util.count(data.adventurers)>=content.RosterCapacity(data) then return "RosterFull" end
			local problem=economy.gold(data,-content.Tavern.ScoutCost,"Scouting",emit);if problem then return problem end
			local draw=roll(1,10000);local cumulative=0;local rank="F"
			for i,weight in ipairs(content.Tavern.Odds[s.tavernLevel]) do cumulative+=weight;if draw<=cumulative then rank=content.Tavern.Ranks[i];break end end
			s.offer={id="offer:"..s.nextOffer,classId=content.AdventurerOrder[roll(1,#content.AdventurerOrder)],rank=rank}
			if content.RecruitmentTemplatesAvailable then
				local pool=content.HeroTemplatePools[s.offer.classId]
				s.offer.templateId=pool[roll(1,#pool)]
			end
			s.nextOffer+=1;emit("hero_scouted",{rank=rank});return nil
		else
			if s.nextHero>=1000000000 then return "SequenceCap" end
			local offer=s.offer;if not offer or offer.id~=a.offerId then return "OfferExpired" end
			local template=offer.templateId and content.HeroTemplates[offer.templateId]
			if offer.templateId and (not template or template.Class~=offer.classId) then return "InvalidAdventurer" end
			if util.count(data.adventurers)>=content.RosterCapacity(data) then return "RosterFull" end
			local rankIndex=table.find(content.Tavern.Ranks,offer.rank) or 1
			local cost=content.Tavern.HireCost+(rankIndex-1)*10
			local problem=economy.gold(data,-cost,"HireHero",emit);if problem then return problem end
			local id="h:"..s.nextHero;local def=content.Adventurers[offer.classId]
			local xp=content.RecruitmentStartingXP(data)
			data.adventurers[id]={id=id,name=def.Name,classId=def.Class,rank=offer.rank,level=content:LevelFromXP(xp,content.ProfileLevelCap(data)),xp=xp,baseStats=util.copy(def.Stats),equipmentSlots={}}
			if offer.templateId then
				data.adventurers[id].templateId=template.Id;data.adventurers[id].name=template.Name
			end
			data.progression.recruitedClasses[def.Class]=true
			local weapon=content.Character.Classes[def.Class].Weapon
			problem=economy.items(data,{{Id=weapon,Quantity=1}},"hire:"..s.nextHero,emit);if problem then return problem end
			data.adventurers[id].equipmentSlots.weapon="hire:"..s.nextHero..":1"
			s.nextHero+=1;s.offer=nil;emit("hero_hired",{classId=def.Class,rank=offer.rank});return nil
		end
	end
	return S
end
