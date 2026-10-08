--!strict
-- Read-only projection of one-item crafting readiness. Server remains authoritative.
return function(data:any,catalog:any,rules:any,id:string,busy:boolean):any
    local recipe=assert(rules.Recipes[id],"Unknown recipe")
    local item=assert(catalog.Items[recipe.Item],"Unknown output")
    local rows={};local missing=false;local ids={}
    for material in pairs(recipe.Cost) do table.insert(ids,material) end;table.sort(ids)
    for _,material in ipairs(ids) do
        local owned=data.inventory.stacks[material] or 0;local needed=recipe.Cost[material]
        table.insert(rows,{id=material,owned=owned,needed=needed,missing=math.max(0,needed-owned)})
        if owned<needed then missing=true end
    end
    local forge=false;for _,building in pairs(data.expansion.buildings) do if building.kind=="forge" then forge=true end end
    local equipment=0;for _ in pairs(data.inventory.equipment) do equipment+=1 end
    local problem:string?=nil;local params:any=nil
    if busy then problem="Waiting for the current action."
    elseif not forge then problem="Build a Blacksmith first."
    elseif data.hallLevel<(recipe.HallLevel or 1) then problem="Requires Hall Lv{level}";params={level=recipe.HallLevel or 1}
    elseif missing then problem="Gather or earn the required materials first."
    elseif data.inventory.nextEquipmentSequence>=1000000000 then problem="Crafting is unavailable. Contact support."
    elseif item.Kind~="Material" and equipment>=catalog.EquipmentLimit then problem="Free an equipment slot before crafting."
    elseif item.Kind=="Material" and (data.inventory.stacks[recipe.Item] or 0)-(recipe.Cost[recipe.Item] or 0)+1>catalog.StackLimit then problem="This material stack is full."
    end
    return {materials=rows,problem=problem,params=params,canCraft=problem==nil,itemId=recipe.Item,equipmentCount=equipment,equipmentLimit=catalog.EquipmentLimit}
end
