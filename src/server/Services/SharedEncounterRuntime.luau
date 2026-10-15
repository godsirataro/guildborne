--!strict
-- Injected same-encounter scheduler only; no production activation or reward delivery.
return function(deps:any):(any?,string?)
 local registry=deps.Registry
 if not registry or type(deps.EnemyStep)~="function" or type(deps.OwnerStep)~="function"then return nil,"InvalidDependencies"end
 local encounter,problem=registry.create();if not encounter then return nil,problem end
 local policy=registry.policy()
 local owners:any={};local enemies:any={};local usedActors:any=setmetatable({},{__mode="k"})
 local sessions:any=setmetatable({},{__mode="k"})
 local ownerCount=0;local closed=false;local busy=false;local lastStamp=-1
 local S={}
 local function ownerValid(id:any):boolean return type(id)=="number" and id==id and id%1==0 and id~=0 and math.abs(id)<=9007199254740991 end
 local function dense(list:any):boolean
  if type(list)~="table" or getmetatable(list)~=nil or #list<1 or #list>6 then return false end
  local count=0
  for key in pairs(list)do if type(key)~="number" or key%1~=0 or key<1 or key>#list then return false end;count+=1 end
  return count==#list
 end
 local function validActor(actor:any,ownerId:number):boolean
  return type(actor)=="table" and getmetatable(actor)==nil and actor.kind=="Hero" and actor.owner==ownerId
   and type(actor.id)=="string" and #actor.id>0 and #actor.id<=64 and actor.id:match("^[%w_:%-]+$")~=nil
 end
 local function detach(entry:any)
  registry.removeOwner(entry.token)
  sessions[entry.session]={ownerId=entry.ownerId,retired=true}
  if owners[entry.ownerId]==entry then owners[entry.ownerId]=nil;ownerCount-=1 end
 end
 function S.Join(ownerId:any,session:any,roster:any):(boolean,string)
  if closed then return false,"Closed"end
  if not ownerValid(ownerId) or type(session)~="table" or not dense(roster)then return false,"InvalidJoin"end
  local previousSession=sessions[session]
  if previousSession and (previousSession.retired or previousSession.ownerId~=ownerId)then return false,"StaleSession"end
  local current=owners[ownerId]
  if current and current.session==session then
   if #roster~=#current.actors then return false,"RosterChangeRequiresLeave"end
   for index,actor in ipairs(roster)do
    if actor~=current.actors[index]then return false,"RosterChangeRequiresLeave"end
    if not policy.key(actor)then return false,"StaleActor"end
   end
   return true,"AlreadyJoined"
  end
  if not current and ownerCount>=16 then return false,"OwnerLimit"end
  local seen,ids={},{}
  for _,actor in ipairs(roster)do
   if not validActor(actor,ownerId) or seen[actor] or ids[actor.id]then return false,"InvalidActor"end
   if usedActors[actor] or policy.key(actor)then return false,"ActorAlreadyUsed"end
   seen[actor]=true;ids[actor.id]=true
  end
  -- Once a new incarnation replaces the old one, failure is closed, never a revival.
  if current then detach(current)end
  local token,ownerProblem=registry.addOwner(encounter,ownerId)
  if not token then return false,ownerProblem or "RegistrationFailed"end
  local registered={}
  for _,actor in ipairs(roster)do
   local key,actorProblem=registry.addActor(encounter,token,actor)
   if not key then registry.removeOwner(token);return false,actorProblem or "RegistrationFailed"end
   usedActors[actor]=true;table.insert(registered,actor)
  end
  owners[ownerId]={ownerId=ownerId,session=session,token=token,actors=registered}
  sessions[session]={ownerId=ownerId,retired=false};ownerCount+=1
  return true,"Joined"
 end
 function S.Leave(ownerId:any,session:any):(boolean,string)
  local entry=owners[ownerId]
  if not entry or entry.session~=session then return false,"StaleSession"end
  detach(entry);return true,"Left"
 end
 function S.AddEnemy(actor:any):(boolean,string)
  if closed then return false,"Closed"end
  if enemies[actor] and policy.key(actor)then return true,"AlreadyRegistered"end
  if type(actor)~="table" or usedActors[actor]then return false,"ActorAlreadyUsed"end
  local key,reason=registry.addEnemy(encounter,actor)
  if not key then return false,reason or "RegistrationFailed"end
  enemies[actor]=true;usedActors[actor]=true;return true,"Registered"
 end
 function S.RemoveEnemy(actor:any):(boolean,string)
  if not enemies[actor]then return false,"UnknownEnemy"end
  enemies[actor]=nil;registry.removeActor(actor);return true,"Removed"
 end
 function S.Policy():any return policy end
 function S.EncounterToken():any? return if closed then nil else encounter end
 local function currentActors(entry:any):any
  local result={}
  if owners[entry.ownerId]==entry then
   for _,actor in ipairs(entry.actors)do if policy.key(actor)then table.insert(result,actor)end end
  end
  return table.freeze(result)
 end
 local function gather():any
  local ids={};for id in pairs(owners)do table.insert(ids,id)end;table.sort(ids)
  local result={}
  for _,id in ipairs(ids)do for _,actor in ipairs(currentActors(owners[id]))do table.insert(result,actor)end end
  return table.freeze(result)
 end
 local function currentEnemies():any
  local result={};for actor in pairs(enemies)do if policy.key(actor)then table.insert(result,actor)end end
  table.sort(result,function(a:any,b:any)return a.id<b.id end)
  return table.freeze(result)
 end
 local function report(stage:string)
  if type(deps.OnError)=="function"then pcall(deps.OnError,stage)end
 end
 function S.Tick(stamp:any):(boolean,string)
  if closed then return false,"Closed"end
  if busy then return false,"Busy"end
  if type(stamp)~="number" or stamp~=stamp or stamp<0 or stamp==math.huge then return false,"InvalidStamp"end
  if stamp<=lastStamp then return false,"AlreadyStepped"end
  busy=true;lastStamp=stamp
  local snapshot={};for _,entry in pairs(owners)do table.insert(snapshot,entry)end
  table.sort(snapshot,function(a:any,b:any)return a.ownerId<b.ownerId end)
  -- Stamp is consumed before any callback: exceptions/yields cannot replay enemy work.
  local ok=pcall(deps.EnemyStep,stamp,gather(),currentEnemies())
  if not ok then report("EnemyStep");busy=false;return false,"EnemyStepFailed"end
  local failed=false
  for _,entry in ipairs(snapshot)do
   if closed then break end
   if owners[entry.ownerId]~=entry then continue end
   local own=currentActors(entry)
   if #own==0 then continue end
   local success=pcall(deps.OwnerStep,entry.ownerId,entry.session,stamp,own,gather(),currentEnemies())
   if not success then failed=true;report("OwnerStep")end
  end
  busy=false
  if closed then return false,"Closed"end
  return not failed,if failed then "OwnerStepFailed"else "Stepped"
 end
 function S.Close()
  if closed then return end
  closed=true
  for _,entry in pairs(owners)do sessions[entry.session]={ownerId=entry.ownerId,retired=true}end
  registry.close(encounter);owners={};enemies={};ownerCount=0
 end
 return S,nil
end
