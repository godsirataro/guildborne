--!strict
-- Pure projection from the server snapshot. Pinning is presentation-only.
local tutorialTabs={welcome="Guild",recruit="Party",party="Party",quest="Quests",claim="Quests",equip="Inventory",roster="Party",supplies="Quests",upgrade="Guild"}
return function(data: any,catalog: any,pinned: string?): any
	if not data or not catalog or not data.settlement then return nil end
	local novice=data.progression and data.progression.novice
	if novice and novice.claimed<6 and catalog.NoviceChapter then
		if novice.claimed==5 and not data.character.classId then return {kind="Novice",tab="Guild",name=if novice.trialClass then "Confirm first class"else "Complete a solo class trial to choose that class.",ready=false}end
		local chapter=catalog.NoviceChapter.Chapters[novice.claimed+1]
		for _,objective in ipairs(chapter.Objectives)do
			if not novice.objectives[objective]then return {kind="Novice",tab="Guild",name=catalog.NoviceChapter.ObjectiveLabels[objective][if data.language=="th"then 2 else 1],ready=false}end
		end
		return {kind="Novice",tab="Guild",name=if novice.claimed==5 then "Found my guild"else "Claim chapter XP in the Guild menu.",ready=true}
	end
	local campaign=data.progression and data.progression.campaign
	if campaign and catalog.CampaignChapter and (campaign.hallPermit or 0)>(data.hallLevel or 0) then
		local nextHall=(data.hallLevel or 0)+1
		for index,chapter in ipairs(catalog.CampaignChapter.Chapters) do
			if chapter.HallPermit==nextHall and campaign.claimed>=index then
				return {kind="Campaign",tab="Guild",focus="UpgradeGuildHall",name=(if data.language=="th"then "กลับเกาะกิลด์ · อัปเกรดหอระดับ "else "Return to guild island · Upgrade Hall ")..nextHall,ready=false}
			end
		end
	end
	if campaign and catalog.CampaignChapter and campaign.claimed<#catalog.CampaignChapter.Chapters then
		local chapter=catalog.CampaignChapter.Chapters[campaign.claimed+1]
		if chapter.Hall and (data.hallLevel or 0)<chapter.Hall then return {kind="Campaign",tab="Guild",name=(if data.language=="th"then "กลับเกาะกิลด์ · อัปเกรดหอระดับ "else "Return to guild island · Upgrade Hall ")..chapter.Hall,ready=false}end
		for _,objective in ipairs(chapter.Objectives)do
			if not campaign.objectives[objective]then return {kind="Campaign",tab="Guild",name=catalog.CampaignChapter.ObjectiveLabels[objective][if data.language=="th"then 2 else 1],ready=false}end
		end
		return {kind="Campaign",tab="Guild",name=if data.language=="th"then "รับรางวัลบทนี้ในเมนูกิลด์"else "Claim chapter rewards in the Guild menu.",ready=true}
	end
	local journal=data.settlement.journal
	local function active(id: string): any
		local def=catalog.Journal[id];local task=journal[id]
		if not def or not task or task.state~="Active" then return nil end
		local progress=math.clamp(if def.Item then data.inventory.stacks[def.Item] or 0 else task.progress,0,def.Count)
		return {id=id,kind="Active",name=def.Name,description=def.Description,progress=progress,count=def.Count,ready=progress>=def.Count,npc=def.NPC,tab="Journal"}
	end
	if pinned then local item=active(pinned);if item then return item end end
	local step=data.progression and data.progression.tutorialStep
	if step and tutorialTabs[step] then return {kind="Tutorial",step=step,tab=tutorialTabs[step]} end
	for _,id in ipairs(catalog.JournalOrder) do local item=active(id);if item then return item end end
 local chapters=catalog.CampaignChapter and catalog.CampaignChapter.Chapters
 if campaign and chapters and #chapters>0 and campaign.claimed==#chapters then
  local last=chapters[#chapters]
  if last.Title and last.Thai then return {kind="CampaignComplete",tab="Guild",focus="CampaignJourney",name=if data.language=="th"then last.Thai else last.Title,ready=false}end
 end
	for _,id in ipairs(catalog.JournalOrder) do
		local def=catalog.Journal[id]
		if def.RequiresRegionalCombat and catalog.RegionalCombatAvailable~=true then continue end
		local unlocked=not def.Requires or (journal[def.Requires] and journal[def.Requires].state=="Claimed")
		if not journal[id] and unlocked then return {id=id,kind="Available",name=def.Name,description=def.Description,npc=def.NPC,tab="Journal"} end
	end
	return nil
end
