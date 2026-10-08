--!strict
-- Authoritative slice definitions. The client receives a display projection only.
local Content: any = {
	Version = "uat01-content-1",
	StatusAllocationAvailable = false,
	RecruitmentTemplatesAvailable = false,
	CivicTravel={Crownford="elian_charter",Sylvaris="vaela_seedlings",Deepforge="borin_castings",Astralis="nyra_stonecharts",Crosshaven="sela_shelter",Ironroot="roka_shared_pot"},
	Character = {
		Version = 1, RaceId = "Human", Tier = 1,
		Classes = {
			Warrior = { PathId = "warrior:1", SkillId = "power_strike", Weapon = "training_sword" },
			Knight = { PathId = "knight:1", SkillId = "taunt", Weapon = "knight_sword" },
			Archer = { PathId = "archer:1", SkillId = "piercing_shot", Weapon = "short_bow" },
			Mage = { PathId = "mage:1", SkillId = "fireball", Weapon = "mage_staff" },
			Priest = { PathId = "priest:1", SkillId = "heal", Weapon = "apprentice_staff" },
		},
	},
	Limits = { Party = 5, Roster = 50, Gold = 1000000000, Stack = 1000000, Equipment = 50, Level = 100,
		XP = 1000000, Audit = 128, RecentResults = 32, ProfileBytes = 131072 },
	Items = {
		stone={Id="stone",Name="Stone",Kind="Material",Description="Stone for building and crafting."},
		timber = { Id = "timber", Name = "Timber", Kind = "Material", Description = "Beams for your Guild Hall." },
		iron_ore = { Id = "iron_ore", Name = "Iron Ore", Kind = "Material", Description = "Stone-rich ore for Hall reinforcement." },
		iron_ingot = { Id = "iron_ingot", Name = "Iron Ingot", Kind = "Material", Description = "A reinforcement for the Hall upgrade." },
		herb = { Id = "herb", Name = "Herb", Kind = "Material", Description = "Supplies for your upgraded Hall." },
		leather_vest = { Id="leather_vest",Name="Leather Vest",Kind="Armor",Slot="armor",Class="Any",Health=4,Defense=2,Price=18,Description="Light protection for every class." },
		guardian_plate = { Id="guardian_plate",Name="Guardian Plate",Kind="Armor",Slot="armor",Classes={Warrior=true,Knight=true},Health=6,Defense=4,Price=30,Description="Heavy protection for Warriors and Knights." },
		woven_robes = { Id="woven_robes",Name="Woven Robes",Kind="Armor",Slot="armor",Classes={Mage=true,Priest=true},Health=8,Defense=1,Price=24,Description="Reinforced robes for Mages and Priests." },
		bronze_ring = { Id="bronze_ring",Name="Bronze Ring",Kind="Accessory",Slot="accessory",Class="Any",Attack=1,Price=15,Description="A small boost to attack." },
		vitality_charm = { Id="vitality_charm",Name="Vitality Charm",Kind="Accessory",Slot="accessory",Class="Any",Health=8,Price=20,Description="Extra vitality for any adventurer." },
		training_sword = { Id = "training_sword", Name = "Training Sword", Kind = "Weapon", Slot = "weapon", Price = 12, Class = "Warrior", Attack = 2, Description = "+2 attack; helps shorten expeditions." },
		short_bow = { Id = "short_bow", Name = "Short Bow", Kind = "Weapon", Slot = "weapon", Price = 12, Class = "Archer", Attack = 2, Description = "+2 attack; helps shorten expeditions." },
		apprentice_staff = { Id = "apprentice_staff", Name = "Apprentice Staff", Kind = "Weapon", Slot = "weapon", Price = 12, Class = "Priest", Attack = 2, Description = "+2 attack; helps shorten expeditions." },
		iron_sword = { Id = "iron_sword", Name = "Iron Sword", Kind = "Weapon", Slot = "weapon", Price = 28, Class = "Warrior", Attack = 4, Description = "+4 attack; a stronger expedition weapon." },
		knight_sword = { Id = "knight_sword", Name = "Knight Sword", Kind = "Weapon", Slot = "weapon", Price = 12, Class = "Knight", Attack = 2, Description = "+2 attack; a dependable guard's weapon." },
		mage_staff = { Id = "mage_staff", Name = "Mage Staff", Kind = "Weapon", Slot = "weapon", Price = 12, Class = "Mage", Attack = 2, Description = "+2 attack; a novice's arcane focus." },
	},
	ItemOrder = { "stone", "timber", "iron_ore", "iron_ingot", "herb", "training_sword", "short_bow", "apprentice_staff", "iron_sword", "knight_sword", "mage_staff", "leather_vest", "guardian_plate", "woven_robes", "bronze_ring", "vitality_charm" },
	Adventurers = {
		Warrior = { Id = "Warrior", Name = "Rowan", Class = "Warrior", Cost = 0, Stats = { Health = 30, Attack = 6, Defense = 4 } },
		Archer = { Id = "Archer", Name = "Ash", Class = "Archer", Cost = 20, Weapon = "short_bow", Stats = { Health = 22, Attack = 8, Defense = 2 } },
		Priest = { Id = "Priest", Name = "Sage", Class = "Priest", Cost = 20, Weapon = "apprentice_staff", Stats = { Health = 24, Attack = 4, Defense = 3 } },
		Knight = { Id = "Knight", Name = "Bram", Class = "Knight", Cost = 20, Weapon = "knight_sword", Stats = { Health = 40, Attack = 4, Defense = 7 } },
		Mage = { Id = "Mage", Name = "Lyra", Class = "Mage", Cost = 20, Weapon = "mage_staff", Stats = { Health = 20, Attack = 10, Defense = 1 } },
	},
	AdventurerOrder = { "Warrior", "Archer", "Priest", "Knight", "Mage" },
	Roles = { Warrior = "Damage", Archer = "Ranged", Priest = "Healer", Knight = "Tank", Mage = "Magic" },
	Enemies = { goblin_scout = { Id = "goblin_scout", Name = "Goblin Scout", Health = 12, Attack = 3 } },
	Quests = {
		trail_watch = { Id = "trail_watch", Name = "Trail Watch", Description = "Secure the woodland path from a Goblin Scout.", Duration = 15, Enemy = "goblin_scout", EnemyCount = 1, Requirements = { PartySize = 1 },
			First = { Gold = 30, XP = 20, Items = { { Id = "training_sword", Quantity = 1 }, { Id = "herb", Quantity = 2 } } },
			Repeat = { Gold = 10, XP = 5, Items = { { Id = "timber", Quantity = 1 }, { Id = "herb", Quantity = 1 } } } },
		timber_escort = { Id = "timber_escort", Name = "Timber Escort", Description = "Escort timber past two Goblin Scouts.", Duration = 25, Enemy = "goblin_scout", EnemyCount = 2, Requirements = { PartySize = 1, FirstClear = "trail_watch" },
			First = { Gold = 40, XP = 30, Items = { { Id = "timber", Quantity = 6 }, { Id = "iron_ingot", Quantity = 1 } } },
			Repeat = { Gold = 12, XP = 8, Items = { { Id = "timber", Quantity = 2 }, { Id = "iron_ingot", Quantity = 1 } } } },
		quarry_patrol = { Id = "quarry_patrol", Name = "Quarry Patrol", Description = "Drive three Goblin Scouts from the quarry.", Duration = 35, Enemy = "goblin_scout", EnemyCount = 3, Requirements = { PartySize = 1, FirstClear = "timber_escort" },
			First = { Gold = 60, XP = 40, Items = { { Id = "iron_ore", Quantity = 6 }, { Id = "iron_sword", Quantity = 1 } } },
			Repeat = { Gold = 15, XP = 10, Items = { { Id = "iron_ore", Quantity = 2 } } } },
	},
	QuestOrder = { "trail_watch", "timber_escort", "quarry_patrol" },
	Hall = { From = 1, To = 2, Gold = 80, Materials = { timber = 6, iron_ore = 6, iron_ingot = 1, herb = 2 }, RequiredQuest = "quarry_patrol" },
	Progression = { XPPerLevel = 50, AttackPerLevel = 1, HealthPerLevel = 3, MinQuestDuration = 10, AttackPerSecondSaved = 2 },
}
Content.HallUpgrades = { [1] = Content.Hall }
-- One current-rules projection for every XP producer, save validator and display.
-- Stored XP is never consumed or rewritten when the Hall cap changes.
Content.ProgressionRulesets={Legacy="guildborne.legacy.1",Novice="guildborne.progression.2"}
function Content.ProgressionMode(data:any):string
 local mode=data.progression and data.progression.ruleset
 assert(mode==nil or mode==Content.ProgressionRulesets.Legacy or mode==Content.ProgressionRulesets.Novice,"Unknown progression ruleset")
 return mode or Content.ProgressionRulesets.Legacy
