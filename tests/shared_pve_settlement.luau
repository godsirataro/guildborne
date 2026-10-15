--!strict
return function(test:any,eq:any)
 local S=require("../src/server/Systems/SharedPvESettlement")
 local Repository=require("../src/server/Services/SharedPvESettlementStore")
 local U=require("../src/shared/Util/TableUtil")
 local Memory=require("../src/server/Persistence/MemoryStore")
 local function sample(n:number,id:string?):any
  local owners={};for i=1,n do table.insert(owners,i)end
  return {version=1,encounterId=id or "encounter_1",owners=owners,rotationSeed=5,xp=101,gold=53,items={{itemId="iron_ore",count=17},{itemId="wood",count=3}}}
 end
 test("shared allocations conserve all budgets across solo party and outsiders",function()
  for _,n in ipairs({1,2,6,7,16})do
   local record=S.Build(sample(n));assert(record)
   local xp,gold,iron,wood=0,0,0,0;local low,high=math.huge,0
   for _,a in ipairs(record.allocations)do xp+=a.xp;gold+=a.gold;iron+=a.items.iron_ore or 0;wood+=a.items.wood or 0;low=math.min(low,a.xp);high=math.max(high,a.xp)end
   eq(xp,101);eq(gold,53);eq(iron,17);eq(wood,3);eq(high-low<=1,true)
  end
 end)
 test("canonical input order does not change allocations and seed rotates remainder",function()
  local input=sample(7);local expected=S.Build(input)
  input.owners={7,5,3,1,2,4,6};input.items={input.items[2],input.items[1]};eq(S.Build(input),expected)
  input.rotationSeed=6;eq(U.equal(S.Build(input),expected),false)
  input.xp=0;input.gold=0;input.items={};local zero=S.Build(input);for _,a in ipairs(zero.allocations)do eq(a.xp,0);eq(a.gold,0);eq(a.items,{})end
 end)
 test("signed Studio owner IDs conserve rewards while zero is rejected",function()
  local p=sample(2);p.owners={2,-1};local record=S.Build(p);assert(record);eq(record.snapshot.owners,{-1,2})
  eq(record.allocations[1].xp+record.allocations[2].xp,101)
  p.owners={0,2};eq(S.Build(p),nil)
 end)
 local function v2():any
  local p=sample(2);p.version=2;p.xpPolicy="equal-actors-v1";p.owners={{ownerId=1,actorIds={"player","hero:rowan","hero:mage"}},{ownerId=2,actorIds={"player"}}};return p
 end
 test("v2 frozen actor roster divides owner XP without multiplying rewards",function()
  local p=v2();local result=S.Build(p);assert(result);local total=0
  for _,a in ipairs(result.allocations)do local sum=0;for _,xp in pairs(a.actorXP)do sum+=xp end;eq(sum,a.xp);total+=sum end
  eq(total,101)
  p.owners={p.owners[2],p.owners[1]};p.owners[2].actorIds={"hero:mage","player","hero:rowan"};eq(S.Build(p),result)
  local old=S.Build(sample(2));eq(old.version,1);eq(old.snapshot.xpPolicy,nil);eq(old.allocations[1].actorXP,nil)
  eq(result.allocations[1].xp,old.allocations[1].xp);eq(result.allocations[1].gold,old.allocations[1].gold);eq(result.allocations[1].items,old.allocations[1].items)
 end)
 test("v2 rejects missing player duplicate unsafe oversized and sparse actor rosters",function()
  for _,ids in ipairs({{}, {"hero:rowan"},{"player","player"},{"player","../hero"},{"player","a","b","c","d","e","f"},{[1]="player",[3]="hero"}})do local p=v2();p.owners[1].actorIds=ids;eq(S.Build(p),nil)end
  local p=v2();p.xpPolicy="multiply";eq(S.Build(p),nil)
  p=v2();p.owners[1].extra=true;eq(S.Build(p),nil)
  p=sample(2);p.xpPolicy="equal-actors-v1";eq(S.Build(p),nil)
 end)
 test("v2 repository isolates versions and conflicts on frozen roster change",function()
  local memory=Memory(U);local one=Repository(memory,U,S,"versions");local two=Repository(memory,U,S,"versions",2)
  local p=v2();eq(one.Prepare(sample(2)),S.Build(sample(2)));eq(two.Prepare(p),S.Build(p))
  local _,_,wrong=one.Prepare(p);eq(wrong,"VersionMismatch");local _,_,wrongTwo=two.Prepare(sample(2));eq(wrongTwo,"VersionMismatch")
  local again=Repository(memory,U,S,"versions",2);eq(again.Prepare(p),S.Build(p));p.owners[1].actorIds={"player","hero:new"}
  local _,_,conflict=again.Prepare(p);eq(conflict,"Conflict");eq(one.Read("encounter_1"),S.Build(sample(2)))
 end)
 test("maximum v2 records fit guarded bucket capacity and roundtrip",function()
  local p=v2();p.owners={};p.items={};for i=1,16 do table.insert(p.owners,{ownerId=i,actorIds={"player","h:1","h:2","h:3","h:4","h:5"}})end
  for i=1,32 do table.insert(p.items,{itemId="item_"..i,count=1000000})end
  p.xp=1000000000;p.gold=1000000000
  local repo=Repository(Memory(U),U,S,"maximum",2)
  for i=1,32 do p.encounterId="max_"..i;local record,state=repo.Prepare(p);eq(state,"Prepared");eq(record,S.Build(p))end
  eq(repo.Read("max_32"),S.Build(p));p.encounterId="max_33";local _,_,why=repo.Prepare(p);eq(why,"Capacity")
 end)
 test("snapshot validation rejects sparse duplicate unknown and unsafe numeric input",function()
  for _,value in ipairs({0/0,math.huge,-1,1.5,1000000001})do local p=sample(2);p.xp=value;eq(S.Build(p),nil)end
  for _,owners in ipairs({{1,1},{[1]=1,[3]=3},{0},{9007199254740992},{1,2,extra=3},{}})do local p=sample(2);p.owners=owners;eq(S.Build(p),nil)end
  eq(S.Build(sample(17)),nil)
  local p=sample(2);p.items[2]=p.items[1];eq(S.Build(p),nil)
  p=sample(2);p.items[1].count=1000001;eq(S.Build(p),nil)
  p=sample(2);p.items[1].unknown=true;eq(S.Build(p),nil)
  p=sample(2);p.extra=true;eq(S.Build(p),nil)
  p=sample(2);p.rotationSeed=2147483648;eq(S.Build(p),nil)
  p=sample(2);p.encounterId="../unsafe";eq(S.Build(p),nil)
 end)
 test("repository prepares once across instances conflicts and returns deep copies",function()
  local store=Memory(U);local a=Repository(store,U,S,"test");local b=Repository(store,U,S,"test")
  local p=sample(6);local record,status=a.Prepare(p);eq(status,"Prepared");eq(b.Prepare(p),record)
  record.allocations[1].gold=999;p.owners[1]=88
  local saved=b.Read("encounter_1");eq(saved,S.Build(sample(6)))
  for _,field in ipairs({"gold","xp","rotationSeed"})do local q=sample(6);q[field]+=1;local _,state,reason=b.Prepare(q);eq(state,"Rejected");eq(reason,"Conflict")end
  local _,state,reason=b.Prepare(p);eq(state,"Rejected");eq(reason,"Conflict")
  local q=sample(6);q.items[1].count+=1;local _,_,itemReason=b.Prepare(q);eq(itemReason,"Conflict")
  saved.snapshot.owners[1]=100;eq(a.Read("encounter_1"),S.Build(sample(6)))
 end)
 test("uncertain after commit is recoverable without issuing another allocation",function()
  for _,version in ipairs({1,2})do
  local memory=Memory(U);local fail=true
  local store={Read=memory.Read,Update=function(key:any,transform:any)local result=memory.Update(key,transform);if fail then fail=false;error("lost acknowledgement")end;return result end}
  local a=Repository(store,U,S,"uncertain",version);local p=if version==1 then sample(7)else v2()
  local record,status,reason=a.Prepare(p);eq(record,nil);eq(status,"Unavailable");eq(reason,"WriteUnconfirmed")
  local b=Repository(store,U,S,"uncertain",version);eq(b.Read(p.encounterId),S.Build(p));eq(b.Prepare(p),S.Build(p))
  end
 end)
 test("capacity fails closed never evicts existing settlements and namespaces isolate",function()
  local memory=Memory(U);local a=Repository(memory,U,S,"capacity")
  for i=1,32 do local _,status=a.Prepare(sample(1,"e_"..i));eq(status,"Prepared")end
  local _,status,reason=a.Prepare(sample(1,"e_33"));eq(status,"Rejected");eq(reason,"Capacity")
  eq(a.Prepare(sample(1,"e_1")),S.Build(sample(1,"e_1")))
  local isolated=Repository(memory,U,S,"other");local _,state=isolated.Read("e_1");eq(state,"Missing")
  eq(isolated.Prepare(sample(1,"e_33")),S.Build(sample(1,"e_33")))
 end)
 test("atomic callback retries use the latest bucket without duplicate entries",function()
  local memory=Memory(U);local other=Repository(memory,U,S,"retry");local injected=false
  local store={Read=memory.Read,Update=function(key:any,transform:any)
   transform(memory.Read(key)) -- discarded proposal before a competing commit
   if not injected then injected=true;other.Prepare(sample(2,"other"))end
   return memory.Update(key,transform)
  end}
  local a=Repository(store,U,S,"retry");eq(a.Prepare(sample(7)),S.Build(sample(7)))
  eq(a.Read("other"),S.Build(sample(2,"other")));eq(a.Read("encounter_1"),S.Build(sample(7)))
 end)
 test("malformed storage and read failures cannot manufacture settlements",function()
  local memory=Memory(U);memory.Update("shared-pve-v1:bad",function()return {version=1,records={corrupt={}}}end)
  local a=Repository(memory,U,S,"bad");local _,state=a.Read("corrupt");eq(state,"Unavailable")
  local _,_,reason=a.Prepare(sample(1));eq(reason,"InvalidBucket")
  local b=Repository({Read=function()error("offline")end,Update=function()error("offline")end},U,S,"offline")
  local _,_,readReason=b.Read("e");eq(readReason,"ReadFailed")
  local _,_,writeReason=b.Prepare(sample(1));eq(writeReason,"WriteUnconfirmed")
 end)
 test("metatable views cyclic graphs and oversized records fail before copying",function()
  local canonical=S.Build(sample(7));local bad:any={}
  table.insert(bad,setmetatable({},{__index=canonical}))
  local allocations=U.copy(canonical);allocations.allocations=setmetatable({},{__index=canonical.allocations});table.insert(bad,allocations)
  local entry=U.copy(canonical);entry.allocations[1]=setmetatable({},{__index=canonical.allocations[1]});table.insert(bad,entry)
  local cycle=U.copy(canonical);cycle.extra=cycle;table.insert(bad,cycle)
  local oversized=U.copy(canonical);oversized.extra={};for i=1,2049 do oversized.extra[i]=i end;table.insert(bad,oversized)
  for _,record in ipairs(bad)do
   local bucket={version=1,records={encounter_1=record}}
   local store={Read=function()return bucket end,Update=function(_key:any,transform:any)return transform(bucket)end}
   local a=Repository(store,U,S,"malformed")
   local found,status,reason=a.Read("encounter_1");eq(found,nil);eq(status,"Unavailable");eq(reason,"InvalidBucket")
   local prepared,state,why=a.Prepare(sample(7));eq(prepared,nil);eq(state,"Rejected");eq(why,"InvalidBucket")
  end
 end)
end
