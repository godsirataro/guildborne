--!nocheck
-- Isolated native review fixture. No server, remotes, persistence or game rewards.
local player = game:GetService("Players").LocalPlayer
local UI = script.Parent:WaitForChild("UI")
local Panel = require(UI.Components.GuildbornePanel)
local Button = require(UI.Components.GuildborneButton)
local Header = require(UI.Components.HeaderBar)
local Tabs = require(UI.Components.TabBar)
local Theme = require(UI.DesignSystem.Theme)
local gui = Instance.new("ScreenGui")
gui.Name = "GuildborneGUIReview"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets; gui.Parent = player:WaitForChild("PlayerGui")
local background = Instance.new("Frame")
background.Size = UDim2.fromScale(1,1); background.BackgroundColor3 = Theme.Colors.Background; background.Parent = gui
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(16,16); scroll.Size = UDim2.new(1,-32,1,-32)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.CanvasSize = UDim2.new(); scroll.Parent = background
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,16); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = scroll
local header = Header.create(scroll,{subtitle="Native component review • ตรวจสอบส่วนประกอบ GUI"})
header.frame.LayoutOrder = 1
local status = Instance.new("TextLabel")
status.Name = "ReviewStatus"; status.Size = UDim2.new(1,0,0,56); status.BackgroundTransparency = 1
status.TextColor3 = Theme.Colors.Text; status.TextSize = 16; status.TextWrapped = true
status.Text = "Local fixture only. Select a tab or activate a button."; status.LayoutOrder = 2; status.Parent = scroll
local tabs = Tabs.create(scroll,{{id="overview",label="Overview"},{id="thai",label="ภาษาไทย"},{id="locked",label="Unavailable"}},function(id) status.Text = "Selected tab: "..id end)
tabs.frame.LayoutOrder = 3; tabs.select("overview"); tabs.setDisabled("locked",true)
local panel = Panel.create(scroll,{name="ComponentStates",size=UDim2.new(1,0,0,350)})
panel.LayoutOrder = 4
local content = panel:FindFirstChild("Content") or panel
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0,16); padding.PaddingRight = UDim.new(0,16)
padding.PaddingTop = UDim.new(0,16); padding.Parent = content
local list = Instance.new("UIListLayout")
list.SortOrder = Enum.SortOrder.LayoutOrder; list.Padding = UDim.new(0,12); list.Parent = content
local count = 0
local primary = Button.create(content,{text="Continue / ดำเนินการต่อ",primary=true,onActivated=function()
 count += 1; status.Text = "Local activations: "..tostring(count)
end}); primary.button.LayoutOrder = 1
local secondary = Button.create(content,{text="Secondary action",onActivated=function() status.Text="Secondary activated" end})
secondary.button.LayoutOrder = 2
local disabled = Button.create(content,{text="Unavailable — disabled",onActivated=function() error("Disabled button activated") end})
disabled.setDisabled(true); disabled.button.LayoutOrder = 3
local pending = Button.create(content,{text="Waiting — pending",onActivated=function() error("Pending button activated") end})
pending.setPending(true); pending.button.LayoutOrder = 4
local selected = Button.create(content,{text="Selected state"}); selected.setSelected(true); selected.button.LayoutOrder=5
print("GUI_REVIEW_READY: isolated native fixture; no gameplay acceptance implied")
local titleGui = Instance.new("ScreenGui")
titleGui.Name="GuildborneTitleReview"; titleGui.ResetOnSpawn=false
titleGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
titleGui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets; titleGui.DisplayOrder=10; titleGui.Parent=player.PlayerGui
local makeTitle = require(UI.TitleView)
local title
local fixture = {status="Loading"}
local function language()
 fixture.data.language = if fixture.data.language=="en" then "th" else "en"
 title.update(fixture)
end
title=makeTitle(titleGui,function() status.Text="Title Continue: entered isolated gallery (no profile or rewards)." end,language)
title.update(fixture)
task.delay(2,function()
 fixture={status="Active",data={language="en",adventurers={},party={},progression={novice={claimed=0}}}}
 title.update(fixture)
end)
local notice=Instance.new("TextLabel")
notice.Name="FixtureNotice"; notice.Text="REVIEW FIXTURE • simulated profile • no saved data"
notice.Size=UDim2.new(1,0,0,24); notice.TextSize=12; notice.BackgroundColor3=Theme.Colors.Primary
notice.TextColor3=Theme.Colors.Text; notice.ZIndex=100; notice.Parent=titleGui
