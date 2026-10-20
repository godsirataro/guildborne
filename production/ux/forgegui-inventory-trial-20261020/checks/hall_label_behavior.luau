-- Actual catalog definitions and projection; recording pane does not emulate clicks.
local passed,failed=0,0
local function test(name,fn)
 local ok,err=pcall(fn)
 if ok then passed+=1;print("PASS "..name)else failed+=1;print("FAIL "..name..": "..tostring(err))end
end
local function fixture(language,id)
 local catalog={Items=Content.Items,ItemOrder=Content.ItemOrder,Character=Content.Character,EquipmentLimit=50}
 local data={character={classId="Priest",equipmentSlots={},stats={Health=20,Attack=4,Defense=3}},adventurers={},
  inventory={equipment={},stacks={}},quests={firstClears={}},gold=1000,hallLevel=0}
 local result,draw,busy;local intents={}
 local env=setmetatable({game={ReplicatedStorage={Shared={Data={Equipment="gear"}}}},script={Parent={Components={InventoryPane="pane"}}}},{__index=getfenv()})
 env.require=function(name)if name=="gear"then return Equipment end;assert(name=="pane");return function(_,m)result=m end end
 local fn=assert(loadstring(source));setfenv(fn,env)
 local function T(key,values)return Locale.translate(language,key,values)end
 draw=fn()({scroll={},T=T,render=function()draw(data,catalog,busy)end,act=function(name,payload)table.insert(intents,{name=name,payload=payload})end})
 draw(data,catalog,false);result.onShop()
 local function select(target)
  for _,item in ipairs(result.items)do if item.definitionId==target then item.onSelect();return end end
  error("missing real catalog item "..target)
 end
 select(id)
 return {data=data,catalog=catalog,intents=intents,select=select,T=T,
  model=function()return result end,
  draw=function(value)busy=value==true;draw(data,catalog,busy)end,
  action=function()return result.selected.actions[1]end}
end
assert(Content.Items.apprentice_staff.HallLevel==nil,"regression requires actual omitted HallLevel")
for _,language in ipairs({"en","th"})do
 for _,id in ipairs({"apprentice_staff","harbor_mail","dawn_crozier"})do
  test(language.." real "..id.." Hall label uses effective minimum",function()
   local f=fixture(language,id);local expected=Content.Items[id].HallLevel or 1
   local action=f.action()
   assert(not action.enabled,"Hall0 must remain locked")
   assert(action.label==f.T("Requires Hall Lv{level}",{level=expected}),action.label)
   assert(not action.label:find("{level}",1,true),"unresolved placeholder")
   assert(#f.intents==0)
  end)
 end
 test(language.." exact threshold price capacity and busy gates",function()
  local f=fixture(language,"apprentice_staff");local price=Content.Items.apprentice_staff.Price
  f.data.hallLevel=1;f.data.gold=price;f.draw();assert(f.action().enabled)
  assert(f.action().label==f.T("Buy · {amount} Gold",{amount=price}))
  f.data.gold=price-1;f.draw();assert(not f.action().enabled)
  f.data.gold=price;f.catalog.EquipmentLimit=0;f.draw();assert(not f.action().enabled)
  f.catalog.EquipmentLimit=50;f.draw(true);assert(not f.action().enabled);f.action().callback();assert(#f.intents==0)
  f.draw(false);assert(f.action().enabled)
 end)
 test(language.." explicit Hall threshold retained",function()
  local f=fixture(language,"dawn_crozier")
  f.data.hallLevel=2;f.draw();assert(not f.action().enabled)
  f.data.hallLevel=3;f.data.gold=Content.Items.dawn_crozier.Price;f.draw();assert(f.action().enabled)
 end)
 test(language.." selecting is nonmutating and intentional purchase has canonical payload",function()
  local f=fixture(language,"apprentice_staff");local gold=f.data.gold;local equipment=f.data.inventory.equipment
  f.select("dawn_crozier");f.select("apprentice_staff")
  assert(#f.intents==0 and f.data.gold==gold and f.data.inventory.equipment==equipment and next(equipment)==nil)
  f.data.hallLevel=1;f.draw();assert(f.action().enabled and #f.intents==0)
  f.action().callback()
  assert(#f.intents==1 and f.intents[1].name=="BuyEquipment" and f.intents[1].payload.definitionId=="apprentice_staff")
  assert(f.data.gold==gold and next(equipment)==nil,"view must not award locally")
 end)
end
print("HALL_LABEL_TESTS "..passed.." passed "..failed.." failed; actual projection, simulated pane")
assert(failed==0,"Hall label regression")
