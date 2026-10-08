--!strict
return function(test: any,eq: any,util: any,content: any,legacySchema: any)
 local C=require('../src/server/Config/Market')
 local O=require('../src/server/Systems/MarketOrders')(C,util)
 local E=require('../src/server/Systems/MarketEscrow')(C,util,content,O)
 local M=require('../src/server/Systems/MarketMatching')(C,O)
 local B=require('../src/server/Systems/MarketBook')(C,util,O,M)
 local D=require('../src/server/Systems/MarketData')(C,util,O)
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
   h.servers[user]=MakeMarket({Config=C,Util=util,Data=data,Escrow=E,Orders=O,Book=B,MarketData=D,Store=store,ReadProfile=function(user) return util.copy(h.profiles["p:"..user]) end,Now=function() return h.now end,
    Changed=function(item,b) h.notifications+=1;if h.transientFault then error('cache lost') end;h.index[item]=util.copy(b) end})
  end
  function h.p(user) return h.data[user].Sessions[user].record.data end
  function h.create(user,p,id)
   h.serial+=1;return h.servers[user].Create(user,id or ('req'..h.serial),p)
  end
  function h.book() return h.books['b:iron_ore:1'] or B.new('iron_ore') end
  function h.recover(user) return h.servers[user].RecoverPlayer(user,'iron_ore') end
  function h.cancel(user,id) return h.servers[user].Cancel(user,'iron_ore',id) end
  function h.check()
   local b=h.book();B.invariants(b)
   local gold,items=b.burnedFees,0
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
  end
  return h
 end
 test('market valid sell reserves owned material immediately',function() local h=harness();eq(h.create(1,order('SELL')),'OK');eq(h.p(1).inventory.stacks.iron_ore,90);eq(h.book().orders['1:req1'].escrow,10);h.check() end)
 test('market valid buy reserves spendable Gold',function() local h=harness();eq(h.create(2,order('BUY')),'OK');eq(h.p(2).currencies.gold,99000);h.check() end)
 test('market unowned quantities reject before ticket',function() local h=harness();eq(h.create(1,order('SELL',101)),'ItemNotOwned');eq(util.count(h.book().receipts),0);h.check() end)
 test('market insufficient Gold rejects before ticket',function() local h=harness();eq(h.create(1,order('BUY',1000,1000)),'InsufficientGold');h.check() end)
 for _,price in ipairs({0,-1,.5,math.huge,-math.huge,0/0,100001}) do test('market rejects invalid price '..tostring(price),function() local h=harness();eq(h.create(1,order('BUY',1,price)),'InvalidPrice');h.check() end) end
 for _,q in ipairs({0,-1,.5,math.huge,0/0,1001}) do test('market rejects invalid quantity '..tostring(q),function() local h=harness();eq(h.create(1,order('SELL',q)),'InvalidQuantity');h.check() end) end
 test('market value ceiling before multiplication exceeds configured limit',function() local h=harness();eq(h.create(1,order('BUY',1000,100000)),'OrderValueLimit');h.check() end)
 test('market unknown item and all existing bound gear rejected',function() for id,def in pairs(content.Items) do eq(def.Tradable,C.Items[id]~=nil) end;for _,id in ipairs({'unknown','training_sword','leather_vest'}) do local p=order('SELL');p.itemId=id;eq(O.validate(p),'NonTradable') end end)
 test('market rejects equipped item identity and forged owner result',function() local p=order('SELL');p.instanceId='q:1:1';eq(O.validate(p),'InvalidRequest');p=order('BUY');p.owner=2;eq(O.validate(p),'InvalidRequest') end)
 test('market duplicate create is durable beyond response cache',function() local h=harness();h.create(1,order('SELL'),'same');h.create(1,order('SELL'),'same');eq(util.count(h.book().orders),1);eq(h.p(1).inventory.stacks.iron_ore,90);h.check() end)
 test('market reused create identity rejects changed payload',function() local h=harness();h.create(1,order('SELL'),'same');eq(h.create(1,order('SELL',9),'same'),'RequestConflict');h.check() end)
 test('market crossing maker price seller fee and buyer price improvement',function() local h=harness();h.create(1,order('SELL'));h.create(2,order('BUY',6,110));h.recover(1);local t=h.book().trades[1];eq(t.price,100);eq(t.gross,600);eq(t.fee,30);eq(h.p(1).currencies.gold,100570);eq(h.p(2).currencies.gold,99400);eq(h.p(2).inventory.stacks.iron_ore,106);h.check() end)
 test('market noncrossing orders remain active',function() local h=harness();h.create(1,order('SELL',10,101));h.create(2,order('BUY'));eq(#h.book().trades,0);h.check() end)
 test('market lowest ask first regardless of time',function() local h=harness();h.create(1,order('SELL',3,110));h.create(3,order('SELL',3,90));h.create(2,order('BUY',2,120));eq(h.book().trades[1].seller,3);h.check() end)
 test('market highest bid first regardless of time',function() local h=harness();h.create(1,order('BUY',3,90));h.create(3,order('BUY',3,110));h.create(2,order('SELL',2,80));eq(h.book().trades[1].buyer,3);h.check() end)
 test('market equal price uses durable acceptance sequence',function() local h=harness();h.create(1,order('SELL',3));h.create(3,order('SELL',3));h.create(2,order('BUY',4));eq(h.book().trades[1].seller,1);eq(h.book().trades[2].seller,3);h.check() end)
 test('market multiple partial fills conserve original remaining and filled',function() local h=harness();h.create(1,order('SELL'));h.create(2,order('BUY',3));h.create(3,order('BUY',4));local o=h.book().orders['1:req1'];eq(o.remaining,3);eq(o.filled,7);eq(o.state,'PARTIALLY_FILLED');h.check() end)
 test('market complete fill removes remaining escrow',function() local h=harness();h.create(1,order('SELL'));h.create(2,order('BUY'));eq(h.book().orders['1:req1'].state,'FILLED');h.recover(1);h.check() end)
 test('market fee is cumulative ceil not ceil per fill',function() local h=harness();h.create(1,order('SELL',20,1));h.create(2,order('BUY',1,1));h.create(3,order('BUY',19,1));eq(h.book().trades[1].fee,1);eq(h.book().trades[2].fee,0);eq(h.book().burnedFees,1);h.check() end)
 test('market 10000 Gold costs 500 fee',function() local h=harness();h.create(1,order('SELL',100,100));h.create(2,order('BUY',100,100));eq(h.book().burnedFees,500);h.check() end)
 test('market fee configuration zero and snapshot',function() local c=util.copy(C);c.FeeBps=0;local book=require('../src/server/Systems/MarketBook')(c,util,O,require('../src/server/Systems/MarketMatching')(c,O));local b=book.new('iron_ore');for i,side in ipairs({'SELL','BUY'}) do local p=order(side);b=book.apply(b,'iron_ore',{action='Prepare',id=tostring(i),owner=i,payload=p},1000);b=book.apply(b,'iron_ore',{action='Deposit',id=tostring(i),owner=i,payload=p},1000) end;eq(b.burnedFees,0) end)
 test('market cancellation returns once and never charges unfilled fee',function() local h=harness();h.create(1,order('SELL'));eq(h.cancel(1,'1:req1'),'OK');h.cancel(1,'1:req1');eq(h.p(1).inventory.stacks.iron_ore,100);eq(h.book().burnedFees,0);h.check() end)
 test('market partial cancellation returns only remaining items',function() local h=harness();h.create(1,order('SELL'));h.create(2,order('BUY',4));h.cancel(1,'1:req1');eq(h.p(1).inventory.stacks.iron_ore,96);eq(h.p(1).currencies.gold,100380);h.check() end)
 test('market Gold cancellation returns exact reserve',function() local h=harness();h.create(1,order('BUY'));h.cancel(1,'1:req1');eq(h.p(1).currencies.gold,100000);h.check() end)
 test('market foreign cancellation rejected',function() local h=harness();h.create(1,order('SELL'));eq(h.cancel(2,'1:req1'),'NotYourOrder');h.check() end)
 test('market self trade never creates volume or fees',function() local h=harness();h.create(1,order('SELL'));h.create(1,order('BUY'));eq(#h.book().trades,0);eq(h.book().burnedFees,0);h.check() end)
 test('market immediate buy unit guard prevents catastrophic fill',function() local h=harness();h.create(1,order('SELL',10,1000));h.create(2,order('BUY',10,100,'MARKET'));eq(#h.book().trades,0);eq(h.p(2).currencies.gold,100000);h.check() end)
 test('market immediate sell minimum guard and empty remainder refund',function() local h=harness();h.create(1,order('BUY',2,90));h.create(2,order('SELL',5,100,'MARKET'));eq(#h.book().trades,0);eq(h.p(2).inventory.stacks.iron_ore,100);h.check() end)
 test('market immediate partial fill cancels unmatched remainder',function() local h=harness();h.create(1,order('SELL',2));h.create(2,order('BUY',5,100,'MARKET'));eq(h.p(2).currencies.gold,99800);eq(h.book().orders['2:req2'].state,'CANCELLED');h.check() end)
 test('market open-order limit spans item reservations',function() local h=harness();for _=1,5 do eq(h.create(1,order('SELL',1)),'OK') end;eq(h.create(1,order('SELL',1)),'OpenOrderLimit');h.check() end)
 test('market cancelled order releases slot',function() local h=harness();for _=1,5 do h.create(1,order('SELL',1)) end;h.cancel(1,'1:req1');eq(h.create(1,order('SELL',1)),'OK');h.check() end)
 test('market missing stale duplicated cache and messages do not authorize fills',function() local h=harness();h.transientFault=true;h.create(1,order('SELL'));h.index={iron_ore={orders={fake={remaining=999999}}}};h.create(2,order('BUY'));h.transientFault=false;h.servers[3].RecoverBook('iron_ore');eq(h.index.iron_ore.orders['1:req1'].remaining,0);h.check() end)
 test('market three workers interleave CAS callback without overfill',function() local h=harness();h.create(1,order('SELL',5));h.replay=true;h.interleave=function() h.create(3,order('BUY',4)) end;h.create(2,order('BUY',4));local b=h.book();eq(b.orders['1:req1'].filled,5);eq(#b.trades,2);h.check() end)
 test('market callback rerun burns fee exactly once',function() local h=harness();h.replay=true;h.create(1,order('SELL'));h.create(2,order('BUY'));eq(h.book().burnedFees,50);h.check() end)
 test('market cancel racing fill preserves ownership',function() local h=harness();h.create(1,order('SELL'));h.interleave=function() h.create(2,order('BUY',4)) end;h.cancel(1,'1:req1');eq(h.p(1).inventory.stacks.iron_ore,96);h.check() end)
 test('market crash after admission before reserve never debits',function() local h=harness();h.fault='after';eq(pcall(h.create,1,order('SELL'),'crash'),false);h.fault=nil;eq(h.p(1).inventory.stacks.iron_ore,100);eq(h.create(1,order('SELL'),'crash'),'OK');h.check() end)
 test('market uncertain profile reservation recovers without double debit',function() local h=harness();h.profileFault='after';eq(h.create(1,order('SELL'),'crash'),'SavePending');h.profileFault=nil;eq(h.data[1].Refresh(1),'OK');eq(h.recover(1),'OK');h.check() end)
 test('market durable reservation survives market store outage',function() local h=harness();local original=h.data[1].CommitMarket;h.data[1].CommitMarket=function(user,action,p) local code=original(user,action,p);if action=='Reserve' then h.fault='before' end;return code end;eq(pcall(h.create,1,order('SELL')),false);h.fault=nil;h.recover(1);h.check() end)
 test('market crash after fill before settlement replay recovers',function() local h=harness();h.create(1,order('SELL'));local original=h.data[2].CommitMarket;h.data[2].CommitMarket=function(user,action,p) if action=='Claim' then error('crash before claim') end;return original(user,action,p) end;eq(pcall(h.create,2,order('BUY')),false);eq(h.book().orders['1:req1'].state,'FILLED');h.data[2].CommitMarket=original;h.recover(2);h.recover(1);h.check() end)
 test('market crash after claim profile commit before ack does not duplicate',function() local h=harness();h.create(1,order('SELL'));local original=h.data[2].CommitMarket;h.data[2].CommitMarket=function(user,action,p) local code=original(user,action,p);if action=='Claim' then error('crash after claim') end;return code end;eq(pcall(h.create,2,order('BUY')),false);h.data[2].CommitMarket=original;h.recover(2);h.recover(2);eq(h.p(2).inventory.stacks.iron_ore,110);h.check() end)
 test('market offline seller mailbox then online owner collection',function() local h=harness();h.create(1,order('SELL'));h.create(2,order('BUY'));eq(h.p(1).currencies.gold,100000);h.recover(1);eq(h.p(1).currencies.gold,100950);h.check() end)
 test('market duplicate claim after newer claim watermark harmless',function() local h=harness();h.create(1,order('SELL',2));h.create(2,order('BUY',1));h.create(3,order('BUY',1));h.recover(1);local before=util.copy(h.p(1));h.recover(1);eq(h.p(1),before);h.check() end)
 test('market full wallet leaves claim pending',function() local h=harness();h.create(1,order('SELL'));h.create(2,order('BUY'));local r=h.data[1].Sessions[1].record;r.data.currencies.gold=content.Limits.Gold;r.data.statistics.goldCreated=content.Limits.Gold;h.profiles['p:1']=util.copy(r);eq(h.recover(1),'WalletFull');eq(h.book().claims['t:1:seller'].state,'PENDING') end)
 test('market expiry without lease or notifications returns remaining reserve',function() local h=harness();h.create(1,order('BUY'));h.now+=C.Lifetime+1;h.servers[3].RecoverBook('iron_ore');eq(h.book().orders['1:req1'].state,'EXPIRED');h.data[1].Sessions[1].record.session.leaseExpiresAt=h.now+180;h.profiles['p:1'].session.leaseExpiresAt=h.now+180;h.recover(1);h.check() end)
 test('market tombstone excludes late deposit after abort',function() local b=B.new('iron_ore');local p=order('SELL');local command={id='1:x',owner=1,payload=p,action='Prepare'};b=B.apply(b,'iron_ore',command,1);command.action='Abort';b=B.apply(b,'iron_ore',command,2);command.action='Deposit';local code;b,code=B.apply(b,'iron_ore',command,3);eq(code,'ABORTED');eq(util.count(b.orders),0) end)
 test('market source refund cannot reverse accepted outcome',function() local h=harness();h.create(1,order('SELL'));local r,code=E.apply(h.data[1].Sessions[1].record,'Outcome',{id='1:req1',outcome='ABORTED'});eq(r,nil);eq(code.code,'InvalidTransition');h.check() end)
 test('market invalid state transition rejected',function() eq(pcall(B.apply,nil,'iron_ore',{action='Mint'},1),false) end)
 test('market retention capacity closes BEFORE reservation',function() local c=util.copy(C);c.BookOrders=1;local b=B.new('iron_ore');local book=require('../src/server/Systems/MarketBook')(c,util,O,M);b=book.apply(b,'iron_ore',{action='Prepare',id='1',owner=1,payload=order('BUY')},1);local code;b,code=book.apply(b,'iron_ore',{action='Prepare',id='2',owner=2,payload=order('SELL')},2);eq(code,'MarketCapacity');eq(util.count(b.receipts),1) end)
 test('market thin and empty book has absent prices and explicit guide',function() local v=D.project(B.new('iron_ore'),1,1000,'1D');eq(v.lastPrice,nil);eq(v.bestBid,nil);eq(v.bestAsk,nil);eq(v.spread,nil);eq(v.volume,0);eq(v.reference.source,'Design guide');eq(#v.candles,0) end)
 test('market reference rejects single extreme trade',function() local ref=D.reference({{at=999,buyer=1,seller=2,quantity=1,gross=99999,price=99999}},1000,'iron_ore');eq(ref.source,'Design guide');eq(ref.value,6) end)
 test('market robust reference ignores isolated extreme in diverse sample',function() local trades={};for i=1,25 do table.insert(trades,{at=10000-i*301,buyer=i%10+1,seller=i%10+20,quantity=2,gross=200,price=100}) end;table.insert(trades,{at=9999,buyer=100,seller=200,quantity=1000,gross=99999000,price=99999});local ref=D.reference(trades,10000,'iron_ore');eq(ref.source,'Market reference');eq(ref.value,100) end)
 test('market split wash pair cannot meet diversity reference threshold',function() local trades={};for i=1,30 do table.insert(trades,{at=i*301,buyer=1,seller=2,quantity=1,gross=100,price=100}) end;eq(D.reference(trades,10000,'iron_ore').source,'Design guide') end)
 test('market OHLC volume and five required periods',function() local trades={{at=990,price=100,quantity=2,gross=200},{at=995,price=120,quantity=3,gross=360},{at=999,price=90,quantity=1,gross=90}};for _,period in ipairs({'1H','6H','1D','7D','30D'}) do local c=D.candles(trades,1000,period);eq(#c,1);eq(c[1].open,100);eq(c[1].close,90);eq(c[1].high,120);eq(c[1].low,90);eq(c[1].volume,6);eq(c[1].gross,650) end end)
 test('market 24h high low volume ignore older trades',function() local b=B.new('iron_ore');b.trades={{id='a',at=1,price=999,quantity=1,gross=999,buyer=2,seller=3},{id='b',at=99999,price=100,quantity=2,gross=200,buyer=2,seller=3}};local v=D.project(b,1,100000,'1D');eq(v.high,100);eq(v.low,100);eq(v.volume,2);eq(v.lastPrice,100) end)
 test('market order book projection hides identities and foreign history',function() local h=harness();h.create(1,order('SELL'));h.create(2,order('BUY',1));local v=h.servers[3].Read(3,'iron_ore','1D');eq(#v.orders,0);eq(#v.history,0);eq(v.asks[1].owner,nil);eq(v.asks[1].id,nil) end)
 test('market v5 migration preserves every existing field and unlock',function() local old=legacySchema.new(1,1000);local original=util.copy(old);local migrated,code=Schema.migrate(old);eq(code,'OK');eq(migrated.schemaVersion,6);local compare=util.copy(migrated);compare.schemaVersion=5;compare.data.market=nil;eq(compare,original);eq(Schema.migrate(migrated),migrated);eq(Schema.validate(migrated,1),true) end)
 test('market migration rejects conflicting field instead of reset',function() local old=legacySchema.new(1,1000);old.data.market={goldIn=999};eq(Schema.migrate(old),nil) end)
 test('market transfers are not Gold faucets or sinks',function() local h=harness();h.create(1,order('SELL'));h.create(2,order('BUY'));h.recover(1);for i=1,3 do eq(h.p(i).statistics.goldCreated,100000);eq(h.p(i).statistics.goldDestroyed,0) end;h.check() end)
 test('market deterministic 90-operation adversarial sequence conserves assets',function() local h=harness();for n=1,90 do local user=n%3+1;local p=order(if n%2==0 then 'BUY' else 'SELL',n%4+1,95+n%11);h.create(user,p);if n%3==0 then for id,o in pairs(h.book().orders) do if o.owner==user and O.active(o) then h.cancel(user,id);break end end end;for i=1,3 do h.recover(i);h.data[i].FlushAudit(i) end;h.check() end end)
 test('market remote rate bucket is bounded and refills',function() local p=require('../src/server/Systems/MarketProtocol')(C,O);local b={tokens=4,at=0};for _=1,4 do eq(p.accept(b,0),true) end;eq(p.accept(b,0),false);eq(p.accept(b,1),false);eq(p.accept(b,2),true) end)
 test('market remote rejects forged identities and result fields',function() local p=require('../src/server/Systems/MarketProtocol')(C,O);eq(p.valid({requestId='abc',action='Read',itemId='iron_ore'}),true);eq(p.valid({requestId='abc',action='Read',itemId='iron_ore',userId=2}),false);eq(p.valid({requestId='abc',action='Mint',itemId='iron_ore'}),false) end)
 test('market offline reservation recovered by foreign worker without profile write',function() local h=harness();local original=h.data[1].CommitMarket;h.data[1].CommitMarket=function(user,action,p) local code=original(user,action,p);if action=='Reserve' then h.fault='before' end;return code end;eq(pcall(h.create,1,order('SELL')),false);h.fault=nil;local before=util.copy(h.profiles['p:1']);h.servers[3].RecoverBook('iron_ore');eq(h.book().orders['1:req1'].state,'ACTIVE');eq(h.profiles['p:1'],before);h.check() end)
 test('market Thai localization covers primary navigation and confirmations',function() local l=require('../src/shared/Config/Localization');for _,key in ipairs({'Browse','Search','My Orders','History','Buy now','Sell now','Confirm order','Maximum cost','Minimum proceeds if fully filled','No recent trade','MarketUnavailable','Advanced order'}) do assert(l.Thai[key] and l.Thai[key]~=key) end end)
end
