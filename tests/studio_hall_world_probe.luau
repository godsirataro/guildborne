--!strict
return function()
    assert(game.PlaceId==0 and game.GameId==0,"Offline fixture only")
    local Sync=require(game.ServerScriptService.Server.Services.GuildHallWorld)
    local Kit=require(game.ServerScriptService.Server.Services.ArtKit)
    local fixture=Instance.new("Folder");fixture.Name="HallMovementProbe";fixture.Parent=workspace
    local templates=Kit.Build() -- keep source templates outside Workspace collision
    local root=Instance.new("Folder");root.Parent=fixture
    local station=Instance.new("Part");station.Anchored=true;station.CanCollide=false;station.Parent=root
    local ground=Instance.new("Part");ground.Size=Vector3.new(80,2,80);ground.Position=Vector3.new(5064,0,-16);ground.Anchored=true;ground.Parent=root
    local plot:any={origin=Vector3.new(5000,1,0),hall=assert(templates:FindFirstChild("GuildHallLv1")):Clone(),level=1,buildings=root,hallStation=station}
    plot.hall.Parent=root;local checks=0;local paths=0
    local function check(value:boolean)assert(value,"Hall world check "..(checks+1));checks+=1 end
    local ok,reason=pcall(function()
        for level=1,2 do for rotation=0,3 do
            Sync(plot,templates,level,{x=6,z=-4,rotation=rotation})
            local cf=plot.hall:GetPivot();local w,d=4,3;if rotation%2==1 then w,d=d,w end
            check((cf.Position-(plot.origin+Vector3.new((6+w/2)*8,0,(-4+d/2)*8))).Magnitude<.001)
            check((station.Position-(cf*Vector3.new(0,3,13))).Magnitude<.001)
            for _,part in ipairs(plot.hall:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then
                for _,sx in ipairs({-1,1}) do for _,sz in ipairs({-1,1}) do
                    local corner=part.CFrame*Vector3.new(sx*part.Size.X/2,0,sz*part.Size.Z/2)-plot.origin
                    check(corner.X>=48-.01 and corner.X<=(6+w)*8+.01 and corner.Z>=-32-.01 and corner.Z<=(-4+d)*8+.01)
                end end
            end end
            local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false})
            path:ComputeAsync(cf*Vector3.new(0,4,17),cf*Vector3.new(0,4,4))
            check(path.Status==Enum.PathStatus.Success);paths+=1
        end end
        local before=plot.hall;Sync(plot,templates,2,nil)
        check(plot.hall==before);check((plot.hall:GetPivot().Position-Vector3.new(5000,1,-24)).Magnitude<.001)
        check((station.Position-Vector3.new(5000,4,-13)).Magnitude<.001)
        Sync(plot,templates,9,{x=6,z=-4,rotation=1})
        local sign=plot.hall:FindFirstChild("HallSign"):FindFirstChildWhichIsA("TextLabel",true)
        check(sign.Text=="Guild Hall · Lv9\nหอกิลด์ · ระดับ 9")
        check((plot.hall:GetPivot().Position-Vector3.new(5060,1,-16)).Magnitude<.001)
    end)
    fixture:Destroy();templates:Destroy();assert(ok,reason)
    return {checks=checks,noJumpEntrancePaths=paths,levels=2,rotations=4,profileWrites=0,fixtureDestroyed=true}
end
