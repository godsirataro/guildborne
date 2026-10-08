--!strict
-- Informational only: no discovery claims, grants, combat inputs or save writes.
return function(ui: any)
	local floor = 1
	local regionIndex=1
	local T, card, text, button = ui.T, ui.card, ui.text, ui.button
	return function(catalog: any, busy: boolean)
		local head = card(ui.scroll, "Bestiary")
		button(head, "Back to Guild", not busy, function() ui.navigate("Guild") end)
		text(head, "Study enemy roles before assembling your company.", 16)
		local guide = catalog.Bestiary
		if not guide then text(head, "Enemy information is unavailable. Reopen after your guild loads.", 16); return end
		local function show(parent: Instance, entry: any, note: string,hideName:boolean?)
			if not hideName then text(parent, entry.Name, 20) end
			text(parent, T("Health {hp} · Attack {attack}", {hp = entry.Health, attack = entry.Attack}), 16)
			if entry.Defense then
				text(parent, T("Defense {defense} · Range {range} studs · Interval {seconds}s", {defense = entry.Defense, range = entry.Range, seconds = entry.Interval}), 16)
			end
			text(parent, note, 16)
		end
		local camp = card(ui.scroll, "Goblin Camp"); camp.Name = "CampEntry"
		show(camp, guide.Camp, "A close-range fighter. Let your Knight take the lead while ranged companions support.")
		local expedition = card(ui.scroll, "Timed expeditions"); expedition.Name = "ExpeditionEntry"
		show(expedition, guide.Expedition, "Expedition encounter values differ from enemies fought in the world.")
		local tower = card(ui.scroll, T("Tower · Floor {floor}", {floor = floor})); tower.Name = "TowerEntries"
		text(tower, "Preview any floor. This does not unlock travel or claim rewards.", 14)
		button(tower, "Previous floor", floor > 1 and not busy, function() floor -= 1; ui.render() end).Name = "PreviousFloor"
		button(tower, "Next floor", floor < #guide.Floors and not busy, function() floor += 1; ui.render() end).Name = "NextFloor"
		for _, entry in ipairs(guide.Floors[floor]) do
			show(tower, entry, if entry.Boss then "Leave the red circle before impact. Below half health, the Warden alternates its slam with a wider pulse."
				elseif entry.Range > 5 then "A ranged defender. Close the distance with your frontline while supporting it."
				else "A melee defender. Keep your support companions behind the frontline.")
		end
		if guide.Regions and #guide.Regions>0 then
			regionIndex=math.clamp(regionIndex,1,#guide.Regions)
			local regional=card(ui.scroll,"Regional field guide");regional.Name="RegionalGuide"
			text(regional,if guide.RegionalCombatAvailable then "Challenge these enemies beyond the safe arrival docks." else "Regional encounters are not open yet.",14)
			text(regional,"Arrival docks are safe. Bring companions and a healer before entering combat.",16)
			for index,region in ipairs(guide.Regions) do
				button(regional,region.Name,not busy and index~=regionIndex,function()regionIndex=index;ui.render()end).Name="Region_"..region.Id
			end
			for _,entry in ipairs(guide.Regions[regionIndex].Entries) do
				local frame=card(ui.scroll,entry.Name);frame.Name="Enemy_"..entry.Id
				show(frame,entry,entry.Note,true)
				text(frame,T("Reward: {gold} Gold · {xp} XP per credited member",{gold=entry.Gold,xp=entry.XP}),15)
				for _,item in ipairs(entry.Items) do text(frame,T("{item} × {amount}",{item=T(catalog.Items[item.Id].Name),amount=item.Quantity}),15) end
			end
		end
	end
end
