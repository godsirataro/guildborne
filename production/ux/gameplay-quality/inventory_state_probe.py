"""Execute actual InventoryView with actual pure Equipment rules and a recording pane."""
from pathlib import Path
import subprocess, tempfile
ROOT=Path(__file__).resolve().parents[3]
def quote(text):
    delimiter='===='
    return '['+delimiter+'['+text+']'+delimiter+']'
source=(ROOT/'src/client/UI/InventoryView.luau').read_text(encoding='utf-8-sig')
equipment=(ROOT/'src/shared/Data/Equipment.luau').read_text(encoding='utf-8-sig')
code='local equipment=assert(loadstring('+quote(equipment)+'))()\n'
code+='local source='+quote(source)+'\n'
code+=r'''
local passed=0
local function test(name,run)run();passed+=1;print("PASS "..name)end
local function fixture()
 local data={character={classId="Warrior",equipmentSlots={weapon="one"},stats={Health=63,Attack=19,Defense=4}},adventurers={rowan={name="Rowan",classId="Warrior",rank="F",equipmentSlots={weapon="two"}}},
 inventory={equipment={one={definitionId="sword"},two={definitionId="sword"},three={definitionId="sword"},bow={definitionId="bow"}},stacks={timber=7}},quests={firstClears={},active=nil},gold=15,hallLevel=1}
 local catalog={EquipmentLimit=50,Character={Classes={Warrior={Weapon="sword"}}},ItemOrder={"sword","bow","timber"},Items={
 sword={Name="Sword",Description="A sword",Kind="Weapon",Slot="weapon",Class="Warrior",Health=0,Attack=5,Defense=0,Price=10,HallLevel=1},
 bow={Name="Bow",Description="A bow",Kind="Weapon",Slot="weapon",Class="Archer",Price=20,Attack=3},
 timber={Name="Timber",Description="Hall material",Kind="Material",Tradable=true}}}
 local result,draw,busy,focus=nil,nil,false,nil
 local actions={};local renders=0
 local env=setmetatable({game={ReplicatedStorage={Shared={Data={Equipment="gear"}}}},script={Parent={Components={InventoryPane="pane"}}}},{__index=getfenv()})
 env.require=function(id)if id=="gear"then return equipment else return function(_,model)result=model end end end
 local fn=assert(loadstring(source));setfenv(fn,env)
 local function T(key,values)
  assert(type(key)=="string","translation key")
  if values then for k,v in pairs(values)do key=key:gsub("{"..k.."}",tostring(v))end end
  return key
 end
 draw=fn()({scroll={},T=T,focusActor=function()local v=focus;focus=nil;return v end,
 render=function()renders+=1;draw(data,catalog,busy)end,act=function(name,payload)table.insert(actions,{name=name,payload=payload})end})
 local f={data=data,catalog=catalog,actions=actions}
 function f.draw(value)busy=value==true;draw(data,catalog,busy);return result end
 function f.model()return result end
 function f.focus(id)focus=id;return f.draw()end
 function f.select(id)for _,item in ipairs(result.items)do if item.id==id then item.onSelect();return end end;error("missing item "..id)end
 function f.act(prefix)for _,a in ipairs(result.selected.actions)do if a.name:sub(1,#prefix)==prefix then if a.enabled then a.callback()end;return a end end;error("missing action "..prefix)end
 function f.filter(id)for _,filter in ipairs(result.filters)do if filter.id==id then filter.onSelect();return end end end
 f.draw();return f
end
test("first selection uses owned equipment before materials and preserves three real slots",function()
 local f=fixture();local m=f.model();assert(m.items[1].kind=="Weapon" and #m.slots==3 and m.stats=="HP 63 / Attack 19 / Defense 4")
 assert(#m.items==4 and m.items[#m.items].quantity==7)
end)
test("actor selection and external focus retain authoritative identity",function()
 local f=fixture();f.model().actors[2].onSelect();assert(f.model().actorId=="rowan")
 f.select("three");f.act("Assign_");assert(f.actions[1].name=="AssignEquipment" and f.actions[1].payload.actorId=="rowan" and f.actions[1].payload.instanceId=="three")
 f.focus("player");assert(f.model().actorId=="player" and #f.model().items==3)
end)
test("unequip keeps canonical payload",function()
 local f=fixture();f.model().slots[1].onUnequip();assert(f.actions[1].name=="UnequipEquipment" and f.actions[1].payload.slot=="weapon")
end)
test("sale requires two actions and changing selection cancels confirmation",function()
 local f=fixture();f.select("three");f.act("Sell_");assert(#f.actions==0)
 assert(f.model().selected.actions[2].label=="Confirm sale · 5 Gold")
 f.select("one");f.select("three");f.act("Sell_");assert(#f.actions==0);f.act("Sell_")
 assert(#f.actions==1 and f.actions[1].name=="SellEquipment" and f.actions[1].payload.instanceId=="three")
end)
test("assigned items cannot be sold or redundantly assigned",function()
 local f=fixture();f.select("one");assert(#f.model().selected.actions==1 and not f.model().selected.actions[1].enabled)
 f.select("two");assert(f.model().selected.actions[1].enabled and #f.model().selected.actions==1)
end)
test("busy blocks toolbar and all mutation callbacks",function()
 local f=fixture();f.select("three");f.draw(true);local m=f.model()
 m.onShop();m.onSort();m.onCompatible();m.actors[2].onSelect();m.slots[1].onUnequip()
 for _,a in ipairs(m.selected.actions)do assert(not a.enabled);a.callback()end
 assert(#f.actions==0 and f.model().actorId=="player" and f.model().shopLabel=="Shop")
end)
test("shop preserves money Hall and capacity gates",function()
 local f=fixture();f.model().onShop();assert(f.model().selected.actions[1].enabled)
 f.act("Buy_");assert(f.actions[1].name=="BuyEquipment" and f.actions[1].payload.definitionId=="sword")
 f.data.gold=0;f.draw();assert(not f.model().selected.actions[1].enabled)
 f.data.gold=100;f.catalog.Items.sword.HallLevel=2;f.draw();assert(not f.model().selected.actions[1].enabled)
 f.catalog.Items.sword.HallLevel=1;f.catalog.EquipmentLimit=4;f.draw();assert(not f.model().selected.actions[1].enabled)
end)
test("materials retain actual counts and no equipment actions",function()
 local f=fixture();f.filter("Material");assert(#f.model().items==1 and f.model().items[1].quantity==7)
 assert(f.model().selected.stats=="Quantity: 7" and #f.model().selected.actions==0 and f.model().selected.binding=="Market eligible material")
end)
test("compatibility toggle exposes disabled incompatible item",function()
 local f=fixture();f.model().onCompatible();f.select("bow");assert(not f.model().selected.actions[1].enabled)
 assert(f.model().selected.comparison==nil)
end)
test("removed selection resolves without stale sale intent and details back preserves selection",function()
 local f=fixture();f.select("three");f.act("Sell_");f.data.inventory.equipment.three=nil;f.draw()
 assert(f.model().selected.name=="Sword");f.model().onBack();assert(f.model().view=="Items")
end)
test("sorting and actor removal remain usable",function()
 local f=fixture();f.model().onSort();assert(f.model().sortLabel=="Sort: Attack")
 f.model().actors[2].onSelect();f.data.adventurers.rowan=nil;f.draw();assert(f.model().actorId=="player")
end)
test("duplicate hero names carry stable identity in selector and assignment",function()
 local f=fixture();f.data.adventurers.rowan2={name="Rowan",classId="Warrior",rank="F",equipmentSlots={}}
 f.draw();assert(f.model().actors[2].name~=f.model().actors[3].name)
 assert(f.model().actors[2].name:find("rowan",1,true) and f.model().actors[3].name:find("rowan2",1,true))
end)
print("SUMMARY "..passed.." actual InventoryView behavior cases passed")
'''
with tempfile.TemporaryDirectory(prefix='guildborne-inventory-') as folder:
    entry=Path(folder)/'probe.luau';entry.write_text(code,encoding='utf-8')
    raise SystemExit(subprocess.run([str(ROOT/'.tools/luau/luau.exe'),str(entry)],cwd=ROOT).returncode)
