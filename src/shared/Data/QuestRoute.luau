--!strict
-- Read-only directions from public geometry and the projected quest state.
return function(city:any,rules:any,waypoint:any,resolveMarker:any?)
 local function destination(quest:any,catalog:any,x:number,z:number,context:any?):any
  local region=city.region(x,z);local inCity=city.contains(x,z)
  local owned=context and context.island and context.playerId==context.island.ownerId
  local inGuild=owned and context.inGuild==true
  local function pointTarget(point:any,name:string,kind:string,final:boolean):any
   if not point then return nil end
   return {name=name,x=point.x,y=point.y,z=point.z,anchor=point.anchor,zone=point.zone or "Guild",kind=kind,final=final}
  end
  if not region and not inCity and not inGuild then return nil end
  if quest and quest.kind=="CampaignComplete" then return nil end
  local campaign=context and context.campaign
  local objective=if quest and quest.kind=="Campaign" and campaign and campaign.ownerId==context.playerId and campaign.objective==quest.objective then campaign.point else nil
  -- ChapterOne/CampaignWorld victory bindings; these objectives have no R prompt.
  local combatObjectives={protect_companion={id="greenwood_archer",marker="ArcherCamp"},defeat_forest_guardian={id="forest_captain",marker="ForestCaptain"}}
  local combat=quest and quest.kind=="Campaign" and combatObjectives[quest.objective]
  if not objective and combat and campaign and campaign.ownerId==context.playerId and campaign.objective==quest.objective then
   local encounter=context.encounters and context.encounters[combat.id]
   if encounter and encounter.ownerId==context.playerId and encounter.marker==combat.marker and encounter.region=="Greenwood" and encounter.alive==true then objective=encounter.point end
  end
  -- ChapterOne's registrar belongs to the player's island. Its streamed marker
  -- is required for the final leg, but not for directions to the city guild gate.
  local needsIsland=quest and quest.kind=="Campaign" and (quest.focus=="UpgradeGuildHall" or quest.objective=="return_forest_evidence" or (objective and objective.zone=="Guild"))
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
  if quest and quest.kind=="Campaign" and not needsIsland then
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
 local function distance(a:any,b:any):number return math.sqrt((a.x-b.x)^2+(a.z-b.z)^2)end
 local function roadStep(start:any,target:any,roads:any):any
  if not roads or #roads==0 then return nil end
  local nodes:{any}={};local adjacency:{any}={};local memberships:{any}={}
  local function add(point:any,road:number):number
   for i,p in ipairs(nodes)do if distance(p,point)<.01 then memberships[i][road]=true;return i end end
   table.insert(nodes,point);table.insert(adjacency,{});table.insert(memberships,{[road]=true});return #nodes
  end
  local function project(p:any,r:any):any
   local dx,dz=r.b.x-r.a.x,r.b.z-r.a.z;local length=dx*dx+dz*dz
   if length<.01 then return nil end
   local t=math.clamp(((p.x-r.a.x)*dx+(p.z-r.a.z)*dz)/length,0,1)
   return {x=r.a.x+t*dx,z=r.a.z+t*dz,y=r.y,anchor=r.anchor}
  end
  for i,r in ipairs(roads)do add(r.a,i);add(r.b,i)end
  for i,a in ipairs(roads)do for j=i+1,#roads do
   local b=roads[j];local ax,az=a.b.x-a.a.x,a.b.z-a.a.z;local bx,bz=b.b.x-b.a.x,b.b.z-b.a.z
   local cross=ax*bz-az*bx
   if math.abs(cross)>.001 then
    local dx,dz=b.a.x-a.a.x,b.a.z-a.a.z
    local t=(dx*bz-dz*bx)/cross;local u=(dx*az-dz*ax)/cross
    if t>=0 and t<=1 and u>=0 and u<=1 then
     local point={x=a.a.x+t*ax,z=a.a.z+t*az,y=a.y,anchor=a.anchor};add(point,i);add(point,j)
    end
   else
    for _,p in ipairs({a.a,a.b,b.a,b.b})do
     local pa,pb=project(p,a),project(p,b)
     if pa and pb and distance(p,pa)<.01 and distance(p,pb)<.01 then add(p,i);add(p,j)end
    end
   end
  end end
  local function nearest(p:any):number?
   local best:any=nil;local index=0;local cost=math.huge
   for i,r in ipairs(roads)do local q=project(p,r)
    if q then local d=distance(p,q);if d<=r.width/2 and d<cost then cost=d;best=q;index=i end end
   end
   return if best then add(best,index) else nil
  end
  local first,last=nearest(start),nearest(target);if not first or not last then return nil end
  for i=1,#nodes do for j=i+1,#nodes do
   for road in pairs(memberships[i])do if memberships[j][road]then
    adjacency[i][j]=distance(nodes[i],nodes[j]);adjacency[j][i]=adjacency[i][j];break
   end end
  end end
  local costs:{[number]:number}={[first]=0};local previous:{[number]:number}={};local visited:{[number]:boolean}={}
  for _=1,#nodes do
   local current:number?=nil;local cost=math.huge
   for i=1,#nodes do if not visited[i] and (costs[i] or math.huge)<cost then current=i;cost=costs[i] end end
   if not current then break end
   if current==last then break end
   visited[current]=true
   for neighbor,length in pairs(adjacency[current])do
    if cost+length<(costs[neighbor] or math.huge)then costs[neighbor]=cost+length;previous[neighbor]=current end
   end
  end
  if not costs[last]then return nil end
  local path={last};local cursor=last
  while cursor~=first do cursor=previous[cursor];if not cursor then return nil end;table.insert(path,1,cursor)end
  for _,id in ipairs(path)do if distance(start,nodes[id])>3 then return nodes[id] end end
  if not target.anchor then target=table.clone(target);target.anchor=nodes[last].anchor;target.y=nodes[last].y end
  return target
 end
 return function(quest:any,catalog:any,x:number,z:number,context:any?):any
  local target=destination(quest,catalog,x,z,context)
  if context and context.civic then
   local exit=context.civic.exit
   if not quest or quest.kind=="CampaignComplete" or not exit then return nil end
   target={x=exit.x,y=exit.y,z=exit.z,name="Central City",zone=context.civic.id,kind="Portal",final=false}
  end
  if target and (type(target.x)~="number" or type(target.z)~="number" or target.x~=target.x or target.z~=target.z or math.abs(target.x)==math.huge or math.abs(target.z)==math.huge)then return nil end
  if not target or not context or not context.authored then return target end
  local function destinationHint():any
   local hint=table.clone(target)
   hint.anchor=nil;hint.guidance="destination";hint.stepLabel="Destination direction — follow paths";hint.destinationName=target.name
   return hint
  end
  local start={x=x,z=z};local nextPoint:any=nil;local label="Continue to destination"
  if target.zone=="City" then
   nextPoint=roadStep(start,target,context.roads);label="Follow the city road"
  elseif target.zone=="Guild" and context.island and context.island.ownerId==context.playerId then
   local island=context.island
   if target.name~="Central City" then return destinationHint() end
   if not island.supported then return nil end
   if island.insideHall then nextPoint=island.hallApproach or island.threshold;label="Leave the Hall"
   elseif target.name=="Central City" then
    if not island.legs then return nil end
    for _,leg in ipairs(island.legs)do
     if not leg.reached then nextPoint=leg.point;label=leg.label;break end
    end
    if not nextPoint then nextPoint=target;label="Follow the promenade" end
   else return nil end
  elseif city.Regions[target.zone] or (context.civic and context.civic.id==target.zone) then
   return destinationHint() -- Direction only: no claim of an authored safe next leg.
  else return nil end
  if not nextPoint then return nil end
  if context.clearSegment and not context.clearSegment(nextPoint) then return nil end
  local result=table.clone(target)
  result.x=nextPoint.x;result.y=nextPoint.y;result.z=nextPoint.z;result.anchor=nextPoint.anchor
  result.final=distance(nextPoint,target)<.01 and target.final;result.stepLabel=label;result.destinationName=target.name
  return result
 end
end
