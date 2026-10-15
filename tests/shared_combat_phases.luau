--!strict
return function(test:any,eq:any)
 local Registry=require("../src/server/Systems/SharedEncounterIdentity")
 local Phases=require("../src/server/Systems/SharedCombatPhases")
 local Targeting=require("../src/server/Systems/CombatTargeting")
 local Damage=require("../src/server/Systems/CombatDamage")
 local function fixture():any
  local h:any={registry=Registry(),current={},calls=0}
  h.encounter=assert(h.registry.create());h.policy=h.registry.policy()
  h.context={SceneToken={},EncounterToken=h.encounter,Policy=h.policy,Contains=function(a:any)return a.inside~=false end,IsCurrent=function(id:any,s:any)return h.current[id]==s end}
  h.phases=Phases(h.context)
  function h.actors(owner:number,count:number?):any
   local list={};for i=1,count or 1 do table.insert(list,{id=if i==1 then "player"else "h:"..i,owner=owner,kind="Hero",active=true,health=50,state="Idle",stats={MaxHealth=100,Attack=10,Defense=0},cooldowns={}})end;return list
  end
  function h.prepare(owner:number,stamp:number,actors:any?):any
   local session=h.current[owner]or {};h.current[owner]=session;local list=actors or h.actors(owner,2)
   local handle,code=h.phases.Prepare(owner,session,stamp,list,{owner=owner});assert(handle,code);return handle,list,session
  end
  function h.register(owner:number,handle:any,actors:any):any
   local token=assert(h.registry.addOwner(h.encounter,owner));for _,a in ipairs(actors)do assert(h.registry.addActor(h.encounter,token,a))end
   eq(h.phases.Register(handle),true);return token
  end
  h.enemy={id="enemy",owner=0,kind="Enemy",active=true,health=100,state="Idle",stats={MaxHealth=100,Attack=10,Defense=0},threat={}}
  assert(h.registry.addEnemy(h.encounter,h.enemy))
  function h.enemies(stamp:number):any return h.phases.Enemies(stamp,{h.enemy},function(allies:any)h.calls+=1;return #allies>0 end)end
  h.target=Targeting(function()return 1 end,nil,nil,h.phases.Policy)
  h.damage=Damage({damage=function(a:any)return a end,valid=function(n:any)return type(n)=="number"and n>0 end},h.target,function()end)
  return h
 end
 test("prepare precedes registration and all phases are opaque consume-once capabilities",function()
  local h=fixture();local token,actors=h.prepare(1,1)
  eq(h.phases.Policy.key(actors[1]),nil);eq(h.phases.Register(token),false)
  h.register(1,token,actors);eq(h.phases.Owner(token,function()error("early")end),false)
  eq(h.enemies(1),true);eq(h.enemies(1),false);eq(h.calls,1)
  local steps=0;eq(h.phases.Owner(token,function(payload:any,own:any,support:any,fighting:any)steps+=1;eq(payload.owner,1);eq(#own,2);eq(#support,2);eq(fighting,true);assert(table.isfrozen(own));eq(h.phases.Owner(token,function()end),false)end),true)
  eq(steps,1);eq(h.phases.Owner(token,function()end),false);eq(h.phases.Finish(token,function()steps+=1 end),true);eq(h.phases.Finish(token,function()end),false);eq(steps,2)
  eq(h.phases.Owner({},function()end),false)
 end)
 test("registered domain-down actors remain in support until session retirement",function()
  local h=fixture();local t1,a1,s1=h.prepare(1,1);local t2,a2=h.prepare(2,1)
  local registration=h.register(1,t1,a1);h.register(2,t2,a2)
  a1[1].health=0;a1[1].active=false;a1[1].state="Downed"
  eq(#h.phases.Support(),4);assert(table.find(h.phases.Support(),a1[1]))
  eq(h.phases.Enemies(1,{h.enemy},function(allies:any)assert(table.find(allies,a1[1]));return false end),true)
  h.registry.removeOwner(registration);h.phases.Detach(1,s1)
  eq(#h.phases.Support(),2);eq(table.find(h.phases.Support(),a1[1]),nil)
 end)
 test("two owners share targeting but retain own lists and effect-time boundary checks",function()
  local h=fixture();local t1,a1=h.prepare(1,1);local t2,a2=h.prepare(2,1);h.register(1,t1,a1);h.register(2,t2,a2)
  eq(#h.phases.Own(a1[1]),2);eq(#h.phases.Support(),4);eq(h.damage.heal(a1[1],a2[1],5,10,1),10)
  eq(h.damage.hit(a1[1],a2[1],5,1,1),0);eq(h.damage.heal(h.enemy,a1[1],5,10,1),0)
  a2[1].inside=false;eq(h.damage.heal(a1[1],a2[1],5,10,1),0);a2[1].inside=true
  local target=Targeting(function()a2[1].inside=false;return 1 end,nil,nil,h.phases.Policy)
  local damage=Damage({damage=function()return 10 end,valid=function()return true end},target,function()end)
  eq(damage.heal(a1[1],a2[1],5,10,1),0)
  a2[1].inside=true;h.current[2]={};eq(h.damage.heal(a1[1],a2[1],5,10,1),0)
 end)
 test("new prepare invalidates old phase and commands before fresh attachment",function()
  local h=fixture();local old,actors,session=h.prepare(1,1);h.register(1,old,actors);eq(h.enemies(1),true)
  local fresh=h.prepare(1,2,actors);eq(h.phases.Policy.key(actors[1]),nil);eq(h.phases.Owner(old,function()error("stale")end),false)
  eq(h.phases.Register(fresh),true);assert(h.phases.Policy.key(actors[1]));h.phases.Detach(1,{});assert(h.phases.Policy.key(actors[1]))
  h.phases.Detach(1,session);eq(h.phases.Policy.key(actors[1]),nil);eq(h.damage.hit(actors[1],h.enemy,5,1,2),0)
 end)
 test("mixed registrations and duplicate actor rosters fail closed",function()
  local h=fixture();h.current[1]={};local a=h.actors(1,2);a[2].id="player";eq(h.phases.Prepare(1,h.current[1],1,a,{}),nil)
  local token,actors=h.prepare(1,1);local first=assert(h.registry.addOwner(h.encounter,1));assert(h.registry.addActor(h.encounter,first,actors[1]))
  eq(h.phases.Register(token),false);assert(h.registry.addActor(h.encounter,first,actors[2]));eq(h.phases.Register(token),true)
  local other=assert(h.registry.create());local outsider=h.actors(2,1);local owner=assert(h.registry.addOwner(other,2));assert(h.registry.addActor(other,owner,outsider[1]));h.current[2]={}
  local t=h.phases.Prepare(2,h.current[2],1,outsider,{});assert(t);eq(h.phases.Register(t),false)
  eq(h.enemies(1),false);eq(h.calls,0)
 end)
 test("once-only enemy callback stays fenced through yield errors and scene closure",function()
  local h=fixture();local t,a,session=h.prepare(1,1);h.register(1,t,a)
  local co=coroutine.create(function()local ok=h.phases.Enemies(1,{h.enemy},function()h.calls+=1;coroutine.yield();eq(h.damage.hit(a[1],h.enemy,5,1,1),0)end);eq(ok,true)end)
  assert(coroutine.resume(co));eq(h.enemies(1),false);eq(h.phases.Owner(t,function()end),false);h.phases.Detach(1,session);assert(coroutine.resume(co));eq(h.calls,1)
  h=fixture();t,a=h.prepare(1,1);h.register(1,t,a);eq(h.phases.Enemies(1,{h.enemy},function()error("failure")end),false);eq(h.enemies(2),false);eq(h.damage.hit(a[1],h.enemy,5,1,2),0)
  h=fixture();t,a=h.prepare(1,1);h.register(1,t,a);h.phases.Close();eq(h.enemies(1),false);eq(h.phases.Policy.key(a[1]),nil)
 end)
 test("prepared identity mutation and scene replacement invalidate capabilities",function()
  local h=fixture();local token,a=h.prepare(1,1);a[1].id="renamed"
  local owner=assert(h.registry.addOwner(h.encounter,1));for _,actor in ipairs(a)do assert(h.registry.addActor(h.encounter,owner,actor))end
  eq(h.phases.Register(token),false)
  h=fixture();token,a=h.prepare(1,1);h.register(1,token,a);h.context.SceneToken={};eq(h.phases.Policy.key(h.enemy),nil);eq(h.damage.hit(a[1],h.enemy,5,1,1),0);eq(h.enemies(1),false)
 end)
 test("running owner phase cannot reattach actors through reentry or yielded preparation",function()
  local h=fixture();local t,a,session=h.prepare(1,1);h.register(1,t,a);eq(h.enemies(1),true)
  local co=coroutine.create(function()
   eq(h.phases.Owner(t,function()
    eq(h.phases.Prepare(1,session,2,a,{}),nil);eq(h.phases.CommandReady(),false)
    coroutine.yield();eq(h.damage.hit(a[1],h.enemy,5,1,1),0)
   end),false)
  end)
  assert(coroutine.resume(co));eq(h.phases.CanPrepare(1,session,2),false);eq(h.phases.Prepare(1,session,2,a,{}),nil)
  h.phases.Detach(1,session);eq(h.phases.Prepare(1,session,2,a,{}),nil);assert(coroutine.resume(co))
  eq(h.phases.CanPrepare(1,session,2),true)
 end)
 test("malformed enemy elements reject without invoking the enemy callback",function()
  local h=fixture();local t,a=h.prepare(1,1);h.register(1,t,a)
  eq(h.phases.Enemies(1,{1},function()error("invalid")end),false)
  eq(h.phases.Enemies(1,{setmetatable({},{__index=function()error("metatable")end})},function()error("invalid")end),false)
  eq(h.enemies(1),true);eq(h.calls,1)
 end)
 test("sixteen owners remain bounded at96 support and six own actors",function()
  local h=fixture()
  for owner=1,16 do local t,a=h.prepare(owner,1,h.actors(owner,6));h.register(owner,t,a);eq(#h.phases.Own(a[1]),6)end
  eq(#h.phases.Support(),96);h.current[17]={};eq(h.phases.Prepare(17,h.current[17],1,h.actors(17,1),{}),nil);eq(h.enemies(1),true);eq(h.calls,1)
 end)
 test("authoritative sinks and predicates cannot yield across combat mutation",function()
  local h=fixture();local t,a=h.prepare(1,1);h.register(1,t,a);local resumed=false
  h.context.Observe=function()coroutine.yield();resumed=true end
  eq(h.phases.Notify("Observe","damage_dealt",a[1],h.enemy,10),false);eq(resumed,false);eq(h.damage.hit(a[1],h.enemy,5,1,1),0)
  h=fixture();t,a=h.prepare(1,1);h.register(1,t,a);h.context.Contains=function()coroutine.yield();return true end
  eq(h.phases.Policy.key(a[1]),nil)
  h=fixture();local recovered=0;h.context.Recover=function(_a:any,n:number)recovered+=n end;eq(h.phases.Notify("Recover",{},7),true);eq(recovered,7)
  eq(h.phases.Call(function()coroutine.yield();error("resumed movement")end),false);eq(h.phases.CommandReady(),false)
 end)
 test("group heal primary and secondary stay inside owning six while singles can share",function()
  local h=fixture();local t,a=h.prepare(1,1,h.actors(1,6));local t2,b=h.prepare(2,1,h.actors(2,1));h.register(1,t,a);h.register(2,t2,b)
  b[1].health=1;local own=h.phases.Own(a[1]);a[1].allies=own
  local groupTarget=h.target.heal(a[1],own,10);assert(groupTarget~=b[1]);eq(h.target.heal(a[1],h.phases.Support(),10),b[1])
  local abilities=require("../src/server/Systems/CombatAbilities")({Classes={Priest={Ability="group"}},Abilities={group={Class="Priest",TargetType="Ally",Effect="Heal",Range=10,Multiplier=1,Flat=0,Group=true,Cooldown=1}}},h.target,h.damage,function()end)
  a[1].class="Priest";eq(abilities.cast(a[1],"group",groupTarget,{},1),true);eq(b[1].health,1)
  for _,actor in ipairs(a)do eq(actor.health,60)end
 end)
end
