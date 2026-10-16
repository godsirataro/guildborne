--!nocheck
-- ISOLATED REVIEW ONLY: actual UI/catalog with local simulated quest states.
-- No remotes, saves, gameplay controllers, rewards or profile mutations outside this fixture.
local Players=game:GetService("Players")
local Shared=game.ReplicatedStorage.Shared
local UI=script.Parent:WaitForChild("UI")
local Theme=require(UI.DesignSystem.Theme)
local Button=require(UI.Components.GuildborneButton)
local Chrome=require(UI.Components.CombatChrome)
local JournalState=require(Shared.Data.JournalViewState)
local Locale=require(Shared.Config.Localization)
local catalog=require(game.ReplicatedStorage.ReviewCatalog)
local player=Players.LocalPlayer
local language="en"
local pinned="timber_help"
local focus="timber_help"
local mode="Journal"
local fixture={settlement={journal={city_gate={state="Claimed",progress=1},timber_help={state="Active",progress=1}}},inventory={stacks={herb=2}}}
local root=Instance.new("ScreenGui")
root.Name="GuildborneGameplayUIReview";root.ResetOnSpawn=false;root.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
root.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;root.Parent=player:WaitForChild("PlayerGui")
local background=Instance.new("Frame");background.Size=UDim2.fromScale(1,1);background.BackgroundColor3=Theme.Colors.Background;background.BorderSizePixel=0;background.Parent=root
local notice=Instance.new("TextLabel");notice.Name="FixtureNotice";notice.Size=UDim2.new(1,0,0,26);notice.BackgroundColor3=Theme.Colors.Primary
notice.TextColor3=Theme.Colors.Text;notice.TextSize=12;notice.TextWrapped=true;notice.Text="REVIEW FIXTURE â€¢ simulated state â€¢ no saves or rewards";notice.Parent=background
local toolbar=Instance.new("Frame");toolbar.Name="ReviewToolbar";toolbar.Position=UDim2.new(0,8,1,-116);toolbar.Size=UDim2.new(1,-16,0,108);toolbar.BackgroundTransparency=1;toolbar.Parent=background
local status=Instance.new("TextLabel");status.Name="FixtureStatus";status.Size=UDim2.new(1,-16,0,36);status.Position=UDim2.fromOffset(8,64)
status.BackgroundTransparency=1;status.TextColor3=Theme.Colors.Text;status.TextWrapped=true;status.TextSize=13;status.Text="Local fixture ready";status.Parent=background
local scroll=Instance.new("ScrollingFrame");scroll.Name="JournalReviewContent";scroll.Position=UDim2.fromOffset(12,106);scroll.Size=UDim2.new(1,-24,1,-234)
scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.CanvasSize=UDim2.new();scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.ScrollBarThickness=5;scroll.Parent=background
local layout=Instance.new("UIListLayout");layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Padding=UDim.new(0,12);layout.Parent=scroll
local hud=Instance.new("ScreenGui");hud.Name="GuildborneGameplayHUDReview";hud.ResetOnSpawn=false;hud.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;hud.DisplayOrder=1;hud.Enabled=false;hud.Parent=player.PlayerGui
local tracker=require(UI.QuestTrackerView)(hud)
local preview=Instance.new("Frame");preview.Name="SimulatedCombatChrome";preview.Position=UDim2.fromOffset(12,176);preview.Size=UDim2.new(1,-24,0,250);preview.BackgroundTransparency=1;preview.Parent=hud
local actor=Instance.new("TextButton");actor.Name="FixtureActor";actor.Size=UDim2.fromOffset(184,60);actor.Text="SIMULATED HERO\n72 / 100 HP";actor.TextColor3=Theme.Colors.Text;actor.BackgroundColor3=Theme.Colors.Surface;actor.Parent=preview
Chrome.actor(actor).update(true,1,72,100)
local skill=Instance.new("TextButton");skill.Name="FixtureSkill";skill.Position=UDim2.fromOffset(0,76);skill.Size=UDim2.fromOffset(150,56);skill.Text="SIMULATED COOLDOWN";skill.TextWrapped=true;skill.TextColor3=Theme.Colors.Text;skill.BackgroundColor3=Theme.Colors.Surface;skill.Parent=preview
Chrome.skill(skill,1).update(false,3.2,true);skill.Active=false;skill.Selectable=false
local function T(key,values)return Locale.translate(language,key,values)end
local render
local journal=require(UI.Components.JournalPane)({scroll=scroll,T=T,language=function()return language end,
 journalFocus=function()local id=focus;focus=nil;return id end,
 isTracked=function(id)return pinned==id end,
 trackQuest=function(id)pinned=if pinned==id then nil else id;status.Text="LOCAL Track: "..id;render()end,
 navigate=function()mode="HUD";render()end,
 render=function(reset)if reset then scroll.CanvasPosition=Vector2.zero end;render()end,
 act=function(action,args)
  local id=args.questId;local def=catalog.Journal[id];if not def then return end
  local state=JournalState.describe(fixture,catalog,id)
  if action=="AcceptTask" and not state.locked and not fixture.settlement.journal[id] then
   fixture.settlement.journal[id]={state="Active",progress=0};pinned=id
  elseif action=="ClaimTask" and state.ready then
   fixture.settlement.journal[id]={state="Claimed",progress=def.Count}
  else status.Text="LOCAL rejected transition: "..action;return end
  status.Text="LOCAL "..action.." â€¢ "..id.." â€¢ no rewards granted";render()
 end})
