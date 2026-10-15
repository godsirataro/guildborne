--!strict
-- Explicit server-owned PvE membership. Token and actor object identity are authority.
return function():any
 local encounters:any={};local owners:any={};local actors:any=setmetatable({},{__mode="k"})
 local serial=0;local encounterCount=0;local R={}
 local function nextId():number serial+=1;return serial end
 local function ownerId(id:any):boolean return type(id)=="number" and id==id and id%1==0 and id~=0 and math.abs(id)<=9007199254740991 end
 local function localId(id:any):boolean return type(id)=="string" and #id>=1 and #id<=64 and id:match("^[%w_:%-]+$")~=nil end
 local function resolve(actor:any):any?
  if type(actor)~="table" then return nil end
  local r=actors[actor]
  if not r or not r.active or not r.encounter.active or (r.owner and not r.owner.active)then return nil end
  if actor.id~=r.id or actor.owner~=r.ownerId or actor.kind~=r.kind then r.active=false;return nil end
  return r
 end
 function R.create():(any?,string?)
  if encounterCount>=8 then return nil,"EncounterLimit"end
  local token=table.freeze({})
  encounters[token]={active=true,token=token,id=nextId(),owners={},enemies={},actors={},ownerCount=0,enemyCount=0}
  encounterCount+=1
  return token,nil
 end
 function R.addOwner(encounter:any,id:any):(any?,string?)
  local e=encounters[encounter]
  if not e or not e.active or not ownerId(id)then return nil,"InvalidOwner"end
  if e.owners[id]then return nil,"OwnerAlreadyRegistered"end
  if e.ownerCount>=16 then return nil,"OwnerLimit"end
  local token=table.freeze({});local o={active=true,id=id,generation=nextId(),encounter=e,actors={},actorCount=0,token=token}
  owners[token]=o;e.owners[id]=o;e.ownerCount+=1;return token,nil
 end
 local function register(e:any,o:any,actor:any):(string?,string?)
  if type(actor)~="table" or getmetatable(actor)~=nil or not localId(actor.id)then return nil,"InvalidActor"end
  if actors[actor]then return nil,"ActorAlreadyRegistered"end
  if o then
   if actor.kind~="Hero" or actor.owner~=o.id then return nil,"InvalidActor"end
  elseif actor.kind~="Enemy" or type(actor.owner)~="number" or actor.owner~=actor.owner or actor.owner%1~=0 or math.abs(actor.owner)>9007199254740991 then return nil,"InvalidActor"end
  local index=if o then o.actors else e.enemies
  if index[actor.id]then return nil,"ActorIdInUse"end
  if (o and o.actorCount>=6)or(not o and e.enemyCount>=64)then return nil,"ActorLimit"end
  local key="enc:"..e.id..":"..(if o then "owner:"..string.format("%.0f",o.id)..":"..o.generation else "enemy")..":"..#actor.id..":"..actor.id..":actor:"..nextId()
  local r={active=true,encounter=e,owner=o,ownerId=actor.owner,id=actor.id,kind=actor.kind,key=key,index=index,actor=actor}
  actors[actor]=r;index[actor.id]=r;e.actors[actor]=r
  if o then o.actorCount+=1 else e.enemyCount+=1 end
  return key,nil
 end
 function R.addActor(encounter:any,ownerToken:any,actor:any):(string?,string?)
  local e,o=encounters[encounter],owners[ownerToken]
  if not e or not e.active or not o or not o.active or o.encounter~=e then return nil,"InvalidMembership"end
  return register(e,o,actor)
 end
 function R.addEnemy(encounter:any,actor:any):(string?,string?)
  local e=encounters[encounter];if not e or not e.active then return nil,"InvalidEncounter"end
  return register(e,nil,actor)
 end
 function R.removeActor(actor:any)
  local r=actors[actor];if not r then return end
  r.active=false
  if r.index and r.index[r.id]==r then
   r.index[r.id]=nil
   if r.owner then r.owner.actorCount-=1 else r.encounter.enemyCount-=1 end
  end
  if r.encounter then r.encounter.actors[actor]=nil end
  r.actor=nil;r.index=nil;r.encounter=nil;r.owner=nil
 end
 function R.removeOwner(token:any)
  local o=owners[token];if not o then return end
  o.active=false;o.encounter.owners[o.id]=nil;o.encounter.ownerCount-=1;owners[token]=nil
  local remove={};for _,r in pairs(o.actors)do table.insert(remove,r.actor)end
  for _,actor in ipairs(remove)do R.removeActor(actor)end
 end
 function R.close(token:any)
  local e=encounters[token];if not e then return end
  e.active=false;encounters[token]=nil;encounterCount-=1
  local remove={};for _,o in pairs(e.owners)do table.insert(remove,o.token)end
  for _,owner in ipairs(remove)do R.removeOwner(owner)end
  local remaining={};for actor in pairs(e.actors)do table.insert(remaining,actor)end
  for _,actor in ipairs(remaining)do R.removeActor(actor)end
 end
 function R.policy():any
  return table.freeze({
   valid=function(a:any,b:any,ally:boolean?):boolean
    local ra,rb=resolve(a),resolve(b)
    if not ra or not rb or ra.encounter~=rb.encounter then return false end
    if ally then return ra.kind=="Hero" and rb.kind=="Hero"end
    return (ra.kind=="Hero" and rb.kind=="Enemy")or(ra.kind=="Enemy" and rb.kind=="Hero")
   end,
   key=function(actor:any):string? local r=resolve(actor);return if r then r.key else nil end,
   encounter=function(actor:any):any? local r=resolve(actor);return if r then r.encounter.token else nil end,
   ownerToken=function(actor:any):any? local r=resolve(actor);return if r and r.owner then r.owner.token else nil end,
  })
 end
 return R
end
