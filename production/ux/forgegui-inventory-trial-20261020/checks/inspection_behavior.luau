local Asset=require(UI.AssetImage)
local Assets=require(game.ReplicatedStorage.Shared.Config.VisualAssets)
test("unknown definition creates neither model nor holder",function()
 local p=Instance.new("Frame");assert(Asset.item(p,"not_a_definition")==nil and #p:GetChildren()==0);p:Destroy()
end)
test("known item and equipment preserve default80 and requested sizes",function()
 for _,id in ipairs({"stone","watchblade"})do
  local p=Instance.new("Frame")
  for _,size in ipairs({80,196,256,512})do
   local art=Asset.item(p,id,if size==80 then nil else {size=size})
   assert(art.Size.X.Offset==size and art.Size.Y.Offset==size)
   local v=art:FindFirstChild("ViewportStub");assert(v.Size.X.Offset==size and v:GetAttribute("ItemId")==id)
  end;p:Destroy()
 end
end)
test("size guard clamps bounds and nonfinite input uses default80",function()
 local p=Instance.new("Frame")
 for _,case in ipairs({{-8,16},{0,16},{900,512},{math.huge,80},{-math.huge,80},{0/0,80}})do
  local a=Asset.item(p,"stone",{size=case[1]});assert(a.Size.X.Offset==case[2]);assert(a:FindFirstChild("ViewportStub").Size.X.Offset==case[2])
 end;p:Destroy()
end)
test("atlas load switches fallback while modelOnly always uses geometry",function()
 local old=Assets.ItemAtlas;Assets.ItemAtlas="rbxassetid://12345"
 local p=Instance.new("Frame");local a=Asset.item(p,"iron_ore",{size=256})
 local image=a:FindFirstChild("AssetArtwork");local model=a:FindFirstChild("ViewportStub")
 assert(image and image.Size.X.Offset==256 and model.Visible and not image.Visible)
 assert(image.ImageRectSize.X>0 and image.ImageRectOffset.X>0)
 image.IsLoaded=true;image:GetPropertyChangedSignal("IsLoaded"):Fire();assert(image.Visible and not model.Visible)
 image.IsLoaded=false;image:GetPropertyChangedSignal("IsLoaded"):Fire();assert(not image.Visible and model.Visible)
 local b=Asset.item(p,"iron_ore",{size=256,modelOnly=true})
 assert(not b:FindFirstChild("AssetArtwork") and b:FindFirstChild("ViewportStub").Visible)
 Assets.ItemAtlas=old;p:Destroy()
end)
for _,width in ipairs({280,320,390,744,968,1210})do
 for _,language in ipairs({"en","th"})do
  test("inspection square and flowing metadata "..width.." "..language,function()
   local root,calls=make(width,"Details",false,language)
   local bay=assert(find(root,"ItemInspectionBay"));local art=assert(bay:FindFirstChild("ItemArtwork"))
   local edge=art.Size.X.Offset;assert(edge==art.Size.Y.Offset and edge>80 and edge<=256)
   assert(art.Position.X.Offset>=8 and art.Position.Y.Offset==8)
   assert(art.Position.X.Offset+edge<=bay.Size.X.Offset-8+.001 and edge+16==bay.Size.Y.Offset)
   assert(not bay.Active and not bay.Selectable and not find(bay,"AssetArtwork"))
   assert(art:FindFirstChild("ViewportStub").Size.X.Offset==edge)
   local title=find(root,"ItemName");local action=find(root,"Assign_one")
   assert(title.LayoutOrder<bay.LayoutOrder and bay.LayoutOrder<action.LayoutOrder)
   local prior=action.LayoutOrder
   for _,name in ipairs({"description","binding","stats","comparison","assignment"})do
    local label=assert(find(root,"Detail_"..name));assert(label.AutomaticSize==Enum.AutomaticSize.Y)
    assert(label.LayoutOrder>prior);prior=label.LayoutOrder
    assert(label.Size.Y.Offset==(if name=="description" or name=="comparison" then 40 else 24))
   end
   local body=bay.Parent;assert(body.AutomaticSize==Enum.AutomaticSize.Y)
   local flow=body:FindFirstChildOfClass("UIListLayout");assert(flow and flow.Padding.Offset==4)
   action.Activated:Fire();assert(calls.assign);root:Destroy();calls.assign=nil;action.Activated:Fire();assert(not calls.assign)
  end)
 end
end
test("busy inspect action stays inert",function()
 local root,calls=make(390,"Details",true);find(root,"Assign_one").Activated:Fire();assert(not calls.assign);root:Destroy()
end)
test("tiles keep80 and zero quantity remains a displayed value",function()
 local root=makeZero(1210,"Items");local tile=assert(find(root,"Item_2"));local art=assert(find(tile,"ItemArtwork"))
 assert(art.Size.X.Offset==80 and art.Size.Y.Offset==80)
 assert(find(tile,"Quantity").Text=="0");root:Destroy()
end)
test("equipment source remains80 at scale.6 with no extra slot",function()
 local root=make(1210,"Items");local slot=assert(find(root,"EquipmentSlot_weapon"))
 local art=assert(find(slot,"ItemArtwork"));local scale=assert(art:FindFirstChildOfClass("UIScale"))
 assert(art.Size.X.Offset==80 and art.Size.Y.Offset==80 and scale.Scale==.6)
 assert(art.Size.X.Offset*scale.Scale==48)
 local count=0
 local function visit(n)if n.Name:match("^EquipmentSlot_")then count+=1 end;for _,c in ipairs(n:GetChildren())do visit(c)end end
 visit(root);assert(count==1,"inspection added an equipment slot")
 root:Destroy()
end)
print("INSPECTION_EXTENSION_TESTS "..passed.." passed; simulation only")