end
function Content.HallLevelCap(hall:number,mode:string?):number
 local selected=mode or Content.ProgressionRulesets.Legacy
 assert(selected==Content.ProgressionRulesets.Legacy or selected==Content.ProgressionRulesets.Novice,"Unknown progression ruleset")
 assert(hall%1==0 and hall>=(if selected==Content.ProgressionRulesets.Novice then 0 else 1) and hall<=20,"Invalid Hall")
 if selected==Content.ProgressionRulesets.Novice then return if hall==0 then 10 else math.min(100,20+5*(hall-1)) end
 return hall*5
end
function Content.ProfileLevelCap(data:any):number
 return Content.HallLevelCap(data.personalGuild.buildings.guildHall,Content.ProgressionMode(data))
end
function Content.NoviceActionProblem(data:any,action:string):string?
 if Content.ProgressionMode(data)~=Content.ProgressionRulesets.Novice then return nil end
 local story=data.progression.novice
 if story and story.claimed==6 then return nil end
 if ({GetState=true,RetryLoad=true,RetrySave=true,SetLanguage=true,BeginTutorial=true,ClaimNoviceChapter=true,FoundNoviceGuild=true,SelectPlayerClass=true})[action] then return nil end
 return "NoviceJourneyRequired"
end
function Content.RecruitmentStartingXP(data:any):number
 return if Content.ProgressionMode(data)==Content.ProgressionRulesets.Novice then 9*Content.Progression.XPPerLevel else 0
