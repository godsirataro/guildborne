--!nocheck
-- Synthetic classed owners, real CombatService/Coordinator effects and isolated Memory PDS.
-- No HeroService Heartbeat: explicit bounded ticks permit complete fixture cleanup.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0,"Local Studio only")
local server=game.ServerScriptService.Server
assert(require(server.Config.Runtime).StudioPersistence=="Memory","Memory candidate required")
local shared=game.ReplicatedStorage.Shared
local U=require(shared.Util.TableUtil)
local C=require(server.Config.Content)
local Expansion=require(shared.Data.Expansion)
local Gear=require(shared.Data.Equipment)(C,Expansion,require(shared.Data.StatusPoints))
local Schema=require(server.Systems.ProfileSchema)(C,U,Gear,Expansion,require(server.Systems.ExpansionSchema)(C,U,Expansion))
local Claims=require(server.Systems.SharedPvEClaims).new(C,U,require(server.Services.EconomyService)(C,U))
local Memory=require(server.Persistence.MemoryStore)
local Settlement=require(server.Systems.SharedPvESettlement)
local profiles,settlements,audit=Memory(U),Memory(U),Memory(U)
local function makeData()
 return require(server.Services.PlayerDataService)({Util=U,Content=C,Schema=Schema,SharedPvEClaims=Claims,Protocol=require(shared.Network.Protocol),
  Store=profiles,AuditStore=audit,Config={MaxAttempts=1,RetryBaseSeconds=0,LeaseSeconds=180,LeaseSafetySeconds=10,AuditPageSize=64},
  Now=function()return 1000 end,Wait=function()end,Jitter=function()return 0 end,Log=function()end,OnCommitted=function()end,
  Commands={apply=function()error("No public fixture command")end}})
end
local Data=makeData()
local repo=require(server.Services.SharedPvESettlementStore)(settlements,U,Settlement,"scene_fixture",2)
local function makeDelivery(data)
 return require(server.Services.SharedPvERewardAdapter)({Data=data,Repository=repo,Claims=Claims,Util=U,Namespace="scene_fixture"})
end
local delivery=makeDelivery(Data)
local world=workspace:WaitForChild("GuildborneWorld",5);assert(world,"World missing")
local root=Instance.new("Model");root.Name="SharedRewardsFlowFixture";root.Parent=world
local origin=Vector3.new(6000,0,6500)
local floor=Instance.new("Part");floor.Name="Ground";floor.Anchored=true;floor.Size=Vector3.new(120,2,150);floor.Position=origin+Vector3.new(0,-1,75);floor.Parent=root
local templates=game.ServerStorage.GuildborneArtKit
local owners={};local coordinator=nil;local binding=nil;local sceneEnemy=nil
local effects,legacyRewards=0,0
local result={synthetic=true,isolatedMemoryOnly=true,owners=2,actors=2,companions=0,productionWrites=0,fixedTestBudget={xp=11,gold=7,herb=3},heroService=false}
local function totals()
 local out={xp=0,gold=0,herb=0,receipts=0}
 for _,o in ipairs(owners)do
  local record=profiles.Read("p:"..o.player.UserId);assert(Schema.validate(record,o.player.UserId),"Invalid persisted record")
  out.xp+=record.data.character.xp;out.gold+=record.data.currencies.gold;out.herb+=record.data.inventory.stacks.herb or 0
  out.receipts+=U.count(record.data.sharedPvEClaims and record.data.sharedPvEClaims.receipts or {})
 end
 return out
