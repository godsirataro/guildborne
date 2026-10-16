-- Synthetic owner/profile, actual HeroService and Roblox physics; no earned progression proof.
return function(options)
 assert(game:GetService('RunService'):IsStudio() and game.PlaceId==0 and game.GameId==0)
 local server=game.ServerScriptService.Server
 local runtime=require(server.Config.Runtime)
 assert(runtime.StudioPersistence=='Memory' and next(runtime.AllowedDataStoreUniverses)==nil)
 local V=Vector3.new
 local world=workspace.GuildborneWorld
 local fixture=Instance.new('Model');fixture.Name='P1FiveHeroCityTraversal';fixture.Parent=world
 local service
 local travel,travelOwner,travelConnection
 local result={synthetic=true,rewardCalls=0,segments={},buildingChecks={},maxSeparation=0,samples=0}
 local ok,problem=xpcall(function()
  local function building(name)
   for _,m in ipairs(world:GetDescendants())do
    if m:IsA('Model') and m.Name==name and m:FindFirstChild('Interior')then return m end
   end
   error('Missing building '..name)
  end
  local tavern,forge,market=building('The Hearth and Banner'),building('Blacksmith'),building('Guildborne Exchange')
  local function point(m,z)return m:GetPivot():PointToWorldSpace(V(0,3,z))end
  local shared=game.ReplicatedStorage.Shared
  local content=require(server.Config.Content)
  local expansion=require(shared.Data.Expansion)
  local gear=require(shared.Data.Equipment)(content,expansion)
  local schema=require(server.Systems.ProfileSchema)(content,require(shared.Util.TableUtil),gear,expansion)
  local function reward()result.rewardCalls+=1 end
  service=require(server.Services.HeroService)(game.ServerStorage.GuildborneArtKit,function()end,reward,reward)
  local char=require(server.Services.HeroRig).Build('Warrior');char.Name='SyntheticLeader';char.Parent=fixture
  char:PivotTo(CFrame.new(0,4,-1100))
  local attrs:{[string]:any}={CurrentZone='City'}
  local owner:any={UserId=-93901,Character=char,GetAttribute=function(_,k)return attrs[k]end,SetAttribute=function(_,k,v)attrs[k]=v end}
  local data=schema.new(owner.UserId,1).data
  data.character.classId='Warrior';data.character.level=10;data.character.xp=450;data.party.adventurerIds={}
  local classes={'Knight','Warrior','Archer','Mage','Priest'}
  for _,class in ipairs(classes)do
   local id='a:'..class
   data.adventurers[id]={id=id,classId=class,name='Fixture '..class,level=10,xp=450,condition='Healthy',equipmentSlots={},rank='F'}
   data.progression.recruitedClasses[class]=true;table.insert(data.party.adventurerIds,id)
  end
  service.Add(owner,fixture,V(7000,0,6000));service.Character(owner,char);service.Sync(owner,data,true)
  local root=assert(char.PrimaryPart);local humanoid=assert(char:FindFirstChildOfClass('Humanoid'))
  root.Anchored=false;root:SetNetworkOwner(nil);humanoid.WalkSpeed=14;humanoid.AutoJumpEnabled=false
  service.Travel(owner);task.wait(2)
  local initial={}
  for _,class in ipairs(classes)do initial[class]=fixture.Heroes[class]:GetAttribute('RecoveryCount')or 0 end
  local function sample()
   assert(humanoid.Health>0 and root.Position.Y>-5,'Leader died/fell')
   local out={}
   for _,class in ipairs(classes)do
    local e=assert(service.CompanionEvidence(owner,'a:'..class),'Missing '..class)
    local recovery=fixture.Heroes[class]:GetAttribute('RecoveryCount')or 0
    local gap=(e.position-root.Position).Magnitude
    result.maxSeparation=math.max(result.maxSeparation,gap)
    table.insert(out,{class=class,x=e.position.X,y=e.position.Y,z=e.position.Z,recoveries=recovery,gap=gap})
    result.lastHeroes=out
    assert(e.health>0 and e.position.Y>-5,class..' died/fell')
    assert(recovery==initial[class],class..' auto-recovered/teleported')
    assert(gap<35,class..' lost leader')
   end
   result.samples+=1;assert(result.rewardCalls==0,'Unexpected rewards');return out
  end
  local function walk(label,goal)
   result.activeSegment=label
   local deadline=os.clock()+(goal-root.Position).Magnitude/12+10
   local refresh=0
   repeat
    if os.clock()>=refresh then humanoid:MoveTo(goal);refresh=os.clock()+1 end
    sample();task.wait(.1)
   until Vector2.new(root.Position.X-goal.X,root.Position.Z-goal.Z).Magnitude<1.5 or os.clock()>deadline
   result.leader={x=root.Position.X,y=root.Position.Y,z=root.Position.Z}
   assert(os.clock()<=deadline,'Leader stalled: '..label)
   table.insert(result.segments,{label=label,heroes=sample()})
  end
  local function allInside(m)
   local deadline=os.clock()+6;local inside=false
   repeat
    sample();inside=true
    for _,class in ipairs(classes)do
     local p=m:GetPivot():PointToObjectSpace(service.CompanionEvidence(owner,'a:'..class).position)
     inside=inside and math.abs(p.X)<7 and p.Z<18 and p.Z> -18
    end
    if not inside then task.wait(.1)end
   until inside or os.clock()>deadline
   assert(inside,'Not all five entered '..m.Name)
   table.insert(result.buildingChecks,{building=m.Name,state='inside',heroes=sample()})
  end
  local function allOutside(m)
   local deadline=os.clock()+8;local outside=false
   repeat
    sample();outside=true
    for _,class in ipairs(classes)do
     local p=m:GetPivot():PointToObjectSpace(service.CompanionEvidence(owner,'a:'..class).position)
     outside=outside and p.Z>23
    end
    if not outside then task.wait(.1)end
   until outside or os.clock()>deadline
   assert(outside,'Not all five exited '..m.Name)
   table.insert(result.buildingChecks,{building=m.Name,state='outside',heroes=sample()})
  end
  walk('Avenue to tavern',V(0,4,-820));walk('Tavern forecourt',V(-140,4,-820))
  walk('Tavern threshold',point(tavern,28));walk('Tavern interior',point(tavern,-12));allInside(tavern)
  walk('Tavern exit',point(tavern,50));allOutside(tavern);walk('Return avenue',V(0,4,-820));walk('Plaza',V(0,4,-1100))
  walk('Market avenue',V(300,4,-1100));walk('Forge outer approach',V(410,4,-1100))
  walk('Forge forecourt',V(410,4,-1000));walk('Forge threshold',point(forge,28))
  walk('Forge interior',point(forge,-12));allInside(forge);walk('Forge exit',point(forge,50));allOutside(forge)
  -- Retrace the east approach to avoid cutting across the market stalls.
  walk('Forge return avenue',V(410,4,-1100));walk('Exchange approach',V(300,4,-1100))
  walk('Exchange threshold',point(market,28));walk('Exchange interior',point(market,-12));allInside(market)
  walk('Exchange exit',point(market,50));allOutside(market)
  walk('Exchange return avenue',V(300,4,-1100))
  if options and options.islandOwnerUserId then
   -- Borrow existing terrain only. The synthetic combat session stays far away;
   -- this cannot establish real-player authorization, combat or quest rewards.
   local island
   for _,candidate in ipairs(world:GetChildren())do
    if candidate.Name=='PersonalGuild' and candidate:GetAttribute('OwnerUserId')==options.islandOwnerUserId then
     assert(island==nil,'Ambiguous owner island');island=candidate
    end
   end
   assert(island,'Owner island not loaded')
   local ground=island.Environment.Nature.Ground
   local origin=ground.Position+V(0,1,0)
   assert(math.abs(origin.X-7000)>100,'Owner island overlaps synthetic combat isolation strip')
   local spawn=island:FindFirstChild('PersonalGuildSpawn')
   assert(spawn and spawn:IsA('SpawnLocation'),'Missing owner spawn')
   assert((spawn.Position-(origin+V(0,1,23))).Magnitude<.01,'Unexpected island origin')
   local camp=island.Environment.Gameplay.CampClearing
   assert((camp.Position-(origin+V(0,.1,91))).Magnitude<.01,'Camp anchor changed')
   local city={town=world.City,spawn=world.City.CentralCitySpawn,portals={},guildAccessPortals={}}
   local marketGate,returnGate
   for _,gate in ipairs(game:GetService('CollectionService'):GetTagged('GuildborneTravelPortal'))do
    if gate:IsDescendantOf(world) and gate:IsA('BasePart')then
     table.insert(city.portals,gate)
     if gate:IsDescendantOf(city.town) and gate:GetAttribute('TravelDestination')=='Guild'then
      table.insert(city.guildAccessPortals,gate)
      if gate:GetAttribute('CityReturnStop')=='MarketDistrict'then marketGate=gate end
     elseif gate.Parent==world.GuildZone and gate:GetAttribute('TravelDestination')=='City'then returnGate=gate end
    end
   end
   assert(marketGate and returnGate,'Missing existing travel gates')
   local config=require(shared.Config.City)
   local stop=config.GuildPortalStops.MarketDistrict
   assert((marketGate.Position-V(stop.X,6,stop.Z)).Magnitude<.01,'Market gate differs from config')
   local run=game:GetService('RunService')
   local platform={Config=config,Civic=require(shared.Config.CivicCities),Rules=require(server.Systems.TravelRules)(config),
    Vector3=Vector3,CFrame=CFrame,RaycastParams=RaycastParams,OverlapParams=OverlapParams,Enum=Enum,Workspace=workspace,Now=os.clock,
    RunService={Heartbeat={Connect=function(_,callback)
     travelConnection=run.Heartbeat:Connect(callback);return travelConnection
    end}}}
   local plots={[owner]={origin=origin,model=island,spawn=spawn}}
   travelOwner=owner
   travel=require(server.Services.TravelService)(city,plots,service,nil,platform)
   result.island={ownerUserId=options.islandOwnerUserId,geometry=island:GetFullName(),combat='NOT_RUN',realPlayerAuthorization='NOT_RUN'}
   result.transitions={}
   local function resetAfterTransition(label)
    local counts={}
    for _,class in ipairs(classes)do
     local count=fixture.Heroes[class]:GetAttribute('RecoveryCount')or 0
     assert(count==initial[class]+1,class..' unexpected transition recovery count')
     counts[class]={before=initial[class],after=count};initial[class]=count
    end
    table.insert(result.transitions,{label=label,recoveries=counts})
    for _=1,20 do sample();task.wait(.1)end
   end
   assert(travel.Validate(owner,'NotAZone')=='InvalidZone','Invalid destination accepted')
   assert(travel.Validate(owner,'Guild')=='VisitStation','Distant portal accepted')
   walk('MarketDistrict portal',V(stop.X,4,stop.Z))
   local denied=travel.Validate(owner,'Guild');assert(denied==nil,'Guild travel denied: '..tostring(denied))
   assert(travel.Validate(owner,'Guild')=='TravelCooling','Travel cooldown not enforced')
   assert(travel.Travel(owner,'Guild'),'Guild travel failed')
   assert(owner:GetAttribute('CurrentZone')=='Guild' and owner.RespawnLocation==spawn,'Guild state/spawn mismatch')
   local landing=root.Position-origin
   assert(math.abs(landing.X)<.01 and (math.abs(landing.Z-23)<.01 or math.abs(landing.Z-14)<.01),'Unsafe/unexpected guild landing')
   resetAfterTransition('Validated MarketDistrict to borrowed owner island')
   walk('Island spawn path',origin+V(0,4,23))
   walk('Island camp entrance',origin+V(0,4,36))
   walk('Existing CampPath',origin+V(0,4,62))
   walk('Existing Goblin Camp clearing',camp.Position+V(0,4,0))
   local campDeadline=os.clock()+8
   local gathered=false
   repeat
    sample();gathered=true
    for _,class in ipairs(classes)do
     local position=service.CompanionEvidence(owner,'a:'..class).position
     local offset=camp.CFrame:PointToObjectSpace(position)
     gathered=gathered and math.abs(offset.X)<camp.Size.X/2 and math.abs(offset.Z)<camp.Size.Z/2
    end
    if not gathered then task.wait(.1)end
   until gathered or os.clock()>campDeadline
   assert(gathered,'Not all five reached existing camp clearing')
   result.campHeroes=sample()
   walk('Camp return path',origin+V(0,4,62));walk('Island return entrance',origin+V(0,4,36))
   walk('Island return spawn',origin+V(0,4,23))
   local access=assert(island:FindFirstChild('ReservedAccess',true),'Missing island ReservedAccess')
   local buildGround=assert(island:FindFirstChild('BuildGround',true),'Missing island BuildGround')
   local link=assert(world.GuildZone:FindFirstChild('IslandLink_'..options.islandOwnerUserId),'Missing owner island link')
   local bridge=assert(link:FindFirstChild('IslandBridge'),'Missing owner bridge')
   assert((access.Position-(origin+V(62,.1,4))).Magnitude<.01,'ReservedAccess anchor changed')
   assert((buildGround.Position-(origin+V(64,-1,0))).Magnitude<.01,'BuildGround anchor changed')
   assert(math.abs(bridge.Position.X-(origin.X+64))<.01,'Bridge belongs to different slot')
   walk('Island main path to access',origin+V(0,4,4))
   walk('ReservedAccess to build ground',origin+V(64,4,4))
   walk('Build ground to bridge mouth',origin+V(64,4,-34))
   walk('Owner IslandBridge',bridge.Position+V(0,4,0))
   walk('IslandPromenade junction',V(bridge.Position.X,4,-65))
   -- Approach from the east without walking through the solid arch pillar at X+5.
   walk('Promenade to Central City gate approach',V(returnGate.Position.X+8,4,returnGate.Position.Z))
   assert((root.Position-returnGate.Position).Magnitude<=10,'Return gate outside native prompt reach')
   result.promenadeWalk='completed: ordinary speed, recovery counter unchanged'
   local returnDenied=travel.Validate(owner,'City');assert(returnDenied==nil,'City return denied: '..tostring(returnDenied))
   assert(travel.Travel(owner,'City'),'City return failed')
   assert(owner:GetAttribute('CurrentZone')=='City' and owner.RespawnLocation==city.spawn,'City state/spawn mismatch')
   local at=root.Position
   assert((at-V(stop.ReturnX,config.Destinations.City.Y,stop.ReturnZ)).Magnitude<.01
    or (at-V(stop.FallbackX,config.Destinations.City.Y,stop.FallbackZ)).Magnitude<.01,'MarketDistrict return not retained')
   resetAfterTransition('Validated remembered MarketDistrict return')
   walk('MarketDistrict return avenue',V(300,4,-1100))
  end
  walk('Return Plaza',V(0,4,-1100))
  task.wait(2);result.finalHeroes=sample()
 end,debug.traceback)
 if travelConnection then travelConnection:Disconnect()end
 if travel then travel.Remove(travelOwner)end
 if service then service.Destroy()end
 fixture:Destroy();result.ok=ok;result.problem=if ok then nil else tostring(problem)
 result.cleanup=world:FindFirstChild('P1FiveHeroCityTraversal')==nil and (not travelConnection or not travelConnection.Connected)
 return result
end
