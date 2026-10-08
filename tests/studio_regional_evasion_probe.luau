--!strict
-- Synthetic actors, copied terrain and a neutral R15 walker; no player/profile actions.
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local services=game.ServerScriptService.Server.Services
    local make=require(services.RegionalEvasion)
    local patterns=require(game.ServerScriptService.Server.Systems.AdventurePatterns)
    local fixture=Instance.new("Folder");fixture.Name="EvasionReview";fixture.Parent=workspace
    local ok,result=pcall(function():any
        local checks=0;local elapsed=0;local goals={}
        for _,entry in ipairs({{region="Greenwood",position=Vector3.new(0,6,1330)},{region="Ironveil",position=Vector3.new(500,10,1330)},{region="Ashen",position=Vector3.new(1000,14,1330)}}) do
            local region=entry.region;local p=entry.position
            local map=workspace.GuildborneWorld:FindFirstChild(region) :: Model
            local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={map}
            local floor=workspace:Raycast(p+Vector3.new(0,20,0),Vector3.new(0,-40,0),ray);assert(floor)
            p=floor.Position
            local root=Instance.new("Part");root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.Position=p+Vector3.new(0,3,0);root.Parent=fixture
            local actor={root=root,owner=-999}
            local hazard={shape="Circle",x=p.X,y=p.Y,z=p.Z,radius=6,due=2}
            local enemy={id="test",owner=-999,active=true,health=100,pendingPattern=hazard}
            local dodge=make(map,region);local start=os.clock();local goal=dodge(actor,{enemy},0);elapsed+=os.clock()-start
            assert(goal and not patterns.contains(hazard,{x=goal.X,y=goal.Y-3,z=goal.Z}));checks+=1
            assert(root.Position==p+Vector3.new(0,3,0),"Query moved actor");checks+=1
            assert(dodge(actor,{enemy},.5)==goal,"Escape target jitter");checks+=1
            enemy.active=false;assert(dodge(actor,{enemy},.7)==nil);checks+=1
            table.insert(goals,{region=region,from=tostring(p),goal=tostring(goal)})
        end
        local map=workspace.GuildborneWorld.Ironveil:Clone();map.Name="CopiedIronveil";map.Parent=fixture
        local wall=Instance.new("Part");wall.Size=Vector3.new(.1,8,16);wall.Position=Vector3.new(503,14,1330)
        wall.Anchored=true;wall.CanQuery=false;wall.Parent=map
        local description=Instance.new("HumanoidDescription")
        local avatar=game.Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15);description:Destroy()
        avatar.Name="EvasionWalker";avatar.Parent=fixture;avatar:PivotTo(CFrame.new(500,14,1330))
        local root=avatar:FindFirstChild("HumanoidRootPart") :: BasePart
        local humanoid=avatar:FindFirstChildOfClass("Humanoid") :: Humanoid
        root:SetNetworkOwner(nil);humanoid.WalkSpeed=17;humanoid.AutoJumpEnabled=false;task.wait(.4)
        local origin=root.Position
        local actor={root=root,owner=-999}
        local hazard={shape="Circle",x=500,y=10,z=1330,radius=6,due=os.clock()+1.4}
        local enemy={id="hammer",owner=-999,active=true,health=100,pendingPattern=hazard}
        local dodge=make(map,"Ironveil");local goal=dodge(actor,{enemy},os.clock());assert(goal)
        assert(goal.X<503,"Escape crossed nonquery wall");checks+=1
        humanoid:MoveTo(goal)
        repeat task.wait(.05) until os.clock()>=hazard.due
        local actual=root.Position-Vector3.new(0,3,0)
        assert(not patterns.contains(hazard,{x=actual.X,y=actual.Y,z=actual.Z}),"R15 failed to leave Hammer Fall before impact")
        assert(root.Position.X<503 and humanoid.Health>0);checks+=2
        return {checks=checks,regions=goals,selectionSeconds=elapsed,walkedStuds=(root.Position-origin).Magnitude,
            standardR15=true,noTeleport=true,nonqueryWallBlocked=true,profileWrites=0}
    end)
    fixture:Destroy();assert(ok,tostring(result));return result
end
