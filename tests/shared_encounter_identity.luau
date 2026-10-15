--!strict
return function(test:any,eq:any)
 local Make=require("../src/server/Systems/SharedEncounterIdentity")
 local Target=require("../src/server/Systems/CombatTargeting")
 local Damage=require("../src/server/Systems/CombatDamage")
 local function actor(id:string,owner:number,kind:string):any
  return {id=id,owner=owner,kind=kind,active=true,health=100,state="Idle",stats={Attack=20,Defense=0,MaxHealth=100},threat={}}
 end
 local stats={valid=function(n:any)return type(n)=="number" and n==n and n>=0 and n<math.huge end,damage=function(a:number,_d:number,m:number)return a*m end}
 local function fixture():any
  local r=Make();local encounter=r.create();local one=assert(r.addOwner(encounter,1));local two=assert(r.addOwner(encounter,2))
  local p1,p2=actor("player",1,"Hero"),actor("player",2,"Hero")
  local h1,h2=actor("h:1",1,"Hero"),actor("h:1",2,"Hero")
  local enemy=actor("enemy:1",0,"Enemy")
  for _,a in ipairs({p1,h1})do assert(r.addActor(encounter,one,a))end
  for _,a in ipairs({p2,h2})do assert(r.addActor(encounter,two,a))end
  assert(r.addEnemy(encounter,enemy))
  local t=Target(function()return 3 end,nil,nil,r.policy());local events={}
  local d=Damage(stats,t,function(name:any,a:any,b:any,value:any)table.insert(events,{name=name,a=a,b=b,value=value})end)
  return {r=r,e=encounter,one=one,two=two,p1=p1,p2=p2,h1=h1,h2=h2,enemy=enemy,t=t,d=d,events=events}
 end
 test("shared actors preserve local IDs but have unique threat keys across owners",function()
  local f=fixture();local keys={}
  for _,a in ipairs({f.p1,f.p2,f.h1,f.h2})do local key=f.t.key(a);eq(keys[key],nil);keys[key]=true end
  eq(f.p1.id,"player");eq(f.p2.id,"player");eq(f.h1.id,"h:1");eq(f.h2.id,"h:1")
  eq(f.d.hit(f.h1,f.enemy,5,1,1),20);eq(f.d.hit(f.h2,f.enemy,5,2,1),40)
  eq(f.enemy.threat[f.t.key(f.h1)],20);eq(f.enemy.threat[f.t.key(f.h2)],40);eq(f.enemy.threat["h:1"],nil)
  eq(f.t.enemy(f.enemy,{f.h1,f.h2},nil,5,2),f.h2)
 end)
 test("shared support credits only effective hero healing and rejects friendly damage and enemy heals",function()
  local f=fixture();f.h2.health=75
  eq(f.t.heal(f.p1,{f.h1,f.h2},5),f.h2)
  eq(f.d.heal(f.p1,f.h2,5,50,1),25);eq(f.d.heal(f.p1,f.h2,5,50,2),0)
  eq(#f.events,1);eq(f.events[1].value,25)
  eq(f.d.hit(f.p1,f.p2,5,1,3),0)
  f.enemy.health=20;eq(f.d.heal(f.p1,f.enemy,5,50,3),0)
  eq(f.d.heal(f.enemy,f.enemy,5,50,3),0);eq(#f.events,1)
 end)
 test("explicit mode fails closed for unregistered clones stale selections and copied token fields",function()
  local f=fixture();local fake=actor("h:1",2,"Hero");fake.encounter=f.e;fake.region="Greenwood"
  eq(f.t.valid(f.p1,fake,5,true),false)
  local selected=f.t.enemy(f.p1,{f.enemy},nil,5,0);eq(selected,f.enemy)
  f.r.removeActor(f.enemy);eq(f.d.hit(f.p1,selected,5,1,1),0);eq(selected.health,100)
  f.h2.health=30;local patient=f.t.heal(f.p1,{f.h2},5);f.r.removeOwner(f.two)
  eq(f.d.heal(f.p1,patient,5,20,1),0);eq(patient.health,30)
  local nextOwner=assert(f.r.addOwner(f.e,2));eq(f.r.addActor(f.e,nextOwner,f.h2),nil)
  local replacement=actor("h:1",2,"Hero");assert(f.r.addActor(f.e,nextOwner,replacement))
  eq(f.t.valid(f.p1,replacement,5,true),true);eq(f.t.valid(f.p1,patient,5,true),false)
 end)
 test("encounter generation and owner registration tokens cannot cross boundaries",function()
  local f=fixture();local e2=f.r.create();local o2=assert(f.r.addOwner(e2,1));local stranger=actor("player",1,"Hero")
  eq(f.r.addActor(e2,f.one,stranger),nil);eq(f.r.addActor(e2,{},stranger),nil)
  assert(f.r.addActor(e2,o2,stranger));eq(f.t.valid(stranger,f.enemy,5),false)
  f.r.close(f.e);eq(f.t.valid(f.p1,f.enemy,5),false);eq(f.t.key(f.p1),nil)
  eq(f.r.addActor(f.e,f.one,actor("new",1,"Hero")),nil)
  eq(f.r.addOwner(f.e,3),nil);f.r.close(f.e);f.r.removeOwner(f.one);f.r.removeActor(f.p1)
 end)
 test("identity mutations invalidate registration and malformed identity never registers",function()
  local f=fixture()
  f.h1.owner=2;eq(f.t.key(f.h1),nil);f.h1.owner=1;eq(f.t.key(f.h1),nil)
  for _,id in ipairs({"",string.rep("a",65),"hero space","hero/1"})do eq(f.r.addActor(f.e,f.one,actor(id,1,"Hero")),nil)end
  for _,id in ipairs({0,1.5,math.huge,0/0,9007199254740992})do eq(f.r.addOwner(f.e,id),nil)end
  eq(f.r.addActor(f.e,f.one,actor("wrong",2,"Hero")),nil)
  eq(f.r.addEnemy(f.e,actor("hero",1,"Hero")),nil)
  eq(f.r.addOwner(f.e,1),nil)
  assert(f.r.addOwner(f.e,-1))
 end)
 test("explicit membership does not bypass range sight or hostile space",function()
  local f=fixture();local distance=10;local sight=true;local space=true
  local t=Target(function()return distance end,function()return space end,function()return sight end,f.r.policy())
  eq(t.valid(f.p1,f.enemy,5),false);distance=3;eq(t.valid(f.p1,f.enemy,5),true)
  sight=false;eq(t.valid(f.p1,f.enemy,5),false);sight=true;space=false;eq(t.valid(f.p1,f.enemy,5),false)
 end)
 test("membership revoked inside spatial validation cannot survive to effect mutation",function()
  local f=fixture()
  local t=Target(function()return 3 end,nil,function()f.r.removeActor(f.enemy);return true end,f.r.policy())
  local d=Damage(stats,t,function()error("no event after revoke")end)
  eq(d.hit(f.p1,f.enemy,5,1,0),0);eq(f.enemy.health,100)
  local g=fixture();g.h2.health=20
  local healing=Target(function()return 3 end,nil,function()g.r.removeOwner(g.two);return true end,g.r.policy())
  eq(Damage(stats,healing,function()error("no heal event after revoke")end).heal(g.p1,g.h2,5,40,0),0)
  eq(g.h2.health,20)
 end)
 test("registry bounds encounters owners allies enemies and releases capacity on cleanup",function()
  local r=Make();local encounters={};for i=1,8 do encounters[i]=assert(r.create())end
  eq(r.create(),nil);local e=encounters[1];local owners={}
  for i=1,16 do owners[i]=assert(r.addOwner(e,i))end
  eq(r.addOwner(e,17),nil)
  local first:any
  for i=1,6 do local a=actor("h:"..i,1,"Hero");assert(r.addActor(e,owners[1],a));if i==1 then first=a end end
  eq(r.addActor(e,owners[1],actor("extra",1,"Hero")),nil)
  r.removeActor(first);assert(r.addActor(e,owners[1],actor("replacement",1,"Hero")))
  for i=1,64 do assert(r.addEnemy(e,actor("enemy:"..i,0,"Enemy")))end
  eq(r.addEnemy(e,actor("extra",0,"Enemy")),nil)
  r.removeOwner(owners[16]);assert(r.addOwner(e,17))
  r.close(e);assert(r.create());r.close(e);eq(r.create(),nil)
 end)
 test("legacy idless enemy damage still applies to a hero while explicit mode rejects it",function()
  local attacker=actor("temporary",1,"Enemy");attacker.id=nil
  local hero=actor("player",1,"Hero");local events=0
  local legacy=Target(function()return 3 end)
  local damage=Damage(stats,legacy,function()events+=1 end)
  eq(damage.hit(attacker,hero,5,1,0),20);eq(hero.health,80);eq(events,1)
  local registry=Make();local explicit=Target(function()return 3 end,nil,nil,registry.policy())
  eq(Damage(stats,explicit,function()error("unregistered effect")end).hit(attacker,hero,5,1,1),0)
  eq(hero.health,80)
 end)
 test("private token accessors expose only current encounter and owner generation",function()
  local f=fixture();local policy=f.r.policy()
  assert(policy.encounter(f.p1)==f.e);assert(policy.ownerToken(f.p1)==f.one)
  assert(policy.encounter(f.enemy)==f.e);eq(policy.ownerToken(f.enemy),nil)
  local other=f.r.create();assert(other~=policy.encounter(f.p1))
  f.r.removeOwner(f.one);eq(policy.ownerToken(f.p1),nil);eq(policy.encounter(f.p1),nil)
  f.r.close(f.e);eq(policy.encounter(f.enemy),nil);eq(policy.ownerToken(f.p2),nil)
 end)
 test("legacy targeting and damage preserve owner restrictions and local threat IDs",function()
  local t=Target(function()return 3 end);local p=actor("player",1,"Hero");local e=actor("enemy",1,"Enemy");local other=actor("h:1",2,"Hero")
  local d=Damage(stats,t,function()end)
  eq(t.valid(p,e,5),true);eq(t.valid(p,other,5,true),false)
  eq(d.hit(p,e,5,1,0),20);eq(e.threat.player,20);eq(t.key(p),"player")
  eq(t.enemy(e,{p,other},nil,5,0),p)
 end)
end
