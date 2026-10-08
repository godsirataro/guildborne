--!strict
-- Client fixture uses a uniquely registered clone; no profile changes or network calls.
return function()
    local player=game.Players.LocalPlayer;local ui=player.PlayerScripts.Client.UI
    local live=player.PlayerGui.GuildborneUI.TitleScreen;local wasVisible=live.Visible;live.Visible=false
    local source=ui.TitleView:Clone();source.Name="TitleBrandFixtureModule"
    source.Source=source.Source:gsub('register%("Title", root, true%)','register("TitleBrandFixture", root, true)');source.Parent=ui
    local cases=0
    local ok,result=pcall(function()
        for _,width in ipairs({260,640}) do
            local gui=Instance.new("ScreenGui");gui.Name="TitleBrandFixture";gui.Parent=player.PlayerGui
            local loadFixture: any=require
            local enterCount=0;local api=loadFixture(source)(gui,function()enterCount+=1 end,function()error("No language mutation allowed")end)
            local root=gui:FindFirstChild("TitleScreen") :: Frame;root.Size=UDim2.fromOffset(width,340)
            local scroll=root:FindFirstChildWhichIsA("ScrollingFrame",true) :: ScrollingFrame
            local button=scroll:FindFirstChild("Continue") :: TextButton
            task.wait(.12)
            local sigil=button:FindFirstChild("SymbolIcon") :: Frame
            assert(sigil.Visible and not button.Active and not button.Selectable,"Loading gate missing")
            local delta=sigil.AbsolutePosition-button.AbsolutePosition
            assert(delta.X>=0 and delta.X+24<=button.AbsoluteSize.X,"Loading icon clipped")
            assert(button.AbsolutePosition.Y+button.AbsoluteSize.Y<=scroll.AbsolutePosition.Y+scroll.AbsoluteSize.Y,"Continue below fold")
            for _,lang in ipairs({"en","th"}) do
                api.update({status="Active",data={language=lang,adventurers={}}});task.wait(.08)
                assert(button.Active and button.Selectable and not sigil.Visible)
                assert(button.TextBounds.X<=button.AbsoluteSize.X-16 and button.TextBounds.Y<=button.AbsoluteSize.Y,"Button text clipped")
                assert(button.AbsolutePosition.Y+button.AbsoluteSize.Y<=scroll.AbsolutePosition.Y+scroll.AbsoluteSize.Y)
                cases+=1
            end
            api.update({status="Degraded"});assert(enterCount==1 and not api.isOpen(),"Recovery route changed")
            gui:Destroy()
        end
        return {widths={260,640},height=340,languageCases=cases,loadingGate=true,readyGate=true,ctaAboveFold=true,recoveryRoute=true,noProfileWrites=true}
    end)
    local leftover=player.PlayerGui:FindFirstChild("TitleBrandFixture");if leftover then leftover:Destroy() end
    source:Destroy();live.Visible=wasVisible;assert(ok,tostring(result));return result
end
