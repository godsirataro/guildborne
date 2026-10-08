--!strict
return function(test:any,eq:any)
    local catalog=require("../src/server/Config/AdventureEncounters")
    local profiles=require("../src/server/Config/AdventureEnemyProfiles")
    local rewards=require("../src/server/Config/AdventureRewards")
    local stats=require("../src/server/Systems/AdventureStats")
    local make=require("../src/server/Systems/AdventureFieldGuide")
    local order=require("../src/shared/Config/City").RegionOrder
    test("regional guide statistics and rewards match all twelve runtime definitions",function()
        local regions=make(catalog,profiles,rewards,stats,order);eq(#regions,3);local count=0
        for index,region in ipairs(regions) do
            eq(region.Id,order[index]);eq(#region.Entries,4)
            for _,entry in ipairs(region.Entries) do
                count+=1;local actual=stats.build(profiles[entry.Id],entry.Role)
                eq(entry.Health,actual.MaxHealth);eq(entry.Attack,actual.Attack);eq(entry.Defense,actual.Defense)
                eq(entry.Range,actual.AttackRange);eq(entry.Interval,actual.AttackInterval)
                eq(entry.Gold,rewards[entry.Id].Gold);eq(entry.XP,rewards[entry.Id].XP);eq(entry.Items,rewards[entry.Id].Items)
                eq(entry.QuestEvent,rewards[entry.Id].Event)
                local matched=false;for _,source in ipairs(catalog.Regions[region.Id].Encounters) do if source.Asset==entry.Id then eq(entry.Marker,source.Marker);matched=true end end
                assert(matched)
                assert(type(entry.Note)=="string" and #entry.Note>10)
            end
        end
        eq(count,12);eq(regions[2].Entries[2].Defense,15)
        regions[1].Entries[4].Items[1].Quantity=999;eq(rewards.forest_captain.Items[1].Quantity,2)
    end)
end
