--!strict
return function(test:any,eq:any)
 local U=require("../src/shared/Util/TableUtil")
 local Identity=require("../src/server/Systems/SharedEncounterIdentity")
 local Participation=require("../src/server/Systems/SharedEncounterParticipation")
 local Settlement=require("../src/server/Systems/SharedPvESettlement")
 local Store=require("../src/server/Services/SharedPvESettlementStore")
 local Memory=require("../src/server/Persistence/MemoryStore")
 local Make=require("../src/server/Services/SharedCombatRewards")
 local function fixture():any
  local f:any={time=0,ids={[1]={"player","hero:1"},[2]={"player"}},calls=0,delivered={},blocked={}}
  f.registry=Identity();f.encounter=f.registry.create();f.enemy={id="enemy",kind="Enemy",owner=0,health=100,stats={MaxHealth=100}}
  f.registry.addEnemy(f.encounter,f.enemy);f.actors={};f.tokens={}
  for i=1,2 do f.tokens[i]=f.registry.addOwner(f.encounter,i);f.actors[i]={id="player",kind="Hero",owner=i};f.registry.addActor(f.encounter,f.tokens[i],f.actors[i])end
  f.repository=Store(Memory(U),U,Settlement,"test",2)
  f.deps={Policy=f.registry.policy(),EncounterToken=f.encounter,Enemy=f.enemy,Now=function()return f.time end,EncounterId="enemy_1",Budget={xp=11,gold=7,items={{itemId="herb",count=3}}},RotationSeed=0,
   OwnerRoster=function(id:number)return f.ids[id]end,MakeParticipation=Participation,Settlement=Settlement,Repository=f.repository,Util=U,
   Delivery={Deliver=function(id:number,_enc:string)
    f.calls+=1;if f.blocked[id]then return "Retry","InventoryFull"end
    f.delivered[id]=(f.delivered[id]or 0)+1;return "Committed","OK"
   end}}
  f.rewards=Make(f.deps)
  function f.hit(id:number,amount:number)f.enemy.health=math.max(0,f.enemy.health-amount);f.rewards.Observe("damage_dealt",f.actors[id],f.enemy,amount)end
  function f.kill()f.enemy.health=0;f.rewards.Observe("enemy_defeated",f.actors[1],f.enemy,1)end
  return f
 end
 test("shared reward sinks freeze conserved roster once and never perform IO",function()
  local f=fixture();f.hit(1,10);f.ids[1]={"player","hero:late"};f.hit(2,10);f.kill()
  eq(f.calls,0);local _,state=f.repository.Read("enemy_1");eq(state,"Missing")
  local snap=f.rewards.State().snapshot;eq(snap.owners[1].actorIds,{"hero:1","player"});eq(#snap.owners,2)
  f.rewards.Observe("enemy_defeated",f.actors[1],f.enemy,1);f.rewards.Pump();f.rewards.Pump();f.rewards.Pump()
  eq(f.calls,2);eq(f.rewards.State().status,"Delivered");eq(f.repository.Read("enemy_1"),Settlement.Build(snap))
  snap.xp=999;eq(f.rewards.State().snapshot.xp,11)
 end)
 test("departure keeps earned frozen roster while stale actor cannot earn more",function()
  local f=fixture();f.hit(1,10);f.rewards.Leave(1);f.registry.removeOwner(f.tokens[1]);f.time=20
  f.rewards.Observe("damage_dealt",f.actors[1],f.enemy,10);f.hit(2,10);f.kill();eq(#f.rewards.State().snapshot.owners,2)
  local g=fixture();g.hit(1,10);g.rewards.Leave(1);g.registry.removeOwner(g.tokens[1]);g.time=31;g.hit(2,10);g.kill();eq(#g.rewards.State().snapshot.owners,1);eq(g.rewards.State().snapshot.owners[1].ownerId,2)
 end)
 test("new owner registration preserves first credited actor roster",function()
  local f=fixture();f.hit(1,10);f.rewards.Leave(1);f.registry.removeOwner(f.tokens[1]);f.time=31
  f.tokens[1]=f.registry.addOwner(f.encounter,1);f.actors[1]={id="player",kind="Hero",owner=1};f.registry.addActor(f.encounter,f.tokens[1],f.actors[1]);f.ids[1]={"player","new:hero"}
  f.hit(1,10);f.kill();eq(f.rewards.State().snapshot.owners[1].actorIds,{"hero:1","player"})
 end)
 test("neutral recovery prevents healer credit and empty eligibility creates no settlement",function()
  local f=fixture();f.rewards.Observe("damage_dealt",f.enemy,f.actors[1],10);f.rewards.Recover(f.actors[1],10)
  f.rewards.Observe("healing_done",f.actors[2],f.actors[1],10);f.kill();eq(#f.rewards.State().snapshot.owners,1)
  local empty=fixture();empty.kill();eq(empty.rewards.State().status,"NoEligibleOwners");empty.rewards.Pump();eq(empty.calls,0)
 end)
 test("unknown preparation never delivers early and retries the immutable snapshot",function()
  local f=fixture();local actual=f.repository.Prepare;local first=true
  f.repository.Prepare=function(snapshot:any)local record,state=actual(snapshot);if first then first=false;error("after commit")end;return record,state end
  f.hit(1,10);f.kill();local ok=f.rewards.Pump();eq(ok,false);eq(f.calls,0)
  f.ids[1]={"player","changed"};f.rewards.Close();eq(f.rewards.Pump(),true);eq(f.delivered[1],1)
  eq(f.repository.Read("enemy_1").snapshot.owners[1].actorIds,{"hero:1","player"})
 end)
 test("blocked recipient does not starve others and scene close retains deliveries",function()
  local f=fixture();f.blocked[1]=true;f.hit(1,10);f.hit(2,10);f.kill();f.rewards.Close()
  f.rewards.Pump();f.rewards.Pump();eq(f.delivered[1],nil);eq(f.delivered[2],1)
  f.blocked[1]=nil;f.rewards.Pump();eq(f.delivered[1],1);eq(f.rewards.State().status,"Delivered")
 end)
 test("conflicting prepared allocation fails closed and invalid roster cannot redistribute",function()
  local f=fixture();local wrong={version=2,xpPolicy="equal-actors-v1",encounterId="enemy_1",owners={{ownerId=1,actorIds={"player"}}},rotationSeed=0,xp=999,gold=7,items={}}
  f.repository.Prepare(wrong);f.hit(1,10);f.kill();eq(f.rewards.Pump(),false);eq(f.calls,0);eq(f.rewards.State().fault,"SettlementConflict")
  local g=fixture();g.ids[1]=nil;g.hit(1,10);g.kill();g.rewards.Pump();eq(g.calls,0);eq(g.rewards.State().fault,"MissingTrustedRoster")
 end)
 test("only exact registered basic enemy death finalizes and worker is single flight",function()
  local f=fixture();f.hit(1,10);f.rewards.Observe("enemy_defeated",f.actors[1],{id="enemy",health=0},1);eq(f.rewards.State().status,"Observing")
  f.kill();local original=f.deps.Delivery.Deliver
  f.deps.Delivery.Deliver=function(id:any,e:any)coroutine.yield();return original(id,e)end
  local co=coroutine.create(f.rewards.Pump);eq(coroutine.resume(co),true);local ok,code=f.rewards.Pump();eq(ok,false);eq(code,"Busy")
  eq(coroutine.resume(co),true);eq(f.delivered[1],1)
 end)
 test("coordinator supplies trusted roster and leaves before registry revocation",function()
  local Coordinator=require("../src/server/Services/SharedCombatCoordinator")
  local Runtime=require("../src/server/Services/SharedEncounterRuntime")
  local player={UserId=1,Character={}};local profile:any={token={},epoch=1,state="Active",record={}}
  local root={Position={}};local s:any={alive=true,active=true,characterData={classId="Warrior"},heroes={},playerCombat={id="player",kind="Hero",owner=1,root=root,model={Parent=true},cooldowns={}}}
  local context:any=nil;local left=false;local closed=false;local pumps=0
  local coordinator:any=nil
  coordinator=Coordinator({Registry=Identity(),MakeRuntime=Runtime,Scene={enemies={{id="enemy",kind="Enemy",owner=0}}},Session=function()return profile end,ContainsPosition=function()return true end,
   MakeRewards=function(c:any)
    context=c
    return {Observe=function()end,Recover=function()end,Leave=function(id:number)eq(id,1);assert(c.Policy.key(s.playerCombat));left=true end,
     Close=function()closed=true end,Pump=function()pumps+=1;return true,"Pending"end,State=function()return {status="Pending"}end}
   end,
   MakeCombat=function()return {PrepareSharedOwner=function(_p:any,state:any)return {},{state.playerCombat}end,RegisterSharedOwner=function()return true end,
    DetachSharedOwner=function()end,CloseShared=function()end,StepSharedEnemies=function()return true end,StepSharedOwner=function()return true end,FinishSharedOwner=function()return true end,
    PlayerAction=function()local ok,code=coordinator.PumpRewards();eq(ok,false);eq(code,"Busy");eq(pumps,0);return true,"OK"end}end})
  coordinator.Prepare(player,s,root,true,1,function()end);eq(context.OwnerRoster(1),{"player"})
  local claimed,accepted=coordinator.Action(player,s,"Basic",1);eq(claimed,true);eq(accepted,true);eq(pumps,0)
  profile={token={},epoch=2,state="Active",record={}};eq(context.OwnerRoster(1),nil)
  coordinator.Detach(player,s);eq(left,true);eq(context.Policy.key(s.playerCombat),nil)
  coordinator.Close();eq(closed,true);eq(coordinator.PumpRewards(),true);eq(pumps,1)
 end)
 test("single enemy legitimate death completes after corpse cleanup without weakening membership",function()
  local Coordinator=require("../src/server/Services/SharedCombatCoordinator")
  local Runtime=require("../src/server/Services/SharedEncounterRuntime")
  local Damage=require("../src/server/Systems/CombatDamage")
  local function scene(mode:string):any
   local f:any={steps=0,closed=0,pumps=0,frozen=false,statuses={}}
   local enemy:any={id="enemy",kind="Enemy",owner=0,health=10,state="Idle",model={Parent=true},root={Position={}},stats={Defense=0},threat={}}
   local player={UserId=1,Character={}};local root={Position={}}
   local profile={token={},epoch=1,state="Active",record={}}
   local s:any={alive=true,active=true,characterData={classId="Warrior"},heroes={},playerCombat={id="player",kind="Hero",owner=1,root=root,model={Parent=true},cooldowns={},stats={Attack=10}}}
   local damage:any=nil
   f.coordinator=Coordinator({Registry=Identity(),MakeRuntime=Runtime,Scene={enemies={enemy}},Session=function()return profile end,ContainsPosition=function()return true end,
    Status=function(status:any)table.insert(f.statuses,status)end,
    MakeRewards=if mode=="norewards"then nil else function()return {Observe=function(event:any)if event=="enemy_defeated"then f.frozen=true end end,Recover=function()end,Leave=function()end,
     Close=function()f.closed+=1 end,Pump=function()f.pumps+=1;return true,"Delivered"end,State=function()return {frozen=f.frozen}end}end,
    MakeCombat=function(context:any)
     damage=Damage({damage=function()return 10 end},{valid=function(a:any,b:any)return context.Policy.valid(a,b,false)end,key=context.Policy.key},context.Observe)
     return {PrepareSharedOwner=function(_p:any,state:any)return {},{state.playerCombat}end,RegisterSharedOwner=function()return true end,
      DetachSharedOwner=function()end,CloseShared=function()end,
      StepSharedEnemies=function(stamp:number)
       f.steps+=1;if not context.Contains(enemy)then return false,"InvalidEnemies"end
       if enemy.health==0 and stamp>=3 then enemy.model.Parent=nil end
       if mode=="failure"and stamp==3 then return false,"ActualFailure"end
       return true,"Stepped"
      end,StepSharedOwner=function()return true end,FinishSharedOwner=function()return true end,
      PlayerAction=function()
       if mode=="zero"then enemy.health=0;enemy.state="Dead"
       elseif mode=="foreign"then enemy.health=0;enemy.state="Dead";context.Observe("enemy_defeated",s.playerCombat,{id="enemy",kind="Enemy",health=0,state="Dead"},10)
       else damage.hit(s.playerCombat,enemy,1,1,1)end
       return true,"OK"
      end}
    end})
   function f.step(stamp:number)f.coordinator.Prepare(player,s,root,true,stamp,function()end);return f.coordinator.Tick(stamp)end
   function f.action()return f.coordinator.Action(player,s,"Basic",1,"player")end
   f.enemy=enemy;f.player=player;f.s=s;f.root=root;return f
  end
  local f=scene("normal");eq(f.step(1),true);f.action();eq(f.frozen,true);eq(f.step(2),true);eq(f.coordinator.Status(),"Ready")
  local ok,code=f.step(3);eq(ok,true);eq(code,"Completed");eq(f.coordinator.Status(),"Completed");eq(f.closed,1)
  eq(f.step(4),true);eq(f.steps,3);local claimed,accepted=f.action();eq(claimed,true);eq(accepted,false)
  eq(f.coordinator.Claimed(f.player,f.s),true);eq(f.coordinator.PumpRewards(),true);eq(f.pumps,1);eq(f.coordinator.RewardState().frozen,true)
  local newcomerClaimed,newcomerAccepted=f.coordinator.Action({UserId=2},f.s,"Basic",4,"player")
  eq(newcomerClaimed,true);eq(newcomerAccepted,false)
  local unpaid=scene("norewards");unpaid.step(1);unpaid.action();unpaid.step(2);unpaid.step(3);unpaid.step(4)
  eq(unpaid.coordinator.Status(),"Completed");eq(unpaid.steps,3);eq(unpaid.coordinator.PumpRewards(),false)
  for _,mode in ipairs({"zero","foreign","failure"})do
   local bad=scene(mode);bad.step(1);bad.action();bad.step(2);bad.step(3);bad.step(4)
   assert(bad.coordinator.Status():find("Faulted",1,true));eq(table.find(bad.statuses,"Completed"),nil)
  end
  local removed=scene("normal");removed.step(1);removed.enemy.model.Parent=nil;removed.step(2)
  assert(removed.coordinator.Status():find("Faulted",1,true))
 end)
end
