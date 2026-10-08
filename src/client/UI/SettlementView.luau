--!strict
local Art=require(game.ReplicatedStorage.Shared.Config.Art)
local Journal=require(game.ReplicatedStorage.Shared.Data.JournalViewState)
local EmptyState=require(script.Parent.EmptyState)
local TavernState=require(game.ReplicatedStorage.Shared.Data.TavernViewState)
return function(ui: any)
	local T,card,text,button=ui.T,ui.card,ui.text,ui.button
	local chosen="woodland";local team: {[string]:boolean}={};local confirm=false;local replaceOffer:string?=nil;local category="Main"
	local journalFilter="All"
	return function(tab: string,data: any,catalog: any,busy: boolean)
		local s=data.settlement;local head=card(ui.scroll,tab)
		if tab~="Tavern" or not s.offer or replaceOffer~=s.offer.id then replaceOffer=nil end
		button(head,"Back to Guild",not busy,function() ui.navigate("Guild") end)
		if tab=="Journal" then
			local focused=ui.journalFocus and ui.journalFocus();if focused and catalog.Journal[focused] then category=catalog.Journal[focused].Category;journalFilter="All" end
			text(head,"Main and NPC quests are completed personally. Only marked field jobs can be dispatched.",16)
			button(head,T("Category")..": "..T(category),not busy,function() category=({Main="Side",Side="NPC",NPC="Main"})[category];ui.render(true) end)
			local labels={All="All tasks",Available="Available",Active="Active",Ready="Ready to turn in",Claimed="Claimed"}
			button(head,T("Quest view")..": "..T(labels[journalFilter]),not busy,function()
				journalFilter=({All="Available",Available="Active",Active="Ready",Ready="Claimed",Claimed="All"})[journalFilter];ui.render(true)
			end).Name="JournalFilter"
			local visibleCount=0
			for _,id in ipairs(catalog.JournalOrder) do local def=catalog.Journal[id];if def.Category~=category then continue end
				local state=Journal.describe(data,catalog,id);if not Journal.matches(state,journalFilter) then continue end
				visibleCount+=1
				local task=s.journal[id];local f=card(ui.scroll,T(def.Name));f.Name="Journal_"..id;text(f,def.Description,16)
				text(f,T("Reward")..": "..def.Gold.." Gold · "..def.XP.." XP",15)
				if def.NPC then text(f,T("Visit {npc} in the city to accept and turn in this quest.",{npc=T(def.NPC)}),15) end
				if task then
					text(f,T(if state.ready then "Ready to turn in" else task.state).." · "..state.progress.."/"..def.Count,16).Name="JournalProgress"
					if task.state=="Active" then button(f,if ui.isTracked(id) then "Stop tracking" else "Track quest",not busy,function() ui.trackQuest(id) end).Name="Track_"..id end
					if task.state=="Active" then
						if def.Item then text(f,"Required items are consumed when you claim this reward.",14) end
						button(f,"Claim task reward",state.ready and not busy,function() ui.act("ClaimTask",{questId=id}) end).Name="Claim_"..id
					end
				else
					local locked=state.locked
					button(f,if state.unavailable then "Regional encounters are not open yet." elseif locked then T("Complete {quest} first",{quest=T(catalog.Journal[def.Requires].Name)}) else "Accept quest",not busy and not locked,function() ui.act("AcceptTask",{questId=id}) end).Name="Accept_"..id
				end
			end
			if visibleCount==0 then
				EmptyState(ui.scroll,"no_quests",T)
				if journalFilter~="All" then button(head,"Show all tasks",not busy,function() journalFilter="All";ui.render(true) end).Name="ResetJournalFilter" end
			end
		elseif tab=="Tavern" then
			local state=TavernState(data,catalog,busy)
			local atGuild=not ui.atGuild or ui.atGuild()
			text(head,T("Tavern level")..": "..s.tavernLevel.." / "..catalog.Tavern.MaxLevel.." · "..T("Roster capacity")..": "..state.count.."/"..data.rosterCapacity,16)
			text(head,"Build and upgrade Hero Quarters to expand housing. Guild Hall limits the maximum capacity.",16)
			if s.tavernLevel<catalog.Tavern.MaxLevel then
				text(head,T("Upgrade cost")..": "..(s.tavernLevel*100).." Gold",14)
				text(head,T("Timber")..": "..state.timber.."/"..(s.tavernLevel*5).." · "..T("Stone")..": "..state.stone.."/"..(s.tavernLevel*3),14)
			end
			button(head,"Upgrade tavern",atGuild and state.upgradeProblem==nil,function() ui.act("UpgradeTavern") end).Name="UpgradeTavern"
			if not atGuild then text(head,"Return to your guild island to upgrade the tavern.",14).Name="TavernLocationReason"end
			if state.upgradeProblem then text(head,state.upgradeProblem,14).Name="TavernUpgradeReason" end
			local odds={};for i,rank in ipairs(catalog.Tavern.Ranks) do table.insert(odds,rank.." "..(catalog.Tavern.Odds[s.tavernLevel][i]/100).."%") end
			text(head,T("Rank odds")..": "..table.concat(odds," · "),15)
			text(head,T("Scouting costs {cost} Gold. Review the candidate before paying the separate hiring cost.",{cost=state.scoutCost}),15)
			text(head,T("Each of the {count} classes has an equal chance.",{count=#catalog.AdventurerOrder}),15)
			if catalog.RecruitmentTemplatesAvailable then text(head,"Each class has three equally likely named recruits. Their base stats match that class.",15) end
			if s.offer then local o=s.offer;local def=catalog.Adventurers[o.classId];local template=o.templateId and catalog.HeroTemplates and catalog.HeroTemplates[o.templateId]
				local f=card(ui.scroll,T(if template then template.Name else def.Name).." · "..T(o.classId).." · "..T("Rank").." "..o.rank);f.Name="TavernCandidate"
				text(f,T("Role")..": "..T(catalog.Roles[o.classId]).." · Lv1",16)
				text(f,T("Base health {health} · attack {attack} · defense {defense}",{health=def.Stats.Health,attack=def.Stats.Attack,defense=def.Stats.Defense}),15).Name="CandidateBaseStats"
				text(f,"Rank, level and equipment add to these base stats.",14)
				local weapon=catalog.Character.Classes[o.classId].Weapon
				text(f,T("Starting weapon included and equipped: {weapon}",{weapon=T(catalog.Items[weapon].Name)}),15).Name="CandidateWeapon"
				text(f,T("Recruitment: {amount} Gold",{amount=state.hireCost}),17)
				if data.gold>=state.hireCost then text(f,T("Gold after hiring: {gold}",{gold=data.gold-state.hireCost}),15) end
				button(f,"Hire candidate",state.hireProblem==nil,function() ui.act("HireHero",{offerId=o.id}) end).Name="HireCandidate"
				if state.hireProblem then text(f,state.hireProblem,14).Name="CandidateHireReason" end
			end
			button(head,T(if s.offer and replaceOffer then "Confirm replace candidate · {cost} Gold" elseif s.offer then "Replace candidate · {cost} Gold" else "Scout candidate · {cost} Gold",{cost=state.scoutCost}),state.scoutProblem==nil,function()
				if s.offer and replaceOffer~=s.offer.id then replaceOffer=s.offer.id;ui.render() else replaceOffer=nil;ui.act("ScoutHero") end end).Name="ScoutCandidate"
			if replaceOffer then
				text(head,"Replacing removes this candidate. The previous scouting fee is not refunded.",14)
				button(head,"Keep current candidate",not busy,function()replaceOffer=nil;ui.render()end).Name="CancelReplaceCandidate"
			end
			if state.scoutProblem then text(head,state.scoutProblem,14).Name="CandidateScoutReason" end
			local clinic=card(ui.scroll,"Recovery clinic");text(clinic,T("Elixirs")..": "..s.elixirs.." · "..catalog.ElixirGold.." Gold",16)
			if catalog.ElixirProductId>0 then button(clinic,"Buy Elixir with Robux",not busy and s.elixirs<99,function() game:GetService("MarketplaceService"):PromptProductPurchase(game.Players.LocalPlayer,catalog.ElixirProductId) end) end
			button(clinic,"Buy revival Elixir",not busy and data.gold>=catalog.ElixirGold,function() ui.act("BuyElixir") end)
			for id,h in pairs(data.adventurers) do
				if h.condition=="Dead" then
					button(clinic,T("Revive").." · "..T(h.name).." ["..h.rank.."] "..id,not busy and s.elixirs>0,function() ui.act("ReviveHero",{actorId=id}) end)
				elseif h.condition=="Injured" then
					text(clinic,T(h.name).." · "..T("Injured").." · "..math.max(0,(h.injuredUntil or 0)-ui.now()).."s",15)
				end
			end
		elseif tab=="Dispatch" then
			text(head,"FIELD OPERATIONS",15,Art.UI.Accent)
			text(head,"Jobs continue while offline. Main quests and NPC conversations cannot be dispatched.",16)
			local map=Instance.new("Frame");map.Name="WorldOverview";map.Size=UDim2.new(1,0,0,280);map.BackgroundColor3=Color3.fromRGB(24,43,51);map.ClipsDescendants=true;map.Parent=head
			local round=Instance.new("UICorner");round.CornerRadius=UDim.new(0,12);round.Parent=map
			for i=0,13 do local dot=Instance.new("Frame");dot.Size=UDim2.fromOffset(4,4);dot.Position=UDim2.fromScale(.23+i*.034,.4-math.sin(i/13*math.pi)*.11);dot.BackgroundColor3=Color3.fromRGB(171,157,119);dot.BorderSizePixel=0;dot.Parent=map end
			for _,id in ipairs(catalog.DispatchOrder) do local def=catalog.Dispatch[id]
				local island=Instance.new("Frame");island.AnchorPoint=Vector2.new(.5,.5);island.Position=UDim2.fromScale(def.X,def.Y);island.Size=UDim2.fromOffset(114,90);island.Rotation=if id=="woodland" then -12 else 14;island.BackgroundColor3=if id=="woodland" then Color3.fromRGB(65,111,88) elseif id=="quarry" then Color3.fromRGB(102,112,120) else Color3.fromRGB(112,85,126);island.Parent=map
				local c=Instance.new("UICorner");c.CornerRadius=UDim.new(.35,0);c.Parent=island
				local node=button(map,T(({woodland="Woodlands",quarry="Quarry",ruins="Ruins"})[id])..(if chosen==id then " ✓" else ""),not busy,function() chosen=id;confirm=false;ui.render() end)
				node.Name="Mission_"..id;node.AnchorPoint=Vector2.new(.5,.5);node.Size=UDim2.fromOffset(110,52);node.Position=UDim2.fromScale(def.X,def.Y)
			end
			local members={};local power=0;local away={}
			for _,job in pairs(s.jobs) do for _,id in ipairs(job.members) do away[id]=true end end
			if data.quests.active then for _,m in ipairs(data.quests.active.partySnapshot) do away[m.id]=true end end
			local ids={};for id in pairs(data.adventurers) do table.insert(ids,id) end;table.sort(ids)
			for _,id in ipairs(ids) do local h=data.adventurers[id]
				if away[id] or table.find(data.party.adventurerIds,id) or (h.condition and h.condition~="Healthy" and not (h.condition=="Injured" and ui.now()>=(h.injuredUntil or math.huge))) then team[id]=nil end
				if team[id] then table.insert(members,id);power+=h.level+(table.find(catalog.Tavern.Ranks,h.rank) or 1)-1 end
			end
			local def=catalog.Dispatch[chosen];local chance=math.clamp(def.BaseChance+power*def.PerLevel,5,100)
			local f=card(ui.scroll,def.Name);text(f,T("Success chance")..": "..chance.."% · "..def.Duration.."s",18)
			text(f,T("On failure per hero")..": "..T("Dead").." "..def.DeathOnFailure.."% · "..T("Injured").." "..def.InjuryOnFailure.."%",15)
			text(f,T("Overall death risk")..": "..string.format("%.2f%%",(100-chance)*def.DeathOnFailure/100).." · "..T("Injury recovery: 15 minutes. Death requires one Elixir."),15)
			local rewards={def.Gold.." Gold",def.XP.." XP"};for _,r in ipairs(def.Items) do table.insert(rewards,T(catalog.Items[r.Id].Name).." ×"..r.Quantity) end;text(f,table.concat(rewards," · "),15)
			text(f,T("Selected: {count}/{limit}",{count=#members,limit=5}),16)
			button(f,if confirm then "Confirm dispatch and risks" else "Review dispatch",not busy and #members>0,function() if not confirm then confirm=true;ui.render() else confirm=false;ui.act("DispatchTeam",{missionId=chosen,adventurerIds=members});team={} end end)
			text(f,"Remove heroes from your field party before assigning them to a remote job.",15)
			for _,id in ipairs(ids) do local h=data.adventurers[id];local available=not away[id] and not table.find(data.party.adventurerIds,id) and (not h.condition or h.condition=="Healthy" or (h.condition=="Injured" and ui.now()>=(h.injuredUntil or math.huge)))
				button(f,(if team[id] then "✓ " else "")..T(h.name).." · "..T(h.classId).." ["..h.rank.."] Lv"..h.level.." · "..id,available and not busy and (team[id] or #members<5),function() team[id]=not team[id];confirm=false;ui.render() end)
			end
			for id,job in pairs(s.jobs) do local j=card(ui.scroll,T(catalog.Dispatch[job.missionId].Name));local remaining=math.max(0,job.completeAt-ui.now());text(j,T("Team away")..": "..#job.members.." · "..remaining.."s",16)
				button(j,"Resolve expedition",not busy and remaining==0,function() ui.act("ClaimDispatch",{jobId=id}) end) end
			if s.lastDispatch then local result=card(ui.scroll,"Last expedition");text(result,if s.lastDispatch.success then "Success" else "Failed",18)
				for id,condition in pairs(s.lastDispatch.casualties) do text(result,T(data.adventurers[id].name).." · "..id.." · "..T(condition),15) end end
		end
	end
end
