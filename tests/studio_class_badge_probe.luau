--!strict
return function()
    local p=game.Players.LocalPlayer;local draw=require(p.PlayerScripts.Client.UI.ClassBadge)
    local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
    local gui=Instance.new("ScreenGui");gui.Name="ClassBadgeFixture";gui.Parent=p.PlayerGui
    local host=Instance.new("Frame");host.BackgroundTransparency=1;host.Parent=gui
    local checks=0
    local ok,result=pcall(function()
        for _,width in ipairs({160,600}) do for _,lang in ipairs({"en","th"}) do for _,id in ipairs({"Knight","Warrior","Archer","Mage","Priest"}) do
            host.Size=UDim2.fromOffset(width,100)
            local badge=assert(draw(host,id,function(key)return locale.translate(lang,key)end))
            task.wait(.03)
            local text=badge:FindFirstChild("ClassName") :: TextLabel;local icon=badge:FindFirstChild("SymbolIcon") :: Frame
            assert(icon:GetAttribute("SymbolId")=="ui.classes."..string.lower(id))
            assert(text.TextBounds.X<=text.AbsoluteSize.X and text.TextBounds.Y<=text.AbsoluteSize.Y,"Class copy clipped")
            assert(icon.AbsolutePosition.X+icon.AbsoluteSize.X<text.AbsolutePosition.X)
            assert(icon.AbsolutePosition.Y>=badge.AbsolutePosition.Y and icon.AbsolutePosition.Y+icon.AbsoluteSize.Y<=badge.AbsolutePosition.Y+badge.AbsoluteSize.Y)
            assert(not icon.Active and not badge.Active)
            badge:Destroy();checks+=1
        end end end
        assert(draw(host,"Unknown",function(key)return key end)==nil);assert(#host:GetChildren()==0)
        return {checks=checks,classes=5,languages={"en","th"},widths={160,600},unknownRejected=true,noClipping=true,noProfileWrites=true}
    end)
    gui:Destroy();assert(ok,tostring(result));return result
end
