--!strict
-- Run only in owned offline memory Play. Disposable world fixture; no profile writes.
return function()
    assert(game.PlaceId==0 and game.GameId==0,"Offline fixture only")
    local Layout=require(game.ReplicatedStorage.Shared.Config.GuildIslandLayout)
    local World=require(game.ServerScriptService.Server.Services.GuildLandWorld)
    local fixture=Instance.new("Model");fixture.Name="LandWorldProbe";fixture.Parent=workspace
    local plot={model=fixture,origin=Vector3.new(0,1,2000)}
    local data:any={guildLand={plots={}}};local checks=0
    local function check(value:boolean)assert(value,"Land world check "..(checks+1));checks+=1 end
    local ok,problem=pcall(function()
        World.sync(plot,data)
        local folder=fixture:FindFirstChild("GuildLand") :: Folder
        check(#folder:GetChildren()==3)
        for _,model in ipairs(folder:GetChildren()) do check(model:FindFirstChild("Ground")==nil) end
        data.guildLand.plots.grove={questUnlocked=true,entitlement={reference="test-only"},delivered={}}
        World.sync(plot,data);check((folder:FindFirstChild("grove") :: Model):FindFirstChild("Ground")==nil)
        -- Direct opened flag is a render fixture, never a purchase or profile grant.
        for id in pairs(Layout.Plots) do data.guildLand.plots[id]={opened=true} end
        World.sync(plot,data)
        local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={fixture};params.RespectCanCollide=true
        game:GetService("RunService").Heartbeat:Wait()
        for id,layout in pairs(Layout.Plots) do
            local model=folder:FindFirstChild(id) :: Model
            local ground=model:FindFirstChild("Ground") :: BasePart
            check(ground.CanCollide and ground.Size==Vector3.new(layout.width,2,layout.depth))
            for _,dx in ipairs({-24,0,24}) do for _,dz in ipairs({-16,0,16}) do
                local hit=workspace:Raycast(plot.origin+Vector3.new(layout.x+dx,10,layout.z+dz),Vector3.new(0,-20,0),params)
                check(hit~=nil and (hit :: RaycastResult).Position.Y>=plot.origin.Y-.01 and (hit :: RaycastResult).Position.Y<=plot.origin.Y+.31)
            end end
            local bridge=model:FindFirstChild("AccessBridge") :: BasePart
            check(bridge.CanCollide and bridge.Position.X-bridge.Size.X/2< -40 and bridge.Position.X+bridge.Size.X/2> -39)
            World.sync(plot,data);check(model==folder:FindFirstChild(id))
        end
        local access=Instance.new("Part");access.Name="ExistingCoreAccessFixture";access.Size=Vector3.new(12,2,160)
        access.Position=plot.origin+Vector3.new(-34,-1,40);access.Anchored=true;access.Parent=fixture
        local buildings=Instance.new("Folder");buildings.Name="Buildings";buildings.Parent=fixture
        local builtPlot:any={model=fixture,origin=plot.origin,expansionFolder=buildings,built={}}
        local expansion=require(game.ServerScriptService.Server.Services.ExpansionWorld)(function()end,function()end)
        expansion.sync(builtPlot,{expansion={buildings={a={kind="warehouse",x=-11,z=-3,rotation=0},b={kind="quarters",x=-11,z=3,rotation=1},c={kind="forge",x=-11,z=9,rotation=2}}}})
        task.wait(1)
        for _,entrance in ipairs({Vector3.new(-80,3,-4),Vector3.new(-68,3,32),Vector3.new(-80,3,68)}) do
            local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=3})
            path:ComputeAsync(plot.origin+Vector3.new(-34,3,0),plot.origin+entrance)
            check(path.Status==Enum.PathStatus.Success)
            for _,waypoint in ipairs(path:GetWaypoints()) do check(waypoint.Action~=Enum.PathWaypointAction.Jump) end
        end
        check(Layout.SlotSpacing+Layout.Bounds.minX>Layout.Bounds.maxX+16)
        data.guildLand.plots={};World.sync(plot,data)
        for _,model in ipairs(folder:GetChildren()) do check(model:FindFirstChild("Ground")==nil) end
        -- NetworkService supplies this sanitized shape to World.Update.
        data.guildLand.plots.grove={status="Buildable",purchased=true,delivered={timber=24,herb=8}}
        World.sync(plot,data);check((folder:FindFirstChild("grove") :: Model):FindFirstChild("Ground")~=nil)
        data.guildLand.plots.grove.status="MaterialsRequired"
        World.sync(plot,data);check((folder:FindFirstChild("grove") :: Model):FindFirstChild("Ground")==nil)
    end)
    fixture:Destroy();assert(ok,problem)
    return {checks=checks,profileWrites=0,purchases=0,fixtureDestroyed=true}
end
