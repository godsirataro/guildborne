--!strict
return function(catalog:any,profiles:any,rewards:any,stats:any,order:{string}):{any}
    local notes={
        Melee="Keep your frontline close and support behind it.",
        Ranged="Close the distance while keeping your healer protected.",
        Guard="Heavy defense reduces direct damage. Keep a healer supporting your frontline.",
        Support="This enemy heals wounded allies. Focus it before the frontline.",
        Charge="Leave the marked attack area before the charge lands.",
        Spell="Move out of the marked spell circle before impact.",
        Boss="Below half health, this boss alternates two marked attacks.",
    }
    local specific={
        forest_captain="Step away from the antler cone. Below half health, also watch for root bursts.",
        quarry_guardian="Leave the hammer circle. Below half health, sidestep the fault line.",
        arcane_warden="Sidestep the rune lance. Below half health, the nova has a safe inner circle.",
        rune_hound="Move out of the marked landing circle before the hound strikes.",
    }
    local regions={}
    for _,id in ipairs(order) do
        local entries={}
        for _,entry in ipairs(catalog.Regions[id].Encounters) do
            local s=stats.build(profiles[entry.Asset],entry.Role);local reward=rewards[entry.Asset];local items={}
            for _,item in ipairs(reward.Items) do table.insert(items,{Id=item.Id,Quantity=item.Quantity}) end
            table.insert(entries,{Id=entry.Asset,Name=stats.title(entry.Asset),Boss=entry.Role=="Boss",Role=entry.Role,QuestEvent=reward.Event,Marker=entry.Marker,
                Health=s.MaxHealth,Attack=s.Attack,Defense=s.Defense,Range=s.AttackRange,Interval=s.AttackInterval,
                Gold=reward.Gold,XP=reward.XP,Items=items,Note=specific[entry.Asset] or notes[entry.Role]})
        end
        table.insert(regions,{Id=id,Name=id,Entries=entries})
    end
    return regions
end
