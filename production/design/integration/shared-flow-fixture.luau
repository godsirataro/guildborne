--!nocheck
-- Seven synthetic owners, real domain modules. No player profile or economic grant.
local server=if game then game.ServerScriptService.Server else nil
local Registry=if game then require(server.Systems.SharedEncounterIdentity) else require("../../../src/server/Systems/SharedEncounterIdentity")
local Runtime=if game then require(server.Services.SharedEncounterRuntime) else require("../../../src/server/Services/SharedEncounterRuntime")
local Participation=if game then require(server.Systems.SharedEncounterParticipation) else require("../../../src/server/Systems/SharedEncounterParticipation")
local Settlement=if game then require(server.Systems.SharedPvESettlement) else require("../../../src/server/Systems/SharedPvESettlement")
local Repository=if game then require(server.Services.SharedPvESettlementStore) else require("../../../src/server/Services/SharedPvESettlementStore")
local Memory=if game then require(server.Persistence.MemoryStore) else require("../../../src/server/Persistence/MemoryStore")
local Util=if game then require(game.ReplicatedStorage.Shared.Util.TableUtil) else require("../../../src/shared/Util/TableUtil")
local Targeting=if game then require(server.Systems.CombatTargeting) else require("../../../src/server/Systems/CombatTargeting")
local DamageFactory=if game then require(server.Systems.CombatDamage) else require("../../../src/server/Systems/CombatDamage")
local registry=Registry();local policy=registry.policy()
local target=Targeting(function(a,b)return math.abs(a.x-b.x)end,nil,nil,policy)
local clock=0;local sequence=0;local contribution
local damage=DamageFactory({valid=function(n)return type(n)=="number"and n>0 end,damage=function(a,_d,m)return a*m end},target,function(event,a,b,amount)
 if event=="damage_dealt"or event=="healing_done"then sequence+=1;assert(contribution.Observe(sequence,event,a,b,amount))end
end)
local enemy={id="shared_enemy",owner=0,kind="Enemy",health=140,active=true,state="Idle",stats={MaxHealth=140,Attack=10,Defense=0},threat={},x=0}
local ticks=0;local ownerSteps=0
local runtime=assert(Runtime({Registry=registry,EnemyStep=function(_stamp,allies,_enemies)
 ticks+=1
 if enemy.health>0 then for _,a in ipairs(allies)do if a.owner==1 and a.id=="player"then damage.hit(enemy,a,100,1,clock);break end end end
end,OwnerStep=function(owner,_session,_stamp,own,allies,_enemies)
 ownerSteps+=1
 local actor=own[2]
 if owner==7 then local recipient=target.heal(actor,allies,100);if recipient then damage.heal(actor,recipient,100,10,clock)end
 elseif enemy.health>0 then damage.hit(actor,enemy,100,1,clock)end
end}))
contribution=Participation(policy,function()return clock end,{totalEnemyHP=140,encounterToken=runtime.EncounterToken()})
local sessions={};local actors={}
for owner=1,7 do
 local roster={}
 for _,id in ipairs({"player","a:Warrior"})do table.insert(roster,{id=id,owner=owner,kind="Hero",health=100,active=true,state="Idle",stats={MaxHealth=100,Attack=5,Defense=0},x=owner})end
 sessions[owner]={};actors[owner]=roster
 assert(runtime.Join(owner,sessions[owner],roster))
end
assert(runtime.AddEnemy(enemy))
for tick=1,12 do
 clock=tick*.2
 local before=ticks;assert(runtime.Tick(clock));assert(ticks==before+1)
 assert(not runtime.Tick(clock));assert(ticks==before+1)
 if tick==2 then assert(contribution.Leave(6));assert(runtime.Leave(6,sessions[6]));assert(not target.valid(actors[6][2],enemy,100))end
 if enemy.health==0 then break end
end
assert(enemy.health==0,"single shared HP never defeated")
local frozen=assert(contribution.Freeze());assert(#frozen.owners==7,"earned departed/solo/healer share missing")
for i,id in ipairs(frozen.owners)do assert(id==i)end
local repo=Repository(Memory(Util),Util,Settlement,"flow_fixture")
local snapshot={version=1,encounterId="fixture_generation_1",owners=frozen.owners,rotationSeed=3,xp=600,gold=7,items={{itemId="training_sword",count=1}}}
local prepared,status=repo.Prepare(snapshot);assert(status=="Prepared")
local sumXP,sumGold,sumItems=0,0,0
for _,allocation in ipairs(prepared.allocations)do sumXP+=allocation.xp;sumGold+=allocation.gold;sumItems+=allocation.items.training_sword or 0 end
assert(sumXP==600 and sumGold==7 and sumItems==1)
local retry,repeatStatus=repo.Prepare(snapshot);assert(repeatStatus=="Prepared"and Util.equal(prepared,retry))
runtime.Close();assert(not target.valid(actors[1][2],enemy,100))
local result={owners=#frozen.owners,enemyTicks=ticks,ownerSteps=ownerSteps,xp=sumXP,gold=sumGold,itemUnits=sumItems,enemyHealth=enemy.health,profileWrites=0,synthetic=true,settlementOnly=true}
if not game then print("PASS shared flow: seven owners, NPC credit, healer, departed contributor, single HP/tick, conserved replay-safe preparation")end
return result
