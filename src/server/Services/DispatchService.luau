--!strict
return function(content: any,economy: any,util: any,random: any?)
	local S={};local roll=random or math.random
	function S.available(data: any,id: string): boolean
		local actor=data.adventurers[id];if not actor or (actor.condition and actor.condition~="Healthy") then return false end
		if data.settlement then for _,job in pairs(data.settlement.jobs) do if table.find(job.members,id) then return false end end end
		return true
	end
	function S.apply(data: any,action: string,a: any,now: number,emit: any): string?
		local s=data.settlement
		if action=="BuyElixir" then
			if s.elixirs>=99 then return "InventoryFull" end
			local problem=economy.gold(data,-content.Elixir.Gold,"Elixir",emit);if problem then return problem end
			s.elixirs+=1;return nil
		elseif action=="ReviveHero" then
			local hero=data.adventurers[a.actorId];if not hero or hero.condition~="Dead" then return "HeroNotDead" end
			if s.elixirs<1 then return "ElixirRequired" end
			s.elixirs-=1;hero.condition="Healthy";hero.injuredUntil=nil;emit("hero_revived",{actorId=a.actorId});return nil
		elseif action=="DispatchTeam" then
			if s.nextJob>=1000000000 then return "SequenceCap" end
			local def=content.Dispatch[a.missionId];if not def then return "InvalidQuest" end
			if util.count(s.jobs)>=3 then return "DispatchFull" end
			if #a.adventurerIds<1 or #a.adventurerIds>5 then return "InvalidParty" end
			local members={};local seen={};local power=0
			for _,id in ipairs(a.adventurerIds) do
				if seen[id] or not S.available(data,id) or table.find(data.party.adventurerIds,id) then return "HeroUnavailable" end
				if data.quests.active then for _,m in ipairs(data.quests.active.partySnapshot) do if m.id==id then return "HeroUnavailable" end end end
				seen[id]=true;table.insert(members,id);local hero=data.adventurers[id]
				power+=hero.level+(table.find(content.Tavern.Ranks,hero.rank or "F") or 1)-1
			end
			local chance=math.clamp(def.BaseChance+power*def.PerLevel,5,100)
			local success=roll(1,100)<=chance;local casualties={}
			if not success then for _,id in ipairs(members) do local n=roll(1,100)
				casualties[id]=if n<=def.DeathOnFailure then "Dead" elseif n<=def.DeathOnFailure+def.InjuryOnFailure then "Injured" else "Healthy" end end
			local id="job:"..s.nextJob;s.nextJob+=1
			s.jobs[id]={id=id,missionId=def.Id,members=members,startAt=now,completeAt=now+def.Duration,chance=chance,
				success=success,casualties=casualties,reward={Gold=def.Gold,XP=def.XP,Items=util.copy(def.Items)}}
			emit("team_dispatched",{missionId=def.Id,chance=chance});return nil
		elseif action=="ClaimDispatch" then
			local job=s.jobs[a.jobId];if not job then return "QuestNotActive" end
			if now<job.completeAt then return "QuestTooEarly" end
			if job.success then
				local problem=economy.gold(data,job.reward.Gold,"DispatchReward",emit);if problem then return problem end
				problem=economy.items(data,job.reward.Items,job.id,emit);if problem then return problem end
				for _,id in ipairs(job.members) do local h=data.adventurers[id];if h.xp+job.reward.XP>content.Limits.XP then return "XPCap" end
					h.xp+=job.reward.XP;h.level=content:LevelFromXP(h.xp,content.ProfileLevelCap(data)) end
			else for id,condition in pairs(job.casualties) do local h=data.adventurers[id];h.condition=condition
				if condition=="Injured" then h.injuredUntil=now+900 end end end
			s.lastDispatch={missionId=job.missionId,success=job.success,casualties=util.copy(job.casualties)};s.jobs[job.id]=nil
			emit("dispatch_claimed",{missionId=job.missionId,success=job.success});return nil
		end
		return "InvalidAction"
	end
	return S
end
