--!strict
-- Clone rendered map only; no travel, position changes, remotes or profile writes.
return function()
    local player=game.Players.LocalPlayer
    local city=require(game.ReplicatedStorage.Shared.Config.City)
    local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
    local gui=Instance.new("ScreenGui");gui.Name="CityMapSymbolFixture";gui.Parent=player.PlayerGui
    local panel=player.PlayerGui.CityNavigation.CityMap:Clone();panel.Visible=true;panel.Parent=gui
    local cases=0
    local ok,result=pcall(function()
        for _,width in ipairs({260,640}) do for _,lang in ipairs({"en","th"}) do
            panel.Size=UDim2.fromOffset(width,340)
            local map=panel.MapScroll.DistrictMap
            map.Size=UDim2.new(1,-6,0,480)
            for _,d in ipairs(city.Districts) do (map:FindFirstChild("Guide_"..d.Id) :: TextButton).Text=locale.translate(lang,d.Name) end
            task.wait(.04)
            for _,d in ipairs(city.Districts) do
                local node=map:FindFirstChild("Guide_"..d.Id) :: TextButton
                local symbol=node:FindFirstChild("SymbolIcon") :: Frame
                assert(node.AbsoluteSize.Y>=44,"Touch target too short")
                assert(node.TextBounds.X<=node.AbsoluteSize.X and node.TextBounds.Y<=node.AbsoluteSize.Y,"District label clipped")
                assert(symbol.AbsolutePosition.Y>=map.AbsolutePosition.Y,"Symbol outside map")
                assert(symbol.AbsolutePosition.Y+symbol.AbsoluteSize.Y<node.AbsolutePosition.Y,"Symbol overlaps own label")
                assert(not symbol.Active,"Decorative icon interactive")
                for _,other in ipairs(city.Districts) do if d.Id~=other.Id then
                    local b=map:FindFirstChild("Guide_"..other.Id) :: TextButton
                    local a0=symbol.AbsolutePosition;local a1=a0+symbol.AbsoluteSize
                    local b0=b.AbsolutePosition;local b1=b0+b.AbsoluteSize
                    assert(a1.X<=b0.X or a0.X>=b1.X or a1.Y<=b0.Y or a0.Y>=b1.Y,"Symbol overlaps another district")
                end end
                cases+=1
            end
        end end
        return {cases=cases,districts=6,widths={260,640},languages={"en","th"},noClipping=true,noOverlap=true,noProfileWrites=true,synthetic=true}
    end)
    gui:Destroy();assert(ok,tostring(result));return result
end
