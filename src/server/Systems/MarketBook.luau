--!strict
return function(config: any,util: any,orders: any,matching: any)
	local B={}
	function B.new(item: string): any
		assert(config.Items[item])
		return {schemaVersion=1,epoch=config.Epoch,itemId=item,revision=0,sequence=0,tradeSequence=0,
			orders={},receipts={},claims={},claimSequence=0,trades={},burnedFees=0,lastAt=0}
	end
	function B.apply(raw: any,item: string,command: any,now: number): (any,string)
		local b=util.copy(raw or B.new(item));assert(b.schemaVersion==1 and b.itemId==item and b.epoch==config.Epoch,"UnsupportedBook")
		now=math.max(now,b.lastAt)
		local code="OK"
		if command.action=="Prepare" then
			local old=b.receipts[command.id]
			if old then assert(old.owner==command.owner and util.equal(old.payload,command.payload),"RequestConflict");return b,old.state end
			assert(not orders.validate(command.payload) and command.payload.itemId==item,"InvalidDeposit")
			if not config.AdmissionEnabled or util.count(b.receipts)>=config.BookOrders then return b,"MarketCapacity" end
			b.receipts[command.id]={owner=command.owner,payload=util.copy(command.payload),state="CREATED"};code="CREATED"
		elseif command.action=="Deposit" then
			local p=command.payload;local existing=b.receipts[command.id]
			if existing then
				assert(existing.owner==command.owner and util.equal(existing.payload,p),"RequestConflict")
				if existing.state~="CREATED" then return b,existing.state end
			end
			assert(existing,"Missing admission ticket")
			assert(not orders.validate(p) and p.itemId==item,"InvalidDeposit")
			-- Every funded deposit gets a durable terminal admission decision, including refusal.
			local receipt={owner=command.owner,payload=util.copy(p),state="ACCEPTED"}
			b.receipts[command.id]=receipt
			if not config.AdmissionEnabled then receipt.state="ABORTED";code="ABORTED"
			else
				b.sequence+=1
				local o={id=command.id,owner=command.owner,itemId=item,side=p.side,kind=p.kind,price=p.price,
					original=p.quantity,remaining=p.quantity,filled=0,escrow=if p.side=="BUY" then p.quantity*p.price else p.quantity,
					sequence=b.sequence,createdAt=now,expiresAt=now+config.Lifetime,state="ACTIVE",gross=0,fee=0,feeBps=config.FeeBps}
				b.orders[o.id]=o
				for _,old in pairs(b.orders) do if old.expiresAt<=now then matching.cancel(b,old,now,"EXPIRED") end end
				matching.run(b,o,now);code="ACCEPTED"
			end
		elseif command.action=="Abort" then
			local old=b.receipts[command.id]
			assert(old and old.owner==command.owner and util.equal(old.payload,command.payload),"RequestConflict")
			if old.state~="CREATED" then return b,old.state end
			old.state="ABORTED";code="ABORTED"
		elseif command.action=="Cancel" then
			local o=b.orders[command.id]
			if not o or o.owner~=command.owner then return b,"NotYourOrder" end
			matching.cancel(b,o,now,"CANCELLED")
		elseif command.action=="Ack" then
			local c=b.claims[command.id]
			assert(c and c.owner==command.owner,"InvalidClaim")
			c.state="CLAIMED";c.claimedAt=c.claimedAt or now
		elseif command.action=="Recover" then
			for _,o in pairs(b.orders) do if o.expiresAt<=now then matching.cancel(b,o,now,"EXPIRED") end end
		else error("InvalidTransition") end
		b.revision+=1;b.lastAt=now
		return b,code
	end
	function B.invariants(b: any)
		local fees=0
		for _,t in ipairs(b.trades) do
			assert(t.buyer~=t.seller and t.gross==t.price*t.quantity and t.net+t.fee==t.gross)
			fees+=t.fee
		end
		assert(fees==b.burnedFees)
		for _,o in pairs(b.orders) do
			assert(o.original==o.remaining+o.filled and o.remaining>=0 and o.filled>=0)
			assert(o.escrow==(if orders.active(o) then (if o.side=="BUY" then o.remaining*o.price else o.remaining) else 0))
			if o.side=="SELL" then assert(o.fee==math.ceil(o.gross*o.feeBps/10000)) end
		end
	end
	return B
end
