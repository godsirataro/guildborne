--!strict
-- Read-only directions from public geometry and the projected quest state.
return function(city:any,rules:any,waypoint:any,resolveMarker:any?)
 -- Exact action-part suffixes authored by AshenWorld and TowerWorld. The client
 -- never derives a marker from translated text or infers a puzzle answer.
 local ashenObjectives={
  follow_ashen_supplies={"supply_trace_1","supply_trace_2","supply_trace_3"},help_ashen_gatekeeper={"gatekeeper"},request_ashen_charter={"permit_ledger"},
  preserve_hearth_traces={"memory_1","memory_2","memory_3"},arrange_hearth_memories={"memory_1","memory_2","memory_3"},meet_hearth_survivor={"survivor"},
  secure_bridge_supports={"support_1","support_2","support_3"},choose_bridge_route={"sheltered_route","direct_route"},escort_bridgewright={"bridgewright"},
  question_ashen_witness={"testimony_1","testimony_2","testimony_3"},verify_ashen_testimony={"witness"},choose_witness_route={"trust_route","guard_route"},
  tune_ashen_bells={"tuning_1","tuning_2","tuning_3"},survive_bell_wave={},send_ashen_dispatch={"courier"},
  break_ashen_bindings={"binding_1","binding_2","binding_3"},protect_ashen_survivor={"civilian"},defeat_ashen_warden={},
 }
 local towerObjectives={
  reach_tower_checkpoint_five={"checkpoint_1","checkpoint_2","checkpoint_3","checkpoint_4","checkpoint_5"},
  finish_tower_orientation={"checkpoint_6","checkpoint_7","checkpoint_8","checkpoint_9","checkpoint_10"},
  collect_tower_chart={"route_chart"},confirm_tower_charter={"council"},try_guardian_guard={"guard_trial"},try_guardian_roles={"mend_trial"},
  read_guardian_rules={"rule_1","rule_2","rule_3"},complete_guardian_defense={"defense_trial"},find_hidden_archive={"hidden_exit"},
  solve_archive_sequence={"sequence_1","sequence_2","sequence_3"},recover_archive_chart={"archive_record"},
  read_guild_memories={"caravan_memory","timber_memory","guild_memory"},rescue_memory_echo={"help_memory"},renew_tower_oath={"oath_courage","oath_compassion"},
  read_twin_door_clues={"door_clue_1","door_clue_2","door_clue_3"},choose_tower_door={"sun_door","moon_door"},
  follow_tower_bypass={"bypass_left","bypass_right","bypass_record"},complete_records_guardian={"records_guardian"},
  copy_first_ledger={"copy_ledger"},earn_three_city_seals={"city_seal_1","city_seal_2","city_seal_3"},
 }
 local surfaceEncounters={survive_bell_wave={id="rune_caster",marker="CasterCourt"},defeat_ashen_warden={id="arcane_warden",marker="ArcaneWarden"}}
 local lessonRoles={try_guardian_guard="Guard",try_guardian_roles="Mend",complete_guardian_defense="Combined"}
 local function finite(value:any):boolean return type(value)=="number" and value==value and math.abs(value)<math.huge end
 -- Explicit Chapter02 marker names authored by IronveilWorld, not inferred labels.
 local mineObjectives={inspect_ironveil_scales={"inspect_ironveil_scales_scale_1","inspect_ironveil_scales_scale_2","inspect_ironveil_scales_scale_3"},interview_carrier={"interview_carrier_carrier"},enter_ironveil={"MineReception"}}
 mineObjectives.read_mine_signal={"read_mine_signal_signal_1","read_mine_signal_signal_2","read_mine_signal_signal_3"}
 mineObjectives.choose_safe_shaft={"choose_safe_shaft_signal_1","choose_safe_shaft_signal_2","choose_safe_shaft_signal_3"}
 mineObjectives.rescue_miner={"rescue_miner_trapped_miner"}
 mineObjectives.inspect_shoring={"inspect_shoring_support_1","inspect_shoring_support_2","inspect_shoring_support_3"}
 mineObjectives.protect_engineer={"protect_engineer_engineer"}
 mineObjectives.repair_shoring={"repair_shoring_support_1","repair_shoring_support_2","repair_shoring_support_3"}
 mineObjectives.collect_reagent={"collect_reagent_reagent"}
 mineObjectives.compare_mine_seals={"compare_mine_seals_seal_1","compare_mine_seals_seal_2"}
 mineObjectives.choose_joint_review={"Review_workers","Review_council"}
 mineObjectives.operate_mine_mechanism={"operate_mine_mechanism_mechanism_1","operate_mine_mechanism_mechanism_2","operate_mine_mechanism_mechanism_3"}
 mineObjectives.protect_mine_worker={"protect_mine_worker_protected_worker"}
 mineObjectives.defeat_mine_warden={}
 mineObjectives.return_mine_key={"return_mine_key_arena_entry"}
 mineObjectives.meet_class_mentor={"meet_class_mentor_mentor"}
 mineObjectives.submit_ironveil_evidence={"submit_ironveil_evidence_mentor"}
 mineObjectives.complete_borrowed_path={}
 for id,path in pairs(rules.Paths or {})do if path.Tier==2 then table.insert(mineObjectives.complete_borrowed_path,"Borrowed_"..id)end end
 table.sort(mineObjectives.complete_borrowed_path)
 local areas={read_mine_signal=true,choose_safe_shaft=true,repair_shoring=true,choose_joint_review=true,operate_mine_mechanism=true,complete_borrowed_path=true}
 local function instruction(quest:any):any return {kind="Instruction",name=quest.name} end
 local walkingPairs={city_greenwood_west={"City","Greenwood"},greenwood_ironveil_south={"Greenwood","Ironveil"},ironveil_ashen_south={"Ironveil","Ashen"}}
 local function walkingEdge(context:any,fromZone:string,toZone:string):any
  local walking=context and context.walking
  if not walking or type(walking.routes)~="table" then return nil end
  for id,pair in pairs(walkingPairs)do
   if (fromZone==pair[1] and toZone==pair[2]) or (fromZone==pair[2] and toZone==pair[1]) then
    local route=walking.routes[id]
    if route and route.routeId==id and route.fromZone==pair[1] and route.toZone==pair[2] and type(route.points)=="table" and #route.points>=2 then return route end
   end
  end
  return nil
 end
 local function walkingApproach(context:any,fromZone:string,toZone:string,x:number,z:number):any
  local route=walkingEdge(context,fromZone,toZone)
  if not route then return nil end
  -- Ironveil's private mine overlaps the surface in X/Z. Do not offer a surface
  -- walking entrance from an elevated private floor or an unknown height.
  if route.routeId=="greenwood_ironveil_south" and (not finite(context.playerY) or context.playerY<1 or context.playerY>35)then return nil end
   if route.routeId=="ironveil_ashen_south" then
    -- City.region includes Ashen's private annex. Only actual public surface
    -- coordinates may offer this entrance, even after falling below a court.
    local area=city.Regions[fromZone]
    if not area or not finite(context.playerY) or context.playerY<1 or context.playerY>35
     or not finite(x) or not finite(z) or math.abs(x-area.X)>area.HalfWidth
     or z<area.Z-area.Back or z>area.Z+area.Front then return nil end
   end
  local point=if fromZone==route.fromZone then route.points[1] else route.points[#route.points]
  if not point or not finite(point.x) or not finite(point.y) or not finite(point.z) then return nil end
  return {name=if toZone=="City" then "Central City" else toZone,x=point.x,y=point.y,z=point.z,zone=fromZone,kind="Portal",final=false}
 end
 local function destination(quest:any,catalog:any,x:number,z:number,context:any?):any
  if quest and quest.kind=="Campaign" and quest.ready==true then return instruction(quest) end
  local region=city.region(x,z);local inCity=city.contains(x,z)
  local owned=context and context.island and context.playerId==context.island.ownerId
  local inGuild=owned and context.inGuild==true
  local function pointTarget(point:any,name:string,kind:string,final:boolean):any
   if not point then return nil end
   return {name=name,x=point.x,y=point.y,z=point.z,anchor=point.anchor,zone=point.zone or "Guild",kind=kind,final=final}
  end
  if not region and not inCity and not inGuild then return nil end
  if quest and quest.kind=="CampaignComplete" then return nil end
  if quest and quest.kind=="Campaign" and quest.focus=="UpgradeGuildHall" and region=="Ashen" and context then
   for _,key in ipairs({"ashen","tower"})do
    local court=context[key];local floor=court and court.floor
    if floor and court.ownerId==context.playerId and finite(court.playerY) and court.playerY>=floor.y and court.playerY<=floor.y+20
     and math.abs(x-floor.x)<=floor.width/2 and math.abs(z-floor.z)<=floor.depth/2 then
     local p=court.anchors and court.anchors.CourtExit
     if p and finite(p.y) and p.y>=floor.y and p.y<=floor.y+20 then return pointTarget(p,"Ashen","Portal",false) end
     return nil
    end
   end
   local y=context.playerY;local area=city.Regions.Ashen
   if y~=nil and (not finite(y) or y<1 or y>35 or math.abs(x-area.X)>area.HalfWidth or z<area.Z-area.Back or z>area.Z+area.Front)then return nil end
  end
  local id=quest and quest.kind=="Campaign" and quest.objective
  local courtNames=id and (ashenObjectives[id] or towerObjectives[id])
  if courtNames then
   -- Known public travel legs remain useful before a private court streams in.
   if inGuild then return pointTarget(context.island.exit,"Central City","Portal",false) end
   if inCity then return {name="Ashen",x=0,z=city.Regions.Ashen.CityGateZ,zone="City",kind="Portal",final=false} end
   if region=="Ironveil" then
    local approach=walkingApproach(context,"Ironveil","Ashen",x,z)
    if approach then return approach end
   end
   if region and region~="Ashen" then local landing=city.Destinations[region];return {name="Central City",x=landing.X,z=landing.Z+12,zone=region,kind="Portal",final=false} end
   local court=context and (if ashenObjectives[id] then context.ashen else context.tower)
   if not court or court.ownerId~=context.playerId or not court.floor or not court.anchors then return nil end
   local floor=court.floor;local y=court.playerY
   if not finite(y) then return nil end
   local function inCourt(point:any):boolean
    return point~=nil and finite(point.x) and finite(point.y) and finite(point.z)
     and math.abs(point.x-floor.x)<=floor.width/2 and math.abs(point.z-floor.z)<=floor.depth/2 and point.y>=floor.y and point.y<=floor.y+20
   end
   local inside=inCourt({x=x,y=y,z=z})
   local area=city.Regions.Ashen
   -- City.region also covers Tower's annex. A low/falling annex avatar is never
   -- on the surface or another owner's elevated court.
   local surface=math.abs(x-area.X)<=area.HalfWidth and z>=area.Z-area.Back and z<=area.Z+area.Front and y>=1 and y<=35
   if id=="complete_records_guardian" and court.trial==true then return instruction(quest) end
   local combat=surfaceEncounters[id]
   if combat then
    if inside then return if inCourt(court.anchors.CourtExit) then pointTarget(court.anchors.CourtExit,"Ashen","Portal",false) else nil end
    if not surface then return nil end
    local enemy=court.encounters and court.encounters[combat.id]
    if enemy and enemy.ownerId==context.playerId and enemy.alive==true and enemy.marker==combat.marker then
     local p=enemy.point
     if p and finite(p.y) and p.y>=1 and p.y<=35 then return pointTarget(p,quest.name,"Enemy",true) end
    end
    return nil
   end
   if not inside then
    if not surface then return nil end
    local p=court.anchors.CourtEntrance
    if p and finite(p.y) and p.y>=1 and p.y<=35 and math.abs(p.x-area.X)<=area.HalfWidth and p.z>=area.Z-area.Back and p.z<=area.Z+area.Front then
     return pointTarget(p,"Ashen","Portal",false)
    end
    return nil
   end
   local escortActor=if id=="help_ashen_gatekeeper"then "gatekeeper"elseif id=="escort_bridgewright"then "bridgewright"else nil
   if (escortActor or id=="rescue_memory_echo") and court.escortStatus and court.escortStatus~="Failed" and court.escortStatus~="Cancelled" then
    if not escortActor then return instruction(quest) end -- Tower exposes no authoritative route/exit.
    local reason=court.escortReasons and court.escortReasons[escortActor]
    local p=if reason=="MeetAtExit" then court.escortExit else court.escortPosition
    return if inCourt(p) then pointTarget(p,quest.name,"Escort",false) else instruction(quest)
   end
   if id=="protect_ashen_survivor" and court.protectionStatus=="Active" then
    return if court.warningLive and inCourt(court.warning) then pointTarget(court.warning,quest.name,"Warning",false) else instruction(quest)
   end
   if lessonRoles[id] and court.lessonRole==lessonRoles[id] and (court.lessonStatus=="Active" or court.lessonStatus=="Completed") then return instruction(quest) end
   local best=nil;local distance=math.huge
   for _,suffix in ipairs(courtNames)do
    local p=court.anchors[id.."_"..suffix]
    if inCourt(p) then
     local squared=(x-p.x)^2+(z-p.z)^2
     if squared<distance then best=p;distance=squared end
    end
   end
   -- Several valid markers describe an area, never a preferred story choice or
   -- a claimed next puzzle step. Enabled prompts retain server-owned progress.
   local multiple=#courtNames>1
   return pointTarget(best,quest.name,if multiple then "ObjectiveArea" else "Objective",not multiple)
  end
  local mineNames=quest and quest.kind=="Campaign" and quest.objective and mineObjectives[quest.objective]
  if mineNames then
   -- Public travel legs do not depend on streaming the distant private mine.
   if inGuild then return pointTarget(context.island.exit,"Central City","Portal",false) end
   if inCity then return {name="Ironveil",x=0,z=city.Regions.Ironveil.CityGateZ,zone="City",kind="Portal",final=false} end
   if region=="Greenwood" or region=="Ashen" then
    local approach=walkingApproach(context,region,"Ironveil",x,z)
    if approach then return approach end
   end
   if region and region~="Ironveil" then local landing=city.Destinations[region];return {name="Central City",x=landing.X,z=landing.Z+12,zone=region,kind="Portal",final=false} end
   local mine=context and context.ironveil
   if not mine or mine.ownerId~=context.playerId or not mine.floor or not mine.anchors then return nil end
   local floor=mine.floor;local y=mine.playerY
   if type(y)~="number" or y~=y then return nil end
   if quest.objective=="complete_borrowed_path" and mine.trial==true then return instruction(quest) end
   local inside=math.abs(x-floor.x)<=floor.width/2 and math.abs(z-floor.z)<=floor.depth/2 and y>=floor.y and y<=floor.y+20
   if region=="Ironveil" then
    if quest.objective=="defeat_mine_warden" then
     if inside then return pointTarget(mine.anchors.MineExit,"Ironveil","Portal",false)end
     if y<1 or y>35 then return nil end
     local enemy=mine.guardian
     if enemy and enemy.ownerId==context.playerId and enemy.alive==true and enemy.marker=="QuarryGuardian" then return pointTarget(enemy.point,quest.name,"Enemy",true)end
     return nil
    end
    if not inside then
     -- Other vertical slots and falling characters are not the surface route.
     if y<1 or y>35 then return nil end
     return pointTarget(mine.anchors.MineEntrance,"Ironveil","Portal",false)
    end
    if quest.objective=="rescue_miner" and mine.escortStatus and mine.escortStatus~="Failed" and mine.escortStatus~="Cancelled" then
     local point=if mine.escortReason=="MeetAtExit" then mine.escortExit else mine.escortPosition
     return if point then pointTarget(point,quest.name,"Escort",false) else instruction(quest)
    end
    if (quest.objective=="protect_engineer" or quest.objective=="protect_mine_worker") and mine.protectionStatus=="Active" then
     return if mine.warning and mine.warningLive then pointTarget(mine.warning,quest.name,"Warning",false) else instruction(quest)
    end
    local best=nil;local distance=math.huge
    for _,name in ipairs(mineNames)do
     local point=mine.anchors[name]
     if point and point.y>=floor.y and point.y<=floor.y+20 then
      local squared=(x-point.x)^2+(z-point.z)^2
      if squared<distance then distance=squared;best=point end
     end
    end
    return pointTarget(best,quest.name,if areas[quest.objective] then "ObjectiveArea" else "Objective",not areas[quest.objective])
   end
   return nil
  end
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
   for _,stopId in ipairs({"Arrival","GuildDistrict","MarketDistrict","TowerDistrict"})do
    local stop=city.GuildPortalStops and city.GuildPortalStops[stopId]
    if stop then local squared=(x-stop.X)^2+(z-stop.Z)^2;if squared<distance then distance=squared;best=stop end end
   end
   if best then return {name=best.Name,x=best.X,z=best.Z,zone="City",kind="Portal",final=false}end
  end
  if quest and quest.kind=="Campaign" and not needsIsland then
   if not objective then return nil end -- Menu/order objectives have no world destination.
   if objective.zone==(region or "City") then return pointTarget(objective,quest.name,"Objective",true) end
   if region then
    local approach=walkingApproach(context,region,objective.zone,x,z)
    if approach then return approach end
   end
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
   elseif region then
    local approach=walkingApproach(context,region,node.Region,x,z)
    if approach then return approach end
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
      elseif region then
       local approach=walkingApproach(context,region,area.Id,x,z)
       if approach then return approach end
      end
     end
    end
   end
  end
  if region then
   if region=="Ironveil" or region=="Ashen" then
    local approach=walkingApproach(context,region,if region=="Ashen" then "Ironveil" else "Greenwood",x,z)
    if approach then return approach end
   end
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
  if target and target.kind=="Instruction" then return target end
  -- The server's single transit projection selects direction. Geometry alone
  -- never changes the player's zone or implies admission/completion.
  local walking=context and context.walking
  if walking and walking.present then
   if not walking.transit or not walking.route or not walking.nextPoint or not quest or quest.kind=="CampaignComplete" then return nil end
   local transit=walking.transit
   local route=walkingEdge(context,transit.fromZone,transit.toZone)
   if not route or route~=walking.route or route.routeId~=transit.routeId then return nil end
   local origin=city.Destinations.City
   local known=destination(quest,catalog,origin.X,origin.Z,context)
   if not known then return nil end
   if known.kind=="Instruction" then return known end
   local p=walking.nextPoint
   if not finite(p.x) or not finite(p.y) or not finite(p.z) then return nil end
   return {x=p.x,y=p.y,z=p.z,name=if route.routeId=="city_greenwood_west" then "City–Greenwood route" else transit.toZone,zone="WalkingRoute",kind="Walk",final=false,
    stepLabel="Follow the walking path",destinationName=walking.transit.toZone,guidance="walking"}
  end
  -- A streamed endpoint is ordinary approach guidance, not transit admission.
  if target and walking and target.kind=="Portal" then
   local approach=walkingApproach(context,target.zone,if target.name=="Central City" then "City" else target.name,x,z)
   if approach then
    target=table.clone(target);target.x=approach.x;target.y=approach.y;target.z=approach.z
    target.kind="Walk";target.final=false;target.stepLabel="Reach the walking path"
   end
  end
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
  local start={x=x,z=z};local nextPoint:any=nil;local label=target.stepLabel or "Continue to destination"
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
