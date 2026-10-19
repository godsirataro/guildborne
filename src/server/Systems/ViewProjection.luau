--!strict
return function(content: any, progression: any, util: any, expansion: any?, bestiary: any?, land: any?,noviceChapter:any?,campaignChapter:any?,permanentPasses:any?,appearance:any?,launch:any?,class3:any?)
	local catalog = { HeroTemplates=util.copy(content.HeroTemplates),Bestiary=if bestiary then util.copy(bestiary) else nil, Tavern=util.copy(content.Tavern),HallUpgrades=util.copy(content.HallUpgrades),Journal=util.copy(content.Journal),JournalOrder=util.copy(content.JournalOrder),Dispatch=util.copy(content.Dispatch),DispatchOrder=util.copy(content.DispatchOrder),ElixirProductId=content.Elixir.DeveloperProductId,ElixirGold=content.Elixir.Gold,RosterLimit=content.Limits.Roster,
		Expansion=if expansion then {Buildings=expansion.Buildings,BuildingOrder=expansion.BuildingOrder,Nodes=expansion.Nodes,Paths=expansion.Paths,Skills=expansion.Skills,SkillOrder=expansion.SkillOrder,Abilities=expansion.Abilities,Recipes=expansion.Recipes,Races=expansion.Races} else nil, Items = util.copy(content.Items), ItemOrder = util.copy(content.ItemOrder),
		Adventurers = util.copy(content.Adventurers), AdventurerOrder = util.copy(content.AdventurerOrder),
		Quests = util.copy(content.Quests), QuestOrder = util.copy(content.QuestOrder), Hall = util.copy(content.Hall),
		StackLimit = content.Limits.Stack, EquipmentLimit = content.Limits.Equipment, Character = util.copy(content.Character), PartyLimit = content.Limits.Party, Roles = util.copy(content.Roles),
	}
	return function(session: any, mode: string, now: number): any
		catalog.ReleaseContent=if launch and launch.Release.Enabled then {Id=launch.Release.Id,MaxLevel=launch.Release.MaxLevel,MaxHall=launch.Release.MaxHall} else nil
		if catalog.ReleaseContent then
			local blocked={}
			for id in pairs(content.Journal) do if launch.Release.problem({},"AcceptTask",{questId=id}) then blocked[id]=true end end
			catalog.ReleaseContent.BlockedTasks=blocked
			catalog.ReleaseContent.TowerUnavailable=launch.Release.problem({},"StartTower",{floor=1})~=nil
			local zones,nodes={},{}
			if expansion then for id,node in pairs(expansion.Nodes)do
				if launch.Release.problem({},"GatherResource",{nodeId=id}) then nodes[id]=true end
				if node.Region and launch.Release.problem({},"TravelZone",{zone=node.Region}) then zones[node.Region]=true end
			end end
			catalog.ReleaseContent.BlockedZones=zones;catalog.ReleaseContent.BlockedNodes=nodes
		end
		catalog.NoviceChapter=if noviceChapter then util.copy(noviceChapter) else nil
		catalog.CampaignChapter=if campaignChapter then util.copy(campaignChapter) else nil
		catalog.RegionalCombatAvailable=content.RegionalCombatAvailable==true
		catalog.StatusAllocationAvailable=content.StatusAllocationAvailable==true
		catalog.RecruitmentTemplatesAvailable=content.RecruitmentTemplatesAvailable==true
		catalog.AppearanceAvailable=content.AppearanceAvailable==true and appearance~=nil and appearance.Service~=nil
		catalog.AppearancePreviewPolicy=if catalog.AppearanceAvailable then {AllowPlaceholders=true,AllowedPresets=util.copy(appearance.Policy.AllowedPresets),AllowedAssets=util.copy(appearance.Policy.AllowedAssets),ApprovedFits=util.copy(appearance.Policy.ApprovedFits),StarterEntitlements=util.copy(appearance.Policy.StarterEntitlements),Evidence=appearance.Policy.Evidence} else nil
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
		view.data.recruitmentLevel=content:LevelFromXP(content.RecruitmentStartingXP(data),content.ProfileLevelCap(data))
		if view.data.expansion then for _,build in pairs(view.data.expansion.actors)do build.mentorProof=nil;build.class3Proof=nil end end
		if launch and launch.Mentor then view.data.heroMentor=launch.Mentor.presentation(data) end
		-- Derived qualification only: world admission still checks live anchor/session state.
		-- Never copy a policy return table or a saved proof into the public view.
		if class3 and class3.Proof and expansion and expansion.usesNoviceProgression(data) then
			local proof=class3.Proof
			local actors={player=data.character};for actorId,actor in pairs(data.adventurers)do actors[actorId]=actor end
			local readiness={}
			for actorId,actor in pairs(actors)do
				local build=expansion.build(data,actorId)
				local parent=build.path and expansion.Paths[build.path]
				if build.tier==2 and parent and parent.Tier==2 and parent.Class==actor.classId then
					local paths={}
					for pathId,path in pairs(expansion.Paths)do
						if path.Tier==3 and path.Class==actor.classId and (not path.Parent or path.Parent==build.path) then
							local releaseProblem=if launch and launch.Release and launch.Release.Enabled then launch.Release.problem(data,"AdvanceClass",{actorId=actorId,pathId=pathId}) else nil
							local trialProblem=releaseProblem or proof.problem(data,actorId,pathId)
							if not trialProblem then
								if actorId=="player" and class3.PlayerProblem then trialProblem=class3.PlayerProblem(data,pathId)
								elseif actorId~="player" and class3.Trial then trialProblem=class3.Trial.class3Problem(data,actorId,pathId)end
							end
							local advanceProblem=releaseProblem or proof.advanceProblem(data,actorId,pathId)
							paths[pathId]={proven=proof.hasProof(data,actorId,pathId)==true,
								trialProblem=if type(trialProblem)=="string" then trialProblem elseif trialProblem~=nil then "Class3TrialUnavailable" else nil,
								advanceProblem=if type(advanceProblem)=="string" then advanceProblem elseif advanceProblem~=nil then "Class3ProofRequired" else nil}
						end
					end
					readiness[actorId]=paths
				end
			end
			view.data.class3Proofs=readiness
		end
		if catalog.ReleaseContent and expansion then
			local actors={player=data.character};for id,actor in pairs(data.adventurers)do actors[id]=actor end
			local problems={}
			for actorId,actor in pairs(actors)do
				local paths={}
				for id,path in pairs(expansion.Paths)do
					if path.Class==actor.classId then paths[id]=launch.Release.problem(data,"AdvanceClass",{actorId=actorId,pathId=id}) end
				end
				problems[actorId]=paths
			end
			view.data.releaseAdvancementProblems=problems
		end
		if launch and launch.Rewards then view.data.launchRewards=launch.Rewards.view(data,now) end
		if catalog.AppearanceAvailable then
			local function projectAppearance(actor:any)
				actor.appearance,actor.appearanceRevision,actor.appearanceEnabled=appearance.Service.read(actor)
			end
			projectAppearance(view.data.character)
			for _,actor in pairs(view.data.adventurers) do projectAppearance(actor) end
		end
		local nextHall=content.HallUpgrades[data.personalGuild.buildings.guildHall]
		local releaseAllowsHall=not launch or not launch.Release.Enabled or (nextHall and nextHall.To<=launch.Release.MaxHall)
		view.data.nextHallLevelCap=if nextHall and releaseAllowsHall then content.HallLevelCap(nextHall.To,content.ProgressionMode(data)) else nil
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
