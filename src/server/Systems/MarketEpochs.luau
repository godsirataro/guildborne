--!strict
-- Fixed per-item authority key. Generation fences survive all receipt compaction.
return function(c: any,u: any,orders: any,matching: any,makeBook: any,data: any)
	local E: any={}
	local periods={['1H']={60,3600},['6H']={300,21600},['1D']={900,86400},['7D']={3600,604800},['30D']={14400,2592000}}
	local function base(epoch: number): any local cfg=u.copy(c);cfg.Epoch=epoch;return makeBook(cfg,u,orders,matching) end
	function E.normalize(raw: any,item: string,now: number): any
		local b=u.copy(raw or base(1).new(item))
		assert(b.schemaVersion==1 or b.schemaVersion==2,'UnsupportedBook')
		if b.schemaVersion==1 then
			b.schemaVersion=2;b.phase='ACTIVE';b.mode='HEALTHY';b.openedAt=now;b.archivedThrough=0
			b.archive={candles={},epochs={},fees=0,trades=0,volume=0,gross=0};b.archivedClaimSequence=0
		end
		return b
	end
	function E.new(item: string): any return E.normalize(nil,item,0) end
	function E.invariants(b: any)
		base(b.epoch).invariants(b)
		assert(b.schemaVersion==2 and b.epoch>b.archivedThrough and b.archivedThrough>=0)
		assert(b.phase=='ACTIVE' or b.phase=='CLOSING' or b.phase=='RECONCILED' or b.phase=='ARCHIVED')
		assert(b.mode=='HEALTHY' or b.mode=='DEGRADED' or b.mode=='READ_ONLY' or b.mode=='PAUSED')
		local ids={};local seq={};local pendingGold,pendingItems=0,0
		for id,t in pairs(b.receipts) do assert(t.state=='CREATED' or t.state=='ACCEPTED' or t.state=='ABORTED');if t.state=='ACCEPTED' then assert(b.orders[id]) end end
		for id,o in pairs(b.orders) do assert(b.receipts[id] and b.receipts[id].state=='ACCEPTED');assert(not seq[o.sequence]);seq[o.sequence]=true end
		for id,claim in pairs(b.claims) do
			assert(id==claim.id and not ids[claim.sequence] and claim.sequence>b.archivedClaimSequence and claim.sequence<=b.claimSequence)
			assert(claim.amount>0 and claim.amount%1==0 and (claim.state=='PENDING' or claim.state=='CLAIMED'));ids[claim.sequence]=true
			if claim.state=='PENDING' then if claim.asset=='Gold' then pendingGold+=claim.amount else pendingItems+=claim.amount end end
		end
		-- Closed-world book ownership accounting, independent of profile acknowledgment lag.
		local goldIn,itemIn,goldOut,itemOut=b.burnedFees,0,0,0
		for _,o in pairs(b.orders) do if o.side=='BUY' then goldOut+=o.original*o.price;goldIn+=o.escrow else itemOut+=o.original;itemIn+=o.escrow end end
		for _,claim in pairs(b.claims) do if claim.asset=='Gold' then goldIn+=claim.amount else itemIn+=claim.amount end end
		assert(goldIn==goldOut,'GoldReconciliation');assert(itemIn==itemOut,'ItemReconciliation')
		return {goldEscrow=goldOut-b.burnedFees-(function() local n=0;for _,x in pairs(b.claims) do if x.asset=='Gold' then n+=x.amount end end;return n end)(),pendingGold=pendingGold,pendingItems=pendingItems,violations=0}
	end
	function E.metrics(b: any,now: number): any
		local active,pending,recovery,oldest=0,0,0,now
		for _,o in pairs(b.orders) do if orders.active(o) then active+=1 end end
		for _,x in pairs(b.claims) do if x.state=='PENDING' then pending+=1;oldest=math.min(oldest,x.createdAt) end end
		for _,x in pairs(b.receipts) do if x.state=='CREATED' or (x.state=='ACCEPTED' and not x.sourceConfirmed) then recovery+=1 end end
		return {currentEpoch=b.epoch,epochAge=math.max(0,now-b.openedAt),phase=b.phase,mode=b.mode,activeOrders=active,pendingClaims=pending,pendingRecovery=recovery,oldestPendingRecovery=if pending>0 then now-oldest else 0,archivedThrough=b.archivedThrough}
	end
	function E.apply(raw: any,item: string,cmd: any,now: number): (any,string)
		local b=E.normalize(raw,item,now);E.invariants(b);now=math.max(now,b.lastAt)
		local action=cmd.action;local epoch=cmd.epoch or 1
		if ({CloseEpoch=true,Reconcile=true,Archive=true,StartEpoch=true})[action] and epoch~=b.epoch then return b,'EpochExpired' end
		if action=='SetMode' then assert(({HEALTHY=true,DEGRADED=true,READ_ONLY=true,PAUSED=true})[cmd.mode]);b.mode=cmd.mode
		elseif b.mode=='PAUSED' then return b,'MarketPaused'
		elseif action=='CloseEpoch' then
			if epoch~=b.epoch then return b,'EpochExpired' end
			if b.phase=='ACTIVE' then
				b.phase='CLOSING';b.closedAt=now
				for _,o in pairs(b.orders) do matching.cancel(b,o,now,'CANCELLED') end
				for _,r in pairs(b.receipts) do if r.state=='CREATED' then r.state='ABORTED' end end
			end
		elseif action=='Reconcile' then
			if b.phase~='CLOSING' then return b,'InvalidTransition' end
			for _,r in pairs(b.receipts) do if r.state=='ACCEPTED' and not r.sourceConfirmed then return b,'RecoveryPending' end end
			for _,x in pairs(b.claims) do if x.state~='CLAIMED' then return b,'RecoveryPending' end end
			b.phase='RECONCILED'
		elseif action=='Archive' then
			if b.phase~='RECONCILED' then return b,'InvalidTransition' end
			if now-b.closedAt<c.ReplaySeconds then return b,'ReplayWindow' end
			for period,window in pairs(periods) do
				local buckets={}
				for _,x in ipairs(b.archive.candles[period] or {}) do if x.at+window[1]>now-window[2] then buckets[x.at]=u.copy(x) end end
				for _,x in ipairs(data.candles(b.trades,now,period)) do local old=buckets[x.at];if old then old.high=math.max(old.high,x.high);old.low=math.min(old.low,x.low);old.close=x.close;old.volume+=x.volume;old.gross+=x.gross else buckets[x.at]=u.copy(x) end end
				local result={};for _,x in pairs(buckets) do table.insert(result,x) end;table.sort(result,function(a: any,z: any) return a.at<z.at end);b.archive.candles[period]=result
			end
			local volume,gross=0,0;for _,t in ipairs(b.trades) do volume+=t.quantity;gross+=t.gross end
			table.insert(b.archive.epochs,{epoch=b.epoch,closedAt=b.closedAt,archivedAt=now,trades=#b.trades,fees=b.burnedFees,volume=volume,gross=gross})
			while #b.archive.epochs>c.ArchiveEpochs do table.remove(b.archive.epochs,1) end
			b.archive.fees+=b.burnedFees;b.archive.trades+=#b.trades;b.archive.volume+=volume;b.archive.gross+=gross
			local last=b.trades[#b.trades];if last then b.archive.lastPrice=last.price end
			local reference=data.reference(b.trades,now,item)
			if reference.source=='Market reference' then b.archive.reference=reference;b.archive.referenceAt=now end
			b.phase='ARCHIVED'
		elseif action=='StartEpoch' then
			if b.phase~='ARCHIVED' then return b,'InvalidTransition' end
			b.archivedThrough=b.epoch;b.epoch+=1;b.archivedClaimSequence=b.claimSequence
			b.orders={};b.receipts={};b.claims={};b.trades={};b.burnedFees=0;b.phase='ACTIVE';b.openedAt=now;b.closedAt=nil
		elseif epoch~=b.epoch then return b,if epoch<=b.archivedThrough then 'EpochExpired' else 'EpochMismatch'
		elseif action=='ConfirmSource' then
			local r=b.receipts[cmd.id];assert(r and r.owner==cmd.owner and r.state=='ACCEPTED','InvalidSource');r.sourceConfirmed=true
		else
			if action=='Prepare' then
				if b.phase~='ACTIVE' then return b,'EpochClosing' end
				if b.mode=='READ_ONLY' then return b,'MarketReadOnly' end
				if E.metrics(b,now).pendingClaims>=c.MaxPendingClaims then b.mode='READ_ONLY';b.revision+=1;return b,'MarketReadOnly' end
				local active=0;for _,o in pairs(b.orders) do if orders.active(o) then active+=1 end end
				local reserved=0;for _,r in pairs(b.receipts) do if r.state=='CREATED' then reserved+=1 end end
				local cap=math.min(c.MaxActivePerItem,math.floor(c.MaxActiveGlobal/c.MaxActiveItems))
				if not b.receipts[cmd.id] and (active+reserved>=cap or #b.trades>=c.RawTradeLimit) then return b,'MarketCapacity' end
			end
			if action=='Deposit' and b.phase~='ACTIVE' then local r=b.receipts[cmd.id];return b,if r and r.state=='ACCEPTED' then 'ACCEPTED' else 'ABORTED' end
			if action=='Deposit' and b.mode=='READ_ONLY' and b.receipts[cmd.id] and b.receipts[cmd.id].state=='CREATED' then b.receipts[cmd.id].state='ABORTED';b.revision+=1;return b,'ABORTED' end
			if action=='Cancel' and b.phase~='ACTIVE' then return b,'OK' end
			local legacy=u.copy(b);legacy.schemaVersion=1
			local nextBook,code=base(b.epoch).apply(legacy,item,cmd,now);nextBook.schemaVersion=2;E.invariants(nextBook);return nextBook,code
		end
		b.revision+=1;b.lastAt=now;E.invariants(b);return b,'OK'
	end
	function E.project(b: any,user: number,now: number,period: string): any
		b=E.normalize(b,b.itemId,now);local view=data.project(b,user,now,period);view.epoch=b.epoch;view.health=b.mode;view.phase=b.phase
		local buckets={};local window=periods[period] or periods['1D']
		for _,x in ipairs(b.archive.candles[period] or {}) do if x.at+window[1]>now-window[2] then buckets[x.at]=u.copy(x) end end
		-- ARCHIVED still contains raw records; those have already been aggregated.
		if b.phase~='ARCHIVED' then for _,x in ipairs(view.candles) do local old=buckets[x.at];if old then old.high=math.max(old.high,x.high);old.low=math.min(old.low,x.low);old.close=x.close;old.volume+=x.volume;old.gross+=x.gross else buckets[x.at]=x end end end
		view.candles={};for _,x in pairs(buckets) do table.insert(view.candles,x) end;table.sort(view.candles,function(a: any,z: any) return a.at<z.at end)
		view.lastPrice=view.lastPrice or b.archive.lastPrice
		if view.reference.source=='Design guide' and b.archive.reference and now-b.archive.referenceAt<c.Reference.Window then view.reference=u.copy(b.archive.reference);view.reference.source='Archived market reference' end
		local daily=if period=='1D' then view.candles else E.project(b,user,now,'1D').candles
		view.volume=0;view.high=nil;view.low=nil
		for _,x in ipairs(daily) do view.volume+=x.volume;view.high=math.max(view.high or x.high,x.high);view.low=math.min(view.low or x.low,x.low) end
		return view
	end
	return E
end