end
function Content:LevelFromXP(xp:number,cap:number):number
 return math.min(cap,1+math.floor(xp/self.Progression.XPPerLevel))
end
for level=2,19 do Content.HallUpgrades[level]={From=level,To=level+1,Gold=80*level,Materials={timber=6*level,stone=8*level,iron_ore=4*level},RequiredQuest="quarry_patrol"} end
Content.Tavern={MaxLevel=5,ScoutCost=20,HireCost=30,Ranks={"F","E","D","C","B","A","S","SS","SSS"},
 Odds={{6000,2500,1000,400,90,10,0,0,0},{4000,3000,1800,800,300,90,10,0,0},{2500,2800,2500,1400,550,200,45,5,0},{1500,2000,2600,2100,1100,500,170,29,1},{500,1200,2000,2500,2000,1200,450,140,10}}}
-- Original named recruits bind the existing fifteen local visual templates.
Content.HeroTemplates={};Content.HeroTemplateOrder={};Content.HeroTemplatePools={}
local heroNames={Warrior={"Rowan","Kira","Toren"},Knight={"Bram","Elian","Vera"},Archer={"Ash","Neris","Fenn"},Mage={"Lyra","Orin","Selene"},Priest={"Sage","Iona","Corin"}}
for _,class in ipairs(Content.AdventurerOrder) do
 local pool={};Content.HeroTemplatePools[class]=pool
 for index,name in ipairs(heroNames[class]) do
  local id=string.lower(class).."_0"..index
  Content.HeroTemplates[id]={Id=id,Name=name,Class=class,VisualId=id}
  table.insert(pool,id);table.insert(Content.HeroTemplateOrder,id)
 end
