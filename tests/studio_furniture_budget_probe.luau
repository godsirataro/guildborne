--!strict
return function()
    assert(game.PlaceId==0 and game.GameId==0,"Offline fixture only")
    local shared=game.ReplicatedStorage.Shared
    local rules=require(shared.Data.Expansion)
    local validate=require(shared.Data.LandBuildingPlacement)(rules,require(shared.Data.IslandPlacement),require(shared.Config.GuildIslandLayout))
    local data:any={expansion={buildings={},furniture={}}}
    for i=1,32 do data.expansion.furniture["f:"..i]={kind="hearth_chair",stored=false,x=6+(i-1)%8*.5,z=2+math.floor((i-1)/8)*.5,rotation=0} end
    local timings={}
    for _=1,20 do
        local started=os.clock();assert(rules.furniturePlacement(data,validate));table.insert(timings,(os.clock()-started)*1000)
    end
    table.sort(timings)
    return {pieces=32,samples=20,medianMs=timings[10],maxMs=timings[20],profileWrites=0,measures="Shared route validation CPU only, not frame rate"}
end
