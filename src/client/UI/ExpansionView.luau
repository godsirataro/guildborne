--!strict
local Rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
local AdvancementCopy=require(game.ReplicatedStorage.Shared.Config.ClassAdvancementCopy)
local SkillTree=require(script.Parent.SkillTreeView)
local SkillAvailability=require(script.Parent.SkillAvailability)
local ClassBadge=require(script.Parent.ClassBadge)
local CraftingState=require(game.ReplicatedStorage.Shared.Data.CraftingViewState)
local ItemViewport=require(script.Parent.ItemViewport)
return function(ui: any)
	local drawFurniture=require(script.Parent.FurnitureView)(ui)
	local drawStatus=require(script.Parent.StatusPointView)(ui)
	local actorId="player";local confirm: string?=nil;local layoutSlot=1
	local T,card,text,button=ui.T,ui.card,ui.text,ui.button
	local function costs(values: any,catalog: any): string
		local ids={};for id in pairs(values) do table.insert(ids,id) end;table.sort(ids)
		local out={};for _,id in ipairs(ids) do table.insert(out,T(catalog.Items[id].Name).." ×"..values[id]) end;return table.concat(out," · ")
	end
	return function(tab: string,data: any,catalog: any,busy: boolean)
		if tab=="Furniture" then drawFurniture(data,catalog,busy);return end
		local e=data.expansion
		local head=card(ui.scroll,tab)
		button(head,"Back to Guild",not busy,function() ui.navigate("Guild") end)
		if tab=="Layouts" then
			button(head,"Back to Base",not busy,function()ui.navigate("Base")end)
			local layout=e.layouts and e.layouts[tostring(layoutSlot)]
			button(head,T("Layout slot: {slot}",{slot=layoutSlot}).." · "..T(if layout then "Saved" else "Empty"),not busy,function()
				layoutSlot=layoutSlot%3+1;confirm=nil;ui.render(true)
			end).Name="LayoutSlot"
			text(head,"Layouts use your existing buildings. Buildings outside the chosen layout return to storage.",15)
			local saveKey="save-layout:"..layoutSlot
			button(head,if layout and confirm==saveKey then "Confirm overwrite layout" else "Save current layout",not busy,function()
				if layout and confirm~=saveKey then confirm=saveKey;ui.render() else confirm=nil;ui.act("SaveBuildLayout",{slot=layoutSlot}) end
			end).Name="SaveBuildLayout"
			button(head,"Apply saved layout",not busy and layout~=nil,function()ui.act("ApplyBuildLayout",{slot=layoutSlot})end).Name="ApplyBuildLayout"
			local deleteKey="delete-layout:"..layoutSlot
			button(head,if confirm==deleteKey then "Confirm delete layout" else "Delete saved layout",not busy and layout~=nil,function()
				if confirm~=deleteKey then confirm=deleteKey;ui.render() else confirm=nil;ui.act("DeleteBuildLayout",{slot=layoutSlot}) end
			end).Name="DeleteBuildLayout"
			if layout then
				local hall=e.layoutHalls and e.layoutHalls[tostring(layoutSlot)]
				if hall==false then text(head,T("Guild Hall").." · "..T("Original Hall site"),15)
				elseif hall then text(head,T("Guild Hall").." · ("..hall.x..", "..hall.z..") · "..hall.rotation*90 .."°",15) end
				local ids={};for id in pairs(layout) do table.insert(ids,id) end;table.sort(ids)
				if #ids==0 then text(head,"This layout stores all utility buildings.",16) end
				for _,id in ipairs(ids) do
					local b=e.buildings[id] or (e.storage and e.storage[id]);local p=layout[id]
					text(head,T(if b then Rules.Buildings[b.kind].Name else "Missing building").." · "..id.." · ("..p.x..", "..p.z..") · "..p.rotation*90 .."°",15)
				end
				local furnishings=e.layoutFurniture and e.layoutFurniture[tostring(layoutSlot)]
				if furnishings then local count=0;for _ in pairs(furnishings) do count+=1 end;text(head,T("Furniture")..": "..count,15) end
			end
		elseif tab=="Base" then
			button(head,"Guild land",not busy,function()ui.navigate("Land")end).Name="OpenLand"
			button(head,"Layouts",not busy,function()ui.navigate("Layouts")end).Name="OpenLayouts"
			button(head,"Building themes",not busy,function()ui.navigate("Themes")end).Name="OpenThemes"
			button(head,"Furniture",not busy,function()ui.navigate("Furniture")end).Name="OpenFurniture"
			button(head,"Move Guild Hall",not busy,function()ui.build(data,"guildHall",nil)end).Name="MoveGuildHall"
			text(head,"Gather nearby resources in the world. Green previews fit; the middle access lane stays clear.",16)
			for _,id in ipairs({"timber","stone","iron_ore","herb","iron_ingot"}) do text(head,T(catalog.Items[id].Name)..": "..(data.inventory.stacks[id] or 0),16) end
			for _,kind in ipairs(Rules.BuildingOrder) do
				local def=Rules.Buildings[kind];local frame=card(ui.scroll,def.Name);frame.Name="Building_"..kind;local owned: string?=nil;local stored:string?=nil
				for id,b in pairs(e.buildings) do if b.kind==kind then owned=id end end
				for id,b in pairs(e.storage or {}) do if b.kind==kind then stored=id end end
				text(frame,({warehouse="Raises gathering stock ceiling from 100 to 200 per resource.",quarters="Recovery at rest is 50% faster. Unlocks prestige trials.",forge="Turns gathered materials into ingots and equipment."})[kind],16)
				text(frame,costs(def.Cost,catalog),16)
				if owned then
					local id=owned;local b=e.buildings[id]
					if kind=="quarters" then
						local level=b.level or 1;text(frame,T("Housing level")..": "..level.." · "..T("Roster capacity")..": "..data.rosterCapacity,16)
						text(frame,T("Upgrade cost")..": "..(60*level).." Gold · "..(8*level).." Timber · "..(6*level).." Stone",14)
						button(frame,"Upgrade housing",not busy,function() ui.act("UpgradeQuarters",{buildingId=id}) end)
					end
					text(frame,"("..b.x..", "..b.z..") · "..b.rotation*90 .."°",14)
					button(frame,"Move building",not busy,function() ui.build(data,kind,id) end)
					local count=0;for _ in pairs(data.adventurers) do count+=1 end
					button(frame,"Store building",not busy and (kind~="quarters" or count<=5),function()ui.act("StoreBuilding",{buildingId=id})end).Name="Store_"..id
					if kind=="quarters" and count>5 then text(frame,"Housing must remain placed while more than five heroes are recruited.",14) end
					button(frame,if confirm==id then "Confirm dismantle · half materials returned" else "Dismantle · half materials returned",not busy,function()
						if confirm==id then confirm=nil;ui.act("DismantleBuilding",{buildingId=id}) else confirm=id;ui.render() end
					end)
				elseif stored then
					local id=stored;text(frame,"Stored buildings keep their upgrades. Place them again without paying materials.",16)
					button(frame,"Place stored building",not busy,function()ui.build(data,kind,id)end).Name="Restore_"..id
				else button(frame,"Preview building",not busy,function() ui.build(data,kind,nil) end).Name="Preview" end
			end
			local forge=card(ui.scroll,"Crafting")
			text(forge,"Recipes consume the listed materials and create one item.",16)
			for _,id in ipairs(Rules.RecipeOrder) do
				local r=Rules.Recipes[id];local def=catalog.Items[r.Item]
				local state=CraftingState(data,catalog,Rules,id,busy)
				local recipeCard=card(ui.scroll,def.Name);recipeCard.Name="Recipe_"..id
				local compact=ui.scroll.AbsoluteSize.Y<180;local size=if compact then 48 else 64
				local row=Instance.new("Frame");row.Name="RecipeIngredients";row.BackgroundTransparency=1;row.Size=UDim2.new(1,0,0,size);row.AutomaticSize=Enum.AutomaticSize.Y;row.Parent=recipeCard
				local preview=ItemViewport(row,r.Item);if preview then preview.Size=UDim2.fromOffset(size,size) end
				local materials=Instance.new("Frame");materials.BackgroundTransparency=1;materials.Position=UDim2.fromOffset(size+12,0);materials.Size=UDim2.new(1,-size-12,0,0);materials.AutomaticSize=Enum.AutomaticSize.Y;materials.Parent=row
				local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,4);list.Parent=materials
				for _,material in ipairs(state.materials) do
					text(materials,T("{item}: {owned}/{needed}",{item=T(catalog.Items[material.id].Name),owned=material.owned,needed=material.needed}),if compact then 14 else 16).Name="Material_"..material.id
				end
				text(recipeCard,def.Description,14)
				if def.Kind~="Material" then text(recipeCard,T("HP {hp} / Attack {attack} / Defense {defense}",{hp=def.Health or 0,attack=def.Attack or 0,defense=def.Defense or 0}),14) end
				local reason=if state.problem then T(state.problem,state.params) else nil
				button(recipeCard,reason or T("Craft").." · "..T(def.Name),state.canCraft,function() ui.act("CraftItem",{recipeId=id}) end).Name="Craft_"..id
			end
		elseif tab=="Skills" or tab=="Status" then
			local actors={"player"};local ids={};for id in pairs(data.adventurers) do table.insert(ids,id) end;table.sort(ids);for _,id in ipairs(ids) do table.insert(actors,id) end
			local a=Rules.actor(data,actorId);if not a then actorId="player";a=data.character end
			button(head,(if actorId=="player" then T("Your character") else T(a.name).." · "..T(a.classId).." ["..a.rank.."] · "..actorId),not busy,function() actorId=actors[(table.find(actors,actorId) or 0)%#actors+1];confirm=nil;ui.render(true) end).Name="SkillActor"
			if not a.classId then text(head,"Select a class in Guild");return end
			ClassBadge(head,a.classId,T)
			if tab=="Status" then drawStatus(data,catalog,actorId,busy);return end
			if catalog.StatusAllocationAvailable then button(head,"Status points",not busy,function()ui.navigate("Status")end).Name="OpenStatus" end
			local build=Rules.build(data,actorId)
			local skillBlocked=busy or (e.tower.active ~= nil and e.tower.active.state == "Fighting")
			text(head,T(a.classId).." · "..T(if build.path then Rules.Paths[build.path].Name else "Class 1").." · Lv"..a.level,18)
			text(head,T("Skill points")..": "..(a.level-1-Rules.spent(build)),16)
			text(head,"Use the combat buttons: starter art, Class 2 art, and Class 3 art. On keyboard: Q, Z, and X. Learn each branch art to unlock its slot.",16)
			text(head,if catalog.StatusAllocationAvailable then "Reset SP and AP for free in Status points near your Guild Hall." else "Resetting learned skills costs 10 Gold.",16)
			SkillTree(head,build,a.level,skillBlocked,T,function(id: string)
				ui.act("LearnSkill",{actorId=actorId,skillId=id})
			end)
			for _,id in ipairs(Rules.SkillOrder) do
				local d=Rules.Skills[id];local frame=card(ui.scroll,id)
				text(frame,T("Cost")..": "..d.Cost.." · "..T("Class tier")..": "..(d.Tier or 1)..(if d.Requires then " · "..T("Requires")..": "..T(d.Requires) else ""),14)
				text(frame,({vitality="+6 maximum HP",focus="+2 Attack; excludes Ward",ward="+3 Defense; excludes Focus",path_art="Unlock your Class 2 active art",master_art="Unlock your Class 3 active art"})[id],16)
				local reason,available=SkillAvailability(build,a.level,id,skillBlocked)
				button(frame,reason,available,function() ui.act("LearnSkill",{actorId=actorId,skillId=id}) end).Name="Learn_"..id
			end
			local loadout=card(ui.scroll,"Skill loadout")
			for _,id in ipairs(Rules.allowedSkills(build,catalog.Character.Classes[a.classId].SkillId)) do
				button(loadout,T(if Rules.Abilities[id] then Rules.Abilities[id].Name else "Starter skill")..(if build.equipped==id then " ✓" else ""),not busy,function() ui.act("EquipSkill",{actorId=actorId,skillId=id}) end)
			end
			if not catalog.StatusAllocationAvailable then button(loadout,if confirm=="reset" then "Confirm reset · 10 Gold" else "Reset skills · 10 Gold",not busy,function() if confirm=="reset" then confirm=nil;ui.act("ResetSkills",{actorId=actorId}) else confirm="reset";ui.render() end end) end
			local advancement=card(ui.scroll,"Class advancement")
			text(advancement,AdvancementCopy.header(data.settings.language,Rules.advancementLevel(data,2)),16)
			if catalog.StatusAllocationAvailable or Rules.usesNoviceProgression(data) then text(advancement,"Advancing refunds your spent skill and attribute points. Assign them again after choosing your class.",15) end
			if not data.quests.firstClears.quarry_patrol then
				text(advancement,"Complete and claim Trail Watch, Timber Escort, then Quarry Patrol in Quests. The mine story and borrowed trial do not replace these expeditions.",15)
				button(advancement,"Open required expeditions",not busy,function()ui.navigate("Quests")end).Name="OpenAdvancementQuests"
			end
			local pathIds={};for id,path in pairs(Rules.Paths) do if path.Class==a.classId and path.Tier==build.tier+1 and (not path.Parent or path.Parent==build.path) then table.insert(pathIds,id) end end;table.sort(pathIds)
			for _,id in ipairs(pathIds) do
				local path=Rules.Paths[id];text(advancement,T(path.Name).." · "..T(path.Prestige or "Standard").." · "..T("Tower floor").." "..path.Floor,16)
				local art=Rules.Abilities[path.Skill]
				text(advancement,T("Art: {name}",{name=T(art.Name)}),16)
				text(advancement,T("Cooldown: {seconds}s · Range: {range} studs",{seconds=art.Cooldown,range=art.Range}),14)
				text(advancement,T("Level: {current} / {required}",{current=a.level,required=Rules.advancementLevel(data,path.Tier)}).." · "..T("Quarry Patrol")..": "..T(if data.quests.firstClears.quarry_patrol then "Complete" else "Incomplete"),14)
				if path.Floor>0 then text(advancement,T("Tower progress: {current} / {required}",{current=e.tower.highest,required=path.Floor}),14) end
				if path.Prestige then text(advancement,"Requires Hero Quarters. Prestige trades damage or health for a different role.",14) end
				if path.Secret then text(advancement,"Secret clue: gather all four resources and conquer floor 10.",14) end
				local problem=Rules.advanceProblem(data,a,build,id)
				local reasons={AdvancementLocked="Complete the listed level, quest and Tower requirements.",QuartersRequired="Build Hero Quarters first.",SecretUndiscovered="Gather wood, stone, ore and herbs to reveal this path."}
				local label=if skillBlocked then T("Unavailable") elseif problem then T(reasons[problem] or "Unavailable") else T(if confirm==id then "Confirm class" else "Advance")..": "..T(path.Name)
				button(advancement,label,not skillBlocked and problem==nil,function() if confirm==id then confirm=nil;ui.act("AdvanceClass",{actorId=actorId,pathId=id}) else confirm=id;ui.render() end end).Name="Advance_"..id
			end
			if actorId=="player" then
				local race=card(ui.scroll,"Ancestry");text(race,"One permanent choice: Human balanced; Elf +1 Attack / -3 HP; Dwarf +3 HP / +1 Defense / -1 speed.",16)
				for _,id in ipairs({"Human","Elf","Dwarf"}) do button(race,T(id)..(if data.character.raceId==id then " ✓" else "")..(if confirm==id then " · "..T("Confirm") else ""),not busy and not e.raceChosen,function() if confirm==id then confirm=nil;ui.act("SelectRace",{raceId=id}) else confirm=id;ui.render() end end) end
			end
		else
			local t=e.tower;local run=t.active
			text(head,T("Highest floor")..": "..t.highest.." / 10",18)
			text(head,"Clear all enemies to earn first-clear or repeat rewards. Bosses guard floors 5 and 10. Rest between floors; checkpoint 5 unlocks entry at 6.",16)
			text(head,"Falling ends the attempt. Rejoining restarts the current fight without granting rewards. Leaving keeps cleared floors.",16)
			if run then
				text(head,T("Tower floor").." "..run.floor.." · "..T(run.state),18)
				button(head,"Enter floor",not busy and run.state=="Ready",function() ui.act("EnterTowerFloor");ui.explore() end)
				button(head,"Leave tower",not busy,function() ui.act("LeaveTower") end)
			else
				button(head,"Begin at floor 1",not busy,function() ui.act("StartTower",{floor=1}) end)
				button(head,"Resume at floor 6",not busy and t.checkpoint==5,function() ui.act("StartTower",{floor=6}) end)
			end
		end
	end
end
