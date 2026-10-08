--!strict
-- Read-only directions from public geometry and the projected quest state.
return function(city:any,rules:any,waypoint:any,resolveMarker:any?)
 return function(quest:any,catalog:any,x:number,z:number):any
  local region=city.region(x,z);local inCity=city.contains(x,z)
  if not region and not inCity then return nil end
  if inCity and quest and quest.kind=="Campaign" and quest.focus=="UpgradeGuildHall" then
   local best=nil;local distance=math.huge
   for _,id in ipairs({"Arrival","GuildDistrict","MarketDistrict","TowerDistrict"})do
    local stop=city.GuildPortalStops and city.GuildPortalStops[id]
    if stop then local squared=(x-stop.X)^2+(z-stop.Z)^2;if squared<distance then distance=squared;best=stop end end
   end
   if best then return {name=best.Name,x=best.X,z=best.Z,zone="City",kind="Portal",final=false}end
  end
  if quest and quest.kind=="CampaignComplete" then return nil end
  local def=quest and quest.id and catalog.Journal[quest.id]
  local nodeId=def and def.Event and def.Event:match("^Gather:(.+)$")
  local node=nodeId and rules.Nodes[nodeId]
  if quest and quest.kind=="Active" and not quest.ready and node and node.Region then
   if region==node.Region then
    local area=city.Regions[region]
    return {name=catalog.Items[node.Item].Name,x=area.X+node.X,z=area.Z+node.Z,zone=region,kind="Resource",nodeId=nodeId,final=true}
   elseif inCity then
    return {name=node.Region,x=0,z=city.Regions[node.Region].CityGateZ,zone="City",kind="Portal",final=false}
   end
  end
  if quest and quest.kind=="Active" and not quest.ready and def and catalog.RegionalCombatAvailable==true then
   for _,area in ipairs(if catalog.Bestiary then catalog.Bestiary.Regions or {} else {}) do
    for _,enemy in ipairs(area.Entries) do
     if enemy.QuestEvent==def.Event and type(enemy.QuestEvent)=="string" then
      if region==area.Id then
       local position=resolveMarker and resolveMarker(area.Id,enemy.Marker)
       if not position then return nil end -- Streamed geometry can arrive later; retain the selected quest.
       return {name=enemy.Name,x=position.x,z=position.z,zone=region,kind="Enemy",enemyId=enemy.Id,final=true}
      elseif inCity then
       return {name=area.Id,x=0,z=city.Regions[area.Id].CityGateZ,zone="City",kind="Portal",final=false}
      end
     end
    end
   end
  end
  if region then
   local landing=city.Destinations[region]
   return {name="Central City",x=landing.X,z=landing.Z+12,zone=region,kind="Portal",final=false}
  end
  local name=if quest and type(quest.npc)=="string" then quest.npc else "City Herald"
  local npc=waypoint.NPCs[name];if not npc then return nil end
  return {name=name,x=npc.X,z=npc.Z,zone="City",kind="NPC",final=true}
 end
end
