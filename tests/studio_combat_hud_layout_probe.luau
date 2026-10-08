--!strict
-- Read-only actor HUD clones, with a synthetic safe viewport. No combat input.
return function()
    local p=game.Players.LocalPlayer;local source=p.PlayerScripts.Client.Controllers.PlayerCombatController
    local layout=require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
    local originalTitle=p.PlayerGui.GuildborneUI.TitleScreen;local wasVisible=originalTitle.Visible;originalTitle.Visible=false
    local active: any=nil;local module: ModuleScript?=nil;local checks=0
    local ok,result=pcall(function()
        for _,size in ipairs({Vector2.new(320,280),Vector2.new(390,500),Vector2.new(600,300),Vector2.new(740,340),Vector2.new(390,844)}) do for _,lang in ipairs({"en","th"}) do
            local cloned=source:Clone() :: ModuleScript;module=cloned;cloned.Name="CombatHudLayoutFixtureModule"
            cloned.Source=cloned.Source:gsub('gui.Name="GuildbornePlayerCombatUI"','gui.Name="CombatHudLayoutFixture"')
                :gsub('local viewport=gui.AbsoluteSize',string.format('local viewport=Vector2.new(%d,%d)',size.X,size.Y))
                :gsub('Localization.translate%(language,key%)','Localization.translate("'..lang..'",key)')
            cloned.Parent=source.Parent
            active=(require :: any)(cloned)()
            local gui=assert(p.PlayerGui:FindFirstChild("CombatHudLayoutFixture")) :: ScreenGui
            local roots=gui:GetChildren();local host=Instance.new("Frame");host.Name="SafeViewport";host.Size=UDim2.fromOffset(size.X,size.Y);host.BackgroundTransparency=1;host.Parent=gui
            for _,child in ipairs(roots) do if child:IsA("GuiObject") then child.Parent=host end end
            task.wait(.16)
            local l=layout(size.X,size.Y)
            local selection=assert(host:FindFirstChild("CompanionSelection")) :: Frame
            local pad=assert(host:FindFirstChild("CombatButtons")) :: Frame
            local health=assert(host:FindFirstChild("PlayerHealth")) :: TextLabel
            local orders=assert(host:FindFirstChild("CompanionOrders")) :: Frame
            local function inside(a: GuiObject)
                local pos=a.AbsolutePosition-host.AbsolutePosition
                assert(pos.X>=-.1 and pos.Y>=-.1 and pos.X+a.AbsoluteSize.X<=size.X+.1 and pos.Y+a.AbsoluteSize.Y<=size.Y+.1,"Outside viewport "..a.Name)
            end
            local regions: {GuiObject}={selection,pad,health,orders}
            for _,a in ipairs(regions) do inside(a) end
            local shown=0
            for _,card in ipairs(selection:GetChildren()) do if card:IsA("TextButton") and card.Name:sub(1,5)=="Actor" and card.Visible then
                shown+=1;inside(card)
                local label=card:FindFirstChild("ActorLabel") :: TextLabel
                assert(label.TextBounds.X<=label.AbsoluteSize.X+1 and label.TextBounds.Y<=label.AbsoluteSize.Y+1,"Actor label clipped "..size.X.."x"..size.Y.." "..lang)
                assert(label.TextBounds.Y<=30,"Roster label must remain two readable lines "..lang.." "..label.Text)
            end end
            if l.collapsed then assert(shown==1,"Collapsed roster must show only selected actor") end
            for _,b in ipairs(pad:GetChildren()) do if b:IsA("TextButton") then
                inside(b);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)
                assert(b.TextBounds.X<=b.AbsoluteSize.X+1 and b.TextBounds.Y<=b.AbsoluteSize.Y+1,"Skill label clipped "..size.X.."x"..size.Y.." "..lang.." "..b.Name)
            end end
            local nextActor=selection:FindFirstChild("CycleActor") :: TextButton
            if nextActor.Visible then assert(nextActor.TextBounds.X<=nextActor.AbsoluteSize.X and nextActor.TextBounds.Y<=nextActor.AbsoluteSize.Y) end
            active.Destroy();active=nil;cloned:Destroy();module=nil;task.wait(.03)
            assert(not p.PlayerGui:FindFirstChild("CombatHudLayoutFixture"));checks+=1
        end end
        return {viewportLanguageCases=checks,minimumSafeArea={320,280},collapsedRoster=true,touchTargets44=true,textBoundsPassed=true,destroyCleanup=true,noProfileWrites=true,physicalDeviceTested=false}
    end)
    if active then active.Destroy() end;if module then module:Destroy() end
    originalTitle.Visible=wasVisible;assert(ok,tostring(result));return result
end
