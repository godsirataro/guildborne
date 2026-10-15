--!strict
-- Trusted server snapshot only. Allocation records authorize no profile payouts.
local S={Limits={Owners=16,ItemTypes=32,Budget=1000000000,ItemCount=1000000}}
local function integer(n:any,low:number,high:number):boolean
 return type(n)=="number" and n==n and n>=low and n<=high and n%1==0
end
local function fields(v:any,allowed:any):boolean
 if type(v)~="table" or getmetatable(v)~=nil then return false end
 for k in pairs(v)do if not allowed[k]then return false end end;return true
end
local function array(v:any,maximum:number):boolean
 if type(v)~="table"or getmetatable(v)~=nil then return false end
 local count=0;for k in pairs(v)do if not integer(k,1,maximum)then return false end;count+=1 end
 for i=1,count do if v[i]==nil then return false end end;return count<=maximum
end
function S.ValidId(id:any):boolean
 return type(id)=="string" and #id>=1 and #id<=64 and id:match("^[%w_%-]+$")~=nil
end
function S.Build(raw:any):(any,string?)
 local v2=type(raw)=="table"and getmetatable(raw)==nil and raw.version==2
 local allowed={version=true,encounterId=true,owners=true,rotationSeed=true,xp=true,gold=true,items=true}
 if v2 then allowed.xpPolicy=true end
 if not fields(raw,allowed)
  or (raw.version~=1 and not v2) or(v2 and raw.xpPolicy~="equal-actors-v1")or not S.ValidId(raw.encounterId) or not integer(raw.rotationSeed,0,2147483647)
  or not integer(raw.xp,0,S.Limits.Budget) or not integer(raw.gold,0,S.Limits.Budget)
  or not array(raw.owners,S.Limits.Owners) or #raw.owners<1 or not array(raw.items,S.Limits.ItemTypes) then return nil,"InvalidSnapshot" end
 local owners:any={};local seen:any={}
 for _,entry in ipairs(raw.owners)do
  local owner=entry
  if v2 then
   if not fields(entry,{ownerId=true,actorIds=true})or not array(entry.actorIds,6)or #entry.actorIds<1 then return nil,"InvalidRoster"end
   owner=entry.ownerId
  end
  if not integer(owner,-9007199254740991,9007199254740991)or owner==0 or seen[owner]then return nil,"InvalidOwner"end
  seen[owner]=true
  if v2 then
   local actors={};local unique:any={}
   for _,id in ipairs(entry.actorIds)do
    if type(id)~="string"or #id<1 or #id>64 or not id:match("^[%w_:%-]+$")or unique[id]then return nil,"InvalidRoster"end
    unique[id]=true;table.insert(actors,id)
   end
   if not unique.player then return nil,"MissingPlayer"end
   table.sort(actors);table.insert(owners,{ownerId=owner,actorIds=actors})
  else table.insert(owners,owner)end
 end
 table.sort(owners,function(a:any,b:any)return (if v2 then a.ownerId else a)<(if v2 then b.ownerId else b)end)
 local items={};seen={}
 for _,item in ipairs(raw.items)do
  if not fields(item,{itemId=true,count=true})or not S.ValidId(item.itemId)or not integer(item.count,1,S.Limits.ItemCount)or seen[item.itemId]then return nil,"InvalidItem"end
  seen[item.itemId]=true;table.insert(items,{itemId=item.itemId,count=item.count})
 end;table.sort(items,function(a,b)return a.itemId<b.itemId end)
 local snapshot:any={version=raw.version,encounterId=raw.encounterId,owners=owners,rotationSeed=raw.rotationSeed,xp=raw.xp,gold=raw.gold,items=items}
 if v2 then snapshot.xpPolicy=raw.xpPolicy end
 local allocations:any={};for _,owner in ipairs(owners)do table.insert(allocations,{ownerId=if v2 then owner.ownerId else owner,xp=0,gold=0,items={}})end
 local n=#owners;local cursor=raw.rotationSeed%n
 local function distribute(total:number,write:any)
  local base=math.floor(total/n);local remainder=total%n
  for i=1,n do local offset=(i-1-cursor+n)%n;write(allocations[i],base+(if offset<remainder then 1 else 0))end
  cursor=(cursor+remainder)%n
 end
 distribute(raw.xp,function(a:any,count:number)a.xp=count end)
 distribute(raw.gold,function(a:any,count:number)a.gold=count end)
 for _,item in ipairs(items)do distribute(item.count,function(a:any,count:number)if count>0 then a.items[item.itemId]=count end end)end
 if v2 then
  for i,a in ipairs(allocations)do
   local ids=owners[i].actorIds;local size=#ids;local base=math.floor(a.xp/size);local remainder=a.xp%size;local start=raw.rotationSeed%size
   a.actorXP={}
   for j,id in ipairs(ids)do a.actorXP[id]=base+(if (j-1-start+size)%size<remainder then 1 else 0)end
  end
 end
 return {version=raw.version,snapshot=snapshot,allocations=allocations},nil
end
return S
