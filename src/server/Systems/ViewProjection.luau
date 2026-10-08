--!strict
return function(content: any, progression: any, util: any, expansion: any?, bestiary: any?, land: any?,noviceChapter:any?,campaignChapter:any?,permanentPasses:any?)
	local catalog = { HeroTemplates=util.copy(content.HeroTemplates),Bestiary=if bestiary then util.copy(bestiary) else nil, Tavern=util.copy(content.Tavern),HallUpgrades=util.copy(content.HallUpgrades),Journal=util.copy(content.Journal),JournalOrder=util.copy(content.JournalOrder),Dispatch=util.copy(content.Dispatch),DispatchOrder=util.copy(content.DispatchOrder),ElixirProductId=content.Elixir.DeveloperProductId,ElixirGold=content.Elixir.Gold,RosterLimit=content.Limits.Roster,
		Expansion=if expansion then {Buildings=expansion.Buildings,BuildingOrder=expansion.BuildingOrder,Nodes=expansion.Nodes,Paths=expansion.Paths,Skills=expansion.Skills,SkillOrder=expansion.SkillOrder,Abilities=expansion.Abilities,Recipes=expansion.Recipes,Races=expansion.Races} else nil, Items = util.copy(content.Items), ItemOrder = util.copy(content.ItemOrder),
		Adventurers = util.copy(content.Adventurers), AdventurerOrder = util.copy(content.AdventurerOrder),
		Quests = util.copy(content.Quests), QuestOrder = util.copy(content.QuestOrder), Hall = util.copy(content.Hall),
		StackLimit = content.Limits.Stack, EquipmentLimit = content.Limits.Equipment, Character = util.copy(content.Character), PartyLimit = content.Limits.Party, Roles = util.copy(content.Roles),
	}
	return function(session: any, mode: string, now: number): any
		catalog.NoviceChapter=if noviceChapter then util.copy(noviceChapter) else nil
		catalog.CampaignChapter=if campaignChapter then util.copy(campaignChapter) else nil
		catalog.RegionalCombatAvailable=content.RegionalCombatAvailable==true
		catalog.StatusAllocationAvailable=content.StatusAllocationAvailable==true
		catalog.RecruitmentTemplatesAvailable=content.RecruitmentTemplatesAvailable==true
		local view: any = { status = if session then session.state else "Loading", problem = if session then session.problem else nil,
			mode = mode, serverTime = now, catalog = catalog, revision = 0 }
		if not session or not session.record then return view end
		local data = session.record.data
		view.revision = session.record.revision
		-- Explicit projection: no lease tokens, audit history, or operation receipts.
		view.data = { settlement=util.copy(data.settlement),rosterCapacity=content.RosterCapacity(data),levelCap=content.ProfileLevelCap(data), expansion=util.copy(data.expansion), character = util.copy(data.character), gold = data.currencies.gold, adventurers = util.copy(data.adventurers), party = util.copy(data.party),
			inventory = util.copy(data.inventory), hallLevel = data.personalGuild.buildings.guildHall,
			progression = util.copy(data.progression), quests = util.copy(data.quests), language = data.settings.language or "en" }
		view.data.settlement.purchases=nil
		local nextHall=content.HallUpgrades[data.personalGuild.buildings.guildHall]
		view.data.nextHallLevelCap=if nextHall then content.HallLevelCap(nextHall.To,content.ProgressionMode(data)) else nil
		-- Theme purchase references remain server-only, including on stored buildings.
		if view.data.expansion then
			local owned={};for id in pairs(data.expansion.themeRights or {}) do owned[id]=true end
			view.data.expansion.themeRights=owned
		end
		view.data.permanentPassOffers={Land={},Theme={}}
		if permanentPasses and permanentPasses.Enabled then
			for _,def in pairs(permanentPasses.Catalog.ById) do
				view.data.permanentPassOffers[def.kind][def.key]=permanentPasses.Offers.resolve(data,def.kind,def.key)=="OK"
			end
		end
		if land and data.guildLand then
			view.data.guildLand={plots={},accessMode=data.guildLand.accessMode or "Private"}
			for id,def in pairs(land.catalog) do
				local state=data.guildLand.plots[id];local display=land.rules.describe(data.guildLand,id)
				local quests={};local eligible=true
				for _,quest in ipairs(def.quests) do local done=data.quests.firstClears[quest]==true;quests[quest]=done;if not done then eligible=false end end
				view.data.guildLand.plots[id]={name=def.name,status=display.status,questEligible=eligible,quests=quests,
					materials=util.copy(def.materials),delivered=if state then util.copy(state.delivered) else {},
					purchased=state~=nil and state.entitlement~=nil,purchaseAvailable=view.data.permanentPassOffers.Land[id]==true}
			end
		end
		for _,job in pairs(view.data.settlement.jobs) do job.success=nil;job.casualties=nil end
		local c=view.data.character
		if c.classId then
			c.stats=progression.stats(data,data.character)
		end
		for id, adventurer in pairs(view.data.adventurers) do adventurer.stats = progression.stats(data, data.adventurers[id]) end
		return view
	end
end
