--!strict
-- Inject Store.Read/Update backed by one atomic authority. No runtime provider is created.
-- Unconfirmed writes must be resolved by Read/Prepare retry; there is no payout API.
return function(store:any,util:any,settlement:any,namespace:string,version:number?)
 assert(type(namespace)=="string"and #namespace>=1 and #namespace<=24 and namespace:match("^[%w_%-]+$"),"Invalid namespace")
 local schemaVersion=version or 1;assert(schemaVersion==1 or schemaVersion==2,"Invalid settlement version")
 local key="shared-pve-v"..schemaVersion..":"..namespace
 local maximum=32
 local function plainRecord(record:any):boolean
  -- Validate the raw tree before indexing or recursive equality/copy. Providers
  -- must return serialized data, never metatable views, aliases or cyclic graphs.
  local visited:any={};local remaining=2048
  local function walk(value:any,depth:number):boolean
   remaining-=1;if remaining<0 or depth>8 then return false end
   if type(value)~="table"then return type(value)=="string"or type(value)=="number"or type(value)=="boolean"end
   if getmetatable(value)~=nil or visited[value]then return false end
   visited[value]=true
   for key,child in next,value do
    if type(key)~="string"and type(key)~="number"then return false end
    if not walk(child,depth+1)then return false end
   end;return true
  end
  return walk(record,0)
 end
 local function valid(bucket:any):boolean
  if type(bucket)~="table"or getmetatable(bucket)~=nil or bucket.version~=schemaVersion or type(bucket.records)~="table"or getmetatable(bucket.records)~=nil then return false end
  for field in pairs(bucket)do if field~="version"and field~="records"then return false end end
  local count=0
  for id,record in pairs(bucket.records)do
   count+=1;if count>maximum or not settlement.ValidId(id)or type(record)~="table"or not plainRecord(record)then return false end
   local rebuilt=settlement.Build(record.snapshot)
   if not rebuilt or rebuilt.version~=schemaVersion or rebuilt.snapshot.encounterId~=id or not util.equal(rebuilt,record)then return false end
  end;return true
 end
 local R={}
 function R.Read(id:any):(any,string,string?)
  if not settlement.ValidId(id)then return nil,"Rejected","InvalidId"end
  local ok,bucket=pcall(store.Read,key)
  if not ok then return nil,"Unavailable","ReadFailed"end
  if bucket==nil then return nil,"Missing",nil end
  if not valid(bucket)then return nil,"Unavailable","InvalidBucket"end
  if bucket.records[id]==nil then return nil,"Missing",nil end
  return util.copy(bucket.records[id]),"Found",nil
 end
 function R.Prepare(snapshot:any):(any,string,string?)
  local candidate,why=settlement.Build(snapshot)
  if not candidate then return nil,"Rejected",why end
  if candidate.version~=schemaVersion then return nil,"Rejected","VersionMismatch"end
  local id=candidate.snapshot.encounterId;local rejection:string?=nil
  local ok,bucket=pcall(store.Update,key,function(current:any):any
   rejection=nil
   if current==nil then current={version=schemaVersion,records={}}end
   if not valid(current)then rejection="InvalidBucket";return nil end
   local existing=current.records[id]
   if existing then
    if not util.equal(existing,candidate)then rejection="Conflict";return nil end
    return current
   end
   local count=0;for _ in pairs(current.records)do count+=1 end
   if count>=maximum then rejection="Capacity";return nil end
   local nextBucket=util.copy(current);nextBucket.records[id]=util.copy(candidate);return nextBucket
  end)
  if not ok then return nil,"Unavailable","WriteUnconfirmed"end
  if bucket==nil then return nil,if rejection then "Rejected"else "Unavailable",rejection or "WriteUnconfirmed"end
  if not valid(bucket)or not util.equal(bucket.records[id],candidate)then return nil,"Unavailable","InvalidCommit"end
  return util.copy(bucket.records[id]),"Prepared",nil
 end
 return R
end
