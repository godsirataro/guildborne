--!nocheck
-- Loaded by run.py with actual component source and the documented simulation.
local UI = getfenv().UI
local Button = require(UI.Components.GuildborneButton)
local Tabs = require(UI.Components.TabBar)
local Header = require(UI.Components.HeaderBar)
local Panel = require(UI.Components.GuildbornePanel)
local root = Instance.new("Frame")
local function find(parent,name)
 if parent.Name==name then return parent end
 for _,child in ipairs(parent:GetChildren()) do
  local match=find(child,name); if match then return match end
 end
 return nil
end
local passed = 0
local function test(name, callback)
 callback(); passed += 1; print("PASS " .. name)
end
test("disabled and pending independently guard activation", function()
 local count = 0
 local h = Button.create(root, {text="Continue", onActivated=function() count+=1 end})
 h.button.Activated:Fire(); assert(count==1)
 h.setDisabled(true); h.button.Activated:Fire(); assert(count==1 and not h.button.Selectable)
 h.setPending(true); h.setDisabled(false); h.button.Activated:Fire(); assert(count==1)
 h.setPending(false); h.button.Activated:Fire(); assert(count==2 and h.button.Selectable)
 h.setSelected(true); assert(h.button:GetAttribute("Selected"))
 h.destroy(); h.button.Activated:Fire(); assert(count==2)
end)
test("external destruction disconnects callbacks", function()
 local h = Button.create(root, {onActivated=function() error("destroyed activation") end})
 h.button:Destroy(); h.button.Activated:Fire(); h.destroy()
end)
test("invalid and disabled tab selections preserve selected tab", function()
 local selected = {}
 local h = Tabs.create(root, {{id="a",label="A"},{id="b",label="B"}}, function(id) table.insert(selected,id) end)
 local a,b = h.frame:FindFirstChild("a"),h.frame:FindFirstChild("b")
 h.select("a"); h.select("missing"); assert(a:GetAttribute("Selected"))
 h.setDisabled("b",true); h.select("b"); b.Activated:Fire()
 assert(a:GetAttribute("Selected") and #selected==0)
 h.setDisabled("b",false); b.Activated:Fire()
 assert(b:GetAttribute("Selected") and not a:GetAttribute("Selected") and selected[1]=="b")
 h.destroy(); b.Activated:Fire(); assert(#selected==1)
end)
test("missing and rejected logo IDs preserve live wordmark", function()
 for _, id in ipairs({"", "https://example.invalid/logo.png", "rbxassetid://0"}) do
  local h=Header.create(root,{logoId=id,subtitle="ภาษาไทย"})
  assert(h.wordmark.Visible and not h.frame:FindFirstChild("GuildborneLogo"))
  h.setSubtitle("Ready"); assert(h.subtitle.Text=="Ready")
  h.setCompact(true); assert(h.wordmark.TextSize < 36); h.destroy()
 end
end)
test("logo loading toggles fallback without hiding subtitle", function()
 local h=Header.create(root,{logoId="rbxassetid://123",subtitle="Ready"})
 local logo=h.frame:FindFirstChild("GuildborneLogo")
 assert(h.wordmark.Visible and not logo.Visible)
 logo.IsLoaded=true; logo:GetPropertyChangedSignal("IsLoaded"):Fire()
 assert(not h.wordmark.Visible and logo.Visible and h.subtitle.Visible)
 logo.IsLoaded=false; logo:GetPropertyChangedSignal("IsLoaded"):Fire(); assert(h.wordmark.Visible)
 h.destroy()
end)
test("panel remains native when no uploaded slice is available", function()
 local panel=Panel.create(root,{sliceImage="",sliceCenter={}})
 assert(panel.ClassName=="Frame" and panel:FindFirstChild("GoldBorder"))
 assert(not find(panel,"OptionalSliceBorder")); panel:Destroy()
end)
test("valid slice uses nested decoration and preserves supplied slice center", function()
 local center={Min={X=8,Y=8},Max={X=24,Y=24}}
 local panel=Panel.create(root,{sliceImage="rbxassetid://123",sliceCenter=center})
 local slice=find(panel,"OptionalSliceBorder")
 assert(slice and slice.Parent.Name=="Decoration")
 assert(slice.Image=="rbxassetid://123" and slice.ScaleType==Enum.ScaleType.Slice)
 assert(slice.SliceCenter==center); panel:Destroy()
end)
local Title = require(UI.TitleView)
test("title waits for active profile and enters once on repeated Continue",function()
 local entered,languages=0,0
 local parent=Instance.new("ScreenGui");parent.Parent=root;parent.Enabled=true
 local h=Title(parent,function() entered+=1 end,function() languages+=1 end)
 local play,language=find(parent,"Continue"),find(parent,"Language")
 local tab=Services.ContextActionService.bindings.GuildborneTitleKeyboardFocus
 local before=Services.FocusCalls or 0
 tab.callback("GuildborneTitleKeyboardFocus",Enum.UserInputState.Begin)
 assert(Services.FocusCalls==before+1)
 play.Activated:Fire();language.Activated:Fire();assert(entered==0 and languages==0)
 h.update({status="Loading",data={language="en"}})
 play.Activated:Fire();language.Activated:Fire();assert(entered==0 and languages==0)
 h.update({status="Active",data={language="th",progression={novice={claimed=0}}}})
 assert(play.Text=="เริ่มเส้นทางนักผจญภัย")
 language.Activated:Fire();assert(languages==1)
 play.Activated:Fire();play.Activated:Fire();assert(entered==1 and not h.isOpen())
 find(parent,"TitleScreen"):GetPropertyChangedSignal("Visible"):Fire()
 assert(not Services.ContextActionService.bindings.GuildborneTitleKeyboardFocus)
 local company=find(parent,"HeroStage")
 assert(company:GetAttribute("PreviewDestroys")==1)
 parent:Destroy();assert(company:GetAttribute("PreviewDestroys")==1)
end)
test("title recovery hands off once and cleans preview",function()
 local entered=0;local parent=Instance.new("ScreenGui")
 local h=Title(parent,function() entered+=1 end,function() end)
 h.update({status="Degraded"});h.update({status="LeaseLost"})
 assert(entered==1 and not h.isOpen())
 assert(find(parent,"HeroStage"):GetAttribute("PreviewDestroys")==1)
 parent:Destroy()
end)
test("Title Tab delegates focus and releases input outside visible menu",function()
 local focus=require(UI.Components.TitleKeyboardFocus)
 local screen=Instance.new("ScreenGui");screen.Parent=root;screen.Enabled=true
 local frame=Instance.new("Frame");frame.Parent=screen
 local count=0;local h=focus.bind(frame,screen,function() count+=1 end)
 local actions=Services.ContextActionService
 local name="GuildborneTitleKeyboardFocus"
 local binding=actions.bindings[name]
 frame:GetPropertyChangedSignal("Visible"):Fire();assert(actions.bindings[name]==binding)
 assert(binding and not binding.touch and binding.priority==3000 and binding.key==Enum.KeyCode.Tab)
 assert(binding.callback(name,Enum.UserInputState.Begin)==Enum.ContextActionResult.Sink and count==1)
 binding.callback(name,Enum.UserInputState.End);assert(count==1)
 Services.UserInputService.focused={}
 assert(binding.callback(name,Enum.UserInputState.Begin)==Enum.ContextActionResult.Pass and count==1)
 Services.UserInputService.focused=nil;Services.GuiService.MenuIsOpen=true
 assert(binding.callback(name,Enum.UserInputState.Begin)==Enum.ContextActionResult.Pass and count==1)
 Services.GuiService.MenuIsOpen=false
 frame.Visible=false;frame:GetPropertyChangedSignal("Visible"):Fire();assert(not actions.bindings[name])
 assert(binding.callback(name,Enum.UserInputState.Begin)==Enum.ContextActionResult.Pass)
 frame.Visible=true;frame:GetPropertyChangedSignal("Visible"):Fire();assert(actions.bindings[name])
 screen.Enabled=false;screen:GetPropertyChangedSignal("Enabled"):Fire();assert(not actions.bindings[name])
 screen.Enabled=true;screen:GetPropertyChangedSignal("Enabled"):Fire();assert(actions.bindings[name])
 frame:Destroy();assert(not actions.bindings[name]);h.destroy()
 frame:GetPropertyChangedSignal("Visible"):Fire();assert(not actions.bindings[name])
 screen:Destroy()
end)
test("Title scene remains intentional without heroes and bounds decorative geometry",function()
 local parent=Instance.new("ScreenGui")
 local h=Title(parent,function() end,function() end)
 local world=find(parent,"DecorativeCitadel");assert(world)
 local count=0
 for _,part in ipairs(world:GetChildren()) do
  assert(part.ClassName=="Part" or part.ClassName=="WedgePart")
  assert(part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery)
  count+=1
 end
 assert(count>0 and count<=60)
 local scroll=find(parent,"TitleContent")
 local story=find(parent,"YourCompany");local controls=find(parent,"EntryControls")
 controls.AbsoluteSize={X=220,Y=380};story.AbsoluteSize={X=400,Y=464}
 for _,width in ipairs({320,680,1280}) do
  scroll.AbsoluteSize={X=width,Y=600};scroll:GetPropertyChangedSignal("AbsoluteSize"):Fire()
  local rail=find(parent,"EntryRail")
  assert(rail.Size[4]==416)
  assert(rail.Size[1]==(if width<680 then 1 else .35))
  assert(story.Position[4]==(if width<680 then 440 else 0))
 end
 h.update({status="Active",data={language="th",progression={novice={claimed=0}}}})
 assert(find(parent,"ChapterHeading").Font==Enum.Font.GothamMedium)
 assert(find(parent,"CitadelDiorama").Visible)
 parent:Destroy()
end)
print("PASS "..passed.." simulated GUI behavior cases; Studio/device acceptance remains pending")
