--!strict
-- Read-only directions from public geometry and the projected quest state.
return function(city:any,rules:any,waypoint:any,resolveMarker:any?)
 return function(quest:any,catalog:any,x:number,z:number,context:any?):any
  local region=city.region(x,z);local inCity=city.contains(x,z)
  local owned=context and context.island and context.playerId==context.island.ownerId
  local inGuild=owned and context.inGuild==true
  local function pointTarget(point:any,name:string,kind:string,final:boolean):any
   if not point then return nil end
   return {name=name,x=point.x,z=point.z,zone=point.zone or "Guild",kind=kind,final=final}
  end
  if not region and not inCity and not inGuild then return nil end
  if quest and quest.kind=="CampaignComplete" then return nil end
  local campaign=context and context.campaign
  local objective=if quest and quest.kind=="Campaign" and campaign and campaign.ownerId==context.playerId and campaign.objective==quest.objective then campaign.point else nil
  local needsIsland=quest and quest.kind=="Campaign" and (quest.focus=="UpgradeGuildHall" or (objective and objective.zone=="Guild"))
  local def=quest and quest.id and catalog.Journal[quest.id]
  local nodeId=def and def.Event and def.Event:match("^Gather:(.+)$")
  local node=nodeId and rules.Nodes and rules.Nodes[nodeId]
  if inGuild then
   if needsIsland then
    return pointTarget(if quest.focus=="UpgradeGuildHall" then context.island.hall else objective,if quest.focus=="UpgradeGuildHall" then "Guild Hall" else quest.name,"Objective",true)
   end
   local destination=objective and (objective.zone=="City" or city.Regions[objective.zone]~=nil)
   if quest and def and (quest.kind=="Active" or quest.kind=="Available") then
    destination=type(quest.npc)=="string" and waypoint.NPCs[quest.npc]~=nil
    if quest.kind=="Active" and not quest.ready then
     destination=destination or (node and city.Regions[node.Region]~=nil)
     if not destination and catalog.RegionalCombatAvailable==true then
      for _,area in ipairs(if catalog.Bestiary then catalog.Bestiary.Regions or {} else {})do
       for _,enemy in ipairs(area.Entries)do
        if type(def.Event)=="string" and enemy.QuestEvent==def.Event and city.Regions[area.Id] then destination=true end
       end
      end
     end
    end
   end
   if not destination then return nil end
   return pointTarget(context.island.exit,"Central City","Portal",false)
  end
  if inCity and needsIsland then
   local best=nil;local distance=math.huge
   for _,id in ipairs({"Arrival","GuildDistrict","MarketDistrict","TowerDistrict"})do
    local stop=city.GuildPortalStops and city.GuildPortalStops[id]
    if stop then local squared=(x-stop.X)^2+(z-stop.Z)^2;if squared<distance then distance=squared;best=stop end end
   end
   if best then return {name=best.Name,x=best.X,z=best.Z,zone="City",kind="Portal",final=false}end
  end
  if quest and quest.kind=="Campaign" and quest.focus~="UpgradeGuildHall" then
   if not objective then return nil end -- Menu/order objectives have no world destination.
   if objective.zone==(region or "City") then return pointTarget(objective,quest.name,"Objective",true) end
   if inCity and city.Regions[objective.zone] then
    return {name=objective.zone,x=0,z=city.Regions[objective.zone].CityGateZ,zone="City",kind="Portal",final=false}
   end
  end
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
