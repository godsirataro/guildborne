--!strict
-- Observe committed snapshots only. Initial, duplicate and stale snapshots stay silent.
return function()
    local revision:number?=nil
    local levels:{[string]:number}={}
    return function(view:any,response:boolean):string?
        if response and view.code and view.code~="OK" and view.code~="AlreadyCommitted" and view.code~="SavePending" then return "error" end
        if view.status~="Active" or not view.data or type(view.revision)~="number" then return nil end
        if revision and view.revision<=revision then return nil end
        local previous=revision;revision=view.revision
        local current:{[string]:number}={player=view.data.character.level}
        local recruited=false;local increased=false
        for id,hero in pairs(view.data.adventurers) do current[id]=hero.level end
        if previous then for id,level in pairs(current) do
            if levels[id] and level>levels[id] then increased=true
            elseif id~="player" and not levels[id] then recruited=true end
        end end
        levels=current
        if not previous then return nil end
        if recruited then return "recruit_reveal" end
        if increased then return "level_up" end
        if response and view.code=="OK" then
            return if view.result and view.result.reward then "reward" else "confirm"
        end
        return nil
    end
end
