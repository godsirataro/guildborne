--!strict
return function(test: any,eq: any,harness: any,util: any,content: any,schema: any,rules: any,gear: any,progression: any,combat: any)
 test("shared XP projection banks excess XP and respects the supplied content rules",function()
  for _,case in ipairs({{0,5,1},{49,5,1},{50,5,2},{199,5,4},{200,5,5},{500,5,5},{500,10,10},{1000000,100,100}}) do
   eq(content:LevelFromXP(case[1],case[2]),case[3])
  end
  eq(content.HallLevelCap(1),5);eq(content.HallLevelCap(2),10);eq(content.HallLevelCap(20),100)
  local alternative=util.copy(content);alternative.Progression.XPPerLevel=100
  eq(alternative:LevelFromXP(99,10),1);eq(alternative:LevelFromXP(100,10),2)
  eq(content.Progression.XPPerLevel,50);eq(content:LevelFromXP(100,10),3)
 end)
 test("advancement readiness preserves every path gate without mutation",function()
  local count=0
  for id,path in pairs(rules.Paths) do
   count+=1
   local data:any={quests={firstClears={quarry_patrol=true}},expansion={tower={highest=path.Floor},buildings={q={kind="quarters"}},gathered={wood=true,stone=true,ore=true,herbs=true}}}
   local actor={classId=path.Class,level=path.Level};local build={tier=path.Tier-1,path=path.Parent,skills={}}
   local before=util.copy(data);eq(rules.advanceProblem(data,actor,build,id),nil);eq(data,before)
   actor.level=path.Level-1;eq(rules.advanceProblem(data,actor,build,id),"AdvancementLocked");actor.level=path.Level
   data.quests.firstClears.quarry_patrol=nil;eq(rules.advanceProblem(data,actor,build,id),"AdvancementLocked");data.quests.firstClears.quarry_patrol=true
   if path.Floor>0 then data.expansion.tower.highest=path.Floor-1;eq(rules.advanceProblem(data,actor,build,id),"AdvancementLocked");data.expansion.tower.highest=path.Floor end
   if path.Prestige then data.expansion.buildings={};eq(rules.advanceProblem(data,actor,build,id),"QuartersRequired");data.expansion.buildings={q={kind="quarters"}} end
   if path.Secret then data.expansion.gathered.ore=nil;eq(rules.advanceProblem(data,actor,build,id),"SecretUndiscovered");data.expansion.gathered.ore=true end
   if path.Parent then build.path="other_path";eq(rules.advanceProblem(data,actor,build,id),"InvalidClassPath");build.path=path.Parent end
   actor.classId="wrong_class";eq(rules.advanceProblem(data,actor,build,id),"InvalidClassPath");actor.classId=path.Class
   build.tier=path.Tier;eq(rules.advanceProblem(data,actor,build,id),"InvalidClassPath")
  end
  eq(count,24)
 end)
 test("skill preview agrees with authoritative prerequisite and point gates",function()
  local b={tier=1,skills={}}
  eq(rules.learnProblem(b,1,"unknown"),"InvalidSkill")
  eq(rules.learnProblem(b,1,"vitality"),"NoSkillPoints")
  eq(rules.learnProblem(b,10,"focus"),"SkillPrerequisite")
  eq(rules.learnProblem(b,2,"vitality"),nil)
  b.skills.vitality=true
  eq(rules.learnProblem(b,2,"vitality"),"AlreadyLearned")
  eq(rules.learnProblem(b,2,"focus"),"NoSkillPoints")
  eq(rules.learnProblem(b,30,"path_art"),"SkillPrerequisite")
  b.tier=2
  eq(rules.learnProblem(b,3,"path_art"),"NoSkillPoints")
  eq(rules.learnProblem(b,4,"path_art"),nil)
 end)
 test("skill preview preserves branch conflict order and never spends",function()
  local b={tier=3,skills={vitality=true,focus=true,path_art=true}}
  local before=util.copy(b)
  eq(rules.learnProblem(b,10,"ward"),"SkillBranchConflict")
  eq(rules.learnProblem(b,5,"ward"),"NoSkillPoints")
  eq(rules.learnProblem(b,6,"master_art"),"NoSkillPoints")
  eq(rules.learnProblem(b,7,"master_art"),nil)
  eq(b,before)
 end)
 test("three skill slots follow server unlocks including prestige holes",function()
  for _,class in ipairs(content.AdventurerOrder) do
   local starter=combat.Classes[class].Ability
   local locked=rules.skillSlots({tier=1,skills={}},starter)
   eq(locked[1],starter);eq(locked[2],nil);eq(locked[3],nil)
   for pathId,path in pairs(rules.Paths) do if path.Class==class then
    local build={tier=path.Tier,path=pathId,skills={vitality=true,path_art=true,master_art=path.Tier==3}}
    local slots=rules.skillSlots(build,starter)
    eq(slots[1],starter)
    if path.Tier==2 then eq(slots[2],path.Skill);eq(slots[3],nil)
    else eq(slots[3],path.Skill);eq(slots[2],if path.Parent then rules.Paths[path.Parent].Skill else nil) end
   end end
  end
 end)
 test("slot casting rejects locked arts and preserves global cooldown across slots",function()
  local stats=require("../src/server/Systems/CombatStats")(content,combat,gear)
  local target=require("../src/server/Systems/CombatTargeting")(function(a: any,b: any) return math.abs(a.x-b.x) end)
  local damage=require("../src/server/Systems/CombatDamage")(stats,target,function() end)
  local abilities=require("../src/server/Systems/CombatAbilities")(combat,target,damage,function() end)
  for _,class in ipairs(content.AdventurerOrder) do
   local starter=combat.Classes[class].Ability
   local a: any={id="player",class=class,kind="Hero",owner=1,active=true,state="Idle",health=1,stats=stats.hero(class,6,nil),x=0,cooldowns={},allowedAbilities={starter}}
   local enemy: any={id="enemy",kind="Enemy",owner=1,active=true,state="Idle",health=5000,stats=combat.Goblin,x=2,threat={}}
   local chosen: any=nil
   for id,path in pairs(rules.Paths) do if path.Class==class and path.Tier==3 and path.Parent then chosen=id;break end end
   local path=rules.Paths[chosen]
   local ok,code=abilities.cast(a,path.Skill,enemy,{enemy},100);eq(ok,false);eq(code,"InvalidAbility")
   a.allowedAbilities=rules.allowedSkills({tier=3,path=chosen,skills={vitality=true,path_art=true,master_art=true}},starter)
   for index,id in ipairs(a.allowedAbilities) do
    a.health=1
    local victim=if combat.Abilities[id].Effect=="Heal" then a else enemy
    eq(abilities.cast(a,id,victim,{enemy},100+index*30),true)
    a.health=1
    local nextId=a.allowedAbilities[index%#a.allowedAbilities+1]
    local nextVictim=if combat.Abilities[nextId].Effect=="Heal" then a else enemy
    local success,reason=abilities.cast(a,nextId,nextVictim,{enemy},101+index*30)
    eq(success,false);eq(reason,"Cooldown")
   end
  end
 end)
	local function setup(class: string?): any
		local h=harness();h.setup();h.quest("trail_watch");h.quest("timber_escort");h.quest("quarry_patrol")
		eq(h.send("SelectPlayerClass",{classId=class or "Warrior"}),"OK")
		return h
	end
	local function mature(h: any)
		h.data().personalGuild.buildings.guildHall=14
		h.data().character.xp=3450;h.data().character.level=70
		for _,a in pairs(h.data().adventurers) do a.xp=3450;a.level=70 end
	end
	local function supplies(h: any)
		for _,id in ipairs({"timber","stone","iron_ore","herb","iron_ingot"}) do h.data().inventory.stacks[id]=50 end
	end
	local function finish(h: any,success: boolean): string
		local run=h.data().expansion.tower.active;return h.service.CommitTower(1,h.command("TowerResult"),run.id,run.floor,success)
	end
	test("v3 migration adds expansion without changing prior data and rejects collisions",function()
		local h=setup();local old=util.copy(h.service.Sessions[1].record);old.data.settlement=nil;for _,hero in pairs(old.data.adventurers) do hero.rank=nil end;old.data.guildLand=nil;old.data.market=nil;old.schemaVersion=3;old.data.expansion=nil
		local migrated,code=schema.migrate(old);eq(code,"OK");eq(schema.validate(migrated,1),true)
		migrated.data.expansion=nil;migrated.data.guildLand=nil;migrated.data.market=nil;migrated.data.settlement=nil;for _,hero in pairs(migrated.data.adventurers) do hero.rank=nil end;eq(migrated.data,old.data)
		old.data.expansion={tower={highest=10}};local copy=util.copy(old);local rejected=schema.migrate(old);eq(rejected,nil);eq(old,copy)
	end)
	test("gathering cooldown capacity and replay persist without duplicated resources",function()
		local h=setup();local cmd=h.command("GatherResource",{nodeId="stone"});eq(h.service.Execute(1,cmd),"OK")
		eq(h.data().inventory.stacks.stone,2);eq(h.service.Execute(1,cmd),"AlreadyCommitted")
		eq(h.send("GatherResource",{nodeId="stone"}),"ResourceCooling")
		h.now+=10;h.data().inventory.stacks.stone=99;eq(h.send("GatherResource",{nodeId="stone"}),"WarehouseFull")
		eq(h.data().inventory.stacks.stone,99)
	end)
	test("building boundary overlap reserved path and foreign IDs reject without cost",function()
		local h=setup();supplies(h)
		eq(h.send("PlaceBuilding",{kind="warehouse",x=6,z=-4,rotation=0}),"OK")
		for _,args in ipairs({{kind="quarters",x=6,z=-4,rotation=0},{kind="quarters",x=6,z=0,rotation=0},{kind="quarters",x=11,z=2,rotation=0},{kind="quarters",x=6,z=2,rotation=4}}) do
			local before=util.copy(h.data());eq(h.send("PlaceBuilding",args),"InvalidPlacement");eq(h.data(),before)
		end
		eq(h.send("MoveBuilding",{buildingId="foreign",x=6,z=2,rotation=0}),"InvalidBuilding")
	end)
	test("move rotate dismantle refunds half once and preserves main access",function()
		local h=setup();supplies(h);eq(h.send("PlaceBuilding",{kind="quarters",x=6,z=-4,rotation=0}),"OK")
		local materials=util.copy(h.data().inventory.stacks)
		eq(h.send("MoveBuilding",{buildingId="b:1",x=8,z=2,rotation=3}),"OK");eq(h.data().inventory.stacks,materials)
		local cmd=h.command("DismantleBuilding",{buildingId="b:1"});eq(h.service.Execute(1,cmd),"OK");eq(h.data().inventory.stacks.timber,46)
		eq(h.service.Execute(1,cmd),"AlreadyCommitted");eq(h.data().inventory.stacks.timber,46);eq(h.data().expansion.buildings,{})
	end)
	test("construction missing materials and uncertain saves never expose partial base",function()
		for _,mode in ipairs({"before","after"}) do
			local h=setup();local before=util.copy(h.data());eq(h.send("PlaceBuilding",{kind="forge",x=6,z=-4,rotation=0}),"MissingMaterials");eq(h.data(),before)
			supplies(h);before=util.copy(h.data());local cmd=h.command("PlaceBuilding",{kind="forge",x=6,z=-4,rotation=0});h.mode=mode
			eq(h.service.Execute(1,cmd),"SavePending");eq(h.data(),before);h.mode="ok";eq(h.service.Refresh(1),"OK")
			eq(h.data().expansion.buildings["b:1"].kind,"forge");eq(h.data().inventory.stacks.stone,42)
		end
	end)
 test("UAT catalog has thirty useful items and ten valid recipes with unchanged trade allowlist",function()
  eq(util.count(content.Items),30);eq(#content.ItemOrder,30)
  eq(require("../src/server/Systems/RecipeValidator")(content,rules,util),true)
  local tradable={};for id,def in pairs(content.Items) do if def.Tradable then table.insert(tradable,id) end end;table.sort(tradable)
  eq(tradable,{"herb","iron_ingot","iron_ore","stone","timber"})
  for _,id in ipairs(rules.RecipeOrder) do local def=content.Items[rules.Recipes[id].Item];if def.Kind~="Material" then eq(def.Tradable,false) end end
 end)
 test("all seven new recipes enforce gates exact costs bound output and replay safety",function()
  for _,id in ipairs(rules.RecipeOrder) do local recipe=rules.Recipes[id];if recipe.HallLevel then
   local h=setup();supplies(h);eq(h.send("PlaceBuilding",{kind="forge",x=6,z=-4,rotation=0}),"OK")
   local before=util.copy(h.data());eq(h.send("CraftItem",{recipeId=id}),"HallRequired");eq(h.data(),before)
   h.data().personalGuild.buildings.guildHall=recipe.HallLevel
   local stacks=util.copy(h.data().inventory.stacks);local sequence=h.data().inventory.nextEquipmentSequence
   local cmd=h.command("CraftItem",{recipeId=id});eq(h.service.Execute(1,cmd),"OK")
   for item,n in pairs(stacks) do eq(h.data().inventory.stacks[item],n-(recipe.Cost[item] or 0)) end
   local output=h.data().inventory.equipment["craft:"..sequence..":1"]
   eq(output.definitionId,recipe.Item);eq(output.binding,"Account")
   local saved=util.copy(h.data());eq(h.service.Execute(1,cmd),"AlreadyCommitted");eq(h.data(),saved)
   eq(schema.validate(h.service.Sessions[1].record,1),true)
  end end
 end)
 test("new gear purchase gates and uncertain crafting recovery preserve ownership",function()
  local h=setup();supplies(h)
  for _,id in ipairs(content.ItemOrder) do local def=content.Items[id];if def.HallLevel then
   local before=util.copy(h.data());eq(h.send("BuyEquipment",{definitionId=id}),"HallRequired");eq(h.data(),before)
  end end
  eq(h.send("PlaceBuilding",{kind="forge",x=6,z=-4,rotation=0}),"OK");h.data().personalGuild.buildings.guildHall=3
  for _,mode in ipairs({"before","after"}) do
   local before=util.copy(h.data());local sequence=before.inventory.nextEquipmentSequence
   local cmd=h.command("CraftItem",{recipeId="watchblade"});h.mode=mode
   eq(h.service.Execute(1,cmd),"SavePending");eq(h.data(),before);h.mode="ok";eq(h.service.Refresh(1),"OK")
   eq(h.data().inventory.equipment["craft:"..sequence..":1"].definitionId,"watchblade")
   eq(h.data().inventory.stacks.iron_ingot,before.inventory.stacks.iron_ingot-4)
  end
 end)
	test("warehouse raises gathering cap and forge consumes exact recipe atomically",function()
		local h=setup();supplies(h);eq(h.send("CraftItem",{recipeId="iron_ingot"}),"ForgeRequired")
		eq(h.send("PlaceBuilding",{kind="warehouse",x=6,z=-4,rotation=0}),"OK")
		eq(h.send("PlaceBuilding",{kind="forge",x=8,z=-4,rotation=0}),"OK")
		h.data().inventory.stacks.stone=100;eq(h.send("GatherResource",{nodeId="stone"}),"OK");eq(h.data().inventory.stacks.stone,102)
		local ore=h.data().inventory.stacks.iron_ore;local cmd=h.command("CraftItem",{recipeId="iron_ingot"})
		eq(h.service.Execute(1,cmd),"OK");eq(h.data().inventory.stacks.iron_ore,ore-3);eq(h.data().inventory.stacks.iron_ingot,51)
		eq(h.service.Execute(1,cmd),"AlreadyCommitted");eq(h.data().inventory.stacks.iron_ingot,51)
	end)
	test("full equipment crafting rolls back recipe and instance sequence",function()
		local h=setup();supplies(h);h.send("PlaceBuilding",{kind="forge",x=6,z=-4,rotation=0})
		for i=util.count(h.data().inventory.equipment)+1,50 do h.data().inventory.equipment["fill:"..i]={definitionId="training_sword",upgradeLevel=0,binding="Account"} end
		local before=util.copy(h.data());eq(h.send("CraftItem",{recipeId="guardian_plate"}),"InventoryFull");eq(h.data(),before)
	end)
	test("promotion boundaries 29 30 69 70 and global Hall cap",function()
		local h=setup();mature(h);local d=h.data()
		local function level(n: number) d=h.data();d.character.level=n;d.character.xp=(n-1)*50 end
		level(29);eq(h.send("AdvanceClass",{actorId="player",pathId="berserker"}),"AdvancementLocked")
		level(30);eq(h.send("AdvanceClass",{actorId="player",pathId="berserker"}),"OK")
		h.data().expansion.tower.highest=5;level(69);eq(h.send("AdvanceClass",{actorId="player",pathId="warlord"}),"AdvancementLocked")
		level(70);eq(h.send("AdvanceClass",{actorId="player",pathId="warlord"}),"OK")
		eq(h.send("AdvanceClass",{actorId="player",pathId="warlord"}),"InvalidClassPath")
		h.data().personalGuild.buildings.guildHall=20;level(100);eq(schema.validate(h.service.Sessions[1].record,1),true)
		level(101);eq(schema.validate(h.service.Sessions[1].record,1),false)
		level(100);d.personalGuild.buildings.guildHall=21;eq(schema.validate(h.service.Sessions[1].record,1),false)
		eq(content.HallUpgrades[19].To,20);eq(content.HallUpgrades[20],nil)
	end)
	test("all five classes have two gated Class 2 branches and matching Class 3 arts",function()
		for _,class in ipairs(content.AdventurerOrder) do
			local count=0
			for id,path in pairs(rules.Paths) do if path.Class==class and path.Tier==2 then
				count+=1;local h=setup(class);eq(h.send("AdvanceClass",{actorId="player",pathId=id}),"AdvancementLocked");mature(h)
				eq(h.send("AdvanceClass",{actorId="player",pathId=id}),"OK");eq(h.data().character.tier,2)
				for child,nextPath in pairs(rules.Paths) do if nextPath.Parent==id then
					eq(h.send("AdvanceClass",{actorId="player",pathId=child}),"AdvancementLocked");h.data().expansion.tower.highest=5
					eq(h.send("AdvanceClass",{actorId="player",pathId=child}),"OK");eq(h.data().character.tier,3);eq(schema.validate(h.service.Sessions[1].record,1),true)
				end end
			end end
			eq(count,2)
		end
	end)
	test("skill prerequisites points branch exclusion and reset conserve builds",function()
		local h=setup();eq(h.send("LearnSkill",{actorId="player",skillId="vitality"}),"NoSkillPoints");mature(h)
		eq(h.send("LearnSkill",{actorId="player",skillId="focus"}),"SkillPrerequisite")
		eq(h.send("LearnSkill",{actorId="player",skillId="vitality"}),"OK");eq(h.send("LearnSkill",{actorId="player",skillId="focus"}),"OK")
		eq(h.send("LearnSkill",{actorId="player",skillId="ward"}),"SkillBranchConflict")
		eq(h.send("AdvanceClass",{actorId="player",pathId="berserker"}),"OK");eq(h.send("LearnSkill",{actorId="player",skillId="path_art"}),"OK")
		eq(h.send("EquipSkill",{actorId="player",skillId="cleave"}),"OK");eq(h.send("EquipSkill",{actorId="player",skillId="nova"}),"SkillNotLearned")
		local gold=h.data().currencies.gold;local cmd=h.command("ResetSkills",{actorId="player"});eq(h.service.Execute(1,cmd),"OK")
		eq(h.data().currencies.gold,gold-10);eq(h.service.Execute(1,cmd),"AlreadyCommitted");eq(rules.spent(h.data().expansion.actors.player),0)
		eq(h.data().expansion.actors.player.path,"berserker")
	end)
	test("hero build is independent and bonuses match projected combat stats",function()
		local h=setup();mature(h);h.send("LearnSkill",{actorId="a:Warrior",skillId="vitality"});eq(rules.spent(rules.build(h.data(),"player")),0)
		h.send("SelectRace",{raceId="Elf"});local a=h.data().character;local projected=progression.stats(h.data(),a)
		local stats=require("../src/server/Systems/CombatStats")(content,combat,gear).hero(a.classId,a.level,"training_sword",nil,nil,gear.extras(h.data(),a))
		eq(projected.Health,stats.MaxHealth);eq(projected.Attack,stats.Attack);eq(projected.Defense,stats.Defense)
	end)
	test("race choice persists exactly once with bounded tradeoffs",function()
		for _,race in ipairs({"Human","Elf","Dwarf"}) do local h=setup();eq(h.send("SelectRace",{raceId=race}),"OK")
			eq(h.send("SelectRace",{raceId="Human"}),"RaceAlreadyChosen");eq(schema.validate(h.service.Sessions[1].record,1),true)
			local saved=util.copy(h.data());h.service.Close(1);h.service=h.make();eq(h.service.Load(1,"race"),"OK");eq(h.data(),saved)
		end
	end)
	test("tower only accepts server completion and never skips uncleared floors",function()
		local h=setup();eq(h.send("TowerResult",{}),"InvalidRequest");eq(h.send("StartTower",{floor=6}),"FloorLocked")
		eq(h.send("StartTower",{floor=1}),"OK");local before=util.copy(h.data());eq(finish(h,true),"StaleTowerRun");eq(h.data(),before)
		eq(h.send("EnterTowerFloor",{}),"OK");eq(finish(h,true),"OK");eq(h.data().expansion.tower.highest,1);eq(h.data().expansion.tower.active.floor,2)
		eq(finish(h,true),"StaleTowerRun");eq(h.send("UpdateParty",{adventurerIds={}}),"LeaveTowerFirst")
		eq(h.send("AssignEquipment",{actorId="player",instanceId="q:3:1"}),"OK")
		h.send("EnterTowerFloor",{});eq(h.send("UnequipEquipment",{actorId="player",slot="weapon"}),"LeaveTowerFirst")
	end)
	test("ten tower floors unlock checkpoint and first-clear repeat rewards differ",function()
		local h=setup();h.send("StartTower",{floor=1})
		for floor=1,10 do eq(h.send("EnterTowerFloor",{}),"OK");eq(finish(h,true),"OK");eq(h.data().expansion.tower.highest,floor) end
		eq(h.data().expansion.tower.active,nil);eq(h.data().expansion.tower.checkpoint,5);eq(h.data().character.level,5)
		local before=h.data().currencies.gold;h.send("StartTower",{floor=6});h.send("EnterTowerFloor",{});eq(finish(h,true),"OK")
		eq(h.data().currencies.gold-before,10)
	end)
	test("tower failure retry and active rejoin retain clear history without rewards",function()
		local h=setup();h.send("StartTower",{floor=1});h.send("EnterTowerFloor",{});local before=h.data().currencies.gold
		eq(finish(h,false),"OK");eq(h.data().currencies.gold,before);eq(h.data().expansion.tower.active.state,"Failed")
		eq(h.send("EnterTowerFloor",{}),"TowerNotReady");eq(h.send("LeaveTower",{}),"OK");eq(h.send("StartTower",{floor=1}),"OK");h.send("EnterTowerFloor",{})
		local saved=util.copy(h.data());h.service.Close(1);h.service=h.make();eq(h.service.Load(1,"tower"),"OK");eq(h.data(),saved)
	end)
	test("uncertain tower completion reconciles first-clear exactly once",function()
		local h=setup();h.send("StartTower",{floor=1});h.send("EnterTowerFloor",{});local run=util.copy(h.data().expansion.tower.active)
		local before=util.copy(h.data());local cmd=h.command("TowerResult");h.mode="after"
		eq(h.service.CommitTower(1,cmd,run.id,1,true),"SavePending");eq(h.data(),before);h.mode="ok";eq(h.service.Refresh(1),"OK")
		eq(h.service.CommitTower(1,cmd,run.id,1,true),"AlreadyCommitted");eq(h.data().currencies.gold,before.currencies.gold+18)
	end)
	test("special Epic Legendary and Secret paths require their actual milestones",function()
		for _,id in ipairs({"commander","rune_knight","bard","shadow_dancer"}) do
			local p=rules.Paths[id];local h=setup(p.Class);mature(h);supplies(h)
			local base=({Warrior="berserker",Knight="guardian",Priest="cleric",Archer="ranger"})[p.Class]
			h.send("AdvanceClass",{actorId="player",pathId=base});h.data().expansion.tower.highest=p.Floor
			eq(h.send("AdvanceClass",{actorId="player",pathId=id}),"QuartersRequired");h.send("PlaceBuilding",{kind="quarters",x=6,z=-4,rotation=0})
			if p.Secret then eq(h.send("AdvanceClass",{actorId="player",pathId=id}),"SecretUndiscovered");for node in pairs(rules.Nodes) do h.send("GatherResource",{nodeId=node}) end end
			eq(h.send("AdvanceClass",{actorId="player",pathId=id}),"OK");eq(schema.validate(h.service.Sessions[1].record,1),true)
		end
	end)
	test("schema rejects forged points path race overlap and tower progress",function()
		local h=setup();for _,mutate in ipairs({
			function(d: any) d.expansion.actors.player={tier=1,skills={master_art=true}} end,
			function(d: any) d.character.raceId="Dragon" end,
			function(d: any) d.expansion.tower.checkpoint=5 end,
			function(d: any) d.expansion.buildings["b:1"]={kind="quarters",x=6,z=0,rotation=0};d.expansion.nextBuilding=2 end,
		}) do local record=util.copy(h.service.Sessions[1].record);mutate(record.data);eq(schema.validate(record,1),false) end
	end)
	test("group prestige support excludes distant foreign and downed actors",function()
		local stats=require("../src/server/Systems/CombatStats")(content,combat,gear)
		local target=require("../src/server/Systems/CombatTargeting")(function(a: any,b: any) return math.abs(a.x-b.x) end)
		local damage=require("../src/server/Systems/CombatDamage")(stats,target,function() end)
		local abilities=require("../src/server/Systems/CombatAbilities")(combat,target,damage,function() end)
		local function actor(id: string,owner: number,x: number): any return {id=id,class="Priest",kind="Hero",owner=owner,active=true,state="Idle",health=5,stats=stats.hero("Priest",8,nil),x=x,cooldowns={}} end
		local a=actor("bard",1,0);a.ability="bard_art"
		local near=actor("near",1,2);local far=actor("far",1,50);local foreign=actor("foreign",2,2);local down=actor("down",1,2);down.health=0;down.state="Downed"
		a.allies={a,near,far,foreign,down};eq(abilities.cast(a,"bard_art",near,{},100),true)
		assert(a.health>5 and near.health>5);eq(far.health,5);eq(foreign.health,5);eq(down.health,0)
		a.class="Warrior";a.ability="commander_art";a.cooldowns={};a.nextAbility=0
		local enemy: any={id="enemy",kind="Enemy",owner=1,active=true,state="Idle",health=100,stats=combat.Goblin,x=2,threat={}}
		eq(abilities.cast(a,"commander_art",enemy,{enemy},200),true);eq(near.guardUntil,204);eq(far.guardUntil,nil);eq(foreign.guardUntil,nil);eq(down.guardUntil,nil)
	end)
	test("all expanded arts enforce targets cooldowns and meaningful effects",function()
		local stats=require("../src/server/Systems/CombatStats")(content,combat,gear)
		local target=require("../src/server/Systems/CombatTargeting")(function(a: any,b: any) return math.abs(a.x-b.x) end)
		local damage=require("../src/server/Systems/CombatDamage")(stats,target,function() end)
		local abilities=require("../src/server/Systems/CombatAbilities")(combat,target,damage,function() end)
		for id,def in pairs(rules.Abilities) do
			local a: any={id="player",class=def.Class,kind="Hero",owner=1,active=true,state="Idle",health=10,stats=stats.hero(def.Class,6,nil),x=0,cooldowns={},ability=id}
			local enemy: any={id="enemy",kind="Enemy",owner=1,active=true,state="Idle",health=500,stats=combat.Goblin,x=2,threat={}}
			local targets={enemy};local victim=if def.Effect=="Heal" then a else enemy
			eq(abilities.cast(a,id,victim,targets,100),true)
			if def.Effect=="Guard" then eq(a.guardUntil,100+def.Duration);eq(enemy.tauntTarget,a)
			elseif def.Effect=="Heal" then assert(a.health>10)
			else assert(enemy.health<500);if def.Effect=="Drain" then assert(a.health>10) elseif def.Effect=="Slow" then eq(enemy.slowUntil,100+def.Duration) end end
			a.ability=combat.Classes[a.class].Ability;local ok,code=abilities.cast(a,a.ability,victim,targets,101);eq(ok,false);eq(code,"Cooldown")
		end
	end)
    test("regional gathering keeps per-profile cooldown and capacity atomic",function()
        local h=harness();h.setup();local cmd=h.command("GatherResource",{nodeId="greenwood_wood"})
        eq(h.service.Execute(1,cmd),"OK");eq(h.service.Execute(1,cmd),"AlreadyCommitted")
        eq(h.data().inventory.stacks.timber,2);eq(h.send("GatherResource",{nodeId="greenwood_wood"}),"ResourceCooling")
        eq(h.data().expansion.gathered.wood,nil);eq(h.data().expansion.gathered.greenwood_wood,true)
        local other=harness();other.setup();eq(other.send("GatherResource",{nodeId="greenwood_wood"}),"OK")
        h.now+=13;h.data().inventory.stacks.timber=99;local before=util.copy(h.data())
        eq(h.send("GatherResource",{nodeId="greenwood_wood"}),"WarehouseFull");eq(h.data(),before)
        eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"regional-gather"),"OK")
        eq(h.data().expansion.gathered.greenwood_wood,true)
    end)
    test("regional gathering does not expose inventory before uncertain save resolves",function()
        for _,mode in ipairs({"before","after"}) do
            local h=harness();h.setup();local before=util.copy(h.data());h.mode=mode
            local cmd=h.command("GatherResource",{nodeId="greenwood_herbs"})
            eq(h.service.Execute(1,cmd),"SavePending");eq(h.data(),before)
            h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,cmd),"AlreadyCommitted")
            eq(h.data().inventory.stacks.herb,2);eq(h.data().expansion.gathered.herbs,nil)
        end
    end)

    test("regional herbs satisfy gathering quests once without replacing home discovery",function()
        local h=harness();h.setup()
        eq(h.send("AcceptTask",{questId="mogra_gathering"}),"OK")
        eq(h.send("AcceptTask",{questId="herb_field"}),"OK")
        local cmd=h.command("GatherResource",{nodeId="greenwood_herbs"})
        eq(h.service.Execute(1,cmd),"OK");eq(h.service.Execute(1,cmd),"AlreadyCommitted")
        eq(h.data().settlement.journal.mogra_gathering.progress,1);eq(h.data().settlement.journal.herb_field.progress,1)
        eq(h.send("GatherResource",{nodeId="greenwood_herbs"}),"ResourceCooling")
        eq(h.data().settlement.journal.mogra_gathering.progress,1)
        h.now+=13;eq(h.send("GatherResource",{nodeId="greenwood_herbs"}),"OK")
        eq(h.data().settlement.journal.mogra_gathering.progress,2);eq(h.data().settlement.journal.herb_field.progress,2)
        eq(h.data().expansion.gathered.herbs,nil)
        eq(h.send("GatherResource",{nodeId="herbs"}),"OK")
        eq(h.data().settlement.journal.herb_field.progress,3);eq(h.data().settlement.journal.mogra_gathering.progress,2)
    end)

    test("Ironveil and Ashen gather nodes preserve original resource discovery gates",function()
        for _,id in ipairs({"ironveil_stone","ironveil_ore","ashen_herbs","ashen_stone"}) do
            local h=harness();h.setup();local node=rules.Nodes[id]
            eq(h.send("GatherResource",{nodeId=id}),"OK");eq(h.data().inventory.stacks[node.Item],2)
            eq(h.data().expansion.gathered[id],true);eq(h.data().expansion.gathered[node.QuestNode],nil)
            eq(h.send("GatherResource",{nodeId=id}),"ResourceCooling");eq(schema.validate(h.service.Sessions[1].record,1),true)
        end
    end)

end

