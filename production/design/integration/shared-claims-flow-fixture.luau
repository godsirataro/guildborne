--!nocheck
-- Synthetic isolated Memory profiles; exercises real repository, profile service and adapter.
local server=if game then game.ServerScriptService.Server else nil
local shared=if game then game.ReplicatedStorage.Shared else nil
if game then assert(game.PlaceId==0 and game.GameId==0)end
local U=if game then require(shared.Util.TableUtil)else require("../../../src/shared/Util/TableUtil")
local C=if game then require(server.Config.Content)else require("../../../src/server/Config/Content")
local Expansion=if game then require(shared.Data.Expansion)else require("../../../src/shared/Data/Expansion")
local Status=if game then require(shared.Data.StatusPoints)else require("../../../src/shared/Data/StatusPoints")
local GearFactory=if game then require(shared.Data.Equipment)else require("../../../src/shared/Data/Equipment")
local SchemaFactory=if game then require(server.Systems.ProfileSchema)else require("../../../src/server/Systems/ProfileSchema")
local ExpansionSchema=if game then require(server.Systems.ExpansionSchema)else require("../../../src/server/Systems/ExpansionSchema")
local Economy=if game then require(server.Services.EconomyService)else require("../../../src/server/Services/EconomyService")
local Claims=if game then require(server.Systems.SharedPvEClaims)else require("../../../src/server/Systems/SharedPvEClaims")
local Adapter=if game then require(server.Services.SharedPvERewardAdapter)else require("../../../src/server/Services/SharedPvERewardAdapter")
local DataFactory=if game then require(server.Services.PlayerDataService)else require("../../../src/server/Services/PlayerDataService")
local Memory=if game then require(server.Persistence.MemoryStore)else require("../../../src/server/Persistence/MemoryStore")
local Settlement=if game then require(server.Systems.SharedPvESettlement)else require("../../../src/server/Systems/SharedPvESettlement")
local Repository=if game then require(server.Services.SharedPvESettlementStore)else require("../../../src/server/Services/SharedPvESettlementStore")
local Protocol=if game then require(shared.Network.Protocol)else require("../../../src/shared/Network/Protocol")
local schema=SchemaFactory(C,U,GearFactory(C,Expansion,Status),Expansion,ExpansionSchema(C,U,Expansion))
local claims=Claims.new(C,U,Economy(C,U))
local profiles=Memory(U);local settlements=Memory(U);local audit=Memory(U)
local now=1000
local function makeData()
 return DataFactory({Util=U,Content=C,Schema=schema,SharedPvEClaims=claims,Protocol=Protocol,
  Store=profiles,AuditStore=audit,Config={MaxAttempts=1,RetryBaseSeconds=0,LeaseSeconds=180,LeaseSafetySeconds=10,AuditPageSize=64},
  Now=function()return now end,Wait=function()end,Jitter=function()return 0 end,Log=function()end,OnCommitted=function()end,
  Commands={apply=function()error("No public command in isolated fixture")end}})
end
local owners={}
for owner=1,7 do
 local r=schema.new(owner,now);local d=r.data;local def=C.Character.Classes.Warrior
 d.character.classId="Warrior";d.character.classPathId=def.PathId;d.character.skillId=def.SkillId
 d.adventurers["a:Warrior"]={id="a:Warrior",name="Fixture",rank="F",classId="Warrior",level=1,xp=0,baseStats=U.copy(C.Adventurers.Warrior.Stats),equipmentSlots={}}
 d.progression.recruitedClasses.Warrior=true
 assert(schema.validate(r,owner))
 profiles.Update("p:"..owner,function()return r end)
 table.insert(owners,{ownerId=owner,actorIds={"a:Warrior","player"}})
end
local repo=Repository(settlements,U,Settlement,"claims_fixture",2)
local record,status=repo.Prepare({version=2,xpPolicy="equal-actors-v1",encounterId="generation_1",owners=owners,rotationSeed=3,xp=600,gold=7,items={{itemId="herb",count=13}}})
assert(record and status=="Prepared")
local data=makeData()
local adapter=Adapter({Data=data,Repository=repo,Claims=claims,Util=U,Namespace="claims_fixture"})
local function totals()
 local xp,gold,items,receipts=0,0,0,0
 for owner=1,7 do
  local r=profiles.Read("p:"..owner);assert(schema.validate(r,owner))
  xp+=r.data.character.xp+r.data.adventurers["a:Warrior"].xp
  gold+=r.data.currencies.gold;items+=r.data.inventory.stacks.herb or 0
  receipts+=U.count(r.data.sharedPvEClaims and r.data.sharedPvEClaims.receipts or {})
 end
 return {xp=xp,gold=gold,items=items,receipts=receipts}
end
for owner=1,7 do
 assert(data.Load(owner,"fixture_"..owner)=="OK")
 assert(adapter.Deliver(owner,"generation_1")=="Committed")
 assert(adapter.Deliver(owner,"generation_1")=="Committed")
 assert(data.FlushAudit(owner)=="OK")
 assert(data.Close(owner)=="OK")
end
local first=totals();assert(first.xp==600 and first.gold==7 and first.items==13 and first.receipts==7)
data=makeData();adapter=Adapter({Data=data,Repository=repo,Claims=claims,Util=U,Namespace="claims_fixture"})
for owner=1,7 do
 assert(data.Load(owner,"replacement_"..owner)=="OK")
 assert(adapter.Deliver(owner,"generation_1")=="Committed")
 assert(data.Close(owner)=="OK")
end
local second=totals();assert(U.equal(first,second))
local result={ok=true,owners=7,actors=14,totals=second,rejoinReplayConserved=true,synthetic=true,isolatedMemoryOnly=true,productionWrites=0}
if not game then print("PASS isolated shared claims: seven owners/fourteen actors, exact pools, seven receipts, session recreation replay")end
return result
