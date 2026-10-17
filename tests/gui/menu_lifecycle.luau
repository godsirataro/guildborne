--!nocheck
-- Actual shared gate module; injected router result reproduces independent review
-- module registries. This does not claim a clean Studio bootstrap reproduction.
local Gate=require(getfenv().UI.Components.GameplayMenuGate)
local passed=0
local function test(name,run)run();passed+=1;print("PASS menu lifecycle "..name)end
local function fixture()
 local gui=Instance.new("Folder")
 local main=Instance.new("ScreenGui");main.Name="GuildborneUI";main.Enabled=true;main.Parent=gui
 function main:IsA(class)return class=="ScreenGui"end
 local management=Instance.new("Frame");management.Name="ManagementPanel";management.Visible=false;management.Parent=main
 function management:IsA(class)return class=="GuiObject"end
 local map=Instance.new("Frame");map.Visible=false
 return gui,main,management,map
end
test("map management map-close retains blocking even when the router registry clears",function()
 local gui,_main,management,map=fixture()
 assert(Gate.toggleMap(map,gui,false) and map.Visible)
 gui:SetAttribute("GuildborneMenuOpen",true);management.Visible=true
 assert(Gate.blocked(gui,false),"Combat must block despite a stale false router result")
 assert(Gate.toggleMap(map,gui,true) and not map.Visible,"Own map can close while menus block")
 assert(Gate.blocked(gui,false) and management.Visible)
 assert(not Gate.toggleMap(map,gui,false) and not map.Visible,"N cannot reopen behind Management")
 gui:SetAttribute("GuildborneMenuOpen",false)
 assert(Gate.blocked(gui,false),"Visible Management protects against flag races too")
 management.Visible=false
 assert(not Gate.blocked(gui,false) and Gate.toggleMap(map,gui,false),"Normal close restores gameplay/map access")
 assert(Gate.toggleMap(map,gui,true) and not map.Visible,"Map router ownership never self-blocks close")
 gui:Destroy();map:Destroy()
end)
test("router and shared flag independently gate actions while disabled Management alone does not",function()
 local gui,main,management,map=fixture()
 assert(Gate.blocked(gui,true))
 gui:SetAttribute("GuildborneMenuOpen",true);assert(Gate.blocked(gui,false))
 gui:SetAttribute("GuildborneMenuOpen",false);management.Visible=true;main.Enabled=false
 assert(not Gate.blocked(gui,false))
 main.Enabled=true;assert(Gate.blocked(gui,false))
 gui:Destroy();map:Destroy()
end)
print(passed.." menu lifecycle cases passed (simulation only).")
