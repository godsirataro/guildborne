--!strict
-- Engine selection lifecycle only. Physical controller navigation is separate UAT.
return function()
    local p=game.Players.LocalPlayer;local service=game:GetService("GuiService")
    local router=require(p.PlayerScripts.Client.UI.MenuRouter)
    local title=p.PlayerGui.GuildborneUI.TitleScreen;local wasVisible=title.Visible;title.Visible=false
    local original=service.SelectedObject
    local gui=Instance.new("ScreenGui");gui.Name="MenuFocusFixture";gui.Parent=p.PlayerGui
    local function panel(name: string): Frame
        local f=Instance.new("Frame");f.Name=name;f.Size=UDim2.fromOffset(320,400);f.Visible=false;f.Parent=gui;return f
    end
    local function button(parent: Instance,name: string,enabled: boolean): TextButton
        local b=Instance.new("TextButton");b.Name=name;b.Text=name;b.Active=enabled;b.Selectable=enabled;b.Size=UDim2.fromOffset(200,48);b.Parent=parent;return b
    end
    local a=panel("A");local b=panel("B")
    button(a,"Disabled",false);local hidden=button(a,"Hidden",true);hidden.Visible=false
    local first=button(a,"First",true);local second=button(a,"Second",true)
    local other=button(b,"Other",true)
    router.register("FocusFixtureA",a);router.register("FocusFixtureB",b)
    local checks=0
    local function selected(expected: GuiObject?) task.wait(.05);assert(service.SelectedObject==expected,"Check "..(checks+1).." expected "..tostring(expected)..", actual "..tostring(service.SelectedObject));checks+=1 end
    local ok,result=pcall(function()
        a.Visible=true;router.focusCurrent();selected(first)
        service.SelectedObject=second;b.Visible=true;selected(other);assert(not a.Visible)
        a.Visible=true;selected(second);assert(not b.Visible)
        second.Active=false;selected(first)
        first:Destroy();selected(nil)
        local replacement=button(a,"Replacement",true);selected(replacement)
        local wrapper=Instance.new("Frame");wrapper.Visible=false;wrapper.Parent=a
        replacement.Parent=wrapper;selected(nil)
        replacement.Parent=a;selected(replacement)
        local pinned=panel("Pinned");local pinButton=button(pinned,"PinnedControl",true)
        router.register("FocusFixturePinned",pinned,true);pinned.Visible=true;selected(pinButton)
        b.Visible=true;assert(not b.Visible);selected(pinButton)
        router.closeAll();assert(pinned.Visible);selected(pinButton)
        pinned:Destroy();a.Visible=true;selected(replacement)
        local duplicate=pcall(function()router.register("FocusFixtureA",a)end);assert(not duplicate)
        router.closeAll();selected(nil);assert(not a.Visible and not b.Visible)
        a:Destroy();local reused=panel("Reuse");local rb=button(reused,"ReuseControl",true)
        router.register("FocusFixtureA",reused);reused.Visible=true;selected(rb)
        return {selectionChecks=checks,skipHiddenDisabled=true,restoreSelection=true,rerenderRecovery=true,pinnedGate=true,duplicateRejected=true,unregisterReuse=true,physicalControllerTested=false,noProfileWrites=true}
    end)
    gui:Destroy();title.Visible=wasVisible
    if original and original.Parent then service.SelectedObject=original else service.SelectedObject=nil end
    assert(ok,tostring(result));return result
end
