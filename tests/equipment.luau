--!strict
return function(test: any,eq: any,harness: any,util: any,content: any,schema: any,gear: any,progression: any)
	local function setup(): any
		local h=harness(); h.setup(); h.quest("trail_watch"); h.quest("timber_escort"); h.quest("quarry_patrol")
		eq(h.send("SelectPlayerClass",{classId="Warrior"}),"OK")
		return h
	end
	local function buy(h: any,id: string): string
		local seq=h.data().inventory.nextEquipmentSequence
		eq(h.send("BuyEquipment",{definitionId=id}),"OK")
		return "shop:"..seq..":1"
	end
	test("v2 migration preserves selected class all ownership and active expedition",function()
		local h=setup(); h.send("StartQuest",{questId="trail_watch"})
		local old=util.copy(h.service.Sessions[1].record); old.data.settlement=nil;for _,hero in pairs(old.data.adventurers) do hero.rank=nil end;old.data.guildLand=nil;old.data.market=nil;old.schemaVersion=2; old.data.expansion=nil
		old.data.character.equipmentSlots=nil; old.data.inventory.nextEquipmentSequence=nil
		local saved=util.copy(old); local migrated,code=schema.migrate(old)
		eq(code,"OK"); eq(old,saved); eq(migrated.schemaVersion,schema.Version); eq(schema.validate(migrated,1),true)
		migrated.data.guildLand=nil;migrated.data.market=nil;migrated.data.settlement=nil;for _,hero in pairs(migrated.data.adventurers) do hero.rank=nil end;migrated.data.expansion=nil; migrated.data.character.equipmentSlots=nil; migrated.data.inventory.nextEquipmentSequence=nil
		eq(migrated.data,old.data)
	end)
	test("unexpected legacy equipment cannot be silently overwritten",function()
		local h=setup(); h.service.Close(1);local old=h.records["p:1"]; old.data.settlement=nil;for _,hero in pairs(old.data.adventurers) do hero.rank=nil end;old.data.guildLand=nil;old.data.market=nil;old.schemaVersion=2; old.data.expansion=nil
		old.data.inventory.nextEquipmentSequence=nil;local before=util.copy(old)
		h.service=h.make();assert(h.service.Load(1,"bad-v2")~="OK");eq(h.records["p:1"],before)
	end)
	test("three slots contribute identical projected and combat stats",function()
		local h=setup();local armor=buy(h,"guardian_plate");local accessory=buy(h,"bronze_ring")
		for _,id in ipairs({"q:3:1",armor,accessory}) do eq(h.send("AssignEquipment",{actorId="player",instanceId=id}),"OK") end
		local s=progression.stats(h.data(),h.data().character);eq(s.Health,36);eq(s.Attack,11);eq(s.Defense,8)
		local stats=require("../src/server/Systems/CombatStats")(content,require("../src/server/Config/Combat"),gear)
		local combat=stats.hero("Warrior",1,"iron_sword","guardian_plate","bronze_ring")
		eq(combat.MaxHealth,s.Health);eq(combat.Attack,s.Attack);eq(combat.Defense,s.Defense)
		eq(schema.validate(h.service.Sessions[1].record,1),true)
	end)
	test("player kit is a fallback and never becomes a sellable inventory instance",function()
		local h=setup();local initial=util.count(h.data().inventory.equipment)
		eq(gear.loadout(h.data(),h.data().character).weapon,"training_sword")
		h.send("AssignEquipment",{actorId="player",instanceId="q:3:1"});eq(h.send("UnequipEquipment",{actorId="player",slot="weapon"}),"OK")
		eq(gear.loadout(h.data(),h.data().character).weapon,"training_sword");eq(util.count(h.data().inventory.equipment),initial)
		eq(h.send("SellEquipment",{instanceId="training_sword"}),"ItemNotOwned")
	end)
	test("transfer removes old assignment replaces destination and retains every item",function()
		local h=setup();local before=util.copy(h.data().inventory.equipment)
		h.send("AssignEquipment",{actorId="player",instanceId="q:1:1"});h.send("AssignEquipment",{actorId="a:Warrior",instanceId="q:3:1"})
		local command=h.command("AssignEquipment",{actorId="player",instanceId="q:3:1"})
		eq(h.service.Execute(1,command),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
		eq(h.data().adventurers["a:Warrior"].equipmentSlots.weapon,nil);eq(h.data().character.equipmentSlots.weapon,"q:3:1")
		eq(gear.owner(h.data(),"q:1:1"),nil);eq(h.data().inventory.equipment,before)
	end)
	test("unowned actor item incompatible class and invalid slot leave data unchanged",function()
		local h=setup();local robes=buy(h,"woven_robes");local before=util.copy(h.data())
		for _,args in ipairs({{actorId="player",instanceId="missing"},{actorId="a:Other",instanceId=robes},{actorId="player",instanceId=robes}}) do
			assert(h.send("AssignEquipment",args)~="OK");eq(h.data(),before)
		end
		eq(h.send("UnequipEquipment",{actorId="player",slot="gold"}),"InvalidSlot");eq(h.data(),before)
	end)
	test("all classes have compatible armor and accessory choices",function()
		for _,class in ipairs(content.AdventurerOrder) do
			assert(gear.compatible(content.Items.leather_vest,class));assert(gear.compatible(content.Items.bronze_ring,class))
		end
		eq(gear.compatible(content.Items.guardian_plate,"Mage"),false);eq(gear.compatible(content.Items.woven_robes,"Warrior"),false)
	end)
	test("schema rejects duplicate cross-actor ownership and wrong slot",function()
		local h=setup();h.send("AssignEquipment",{actorId="player",instanceId="q:3:1"})
		local r=util.copy(h.service.Sessions[1].record);r.data.adventurers["a:Warrior"].equipmentSlots.weapon="q:3:1";eq(schema.validate(r,1),false)
		r=util.copy(h.service.Sessions[1].record);r.data.character.equipmentSlots.armor="q:3:1";eq(schema.validate(r,1),false)
	end)
	test("full inventory purchase fails atomically without spending or sequence advance",function()
		local h=setup();local inventory=h.service.Sessions[1].record.data.inventory
		for i=util.count(inventory.equipment)+1,content.Limits.Equipment do inventory.equipment["fill:"..i]={definitionId="training_sword",upgradeLevel=0,binding="Account"} end
		local before=util.copy(h.data());eq(h.send("BuyEquipment",{definitionId="leather_vest"}),"InventoryFull");eq(h.data(),before)
	end)
	test("purchase price authority no-negative Gold and duplicate purchase receipt",function()
		local h=harness();h.setup();local before=util.copy(h.data())
		eq(h.send("BuyEquipment",{definitionId="leather_vest"}),"InsufficientGold");eq(h.data(),before)
		eq(h.send("BuyEquipment",{definitionId="leather_vest",price=0}),"InvalidRequest")
		h.quest("trail_watch");local c=h.command("BuyEquipment",{definitionId="leather_vest"})
		eq(h.service.Execute(1,c),"OK");eq(h.service.Execute(1,c),"AlreadyCommitted");eq(h.data().currencies.gold,12);eq(h.data().inventory.nextEquipmentSequence,2)
	end)
	test("sale requires unequip and cannot duplicate Gold after retries",function()
		local h=setup();local id=buy(h,"bronze_ring");h.send("AssignEquipment",{actorId="player",instanceId=id})
		eq(h.send("SellEquipment",{instanceId=id}),"UnequipBeforeSelling")
		h.send("UnequipEquipment",{actorId="player",slot="accessory"});local before=h.data().currencies.gold
		local c=h.command("SellEquipment",{instanceId=id});eq(h.service.Execute(1,c),"OK");eq(h.service.Execute(1,c),"AlreadyCommitted")
		eq(h.data().currencies.gold,before+7);eq(h.data().inventory.equipment[id],nil);eq(h.send("SellEquipment",{instanceId=id}),"ItemNotOwned")
	end)
	test("expedition snapshot remains immutable through away-hero equipment transfer",function()
		local h=setup();h.send("AssignEquipment",{actorId="a:Warrior",instanceId="q:3:1"});h.send("StartQuest",{questId="trail_watch"})
		local snapshot=util.copy(h.data().quests.active)
		eq(h.send("AssignEquipment",{actorId="player",instanceId="q:3:1"}),"OK");eq(h.data().quests.active,snapshot)
	end)
	test("transfer uncertain save never exposes partial assignment and exact rejoin persists",function()
		for _,mode in ipairs({"before","after"}) do
			local h=setup();h.send("AssignEquipment",{actorId="a:Warrior",instanceId="q:3:1"});local before=util.copy(h.data())
			h.mode=mode;local c=h.command("AssignEquipment",{actorId="player",instanceId="q:3:1"})
			eq(h.service.Execute(1,c),"SavePending");eq(h.data(),before);h.mode="ok";eq(h.service.Refresh(1),"OK")
			eq(gear.owner(h.data(),"q:3:1"),"player");eq(h.service.Execute(1,c),"AlreadyCommitted")
			local committed=util.copy(h.data());h.service.Close(1);h.service=h.make();eq(h.service.Load(1,"gear-rejoin"),"OK");eq(h.data(),committed)
		end
	end)
	test("uncertain purchase and sale preserve exact Gold and instance conservation",function()
		local h=setup();local before=h.data().currencies.gold;h.mode="after"
		local c=h.command("BuyEquipment",{definitionId="leather_vest"});eq(h.service.Execute(1,c),"SavePending")
		h.mode="ok";h.service.Refresh(1);eq(h.data().currencies.gold,before-18);eq(h.service.Execute(1,c),"AlreadyCommitted")
		h.mode="after";local sale=h.command("SellEquipment",{instanceId="shop:1:1"});eq(h.service.Execute(1,sale),"SavePending")
		h.mode="ok";h.service.Refresh(1);eq(h.data().currencies.gold,before-9);eq(h.data().inventory.equipment["shop:1:1"],nil)
	end)
end
