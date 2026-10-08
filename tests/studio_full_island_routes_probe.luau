--!strict
-- Copies current island geometry into a disposable distant scene; no paid/profile grants.
return function()
    assert(game.PlaceId==0 and game.GameId==0,"Offline fixture only")
    local player=game.Players:GetPlayers()[1];local source:Model?=nil
    for _,m in ipairs(workspace.GuildborneWorld:GetChildren()) do if m:IsA("Model") and m:GetAttribute("OwnerUserId")==player.UserId then source=m;break end end
    assert(source)
    local clone=source:Clone();clone.Name="FullIslandRouteProbe"
    local offset=Vector3.new(5000,0,3000);clone:PivotTo(clone:GetPivot()+offset);clone.Parent=workspace
    for _,v in ipairs(clone:GetDescendants()) do if v:IsA("ProximityPrompt") then v:Destroy() end end
    local origin=(source:GetAttribute("PlotOrigin") :: Vector3)+offset
    local env=assert(clone:FindFirstChild("Environment"));local buildings=assert(env:FindFirstChild("Buildings"))
    local hall:Model?=nil;for _,m in ipairs(buildings:GetChildren()) do if m:IsA("Model") and m.Name:match("^GuildHallLv") then hall=m;break end end
    assert(hall)
    local templates=require(game.ServerScriptService.Server.Services.ArtKit).Build()
    local plot:any={model=clone,origin=origin,buildings=buildings,hall=hall,hallStation=clone:FindFirstChild("Guild Hall",true),level=clone:GetAttribute("HallLevel") or 1}
    local Sync=require(game.ServerScriptService.Server.Services.GuildHallWorld)
    local Land=require(game.ServerScriptService.Server.Services.GuildLandWorld)
    local results={};local checks=0
    local ok,reason=pcall(function()
        Land.sync(plot,{guildLand={plots={grove={status="Buildable"},quarry={status="Buildable"},summit={status="Buildable"}}}})
        task.wait(.5)
        for _,area in ipairs({{id="grove",z=-4},{id="quarry",z=2},{id="summit",z=8}}) do
            for rotation=0,3 do
                Sync(plot,templates,2,{x=-12,z=area.z,rotation=rotation})
                local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=3})
                path:ComputeAsync(origin+Vector3.new(0,4,23),plot.hall:GetPivot()*Vector3.new(0,4,4))
                assert(path.Status==Enum.PathStatus.Success,area.id.." rotation "..rotation..": "..path.Status.Name);checks+=1
                for _,point in ipairs(path:GetWaypoints()) do assert(point.Action~=Enum.PathWaypointAction.Jump);checks+=1 end
                table.insert(results,{plot=area.id,rotation=rotation,waypoints=#path:GetWaypoints()})
            end
        end
    end)
    clone:Destroy();templates:Destroy();assert(ok,reason)
    return {checks=checks,routes=results,profileWrites=0,purchases=0,fixtureDestroyed=true}
end
