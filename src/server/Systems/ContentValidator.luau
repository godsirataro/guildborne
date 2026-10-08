--!strict
return function(content: any, util: any)
	local function check(condition: any, message: string)
		assert(condition, "Invalid content: " .. message)
	end
	local function catalog(entries: any, order: any, expected: number)
		check(util.count(entries) == expected and #order == expected, "catalog count")
		local seen = {}
		for key, definition in pairs(entries) do
			check(definition.Id == key and not seen[definition.Id], "duplicate/mismatched ID")
			seen[definition.Id] = true
		end
		local ordered = {}
		for _, key in ipairs(order) do check(entries[key] and not ordered[key], "order reference"); ordered[key] = true end
	end
	catalog(content.Items, content.ItemOrder, 30)
	catalog(content.Adventurers, content.AdventurerOrder, 5)
	catalog(content.HeroTemplates,content.HeroTemplateOrder,15)
	local templateNames={};local templatePoolIds={}
	for _,class in ipairs(content.AdventurerOrder) do
		local pool=content.HeroTemplatePools[class];check(type(pool)=="table" and #pool==3,"three hero templates per class")
		for _,id in ipairs(pool) do
			local template=content.HeroTemplates[id]
			check(template and template.Class==class and template.VisualId==id and id:match("^"..string.lower(class).."_0[123]$"),"hero template class/visual binding")
			check(type(template.Name)=="string" and #template.Name>0 and #template.Name<=32 and not templateNames[template.Name] and not templatePoolIds[id],"unique hero template identity")
			templateNames[template.Name]=true;templatePoolIds[id]=true
		end
	end
	catalog(content.Quests, content.QuestOrder, 3)
	check(content.Limits.Party == 5 and content.Limits.Roster >= content.Limits.Party, "party/roster limits")
	check(util.count(content.Enemies) == 1, "one enemy required")
	for _, item in pairs(content.Items) do
		check(item.Kind == "Material" or item.Kind == "Weapon" or item.Kind == "Armor" or item.Kind == "Accessory", "item kind")
		if item.Kind~="Material" then
			check(item.Slot==({Weapon="weapon",Armor="armor",Accessory="accessory"})[item.Kind],"equipment slot")
			check(util.integer(item.Price,1,content.Limits.Gold),"shop price")
			check(item.HallLevel==nil or util.integer(item.HallLevel,1,20),"item Hall gate")
			check(item.Tradable==false,"equipment must remain bound")
			check(item.Class=="Any" or content.Adventurers[item.Class] or type(item.Classes)=="table","equipment compatibility")
			if item.Classes then for class,allowed in pairs(item.Classes) do check(content.Adventurers[class] and allowed==true,"equipment class") end end
			for _,key in ipairs({"Health","Attack","Defense"}) do check(item[key]==nil or util.integer(item[key],0,100),"equipment bonus") end
		end
		if item.Kind == "Weapon" then check(content.Adventurers[item.Class] and util.integer(item.Attack, 1, 100), "weapon class/stats") end
	end
	for _, recruit in pairs(content.Adventurers) do
		check(type(content.Roles[recruit.Class]) == "string", "class role")
		check(recruit.Id == recruit.Class and util.integer(recruit.Cost, 0, content.Limits.Gold), "recruit")
		for _, stat in pairs(recruit.Stats) do check(util.integer(stat, 1, 1000), "base stat") end
		if recruit.Weapon then check(content.Items[recruit.Weapon].Class == recruit.Class, "recruit weapon") end
	end
	for _, quest in pairs(content.Quests) do
		check(content.Enemies[quest.Enemy] and util.integer(quest.Duration, 1, 3600), "quest encounter")
		check(util.integer(quest.Requirements.PartySize, 1, content.Limits.Party), "party requirement")
		if quest.Requirements.FirstClear then check(content.Quests[quest.Requirements.FirstClear], "quest prerequisite") end
		for _, reward in ipairs({ quest.First, quest.Repeat }) do
			check(util.integer(reward.Gold, 0, content.Limits.Gold) and util.integer(reward.XP, 0, content.Limits.XP), "reward numbers")
			for _, item in ipairs(reward.Items) do check(content.Items[item.Id] and util.integer(item.Quantity, 1, 100), "reward reference") end
		end
	end
	check(content.Hall.From == 1 and content.Hall.To == 2 and util.integer(content.Hall.Gold, 1, content.Limits.Gold), "Hall")
	check(content.Quests[content.Hall.RequiredQuest], "Hall prerequisite")
	for itemId, quantity in pairs(content.Hall.Materials) do check(content.Items[itemId].Kind == "Material" and util.integer(quantity, 1, content.Limits.Stack), "Hall material") end
	for level=1,9 do local def=content.HallUpgrades[level];check(def and def.From==level and def.To==level+1,"Hall progression") end
	for _,weights in ipairs(content.Tavern.Odds) do local total=0;check(#weights==#content.Tavern.Ranks,"rank odds")
		for _,n in ipairs(weights) do check(util.integer(n,0,10000),"rank weight");total+=n end;check(total==10000,"rank probability total") end
	catalog(content.Journal,content.JournalOrder,37)
	local events={VisitGuild=true,Goblin=true,["Gather:wood"]=true,["Gather:stone"]=true,["Gather:ore"]=true,["Gather:herbs"]=true,["Craft:iron_ingot"]=true,CraftEquipment=true,Equip=true,EnterTower=true}
	for _,node in ipairs({"greenwood_wood","greenwood_herbs","ironveil_stone","ironveil_ore","ashen_herbs","ashen_stone"}) do events["Gather:"..node]=true end
	local goals={Forge=true,Hall2=true,Roster2=true,LearnedSkill=true}
	for _,event in ipairs({"GreenwoodScout","ForestCaptain","QuarryRaider","QuarryGuardian","ArcaneSentinel","ArcaneWarden"}) do events[event]=true end
	for id,def in pairs(content.Journal) do
		check(not def.NPC or content.QuestNPCs[def.NPC],"journal NPC reference")
		check(util.integer(def.Count,1,100),"journal objective count")
		check(util.integer(def.Gold,0,1000) and util.integer(def.XP,0,1000),"journal rewards")
		check((if def.Event then 1 else 0)+(if def.StateGoal then 1 else 0)+(if def.Item then 1 else 0)==1,"journal objective mode")
		check(not def.Event or events[def.Event],"journal event")
		check(not def.StateGoal or goals[def.StateGoal],"journal state goal")
		check(not def.Item or content.Items[def.Item],"journal delivery item")
		local seen={[id]=true};local current=def.Requires
		while current do check(content.Journal[current] and not seen[current],"journal prerequisite cycle/reference");seen[current]=true;current=content.Journal[current].Requires end
	end
	for _,def in pairs(content.Dispatch) do
		check(util.integer(def.Duration,1,3600) and util.integer(def.BaseChance,0,100),"dispatch duration/chance")
		check(def.DeathOnFailure+def.InjuryOnFailure<=100,"dispatch consequences")
		for _,item in ipairs(def.Items) do check(content.Items[item.Id] and util.integer(item.Quantity,1,100),"dispatch reward") end
	end
	return true
end
