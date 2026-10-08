--!strict
return function()
    assert(game.PlaceId==0 and game.GameId==0,"Offline fixture only")
    local A=require(game.ReplicatedStorage.Shared.Presentation.BuildingAppearance)
    local C=require(game.ReplicatedStorage.Shared.Config.BuildingThemes)
    local fixture=Instance.new("Folder");fixture.Name="BuildingThemeProbe";fixture.Parent=workspace
    local checks=0;local total=0;local counts={}
    local function check(value:boolean)assert(value,"Theme check "..(checks+1));checks+=1 end
    local ok,reason=pcall(function()
        for i,id in ipairs(C.Order) do
            local m=A.preview(id);m.Parent=fixture;local count=0;local solid=0
            for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then
                count+=1;if p.CanCollide then solid+=1 end
                if p:IsDescendantOf(assert(m:FindFirstChild("ThemeDetails"))) then check(not p.CanCollide and not p.CanTouch and not p.CanQuery) end
            end end
            check(solid==7);check(count<=32);check(m:GetAttribute("BuildingTheme")==id)
            local before=count;A.apply(m,id);count=0
            for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then count+=1 end end
            check(count==before);counts[id]=count;total+=count
            m:PivotTo(CFrame.new(4000+i*24,5,0))
        end
        local make=require(game.ServerScriptService.Server.Services.ExpansionWorld)
        local f=Instance.new("Folder");f.Parent=fixture
        local plot:any={model=Instance.new("Model"),origin=Vector3.new(5000,1,0),built={},expansionFolder=f};plot.model.Parent=fixture
        local service=make(function()end,function()end)
        service.sync(plot,{expansion={buildings={a={kind="quarters",x=6.25,z=-3.75,rotation=1,theme="human",level=2}}}})
        local original=plot.built.a;local pivot=original:GetPivot()
        service.sync(plot,{expansion={buildings={a={kind="quarters",x=6.25,z=-3.75,rotation=1,theme="orc",level=2}}}})
        check(original.Parent==nil);check(plot.built.a:GetAttribute("BuildingTheme")=="orc")
        check((plot.built.a:GetPivot().Position-pivot.Position).Magnitude<.001)
        check((plot.built.a:GetPivot().LookVector-pivot.LookVector).Magnitude<.001)
        local current=plot.built.a
        service.sync(plot,{expansion={buildings={a={kind="quarters",x=6.25,z=-3.75,rotation=1,theme="orc",level=2}}}})
        check(current==plot.built.a)
    end)
    fixture:Destroy();assert(ok,reason)
    return {checks=checks,parts=total,counts=counts,fixtureDestroyed=true,profileWrites=0}
end