local controls={}
local function add(name,text,callback)
 local h=Button.create(toolbar,{name=name,text=text,onActivated=callback});table.insert(controls,h.button)
 h.button.Size=UDim2.new(.5,-6,0,48);h.button.Position=UDim2.new(((#controls-1)%2)*.5,0,0,math.floor((#controls-1)/2)*56);h.button.TextSize=13
 return h.button
end
local languageButton=add("ReviewLanguage","EN / à¹„à¸—à¸¢",function()language=if language=="en" then "th" else "en";render()end)
local modeButton=add("ReviewMode","Show HUD",function()mode=if mode=="Journal" then "HUD" else "Journal";render()end)
add("SimulateProgress","SIM + progress",function()
 local id=pinned or "timber_help";local task=fixture.settlement.journal[id];local def=catalog.Journal[id]
 if task and task.state=="Active" and def then
  if def.Item then fixture.inventory.stacks[def.Item]=math.min(def.Count,(fixture.inventory.stacks[def.Item]or 0)+1)else task.progress=math.min(def.Count,task.progress+1)end
  focus=id;status.Text="SIMULATED progress: "..id;render()
 else status.Text="SIM: accept and track an active quest first"end
end)
add("ResetFixture","Reset fixture",function()
 fixture.settlement.journal={city_gate={state="Claimed",progress=1},timber_help={state="Active",progress=1}};fixture.inventory.stacks={herb=2};pinned="timber_help";focus=pinned;status.Text="LOCAL fixture reset";render()
end)
render=function()
 for _,child in ipairs(scroll:GetChildren())do if child:IsA("GuiObject")then child:Destroy()end end
 scroll.Visible=mode=="Journal";hud.Enabled=mode=="HUD"
 modeButton.Text=if mode=="Journal"then "Show HUD"else "Show journal"
 languageButton.Text=if language=="th"then "à¸ à¸²à¸©à¸²: à¹„à¸—à¸¢"else "Language: EN"
 if mode=="Journal"then journal(fixture,catalog,false)end
 local id=pinned or "timber_help";local state=JournalState.describe(fixture,catalog,id);local def=catalog.Journal[id]
 tracker.update({progress=state.progress,count=def.Count,ready=state.ready},T("Tracked quest"),T(def.Name).." "..state.progress.."/"..def.Count,true)
 root:SetAttribute("FixtureLanguage",language);root:SetAttribute("FixtureMode",mode);root:SetAttribute("FixturePinnedQuest",pinned)
end
tracker.button.Activated:Connect(function()focus=pinned;mode="Journal";render()end)
root.Destroying:Connect(function()hud:Destroy()end)
render()
print("GAMEPLAY_UI_REVIEW_READY: actual JournalPane/QuestTrackerView/CombatChrome; simulated state; no saves/rewards")
