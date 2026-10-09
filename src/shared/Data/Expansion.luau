--!strict
-- Shared, deterministic definitions and rules. No client result is trusted by the server.
local E: any = {}
E.Buildings={
	warehouse={Name="Warehouse",Width=2,Depth=2,Cost={timber=8,stone=4},Limit=1},
	quarters={Name="Hero Quarters",Width=2,Depth=2,Cost={timber=8,stone=6,herb=2},Limit=1},
	forge={Name="Blacksmith",Width=2,Depth=2,Cost={timber=6,stone=8,iron_ore=4},Limit=1},
}
E.BuildingOrder={"warehouse","quarters","forge"}
E.FurnitureLimit=32
E.Furniture={
	hearth_table={Name="Hearth Table",Width=1,Depth=.75,Height=3.3,Cost={timber=4}},
	hearth_chair={Name="Hearth Chair",Width=.5,Depth=.5,Height=3.8,Cost={timber=2}},
	welcome_bench={Name="Welcome Bench",Width=1,Depth=.5,Height=3.8,Cost={timber=3}},
	guild_bookcase={Name="Guild Bookcase",Width=.75,Depth=.5,Height=7,Cost={timber=6,herb=2}},
	woven_rug={Name="Compass Rug",Width=1,Depth=1,Height=.15,Cost={herb=4}},
	guild_banner={Name="Standing Guild Banner",Width=.5,Depth=.5,Height=7,Cost={timber=2,herb=3}},
	garden_planter={Name="Garden Planter",Width=.75,Depth=.5,Height=3.05,Cost={timber=3,herb=2}},
	crystal_lantern={Name="Crystal Lantern",Width=.5,Depth=.5,Height=5.85,Cost={stone=3,iron_ore=2}},
	display_plinth={Name="Display Plinth",Width=.5,Depth=.5,Height=3.1,Cost={stone=4}},
	hearth_bed={Name="Hearth Bed",Width=.75,Depth=1,Height=2.8,Cost={timber=5,herb=3}},
}
E.FurnitureOrder={"hearth_table","hearth_chair","welcome_bench","guild_bookcase","woven_rug","guild_banner","garden_planter","crystal_lantern","display_plinth","hearth_bed"}
E.HallFootprint={Name="Guild Hall",Width=4,Depth=3}
function E.footprint(kind:string):any return if kind=="guildHall" then E.HallFootprint else E.Buildings[kind] or E.Furniture[kind] end
E.Nodes={
	wood={Item="timber",X=30,Z=-20,Seconds=6},stone={Item="stone",X=30,Z=-10,Seconds=6},
	ore={Item="iron_ore",X=30,Z=4,Seconds=8},herbs={Item="herb",X=30,Z=28,Seconds=8},
	greenwood_wood={Item="timber",Region="Greenwood",QuestNode="wood",X=-35,Z=55,Seconds=12},
	greenwood_herbs={Item="herb",Region="Greenwood",QuestNode="herbs",X=35,Z=55,Seconds=12},
	ironveil_stone={Item="stone",Region="Ironveil",QuestNode="stone",X=-40,Z=70,Seconds=12},
	ironveil_ore={Item="iron_ore",Region="Ironveil",QuestNode="ore",X=40,Z=30,Seconds=14},
	ashen_herbs={Item="herb",Region="Ashen",QuestNode="herbs",X=-65,Z=20,Seconds=14},
	ashen_stone={Item="stone",Region="Ashen",QuestNode="stone",X=65,Z=20,Seconds=14},
}
E.Races={Human={Health=0,Attack=0,Defense=0},Elf={Health=-3,Attack=1,Defense=0},Dwarf={Health=3,Attack=0,Defense=1,Speed=-1}}
E.Paths={}
local branches: {[string]:{{any}}}={
	Warrior={{"berserker","Berserker","warlord","Warlord","cleave","Whirlwind","Area",2.1,8,8},{"duelist","Duelist","sword_saint","Sword Saint","lunge","Spirit Blade","Physical",2.8,9,6}},
	Knight={{"guardian","Guardian","fortress","Fortress","bulwark","Iron Oath","Guard",1,10,14},{"paladin","Paladin","holy_sentinel","Holy Sentinel","radiance","Dawn Verdict","Drain",1.8,9,8}},
	Archer={{"ranger","Ranger","beastwarden","Wild Warden","volley","Rain of Arrows","Area",1.6,9,23},{"sniper","Sniper","deadeye","Deadeye","snipe","Horizon Shot","Physical",3.4,12,30}},
	Mage={{"elementalist","Elementalist","archmage","Archmage","nova","Astral Storm","Area",2.1,10,22},{"spellblade","Spellblade","arcane_knight","Arcane Knight","arcane_slash","Rune Rupture","Drain",2.1,8,9}},
	Priest={{"cleric","Cleric","high_priest","High Priest","renewal","Sanctuary","Heal",2.8,8,25},{"oracle","Oracle","prophet","Prophet","judgment","Fate Unbound","Slow",2,9,22}},
}
E.Abilities={}
for class,list in pairs(branches) do
	for _,b in ipairs(list) do
		E.Paths[b[1]]={Name=b[2],Class=class,Tier=2,Skill=b[5],Level=30,Floor=0}
		E.Paths[b[3]]={Name=b[4],Class=class,Tier=3,Parent=b[1],Skill=b[5].."_master",Level=70,Floor=5}
		for tier=2,3 do
			local id=b[5]..(if tier==3 then "_master" else "")
			E.Abilities[id]={Id=id,Name=if tier==3 then b[6] else b[2].." Art",Class=class,Tier=tier,Effect=b[7],Multiplier=b[8]+(tier-2)*.5,Flat=8,
				Cooldown=b[9],Range=b[10],Duration=3,TargetType=if b[7]=="Heal" then "Ally" else "Enemy",Radius=10}
		end
	end