end
Content.Journal={
 city_gate={Id="city_gate",Name="A Guild of Your Own",Category="Main",Description="Visit the Guild Zone through the city portal.",Event="VisitGuild",Count=1,Gold=15,XP=10},
 camp_threat={Id="camp_threat",Name="The Goblin Threat",Category="Main",Description="Defeat three Goblins with your guild team.",Event="Goblin",Count=3,Requires="city_gate",Gold=30,XP=25},
 timber_help={Id="timber_help",Name="Timber for the Town",Category="Side",Description="Gather timber four times after accepting this quest.",Event="Gather:wood",Count=4,Gold=20,XP=15},
 herbalist={Id="herbalist",Name="Mira's Remedy",Category="NPC",Description="Bring six herbs to Mira in the city.",NPC="Mira",Item="herb",Count=6,Gold=25,XP=20},
}
Content.JournalOrder={"city_gate","camp_threat","timber_help","herbalist"}
Content.QuestNPCs={["City Herald"]=true,Mira=true,Borga=true,Mogra=true,Rukk=true,Ghar=true}
for _,name in ipairs({"Marshal Elian","Arborist Vaela","Smith Borin","Cartographer Nyra","Harbormaster Sela","Steward Roka"})do Content.QuestNPCs[name]=true end
-- First-session objectives: state goals honor existing progress; event goals start on acceptance.
Content.Journal.stonework={Id="stonework",Name="A Lasting Foundation",Category="Main",Description="Gather stone three times after accepting this quest.",Count=3,Gold=12,XP=10,Event="Gather:stone",Requires="city_gate"}
table.insert(Content.JournalOrder,"stonework")
Content.Journal.ore_supply={Id="ore_supply",Name="Metal for the Forge",Category="Side",Description="Gather iron ore three times after accepting this quest.",Count=3,Gold=12,XP=10,Event="Gather:ore",Requires="stonework"}
table.insert(Content.JournalOrder,"ore_supply")
Content.Journal.herb_field={Id="herb_field",Name="Field Medicine",Category="Side",Description="Gather herbs three times after accepting this quest.",Count=3,Gold=12,XP=10,Event="Gather:herbs"}
table.insert(Content.JournalOrder,"herb_field")
Content.Journal.forge_foundation={Id="forge_foundation",Name="Light the Forge",Category="Main",Description="Build or own a Blacksmith in your guild.",Count=1,Gold=15,XP=10,StateGoal="Forge",Requires="stonework"}
table.insert(Content.JournalOrder,"forge_foundation")
Content.Journal.first_ingot={Id="first_ingot",Name="From Ore to Iron",Category="Main",Description="Smelt one Iron Ingot after accepting this quest.",Count=1,Gold=10,XP=10,Event="Craft:iron_ingot",Requires="forge_foundation"}
table.insert(Content.JournalOrder,"first_ingot")
Content.Journal.field_outfit={Id="field_outfit",Name="Made by Your Guild",Category="Main",Description="Craft one weapon, armor or accessory after accepting this quest.",Count=1,Gold=15,XP=15,Event="CraftEquipment",Requires="first_ingot"}
table.insert(Content.JournalOrder,"field_outfit")
Content.Journal.ready_for_battle={Id="ready_for_battle",Name="Ready for the Road",Category="Main",Description="Equip an owned item on your character or a companion after accepting this quest.",Count=1,Gold=10,XP=10,Event="Equip",Requires="city_gate"}
table.insert(Content.JournalOrder,"ready_for_battle")
Content.Journal.growing_hall={Id="growing_hall",Name="Room to Grow",Category="Main",Description="Reach Guild Hall level 2 or higher.",Count=1,Gold=15,XP=10,StateGoal="Hall2",Requires="camp_threat"}
table.insert(Content.JournalOrder,"growing_hall")
Content.Journal.company_reinforcement={Id="company_reinforcement",Name="A Company Takes Shape",Category="Side",Description="Own at least two adventurers.",Count=1,Gold=10,XP=10,StateGoal="Roster2",Requires="city_gate"}
table.insert(Content.JournalOrder,"company_reinforcement")
Content.Journal.first_lesson={Id="first_lesson",Name="A New Technique",Category="Main",Description="Learn at least one skill-tree node on your character or a companion.",Count=1,Gold=10,XP=10,StateGoal="LearnedSkill",Requires="ready_for_battle"}
table.insert(Content.JournalOrder,"first_lesson")
Content.Journal.spire_entry={Id="spire_entry",Name="Answer the Spire",Category="Main",Description="Enter a Tower encounter after accepting this quest. Victory is not required.",Count=1,Gold=15,XP=15,Event="EnterTower",Requires="first_lesson"}
table.insert(Content.JournalOrder,"spire_entry")
-- Friendly Orc professions introduce useful work without changing ancestry/class rules.
Content.Journal.borga_hearth={Id="borga_hearth",Name="A Hearth for Everyone",Category="NPC",Description="Bring four Timber to Borga so the inn can welcome more travellers.",NPC="Borga",Item="timber",Count=4,Gold=8,XP=6}
Content.Journal.mogra_gathering={Id="mogra_gathering",Name="The Herbalist's Lesson",Category="NPC",Description="Gather herbs twice after accepting Mogra's lesson, then return to her.",NPC="Mogra",Event="Gather:herbs",Count=2,Gold=8,XP=8}
Content.Journal.rukk_practice={Id="rukk_practice",Name="The Apprentice's First Shield",Category="NPC",Description="Bring one Iron Ingot to Rukk for his shield-making practice.",NPC="Rukk",Item="iron_ingot",Count=1,Gold=12,XP=10,Requires="forge_foundation"}
Content.Journal.ghar_caravans={Id="ghar_caravans",Name="Safe Roads, Shared Roads",Category="NPC",Description="Defeat two Goblins after accepting Ghar's request, then report back to him.",NPC="Ghar",Event="Goblin",Count=2,Gold=12,XP=10,Requires="city_gate"}
for _,id in ipairs({"borga_hearth","mogra_gathering","rukk_practice","ghar_caravans"}) do table.insert(Content.JournalOrder,id) end
-- Visiting civic envoys bind existing native cast to optional, one-time community work.
local civicTasks:{{any}}={
 {"elian_charter","A Charter with a Home","Return to your guild island after accepting Elian's request, then report to him in the city.","Marshal Elian","Event","VisitGuild",1,"city_gate",10,6},
 {"vaela_seedlings","Leave Room to Grow","Gather herbs twice at the Greenwood herb patch after accepting Vaela's request, then return to her. Keep the herbs.","Arborist Vaela","Event","Gather:greenwood_herbs",2,"herb_field",10,10},
 {"borin_castings","Work That Lasts","Craft two Iron Ingots after accepting Borin's request, then return to him. Keep the ingots.","Smith Borin","Event","Craft:iron_ingot",2,"first_ingot",12,10},
 {"nyra_stonecharts","A Safe Way Home","Gather stone twice at the Ashen stone outcrop after accepting Nyra's request, then return with your observations. Keep the stone.","Cartographer Nyra","Event","Gather:ashen_stone",2,"herb_field",12,10},
 {"sela_shelter","Promises at the Dock","Deliver four Timber to Sela for the shared cargo shelter.","Harbormaster Sela","Item","timber",4,"company_reinforcement",8,6},
 {"roka_shared_pot","A Seat for Everyone","Deliver four Herbs to Roka for a meal shared by visitors from every people.","Steward Roka","Item","herb",4,"borga_hearth",8,6},
}
for _,row in ipairs(civicTasks)do
 local id=row[1];local task:any={Id=id,Name=row[2],Description=row[3],NPC=row[4],Category="NPC",Count=row[7],Requires=row[8],Gold=row[9],XP=row[10]}
 if id=="vaela_seedlings"or id=="nyra_stonecharts"then task.RequiresRegionalCombat=true end
 task[row[5]]=row[6];Content.Journal[id]=task;table.insert(Content.JournalOrder,id)
