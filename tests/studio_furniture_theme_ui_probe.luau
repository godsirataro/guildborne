--!strict
-- Disposable projection/UI fixture; never sends a remote or grants player rights.
return function():any
    local player=game.Players.LocalPlayer
    local make=require(player.PlayerScripts.Client.UI.BuildingThemesView)
    local gui=Instance.new("ScreenGui");gui.Name="FurnitureThemeUIProbe";gui.Parent=player.PlayerGui
    local scroll=Instance.new("ScrollingFrame");scroll.Size=UDim2.fromOffset(700,500);scroll.Parent=gui
    local callbacks:{[Instance]:any}={};local actions={};local checks=0
    local ui:any={scroll=scroll,T=function(value:string)return value end,navigate=function()end,render=function()end}
    ui.card=function(parent:Instance,title:string)local f=Instance.new("Frame");f.Name=title;f.Parent=parent;return f end
    ui.text=function()end
    ui.button=function(parent:Instance,label:string,enabled:boolean,callback:any)
        local b=Instance.new("TextButton");b.Text=label;b.Active=enabled;b.Parent=parent
        if enabled then callbacks[b]=callback end;return b
    end
    ui.act=function(action:string,args:any)table.insert(actions,{action=action,args=args})end
    local function check(ok:boolean)assert(ok,"Furniture UI "..checks);checks+=1 end
    local ok,problem=pcall(function()
        local render=make(ui)
        render({expansion={buildings={},furniture={["f:1"]={kind="hearth_chair",theme="human",stored=true}},themeRights={orc=true}},settlement={journal={}}},false)
        local themes=0
        for _,card in ipairs(scroll:GetChildren()) do if card.Name:match("^Theme_") then
            themes+=1;local viewport=card:FindFirstChild("ThemePreview") :: ViewportFrame
            local model=viewport:FindFirstChild("hearth_chair") :: Model?
            check(model~=nil);assert(model);check(model:GetAttribute("BuildingTheme")==card.Name:sub(7))
        end end
        check(themes==6)
        local orc=scroll:FindFirstChild("ApplyTheme_orc",true);check(orc~=nil and callbacks[orc]~=nil);assert(orc);callbacks[orc]()
        check(#actions==1 and actions[1].action=="ApplyBuildingTheme" and actions[1].args.buildingId=="f:1" and actions[1].args.themeId=="orc")
        check(scroll:FindFirstChild("ApplyTheme_mage",true)==nil)
        local human=scroll:FindFirstChild("ApplyTheme_human",true);check(human~=nil and callbacks[human]==nil)
    end)
    gui:Destroy();if not ok then error(tostring(problem)) end
    return {checks=checks,previews=6,remoteCalls=0,fixtureDestroyed=true}
end
