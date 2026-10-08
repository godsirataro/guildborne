--!strict

local MakeGear=require(game.ReplicatedStorage.Shared.Data.Equipment)

local AssetImage=require(script.Parent.AssetImage)

return function(ui: any)

	local actorId="player"; local filter="All"; local sortBy="Name"; local compatibleOnly=true; local shop=false; local confirmSale: string?=nil

	return function(data: any,catalog: any,busy: boolean)

		local gear=MakeGear(catalog)

		local T,card,text,button=ui.T,ui.card,ui.text,ui.button

		local actors={}

		if data.character.classId then table.insert(actors,"player") end

		local ids={};for id in pairs(data.adventurers) do table.insert(ids,id) end;table.sort(ids);for _,id in ipairs(ids) do table.insert(actors,id) end

		if not table.find(actors,actorId) then actorId=actors[1] or "player" end
		local focus=ui.focusActor and ui.focusActor()
		if focus and table.find(actors,focus) then actorId=focus;shop=false;filter="Weapon";compatibleOnly=true;confirmSale=nil end

		local actor=gear.actor(data,actorId)

		local function actorName(id: string): string

			local a=gear.actor(data,id)

			return if id=="player" then T("Your character") else T(a.name).." · "..T(a.classId).." ["..a.rank.."] · "..id

		end

		local count=0; for _ in pairs(data.inventory.equipment) do count+=1 end

		local top=card(ui.scroll,"Shared inventory")

		text(top,T("Equipment: {count}/{limit}",{count=count,limit=catalog.EquipmentLimit}),16)
		local weaponHint=gear.weaponHint(data,actor)
		if weaponHint then text(top,weaponHint,16) end

		button(top,T("Viewing: {actor}",{actor=if actor and actor.classId then actorName(actorId) else T("Select a class in Guild")}),#actors>1 and not busy,function()

			actorId=actors[(table.find(actors,actorId) or 0)%#actors+1];confirmSale=nil;ui.render(true)

		end).Name="InventoryActor"

		button(top,if shop then "Show owned equipment" else "Open equipment shop",not busy,function()shop=not shop;confirmSale=nil;ui.render(true)end).Name="InventoryShop"

		button(top,T("Filter: {kind}",{kind=T(filter)}),not busy,function()

			local options={"All","Weapon","Armor","Accessory","Material"};filter=options[(table.find(options,filter) or 1)%#options+1];ui.render(true)

		end).Name="InventoryFilter"

		button(top,T("Sort: {kind}",{kind=T(sortBy)}),not busy,function()

			local options={"Name","Attack","Defense","Health"};sortBy=options[(table.find(options,sortBy) or 1)%#options+1];confirmSale=nil;ui.render(true)

		end).Name="InventorySort"

		button(top,if compatibleOnly then "Compatible items only" else "Show all classes",not busy,function()compatibleOnly=not compatibleOnly;ui.render(true)end)

		if actor and actor.classId then

			local frame=card(ui.scroll,T("Loadout: {actor}",{actor=actorName(actorId)}))

			local s=actor.stats

			if s then text(frame,T("HP {hp} / Attack {attack} / Defense {defense}",{hp=s.Health,attack=s.Attack,defense=s.Defense}),16) end

			for _,slot in ipairs(gear.Slots) do

				local id=actor.equipmentSlots[slot]; local owned=id and data.inventory.equipment[id]

				local fallback=actorId=="player" and slot=="weapon"

				text(frame,T(slot)..": "..(if owned then T(catalog.Items[owned.definitionId].Name) elseif fallback then T("Class training kit") else T("Empty")),16)

				if id then button(frame,T("Unequip {slot}",{slot=T(slot)}),not busy,function()ui.act("UnequipEquipment",{actorId=actorId,slot=slot})end).Name="Unequip_"..slot end

			end

			if data.quests.active then text(frame,"Current expedition keeps its starting equipment stats.",14) end

		end

		local function visible(def: any): boolean

			return (filter=="All" or filter==def.Kind) and (not compatibleOnly or not actor or not actor.classId or gear.compatible(def,actor.classId))

		end

		if not shop and (filter=="All" or filter=="Material") then

			local materials=card(ui.scroll,"Hall materials")

			for _,id in ipairs(catalog.ItemOrder) do local def=catalog.Items[id];if def.Kind=="Material" then
				local row=Instance.new("Frame");row.Name="Material_"..id;row.Size=UDim2.new(1,0,0,64);row.BackgroundTransparency=1;row.Parent=materials
				local icon=AssetImage.item(row,id);if icon then icon.Size=UDim2.fromOffset(60,60);for _,child in ipairs(icon:GetChildren()) do if child:IsA("GuiObject") then child.Size=UDim2.fromScale(1,1) end end end
				local label=Instance.new("TextLabel");label.Size=UDim2.new(1,-72,1,0);label.Position=UDim2.fromOffset(72,0);label.BackgroundTransparency=1
				label.Text=T(def.Name)..": "..tostring(data.inventory.stacks[id] or 0).."\n"..T(if def.Tradable then "Market eligible material" else "Account bound")
				label.TextSize=16;label.TextColor3=Color3.fromRGB(234,226,206);label.Font=Enum.Font.Gotham;label.TextWrapped=true;label.TextXAlignment=Enum.TextXAlignment.Left;label.Parent=row
			end end

		end

		local itemIds={}

		if shop then for _,id in ipairs(catalog.ItemOrder) do if catalog.Items[id].Price then table.insert(itemIds,id) end end

		else for id in pairs(data.inventory.equipment) do table.insert(itemIds,id) end end

		local function definition(id: string): any return catalog.Items[if shop then id else data.inventory.equipment[id].definitionId] end

		table.sort(itemIds,function(a: string,b: string): boolean

			local ad,bd=definition(a),definition(b)

			if sortBy~="Name" and (ad[sortBy] or 0)~=(bd[sortBy] or 0) then return (ad[sortBy] or 0)>(bd[sortBy] or 0) end

			local an,bn=T(ad.Name),T(bd.Name)

			return if an==bn then a<b else an<bn

		end)

		local shown=0

		for _,id in ipairs(itemIds) do

			local definitionId=if shop then id else data.inventory.equipment[id].definitionId

			local def=catalog.Items[definitionId]

			if not visible(def) then continue end

			shown+=1

			local frame=card(ui.scroll,def.Name);frame.Name="Item_"..id

			AssetImage.item(frame,definitionId)

			text(frame,def.Description,16)

			text(frame,"Account bound",14)

			text(frame,T("HP {hp} / Attack {attack} / Defense {defense}",{hp=def.Health or 0,attack=def.Attack or 0,defense=def.Defense or 0}),14)

			local compatible=actor and gear.compatible(def,actor.classId)

			if compatible then

				local loadout=gear.loadout(data,actor);local previous=catalog.Items[loadout[def.Slot]] or {}

				text(frame,T("Change: HP {hp} / Attack {attack} / Defense {defense}",{hp=(def.Health or 0)-(previous.Health or 0),attack=(def.Attack or 0)-(previous.Attack or 0),defense=(def.Defense or 0)-(previous.Defense or 0)}),14)

			end

			if shop then

				button(frame,if data.hallLevel<(def.HallLevel or 1) then T("Requires Hall Lv{level}",{level=def.HallLevel}) else T("Buy · {amount} Gold",{amount=def.Price}),not busy and data.hallLevel>=(def.HallLevel or 1) and data.gold>=def.Price and count<catalog.EquipmentLimit,function()ui.act("BuyEquipment",{definitionId=id})end).Name="Buy_"..id

			else

				local owner=gear.owner(data,id)

				text(frame,T("Assigned: {actor}",{actor=if owner then actorName(owner) else T("Unassigned")}),14)

				button(frame,if not compatible then "IncompatibleEquipment" elseif owner==actorId then "AlreadyEquipped" elseif owner then T("Move to {actor}",{actor=actorName(actorId)}) else T("Equip on {actor}",{actor=actorName(actorId)}),compatible and owner~=actorId and not busy,function()ui.act("AssignEquipment",{actorId=actorId,instanceId=id})end).Name="Assign_"..id

				if not owner then

					button(frame,T(if confirmSale==id then "Confirm sale · {amount} Gold" else "Sell · {amount} Gold",{amount=math.floor(def.Price/2)}),not busy,function()

						if confirmSale==id then confirmSale=nil;ui.act("SellEquipment",{instanceId=id}) else confirmSale=id;ui.render() end

					end).Name="Sell_"..id

				end

			end

		end

		if shown==0 and filter~="Material" then require(script.Parent.EmptyState)(ui.scroll,if not shop and count==0 then "empty_inventory" else "no_search_results",T) end

	end

end

