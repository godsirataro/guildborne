--!strict
-- Server-only candidate builder. No network action maps to this module.
return function(content: any, config: any, util: any, economy: any,regional:any?)
	return function(record: any, members: {string},encounterId:string?): (any,any,any)
		local reward=if encounterId then regional and regional[encounterId] else config.Goblin.Reward
		if not reward then return nil,{code="InvalidEncounter"},{} end
		local copy=util.copy(record); local events={}
		local function emit(name: string,payload: any) table.insert(events,{name=name,payload=payload}) end
		if #members==0 or #members>content.Limits.Party+1 then return nil,{code="InvalidParty"},{} end
		local seen={}
		for _,id in ipairs(members) do
			local hero=if id=="player" then copy.data.character else copy.data.adventurers[id]
			if not hero or not hero.classId or seen[id] then return nil,{code="InvalidParty"},{} end
			seen[id]=true
			if hero.xp+reward.XP>content.Limits.XP then return nil,{code="XPCap"},{} end
			hero.xp+=reward.XP; hero.level=content:LevelFromXP(hero.xp,content.ProfileLevelCap(copy.data))
		end
		if copy.data.settlement then for id,task in pairs(copy.data.settlement.journal) do
			local def=content.Journal[id];if task.state=="Active" and def.Event==(if encounterId then reward.Event else "Goblin") then task.progress=math.min(def.Count,task.progress+1) end
		end end
		local reason=if encounterId then "encounter:"..encounterId else "goblin_combat"
		local problem=economy.gold(copy.data,reward.Gold,reason,emit)
		if problem then return nil,{code=problem},{} end
		if reward.Items and #reward.Items>0 then
			problem=economy.items(copy.data,reward.Items,reason,emit)
			if problem then return nil,{code=problem},{} end
		end
		emit("combat_reward",{gold=reward.Gold,xp=reward.XP,members=#members,encounterId=encounterId})
		return copy,{code="OK"},events
	end
end
