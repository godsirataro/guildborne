--!strict
return function(test:any,eq:any,makePaths:any?)
 if makePaths then
  local function fixture()
   local vector:any={};vector.__index=function(self:any,key:any)
    if key=="Magnitude"then return math.sqrt(self.X*self.X+self.Y*self.Y+self.Z*self.Z)end
    return vector[key]
   end
   local function v(x:number,y:number,z:number):any return setmetatable({X=x,Y=y,Z=z},vector)end
   vector.__add=function(a:any,b:any)return v(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
   vector.__sub=function(a:any,b:any)return v(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
   vector.__mul=function(a:any,b:number)return v(a.X*b,a.Y*b,a.Z*b)end
   local h:any={generation=0,state="Following",root={Position=v(0,0,0),Anchored=false},lastPosition=v(0,0,0),lastProgress=0,nextPath=0,recoveries=0}
   local s:any={alive=true,origin=v(0,0,0),heroes={h},history={},reset=false}
   h.home={Position=v(-5,0,0)}
   h.model={PivotTo=function(_self:any,pivot:any)h.root.Position=pivot.Position end,SetAttribute=function()end}
   h.humanoid={MoveTo=function(_self:any,p:any)h.move=p end}
   local f:any={h=h,s=s,v=v,blocked=true,started=0,jobs={}}
   f.player={};f.character={GetDescendants=function()return {}end,DescendantAdded={Connect=function()return {Disconnect=function()end}end}}
   local root={Position=v(0,0,0),CFrame={LookVector=v(0,0,-1)}}
   local env:any={V=v,Vector3={zero=v(0,0,0)},CFrame={new=function(p:any)return {Position=p}end},Enum={PathStatus={Success="Success"},PathWaypointAction={Jump="Jump"}},s=s,h=h,root=root,sessions={[f.player]=s}}
   env.workspace={Raycast=function()return if f.blocked then {}else nil end}
   env.Pathfinding={CreatePath=function()
    f.started+=1;local path:any={Status="Success"}
    path.ComputeAsync=function()coroutine.yield()end
    path.GetWaypoints=function()return {{Position=v(0,0,0)},{Position=v(9,0,0)}}end
    return path
   end}
   env.task={spawn=function(callback:any)local thread=coroutine.create(callback);table.insert(f.jobs,thread);assert(coroutine.resume(thread))end}
   f.api=makePaths(env)
   function f.start()f.api.walk(s,h,v(10,0,0),1);eq(h.computing,true);eq(f.started,1)end
   function f.finish()local thread=table.remove(f.jobs,1)::thread;assert(coroutine.resume(thread));eq(coroutine.status(thread),"dead");eq(h.computing,false)end
   return f
  end
  test("current HeroService route installs after yielded computation",function()
   local f=fixture();f.start();f.finish();eq(f.h.waypoint,2);eq(#f.h.path,2)
  end)
  test("recovery rejects old completion and permits one later route",function()
   local f=fixture();f.start();f.api.recover(f.h,f.v(5,0,0));eq(f.h.path,nil);eq(f.h.waypoint,nil);eq(f.h.computing,true);eq(f.h.move.X,5)
   f.api.walk(f.s,f.h,f.v(15,0,0),3);eq(f.started,1);f.finish();eq(f.h.path,nil)
   f.api.walk(f.s,f.h,f.v(15,0,0),4);eq(f.started,2);f.finish();eq(#f.h.path,2)
  end)
  test("walk distance recovery invalidates pending route",function()
   local f=fixture();f.start();f.api.walk(f.s,f.h,f.v(60,0,0),2);eq(f.h.recoveries,1);f.finish();eq(f.h.path,nil)
  end)
  test("walk arrival invalidates pending route",function()
   local f=fixture();f.start();f.api.walk(f.s,f.h,f.v(0,0,0),2);f.finish();eq(f.h.path,nil)
  end)
  test("walk clear line invalidates pending route",function()
   local f=fixture();f.start();f.blocked=false;f.api.walk(f.s,f.h,f.v(10,0,0),2);f.finish();eq(f.h.path,nil);eq(f.h.move.X,10)
  end)
  test("character replacement invalidates pending route without shared coordinator",function()
   local f=fixture();f.start();f.api.character(f.player,f.character);f.finish();eq(f.h.path,nil);eq(f.s.reset,true)
  end)
  test("owner parking invalidates pending route",function()
   local f=fixture();f.start();f.api.park();f.finish();eq(f.h.path,nil);eq(f.h.root.Anchored,true)
  end)
  test("history reset invalidates pending route",function()
   local f=fixture();f.start();f.s.reset=true;f.api.reset();f.finish();eq(f.h.path,nil);eq(f.s.reset,false);eq(#f.s.history,31)
  end)
  test("owner teleport invalidates pending route",function()
   local f=fixture();f.start();f.s.history={f.v(40,0,0)};f.api.reset();f.finish();eq(f.h.path,nil);eq(#f.s.history,31)
  end)
  test("dead session rejects pending route",function()
   local f=fixture();f.start();f.s.alive=false;f.finish();eq(f.h.path,nil)
  end)
  return
 end
 local Coordinator=require("../src/server/Services/SharedCombatCoordinator")
 local Registry=require("../src/server/Systems/SharedEncounterIdentity")
 local Runtime=require("../src/server/Services/SharedEncounterRuntime")
 local Phases=require("../src/server/Systems/SharedCombatPhases")
 local function fixture():any
  local h:any={profiles={},enemySteps=0,ownerSteps=0,entered=0,exited=0}
  local function actor(id:any,owner:any):any return {id=id,owner=owner,kind="Hero",active=true,health=37,cooldowns={art=99},nextAttack=81,order="Hold",root={Position={inside=true}},model={Parent=true}}end
  h.enemy={id="scout",owner=0,kind="Enemy",root={Position={inside=true}},model={Parent=true},health=100,active=true}
  h.coordinator=Coordinator({Registry=Registry(),MakeRuntime=Runtime,Scene={enemies={h.enemy}},Session=function(p:any)return h.profiles[p]end,ContainsPosition=function(p:any)return p.inside end,
   Enter=function()h.entered+=1 end,Exit=function()h.exited+=1 end,
   MakeCombat=function(context:any)
    h.phases=Phases(context);h.policy=h.phases.Policy
    return {PrepareSharedOwner=function(p:any,s:any,r:any,_v:any,stamp:any,_w:any,session:any)
      local actors={s.playerCombat};for _,hero in pairs(s.heroes)do table.insert(actors,hero.combat)end
      for _,a in ipairs(actors)do a.active=true end
      local token,why=h.phases.Prepare(p.UserId,session,stamp,actors,{})
      return token,if token then actors else why
     end,RegisterSharedOwner=h.phases.Register,DetachSharedOwner=h.phases.Detach,CloseShared=h.phases.Close,
     StepSharedEnemies=function(stamp:any)return h.phases.Enemies(stamp,{h.enemy},function()h.enemySteps+=1;if h.enemyError then error("enemy fault")end;return true end)end,
     StepSharedOwner=function(token:any)return h.phases.Owner(token,function()h.ownerSteps+=1 end)end,
     FinishSharedOwner=function(token:any)return h.phases.Finish(token,function()end)end,
     PlayerAction=function(s:any)if h.onAction then h.onAction()end;s.playerCombat.cooldowns.art=200;return true,"OK"end}
   end})
  function h.owner(id:number,count:number?):any
   local p={UserId=id,Character={}};local s:any={alive=true,active=true,characterData={classId="Warrior"},heroes={},playerCombat=actor("player",id)}
   for i=1,count or 1 do s.heroes["h"..i]={state="Following",slot=i,model={Parent=true},root={},combat=actor("h"..i,id)}end
   h.profiles[p]={token={},epoch=1,state="Active",record={}};return p,s,s.playerCombat.root
  end
  function h.prepare(p:any,s:any,r:any,stamp:number):any local claimed,valid,status=h.coordinator.Prepare(p,s,r,true,stamp,function()end);eq(claimed,true);eq(valid,true);eq(status,"Prepared");return s.playerCombat end
  return h
 end
 test("two owners repeated local IDs share exactly one enemy tick",function()
  local h=fixture();local p,s,r=h.owner(1,5);local q,t,u=h.owner(2,5)
  h.prepare(p,s,r,1);h.prepare(q,t,u,1);assert(h.policy.key(s.playerCombat)~=h.policy.key(t.playerCombat));eq(h.coordinator.Tick(1),true);eq(h.enemySteps,1);eq(h.ownerSteps,2);eq(h.coordinator.Tick(1),false)
  h.coordinator.Detach(p,s);eq(h.policy.key(s.playerCombat),nil);assert(h.policy.key(t.playerCombat));eq(h.enemy.model.Parent,true)
 end)
 test("save states retain incarnation and follower validity without enabling inactive Active",function()
  local h=fixture();local p,s,r=h.owner(1);local a=h.prepare(p,s,r,1);h.coordinator.Tick(1)
  s.active=false;h.profiles[p].state="Saving";h.prepare(p,s,r,40);eq(s.playerCombat,a);h.coordinator.Tick(40)
  h.profiles[p].state="Degraded";h.prepare(p,s,r,41);eq(s.playerCombat,a);h.coordinator.Tick(41)
  h.profiles[p].state="Active";local claimed,valid=h.coordinator.Prepare(p,s,r,true,42,function()end);eq(claimed,true);eq(valid,false);eq(h.policy.key(a),nil)
 end)
 test("session epoch and roster replacements preserve HP and cooldown but retire proofs",function()
  local h=fixture();local p,s,r=h.owner(1);local old=h.prepare(p,s,r,1);h.coordinator.Tick(1)
  h.profiles[p].epoch=2;h.prepare(p,s,r,2);local fresh=s.playerCombat;assert(fresh~=old);eq(h.policy.key(old),nil);eq(fresh.health,37);eq(fresh.cooldowns.art,99);eq(fresh.nextAttack,81);eq(fresh.order,"Hold");assert(fresh.cooldowns~=old.cooldowns);h.coordinator.Tick(2)
  s.heroes.h1.slot=2;h.prepare(p,s,r,3);assert(s.playerCombat~=fresh);eq(h.policy.key(fresh),nil)
 end)
 test("old player removal cannot detach replacement and character change is fresh",function()
  local h=fixture();local p,s,r=h.owner(1);h.prepare(p,s,r,1);h.coordinator.Tick(1);local q,t,u=h.owner(1);h.prepare(q,t,u,2);h.coordinator.Detach(p,s);assert(h.policy.key(t.playerCombat));h.coordinator.Tick(2)
  local old=t.playerCombat;q.Character={};h.prepare(q,t,u,3);eq(h.policy.key(old),nil)
 end)
 test("mentor death and boundary exits revoke while preserving other owner",function()
  local h=fixture();local p,s,r=h.owner(1);local q,t,u=h.owner(2);h.prepare(p,s,r,1);h.prepare(q,t,u,1);h.coordinator.Tick(1)
  s.mentor={};eq(h.coordinator.Prepare(p,s,r,true,2,function()end),false);eq(h.policy.key(s.playerCombat),nil);h.prepare(q,t,u,2);eq(h.coordinator.Tick(2),true)
  local c,v=h.coordinator.Prepare(q,t,u,false,3,function()end);eq(c,true);eq(v,false);eq(h.policy.key(t.playerCombat),nil)
 end)
 test("enemy callback fault closes proof and never silently falls back",function()
  local h=fixture();local p,s,r=h.owner(1);h.prepare(p,s,r,1);h.enemyError=true;eq(h.coordinator.Tick(1),false);eq(h.policy.key(s.playerCombat),nil);local c,_,status=h.coordinator.Prepare(p,s,r,true,2,function()end);eq(c,true);eq(status,"Faulted");local claimed,ok=h.coordinator.Action(p,s,"Attack",2);eq(claimed,true);eq(ok,false)
 end)
 test("manual callback cannot create incarnation before spent cooldown is published",function()
  local h=fixture();local p,s,r=h.owner(1);h.prepare(p,s,r,1);h.coordinator.Tick(1);local old=s.playerCombat
  h.onAction=function()h.coordinator.Detach(p,s);local c,_,status=h.coordinator.Prepare(p,s,r,true,2,function()end);eq(c,true);eq(status,"Busy");eq(s.playerCombat,old)end
  local c,ok=h.coordinator.Action(p,s,"Attack",2);eq(c,true);eq(ok,true);h.prepare(p,s,r,2);eq(s.playerCombat.cooldowns.art,200);eq(h.policy.key(old),nil)
 end)
 test("seven owners and full six actor rosters remain bounded and close releases all",function()
  local h=fixture();local owners={};for id=1,7 do local p,s,r=h.owner(id,5);h.prepare(p,s,r,1);table.insert(owners,{p,s})end
  eq(h.coordinator.Tick(1),true);eq(h.enemySteps,1);eq(h.ownerSteps,7);h.coordinator.Close();eq(h.exited,7);for _,pair in ipairs(owners)do eq(h.policy.key(pair[2].playerCombat),nil)end;eq(h.enemy.model.Parent,true)
 end)
end
