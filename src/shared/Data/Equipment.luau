--!strict
-- Pure catalog rules shared by authoritative services and display-only comparisons.
return function(content: any,rules: any?,statusRules:any?)
	local E={Slots={"weapon","armor","accessory"}}
	function E.validStatus(actor:any):boolean
		return if statusRules then statusRules.validate(actor.level,actor.statusAllocations) else actor.statusAllocations==nil
	end
	function E.build(data: any,actor: any): any return if rules then rules.build(data,actor.id or "player") else {tier=1,skills={}} end
	function E.extras(data: any,actor: any): any
		local extra=if rules then rules.bonuses(E.build(data,actor),actor.raceId) else {Health=0,Attack=0,Defense=0,Speed=0}
		local rank=math.max(0,(table.find(content.Tavern.Ranks,actor.rank or "F") or 1)-1)
		extra.Health+=rank*2;extra.Attack+=rank;extra.Defense+=math.floor(rank/3)
		if statusRules then for key,value in pairs(statusRules.bonuses(actor.classId,actor.statusAllocations)) do extra[key]=(extra[key] or 0)+value end end
		return extra
	end
	function E.compatible(def: any,class: string?): boolean
		return def~=nil and class~=nil and (def.Class=="Any" or def.Class==class or (def.Classes~=nil and def.Classes[class]==true))
	end
	function E.actor(data: any,id: string): any
		return if id=="player" then data.character else data.adventurers[id]
	end
	function E.weaponHint(data:any,actor:any):string?
		if not actor or actor==data.character or (actor.equipmentSlots and actor.equipmentSlots.weapon) then return nil end
		for _,owned in pairs(data.inventory.equipment) do
			local def=content.Items[owned.definitionId]
			if def and def.Slot=="weapon" and E.compatible(def,actor.classId) then return "No weapon equipped. Choose a compatible weapon from your inventory." end
		end
		if actor.classId=="Warrior" and not data.quests.firstClears.trail_watch then return "Complete Trail Watch to earn Rowan's Training Sword, then equip it here." end
		return "No compatible weapon owned. Earn one through quests or visit the equipment shop."
	end
	function E.loadout(data: any,actor: any): any
		local result={}
		for _,slot in ipairs(E.Slots) do
			local id=actor.equipmentSlots and actor.equipmentSlots[slot]
			local owned=id and data.inventory.equipment[id]
			if owned then result[slot]=owned.definitionId end
		end
		if actor==data.character and actor.classId and not result.weapon then result.weapon=content.Character.Classes[actor.classId].Weapon end
		return result
	end
	function E.bonuses(loadout: any,class: string): any
		local total={Health=0,Attack=0,Defense=0,WeaponBonus=0}
		for _,slot in ipairs(E.Slots) do
			local id=loadout[slot]
			if id then
				local def=content.Items[id]
				if not E.compatible(def,class) or def.Slot~=slot then return nil end
				for _,key in ipairs({"Health","Attack","Defense"}) do total[key]+=def[key] or 0 end
				if slot=="weapon" then total.WeaponBonus=def.Attack or 0 end
			end
		end
		return total
	end
	function E.owner(data: any,instanceId: string): (string?,string?)
		local actors={player=data.character}
		for id,actor in pairs(data.adventurers) do actors[id]=actor end
		for id,actor in pairs(actors) do
			for _,slot in ipairs(E.Slots) do if actor.equipmentSlots and actor.equipmentSlots[slot]==instanceId then return id,slot end end
		end
		return nil,nil
	end
	return E
end
