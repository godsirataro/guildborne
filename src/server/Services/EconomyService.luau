--!strict
return function(content: any, util: any)
	local Economy = {}
	function Economy.gold(data: any, delta: number, reason: string, emit: any): string?
		local balance = data.currencies.gold + delta
		if not util.integer(balance, 0, content.Limits.Gold) then return if balance < 0 then "InsufficientGold" else "WalletFull" end
		data.currencies.gold = balance
		if delta > 0 then data.statistics.goldCreated += delta else data.statistics.goldDestroyed -= delta end
		if delta ~= 0 then emit(if delta > 0 then "gold_created" else "gold_destroyed", { amount = math.abs(delta), reason = reason, balance = balance }) end
		return nil
	end
	function Economy.items(data: any, items: any, prefix: string, emit: any): string?
		local weaponIndex = 0
		for _, reward in ipairs(items) do
			local definition = content.Items[reward.Id]
			if not definition or not util.integer(reward.Quantity, 1, content.Limits.Stack) then return "InvalidItem" end
			if definition.Kind == "Material" then
				local total = (data.inventory.stacks[reward.Id] or 0) + reward.Quantity
				if total > content.Limits.Stack then return "InventoryFull" end
				data.inventory.stacks[reward.Id] = total
			else
				if util.count(data.inventory.equipment) + reward.Quantity > content.Limits.Equipment then return "InventoryFull" end
				for _ = 1, reward.Quantity do
					weaponIndex += 1
					local id = prefix .. ":" .. tostring(weaponIndex)
					if data.inventory.equipment[id] then return "DuplicateItem" end
					data.inventory.equipment[id] = { definitionId = reward.Id, upgradeLevel = 0, binding = "Account" }
				end
			end
			emit("item_acquired", { itemId = reward.Id, quantity = reward.Quantity, source = prefix })
		end
		return nil
	end
	function Economy.consume(data: any, materials: any, reason: string, emit: any): string?
		for itemId, amount in pairs(materials) do if (data.inventory.stacks[itemId] or 0) < amount then return "MissingMaterials" end end
		for itemId, amount in pairs(materials) do
			local remaining = data.inventory.stacks[itemId] - amount
			data.inventory.stacks[itemId] = if remaining > 0 then remaining else nil
			emit("item_destroyed", { itemId = itemId, quantity = amount, reason = reason })
		end
		return nil
	end
	return Economy
end