end
-- Regional contracts use committed encounter events; no retroactive kill credit.
Content.RegionalCombatAvailable=false
local regionalContracts:{{any}}={
 {"greenwood_watch","Beyond the Greenwood Dock","Defeat two Greenwood Scouts after accepting Ghar's contract. Bring companions and a healer.","GreenwoodScout",2,"company_reinforcement",20,15},
 {"greenwood_captain","The Forest Captain","Defeat the Forest Captain after accepting this contract. Leave the marked attack areas.","ForestCaptain",1,"greenwood_watch",35,25},
 {"ironveil_watch","Reclaim the Quarry Road","Defeat two Quarry Raiders after accepting Ghar's contract.","QuarryRaider",2,"greenwood_captain",30,25},
 {"ironveil_guardian","The Quarry Guardian","Defeat the Quarry Guardian after accepting this contract. Watch for the hammer and fault line.","QuarryGuardian",1,"ironveil_watch",50,40},
 {"ashen_watch","Through the Ashen Gate","Defeat two Arcane Sentinels after accepting Ghar's contract.","ArcaneSentinel",2,"ironveil_guardian",40,35},
 {"ashen_warden","Silence the Warden","Defeat the Arcane Warden after accepting this contract. Use the safe center of Hollow Nova.","ArcaneWarden",1,"ashen_watch",70,60},
}
for _,row in ipairs(regionalContracts) do
 local id=row[1]
 Content.Journal[id]={Id=id,Name=row[2],Description=row[3],Event=row[4],Count=row[5],Requires=row[6],Gold=row[7],XP=row[8],Category="NPC",NPC="Ghar",RequiresRegionalCombat=true}
 table.insert(Content.JournalOrder,id)
