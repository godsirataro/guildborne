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
local function make(width,view,busy,language)
 local parent=Instance.new("Frame")
 local calls={}
 local T=function(key)return Locale.translate(language or "en",key)end
 local model={T=T,title=T("Shared inventory"),capacity="Equipment 2/50",actorName="Your character",actorId="player",data={},stats="HP63 / Attack19 / Defense4",view=view or "Items",busy=busy,
 actors={{id="player",name="Your character",selected=true,onSelect=function()calls.actor=true end}},
 slots={{slot="weapon",label="Weapon",itemName="Training Sword",definitionId="training_sword",onUnequip=function()calls.unequip=true end,enabled=not busy}},
 filters={{id="All",label="All",selected=true,onSelect=function()calls.filter=true end}},items={},shopLabel="Shop",sortLabel="Sort: Name",compatibleLabel="Compatible",onShop=function()calls.shop=true end,onSort=function()end,onCompatible=function()end,
 onView=function(v)calls.view=v end,onBack=function()calls.back=true end,
 selected={name="Training Sword",definitionId="training_sword",description="Actual item description",binding="Account bound",stats="HP0 Attack5 Defense0",actions={{name="Assign_one",label="Equip",enabled=not busy,callback=function()calls.assign=true end}}}}
 for i=1,30 do table.insert(model.items,{id=tostring(i),name="Sword "..i,definitionId="training_sword",selected=i==1,onSelect=function()calls.item=i end})end
 local root=Pane(parent,model);root.AbsoluteSize={X=width,Y=700};root:GetPropertyChangedSignal("AbsoluteSize"):Fire()
 return root,calls
end
test("medium first viewport exposes actual actor and grid then selected details in place",function()
 local root,calls=make(744)
 assert(find(root,"SelectedActorLoadout") and find(root,"ItemGrid").Position.Y.Offset==208)
 assert(not find(root,"SelectedItemDetails"));find(root,"Item_1").Activated:Fire();assert(calls.item==1);root:Destroy()
 root,calls=make(744,"Details");assert(not find(root,"ItemGrid") and find(root,"SelectedItemDetails").Position.Y.Offset==94)
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
 assert(find(root,"Item_24") and not find(root,"Item_25"))
 find(root,"NextItems").Activated:Fire();assert(find(root,"Item_25") and find(root,"Item_30") and not find(root,"Item_1"))
 find(root,"Item_30").Activated:Fire();assert(calls.item==30);root:Destroy()
end)
test("Thai headings and new controls retain live localized text",function()
 local root=make(288,"Details",false,"th")
 assert(find(root,"View_Details").Text=="รายละเอียด" and find(root,"ItemName").Font==Enum.Font.GothamMedium)
 assert(Locale.translate("th","Actor preview unavailable")~="Actor preview unavailable");root:Destroy()
end)
print("SUMMARY "..passed.." inventory pane simulations passed")
