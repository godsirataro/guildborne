--!strict
local W=require("../src/shared/Data/CityWaypoint")
return function(test: any,eq: any)
 test("earned Hall directions choose the nearest city guild portal and completed campaigns invent no NPC",function()
  local city=require("../src/shared/Config/City")
  local route=require("../src/shared/Data/QuestRoute")(city,{},W)
  local quest={kind="Campaign",focus="UpgradeGuildHall"}
  for _,stop in pairs(city.GuildPortalStops)do
   local target=route(quest,{Journal={}},stop.ReturnX,stop.ReturnZ)
   eq(target.kind,"Portal");eq(target.x,stop.X);eq(target.z,stop.Z);eq(target.name,stop.Name)
  end
  eq(route(quest,{Journal={}},500,1500).name,"Central City")
  eq(route({kind="CampaignComplete"},{Journal={}},0,-1100),nil)
 end)
	test("combat quest routes use catalog events and loaded markers, then return for turn-in",function()
		local city=require("../src/shared/Config/City");local rules=require("../src/shared/Data/Expansion")
		local util=require("../src/shared/Util/TableUtil");local content=util.copy(require("../src/server/Config/Content"));content.RegionalCombatAvailable=true
		content.Bestiary={Regions=require("../src/server/Systems/AdventureFieldGuide")(require("../src/server/Config/AdventureEncounters"),require("../src/server/Config/AdventureEnemyProfiles"),require("../src/server/Config/AdventureRewards"),require("../src/server/Systems/AdventureStats"),city.RegionOrder)}
		local loaded=true;local requested=nil
		local route=require("../src/shared/Data/QuestRoute")(city,rules,W,function(region,marker)requested={region,marker};return if loaded then {x=city.Regions[region].X+17,z=city.Regions[region].Z-23} else nil end)
		local count=0
		for id,def in pairs(content.Journal) do
			if def.RequiresRegionalCombat and not def.Event:match("^Gather:") then
				count+=1;local area,enemy
				for _,a in ipairs(content.Bestiary.Regions) do for _,e in ipairs(a.Entries) do if e.QuestEvent==def.Event then area=a;enemy=e end end end
				assert(area and enemy);local quest={id=id,kind="Active",ready=false,npc=def.NPC};local before=util.copy(quest)
				local target=route(quest,content,0,-1100);eq(target.kind,"Portal");eq(target.name,area.Id);eq(target.z,city.Regions[area.Id].CityGateZ)
				for _,region in ipairs(city.RegionOrder) do
					local at=city.Destinations[region];target=route(quest,content,at.X,at.Z)
					if region==area.Id then eq(target.kind,"Enemy");eq(target.enemyId,enemy.Id);eq(target.x,city.Regions[region].X+17);eq(target.z,city.Regions[region].Z-23);eq(requested,{region,enemy.Marker})
					else eq(target.kind,"Portal");eq(target.name,"Central City") end
				end
				eq(quest,before);local at=city.Destinations[area.Id]
				loaded=false;eq(route(quest,content,at.X,at.Z),nil);loaded=true
				quest.ready=true;eq(route(quest,content,at.X,at.Z).name,"Central City");eq(route(quest,content,0,-1100).name,"Ghar")
				quest.ready=false;quest.kind="Available";eq(route(quest,content,0,-1100).kind,"NPC")
				quest.kind="Active";content.RegionalCombatAvailable=false;eq(route(quest,content,0,-1100).kind,"NPC");content.RegionalCombatAvailable=true
			end
		end
		eq(count,6)
	end)
	test("regional quest guidance routes eight quests through portals then back to the NPC",function()
		local city=require("../src/shared/Config/City");local rules=require("../src/shared/Data/Expansion")
		local content=require("../src/server/Config/Content");local util=require("../src/shared/Util/TableUtil")
		local route=require("../src/shared/Data/QuestRoute")(city,rules,W);local count=0
		for id,def in pairs(content.Journal) do
			local nodeId=def.Event and def.Event:match("^Gather:(.+)$");local node=nodeId and rules.Nodes[nodeId]
			if node and node.Region then
				count+=1;local quest={id=id,kind="Active",ready=false,npc=def.NPC};local before=util.copy(quest)
				local r=route(quest,content,0,-1100);eq(r.kind,"Portal");eq(r.name,node.Region);eq(r.z,city.Regions[node.Region].CityGateZ);eq(r.final,false)
				for _,region in ipairs(city.RegionOrder) do
					local at=city.Destinations[region];r=route(quest,content,at.X,at.Z)
					if region==node.Region then eq(r.kind,"Resource");eq(r.nodeId,nodeId);eq(r.x,city.Regions[region].X+node.X);eq(r.z,city.Regions[region].Z+node.Z);eq(r.final,true)
					else eq(r.kind,"Portal");eq(r.name,"Central City");eq(r.z,at.Z+12) end
				end
				eq(quest,before);quest.ready=true
				local at=city.Destinations[node.Region];r=route(quest,content,at.X,at.Z);eq(r.name,"Central City")
				r=route(quest,content,0,-1100);eq(r.kind,"NPC");eq(r.name,def.NPC);eq(r.x,W.NPCs[def.NPC].X)
				quest.ready=false;quest.kind="Available";eq(route(quest,content,0,-1100).kind,"NPC")
			end
		end
		eq(count,8);eq(route(nil,content,0,0),nil);eq(route(nil,content,0,-1100).name,"City Herald")
		eq(route({npc="Unknown"},content,0,-1100),nil)
	end)
	test("city waypoint uses planar arrival threshold and rounded distance",function()
		local d,a=W.progress(0,0,6,8);eq(d,10);eq(a,true)
		d,a=W.progress(0,0,0,10.1);eq(d,10);eq(a,false)
		d,a=W.progress(100,-100,100,-100);eq(d,0);eq(a,true)
	end)
	test("city waypoint arrow matches camera-local cardinal directions",function()
		eq(W.heading(0,-1),0);eq(W.heading(1,0),90);eq(W.heading(-1,0),-90);eq(math.abs(W.heading(0,1)),180)
	end)
	test("city quest navigation names resolve to current NPC stations",function()
		eq(W.NPCs.Mira.X,250);eq(W.NPCs.Mira.Z,-1030)
		eq(W.NPCs["City Herald"].X,-45);eq(W.NPCs["Expedition Master"].Z,-840)
		eq(W.NPCs["Unknown"],nil)
		for id,npc in pairs(require("../src/shared/Config/FriendlyNpcs")) do
			if string.sub(id,1,5)=="host_"then continue end -- Civic hosts are indexed on their local city map.
			eq(W.NPCs[npc.name].X,npc.x);eq(W.NPCs[npc.name].Z,npc.z)
		end
	end)
end
