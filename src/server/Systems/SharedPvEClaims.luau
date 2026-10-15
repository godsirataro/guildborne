--!strict
-- Private durable recipient claims. No remote dispatch and no settlement acknowledgement.
local S={}
local function integer(n:any,lo:number,hi:number):boolean return type(n)=="number"and n==n and n%1==0 and n>=lo and n<=hi end
local function fields(t:any,allowed:any):boolean
 if type(t)~="table"or getmetatable(t)~=nil then return false end
 for k in pairs(t)do if not allowed[k]then return false end end;return true
end
local function id(v:any,max:number):boolean return type(v)=="string"and #v>0 and #v<=max and v:match("^[%w_%-]+$")~=nil end
function S.key(c:any):string return c.namespace..":"..c.encounterId end
function S.validateClaim(c:any,owner:any):boolean
 if not fields(c,{namespace=true,encounterId=true,settlementVersion=true,xpPolicy=true,allocation=true})or not id(c.namespace,24)or not id(c.encounterId,64)
  or c.settlementVersion~=2 or c.xpPolicy~="equal-actors-v1"then return false end
 local a=c.allocation
 if not fields(a,{ownerId=true,xp=true,gold=true,items=true,actorXP=true})or not integer(a.ownerId,-9007199254740991,9007199254740991)or a.ownerId==0 or a.ownerId~=owner
  or not integer(a.xp,0,1000000000)or not integer(a.gold,0,1000000000)or type(a.items)~="table"or getmetatable(a.items)~=nil
  or type(a.actorXP)~="table"or getmetatable(a.actorXP)~=nil then return false end
 local count=0
 for item,n in pairs(a.items)do count+=1;if count>32 or not id(item,64)or not integer(n,1,1000000)then return false end end
 count=0;local sum=0
 for actor,n in pairs(a.actorXP)do
  count+=1;if count>6 or type(actor)~="string"or #actor<1 or #actor>64 or not actor:match("^[%w_:%-]+$")or not integer(n,0,1000000000)then return false end
  sum+=n
 end
 return count>0 and a.actorXP.player~=nil and sum==a.xp
end
function S.validateExtension(data:any):boolean
 local ext=data.sharedPvEClaims;if ext==nil then return true end
 if not fields(ext,{version=true,receipts=true})or ext.version~=1 or type(ext.receipts)~="table"or getmetatable(ext.receipts)~=nil then return false end
 local count=0
 for key,claim in pairs(ext.receipts)do
  count+=1;if count>32 or not S.validateClaim(claim,data.profile.userId)or key~=S.key(claim)then return false end
 end;return true
end
-- Conservative JSON upper bound, including worst-case string escaping. Reject cycles.
function S.bytes(value:any):number
 local seen:any={};local nodes=0
 local function walk(v:any):number
  nodes+=1;if nodes>100000 then return math.huge end
  if type(v)=="string"then return #v*6+2 elseif type(v)=="number"then return 32 elseif type(v)=="boolean"then return 5 elseif v==nil then return 4 end
  if type(v)~="table"or getmetatable(v)~=nil or seen[v]then return math.huge end
  seen[v]=true;local total=2
  for k,child in pairs(v)do total+=walk(k)+walk(child)+2 end
  seen[v]=nil;return total
 end
 return walk(value)
end
function S.new(content:any,util:any,economy:any):any
 local C={validateClaim=S.validateClaim,validateExtension=S.validateExtension,key=S.key}
 function C.check(record:any,claim:any):string?
  if not S.validateClaim(claim,record.data.profile.userId)or not S.validateExtension(record.data)then return "InvalidSharedClaim"end
  local ext=record.data.sharedPvEClaims;local prior=ext and ext.receipts[S.key(claim)]
  if prior then return if util.equal(prior,claim)then "AlreadyCommitted"else "SharedClaimConflict"end
  return nil
 end
 function C.apply(record:any,command:any):(any,any,any)
  local claim=command.args;local problem=C.check(record,claim)
  if problem then return nil,{code=problem},{} end
  local copy=util.copy(record);local d=copy.data;local a=claim.allocation
  local ext=d.sharedPvEClaims or {version=1,receipts={}}
  if util.count(ext.receipts)>=32 then return nil,{code="SharedClaimCapacity"},{} end
  for actorId,xp in pairs(a.actorXP)do
   local actor=if actorId=="player"then d.character else d.adventurers[actorId]
   if not actor or not actor.classId then return nil,{code="SharedClaimActorMissing"},{} end
   if not util.integer(actor.xp+xp,0,content.Limits.XP)then return nil,{code="XPCap"},{} end
   actor.xp+=xp;actor.level=content:LevelFromXP(actor.xp,content.ProfileLevelCap(d))
  end
  local events={};local function emit(name:string,payload:any)table.insert(events,{name=name,payload=payload})end
  problem=economy.gold(d,a.gold,"shared_pve",emit);if problem then return nil,{code=problem},{} end
  local sequence=d.inventory.nextEquipmentSequence
  if not util.integer(sequence,1,999999999)then return nil,{code="InventoryFull"},{} end
  local ids={};for itemId in pairs(a.items)do table.insert(ids,itemId)end;table.sort(ids)
  local items={};for _,itemId in ipairs(ids)do table.insert(items,{Id=itemId,Quantity=a.items[itemId]})end
  problem=economy.items(d,items,"shared:"..sequence,emit);if problem then return nil,{code=problem},{} end
  d.inventory.nextEquipmentSequence+=1
  ext.receipts[S.key(claim)]=util.copy(claim);d.sharedPvEClaims=ext
  emit("shared_pve_claim",{namespace=claim.namespace,encounterId=claim.encounterId,xp=a.xp,gold=a.gold})
  -- Model the full next operation/audit envelope; keep old results for a conservative bound.
  local prospective=util.copy(copy);local opId=tostring(record.session.epoch)..":"..command.requestId
  table.insert(prospective.operations.recentResults,{id=opId,command=util.copy(command),result={code="OK",revision=record.revision+1}})
  for i,event in ipairs(events)do
   local e=util.copy(event);e.sequence=record.audit.nextSequence+i-1;e.eventId=tostring(d.profile.userId)..":"..tostring(e.sequence)
   e.operationId=opId;e.occurredAt=100000000000;e.contentVersion=content.Version;table.insert(prospective.audit.outbox,e)
  end
  if S.bytes(prospective)+1024>content.Limits.ProfileBytes then return nil,{code="SharedClaimProfileCapacity"},{} end
  return copy,{code="OK"},events
 end
 return C
end
return S
