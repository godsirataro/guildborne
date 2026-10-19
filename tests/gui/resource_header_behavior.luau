--!nocheck
-- Real component/state and rectangle arithmetic; no native glyph/render acceptance.
local Header=require(getfenv().UI.Components.ResourceHeader)
local Layout=require(game.ReplicatedStorage.Shared.Data.CombatHudLayout)
local passed=0
local function test(name,run) run();passed+=1;print("PASS resource header "..name) end
local function descendants(root)
 local result={}
 local function visit(node)
  table.insert(result,node)
  for _,child in ipairs(node:GetChildren()) do visit(child) end
 end
 visit(root);return result
end
local function textNode(root,value)
 for _,node in ipairs(descendants(root)) do
  if node.ClassName=="TextLabel" and node.Visible and node.Text==value then return node end
 end
 return nil
end
local function fixture(w,h)
 local gui=Instance.new("ScreenGui");gui.AbsoluteSize={X=w or 1210,Y=h or 674}
 return gui,Header.new(gui)
end
local function overlap(a,b)
 return a.x<b.x+b.w and b.x<a.x+a.w and a.y<b.y+b.h and b.y<a.y+a.h
end

test("text property simulation follows the native observed coupling on repeated writes",function()
 for _,class in ipairs({"TextLabel","TextButton","TextBox"}) do
  local label=Instance.new(class)
  for _=1,3 do
   label.TextScaled=true
   assert(label.TextScaled and label.TextWrapped,"Scaling must enable wrapping")
   label.TextWrapped=false
   assert(not label.TextScaled and not label.TextWrapped,"Disabling wrap must disable scaling")
   label.TextWrapped=true
   assert(not label.TextScaled,"Wrapping alone must not enable scaling")
   label.TextScaled=true
   label.TextScaled=false
   assert(label.TextWrapped,"Disabling scale must preserve wrapping")
  end
  label:Destroy()
 end
end)

