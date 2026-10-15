--!strict
-- Optional injected candidate coordinator; owns scene registration, never profile rewards.
return function(deps:any):any
 local owners:any={};local claimed:any={};local fault:string?=nil;local closed=false;local currentStamp=-1;local mutating=false
 local combat:any=nil;local runtime:any=nil;local rewards:any=nil
 local completed=false;local witnessed=false
 local terminalEnemy=if #deps.Scene.enemies==1 then deps.Scene.enemies[1]else nil
 local function call(f:any,...:any):(boolean,any)
  local thread=coroutine.create(f);local ok,value=coroutine.resume(thread,...)
  if not ok or coroutine.status(thread)~="dead"then if coroutine.status(thread)~="dead"then coroutine.close(thread)end;return false,value end
  return true,value
 end
 local function session(player:any):any
  local ok,value=call(deps.Session,player);if not ok then return nil end
  if type(value)~="table"or value.closing or value.token==nil or value.epoch==nil or type(value.record)~="table" then return nil end
  if value.state~="Active"and value.state~="Saving"and value.state~="Degraded"then return nil end
  return value
 end
 local function inside(root:any):boolean
  if not root then return false end
  local ok,value=call(deps.ContainsPosition,root.Position);return ok and value==true
 end
 local function roster(s:any):any
  local list={}
  for id,h in pairs(s.heroes or {})do if h.state=="Following"then table.insert(list,{id=id,hero=h,slot=h.slot,model=h.model,root=h.root})end end
  table.sort(list,function(a:any,b:any)return a.id<b.id end);return list
 end
 local function sameRoster(a:any,b:any):boolean
  if #a~=#b then return false end
  for i,x in ipairs(a)do local y=b[i];if x.id~=y.id or x.hero~=y.hero or x.slot~=y.slot or x.model~=y.model or x.root~=y.root then return false end end
  return true
 end
 local function current(e:any):boolean
  local live=session(e.player)
  return not closed and fault==nil and owners[e.player.UserId]==e and e.s.alive~=false and not e.s.mentor and not e.s.towerRun
   and live==e.profile and live.token==e.profileToken and live.epoch==e.profileEpoch and e.player.Character==e.character
   and sameRoster(e.roster,roster(e.s)) and inside(e.root)
 end
 local function invalidate(s:any)
  for _,h in pairs(s.heroes or {})do h.generation=(h.generation or 0)+1;h.path=nil;h.combatMove=false end
 end
 local function fresh(actor:any):any
  if not actor then return nil end
  local copy=table.clone(actor);copy.cooldowns=table.clone(actor.cooldowns or {});copy.allies={}
  copy.target=nil;copy.previousTarget=nil;copy.focusTarget=nil;copy.evasion=nil;copy.tauntTarget=nil
  actor.active=false;actor.target=nil;actor.previousTarget=nil;actor.focusTarget=nil;actor.allies={}
  return copy
 end
 local function detach(e:any)
  if owners[e.player.UserId]~=e then return end
  if rewards then local ok=call(rewards.Leave,e.player.UserId);if not ok then rewards.Close()end end
  if combat then combat.DetachSharedOwner(e.player.UserId,e.attachment)end
  if runtime then runtime.Leave(e.player.UserId,e.attachment)end
  owners[e.player.UserId]=nil;invalidate(e.s)
  for _,actor in ipairs(e.actors or {})do actor.active=false;actor.target=nil;actor.previousTarget=nil;actor.focusTarget=nil end
 end
 local function fail(reason:string)
  if fault then return end;fault=reason
  local list={};for _,e in pairs(owners)do table.insert(list,e)end;for _,e in ipairs(list)do detach(e)end
  if combat then combat.CloseShared()end;if runtime then runtime.Close()end
  if rewards then rewards.Close()end
  if deps.Status then call(deps.Status,"Faulted",reason)end
 end
 local made,problem=deps.MakeRuntime({Registry=deps.Registry,
  EnemyStep=function(stamp:any)
   local ok,why=combat.StepSharedEnemies(stamp);if not ok then error(why)end
  end,
  OwnerStep=function(ownerId:any,attachment:any,stamp:any)
   local e=owners[ownerId]
   if not e or e.attachment~=attachment or e.stamp~=stamp or not current(e)then error("StaleOwner")end
   local ok,why=combat.StepSharedOwner(e.handle);if not ok then error(why)end
   ok,why=combat.FinishSharedOwner(e.handle);if not ok then error(why)end
  end,
  OnError=function(stage:any)fail(stage)end})
 assert(made,problem);runtime=made
 for _,enemy in ipairs(deps.Scene.enemies)do local ok,why=runtime.AddEnemy(enemy);if not ok then fail(why);break end end
 if deps.MakeRewards and not fault then
  assert(#deps.Scene.enemies==1,"Rewards require one basic enemy")
  local ok,value=call(deps.MakeRewards,{Policy=runtime.Policy(),EncounterToken=runtime.EncounterToken(),Enemy=deps.Scene.enemies[1],
   OwnerRoster=function(ownerId:number):any
    local e=owners[ownerId];if not e or not current(e)then return nil end
    local ids={};for _,actor in ipairs(e.actors or {})do if actor.owner~=ownerId or not runtime.Policy().key(actor)then return nil end;table.insert(ids,actor.id)end
    return ids
   end})
  assert(ok and type(value)=="table","Reward factory unavailable");rewards=value
 end
 local context={SceneToken={},EncounterToken=runtime.EncounterToken(),Scene=deps.Scene,Policy=runtime.Policy(),
  Contains=function(actor:any)return actor.model~=nil and actor.model.Parent~=nil and inside(actor.root)end,
  IsCurrent=function(ownerId:any,attachment:any)local e=owners[ownerId];return e~=nil and e.attachment==attachment and current(e)end,
  Observe=function(event:any,a:any,b:any,value:any)
   -- Record only the exact registered single-scene death reported by combat.
   -- Reward finalization must run before any later terminal cleanup.
   local observer=if rewards then rewards.Observe else deps.Observe
   if observer then observer(event,a,b,value)end
   if mutating and event=="enemy_defeated"and terminalEnemy~=nil and b==terminalEnemy and b.health==0 and b.state=="Dead"
    and runtime.Policy().key(b)~=nil and runtime.Policy().key(a)~=nil then witnessed=true end
  end,Recover=if rewards then rewards.Recover else deps.Recover}
 combat=deps.MakeCombat(context)
 local S={}
 function S.Detach(player:any,s:any)
  local e=owners[player.UserId];if e and e.player==player and e.s==s then detach(e)end
  local c=claimed[player.UserId]
  if c and c.player==player and c.s==s then
   claimed[player.UserId]=nil
   if deps.Exit then local ok=call(deps.Exit,player,s);if not ok then fail("ExitFailed")end end
  end
 end
 function S.Prepare(player:any,s:any,root:any,physical:boolean,stamp:number,walk:any):(boolean,boolean,string)
  local id=player.UserId
  if mutating then return inside(root)or claimed[id]~=nil,physical,"Busy"end
  if not inside(root)or s.mentor or s.towerRun then S.Detach(player,s);return false,physical and s.active==true,"Outside"end
  local claim=claimed[id]
  if claim and(claim.player~=player or claim.s~=s)then S.Detach(claim.player,claim.s);claim=nil end
  if not claim then
   local count=0;for _ in pairs(claimed)do count+=1 end
   if count>=16 then fail("OwnerCapacity");return true,false,"Faulted"end
   claimed[id]={player=player,s=s}
   if deps.Enter then local ok=call(deps.Enter,player,s);if not ok then fail("EnterFailed")end end
  end
  local profile=session(player);local ready=physical and profile~=nil and (s.active==true or profile.state=="Saving"or profile.state=="Degraded")and s.alive~=false
  if closed or fault then return true,ready,"Faulted"end
  if completed then return true,ready,"Completed"end
  local previous=owners[id];local list=roster(s)
  if not ready or #list>5 or not s.characterData or not s.characterData.classId then
   if previous then detach(previous)end;return true,false,"NotReady"
  end
  local changed=previous and(previous.s~=s or previous.player~=player or previous.profile~=profile or previous.profileToken~=profile.token or previous.profileEpoch~=profile.epoch or previous.character~=player.Character or previous.root~=root or not sameRoster(previous.roster,list))
  if changed then detach(previous);previous=nil end
  local e=previous
  if not e then
   -- Revoke all old proof before assigning fresh combat incarnations to existing models.
   s.playerCombat=fresh(s.playerCombat)
   for _,r in ipairs(list)do r.hero.combat=fresh(r.hero.combat)end
   invalidate(s)
   e={player=player,s=s,profile=profile,profileToken=profile.token,profileEpoch=profile.epoch,character=player.Character,root=root,roster=list,attachment={}}
   owners[id]=e
  end
  local token,actors=combat.PrepareSharedOwner(player,s,root,true,stamp,walk,e.attachment)
  if not token then detach(e);return true,ready,"PreparationUnavailable"end
  for _,actor in ipairs(actors)do if not inside(actor.root)then detach(e);return true,ready,"AwaitingFollowers"end end
  local ordered=table.clone(actors);table.sort(ordered,function(a:any,b:any)return a.id<b.id end)
  local ok,why=runtime.Join(id,e.attachment,ordered)
  if not ok then detach(e);fail(why);return true,ready,"Faulted"end
  e.actors=actors;e.handle=token;e.stamp=stamp
  ok,why=combat.RegisterSharedOwner(token)
  if not ok then detach(e);fail(why);return true,ready,"Faulted"end
  return true,ready,"Prepared"
 end
 function S.Tick(stamp:number):(boolean,string)
  if mutating then return false,"Busy"end
  if closed or fault then return false,fault or "Closed"end
  if completed then return true,"Completed"end
  if stamp<=currentStamp then return false,"AlreadyStepped"end
  currentStamp=stamp
  local stale={};for _,e in pairs(owners)do if e.stamp~=stamp or not current(e)then table.insert(stale,e)end end
  for _,e in ipairs(stale)do detach(e)end
  mutating=true;local ok,why=runtime.Tick(stamp);mutating=false
  if not ok and why~="AlreadyStepped"then fail(why)end
  -- The successful enemy phase just finished its normal corpse cleanup. Close
  -- before another phase can reject that intentionally detached corpse.
  if ok and not fault and witnessed and #deps.Scene.enemies==1 and deps.Scene.enemies[1]==terminalEnemy
   and terminalEnemy.health==0 and terminalEnemy.state=="Dead"and terminalEnemy.model and terminalEnemy.model.Parent==nil then
   completed=true
   local list={};for _,e in pairs(owners)do table.insert(list,e)end;for _,e in ipairs(list)do detach(e)end
   combat.CloseShared();runtime.Close();if rewards then rewards.Close()end
   if deps.Status then call(deps.Status,"Completed",nil)end
   return true,"Completed"
  end
  return ok,why
 end
 function S.Action(player:any,s:any,action:string,now:number,actorId:any):(boolean,boolean,string)
  local c=claimed[player.UserId]
  if not c or c.player~=player or c.s~=s then
   if (fault or closed or completed)and s.playerCombat and inside(s.playerCombat.root)then return true,false,"SharedCombatUnavailable"end
   return false,false,"Outside"
  end
  local e=owners[player.UserId]
  if mutating or not e or not current(e)then return true,false,"SharedCombatUnavailable"end
  mutating=true;local ran,ok,why=pcall(combat.PlayerAction,s,action,now,actorId);mutating=false
  if not ran then fail("ActionFailed");return true,false,"SharedCombatUnavailable"end
  return true,ok,why
 end
 function S.Claimed(player:any,s:any):boolean local c=claimed[player.UserId];return c~=nil and c.player==player and c.s==s end
 function S.Status():string return if fault then "Faulted:"..fault elseif closed then "Closed"elseif completed then "Completed"else "Ready"end
 function S.PumpRewards():(boolean,string)if mutating then return false,"Busy"end;if not rewards then return false,"Disabled"end;return rewards.Pump()end
 function S.RewardState():any return if rewards then rewards.State()else nil end
 function S.Close()
  if closed then return end;closed=true
  local list={};for _,e in pairs(owners)do table.insert(list,e)end;for _,e in ipairs(list)do detach(e)end
  combat.CloseShared();runtime.Close()
  local claims={};for _,c in pairs(claimed)do table.insert(claims,c)end;for _,c in ipairs(claims)do S.Detach(c.player,c.s)end
  if rewards then rewards.Close()end
 end
 return S
end
