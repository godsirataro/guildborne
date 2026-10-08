--!strict
return function(content: any, economy: any, campaignEnabled: boolean?, campaignConfig:any?)
	return function(data: any, emit: any): string?
		if data.quests.active or (data.expansion and data.expansion.tower.active) then return "FinishExpedition" end
		local def=content.HallUpgrades[data.personalGuild.buildings.guildHall]
		if not def then return "HallAlreadyUpgraded" end
		local campaign=data.progression and data.progression.campaign
		local permitChapter=if data.personalGuild.buildings.guildHall==1 then 6 else nil
		if campaignConfig then for i,chapter in ipairs(campaignConfig.Chapters)do if chapter.HallPermit==def.To then permitChapter=i end end end
		local campaignGate=campaignEnabled==true and content.ProgressionMode(data)==content.ProgressionRulesets.Novice
		if campaignGate then
			-- An unselected future arc has no permit chapter. It must stay locked,
			-- not fall back to the legacy Quarry Patrol gate after the last arc.
			if not permitChapter or not campaign or campaign.claimed<permitChapter or not campaign.hallPermit or campaign.hallPermit<def.To then return "CampaignHallLocked" end
		elseif not data.quests.firstClears[def.RequiredQuest] then return "HallLocked" end
		local problem=economy.consume(data,def.Materials,"GuildUpgrade",emit);if problem then return problem end
		problem=economy.gold(data,-def.Gold,"GuildUpgrade",emit);if problem then return problem end
		data.personalGuild.buildings.guildHall=def.To
		local function unlock(a: any) a.level=content:LevelFromXP(a.xp,content.ProfileLevelCap(data)) end
		unlock(data.character);for _,a in pairs(data.adventurers) do unlock(a) end
		emit("guild_upgraded",{buildingId="guildHall",level=def.To,goldCost=def.Gold});return nil
	end
end
