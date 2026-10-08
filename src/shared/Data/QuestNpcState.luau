--!strict
-- Per-player presentation only. Quest rewards and proximity remain server-owned.
return function(data: any,catalog: any,npc: string,all: boolean?): any
	if not data or not data.settlement or not catalog or not catalog.Journal then return if all then {} else nil end
	local journal=data.settlement.journal;local choices: {any}={}
	for order,id in ipairs(catalog.JournalOrder) do
		local def=catalog.Journal[id]
		if (def.NPC or "City Herald")~=npc then continue end
		local entry=journal[id];local state,priority="",0
		if not entry and def.RequiresRegionalCombat and catalog.RegionalCombatAvailable~=true then continue end
		if entry and entry.state=="Active" then
			local progress=if def.Item then data.inventory.stacks[def.Item] or 0 else entry.progress
			state=if progress>=def.Count then "Ready to turn in" else "Quest in progress"
			priority=if progress>=def.Count then 3 else 1
		elseif not entry and (not def.Requires or (journal[def.Requires] and journal[def.Requires].state=="Claimed")) then
			state="Quest available";priority=2
		end
		if priority>0 then
			table.insert(choices,{id=id,state=state,priority=priority,order=order,symbol=if priority==3 then "?" elseif priority==2 then "!" else "..."})
		end
	end
	table.sort(choices,function(a:any,b:any)return if a.priority==b.priority then a.order<b.order else a.priority>b.priority end)
	return if all then choices else choices[1]
end
