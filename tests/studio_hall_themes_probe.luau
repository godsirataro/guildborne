--!strict
return function()
    assert(game.PlaceId==0 and game.GameId==0,"Offline fixture only")
    local Kit=require(game.ServerScriptService.Server.Services.ArtKit)
    local A=require(game.ReplicatedStorage.Shared.Presentation.HallAppearance)
    local C=require(game.ReplicatedStorage.Shared.Config.BuildingThemes)
    local templates=Kit.Build();local fixture=Instance.new("Folder");fixture.Name="HallThemesProbe";fixture.Parent=workspace
    local ground=Instance.new("Part");ground.Size=Vector3.new(80,2,80);ground.Position=Vector3.new(5000,0,0);ground.Anchored=true;ground.Parent=fixture
    local checks,paths,parts=0,0,0
    local function check(ok:boolean)assert(ok,"Hall theme check "..(checks+1));checks+=1 end
    local ok,reason=pcall(function()
        for level=1,2 do for _,id in ipairs(C.Order) do
            local m=(templates:FindFirstChild("GuildHallLv"..level) :: Model):Clone()
            local collisions={}
            for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then table.insert(collisions,{p=p,size=p.Size,cf=p.CFrame,query=p.CanQuery}) end end
            A.apply(m,id)
            for _,row in ipairs(collisions) do check(row.p.Parent~=nil and row.p.Size==row.size and row.p.CFrame==row.cf and row.p.CanCollide and row.p.CanQuery==row.query) end
            local count=0
            for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then count+=1 end end
            A.apply(m,id);local again=0;for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then again+=1 end end
            check(count==again);parts+=count
            for rotation=0,3 do
                local cf=CFrame.new(5000,1,0)*CFrame.Angles(0,rotation*math.pi/2,0);m:PivotTo(cf);m.Parent=fixture
                for _,child in ipairs(assert(m:FindFirstChild("HallThemeDetails")):GetChildren()) do
                    local p=child :: BasePart
                    check(p:IsA("BasePart") and p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery)
                    for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
                        local point=cf:PointToObjectSpace(p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)/2))
                        check(math.abs(point.X)<=16.01 and math.abs(point.Z)<=12.01 and point.Y>=0)
                    end end end
                end
                local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false})
                path:ComputeAsync(cf*Vector3.new(0,4,17),cf*Vector3.new(0,4,4));check(path.Status==Enum.PathStatus.Success);paths+=1
            end
            m:Destroy()
        end end
        local station=Instance.new("Part");station.Anchored=true;station.CanCollide=false;station.Parent=fixture
        local hall=(templates:FindFirstChild("GuildHallLv1") :: Model):Clone();hall:PivotTo(CFrame.new(5000,1,0));hall.Parent=fixture
        local plot:any={origin=Vector3.new(5000,1,0),buildings=fixture,hall=hall,hallStation=station,level=1}
        local sync=require(game.ServerScriptService.Server.Services.GuildHallWorld)
        local position={x=6,z=-4,rotation=1}
        sync(plot,templates,2,position,"orc");local cf=plot.hall:GetPivot()
        check(plot.hall:GetAttribute("BuildingTheme")=="orc");check(plot.level==2)
        sync(plot,templates,9,position,"mage")
        check(plot.hall:GetAttribute("BuildingTheme")=="mage");check(plot.hall:GetPivot()==cf)
        check((station.Position-(cf*Vector3.new(0,3,13))).Magnitude<.001)
        local stable=plot.hall;sync(plot,templates,9,position,"mage");check(plot.hall==stable)
        local sign=plot.hall:FindFirstChild("HallSign"):FindFirstChildWhichIsA("TextLabel",true)
        check(sign.Text=="Guild Hall · Lv9\nหอกิลด์ · ระดับ 9")
    end)
    fixture:Destroy();templates:Destroy();assert(ok,reason)
    return {checks=checks,paths=paths,parts=parts,themes=6,levels=2,fixtureDestroyed=true,profileWrites=0}
end