end
local ok,problem=pcall(function()
 local enemies=require(server.Services.EnemyService)(templates).create(root,origin,0)
 sceneEnemy=enemies[1];for i=2,#enemies do enemies[i].model:Destroy()end
 sceneEnemy.plot=root
 -- Keep the actual base scout HP/stats. No fabricated damage or death is applied.
 result.initialEnemyHP=sceneEnemy.health
 local scene={plot=root,origin=origin,enemies={sceneEnemy}}
 coordinator=require(server.Services.SharedCombatCoordinator)({Registry=require(server.Systems.SharedEncounterIdentity)(),MakeRuntime=require(server.Services.SharedEncounterRuntime),Scene=scene,
  Session=function(player)return Data.Sessions[player.UserId]end,
  ContainsPosition=function(position)local p=position-origin;return math.abs(p.X)<50 and p.Z>40 and p.Z<130 and p.Y>0 and p.Y<30 end,
  MakeRewards=function(context)
   binding=require(server.Services.SharedCombatRewards)({Policy=context.Policy,EncounterToken=context.EncounterToken,Enemy=context.Enemy,OwnerRoster=context.OwnerRoster,
    Now=os.clock,EncounterId="scout_generation_1",RotationSeed=0,Budget={xp=11,gold=7,items={{itemId="herb",count=3}}},
    MakeParticipation=require(server.Systems.SharedEncounterParticipation),Settlement=Settlement,Repository=repo,Delivery=delivery,Util=U})
   local observe=binding.Observe
   binding.Observe=function(name,a,b,value)if name=="damage_dealt"or name=="healing_done"then effects+=1 end;observe(name,a,b,value)end
   return binding
  end,
  MakeCombat=function(context)return require(server.Services.CombatService)(templates,function()legacyRewards+=1 end,function()legacyRewards+=1 end,nil,nil,context)end})
 local Rig=require(server.Services.HeroRig)
 for index=1,2 do
  local id=-94900-index;local r=Schema.new(id,1000);local def=C.Character.Classes.Warrior
  r.data.character.classId="Warrior";r.data.character.classPathId=def.PathId;r.data.character.skillId=def.SkillId
  assert(Schema.validate(r,id),"Classed synthetic seed invalid")
  profiles.Update("p:"..id,function()return r end);assert(Data.Load(id,"fixture_"..index)=="OK")
  local character=Rig.Build("Warrior");character.Name="SyntheticOwner"..index;character.Parent=root
  character:PivotTo(CFrame.new(sceneEnemy.root.Position+Vector3.new(if index==1 then -2 else 2,1,0)))
  local body=character:FindFirstChild("HumanoidRootPart");body.Anchored=true
  local player={UserId=id,Character=character};local data=Data.Sessions[id].record.data
  local s={alive=true,active=true,plot=root,origin=origin,heroes={},characterData=data.character,playerBuild=Gear.build(data,data.character),playerLoadout=Gear.loadout(data,data.character),
   extra=Gear.extras(data,data.character),expansionData=data.expansion,enemies={},campEnemies={}}
  table.insert(owners,{player=player,s=s,body=body})
 end
 local before=totals();local deadline=os.clock()+25;local ticks=0;local accepted={};local reasons={}
 while os.clock()<deadline and sceneEnemy.health>0 do
  local stamp=os.clock();ticks+=1
  for _,o in ipairs(owners)do local claimed,valid,state=coordinator.Prepare(o.player,o.s,o.body,true,stamp,function()end);assert(claimed and valid and state=="Prepared",tostring(state))end
  local stepped,why=coordinator.Tick(stamp);assert(stepped,why)
  for _,o in ipairs(owners)do
   local claimed,hit,why=coordinator.Action(o.player,o.s,"Basic",os.clock(),"player")
   reasons[tostring(why)]=(reasons[tostring(why)]or 0)+1
   if claimed and hit then accepted[o.player.UserId]=(accepted[o.player.UserId]or 0)+1 end
   local abilityClaimed,abilityHit,abilityWhy=coordinator.Action(o.player,o.s,"Ability",os.clock(),"player")
   reasons["Ability:"..tostring(abilityWhy)]=(reasons["Ability:"..tostring(abilityWhy)]or 0)+1
   if abilityClaimed and abilityHit then accepted[o.player.UserId]=(accepted[o.player.UserId]or 0)+1 end
  end
  task.wait(.21)
 end
 result.actionReasons=reasons;result.enemyHP=sceneEnemy.health;result.acceptedActions=accepted;result.effects=effects;result.ticks=ticks
 result.ownerState={}
 for _,o in ipairs(owners)do local a=o.s.playerCombat;result.ownerState[tostring(o.player.UserId)]={health=a and a.health,active=o.s.active,distance=(o.body.Position-sceneEnemy.root.Position).Magnitude}end
 assert(sceneEnemy.health==0,"Actual combat did not defeat scout within 25 seconds")
 for _,o in ipairs(owners)do assert((accepted[o.player.UserId]or 0)>0,"An owner never landed a real action")end
 local state=binding.State();assert(state.snapshot and #state.snapshot.owners==2,"Both owners must qualify")
 assert(effects>0 and legacyRewards==0,"Unexpected legacy reward path")
 assert(U.equal(before,totals()),"Combat sink granted before Pump")
 local beforeRecord,beforeStatus=repo.Read("scout_generation_1")
 assert(beforeRecord==nil and beforeStatus=="Missing","Combat sink prepared before Pump")
 result.noGrantOrSettlementBeforePump=true
 -- External worker only, after synchronous combat has returned. No storage in sinks.
 for _=1,6 do coordinator.PumpRewards();if binding.State().status=="Delivered"then break end;task.wait(.05)end
 assert(binding.State().status=="Delivered",binding.State().status)
 for _,o in ipairs(owners)do
  local persisted=profiles.Read("p:"..o.player.UserId);assert(U.equal(persisted,Data.Sessions[o.player.UserId].record),"Session/persisted record mismatch")
  assert(delivery.Deliver(o.player.UserId,"scout_generation_1")=="Committed","Duplicate claim failed")
 end
 local first=totals();assert(first.xp-before.xp==11 and first.gold-before.gold==7 and first.herb-before.herb==3 and first.receipts==2,"Budget or receipt mismatch")
 coordinator.Close()
 for _,o in ipairs(owners)do assert(Data.Close(o.player.UserId)=="OK")end
 Data=makeData();delivery=makeDelivery(Data)
 for _,o in ipairs(owners)do
  assert(Data.Load(o.player.UserId,"replacement_"..o.player.UserId)=="OK")
  assert(delivery.Deliver(o.player.UserId,"scout_generation_1")=="Committed")
  assert(U.equal(profiles.Read("p:"..o.player.UserId),Data.Sessions[o.player.UserId].record),"Reconstructed session mismatch")
 end
 assert(U.equal(first,totals()),"Reconstruction replay duplicated rewards")
 result.ticks=ticks;result.effects=effects;result.acceptedActions=accepted;result.enemyHP=sceneEnemy.health
 result.delta={xp=first.xp-before.xp,gold=first.gold-before.gold,herb=first.herb-before.herb,receipts=first.receipts}
 result.duplicateStable=true;result.memoryServiceReconstructionStable=true;result.sessionMatchesPersisted=true
end)
if coordinator then pcall(coordinator.Close)end
local remaining={};for id in pairs(Data.Sessions)do table.insert(remaining,id)end
for _,id in ipairs(remaining)do local s=Data.Sessions[id];delivery.Remove(id,s);pcall(Data.Close,id)end
root:Destroy()
result.ok=ok;result.problem=if ok then nil else tostring(problem);result.legacyRewardCalls=legacyRewards
result.cleanup=world:FindFirstChild("SharedRewardsFlowFixture")==nil
result.profileSessionsClosed=next(Data.Sessions)==nil
result.schedulerCleanup="No Heartbeat or event connections created; explicit ticks only"
return result
