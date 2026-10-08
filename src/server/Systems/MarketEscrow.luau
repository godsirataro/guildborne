--!strict
-- Only invoked through PlayerDataService's authoritative profile commit.
return function(config: any,util: any,content: any,orders: any)
	local E={}
	function E.new(): any return {transfers={},claims={},goldIn=0,goldOut=0} end
	function E.apply(record: any,action: string,p: any): (any,any,any)
		local r=util.copy(record);local d=r.data;local m=d.market
		local function fail(code: string): (any,any,any) return nil,{code=code},{} end
		if not m then return fail("MarketUnavailable") end
		if action=="Reserve" then
			local gate=content.NoviceActionProblem(d,"MarketReserve");if gate then return fail(gate) end
			if p.epoch and p.epoch<=((m.floors or {})[p.payload.itemId] or 0) then return fail("EpochExpired") end
			local code=orders.validate(p.payload);if code then return fail(code) end
			local old=m.transfers[p.id]
			if old then
				if not util.equal(old.payload,p.payload) then return fail("RequestConflict") end
				return r,{code="OK"},{}
			end
			if util.count(m.transfers)>=config.ProfileTransfers then return fail("MarketCapacity") end
			local active=0;for _,t in pairs(m.transfers) do if t.state~="CLOSED" and t.state~="REFUNDED" then active+=1 end end
			if active>=config.OpenOrders then return fail("OpenOrderLimit") end
			local o=p.payload;local amount=if o.side=="BUY" then o.price*o.quantity else o.quantity
			if o.side=="BUY" then
				if d.currencies.gold<amount then return fail("InsufficientGold") end
				d.currencies.gold-=amount;m.goldOut+=amount
			else
				if (d.inventory.stacks[o.itemId] or 0)<amount then return fail("ItemNotOwned") end
				local left=d.inventory.stacks[o.itemId]-amount;d.inventory.stacks[o.itemId]=if left>0 then left else nil
			end
			m.transfers[p.id]={payload=util.copy(o),state="PREPARED",epoch=p.epoch}
		elseif action=="Outcome" then
			local t=m.transfers[p.id];if not t then return fail("InvalidTransition") end
			if p.outcome=="ABORTED" then
				if t.state=="REFUNDED" then return r,{code="OK"},{} end
				if t.state~="PREPARED" then return fail("InvalidTransition") end
				local o=t.payload;local amount=if o.side=="BUY" then o.price*o.quantity else o.quantity
				if o.side=="BUY" then
					if d.currencies.gold+amount>content.Limits.Gold then return fail("WalletFull") end
					d.currencies.gold+=amount;m.goldIn+=amount
				else
					if (d.inventory.stacks[o.itemId] or 0)+amount>content.Limits.Stack then return fail("InventoryFull") end
					d.inventory.stacks[o.itemId]=(d.inventory.stacks[o.itemId] or 0)+amount
				end
				t.state="REFUNDED"
			elseif p.outcome=="ACCEPTED" then
				if t.state=="PREPARED" then t.state="EXPORTED" end
				if p.closed and t.state=="EXPORTED" then t.state="CLOSED" end
			else return fail("InvalidTransition") end
		elseif action=="Claim" then
			local c=p.claim;local id=p.itemId..":"..config.Epoch
			if c.owner~=d.profile.userId or (c.asset~="Gold" and c.asset~="Item") or not util.integer(c.amount,1,config.MaxOrderValue) then return fail("InvalidClaim") end
			if not util.integer(c.sequence,1,1000000000) then return fail("InvalidClaim") end
			if (m.claims[id] or 0)>=c.sequence then return r,{code="OK"},{} end
			if c.asset=="Gold" then
				if d.currencies.gold+c.amount>content.Limits.Gold then return fail("WalletFull") end
				d.currencies.gold+=c.amount;m.goldIn+=c.amount
			else
				if not config.Items[p.itemId] then return fail("NonTradable") end
				local amount=(d.inventory.stacks[p.itemId] or 0)+c.amount
				if amount>content.Limits.Stack then return fail("InventoryFull") end
				d.inventory.stacks[p.itemId]=amount
			end
			m.claims[id]=c.sequence
		elseif action=="Compact" then
			if not config.Items[p.itemId] or not util.integer(p.through,0,1000000000) then return fail("InvalidTransition") end
			for id,t in pairs(m.transfers) do
				if t.payload.itemId==p.itemId and (t.epoch or 1)<=p.through then
					if t.state=="PREPARED" then return fail("RecoveryPending") end
					m.transfers[id]=nil
				end
			end
			m.floors=m.floors or {};m.floors[p.itemId]=math.max(m.floors[p.itemId] or 0,p.through)
		else return fail("InvalidTransition") end
		return r,{code="OK"},{{name="market_transfer",payload={stage=action}}}
	end
	function E.validate(m: any)
		assert(type(m)=="table" and util.count(m.transfers)<=config.ProfileTransfers and util.count(m.claims)<=config.ProfileClaims)
		assert(util.integer(m.goldIn,0,9007199254740991) and util.integer(m.goldOut,0,9007199254740991))
		for id,t in pairs(m.transfers) do
			assert(type(id)=="string" and #id<=100 and not orders.validate(t.payload))
			assert(t.state=="PREPARED" or t.state=="EXPORTED" or t.state=="CLOSED" or t.state=="REFUNDED")
		end
		for id,v in pairs(m.claims) do assert(type(id)=="string" and #id<=150 and util.integer(v,1,1000000000)) end
		for id,v in pairs(m.floors or {}) do assert(config.Items[id] and util.integer(v,0,1000000000)) end
	end
	return E
end
