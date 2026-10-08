--!strict
-- Synthetic profiles exercise authoritative commands, not actual journey acceptance.
return function(test:any,eq:any,harness:any,util:any,content:any)
 local ids={"elian_charter","vaela_seedlings","borin_castings","nyra_stonecharts","sela_shelter","roka_shared_pot"}
 local entries=require("../src/shared/Config/FriendlyNpcs")
 local locales=require("../src/shared/Config/Localization")
 test("six civic envoys have localized quests and synchronized public directions",function()
  local waypoint=require("../src/shared/Data/CityWaypoint");local cities={};local count=0
  for _,entry in pairs(entries)do if entry.homeCity then
   count+=1;assert(not cities[entry.homeCity]);cities[entry.homeCity]=true
   eq(content.QuestNPCs[entry.name],true);eq(waypoint.NPCs[entry.name],{X=entry.x,Z=entry.z})
   assert(#entry.en>80 and #entry.th>80);assert(locales.translate("th",entry.name)~=entry.name)
  end end;eq(count,6)
  for _,id in ipairs(ids)do local q=content.Journal[id];assert(q and q.NPC and q.Requires);assert(locales.translate("th",q.Name)~=q.Name);assert(locales.translate("th",q.Description)~=q.Description)end
 end)
 test("civic tasks require prior community work; regional ones remain preview-gated",function()
  local h=harness();h.setup()
  for _,id in ipairs(ids)do local q=content.Journal[id]
   eq(h.send("AcceptTask",{questId=id}),if q.RequiresRegionalCombat then "RegionalEncountersUnavailable"else "QuestLocked")
   eq(h.data().settlement.journal[id],nil)
  end
 end)
 test("all six civic tasks commit exact one-time rewards through write outages and rejoin",function()
  local old=content.RegionalCombatAvailable;content.RegionalCombatAvailable=true
  local ok,problem=pcall(function()
   for _,id in ipairs(ids)do for _,mode in ipairs({"before","after"})do
    local h=harness();h.setup();eq(h.send("SelectPlayerClass",{classId="Warrior"}),"OK")
    local q=content.Journal[id];h.data().settlement.journal[q.Requires]={state="Claimed",progress=content.Journal[q.Requires].Count}
    h.data().currencies.gold+=1000;h.data().statistics.goldCreated+=1000
    for _,item in ipairs({"timber","stone","iron_ore","herb"})do h.data().inventory.stacks[item]=50 end
    if id=="borin_castings"then eq(h.send("PlaceBuilding",{kind="forge",x=6,z=-4,rotation=0}),"OK")end
    eq(h.send("AcceptTask",{questId=id}),"OK")
    if q.Event then
     eq(h.send("ClaimTask",{questId=id}),"TaskIncomplete")
     for _=1,q.Count do
      local action:string;local args:any
      if id=="elian_charter"then action="TravelZone";args={zone="Guild"}
      elseif id=="borin_castings"then action="CraftItem";args={recipeId="iron_ingot"}
      else action="GatherResource";args={nodeId=q.Event:sub(8)};h.now+=20 end
      local command=h.command(action,args);eq(h.service.Execute(1,command),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
     end
    end
    local before=util.copy(h.data());local command=h.command("ClaimTask",{questId=id});h.mode=mode
    eq(h.service.Execute(1,command),"SavePending");eq(h.data(),before)
    h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
    eq(h.data().currencies.gold,before.currencies.gold+q.Gold);eq(h.data().character.xp,before.character.xp+q.XP)
    if q.Item then eq(h.data().inventory.stacks[q.Item],before.inventory.stacks[q.Item]-q.Count)else eq(h.data().inventory.stacks,before.inventory.stacks)end
    eq(h.service.Close(1),"OK");eq(h.service.Load(1,"civic-rejoin"),"OK");eq(h.send("ClaimTask",{questId=id}),"QuestNotActive")
    eq(h.data().currencies.gold,before.currencies.gold+q.Gold)
   end end
  end)
  content.RegionalCombatAvailable=old;assert(ok,tostring(problem))
 end)
 test("civic gathering counts only accepted named nodes and deliveries cannot overspend",function()
  local old=content.RegionalCombatAvailable;content.RegionalCombatAvailable=true
  local ok,problem=pcall(function()
   local h=harness();h.setup();h.data().settlement.journal.herb_field={state="Claimed",progress=3}
   eq(h.send("GatherResource",{nodeId="greenwood_herbs"}),"OK");eq(h.send("AcceptTask",{questId="vaela_seedlings"}),"OK")
   eq(h.data().settlement.journal.vaela_seedlings.progress,0);eq(h.send("GatherResource",{nodeId="herbs"}),"OK");eq(h.data().settlement.journal.vaela_seedlings.progress,0)
   h.data().settlement.journal.borga_hearth={state="Claimed",progress=4};eq(h.send("AcceptTask",{questId="roka_shared_pot"}),"OK")
   h.data().inventory.stacks.herb=3;local before=util.copy(h.data());eq(h.send("ClaimTask",{questId="roka_shared_pot"}),"MissingMaterials");eq(h.data(),before)
  end)
  content.RegionalCombatAvailable=old;assert(ok,tostring(problem))
 end)
end
