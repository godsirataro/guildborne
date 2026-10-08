--!strict
-- Read-only journal projection. Item objectives use current stock; claimed tasks
-- remain complete after those items have been consumed by authoritative turn-in.
local Journal={}
function Journal.describe(data: any,catalog: any,id: string): any
    local def=catalog.Journal[id];if not def then return nil end
    local task=data.settlement.journal[id]
    if task and task.state=="Claimed" then return {state="Claimed",progress=def.Count,ready=false,locked=false} end
    if task and task.state=="Active" then
        local progress=math.clamp(if def.Item then data.inventory.stacks[def.Item] or 0 else task.progress,0,def.Count)
        return {state="Active",progress=progress,ready=progress>=def.Count,locked=false}
    end
    local prerequisite=def.Requires and data.settlement.journal[def.Requires]
	if def.RequiresRegionalCombat and catalog.RegionalCombatAvailable~=true then return {state="Locked",progress=0,ready=false,locked=true,unavailable=true} end
    local locked=def.Requires~=nil and (not prerequisite or prerequisite.state~="Claimed")
    return {state=if locked then "Locked" else "Available",progress=0,ready=false,locked=locked}
end
function Journal.matches(state: any,filter: string): boolean
    if filter=="All" then return true end
    if filter=="Ready" then return state.ready end
    return state.state==filter
end
return Journal
