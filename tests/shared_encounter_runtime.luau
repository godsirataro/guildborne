--!strict
return function(test:any,eq:any)
 local Identity=require("../src/server/Systems/SharedEncounterIdentity")
 local Runtime=require("../src/server/Services/SharedEncounterRuntime")
 local function actor(id:string,owner:number,kind:string?):any return {id=id,owner=owner,kind=kind or "Hero",active=true,health=100,state="Idle",threat={},stats={Attack=10,Defense=0,MaxHealth=100}}end
 local function roster(owner:number,count:number):any local result={};for i=1,count do result[i]=actor(if i==1 then "player"else "h:"..i-1,owner)end;return result end
 local function make(enemy:any?,owner:any?):any return assert(Runtime({Registry=Identity(),EnemyStep=enemy or function()end,OwnerStep=owner or function()end}))end
 test("two six and seven owners share exactly one enemy step with private owned actor slices",function()
  for _,count in ipairs({2,6,7})do
   local enemyCalls,ownerCalls=0,0
   local r=make(function(stamp:any,allies:any,enemies:any)eq(stamp,1);eq(#allies,count*6);eq(#enemies,1);enemyCalls+=1;assert(table.isfrozen(allies))end,
    function(id:any,_session:any,_stamp:any,own:any,allies:any)ownerCalls+=1;eq(#own,6);eq(#allies,count*6);for _,a in ipairs(own)do eq(a.owner,id)end end)
   for i=1,count do assert(r.Join(i,{},roster(i,6)))end
   assert(r.AddEnemy(actor("enemy",0,"Enemy")));assert(r.Tick(1));eq(enemyCalls,1);eq(ownerCalls,count)
   eq(r.Tick(1),false);eq(enemyCalls,1)
  end
 end)
 test("fixture bounds support 96 allied actors and reject a seventeenth owner",function()
  local observed=0;local r=make(function(_s:any,allies:any)observed=#allies end)
  for i=1,16 do assert(r.Join(i,{},roster(i,6)))end
  eq(r.Join(17,{},roster(17,1)),false);eq(r.Join(1,{},roster(1,7)),false)
  assert(r.Tick(0));eq(observed,96)
 end)
 test("join idempotence replacement and exact-session leave invalidate old actors only",function()
  local r=make();local a,b={},{};local old,new=roster(1,2),roster(1,2);local other=roster(2,2)
  assert(r.Join(1,a,old));local key=r.Policy().key(old[1]);local token=r.Policy().ownerToken(old[1])
  local ok,code=r.Join(1,a,old);eq(ok,true);eq(code,"AlreadyJoined");eq(r.Policy().key(old[1]),key)
  eq(r.Join(1,a,new),false);assert(r.Join(2,{},other));local e=actor("enemy",0,"Enemy");assert(r.AddEnemy(e))
  assert(r.Join(1,b,new));eq(r.Policy().key(old[1]),nil);assert(r.Policy().ownerToken(new[1])~=token)
  eq(r.Leave(1,a),false);assert(r.Policy().key(new[1]));eq(r.Join(1,a,roster(1,1)),false)
  assert(r.Leave(1,b));eq(r.Policy().key(new[1]),nil);assert(r.Policy().key(other[1]));assert(r.Policy().key(e))
 end)
 test("mentor detach and fresh attachment never revive stale actor objects",function()
  local r=make();local session={};local own=roster(1,1);assert(r.Join(1,session,own));assert(r.Leave(1,session))
  eq(r.Join(1,session,roster(1,1)),false);eq(r.Join(1,{},own),false)
  local replacement=roster(1,1);assert(r.Join(1,{},replacement));eq(r.Policy().key(own[1]),nil)
  assert(r.Policy().key(replacement[1]))
 end)
 test("yielding enemy callback fences reentry and revokes old effects after replacement",function()
  local r:any;local damage:any;local old=roster(1,1);local replacement=roster(1,1);local oldSession={};local nextSession={}
  local enemy=actor("enemy",0,"Enemy");local enemyCalls,ownerCalls=0,0;local hit=-1
  r=make(function()enemyCalls+=1;coroutine.yield("pending");hit=damage.hit(old[1],enemy,10,1,0)end,function()ownerCalls+=1 end)
  local target=require("../src/server/Systems/CombatTargeting")(function()return 1 end,nil,nil,r.Policy())
  damage=require("../src/server/Systems/CombatDamage")({damage=function()return 10 end},target,function()end)
  assert(r.Join(1,oldSession,old));assert(r.AddEnemy(enemy))
  local result:any;local thread=coroutine.create(function()result={r.Tick(1)}end)
  local ok,marker=coroutine.resume(thread);eq(ok,true);eq(marker,"pending")
  local accepted,code=r.Tick(2);eq(accepted,false);eq(code,"Busy");eq(enemyCalls,1)
  assert(r.Join(1,nextSession,replacement));assert(coroutine.resume(thread))
  eq(hit,0);eq(enemy.health,100);eq(ownerCalls,0);eq(result[1],true);eq(r.Tick(1),false)
 end)
 test("callbacks are once per stamp failures consumed and reentrant ticks rejected",function()
  local r:any;local calls,owners=0,0
  r=make(function(stamp:any)calls+=1;local ok,code=r.Tick(stamp+1);eq(ok,false);eq(code,"Busy");if stamp==1 then error("fault after work")end end,
   function(id:any)owners+=1;if id==1 then error("owner fault")end end)
  assert(r.Join(1,{},roster(1,1)));assert(r.Join(2,{},roster(2,1)))
  local ok,code=r.Tick(1);eq(ok,false);eq(code,"EnemyStepFailed");eq(owners,0)
  eq(r.Tick(1),false);eq(calls,1)
  ok,code=r.Tick(2);eq(ok,false);eq(code,"OwnerStepFailed");eq(owners,2);eq(calls,2)
  eq(r.Tick(2),false);eq(owners,2)
 end)
 test("owner callback suspended across mentor detach cannot heal through stale membership",function()
  local r:any;local damage:any;local old=roster(1,1);local patient=roster(2,1);patient[1].health=20
  local session={};local healed=-1;local callbacks=0
  r=make(nil,function(id:any,_session:any,_stamp:any,own:any,allies:any)
   callbacks+=1
   if id==1 then coroutine.yield();healed=damage.heal(own[1],allies[2],10,30,0)end
  end)
  local t=require("../src/server/Systems/CombatTargeting")(function()return 1 end,nil,nil,r.Policy())
  damage=require("../src/server/Systems/CombatDamage")({valid=function()return true end},t,function()error("no stale heal")end)
  assert(r.Join(1,session,old));assert(r.Join(2,{},patient))
  local thread=coroutine.create(function()r.Tick(1)end);assert(coroutine.resume(thread))
  assert(r.Leave(1,session));assert(r.Join(1,{},roster(1,1)));assert(coroutine.resume(thread))
  eq(healed,0);eq(patient[1].health,20);eq(callbacks,2)
 end)
 test("close during suspended callback revokes all and prevents remaining owner steps",function()
  local owners=0;local r=make(function()coroutine.yield()end,function()owners+=1 end)
  local own=roster(1,1);assert(r.Join(1,{},own));local token=r.EncounterToken();assert(token)
  local thread=coroutine.create(function()r.Tick(1)end);assert(coroutine.resume(thread));r.Close();r.Close()
  eq(r.EncounterToken(),nil);eq(r.Policy().key(own[1]),nil);assert(coroutine.resume(thread));eq(owners,0)
  eq(r.Tick(2),false);eq(r.Join(1,{},roster(1,1)),false)
 end)
 test("malformed rosters rejected without detaching a valid current session",function()
  local r=make();local session={};local own=roster(1,1);assert(r.Join(1,session,own))
  eq(r.Join(1,{},{}),false);eq(r.Join(1,{}, {[2]=actor("player",1)}),false)
  eq(r.Join(1,{},roster(2,1)),false);eq(r.Join(1,{}, {own[1],own[1]}),false)
  assert(r.Policy().key(own[1]));assert(r.Leave(1,session))
  for _,stamp in ipairs({-1,math.huge,0/0})do eq(r.Tick(stamp),false)end
 end)
end