end
-- Exploration work for the friendly Orcs; counts only the named regional node.
local regionalSupplies:{{string}}={
 {"borga_greenwood_timber","Timber Beyond the Harbour","Gather timber twice at the Greenwood log pile after accepting Borga's request. Return to Borga; keep the gathered materials.","Borga","greenwood_wood","borga_hearth"},
 {"mogra_greenwood_herbs","Leaves of the Greenwood","Gather herbs twice at the Greenwood herb patch after accepting Mogra's request. Return to Mogra; keep the gathered materials.","Mogra","greenwood_herbs","mogra_gathering"},
 {"rukk_ironveil_stone","Stone Worth Shaping","Gather stone twice at the Ironveil stone outcrop after accepting Rukk's request. Return to Rukk; keep the gathered materials.","Rukk","ironveil_stone","rukk_practice"},
 {"rukk_ironveil_ore","Iron Under the Veil","Gather ore twice at the Ironveil ore vein after accepting Rukk's request. Return to Rukk; keep the gathered materials.","Rukk","ironveil_ore","rukk_ironveil_stone"},
 {"mogra_ashen_herbs","Life Among the Ashes","Gather herbs twice at the Ashen herb patch after accepting Mogra's request. Return to Mogra; keep the gathered materials.","Mogra","ashen_herbs","mogra_greenwood_herbs"},
 {"borga_ashen_stone","A Hearth That Endures","Gather stone twice at the Ashen stone outcrop after accepting Borga's request. Return to Borga; keep the gathered materials.","Borga","ashen_stone","borga_greenwood_timber"},
}
for _,row in ipairs(regionalSupplies) do
 local id=row[1];Content.Journal[id]={Id=id,Name=row[2],Description=row[3],NPC=row[4],Event="Gather:"..row[5],Requires=row[6],Category="NPC",Count=2,Gold=8,XP=6,RequiresRegionalCombat=true}
 table.insert(Content.JournalOrder,id)
end
Content.Dispatch={
 woodland={Id="woodland",Name="Woodland Supply Route",Duration=180,BaseChance=90,PerLevel=1,DeathOnFailure=0,InjuryOnFailure=0,Gold=8,XP=10,Items={{Id="timber",Quantity=6}},X=.23,Y=.4},
 quarry={Id="quarry",Name="Old Quarry Expedition",Duration=300,BaseChance=45,PerLevel=2,DeathOnFailure=5,InjuryOnFailure=45,Gold=30,XP=30,Items={{Id="stone",Quantity=10},{Id="iron_ore",Quantity=5}},X=.7,Y=.3},
 ruins={Id="ruins",Name="Ruins Reconnaissance",Duration=600,BaseChance=30,PerLevel=2,DeathOnFailure=10,InjuryOnFailure=60,Gold=65,XP=50,Items={{Id="iron_ingot",Quantity=3},{Id="herb",Quantity=8}},X=.62,Y=.74},
}
Content.DispatchOrder={"woodland","quarry","ruins"}
Content.Elixir={Gold=1000,DeveloperProductId=0}
function Content.RosterCapacity(data: any): number
 local housing=0
 for _,b in pairs(data.expansion and data.expansion.buildings or {}) do if b.kind=="quarters" then housing=b.level or 1 end end
 return math.min(Content.Limits.Roster,data.personalGuild.buildings.guildHall*5,5+housing*5)
