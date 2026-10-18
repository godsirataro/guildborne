--!strict
-- Pure snapshot projection into the native pane. All changes use existing intents.
local MakeGear=require(game.ReplicatedStorage.Shared.Data.Equipment)
local Pane=require(script.Parent.Components.InventoryPane)
return function(ui:any)
 local actorId="player";local filter="All";local sortBy="Name";local compatibleOnly=true;local shop=false
 local confirmSale:string?=nil;local selected:string?=nil;local view="Items"
 return function(data:any,catalog:any,busy:boolean)
  local gear=MakeGear(catalog);local T=ui.T
  local actors={};if data.character.classId then table.insert(actors,"player")end
  local ids={};for id in pairs(data.adventurers)do table.insert(ids,id)end;table.sort(ids)
  for _,id in ipairs(ids)do table.insert(actors,id)end
  if not table.find(actors,actorId)then actorId=actors[1]or"player";confirmSale=nil end
  local focus=ui.focusActor and ui.focusActor()
  if focus and table.find(actors,focus)then actorId=focus;shop=false;filter="Weapon";compatibleOnly=true;confirmSale=nil;selected=nil;view="Items"end
  local actor=gear.actor(data,actorId)
  local function actorName(id:string):string
   local a=gear.actor(data,id)
   if id=="player"then return T("Your character")end
   local label=T(a.name).." · "..T(a.classId).." ["..a.rank.."]"
   for otherId,other in pairs(data.adventurers)do
    if otherId~=id and other.name==a.name and other.classId==a.classId and other.rank==a.rank then return label.." · "..id end
   end
   return label
  end
  local function redraw(reset:boolean?)ui.render(reset)end
  local function action(name:string,payload:any)if busy then return end;confirmSale=nil;ui.act(name,payload)end
  local count=0;for _ in pairs(data.inventory.equipment)do count+=1 end
  local s=actor and actor.stats;local hint=gear.weaponHint(data,actor)
  local model:any={T=T,data=data,actorId=actorId,busy=busy,view=view,title=T("Shared inventory"),
   capacity=T("Equipment: {count}/{limit}",{count=count,limit=catalog.EquipmentLimit}),
   actorName=if actor and actor.classId then actorName(actorId)else T("Select a class in Guild"),
   stats=if s then T("HP {hp} / Attack {attack} / Defense {defense}",{hp=s.Health,attack=s.Attack,defense=s.Defense})else "",
   weaponHint=if hint then T(hint)else nil,expeditionHint=if data.quests.active then T("Current expedition keeps its starting equipment stats.")else nil,
   shopLabel=T(if shop then "Owned"else"Shop"),sortLabel=T("Sort: {kind}",{kind=T(sortBy)}),
   compatibleLabel=T(if compatibleOnly then "Compatible"else"All classes"),actors={},slots={},filters={},items={}}
  model.onShop=function()if busy then return end;shop=not shop;confirmSale=nil;selected=nil;view="Items";redraw(true)end
  model.onSort=function()if busy then return end;local options={"Name","Attack","Defense","Health"};sortBy=options[(table.find(options,sortBy)or 1)%#options+1];confirmSale=nil;redraw(true)end
  model.onCompatible=function()if busy then return end;compatibleOnly=not compatibleOnly;confirmSale=nil;redraw(true)end
  model.onView=function(nextView:string)if nextView~="Items"and nextView~="Loadout"and nextView~="Details"then return end;view=nextView;redraw(true)end
  model.onBack=function()view="Items";confirmSale=nil;redraw(true)end
  for _,id in ipairs(actors)do
   table.insert(model.actors,{id=id,name=actorName(id),selected=id==actorId,onSelect=function()if busy then return end;actorId=id;confirmSale=nil;view="Items";redraw(true)end})
  end
  if actor and actor.classId then for _,slot in ipairs(gear.Slots)do
   local id=actor.equipmentSlots and actor.equipmentSlots[slot];local owned=id and data.inventory.equipment[id];local def=owned and catalog.Items[owned.definitionId]
   table.insert(model.slots,{slot=slot,label=T(slot),itemName=if def then T(def.Name)elseif actorId=="player"and slot=="weapon"then T("Class training kit")else T("Empty"),definitionId=owned and owned.definitionId,
    enabled=not busy,onUnequip=if id then function()action("UnequipEquipment",{actorId=actorId,slot=slot})end else nil})
  end end
  for _,kind in ipairs({"All","Weapon","Armor","Accessory","Material"})do
   table.insert(model.filters,{id=kind,label=T(kind),selected=kind==filter,onSelect=function()if busy then return end;filter=kind;selected=nil;confirmSale=nil;view="Items";redraw(true)end})
  end
  local entries:any={}
  if shop then
   for _,id in ipairs(catalog.ItemOrder)do if catalog.Items[id].Price then table.insert(entries,{id="shop:"..id,definitionId=id,instanceId=id})end end
  else
   for id,owned in pairs(data.inventory.equipment)do table.insert(entries,{id=id,definitionId=owned.definitionId,instanceId=id})end
   if filter=="All"or filter=="Material"then for _,id in ipairs(catalog.ItemOrder)do if catalog.Items[id].Kind=="Material"then
    table.insert(entries,{id="material:"..id,definitionId=id,material=true,quantity=data.inventory.stacks[id]or 0})
   end end end
  end
  table.sort(entries,function(a:any,b:any):boolean
   if (a.material==true)~=(b.material==true)then return a.material~=true end
   local ad,bd=catalog.Items[a.definitionId],catalog.Items[b.definitionId]
   if sortBy~="Name"and(ad[sortBy]or 0)~=(bd[sortBy]or 0)then return(ad[sortBy]or 0)>(bd[sortBy]or 0)end
   local an,bn=T(ad.Name),T(bd.Name);return if an==bn then a.id<b.id else an<bn
  end)
  local visible:any={}
  for _,entry in ipairs(entries)do local def=catalog.Items[entry.definitionId]
   if (filter=="All"or filter==def.Kind)and(entry.material or not compatibleOnly or not actor or not actor.classId or gear.compatible(def,actor.classId))then table.insert(visible,entry)end
  end
  local choice:any=nil;for _,entry in ipairs(visible)do if entry.id==selected then choice=entry;break end end
  if not choice then choice=visible[1];selected=choice and choice.id;confirmSale=nil end
  for _,entry in ipairs(visible)do local def=catalog.Items[entry.definitionId]
   table.insert(model.items,{id=entry.id,name=T(def.Name),definitionId=entry.definitionId,quantity=entry.quantity,selected=entry.id==selected,kind=def.Kind,onSelect=function()if busy then return end;selected=entry.id;confirmSale=nil;view="Details";redraw(true)end})
  end
  model.emptyText=T(if not shop and count==0 and filter~="Material"then "Your inventory is empty."else "No matching items.")
  if choice then
   local entry=choice;local def=catalog.Items[entry.definitionId];local id=entry.instanceId
   local detail:any={name=T(def.Name),definitionId=entry.definitionId,description=T(def.Description),binding=T(if entry.material and def.Tradable then "Market eligible material"else "Account bound"),actions={}}
   if entry.material then detail.stats=T("Quantity: {count}",{count=entry.quantity})
   else
    detail.stats=T("HP {hp} / Attack {attack} / Defense {defense}",{hp=def.Health or 0,attack=def.Attack or 0,defense=def.Defense or 0})
    local compatible=actor and gear.compatible(def,actor.classId)
    if compatible then local loadout=gear.loadout(data,actor);local previous=catalog.Items[loadout[def.Slot]]or{}
     detail.comparison=T("Change: HP {hp} / Attack {attack} / Defense {defense}",{hp=(def.Health or 0)-(previous.Health or 0),attack=(def.Attack or 0)-(previous.Attack or 0),defense=(def.Defense or 0)-(previous.Defense or 0)})
    end
    if shop then
     table.insert(detail.actions,{name="Buy_"..id,label=if data.hallLevel<(def.HallLevel or 1)then T("Requires Hall Lv{level}",{level=def.HallLevel})else T("Buy · {amount} Gold",{amount=def.Price}),enabled=not busy and data.hallLevel>=(def.HallLevel or 1)and data.gold>=def.Price and count<catalog.EquipmentLimit,callback=function()action("BuyEquipment",{definitionId=id})end})
    else
     local owner=gear.owner(data,id)
     detail.assignment=T("Assigned: {actor}",{actor=if owner then actorName(owner)else T("Unassigned")})
     table.insert(detail.actions,{name="Assign_"..id,label=if not compatible then T("IncompatibleEquipment")elseif owner==actorId then T("AlreadyEquipped")elseif owner then T("Move to {actor}",{actor=actorName(actorId)})else T("Equip on {actor}",{actor=actorName(actorId)}),enabled=compatible and owner~=actorId and not busy,callback=function()action("AssignEquipment",{actorId=actorId,instanceId=id})end})
     if not owner then table.insert(detail.actions,{name="Sell_"..id,label=T(if confirmSale==id then "Confirm sale · {amount} Gold"else "Sell · {amount} Gold",{amount=math.floor(def.Price/2)}),enabled=not busy,callback=function()if busy then return end;if confirmSale==id then action("SellEquipment",{instanceId=id})else confirmSale=id;redraw()end end})end
    end
   end
   model.selected=detail
  end
  Pane(ui.scroll,model)
 end
end