end
local specials: {{any}}={
	{"commander","Commander","Warrior","Epic","Guard",5},
	{"rune_knight","Rune Knight","Knight","Epic","Drain",5},
	{"bard","Bard","Priest","Epic","Heal",5},
	{"shadow_dancer","Shadow Dancer","Archer","Legendary","Drain",10},
}
for _,s in ipairs(specials) do
	E.Paths[s[1]]={Name=s[2],Class=s[3],Tier=3,Skill=s[1].."_art",Level=70,Floor=s[6],Prestige=s[4],Secret=s[1]=="shadow_dancer"}
	E.Abilities[s[1].."_art"]={Id=s[1].."_art",Name=s[2].." Art",Class=s[3],Tier=3,Group=s[1]=="bard" or s[1]=="commander",Effect=s[5],Multiplier=2.2,Flat=10,Cooldown=12,Range=22,Duration=4,TargetType=if s[5]=="Heal" then "Ally" else "Enemy",Radius=10}
end
E.Skills={vitality={Cost=1,Health=6},focus={Cost=1,Attack=2,Requires="vitality"},ward={Cost=1,Defense=3,Requires="vitality"},path_art={Cost=2,Requires="vitality",Tier=2},master_art={Cost=2,Requires="path_art",Tier=3}}
E.SkillOrder={"vitality","focus","ward","path_art","master_art"}
E.Recipes={iron_ingot={Name="Smelt Iron",Cost={iron_ore=3,stone=1},Item="iron_ingot"},guardian_plate={Name="Forge Guardian Plate",Cost={iron_ingot=2,timber=2},Item="guardian_plate"},vitality_charm={Name="Craft Vitality Charm",Cost={herb=5,stone=3},Item="vitality_charm"}}
E.Recipes.watchblade={Name="Craft Watchblade",Item="watchblade",HallLevel=3,Cost={iron_ingot=4,timber=4,stone=2}}
E.Recipes.oathblade={Name="Craft Oathblade",Item="oathblade",HallLevel=3,Cost={iron_ingot=4,stone=5}}
E.Recipes.yew_longbow={Name="Craft Yew Longbow",Item="yew_longbow",HallLevel=3,Cost={timber=12,iron_ingot=2,herb=4}}
E.Recipes.tide_staff={Name="Craft Tide Staff",Item="tide_staff",HallLevel=3,Cost={timber=6,iron_ingot=3,herb=6}}
E.Recipes.dawn_crozier={Name="Craft Dawn Crozier",Item="dawn_crozier",HallLevel=3,Cost={timber=6,iron_ingot=3,herb=8}}
E.Recipes.scout_coat={Name="Craft Scout Coat",Item="scout_coat",HallLevel=2,Cost={timber=6,herb=8,iron_ingot=2}}
E.Recipes.runewoven_mantle={Name="Craft Runewoven Mantle",Item="runewoven_mantle",HallLevel=3,Cost={herb=12,iron_ingot=3,stone=4}}
E.RecipeOrder={"iron_ingot","guardian_plate","vitality_charm","watchblade","oathblade","yew_longbow","tide_staff","dawn_crozier","scout_coat","runewoven_mantle"}
function E.new(): any return {buildings={},nextBuilding=1,gatherReady={},gathered={},actors={},tower={highest=0,checkpoint=0,nextRun=1},raceChosen=false} end
function E.actor(data: any,id: string): any return if id=="player" then data.character else data.adventurers[id] end
function E.build(data: any,id: string): any return data.expansion and data.expansion.actors[id] or {tier=1,skills={}} end
function E.spent(build: any): number local n=0;for id in pairs(build.skills) do n+=E.Skills[id].Cost end;return n end
function E.learnProblem(build: any,level: number,id: string): string?
	local node=E.Skills[id];if not node then return "InvalidSkill" end
	if build.skills[id] then return "AlreadyLearned" end
	if (node.Tier or 1)>build.tier or (node.Requires and not build.skills[node.Requires]) then return "SkillPrerequisite" end
	if E.spent(build)+node.Cost>level-1 then return "NoSkillPoints" end
	if (id=="ward" and build.skills.focus) or (id=="focus" and build.skills.ward) then return "SkillBranchConflict" end
	return nil
