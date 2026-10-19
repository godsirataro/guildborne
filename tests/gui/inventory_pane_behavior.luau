--!nocheck
-- Geometry intent and callbacks only. Preview/physics/font shaping are not simulated.
local Pane=require(UI.Components.InventoryPane)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local passed=0
local function test(name,fn)fn();passed+=1;print("PASS "..name)end
local function find(root,name)
 if root.Name==name then return root end
 for _,c in ipairs(root:GetChildren())do local hit=find(c,name);if hit then return hit end end
end
local function make(width,view,busy,language,actorCount)
 local parent=Instance.new("Frame")
 local calls={}
 local T=function(key)return Locale.translate(language or "en",key)end
 local model={T=T,title=T("Shared inventory"),capacity="Equipment 2/50",actorName="Your character",actorId="player",data={},stats="HP63 / Attack19 / Defense4",view=view or "Items",busy=busy,
 actors={{id="player",name="Your character",selected=true,onSelect=function()calls.actor=true end}},
 slots={{slot="weapon",label="Weapon",itemName="Training Sword",definitionId="training_sword",onUnequip=function()calls.unequip=true end,enabled=not busy}},
 filters={{id="All",label="All",selected=true,onSelect=function()calls.filter=true end}},items={},shopLabel="Shop",sortLabel="Sort: Name",compatibleLabel="Compatible",onShop=function()calls.shop=true end,onSort=function()end,onCompatible=function()end,
 onView=function(v)calls.view=v end,onBack=function()calls.back=true end,
 selected={name="Training Sword",definitionId="training_sword",description="Actual item description",binding="Account bound",stats="HP0 Attack5 Defense0",actions={{name="Assign_one",label="Equip",enabled=not busy,callback=function()calls.assign=true end}}}}
 model.actors={}
 for i=1,actorCount or 1 do table.insert(model.actors,{id=if i==1 then "player" else "hero"..i,name=T("Your character").." "..i,selected=i==1,onSelect=function()calls.actor=i end})end
 model.filters={}
 for _,kind in ipairs({"All","Weapon","Armor","Accessory","Material"})do table.insert(model.filters,{id=kind,label=T(kind),selected=kind=="All",onSelect=function()calls.filter=kind end})end
 for i=1,30 do table.insert(model.items,{id=tostring(i),name="Sword "..i,definitionId="training_sword",quantity=if i==2 then 123 else nil,selected=i==1,onSelect=function()calls.item=i end})end
 local root=Pane(parent,model);root.AbsoluteSize={X=width,Y=700};root:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 return root,calls
