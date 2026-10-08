--!strict
-- Client-only synthetic UI; no profile writes. Pass true to retain the review gallery.
return function(keepGallery: boolean?)
    local player=game:GetService("Players").LocalPlayer
    local factory=require(player.PlayerScripts.Client.UI.SymbolIcon)
    local symbols=require(game.ReplicatedStorage.Shared.Data.UISymbols)
    local gui=Instance.new("ScreenGui");gui.Name="UISymbolReview";gui.DisplayOrder=1000;gui.IgnoreGuiInset=true;gui.Parent=player.PlayerGui
    local ids={};for id in pairs(symbols) do table.insert(ids,id) end;table.sort(ids)
    assert(#ids==58,"Expected 58 symbols")
    local primitives=0
    for _,size in ipairs({18,24,48}) do
        for _,id in ipairs(ids) do
            local icon=assert(factory(gui,id,size))
            assert(icon:GetAttribute("SymbolId")==id and not icon.Active)
            assert(#icon:GetChildren()==#symbols[id])
            for _,child in ipairs(icon:GetChildren()) do
                assert(child:IsA("Frame") and not child.Active and not child.Selectable)
                local half=Vector2.new(child.Size.X.Scale*size+child.Size.X.Offset,child.Size.Y.Scale*size+child.Size.Y.Offset)/2
                local center=Vector2.new(child.Position.X.Scale*size+child.Position.X.Offset,child.Position.Y.Scale*size+child.Position.Y.Offset)+Vector2.new((.5-child.AnchorPoint.X)*half.X*2,(.5-child.AnchorPoint.Y)*half.Y*2)
                local theta=math.rad(child.Rotation);local stroke=child:FindFirstChildOfClass("UIStroke");local pad=if stroke then stroke.Thickness/2 else 0
                for _,x in ipairs({-half.X,half.X}) do for _,y in ipairs({-half.Y,half.Y}) do
                    local point=center+Vector2.new(x*math.cos(theta)-y*math.sin(theta),x*math.sin(theta)+y*math.cos(theta))
                    assert(point.X-pad>=-.01 and point.Y-pad>=-.01 and point.X+pad<=size+.01 and point.Y+pad<=size+.01,id.." clipped")
                end end
                primitives+=1
            end
            icon:Destroy()
        end
    end
    assert(factory(gui,"missing_symbol")==nil)
    if keepGallery then
        local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=Color3.fromRGB(16,23,36);bg.Parent=gui
        for i,id in ipairs(ids) do
            local rows=math.ceil(#ids/7)
            local cell=Instance.new("Frame");cell.BackgroundTransparency=1;cell.Position=UDim2.fromScale(((i-1)%7)/7,math.floor((i-1)/7)/rows);cell.Size=UDim2.fromScale(1/7,1/rows);cell.Parent=bg
            local icon=assert(factory(cell,id,26));icon.Position=UDim2.new(.5,-13,0,4)
            local label=Instance.new("TextLabel");label.BackgroundTransparency=1;label.Size=UDim2.new(1,0,0,20);label.Position=UDim2.new(0,0,1,-22);label.Text=id:match("[^.]+$") or id;label.TextSize=10;label.TextColor3=Color3.fromRGB(238,229,207);label.Parent=cell
        end
    else gui:Destroy() end
    return {symbols=#ids,sizes={18,24,48},primitiveChecks=primitives,unknownRejected=true,boundsPassed=true,synthetic=true}
end
