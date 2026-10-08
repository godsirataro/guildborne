--!strict
return function(test: any,eq: any,util: any,content: any,legacySchema: any)
 local C=util.copy(require('../src/server/Config/Market'));C.ReplaySeconds=0
 local O=require('../src/server/Systems/MarketOrders')(C,util)
 local E=require('../src/server/Systems/MarketEscrow')(C,util,content,O)
 local M=require('../src/server/Systems/MarketMatching')(C,O)
 local BaseBook=require('../src/server/Systems/MarketBook')
 local D=require('../src/server/Systems/MarketData')(C,util,O)
 local B=require('../src/server/Systems/MarketEpochs')(C,util,O,M,BaseBook,D)
 local Expansion=require('../src/shared/Data/Expansion')
 local Gear=require('../src/shared/Data/Equipment')(content,Expansion)
 local Schema=require('../src/server/Systems/ProfileSchema')(content,util,Gear,Expansion,require('../src/server/Systems/ExpansionSchema')(content,util,Expansion),E)
 local MakeData=require('../src/server/Services/PlayerDataService')
 local MakeMarket=require('../src/server/Services/MarketService')
 local function order(side: string,q: number?,price: number?,kind: string?): any
  return {itemId='iron_ore',side=side,quantity=q or 10,price=price or 100,kind=kind or 'LIMIT'}
 end
 local function harness(): any
  local h: any={now=1000,books={},profiles={},servers={},data={},serial=0,notifications=0,index={},fault=nil,profileFault=nil}
  local store={Read=function(k: string) return util.copy(h.books[k]) end,Update=function(k: string,f: any)
   if h.fault=='before' then error('before durable write') end
   if h.interleave then local hook=h.interleave;h.interleave=nil;f(util.copy(h.books[k]));hook() end
   if h.replay then f(util.copy(h.books[k])) end
   local value=f(util.copy(h.books[k]));if value then h.books[k]=util.copy(value) end
   if h.fault=='after' then error('after durable write') end
   return util.copy(value)
  end}
  local profileStore={Update=function(k: string,f: any)
   if h.profileFault=='before' then error('profile before') end
   local value=f(util.copy(h.profiles[k]));if value then h.profiles[k]=util.copy(value) end
   if h.profileFault=='after' then error('profile after') end
   return util.copy(value)
  end}
  for user=1,3 do
   local initial=Schema.new(user,h.now);initial.data.currencies.gold=100000;initial.data.statistics.goldCreated=100000;initial.data.inventory.stacks.iron_ore=100
   h.profiles['p:'..user]=initial
   local data=MakeData({Util=util,Content=content,Config=require('../src/server/Config/Runtime'),Schema=Schema,Protocol={},Commands={},Store=profileStore,AuditStore={Update=function(_,f) return f(nil) end},MarketEscrow=E,
    Now=function() return h.now end,Wait=function() end,Jitter=function() return 0 end,Log=function() end,OnCommitted=function() end})
   eq(data.Load(user,'server'..user),'OK');h.data[user]=data
   h.servers[user]=MakeMarket({Config=C,Util=util,Data=data,Escrow=E,Orders=O,Book=B,Epochs=B,MarketData=D,Store=store,ReadProfile=function(user) return util.copy(h.profiles["p:"..user]) end,Now=function() return h.now end,
    Changed=function(item,b) h.notifications+=1;if h.transientFault then error('cache lost') end;h.index[item]=util.copy(b) end})
  end
  function h.p(user) return h.data[user].Sessions[user].record.data end
  function h.create(user,p,id)
   h.serial+=1;return h.servers[user].Create(user,id or ('req'..h.serial),p,h.book().epoch)
  end
  function h.book() return h.books['b:iron_ore:1'] or B.new('iron_ore') end
  function h.recover(user) return h.servers[user].RecoverPlayer(user,'iron_ore') end
  function h.cancel(user,id) return h.servers[user].Cancel(user,'iron_ore',id) end
  function h.check()
   local b=h.book();B.invariants(b)
   local gold,items=b.burnedFees+b.archive.fees,0
   for user=1,3 do
    local p=h.p(user);eq(Schema.validate(h.data[user].Sessions[user].record,user),true)
    gold+=p.currencies.gold;items+=p.inventory.stacks.iron_ore or 0
    for id,t in pairs(p.market.transfers) do
     local receipt=b.receipts[id]
     if t.state=='PREPARED' and (not receipt or receipt.state~='ACCEPTED') then
      if t.payload.side=='BUY' then gold+=t.payload.price*t.payload.quantity else items+=t.payload.quantity end
     end
    end
   end
   for _,o in pairs(b.orders) do if o.side=='BUY' then gold+=o.escrow else items+=o.escrow end end
   for _,c in pairs(b.claims) do
    local watermark=h.p(c.owner).market.claims['iron_ore:1'] or 0
    if c.sequence>watermark then if c.asset=='Gold' then gold+=c.amount else items+=c.amount end end
   end
   eq(gold,300000);eq(items,300)
   local cohort={};for user=1,3 do cohort[user]=h.data[user].Sessions[user].record end
   local audited=require('../src/server/Systems/MarketReconciliation')(b,cohort,{gold=300000,items=300});eq(audited.violations,0)
  end
  function h.op(action,args) return h.servers[1].Operator(action,'iron_ore',args) end
  function h.roll()
   eq(h.op('CloseEpoch').code,'OK');for user=1,3 do eq(h.recover(user),'OK') end
   eq(h.op('Reconcile').code,'OK');eq(h.op('Archive').code,'OK');eq(h.op('StartEpoch').code,'OK')
   for user=1,3 do eq(h.recover(user),'OK') end;h.check()
  end
  return h
 end

 local function add(name,fn) test('hardening '..name,fn) end
 local function sold() local h=harness();eq(h.create(1,order('SELL',5,10),'sell'),'OK');return h end
 local function filled() local h=sold();eq(h.create(2,order('BUY',2,12,'MARKET'),'buy'),'OK');return h end
 add('numeric epoch starts at one and server controls identity',function() local h=harness();eq(h.book().epoch,1);eq(h.book().phase,'ACTIVE');eq(h.servers[1].Create(1,'bad',order('BUY'),999),'EpochExpired');h.check() end)
 add('v1 market migration preserves escrow and claims',function() local b=BaseBook(C,util,O,M).new('iron_ore');local p=order('SELL');b=BaseBook(C,util,O,M).apply(b,'iron_ore',{action='Prepare',id='x',owner=1,payload=p},1000);b=BaseBook(C,util,O,M).apply(b,'iron_ore',{action='Deposit',id='x',owner=1,payload=p},1000);local n=B.normalize(b,'iron_ore',1001);eq(n.orders,b.orders);eq(n.receipts,b.receipts);eq(n.schemaVersion,2);B.invariants(n) end)
 add('old v1 worker cannot overwrite migrated book',function() eq(pcall(function() BaseBook(C,util,O,M).apply(B.new('iron_ore'),'iron_ore',{action='Recover'},1000) end),false) end)
 add('closing rejects admission before profile debit',function() local h=sold();h.op('CloseEpoch');eq(h.create(2,order('BUY')),'EpochClosing');eq(h.p(2).currencies.gold,100000);h.check() end)
 add('close cancels all remaining orders preserving quantity',function() local h=filled();h.op('CloseEpoch');local o=h.book().orders['1:1:sell'];eq(o.state,'CANCELLED');eq(o.remaining,3);eq(o.filled,2);eq(o.escrow,0);h.check() end)
 add('closing returns item escrow exactly once',function() local h=sold();h.op('CloseEpoch');h.recover(1);h.op('CloseEpoch');h.recover(1);eq(h.p(1).inventory.stacks.iron_ore,100);h.check() end)
 add('closing returns Gold escrow exactly once',function() local h=harness();h.create(2,order('BUY',5,10));h.op('CloseEpoch');h.recover(2);h.recover(2);eq(h.p(2).currencies.gold,100000);h.check() end)
 add('offline claim blocks reconciliation without loss',function() local h=filled();h.op('CloseEpoch');eq(h.op('Reconcile').code,'RecoveryPending');h.check();h.recover(1);eq(h.op('Reconcile').code,'OK') end)
 add('archive prohibited before reconciliation',function() local h=filled();eq(h.op('Archive').code,'InvalidTransition');h.check() end)
 add('rollover archives and new generation accepts orders',function() local h=filled();h.roll();eq(h.book().epoch,2);eq(h.book().archive.fees,1);eq(h.create(1,order('SELL',1,20)),'OK');h.check() end)
 add('stale order replay after archive rejected',function() local h=sold();h.roll();eq(h.servers[1].Create(1,'sell',order('SELL',5,10),1),'EpochExpired');h.check() end)
 add('late old deposit fenced even after receipt pruning',function() local h=sold();h.roll();local b,code=B.apply(h.book(),'iron_ore',{action='Deposit',epoch=1,id='1:1:sell',owner=1,payload=order('SELL',5,10)},1001);eq(code,'EpochExpired');eq(b,h.book()) end)
 add('profile compaction keeps fixed claim watermark',function() local h=filled();h.recover(1);local watermark=h.p(1).market.claims['iron_ore:1'];h.roll();eq(util.count(h.p(1).market.transfers),0);eq(h.p(1).market.claims['iron_ore:1']>=watermark,true);eq(h.p(1).market.floors.iron_ore,1);h.check() end)
 add('duplicate old claim after compaction creates no value',function() local h=filled();local claim;for _,x in pairs(h.book().claims) do if x.owner==2 and x.asset=='Item' then claim=util.copy(x) end end;h.roll();local before=h.p(2).inventory.stacks.iron_ore;eq(h.data[2].CommitMarket(2,'Claim',{itemId='iron_ore',claim=claim}),'OK');eq(h.p(2).inventory.stacks.iron_ore,before);h.check() end)
 add('old reservation after profile compaction fenced',function() local h=sold();h.roll();eq(h.data[1].CommitMarket(1,'Reserve',{id='late',epoch=1,payload=order('SELL')}),'EpochExpired');h.check() end)
 add('unconfirmed accepted source prevents archival',function() local h=sold();h.books['b:iron_ore:1'].receipts['1:1:sell'].sourceConfirmed=nil;h.op('CloseEpoch');eq(h.op('Reconcile').code,'RecoveryPending');h.recover(1);eq(h.op('Reconcile').code,'OK') end)
 add('stale rollover command cannot close new generation',function() local h=sold();h.roll();local b,code=B.apply(h.book(),'iron_ore',{action='CloseEpoch',epoch=1},1001);eq(code,'EpochExpired');eq(b.phase,'ACTIVE') end)
 add('replay safety window before archival',function() local cc=util.copy(C);cc.ReplaySeconds=300;local e=require('../src/server/Systems/MarketEpochs')(cc,util,O,M,BaseBook,D);local b=e.apply(nil,'iron_ore',{action='CloseEpoch',epoch=1},1000);b=e.apply(b,'iron_ore',{action='Reconcile',epoch=1},1000);local n,code=e.apply(b,'iron_ore',{action='Archive',epoch=1},1100);eq(code,'ReplayWindow');n,code=e.apply(n,'iron_ore',{action='Archive',epoch=1},1300);eq(code,'OK') end)
 add('30 day candles cross epoch boundary without raw replay',function() local h=filled();h.roll();eq(#h.book().trades,0);local v=h.servers[1].Read(1,'iron_ore','30D');eq(v.candles[1].volume,2);h.create(3,order('SELL',1,20));h.create(2,order('BUY',1,20));v=h.servers[1].Read(1,'iron_ore','30D');eq(v.candles[1].volume,3);eq(v.candles[1].high,20);h.check() end)
 add('all five candle windows rebuild after pruning',function() local h=filled();h.roll();for _,period in ipairs({'1H','6H','1D','7D','30D'}) do eq(h.servers[1].Read(1,'iron_ore',period).candles[1].volume,2) end end)
 add('archive does not double-count before StartEpoch',function() local h=filled();h.op('CloseEpoch');h.recover(1);h.op('Reconcile');h.op('Archive');eq(h.servers[1].Read(1,'iron_ore','1D').candles[1].volume,2) end)
 add('thin reference fallback after boundary is explicit',function() local h=filled();h.roll();eq(h.servers[1].Read(1,'iron_ore','1D').reference.source,'Design guide') end)
 add('archive old candles expire without deleting pending claims',function() local h=filled();h.roll();local v=B.project(h.book(),1,h.now+31*86400,'30D');eq(#v.candles,0);h.check() end)
 add('per player order cap',function() local h=harness();for i=1,C.OpenOrders do eq(h.create(1,order('SELL',1,100+i)),'OK') end;eq(h.create(1,order('SELL',1,999)),'OpenOrderLimit');h.check() end)
 add('per item and partitioned global cap includes admission tickets',function() local b=B.new('iron_ore');for i=1,C.MaxActivePerItem do local code;b,code=B.apply(b,'iron_ore',{action='Prepare',id=tostring(i),owner=i,payload=order('SELL'),epoch=1},1000);eq(code,'CREATED') end;local _,code=B.apply(b,'iron_ore',{action='Prepare',id='overflow',owner=100,payload=order('SELL'),epoch=1},1000);eq(code,'MarketCapacity');eq(C.MaxActivePerItem*C.MaxActiveItems<=C.MaxActiveGlobal,true) end)
 add('hot item capacity does not block another item',function() local b=B.new('timber');local p=order('SELL');p.itemId='timber';local _,code=B.apply(b,'timber',{action='Prepare',id='other',owner=1,payload=p,epoch=1},1000);eq(code,'CREATED') end)
 add('concurrent callback replays allocate unique sequence',function() local h=harness();h.replay=true;h.create(1,order('SELL',1,10));h.create(3,order('SELL',1,10));eq(h.book().sequence,2);h.create(2,order('BUY',2,10));eq(h.book().trades[1].seller,1);eq(h.book().trades[2].seller,3);h.check() end)
 add('two workers race same remaining fill',function() local h=sold();h.interleave=function() h.create(3,order('BUY',5,10,'MARKET')) end;h.create(2,order('BUY',5,10,'MARKET'));eq(h.book().orders['1:1:sell'].filled,5);h.check() end)
 add('cancellation races fill under epoch fence',function() local h=sold();h.interleave=function() h.create(2,order('BUY',2,10)) end;h.cancel(1,'1:1:sell');eq(h.book().orders['1:1:sell'].filled,2);h.check() end)
 for _,fault in ipairs({'before','after'}) do add('durable '..fault..' fault recovers without duplicates',function() local h=sold();h.fault=fault;pcall(h.create,2,order('BUY',2,10),'fault');h.fault=nil;h.create(2,order('BUY',2,10),'fault');h.recover(1);h.check() end) end
 add('MemoryStore total loss and dropped duplicated messages harmless',function() local h=filled();h.transientFault=true;h.cancel(1,'1:1:sell');h.index={};h.recover(1);h.transientFault=false;h.servers[2].RecoverBook('iron_ore');h.servers[3].RecoverBook('iron_ore');eq(h.index.iron_ore.orders,h.book().orders);h.check() end)
 add('recovery worker crash restart and duplicate run',function() local h=filled();h.fault='after';pcall(h.recover,1);h.fault=nil;h.recover(1);h.recover(1);h.check() end)
 add('pending claim age and backlog metrics',function() local h=filled();local v=B.metrics(h.book(),1100);eq(v.pendingClaims>0,true);eq(v.oldestPendingRecovery,100) end)
 add('audit Gold corruption fails loudly',function() local h=filled();h.books['b:iron_ore:1'].burnedFees+=1;eq(pcall(h.op,'AuditEpoch'),false) end)
 add('audit item escrow corruption fails loudly',function() local h=sold();h.books['b:iron_ore:1'].orders['1:1:sell'].escrow+=1;eq(pcall(h.op,'AuditEpoch'),false) end)
 add('audit claim corruption fails loudly',function() local h=filled();for _,x in pairs(h.books['b:iron_ore:1'].claims) do x.amount+=1;break end;eq(pcall(h.op,'AuditEpoch'),false) end)
 add('audit conservation and fees succeed',function() local h=filled();eq(h.op('AuditEpoch').violations,0);h.check() end)
 add('READ_ONLY rejects creates but allows cancellation settlement',function() local h=filled();h.op('SetMode',{mode='READ_ONLY'});eq(h.create(3,order('BUY')),'MarketReadOnly');eq(h.cancel(1,'1:1:sell'),'OK');eq(h.servers[1].Read(1,'iron_ore','1D').health,'READ_ONLY');h.check() end)
 add('PAUSED rejects mutation retains readable data',function() local h=filled();h.op('SetMode',{mode='PAUSED'});eq(h.create(3,order('BUY')),'MarketPaused');eq(h.recover(1),'MarketPaused');eq(h.cancel(1,'1:1:sell'),'MarketPaused');eq(h.servers[1].Read(1,'iron_ore','1D').health,'PAUSED');h.op('SetMode',{mode='HEALTHY'});h.recover(1);h.check() end)
 add('market pause does not lock normal profile service',function() local h=sold();h.op('SetMode',{mode='PAUSED'});eq(h.data[1].Sessions[1].state,'Active');eq(h.data[1].Sessions[1].busy,false);eq(Schema.validate(h.data[1].Sessions[1].record,1),true) end)
 add('circuit breaker threshold bounded cooldown',function() local now=0;local h=require('../src/server/Systems/MarketHealth')(C,function() return now end);for i=1,C.FailureThreshold do h.failed('throttle') end;eq(h.allow(),false);eq(h.allow(true),true);now=C.BreakerSeconds;eq(h.allow(),true);h.success();eq(h.state,'HEALTHY') end)
 add('profile save budgets protected before market maintenance',function() local h=require('../src/server/Systems/MarketHealth')(C,function() return 0 end);eq(h.budget(20,20),false);eq(h.budget(25,25,true),false);eq(h.budget(100,100,true),true);eq(h.throttles,2) end)
 add('namespace public disable staging prod separation',function() local n=require('../src/server/Systems/MarketNamespace');eq(n('prod',true,false,C),nil);eq(n('staging',true,false,C),'staging');eq(n('staging',false,false,C),nil);eq(n('staging',false,true,C),'staging');eq(n('unknown',false,true,C),nil) end)
 add('operator commands absent from client protocol',function() local p=require('../src/server/Systems/MarketProtocol')(C,O);for _,action in ipairs({'CloseEpoch','SetMode','Archive','AuditEpoch','StartEpoch'}) do eq(p.valid({requestId='x',action=action,itemId='iron_ore'}),false) end end)
 add('operator unknown commands fail',function() local h=harness();eq(pcall(h.op,'GiveGold'),false) end)
 add('index rebuild read-only operator preserves balances',function() local h=filled();h.index={};h.op('RebuildIndex');eq(h.index.iron_ore.orders,h.book().orders);h.check() end)
 add('recovery assist has no mint capability',function() local h=filled();h.op('RecoveryAssist');h.check() end)

 add('invariant mismatch latches circuit PAUSED without auto restart',function() local now=0;local h=require('../src/server/Systems/MarketHealth')(C,function() return now end);h.failed('MarketInvariant: GoldReconciliation');now=99999;eq(h.allow(),false);eq(h.state,'PAUSED');eq(h.allow(true),true) end)
 add('24 hour aggregates survive epoch rollover',function() local h=filled();h.roll();local v=h.servers[1].Read(1,'iron_ore','30D');eq(v.volume,2);eq(v.high,10);eq(v.low,10) end)
 add('archived reference snapshot expires to explicit guide',function() local h=filled();h.roll();local b=h.book();b.archive.reference={source='Market reference',value=12,samples=20};b.archive.referenceAt=h.now;eq(B.project(b,1,h.now,'1D').reference.source,'Archived market reference');eq(B.project(b,1,h.now+C.Reference.Window+1,'1D').reference.source,'Design guide') end)
 add('schema v6 stays v6 with bounded floor extension',function() local h=filled();h.roll();eq(h.data[1].Sessions[1].record.schemaVersion,6);eq(Schema.validate(h.data[1].Sessions[1].record,1),true) end)

 for _,side in ipairs({'SELL','BUY'}) do add('crash after '..side..' profile reserve resumes through session refresh',function() local h=harness();h.profileFault='after';eq(h.create(1,order(side),'crash'),'SavePending');h.profileFault=nil;eq(h.data[1].Refresh(1),'OK');h.recover(1);h.check() end) end
 add('claim credit committed before acknowledgment resumes once',function() local h=filled();h.profileFault='after';eq(h.recover(1),'SavePending');h.profileFault=nil;eq(h.data[1].Refresh(1),'OK');h.recover(1);h.recover(1);eq(h.p(1).currencies.gold,100019);h.check() end)
 add('session departure forbids claim on foreign owner',function() local h=filled();h.data[1].Sessions[1].closing=true;eq(pcall(h.recover,1),false);h.data[1].Sessions[1].closing=false;h.recover(1);h.check() end)
 add('close during uncertain prepared reserve compensates exactly once',function() local h=harness();h.profileFault='after';h.create(1,order('SELL'),'crash');h.profileFault=nil;h.op('CloseEpoch');eq(h.data[1].Refresh(1),'OK');h.recover(1);h.recover(1);eq(h.p(1).inventory.stacks.iron_ore,100);h.check() end)
 add('automatic recovery advances closed epoch without leases',function() local h=sold();h.op('CloseEpoch');h.recover(1);for _=1,3 do h.servers[1].RecoverBook('iron_ore') end;eq(h.book().epoch,2);h.recover(1);h.check() end)
 add('private acceptance names isolate both profile and market roots',function() local n=require('../src/server/Systems/MarketAcceptanceConfig');eq(n({Enabled=false},'staging',true,false),nil);eq(n({Enabled=true,RunId='test1',UserIds={[123]=true}},'staging',false,true),'qa45_test1');eq(pcall(n,{Enabled=true,RunId='test1',UserIds={[123]=true}},'prod',false,true),false);eq(pcall(n,{Enabled=true,RunId='test1',UserIds={[123]=true}},'staging',false,false),false) end)
 add('throttled response unblocks UI without reflecting oversized identity',function() local p=require('../src/server/Systems/MarketProtocol')(C,O);eq(p.busyResponse({requestId='safe-id'}),{code='MarketBusy',requestId='safe-id'});eq(p.busyResponse({requestId=string.rep('x',10000)}),{code='MarketBusy'});eq(p.busyResponse(42),{code='MarketBusy'}) end)
 add('5000 order sustained deterministic multi-epoch load conserves every step',function()
  local h=harness();local started=os.clock();local elapsed={};local epochs=0
  for i=1,2500 do
   local t=os.clock();local seller=if i%2==1 then 1 else 2;local buyer=if seller==1 then 2 else 1
   eq(h.create(seller,order('SELL',1,10),'s'..i),'OK');eq(h.create(buyer,order('BUY',1,10,'MARKET'),'b'..i),'OK')
   h.recover(seller);for user=1,3 do h.data[user].FlushAudit(user) end;h.check();table.insert(elapsed,(os.clock()-t)*1000)
   if i%40==0 then h.roll();epochs+=1;h.now+=1 end
  end
  h.roll();epochs+=1;h.check();eq(util.count(h.books),1);eq(#h.book().archive.epochs<=C.ArchiveEpochs,true);eq(util.count(h.p(1).market.transfers),0)
  table.sort(elapsed);local seconds=os.clock()-started
  print(string.format('PHASE45_LOAD orders=5000 cycles=2500 epochs=%d seconds=%.3f ordersPerSecond=%.2f pairP50Ms=%.3f pairP95Ms=%.3f pairMaxMs=%.3f invariantViolations=0 fixedKeys=%d',epochs,seconds,5000/seconds,elapsed[1250],elapsed[2375],elapsed[#elapsed],util.count(h.books)))
 end)
end