end
test("medium first viewport exposes actual actor and grid then selected details in place",function()
 local root,calls=make(744)
 assert(find(root,"SelectedActorLoadout") and find(root,"ItemGrid").Position.Y.Offset<208)
 assert(not find(root,"SelectedItemDetails"));find(root,"Item_1").Activated:Fire();assert(calls.item==1);root:Destroy()
 root,calls=make(744,"Details");assert(not find(root,"ItemGrid") and find(root,"SelectedItemDetails").Position.Y.Offset==38)
 find(root,"BackToItems").Activated:Fire();assert(calls.back);find(root,"Assign_one").Activated:Fire();assert(calls.assign);root:Destroy()
end)
test("desktop has three panes and phone switches real view without squeezing columns",function()
 local root=make(968);assert(find(root,"SelectedActorLoadout") and find(root,"ItemGrid") and find(root,"SelectedItemDetails"));root:Destroy()
 root=make(280,"Items");assert(find(root,"View_Loadout") and find(root,"ItemGrid") and not find(root,"SelectedActorLoadout"))
 local grid=find(root,"ItemGrid");assert(grid.Position.Y.Offset+grid:FindFirstChildOfClass("UIGridLayout").CellSize.Y.Offset<=380);root:Destroy()
 root=make(288,"Loadout");assert(find(root,"SelectedActorLoadout") and not find(root,"ItemGrid"));root:Destroy()
 root=make(288,"Details");assert(find(root,"SelectedItemDetails") and find(root,"BackToItems"));root:Destroy()
end)
test("busy native controls cannot dispatch and destroyed controls remain inert",function()
 local root,calls=make(744,"Details",true)
 find(root,"Assign_one").Activated:Fire();find(root,"Unequip_weapon").Activated:Fire();assert(not calls.assign and not calls.unequip)
 local b=find(root,"Assign_one");root:Destroy();b.Activated:Fire();assert(not calls.assign)
end)
test("paging limits item previews and reaches every item",function()
 local root,calls=make(744)
 assert(find(root,"NextItems").Text==utf8.char(0x203A) and find(root,"PreviousItems").Text==utf8.char(0x2039),"pager glyph encoding")
 assert(find(root,"Item_24") and not find(root,"Item_25"))
 find(root,"NextItems").Activated:Fire();assert(find(root,"Item_25") and find(root,"Item_30") and not find(root,"Item_1"))
 find(root,"Item_30").Activated:Fire();assert(calls.item==30);root:Destroy()
end)
test("Thai headings and new controls retain live localized text",function()
 local root=make(288,"Details",false,"th")
 assert(find(root,"View_Details").Text=="รายละเอียด" and find(root,"ItemName").Font==Enum.Font.GothamMedium)
 assert(Locale.translate("th","Actor preview unavailable")~="Actor preview unavailable");root:Destroy()
end)
test("storage focus hover and press never select before activation; busy and stale tiles cannot dispatch",function()
 local root,calls=make(744)
 local selected=find(root,"Item_1");local tile=find(root,"Item_2")
 assert(find(selected,"SelectedCorners").Visible and not find(tile,"SelectedCorners").Visible)
 assert(not find(tile,"ButtonBevel") and not find(tile,"SelectedMark"),"storage must not retain action decoration")
 tile.MouseEnter:Fire();tile.SelectionGained:Fire()
 assert(find(tile,"StorageRim").Thickness==2 and calls.item==nil)
 tile.InputBegan:Fire({UserInputType=Enum.UserInputType.Touch});tile.InputEnded:Fire()
 assert(calls.item==nil and not find(tile,"SelectedCorners").Visible,"focus or press invented selection")
 tile.Activated:Fire();assert(calls.item==2)
 tile.SelectionLost:Fire();tile.MouseLeave:Fire();assert(find(tile,"StorageRim").Thickness==1)
 local quantity=find(tile,"Quantity");assert(quantity.Text=="123" and quantity.BackgroundTransparency<1)
 root:Destroy();calls.item=nil;tile.Activated:Fire();tile.SelectionGained:Fire();assert(calls.item==nil)
 root,calls=make(280,"Items",true)
 tile=find(root,"Item_2");assert(not tile.Active and not tile.Selectable)
 tile.MouseEnter:Fire();tile.SelectionGained:Fire();tile.Activated:Fire()
 assert(calls.item==nil and find(tile,"StorageRim").Thickness==1);root:Destroy()
end)
test("paging destroys storage callbacks and decorative corners never become hit targets",function()
 local root,calls=make(744)
 local old=find(root,"Item_2")
 local function passive(node)
  for _,child in ipairs(node:GetChildren())do
   if child:IsA("Frame")then assert(child.Active==false and child.Selectable==false,"interactive storage corner");passive(child)end
  end
 end
 passive(find(root,"Item_1"):FindFirstChild("SelectedCorners"))
 find(root,"NextItems").Activated:Fire()
 old.Activated:Fire();assert(calls.item==nil)
 find(root,"Item_25").Activated:Fire();assert(calls.item==25);root:Destroy()
end)
test("pane painter order keeps nested stage behind avatar and quantity above item artwork",function()
 local function visit(node,fn)fn(node);for _,child in ipairs(node:GetChildren())do visit(child,fn)end end
 for _,width in ipairs({280,744,968})do
  local root=make(width,if width<600 then "Loadout" else "Items")
  local preview=find(root,"InventoryActorPreview");local viewport=find(preview,"ActorViewport")
  visit(find(preview,"PortraitStage"),function(node)
   if node:IsA("GuiObject")then assert(node.ZIndex<viewport.ZIndex,"decoration paints over avatar")end
  end)
  assert(find(preview,"PreviewUnavailable").ZIndex>viewport.ZIndex)
  root:Destroy()
  root=make(width,"Items")
  local tile=find(root,"Item_2");local quantity=find(tile,"Quantity")
  local art=find(tile,"ItemArtwork");local top=0
  visit(art,function(node)if node:IsA("GuiObject")then top=math.max(top,node.ZIndex)end end)
  assert(quantity.ZIndex>top,"item artwork covers quantity plate")
  visit(find(tile,"SelectedCorners"),function(node)
   if node:IsA("GuiObject")then assert(node.ZIndex>top,"artwork covers selected corners")end
  end)
  root:Destroy()
 end
end)
local function bottom(node)return node.Position.Y.Offset+node.Size.Y.Offset end
local function inside(child,parent)
 assert(child.Position.X.Offset>=0 and child.Position.Y.Offset>=0,"negative child origin")
 assert(child.Position.X.Offset+child.Size.X.Offset<=parent.Size.X.Offset+1,"category cropped horizontally")
 assert(bottom(child)<=parent.Size.Y.Offset+1,"category cropped vertically")
end
local function unique(root)
 local seen={};for _,child in ipairs(root:GetChildren())do assert(not seen[child.Name],"duplicate "..child.Name);seen[child.Name]=true end