test("all resource labels keep native fitting and explicit hierarchy through updates",function()
 local gui,header=fixture(320,640)
 local root=assert(gui:FindFirstChild("ResourceHeader"))
 local plaque=assert(root:FindFirstChild("ResourcePlaque"))
 for _,copy in ipairs({{nil,"","กำลังโหลด"},{"0","Gold · Hall Lv0","Loading"},
  {"9007199254740991","ทอง · หอกิลด์ 20","กำลังโหลด"}}) do
  header.update(copy[1],copy[2],copy[3])
  for name,maximum in pairs({GoldValue=22,ResourceCaption=13,ResourceLoading=16}) do
   local label=assert(plaque:FindFirstChild(name))
   local constraint=assert(label:FindFirstChild("UITextSizeConstraint"))
   assert(label.TextScaled and label.TextWrapped,name.." lost native scaling")
   assert(label.TextSize==maximum and constraint.MaxTextSize==maximum,name.." lost explicit fallback size")
  end
 end
 assert(plaque:FindFirstChild("GoldValue").Size[4]==24)
 assert(plaque:FindFirstChild("ResourceCaption").Size[4]==16,"Caption geometry changed")
 header.destroy();gui:Destroy()
end)
test("header lanes fit and clear existing HUD across breakpoints",function()
 local count=0
 for _,w in ipairs({320,390,600,796,844,899,900,945,1210,1920}) do
  for _,h in ipairs({240,340,449,450,568,570,640,844}) do
   local l=Layout(w,h)
   for _,name in ipairs({"resourceRect","menuRect","trackerRect"}) do
    local r=assert(l[name],name)
    assert(r.w>0 and r.h>0 and r.x>=0 and r.y>=0 and r.x+r.w<=w and r.y+r.h<=h,name.." outside "..w.."x"..h)
   end
   assert(l.menuRect.w>=44 and l.menuRect.h>=44,"Menu touch target shrank")
   assert(l.trackerRect.w>=44 and l.trackerRect.h>=44,"Quest touch target shrank")
   assert(not overlap(l.resourceRect,l.menuRect),"Resource/menu overlap")
   for _,r in ipairs({l.resourceRect,l.menuRect}) do
    for _,other in ipairs({l.trackerRect,l.mapRect,l.rosterRect,l.padRect}) do
     assert(not overlap(r,other),"Header covers existing HUD at "..w.."x"..h)
    end
   end
   if l.trackerWide then
    assert(l.menuRect.x-(l.resourceRect.x+l.resourceRect.w)>=w*.35,"Desktop center must remain visibly clear")
   end
   count+=1
  end
 end
 print("  "..count.." viewport rectangle cases")
end)
test("missing snapshot is loading while genuine zero stays zero",function()
 local gui,header=fixture()
 header.update(nil,"Gold · Hall 1","Loading…")
 assert(textNode(gui,"Loading…"),"Missing data must show supplied loading text")
 assert(not textNode(gui,"0"),"Missing data fabricated a zero")
 header.update("0","Gold · Hall 1","Loading…")
 assert(textNode(gui,"0"),"Actual zero lost")
 assert(textNode(gui,"Gold · Hall 1"),"Actual caption lost")
 assert(not textNode(gui,"Loading…"),"Loading remained after snapshot")
 header.destroy();gui:Destroy()
end)
test("EN TH and long formatted values survive reflow without replacing the native action",function()
 local gui,header=fixture();local button=header.button
 assert(button.ClassName=="TextButton" and button.Active and button.Selectable)
 local activations=0;local connection=button.Activated:Connect(function()activations+=1 end)
 local instances=#descendants(gui)
 for _,copy in ipairs({{"9,999,999,999,999,999","Gold · Hall 120"},{"9,999,999,999,999,999","ทอง · หอสมาคม 120"}}) do
  header.update(copy[1],copy[2],"Loading…")
  for _,size in ipairs({{320,568},{390,844},{600,340},{796,674},{900,640},{1210,674},{1920,1080}}) do
   gui.AbsoluteSize={X=size[1],Y=size[2]};gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
   assert(header.button==button and not button.destroyed,"Reflow replaced action/focus identity")
   assert(textNode(gui,copy[1]) and textNode(gui,copy[2]),"Reflow changed authoritative formatted copy")
   local value=textNode(gui,copy[1]);local constraint=value:FindFirstChild("UITextSizeConstraint")
   assert(value.TextScaled and constraint and constraint.MinTextSize>=12,"Long value must retain bounded readable type")
   assert(button.Size[2]>=44 and button.Size[4]>=44)
   assert(#descendants(gui)==instances,"Reflow accumulated instances")
   button.Activated:Fire()
  end
 end
 assert(activations==14,"External menu binding lost or duplicated")
 connection:Disconnect();header.destroy();gui:Destroy()
end)
test("destroy is idempotent and detaches resize callback",function()
 local gui,header=fixture();local button=header.button
 header.update("123","Gold · Hall 1","Loading…")
 header.destroy();header.destroy()
 assert(button.destroyed,"Action survived teardown")
 local position,size=button.Position,button.Size
 gui.AbsoluteSize={X=320,Y=568};gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 header.update("456","ทอง · หอสมาคม 2","Loading…")
 assert(button.Position==position and button.Size==size,"Destroyed header handled resize")
 gui:Destroy()
end)
test("external GUI teardown releases each mounted header",function()
 for _=1,5 do
  local gui,header=fixture();local button=header.button
  local root=assert(gui:FindFirstChild("ResourceHeader"))
  assert(root.BackgroundTransparency==1 and not root.Active,"Clear center became an opaque input blocker")
  header.update("654","ทอง · หอสมาคม 1","กำลังโหลด…")
  gui:Destroy()
  local position,size=button.Position,button.Size
  gui.AbsoluteSize={X=390,Y=844};gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
  assert(button.destroyed and button.Position==position and button.Size==size,"External teardown left resize listener active")
  header.destroy()
 end
end)
print(passed.." resource header cases passed (simulation only).")
