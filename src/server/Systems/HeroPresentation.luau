--!strict
-- Read-only presentation derived from the committed public projection, never a profile writer.
return function(content: any, gear: any)
	return function(data: any): { any }
		local selected: { [string]: number } = {}
		for index, id in ipairs(data.party.adventurerIds) do if index <= content.Limits.Party then selected[id] = index end end
		local away: { [string]: boolean } = {}
		if data.quests.active then
			for _, member in ipairs(data.quests.active.partySnapshot) do away[member.id] = true end
		end
		local result = {};local entries={}
		for index,class in ipairs(content.AdventurerOrder) do if data.adventurers["a:"..class] or not data.progression.recruitedClasses[class] then table.insert(entries,{id="a:"..class,class=class,index=index}) end end
		local ids={};for id in pairs(data.adventurers) do if id:sub(1,2)=="h:" then table.insert(ids,id) end end;table.sort(ids)
		for _,id in ipairs(ids) do local h=data.adventurers[id];table.insert(entries,{id=id,class=h.classId,index=table.find(content.AdventurerOrder,h.classId) or 1}) end
		if data.settlement then for _,job in pairs(data.settlement.jobs) do for _,id in ipairs(job.members) do away[id]=true end end end
		for _,entry in ipairs(entries) do
			local id,class,index=entry.id,entry.class,entry.index
			local hero = data.adventurers[id]
			local weaponId = hero and hero.equipmentSlots.weapon
			local owned = weaponId and data.inventory.equipment[weaponId]
			local definition = owned and content.Items[owned.definitionId]
			table.insert(result, {
				build=if hero then gear.build(data,hero) else {tier=1,skills={}}, extra=if hero then gear.extras(data,hero) else nil,
				id = id, class = class, index = index, name = if hero then hero.name else content.Adventurers[class].Name,templateId=if hero then hero.templateId else nil,rank=if hero then hero.rank or "F" else "F",visible=not hero or selected[id]~=nil or id=="a:"..class,
				cost = content.Adventurers[class].Cost, level = if hero then hero.level else 1,
				state = if not hero then "Available" elseif hero.condition=="Dead" then "Dead" elseif hero.condition=="Injured" then "Injured" elseif away[id] then "On expedition" elseif selected[id] then "Following" else "Resting at guild",
				slot = if hero then selected[id] else nil,
				armor = if hero then gear.loadout(data,hero).armor else nil, accessory = if hero then gear.loadout(data,hero).accessory else nil,
				weapon = if definition and definition.Class == class then owned.definitionId else nil,
			})
		end
		return result
	end
end
