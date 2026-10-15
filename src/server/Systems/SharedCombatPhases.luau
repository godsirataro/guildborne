--!strict
-- Server-only capabilities. Preparation precedes registration; no Roblox dependencies.
return function(context:any):any
 assert(type(context.SceneToken)=="table"and type(context.EncounterToken)=="table"and type(context.Policy)=="table")
 assert(type(context.Contains)=="function"and type(context.IsCurrent)=="function")
 local registry=context.Policy;local scene=context.SceneToken;local encounter=context.EncounterToken
 local records:any=setmetatable({},{__mode="k"});local owners:any={};local attached:any=setmetatable({},{__mode="k"})
 local faulted=false;local closed=false;local enemyStamp=-1;local enemyBusy=false;local enemyResult:any=nil;local executing=false
 local function predicate(callback:any,...:any):boolean
  if closed or faulted then return false end
  local thread=coroutine.create(callback);local ok,result=coroutine.resume(thread,...)
  if not ok or coroutine.status(thread)~="dead"then
   if coroutine.status(thread)~="dead"then coroutine.close(thread)end;faulted=true;return false
  end
  return result==true
 end
 local function current(owner:any):boolean return not closed and not faulted and context.SceneToken==scene and context.EncounterToken==encounter and predicate(context.IsCurrent,owner.id,owner.session) end
 local function member(actor:any):boolean
  if closed or faulted or context.SceneToken~=scene or context.EncounterToken~=encounter or type(actor)~="table"or registry.encounter(actor)~=encounter or not registry.key(actor)or not predicate(context.Contains,actor)then return false end
  if actor.kind=="Enemy"then return not closed and not faulted end
  local entry=attached[actor]
  return entry~=nil and owners[actor.owner]==entry and current(entry)and registry.ownerToken(actor)==entry.registration
 end
 local policy={}
 function policy.key(actor:any):any return if member(actor)then registry.key(actor)else nil end
 function policy.valid(a:any,b:any,ally:any):boolean return member(a)and member(b)and registry.valid(a,b,ally)end
 local function dense(actors:any,maximum:number):boolean
  if type(actors)~="table"or getmetatable(actors)~=nil or #actors<1 or #actors>maximum then return false end
  local n=0;for k in pairs(actors)do if type(k)~="number"or k%1~=0 or k<1 or k>#actors then return false end;n+=1 end
  return n==#actors
 end
 local function stampValid(stamp:any):boolean return type(stamp)=="number"and stamp==stamp and stamp>=0 and stamp<math.huge end
 local S={Policy=table.freeze(policy)}
 function S.CommandReady():boolean return not executing and not closed and not faulted end
 function S.CanPrepare(ownerId:number,session:any,stamp:any):boolean
  if executing or closed or faulted or type(session)~="table"or not stampValid(stamp)or stamp<=enemyStamp then return false end
  if type(ownerId)~="number"or ownerId%1~=0 or ownerId==0 or math.abs(ownerId)>9007199254740991 or not predicate(context.IsCurrent,ownerId,session)then return false end
  local previous=owners[ownerId];if previous and previous.stamp>=stamp then return false end
  local count=0;for _ in pairs(owners)do count+=1 end;return previous~=nil or count<16
 end
 function S.Prepare(ownerId:number,session:any,stamp:any,actors:any,payload:any):(any?,string)
  if not S.CanPrepare(ownerId,session,stamp)or type(session)~="table"or not stampValid(stamp)or stamp<=enemyStamp or not dense(actors,6)then return nil,"InvalidPreparation"end
  if type(ownerId)~="number"or ownerId%1~=0 or ownerId==0 or math.abs(ownerId)>9007199254740991 then return nil,"InvalidOwner"end
  if not predicate(context.IsCurrent,ownerId,session)then return nil,"StaleSession"end
  local count=0;for _ in pairs(owners)do count+=1 end;if not owners[ownerId]and count>=16 then return nil,"OwnerLimit"end
  local seen:any={};local ids:any={};local identities:any={};local list={}
  for _,actor in ipairs(actors)do
   if type(actor)~="table"or actor.kind~="Hero"or actor.owner~=ownerId or type(actor.id)~="string"or seen[actor]or ids[actor.id]then return nil,"InvalidActors"end
   seen[actor]=true;ids[actor.id]=true;identities[actor]=actor.id;table.insert(list,actor)
  end
  if not ids.player then return nil,"MissingPlayer"end
  local previous=owners[ownerId]
  if previous and previous.stamp>=stamp then return nil,"StaleStamp"end
  if previous then
   records[previous.token]=nil
   for _,actor in ipairs(previous.actors)do if attached[actor]==previous then attached[actor]=nil end end
  end
  local token=table.freeze({});local entry={id=ownerId,session=session,stamp=stamp,actors=table.freeze(list),identities=identities,payload=payload,phase="Prepared",token=token}
  records[token]=entry;owners[ownerId]=entry
  return token,"Prepared"
 end
 local function resolve(token:any,phase:string):any
  local e=records[token]
  if not e or e.phase~=phase or owners[e.id]~=e or not current(e)then return nil end
  return e
 end
 function S.Register(token:any):(boolean,string)
  if executing then return false,"PhaseBusy"end
  local e=resolve(token,"Prepared");if not e then return false,"StalePhase"end
  local registration=nil
  for _,actor in ipairs(e.actors)do
   if actor.owner~=e.id or actor.kind~="Hero"or actor.id~=e.identities[actor]then return false,"ChangedActors"end
   local owner=registry.ownerToken(actor)
   if not owner or registry.encounter(actor)~=encounter or(registration and registration~=owner)then return false,"NotRegistered"end
   registration=owner
  end
  e.registration=registration;e.phase="Registered"
  for _,actor in ipairs(e.actors)do attached[actor]=e end
  return true,"Registered"
 end
 function S.Own(actor:any):any
  local entry=attached[actor];local result={}
  if member(actor)and entry then for _,a in ipairs(entry.actors)do if member(a)then table.insert(result,a)end end end
  return table.freeze(result)
 end
 function S.Support():any
  local ids={};for id in pairs(owners)do table.insert(ids,id)end;table.sort(ids)
  local result={}
  for _,id in ipairs(ids)do local e=owners[id];for _,actor in ipairs(e.actors)do if member(actor)then table.insert(result,actor)end end end
  return table.freeze(result)
 end
 function S.Enemies(stamp:any,enemies:any,callback:any):(boolean,string)
  if executing or closed or faulted or enemyBusy or not stampValid(stamp)or stamp<=enemyStamp then return false,"StaleEnemyPhase"end
  if not dense(enemies,64)then return false,"InvalidEnemies"end
  local seen:any={}
  for _,e in ipairs(enemies)do if type(e)~="table"or getmetatable(e)~=nil or e.kind~="Enemy"or seen[e]or not member(e)then return false,"InvalidEnemies"end;seen[e]=true end
  for _,owner in pairs(owners)do if not current(owner)or owner.stamp~=stamp or owner.phase~="Registered"then return false,"OwnersNotPrepared"end;for _,actor in ipairs(owner.actors)do if not member(actor)then return false,"StaleMembership"end end end
  enemyStamp=stamp;enemyBusy=true;enemyResult=nil;executing=true
  local ok,result=pcall(callback,S.Support(),table.freeze(table.clone(enemies)))
  enemyBusy=false;executing=false
  if not ok then faulted=true;return false,"EnemyPhaseFailed"end
  if closed or faulted then return false,"Closed"end
  enemyResult=result;return true,"EnemiesStepped"
 end
 function S.Owner(token:any,callback:any):(boolean,string)
  if executing then return false,"PhaseBusy"end
  local e=resolve(token,"Registered")
  if not e or enemyBusy or enemyStamp~=e.stamp then return false,"StalePhase"end
  for _,actor in ipairs(e.actors)do if not member(actor)then return false,"StaleMembership"end end
  e.phase="Running";executing=true
  local ok=pcall(callback,e.payload,e.actors,S.Support(),enemyResult)
  executing=false
  if not ok then faulted=true;return false,"OwnerPhaseFailed"end
  if owners[e.id]~=e or not current(e)then return false,"StalePhase"end
  e.phase="Stepped";return true,"OwnerStepped"
 end
 function S.Finish(token:any,callback:any):(boolean,string)
  if executing then return false,"PhaseBusy"end
  local e=resolve(token,"Stepped");if not e then return false,"StalePhase"end
  e.phase="Finished";executing=true;local ok=pcall(callback,e.payload);executing=false
  if not ok then faulted=true;return false,"FinishFailed"end
  if owners[e.id]~=e or not current(e)then return false,"StalePhase"end
  return true,"Finished"
 end
 function S.Detach(ownerId:number,session:any)
  local e=owners[ownerId];if not e or e.session~=session then return end
  owners[ownerId]=nil;records[e.token]=nil
  for _,actor in ipairs(e.actors)do if attached[actor]==e then attached[actor]=nil end end
 end
 function S.Call(callback:any,...:any):boolean
  if type(callback)~="function"then return false end
  if closed or faulted then return false end
  local thread=coroutine.create(callback);local ok=coroutine.resume(thread,...)
  if not ok or coroutine.status(thread)~="dead"then
   if coroutine.status(thread)~="dead"then coroutine.close(thread)end
   faulted=true;return false
  end
  return true
 end
 function S.Notify(name:string,...:any):boolean
  local callback=context[name];if callback==nil then return true end
  return S.Call(callback,...)
 end
 function S.Close()closed=true;owners={};attached=setmetatable({},{__mode="k"});records=setmetatable({},{__mode="k"})end
 return S
end