end
-- UAT equipment extends existing IDs; all additions remain account-bound.
Content.Items.watchblade={Id="watchblade",Name="Watchblade",Kind="Weapon",Slot="weapon",Health=0,Attack=5,Defense=1,Price=90,HallLevel=3,Description="An offensive blade that keeps a small defensive edge.",Tint={185,135,73},Class="Warrior"}
table.insert(Content.ItemOrder,"watchblade")
Content.Items.oathblade={Id="oathblade",Name="Oathblade",Kind="Weapon",Slot="weapon",Health=0,Attack=3,Defense=2,Price=85,HallLevel=3,Description="A defensive sword for holding the frontline.",Tint={97,158,195},Class="Knight"}
table.insert(Content.ItemOrder,"oathblade")
Content.Items.yew_longbow={Id="yew_longbow",Name="Yew Longbow",Kind="Weapon",Slot="weapon",Health=2,Attack=5,Defense=0,Price=90,HallLevel=3,Description="A stronger bow with a small vitality bonus.",Tint={126,165,85},Class="Archer"}
table.insert(Content.ItemOrder,"yew_longbow")
Content.Items.tide_staff={Id="tide_staff",Name="Tide Staff",Kind="Weapon",Slot="weapon",Health=0,Attack=5,Defense=1,Price=95,HallLevel=3,Description="Arcane offense with a protective ward.",Tint={81,186,204},Class="Mage"}
table.insert(Content.ItemOrder,"tide_staff")
Content.Items.dawn_crozier={Id="dawn_crozier",Name="Dawn Crozier",Kind="Weapon",Slot="weapon",Health=5,Attack=4,Defense=0,Price=95,HallLevel=3,Description="Supports stronger healing and the healer's survival.",Tint={225,193,114},Class="Priest"}
table.insert(Content.ItemOrder,"dawn_crozier")
Content.Items.scout_coat={Id="scout_coat",Name="Scout Coat",Kind="Armor",Slot="armor",Health=6,Attack=0,Defense=2,Price=60,HallLevel=2,Description="Light frontline protection for Warriors and Archers.",Tint={98,131,79},Classes={Warrior=true,Archer=true}}
table.insert(Content.ItemOrder,"scout_coat")
Content.Items.runewoven_mantle={Id="runewoven_mantle",Name="Runewoven Mantle",Kind="Armor",Slot="armor",Health=10,Attack=0,Defense=2,Price=72,HallLevel=3,Description="A reinforced mantle for casters under pressure.",Tint={101,106,168},Classes={Mage=true,Priest=true}}
table.insert(Content.ItemOrder,"runewoven_mantle")
Content.Items.harbor_mail={Id="harbor_mail",Name="Harbor Mail",Kind="Armor",Slot="armor",Health=4,Attack=0,Defense=3,Price=50,HallLevel=2,Description="More armor, less vitality than heavier adventuring gear.",Tint={106,142,158},Class="Any"}
table.insert(Content.ItemOrder,"harbor_mail")
Content.Items.vanguard_harness={Id="vanguard_harness",Name="Vanguard Harness",Kind="Armor",Slot="armor",Health=10,Attack=0,Defense=2,Price=70,HallLevel=3,Description="Trades plate defense for a larger health reserve.",Tint={166,116,74},Classes={Warrior=true,Knight=true}}
table.insert(Content.ItemOrder,"vanguard_harness")
Content.Items.pilgrim_robes={Id="pilgrim_robes",Name="Pilgrim Robes",Kind="Armor",Slot="armor",Health=12,Attack=0,Defense=0,Price=50,HallLevel=2,Description="A large health reserve without an armor bonus.",Tint={194,179,142},Class="Any"}
table.insert(Content.ItemOrder,"pilgrim_robes")
Content.Items.sentinel_seal={Id="sentinel_seal",Name="Sentinel Seal",Kind="Accessory",Slot="accessory",Health=0,Attack=0,Defense=2,Price=45,HallLevel=2,Description="Choose defense instead of offensive or vitality jewelry.",Tint={129,159,178},Class="Any"}
table.insert(Content.ItemOrder,"sentinel_seal")
Content.Items.hunters_token={Id="hunters_token",Name="Hunter's Token",Kind="Accessory",Slot="accessory",Health=2,Attack=2,Defense=0,Price=55,HallLevel=2,Description="Attack and a little vitality for physical skirmishers.",Tint={131,170,83},Classes={Warrior=true,Archer=true}}
table.insert(Content.ItemOrder,"hunters_token")
Content.Items.focus_prism={Id="focus_prism",Name="Focus Prism",Kind="Accessory",Slot="accessory",Health=0,Attack=2,Defense=1,Price=60,HallLevel=3,Description="A caster focus that trades vitality for attack and defense.",Tint={129,114,198},Classes={Mage=true,Priest=true}}
table.insert(Content.ItemOrder,"focus_prism")
Content.Items.wardstone={Id="wardstone",Name="Wardstone",Kind="Accessory",Slot="accessory",Health=4,Attack=0,Defense=1,Price=45,HallLevel=2,Description="Balanced vitality and armor; less health than a Vitality Charm.",Tint={94,175,163},Class="Any"}
table.insert(Content.ItemOrder,"wardstone")
-- Explicit allowlist; all existing equipment is account-bound and cannot be listed.
local tradable={stone=3,timber=4,iron_ore=6,iron_ingot=20,herb=5}
for id,item in pairs(Content.Items) do item.Tradable=tradable[id]~=nil;item.BasePrice=tradable[id] end
return Content
