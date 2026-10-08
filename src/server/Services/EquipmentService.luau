--!strict
-- Mutates only the disposable command candidate. The whole transfer commits atomically.
return function(content: any,economy: any,gear: any)
	local E={}
	function E.assign(data: any,args: any,emit: any): string?
		local actor=gear.actor(data,args.actorId)
		local item=data.inventory.equipment[args.instanceId]
		if not actor or not actor.classId then return "ActorNotReady" end
		if not item then return "ItemNotOwned" end
		local def=content.Items[item.definitionId]
		if not gear.compatible(def,actor.classId) then return "IncompatibleEquipment" end
		local owner,slot=gear.owner(data,args.instanceId)
		if owner==args.actorId then return "AlreadyEquipped" end
		if owner and slot then gear.actor(data,owner).equipmentSlots[slot]=nil end
		actor.equipmentSlots[def.Slot]=args.instanceId
		data.progression.everEquipped=true
		emit("equipment_assigned",{itemId=item.definitionId,actorId=args.actorId,fromActor=owner,slot=def.Slot})
		return nil
	end
	function E.unequip(data: any,args: any,emit: any): string?
		local actor=gear.actor(data,args.actorId)
		if not actor or not actor.classId then return "ActorNotReady" end
		if not table.find(gear.Slots,args.slot) then return "InvalidSlot" end
		local id=actor.equipmentSlots[args.slot]
		if not id then return "SlotEmpty" end
		actor.equipmentSlots[args.slot]=nil
		emit("equipment_removed",{actorId=args.actorId,slot=args.slot})
		return nil
	end
	function E.buy(data: any,args: any,emit: any): string?
		local def=content.Items[args.definitionId]
		if not def or not def.Price then return "ItemNotForSale" end
		if data.personalGuild.buildings.guildHall<(def.HallLevel or 1) then return "HallRequired" end
		local sequence=data.inventory.nextEquipmentSequence
		if sequence>=1000000000 then return "InventoryFull" end
		local problem=economy.gold(data,-def.Price,"EquipmentPurchase",emit)
		if problem then return problem end
		problem=economy.items(data,{{Id=def.Id,Quantity=1}},"shop:"..sequence,emit)
		if problem then return problem end
		data.inventory.nextEquipmentSequence+=1
		return nil
	end
	function E.sell(data: any,args: any,emit: any): string?
		local item=data.inventory.equipment[args.instanceId]
		if not item then return "ItemNotOwned" end
		if gear.owner(data,args.instanceId) then return "UnequipBeforeSelling" end
		local def=content.Items[item.definitionId]
		if not def.Price then return "ItemNotForSale" end
		local problem=economy.gold(data,math.floor(def.Price/2),"EquipmentSale",emit)
		if problem then return problem end
		data.inventory.equipment[args.instanceId]=nil
		emit("item_destroyed",{itemId=def.Id,quantity=1,reason="EquipmentSale"})
		return nil
	end
	return E
end
