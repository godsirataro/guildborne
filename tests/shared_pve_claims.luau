--!strict
return function(test:any,eq:any)
 local U=require("../src/shared/Util/TableUtil")
 local C=require("../src/server/Config/Content")
 local E=require("../src/shared/Data/Expansion")
 local G=require("../src/shared/Data/Equipment")(C,E,require("../src/shared/Data/StatusPoints"))
 local Schema=require("../src/server/Systems/ProfileSchema")(C,U,G,E,require("../src/server/Systems/ExpansionSchema")(C,U,E))
 local ClaimsModule=require("../src/server/Systems/SharedPvEClaims")
 local claims=ClaimsModule.new(C,U,require("../src/server/Services/EconomyService")(C,U))
 local P=require("../src/shared/Network/Protocol")
 local Settlement=require("../src/server/Systems/SharedPvESettlement")
 local MakeData=require("../src/server/Services/PlayerDataService")
 local MakeAdapter=require("../src/server/Services/SharedPvERewardAdapter")
 local function fixture(owner:number):any
  local r=Schema.new(owner,1000);local c=r.data.character;local def=C.Character.Classes.Warrior
  c.classId="Warrior";c.classPathId=def.PathId;c.skillId=def.SkillId
  return r
 end
 local function claim(owner:number,id:string?):any return {namespace="test",encounterId=id or "encounter",settlementVersion=2,xpPolicy="equal-actors-v1",allocation={ownerId=owner,xp=10,gold=7,items={herb=2},actorXP={player=10}}}end
 local function command(r:any,c:any):any return {version=1,requestId="claim:"..r.revision,revision=r.revision,action="CommitSharedPvE",args=c}end
 local function harness():any
  local h:any={records={["p:1"]=fixture(1),["p:2"]=fixture(2)},now=1000,mode="ok",audit={}}
  local store={Update=function(key:any,transform:any):any
   if h.mode=="before"then error("before")end
   if h.replay then transform(U.copy(h.records[key]))end
   local r=transform(U.copy(h.records[key]));if r then h.records[key]=U.copy(r)end
   if h.mode=="after"then error("after")end;return U.copy(r)
  end}
  function h.make():any return MakeData({Util=U,Content=C,SharedPvEClaims=claims,Schema=Schema,Protocol=P,
   Config={MaxAttempts=1,RetryBaseSeconds=0,LeaseSeconds=180,LeaseSafetySeconds=10,AuditPageSize=64},
   Store=store,AuditStore={Update=function(key:any,f:any):any local r=f(h.audit[key]);h.audit[key]=r;return r end},
   Now=function()return h.now end,Wait=function()end,Jitter=function()return 0 end,Log=function()end,OnCommitted=function()end,
   Commands={apply=function(record:any,cmd:any):any local copy=U.copy(record);copy.data.settings.language=cmd.args.language;return copy,{code="OK"},{}end}})end
  h.data=h.make();eq(h.data.Load(1,"one"),"OK");eq(h.data.Load(2,"two"),"OK")
  function h.record(owner:number?):any return h.data.Sessions[owner or 1].record end
  function h.commit(c:any):string return h.data.CommitSharedPvE(c.allocation.ownerId,command(h.record(c.allocation.ownerId),c))end
  function h.adapter():any
   return MakeAdapter({Data=h.data,Util=U,Claims=claims,Namespace="test",Repository={Read=function(id:any):any
    if h.readHook then h.readHook()end
    local r=Settlement.Build({version=2,xpPolicy="equal-actors-v1",encounterId=id,owners={{ownerId=1,actorIds={"player"}},{ownerId=2,actorIds={"player"}}},rotationSeed=0,xp=20,gold=14,items={{itemId="herb",count=4}}})
    return r,"Found"
   end}})
  end
  return h
 end
 test("atomic claim uses frozen recipients and durable receipt, public protocol rejects",function()
  local h=harness();local before=U.copy(h.record());local c=claim(1);local cmd=command(before,c)
  eq(P.validate(cmd),false);eq(h.data.CommitSharedPvE(1,cmd),"OK")
  local d=h.record().data;eq(d.character.xp,10);eq(d.currencies.gold,7);eq(d.statistics.goldCreated,7);eq(d.inventory.stacks.herb,2)
  eq(d.sharedPvEClaims.receipts["test:encounter"],c);eq(Schema.validate(h.record(),1),true)
  eq(h.data.CommitSharedPvE(1,cmd),"AlreadyCommitted");eq(h.record().revision,1)
  c.allocation.gold=8;eq(h.commit(c),"SharedClaimConflict");eq(d.currencies.gold,7)
 end)
 test("durable claim survives recent32 eviction and fresh session epoch",function()
  local h=harness();local c=claim(1);local old=command(h.record(),c);eq(h.commit(c),"OK")
  for i=1,40 do eq(h.data.Execute(1,{version=1,requestId="lang"..i,revision=h.record().revision,action="SetLanguage",args={language=if i%2==0 then "en"else "th"}}),"OK")end
  eq(#h.record().operations.recentResults,32);eq(h.data.CommitSharedPvE(1,old),"AlreadyCommitted")
  eq(h.data.Close(1),"OK");h.data=h.make();eq(h.data.Load(1,"new"),"OK");eq(h.data.CommitSharedPvE(1,old),"AlreadyCommitted");eq(h.record().data.currencies.gold,7)
 end)
 test("adapter recreation and pre/post commit exceptions deliver once",function()
  for _,mode in ipairs({"before","after"})do
   local h=harness();h.mode=mode;h.replay=true;local a=h.adapter();local status,code=a.Deliver(1,"encounter")
   eq(status,"Retry");eq(code,"SavePending");h.mode="ok";a=h.adapter();eq(a.Deliver(1,"encounter"),"Committed")
   eq(h.record().data.character.xp,10);eq(h.record().data.currencies.gold,7);eq(h.record().data.inventory.stacks.herb,2)
   eq(h.data.Close(1),"OK");h.data=h.make();eq(h.data.Load(1,"rejoin"),"OK");eq(h.adapter().Deliver(1,"encounter"),"Committed");eq(h.record().data.currencies.gold,7)
  end
 end)
 test("adapter handles thrown commit response and retains immutable command across uncertainty",function()
  for _,after in ipairs({false,true})do
   local h=harness();local original=h.data.CommitSharedPvE;local seen=nil
   h.data.CommitSharedPvE=function(owner:any,cmd:any):any seen=U.copy(cmd);if after then original(owner,cmd)end;error("unknown response")end
   local a=h.adapter();local status,code=a.Deliver(1,"encounter");eq(status,"Retry");eq(code,"CommitUnavailable")
   h.data.CommitSharedPvE=function(owner:any,cmd:any):any eq(cmd,seen);return original(owner,cmd)end
   eq(a.Deliver(1,"encounter"),"Committed");eq(h.record().data.currencies.gold,7)
   h.data.CommitSharedPvE=original
   eq(h.adapter().Deliver(1,"encounter"),"Committed");eq(h.record().data.character.xp,10)
  end
 end)
 test("unknown pre-commit result resolves after unrelated revision without blocking other claims",function()
  local h=harness();local original=h.data.CommitSharedPvE
  h.data.CommitSharedPvE=function()error("before submit")end
  local a=h.adapter();eq(a.Deliver(1,"encounter"),"Retry");h.data.CommitSharedPvE=original
  eq(h.data.Execute(1,{version=1,requestId="shared-attempt:1",revision=h.record().revision,action="SetLanguage",args={language="th"}}),"OK")
  eq(a.Deliver(1,"second"),"Committed");eq(a.Deliver(1,"encounter"),"Committed");eq(h.record().data.currencies.gold,14)
 end)
 test("public request IDs cannot poison fresh private claim attempts",function()
  for _,requestId in ipairs({"shared:1","shared-attempt:1"})do
   local h=harness()
   eq(h.data.Execute(1,{version=1,requestId=requestId,revision=0,action="SetLanguage",args={language="th"}}),"OK")
   local a=h.adapter();eq(a.Deliver(1,"encounter"),"Committed");eq(h.record().data.currencies.gold,7)
   eq(h.adapter().Deliver(1,"encounter"),"Committed");eq(h.record().data.currencies.gold,7)
  end
  local h=harness();for i=1,32 do eq(h.data.Execute(1,{version=1,requestId="shared-attempt:"..i,revision=h.record().revision,action="SetLanguage",args={language="th"}}),"OK")end
  eq(h.adapter().Deliver(1,"encounter"),"Committed");eq(h.record().data.currencies.gold,7)
 end)
 test("yielded repository Read cannot submit into unrelated pending save",function()
  local h=harness();local a=h.adapter();h.readHook=function()coroutine.yield()end
  local co=coroutine.create(function()local status,code=a.Deliver(1,"encounter");eq(status,"Retry");eq(code,"SavePending")end)
  assert(coroutine.resume(co));h.mode="after"
  eq(h.data.Execute(1,{version=1,requestId="interleave",revision=h.record().revision,action="SetLanguage",args={language="th"}}),"SavePending")
  assert(coroutine.resume(co));h.mode="ok";h.readHook=nil;eq(a.Deliver(1,"encounter"),"Committed");eq(h.record().data.currencies.gold,7)
 end)
 test("adapter bounds and exact-session cleanup do not cancel replacement work",function()
  local h=harness();local fake:any={Sessions={},CommitSharedPvE=function()error("before submit")end}
  local fakeClaims={validateClaim=function()return true end,check=function()return nil end}
  local a=MakeAdapter({Data=fake,Util=U,Claims=fakeClaims,Namespace="test",Repository={Read=function(id:any):any
   local alloc={};for i=1,33 do table.insert(alloc,{ownerId=i})end
   return {version=2,snapshot={encounterId=id,xpPolicy="equal-actors-v1"},allocations=alloc},"Found"
  end}})
  for i=1,33 do fake.Sessions[i]={token="t"..i,epoch=1,state="Active",record={revision=0,operations={recentResults={}}}}end
  for i=1,32 do eq(a.Deliver(i,"encounter"),"Retry")end
  local status,code=a.Deliver(33,"encounter");eq(status,"Retry");eq(code,"AdapterCapacity")
  local old=fake.Sessions[1];a.Remove(1,{});local _,still=a.Deliver(33,"encounter");eq(still,"AdapterCapacity")
  a.Remove(1,old);local _,admitted=a.Deliver(33,"encounter");eq(admitted,"CommitUnavailable")
  fake.Sessions[2]=nil;a.Sweep();fake.Sessions[1]=old;local _,again=a.Deliver(1,"encounter");eq(again,"CommitUnavailable")
  -- An old yielded read cannot clear the busy marker for a replacement attempt.
  h=harness();local real=h.adapter();h.readHook=function()coroutine.yield()end
  local first=coroutine.create(function()local _,why=real.Deliver(1,"encounter");eq(why,"SessionChanged")end);assert(coroutine.resume(first))
  real.Remove(1,h.data.Sessions[1]);local second=coroutine.create(function()eq(real.Deliver(1,"encounter"),"Committed")end);assert(coroutine.resume(second))
  assert(coroutine.resume(first));local _,why=real.Deliver(1,"encounter");eq(why,"Busy");assert(coroutine.resume(second));eq(h.record().data.currencies.gold,7)
 end)
 test("crash after uncertain write resolves receipt under new owner epoch",function()
  local h=harness();h.mode="after";eq(h.adapter().Deliver(1,"encounter"),"Retry");h.mode="ok";h.now+=181
  h.data=h.make();eq(h.data.Load(1,"replacement"),"OK");eq(h.adapter().Deliver(1,"encounter"),"Committed");eq(h.record().data.currencies.gold,7)
 end)
 test("two recipients remain independent when one inventory is full",function()
  local h=harness();h.record(1).data.inventory.stacks.herb=C.Limits.Stack;h.records["p:1"]=U.copy(h.record(1))
  local a=h.adapter();local status,code=a.Deliver(1,"encounter");eq(status,"Retry");eq(code,"InventoryFull")
  eq(a.Deliver(2,"encounter"),"Committed");eq(h.record(1).data.currencies.gold,0);eq(h.record(1).data.character.xp,0);eq(h.record(1).data.sharedPvEClaims,nil)
  eq(h.record(2).data.currencies.gold,7)
 end)
 test("missing frozen actor, XP cap, wallet and receipt capacity reject entire allocation",function()
  for _,reason in ipairs({"SharedClaimActorMissing","XPCap","WalletFull","SharedClaimCapacity"})do
   local h=harness();local r=h.record();local c=claim(1)
   if reason=="SharedClaimActorMissing"then c.allocation.actorXP={player=5,missing=5}
   elseif reason=="XPCap"then r.data.character.xp=C.Limits.XP
   elseif reason=="WalletFull"then r.data.currencies.gold=C.Limits.Gold
   else r.data.sharedPvEClaims={version=1,receipts={}};for i=1,32 do local prior=claim(1,"prior"..i);r.data.sharedPvEClaims.receipts[ClaimsModule.key(prior)]=prior end end
   local before=U.copy(r);eq(h.commit(c),reason);eq(r,before)
  end
 end)
 test("optional extension absent valid and malformed receipts rejected even without activation",function()
  local r=fixture(1);eq(Schema.validate(r,1),true)
  local c=claim(1);r.data.sharedPvEClaims={version=1,receipts={[ClaimsModule.key(c)]=c}};eq(Schema.validate(r,1),true)
  c.allocation.actorXP.player=9;eq(Schema.validate(r,1),false)
  c.allocation.actorXP.player=10;c.xpPolicy="future";eq(Schema.validate(r,1),false)
  r.data.sharedPvEClaims=nil;local migrated=Schema.migrate(r);assert(migrated);eq(migrated.schemaVersion,r.schemaVersion);eq(migrated.data.sharedPvEClaims,nil)
 end)
 test("lease and session states precede durable success and yielded Read fences replacement",function()
  local h=harness();eq(h.commit(claim(1)),"OK");local s=h.data.Sessions[1];s.closing=true;eq(h.commit(claim(1)),"Closing");s.closing=false
  s.busy=true;eq(h.commit(claim(1)),"Busy");s.busy=false;h.now+=175;eq(h.commit(claim(1)),"LeaseExpiring")
  h=harness();local a=h.adapter();h.readHook=function()coroutine.yield()end
  local co=coroutine.create(function()local status,code=a.Deliver(1,"encounter");eq(status,"Retry");eq(code,"SessionChanged")end)
  assert(coroutine.resume(co));local replacement=U.copy(h.data.Sessions[1]);replacement.token="other";replacement.epoch+=1;h.data.Sessions[1]=replacement
  assert(coroutine.resume(co));eq(h.record().data.currencies.gold,0)
 end)
 test("frozen hero XP is independent of current party and audit saturation is atomic",function()
  local h=harness();local r=h.record();local d=r.data
  d.adventurers["a:Warrior"]={id="a:Warrior",name="Fixture",rank="F",classId="Warrior",level=1,xp=0,baseStats=U.copy(C.Adventurers.Warrior.Stats),equipmentSlots={}}
  d.progression.recruitedClasses.Warrior=true;d.party.adventurerIds={};h.records["p:1"]=U.copy(r)
  local c=claim(1);c.allocation.actorXP={player=4,["a:Warrior"]=6}
  eq(h.commit(c),"OK");eq(h.record().data.adventurers["a:Warrior"].xp,6);eq(h.record().data.character.xp,4)
  h=harness();r=h.record();for i=1,C.Limits.Audit do table.insert(r.audit.outbox,{sequence=i,name="fixture",payload={}})end;r.audit.nextSequence=C.Limits.Audit+1
  local before=U.copy(r);eq(h.commit(claim(1)),"AuditBacklog");eq(r,before)
  local a=h.adapter();eq(a.Deliver(0,"encounter"),"Rejected");eq(a.Deliver(1,"bad:identifier"),"Rejected")
 end)
 test("equipment uses bounded sequence ids and byte capacity rejects before commit",function()
  local r=fixture(1);local c=claim(1,string.rep("x",64));local equipment=nil;for id,def in pairs(C.Items)do if def.Kind~="Material"then equipment=id;break end end
  assert(equipment);c.allocation.items={[equipment]=1};local nextRecord=claims.apply(r,command(r,c));assert(nextRecord)
  for id in pairs(nextRecord.data.inventory.equipment)do assert(#id<=64);eq(id,"shared:1:1")end
  eq(nextRecord.data.inventory.nextEquipmentSequence,2)
  local tiny=U.copy(C);tiny.Limits.ProfileBytes=100
  local bounded=ClaimsModule.new(tiny,U,require("../src/server/Services/EconomyService")(tiny,U));local result,why=bounded.apply(r,command(r,c));eq(result,nil);eq(why.code,"SharedClaimProfileCapacity")
 end)
end
