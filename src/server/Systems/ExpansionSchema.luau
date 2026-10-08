--!strict
return function(content: any,util: any,rules: any,landPlacement:any?,themes:any?)
	return function(data: any)
		local e=data.expansion;assert(type(e)=="table" and type(e.raceChosen)=="boolean")
		if themes then assert(themes.validate(e)) end
		assert(rules.Races[data.character.raceId] and util.integer(e.nextBuilding,1,1000000000))
		assert(e.storage==nil or type(e.storage)=="table")
		assert(util.count(e.buildings)+util.count(e.storage or {})<=8)
		local kinds={}
		local function position(p:any):boolean return type(p)=="table" and rules.gridCoordinate(p.x) and rules.gridCoordinate(p.z) and util.integer(p.rotation,0,3) end
		assert(e.furniture==nil or type(e.furniture)=="table")
		assert(e.nextFurniture==nil or util.integer(e.nextFurniture,1,1000000000))
		assert(util.count(e.furniture or {})<=rules.FurnitureLimit)
		for id,b in pairs(e.furniture or {}) do
			assert(type(id)=="string" and id:match("^f:%d+$") and tonumber(id:sub(3))<(e.nextFurniture or 1))
			assert(id=="f:"..tostring(tonumber(id:sub(3))) and tonumber(id:sub(3))>=1)
			assert(type(b)=="table" and rules.Furniture[b.kind] and type(b.stored)=="boolean" and position(b))
			for key in pairs(b) do assert(key=="kind" or key=="stored" or key=="x" or key=="z" or key=="rotation" or key=="theme") end
		end
		assert(rules.furniturePlacement(data,landPlacement))
		if e.hallPosition then
			assert(position(e.hallPosition) and landPlacement)
			assert(landPlacement(data,"guildHall",e.hallPosition.x,e.hallPosition.z,e.hallPosition.rotation,nil,true))
		end
		for id,b in pairs(e.buildings) do
			assert(type(id)=="string" and id:match("^b:%d+$") and tonumber(id:sub(3))<e.nextBuilding)
			assert(rules.Buildings[b.kind])
			assert(b.level==nil or (b.kind=="quarters" and util.integer(b.level,1,9)))
			local valid=if landPlacement then landPlacement(data,b.kind,b.x,b.z,b.rotation,id,true) else rules.placement(e.buildings,b.kind,b.x,b.z,b.rotation,id)
			assert(not kinds[b.kind] and valid);kinds[b.kind]=true
		end
		for id,b in pairs(e.storage or {}) do
			assert(type(id)=="string" and id:match("^b:%d+$") and tonumber(id:sub(3))<e.nextBuilding and not e.buildings[id])
			assert(type(b)=="table" and rules.Buildings[b.kind] and not kinds[b.kind]);kinds[b.kind]=true
			assert(b.level==nil or (b.kind=="quarters" and util.integer(b.level,1,9)))
			assert(rules.gridCoordinate(b.x) and rules.gridCoordinate(b.z) and util.integer(b.rotation,0,3))
		end
		for id,time in pairs(e.gatherReady) do assert(rules.Nodes[id] and util.integer(time,0,100000000000)) end
		assert(e.layouts==nil or type(e.layouts)=="table")
		assert(e.layoutHalls==nil or type(e.layoutHalls)=="table")
		assert(e.layoutFurniture==nil or type(e.layoutFurniture)=="table")
		for slot,items in pairs(e.layoutFurniture or {}) do
			assert(e.layouts and e.layouts[slot] and type(items)=="table" and util.count(items)<=rules.FurnitureLimit)
			for id,p in pairs(items) do
				assert(type(id)=="string" and id:match("^f:%d+$") and tonumber(id:sub(3))>=1 and tonumber(id:sub(3))<(e.nextFurniture or 1))
				assert(id=="f:"..tostring(tonumber(id:sub(3))) and position(p))
				for key in pairs(p) do assert(key=="x" or key=="z" or key=="rotation") end
			end
		end
		for slot,p in pairs(e.layoutHalls or {}) do assert(e.layouts and e.layouts[slot] and (p==false or position(p))) end
		assert(util.count(e.layouts or {})<=3)
		for slot,positions in pairs(e.layouts or {}) do
			assert(slot=="1" or slot=="2" or slot=="3")
			assert(type(positions)=="table" and util.count(positions)<=8)
			for id,p in pairs(positions) do
				assert(type(id)=="string" and id:match("^b:%d+$") and tonumber(id:sub(3))<e.nextBuilding)
				assert(type(p)=="table" and rules.gridCoordinate(p.x) and rules.gridCoordinate(p.z) and util.integer(p.rotation,0,3))
				for key in pairs(p) do assert(key=="x" or key=="z" or key=="rotation") end
			end
		end
		for id,value in pairs(e.gathered) do assert(rules.Nodes[id] and value==true) end
		for id,build in pairs(e.actors) do
			local actor=rules.actor(data,id);assert(actor and actor.classId and util.integer(build.tier,1,3))
			-- Preserve already-earned legacy promotions; AdvanceClass enforces current 30/70 gates.
			local path=build.path and rules.Paths[build.path]
			assert((build.tier==1 and not path) or (path and path.Tier==build.tier and path.Class==actor.classId and actor.level>=(if path.Tier==2 then 3 else 6)))
			for skill,value in pairs(build.skills) do
				local def=rules.Skills[skill];assert(def and value==true and (def.Tier or 1)<=build.tier and (not def.Requires or build.skills[def.Requires]))
			end
			assert(not (build.skills.focus and build.skills.ward) and rules.spent(build)<=actor.level-1)
			assert(not build.equipped or table.find(rules.allowedSkills(build,content.Character.Classes[actor.classId].SkillId),build.equipped))
		end
		local build=rules.build(data,"player");assert(data.character.tier==build.tier)
		if data.character.classId then
			assert(data.character.classPathId==(build.path or content.Character.Classes[data.character.classId].PathId))
		end
		local t=e.tower;assert(util.integer(t.highest,0,10) and (t.checkpoint==0 or t.checkpoint==5) and t.checkpoint<=t.highest and util.integer(t.nextRun,1,1000000000))
		if t.active then
			assert(t.active.id=="tower:"..(t.nextRun-1) and util.integer(t.active.floor,1,10) and t.active.floor<=t.highest+1)
			assert(t.active.state=="Ready" or t.active.state=="Fighting" or t.active.state=="Failed")
		end
	end
end
