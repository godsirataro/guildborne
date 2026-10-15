--!strict
-- Experimental server-only eligibility. No payout or profile mutation authority.
return function(identity:any,Now:any,options:any):any
 local function number(n:any,low:number,high:number):boolean return type(n)=="number"and n==n and n>=low and n<=high end
 local function owner(id:any):boolean return number(id,-9007199254740991,9007199254740991)and id~=0 and id%1==0 end
 assert(type(options)=="table"and number(options.totalEnemyHP,1,1000000000),"Invalid fixed HP budget")
 assert(type(options.encounterToken)=="table", "Missing encounter authority")
 local encounterToken=options.encounterToken
 local activity=options.activityWindow or 90;local grace=options.departureGrace or 30
 assert(number(activity,1,90)and number(grace,0,30),"Invalid participation windows")
 local threshold=math.max(1,math.ceil(options.totalEnemyHP*.01))
 local records:any={};local count=0;local wounds:any={};local woundCount=0;local lastSeq=0;local lastNow:number?=nil;local frozen:any=nil
 local function copy(v:any):any if type(v)~="table"then return v end;local out={};for k,x in pairs(v)do out[k]=copy(x)end;return out end
 local function now():number?
  local ok,t=pcall(Now)
  if not ok or not number(t,0,1000000000000)or(lastNow~=nil and t<lastNow)then return nil end
  lastNow=t;return t
 end
 local function key(actor:any):string?
  local ok,k=pcall(identity.key,actor)
  local matched,e=pcall(identity.encounter,actor)
  return if ok and matched and e==encounterToken and type(k)=="string"and #k<=256 then k else nil
 end
 local function membership(actor:any):any
  local ok,token=pcall(identity.ownerToken,actor);return if ok and type(token)=="table"then token else nil
 end
 local function sequence(seq:any):boolean
  if not number(seq,1,2147483647)or seq%1~=0 or seq<=lastSeq then return false end
  lastSeq=seq;return true
 end
 local function prune(t:number)
  for k,w in pairs(wounds)do
   if t-w.lastDamage>activity or key(w.actor)~=k then wounds[k]=nil;woundCount-=1 end
  end
 end
 local function active(id:number,token:any):boolean return token~=nil and (not records[id]or records[id].retiredToken~=token)end
 local function credit(id:number,token:any,kind:string,amount:number,t:number)
  local r=records[id]
  if not r then r={ownerId=id,damage=0,healing=0,tanking=0,lastActivity=t};records[id]=r;count+=1 end
  r[kind]=math.min(1000000000,r[kind]+amount);r.lastActivity=t;r.token=token;r.leftAt=nil
 end
 local L={}
 function L.Observe(seq:any,event:any,a:any,b:any,amount:any):(boolean,string?)
  if frozen then return false,"Frozen"end
  if not sequence(seq)then return false,"InvalidSequence"end
  local t=now();if t==nil then return false,"InvalidClock"end;prune(t)
  if not number(amount,0.000001,1000000000)or type(a)~="table"or type(b)~="table"then return false,"InvalidEffect"end
  local ka,kb=key(a),key(b);if not ka or not kb then return false,"InvalidActor"end
  local heal=event=="healing_done"
  if not heal and event~="damage_dealt"then return false,"InvalidEvent"end
  local ok,valid=pcall(identity.valid,a,b,heal);if not ok or valid~=true then return false,"InvalidPair"end
  local id:any=nil;local token:any=nil;local kind="";local used=amount
  if heal then
   if a.kind~="Hero"or b.kind~="Hero"or not owner(a.owner)or not owner(b.owner)or not active(b.owner,membership(b))then return false,"InvalidHealing"end
   id=a.owner;token=membership(a);kind="healing";used=math.min(amount,if wounds[kb]then wounds[kb].amount else 0)
   if used<=0 then return false,"NoCombatWound"end
  elseif a.kind=="Hero"and b.kind=="Enemy"then id=a.owner;token=membership(a);kind="damage"
  elseif a.kind=="Enemy"and b.kind=="Hero"then
   id=b.owner;token=membership(b);kind="tanking"
   if wounds[kb]==nil and woundCount>=96 then return false,"WoundCapacity"end
  else return false,"InvalidPair"end
  if not owner(id)or not active(id,token)then return false,"InvalidOwner"end
  if not records[id]and count>=16 then return false,"OwnerCapacity"end
  if kind=="tanking"then
   if wounds[kb]==nil then woundCount+=1 end
   wounds[kb]={amount=math.min(1000000000,(if wounds[kb]then wounds[kb].amount else 0)+used),lastDamage=t,actor=b}
  elseif heal then
   wounds[kb].amount-=used;if wounds[kb].amount<=0 then wounds[kb]=nil;woundCount-=1 end
  end
  credit(id,token,kind,used,t);return true,nil
 end
 function L.Recover(seq:any,actor:any,amount:any):(boolean,string?)
  if frozen then return false,"Frozen"end
  if not sequence(seq)then return false,"InvalidSequence"end
  local t=now();if t==nil then return false,"InvalidClock"end;prune(t)
  if not number(amount,0.000001,1000000000)or type(actor)~="table"or actor.kind~="Hero"then return false,"InvalidRecovery"end
  local k=key(actor);if not k then return false,"InvalidActor"end
  local w=wounds[k]
  if w then w.amount=math.max(0,w.amount-amount);if w.amount<=0 then wounds[k]=nil;woundCount-=1 end end
  return true,nil
 end
 function L.Leave(id:any):(boolean,string?)
  if frozen then return false,"Frozen"end
  if not owner(id)then return false,"InvalidOwner"end
  local r=records[id]
  if not r then return true,nil end
  if r and r.leftAt~=nil then return true,nil end
  local t=now();if t==nil then return false,"InvalidClock"end
  r.leftAt=t;r.retiredToken=r.token;return true,nil
 end
 function L.Freeze():(any,string?)
  if frozen then return copy(frozen),nil end
  local t=now();if t==nil then return nil,"InvalidClock"end
  local owners={};local diagnostics={}
  for id,r in pairs(records)do
   local score=math.min(1000000000,r.damage+r.healing+r.tanking)
   local eligible=score>=threshold and t-r.lastActivity<=activity and (r.leftAt==nil or t-r.leftAt<=grace)
   if eligible then table.insert(owners,id)end
   table.insert(diagnostics,{ownerId=id,damage=r.damage,healing=r.healing,tanking=r.tanking,eligible=eligible,departed=r.leftAt~=nil})
  end
  table.sort(owners);table.sort(diagnostics,function(a,b)return a.ownerId<b.ownerId end)
  frozen={owners=owners,diagnostics=diagnostics,lastSeq=lastSeq,threshold=threshold};return copy(frozen),nil
 end
 return L
end