end
function E.usesNoviceProgression(data:any):boolean
 return data.progression~=nil and data.progression.ruleset=="guildborne.progression.2"
end
-- New-journey gates differ from already-shipped legacy progression. Do not rewrite saved paths.
function E.advancementLevel(data:any,tier:number):number
 local novice=E.usesNoviceProgression(data)
 return if tier==1 then 10 elseif tier==2 then (if novice then 35 else 30) else 70
end
-- Shared read-only readiness; the server still owns spatial and transaction checks.
function E.advanceProblem(data:any,actor:any,build:any,id:string):string?
 local path=E.Paths[id]
 if not path or path.Class~=actor.classId or path.Tier~=build.tier+1 or (path.Parent and path.Parent~=build.path) then return "InvalidClassPath" end
 local e=data.expansion
 if actor.level<E.advancementLevel(data,path.Tier) or not data.quests.firstClears.quarry_patrol or e.tower.highest<path.Floor then return "AdvancementLocked" end
 if path.Prestige then
  local quarters=false;for _,building in pairs(e.buildings) do if building.kind=="quarters" then quarters=true end end
  if not quarters then return "QuartersRequired" end
 end
 if path.Secret and not (e.gathered.wood and e.gathered.stone and e.gathered.ore and e.gathered.herbs) then return "SecretUndiscovered" end
 return nil
end
function E.gridCoordinate(value:any):boolean
	return type(value)=="number" and value==value and math.abs(value)<=100 and (value*4)%1==0
end
function E.furniturePlacement(data:any,validate:any):(boolean,string)
	local regions={}
	for id,b in pairs(data.expansion.furniture or {}) do if not b.stored then
		if not E.Furniture[b.kind] or not E.gridCoordinate(b.x) or not E.gridCoordinate(b.z)
			or type(b.rotation)~="number" or b.rotation%1~=0 or b.rotation<0 or b.rotation>3 then return false,"InvalidPlacement" end
		-- The east route grid includes surrounding ground; retain the narrower editable bounds per piece.
		if b.x>=0 and not E.placement({},b.kind,b.x,b.z,b.rotation) then return false,"InvalidPlacement" end
		regions[if b.x<0 then "west" else "east"]={id=id,b=b}
	end end
	-- Each region validation already checks every obstacle and entrance in that region.
	for _,entry in pairs(regions) do
		if not validate then return false,"InvalidPlacement" end
		local b=entry.b;local ok,reason=validate(data,b.kind,b.x,b.z,b.rotation,entry.id)
		if not ok then return false,reason end
	end
	return true,"OK"
end
function E.placement(buildings: any,kind: string,x: number,z: number,rotation: number,ignore: string?): boolean
	local def=E.footprint(kind);if not def or not E.gridCoordinate(x) or not E.gridCoordinate(z) or rotation%1~=0 or rotation<0 or rotation>3 then return false end
	local w,d=def.Width,def.Depth;if rotation%2==1 then w,d=d,w end
	if x<6 or x+w>12 or z< -4 or z+d>5 or (z<1 and z+d>0) then return false end
	for id,b in pairs(buildings) do if id~=ignore then
		local other=E.footprint(b.kind);if not other then return false end;local ow,od=other.Width,other.Depth;if b.rotation%2==1 then ow,od=od,ow end
		if x<b.x+ow and x+w>b.x and z<b.z+od and z+d>b.z then return false end
	end end
	return true
end
function E.bonuses(build: any,race: string?): any
	local r=E.Races[race or "Human"];local b={Health=r.Health,Attack=r.Attack,Defense=r.Defense,Speed=r.Speed or 0}
	for id in pairs(build.skills) do local d=E.Skills[id];for _,k in ipairs({"Health","Attack","Defense"}) do b[k]+=d[k] or 0 end end
	-- Prestige is specialization, not a universal upgrade.
	if build.path=="commander" or build.path=="bard" then b.Attack-=1;b.Defense+=2
	elseif build.path=="shadow_dancer" then b.Health-=6;b.Attack+=2 end
	return b
end
function E.allowedSkills(build: any,starter: string): any
	local ids={starter};local path=build.path and E.Paths[build.path]
	if path then
		if path.Tier==2 and build.skills.path_art then table.insert(ids,path.Skill) end
		if path.Tier==3 then
			local parent=path.Parent and E.Paths[path.Parent]
			if parent and build.skills.path_art then table.insert(ids,parent.Skill) end
			if build.skills.master_art then table.insert(ids,path.Skill) end
		end
	end
	return ids
end
-- Stable input slots: prestige arts stay in slot 3 even without a parent art.
function E.skillSlots(build: any,starter: string): {[number]: string}
 local slots: {[number]: string}={[1]=starter}
 for _,id in ipairs(E.allowedSkills(build,starter)) do
  if id~=starter then slots[if E.Abilities[id].Tier==3 then 3 else 2]=id end
 end
 return slots
end
return E
