--!strict
-- Synthetic client UI at two widths in both languages; destroys every fixture.
return function()
    local player=game.Players.LocalPlayer
    local draw=require(player.PlayerScripts.Client.UI.EmptyState)
    local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
    local gui=Instance.new("ScreenGui");gui.Name="EmptyStatesFixture";gui.Parent=player.PlayerGui
    local host=Instance.new("Frame");host.BackgroundTransparency=1;host.Size=UDim2.fromOffset(240,600);host.Parent=gui
    local count=0
    for _,width in ipairs({240,640}) do for _,lang in ipairs({"en","th"}) do
        host.Size=UDim2.fromOffset(width,600)
        for _,key in ipairs({"empty_inventory","empty_party","no_quests","no_market_orders","no_search_results","guild_not_joined","content_locked","offline_unavailable"}) do
            local state=draw(host,key,function(s)return locale.translate(lang,s)end)
            task.wait(.05)
            local heading=state:FindFirstChild("Heading") :: TextLabel;local detail=state:FindFirstChild("Detail") :: TextLabel
            assert(state.AbsoluteSize.Y>80 and state.AbsoluteSize.Y<500)
            for _,text in ipairs({heading,detail}) do
                assert(text.TextBounds.X<=text.AbsoluteSize.X+1 and text.TextBounds.Y<=text.AbsoluteSize.Y+1,"Clipped "..key.." "..lang)
                assert(text.AbsolutePosition.Y+text.AbsoluteSize.Y<=state.AbsolutePosition.Y+state.AbsoluteSize.Y+1,"Outside card")
                if lang=="th" then assert(text.Text:find("[\224-\239]"),"Missing Thai copy") end
            end
            assert(detail.AbsolutePosition.Y>=heading.AbsolutePosition.Y+heading.AbsoluteSize.Y)
            local row=assert(state:FindFirstChild("IconRow"));local symbol=assert(row:FindFirstChild("SymbolIcon"))
            assert(symbol:GetAttribute("SymbolId")=="ui.empty_states."..key)
            for _,child in ipairs(state:GetDescendants()) do assert(not child:IsA("TextButton"),"Empty-state art cannot submit actions") end
            count+=1;state:Destroy()
        end
    end end
    gui:Destroy()
    return {variants=8,cases=count,widths={240,640},languages={"en","th"},noClipping=true,noActions=true}
end
