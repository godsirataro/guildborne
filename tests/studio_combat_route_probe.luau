--!strict
-- Read-only production catalog/geometry; quest states below are isolated fixtures.
return function():any
 local snapshot:any=nil
 local connection=game.ReplicatedStorage.GuildborneRemotes.State.OnClientEvent:Connect(function(v)snapshot=v end)
 local start=os.clock();repeat task.wait(.1) until snapshot or os.clock()-start>7
 connection:Disconnect();assert(snapshot and snapshot.catalog,"No projected catalog")
 local Shared=game.ReplicatedStorage.Shared
 local city=require(Shared.Config.City);local catalog=snapshot.catalog
 local function marker(region:string,name:string):any
  local world=workspace:FindFirstChild("GuildborneWorld");local area=world and world:FindFirstChild(region)
  local folder=area and area:FindFirstChild("EncounterMarkers");local part=folder and folder:FindFirstChild(name)
  return if part and part:IsA("BasePart") then {x=part.Position.X,z=part.Position.Z} else nil
 end
 local route=require(Shared.Data.QuestRoute)(city,require(Shared.Data.Expansion),require(Shared.Data.CityWaypoint),marker)
 local enemyCount=0;local quests=0
 for _,region in ipairs(catalog.Bestiary.Regions) do
  for _,enemy in ipairs(region.Entries) do
   local position=marker(region.Id,enemy.Marker);assert(position,"Missing encounter marker")
   assert(city.region(position.x,position.z)==region.Id);assert(type(enemy.QuestEvent)=="string");enemyCount+=1
   for id,def in pairs(catalog.Journal) do if def.Event==enemy.QuestEvent then
    quests+=1;local quest={id=id,kind="Active",ready=false,npc=def.NPC};local at=city.Destinations[region.Id]
    local target=route(quest,catalog,0,-1100);assert(target.kind=="Portal" and target.name==region.Id)
    local encounter=route(quest,catalog,at.X,at.Z);assert(encounter.kind=="Enemy" and encounter.enemyId==enemy.Id and encounter.x==position.x and encounter.z==position.z)
    quest.ready=true;local back=route(quest,catalog,at.X,at.Z);assert(back.name=="Central City")
    local turnIn=route(quest,catalog,0,-1100);assert(turnIn.kind=="NPC" and turnIn.name=="Ghar")
   end end
  end
 end
 assert(enemyCount==12 and quests==6)
 return {enemyMarkers=enemyCount,questRoutes=quests,projectedCatalog=true,actualGeometry=true,syntheticQuestStates=true,profileWrites=0}
end