end
for _,language in ipairs({"en","th"})do
 for _,actorCount in ipairs({0,1,6})do
  for _,width in ipairs({280,744,968})do
   test("density matrix "..language.." actors="..actorCount.." width="..width,function()
    local root,calls=make(width,"Items",false,language,actorCount)
    unique(root)
    local actors=find(root,"ActorSelection")
    assert((actors~=nil)==(actorCount>1),"unnecessary actor selector retains empty space")
    if actors then
     local last=find(actors,"Actor_hero6");assert(last and actors.CanvasSize.X.Offset>=last.Position.X.Offset+last.Size.X.Offset)
     last.Activated:Fire();assert(calls.actor==6,"last hero unreachable")
    end
    local categories=find(root,"ItemCategories")
    local grid=find(root,"ItemGrid")
    if width<600 then
     assert(bottom(find(root,"View_Items"))<=categories.Position.Y.Offset,"view tabs overlap categories")
     assert(grid.Position.Y.Offset+grid:FindFirstChildOfClass("UIGridLayout").CellSize.Y.Offset<=380,"first complete phone row below fold")
     local picker=find(root,"CategoryPicker");assert(picker and picker.Size.Y.Offset>=48)
     assert(picker.Text==Locale.translate(language,"All"),"picker must retain full localized label only")
     local chevron=find(picker,"CategoryChevron")
     assert(chevron and chevron:IsA("Frame") and chevron.Rotation==0,"closed native chevron")
     assert(not chevron.Active and not chevron.Selectable,"decoration intercepts picker")
     local padding=picker:FindFirstChildOfClass("UIPadding")
     assert(padding.PaddingLeft.Offset==8 and padding.PaddingRight.Offset==36,"reserve chevron text space locally")
     local center=picker.Size.X.Offset-padding.PaddingRight.Offset+chevron.Position.X.Offset
     assert(center-chevron.Size.X.Offset/2>picker.Size.X.Offset-padding.PaddingRight.Offset)
     assert(center+chevron.Size.X.Offset/2<picker.Size.X.Offset,"chevron exceeds button")
     assert(find(chevron,"Stroke1").Rotation==45 and find(chevron,"Stroke2").Rotation==-45)
     for _,stroke in ipairs(chevron:GetChildren())do
      assert(stroke:IsA("Frame") and stroke.Size.X.Offset==9 and stroke.Size.Y.Offset==2 and stroke.BackgroundTransparency==0)
      assert(not stroke.Active and not stroke.Selectable)
     end
     local closedGridY=grid.Position.Y.Offset
     picker.Activated:Fire();categories=find(root,"ItemCategories");grid=find(root,"ItemGrid")
     assert(find(root,"CategoryPicker").Text==Locale.translate(language,"All"),"expanded picker full label")
     assert(find(root,"CategoryChevron").Rotation==180,"expanded native chevron must point up")
     assert(find(root,"CategoryChevron")~=chevron,"chevron not rebuilt with picker state")
     assert(grid.Position.Y.Offset>closedGridY,"expanded categories overlay grid")
    else
     local stage=find(root,"ActorStage");assert(stage)
     if width<900 then assert(stage.Size.Y.Offset>=180,"medium portrait too small")end
     assert(find(root,"SelectedActorLoadout").Position.Y.Offset==categories.Position.Y.Offset,"actor stage moves grid start")
     if actorCount<=1 then assert(categories.Position.Y.Offset<=38,"empty header gap retained")end
    end
    local tools=find(root,"InventoryTools");assert(tools.Position.Y.Offset>=bottom(categories),"categories overlap tools")
    assert(grid.Position.Y.Offset>=bottom(tools),"tools overlap grid")
    local boxes={}
    for _,kind in ipairs({"All","Weapon","Armor","Accessory","Material"})do
     local button=find(root,"Filter_"..kind);assert(button and button.Text==Locale.translate(language,kind))
     assert(button.TextSize>=15 and button.Size.Y.Offset>=48,"category unreadable or untappable")
     inside(button,categories)
     for _,other in ipairs(boxes)do
      assert(button.Position.X.Offset>=other.Position.X.Offset+other.Size.X.Offset or other.Position.X.Offset>=button.Position.X.Offset+button.Size.X.Offset or button.Position.Y.Offset>=bottom(other) or other.Position.Y.Offset>=bottom(button),"category overlap")
     end
     table.insert(boxes,button)
    end
    -- Check bounds before callbacks; a phone selection intentionally closes its menu.
    find(root,"Filter_Material").Activated:Fire();assert(calls.filter=="Material")
    if width<600 then
     assert(not find(root,"Filter_Material"),"phone selection did not collapse")
     assert(find(root,"CategoryChevron").Rotation==0,"selection did not restore downward chevron")
     find(root,"View_Loadout").Activated:Fire();assert(calls.view=="Loadout")
    end
    root:Destroy()
    if width<600 then
     root=make(width,"Loadout",false,language,actorCount)
     assert(find(root,"SelectedActorLoadout") and find(root,"SimulatedPreview"),"actor view lost")
     root:Destroy()
    end
   end)
  end
 end
end
test("busy phone picker and category controls cannot dispatch",function()
 local root,calls=make(280,"Items",true,"th",6)
 find(root,"CategoryPicker").Activated:Fire()
 assert(not find(root,"Filter_Material") and not calls.filter)
 root:Destroy()
 local medium,mediumCalls=make(744,"Items",true,"en",6)
 find(medium,"Filter_Material").Activated:Fire();find(medium,"Actor_hero6").Activated:Fire()
 assert(not mediumCalls.filter and not mediumCalls.actor);medium:Destroy()
end)
print("SUMMARY "..passed.." inventory pane simulations passed")
