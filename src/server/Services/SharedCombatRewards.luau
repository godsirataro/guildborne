--!strict
-- Single basic encounter, optional private binding. Sinks never call storage.
return function(d:any):any
 local U=d.Util;local enemy=d.Enemy
 assert(type(enemy)=="table"and enemy.kind=="Enemy"and not enemy.boss and not enemy.templateId and not enemy.towerFloor,"Basic enemy required")
 local base={version=2,xpPolicy="equal-actors-v1",encounterId=d.EncounterId,rotationSeed=d.RotationSeed,xp=d.Budget.xp,gold=d.Budget.gold,items=U.copy(d.Budget.items)}
 local probe=U.copy(base);probe.owners={{ownerId=1,actorIds={"player"}}};assert(d.Settlement.Build(probe),"Invalid fixed budget")
 local ledger=d.MakeParticipation(d.Policy,d.Now,{totalEnemyHP=enemy.stats.MaxHealth,encounterToken=d.EncounterToken})
 local seq=0;local rosters:any={};local snapshot:any=nil;local expected:any=nil;local closed=false;local final=false;local busy=false;local prepared=false;local fault:string?=nil
 local deliveries:any={};local cursor=1;local status="Observing"
 local function nextSeq():number seq+=1;assert(seq<=2147483647,"Event sequence exhausted");return seq end
 local function fail(reason:string)fault=reason;status="Faulted"end
 local function roster(owner:number):any
  if rosters[owner]then return rosters[owner]end
  local ids=d.OwnerRoster(owner)
  if type(ids)~="table"then return nil end
  local test=U.copy(base);test.owners={{ownerId=owner,actorIds=ids}}
  local built=d.Settlement.Build(test);return if built then built.snapshot.owners[1]else nil
 end
 local R={}
 function R.Observe(event:string,a:any,b:any,amount:any)
  if closed or final or fault then return end
  if event=="damage_dealt"or event=="healing_done"then
   local owner=if a.kind=="Hero"then a.owner elseif b.kind=="Hero"then b.owner else nil
   if owner==nil then return end
   local frozen=roster(owner);if not frozen then fail("MissingTrustedRoster");return end
   local accepted=ledger.Observe(nextSeq(),event,a,b,amount)
   if accepted and not rosters[owner]then rosters[owner]=U.copy(frozen)end
  elseif event=="enemy_defeated"and b==enemy and enemy.health==0 and d.Policy.key(enemy)~=nil then
   -- CombatDamage emits this after the lethal damage has been credited.
   final=true;local eligible=ledger.Freeze()
   if not eligible then fail("EligibilityUnavailable");return end
   if #eligible.owners==0 then status="NoEligibleOwners";return end
   local candidate=U.copy(base);candidate.owners={}
   for _,owner in ipairs(eligible.owners)do
    if not rosters[owner]then fail("MissingFrozenRoster");return end
    table.insert(candidate.owners,U.copy(rosters[owner]))
   end
   local built=d.Settlement.Build(candidate);if not built then fail("InvalidSettlement");return end
   snapshot=U.copy(built.snapshot);expected=built;status="PendingPreparation"
   for _,owner in ipairs(eligible.owners)do table.insert(deliveries,{ownerId=owner,committed=false,code="Pending"})end
  end
 end
 function R.Recover(actor:any,amount:any)
  if closed or final or fault or actor.kind~="Hero"then return end
  ledger.Recover(nextSeq(),actor,amount)
 end
 function R.Leave(owner:number)if not final and not closed and not fault then ledger.Leave(owner)end end
 function R.Close()closed=true;if not final then status="ClosedWithoutSettlement"end end
 -- Explicit worker entrypoint; caller may schedule it outside the combat mutation.
 -- One recipient per invocation keeps unavailable recipients from starving others.
 function R.Pump():(boolean,string)
  if busy then return false,"Busy"end
  if fault or not snapshot then return false,fault or status end
  busy=true
  local ok=pcall(function()
   if not prepared then
    local record,state=d.Repository.Prepare(U.copy(snapshot))
    if state~="Prepared"then
     record,state=d.Repository.Read(snapshot.encounterId)
     if state~="Found"then status="PendingPreparation";return end
    end
    if not U.equal(record,expected)then fail("SettlementConflict");return end
    prepared=true;status="PendingDelivery"
   end
   local entry=deliveries[cursor];cursor=cursor%#deliveries+1
   if not entry.committed then
    local outcome,code=d.Delivery.Deliver(entry.ownerId,snapshot.encounterId)
    entry.code=code;entry.committed=outcome=="Committed"
   end
   local all=true;for _,recipient in ipairs(deliveries)do if not recipient.committed then all=false end end
   if all then status="Delivered"end
  end)
  busy=false
  if not ok then return false,"WorkerUnavailable"end
  return not fault,status
 end
 function R.State():any return {status=status,fault=fault,closed=closed,prepared=prepared,snapshot=U.copy(snapshot),deliveries=U.copy(deliveries)}end
 return R
end
