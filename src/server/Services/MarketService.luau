--!strict
-- Orchestration only. Pure transforms own accounting; adapters own I/O.
return function(deps: any)
	local S: any={};local config=deps.Config;local util=deps.Util
	local function readBook(item: string): any
		local raw=deps.Store.Read("b:"..item..":"..config.Epoch)
		return if deps.Epochs then deps.Epochs.normalize(raw,item,deps.Now()) else raw or deps.Book.new(item)
	end
	local function update(item: string,command: any): (any,string)
		local code="MarketUnavailable"
		local b=deps.Store.Update("b:"..item..":"..config.Epoch,function(raw: any)
			if raw then local valid,problem=pcall(deps.Book.invariants,if deps.Epochs then deps.Epochs.normalize(raw,item,deps.Now()) else raw);if not valid then error("MarketInvariant: "..tostring(problem)) end end
			local nextBook,outcome=deps.Book.apply(raw,item,command,deps.Now());code=outcome;deps.Book.invariants(nextBook);return nextBook
		end)
		if b then pcall(deps.Changed,item,b) end
		return b,code
	end
	local function profile(userId: number): any
		local s=deps.Data.Sessions[userId]
		assert(s and s.state=="Active" and not s.busy and not s.closing,"ProfileNotReady")
		return s.record
	end
	local function commit(userId: number,action: string,p: any): string
		return deps.Data.CommitMarket(userId,action,p)
	end
	function S.RecoverPlayer(userId: number,item: string): string
		local r=profile(userId)
		local current=readBook(item)
		if deps.Epochs and current.mode=="PAUSED" then return "MarketPaused" end
		-- Profile-owned journal is the discoverable durable source for unexported reserves.
		for id,t in pairs(r.data.market.transfers) do
			if t.payload.itemId==item and t.state=="PREPARED" then
				local b,code=update(item,{action="Deposit",id=id,owner=userId,payload=t.payload,epoch=t.epoch or 1})
				if code=="EpochExpired" then code="ABORTED" end
				if code=="ACCEPTED" or code=="ABORTED" then
					local o=b.orders[id]
					local result=commit(userId,"Outcome",{id=id,outcome=code,closed=o and not deps.Orders.active(o)})
					if result~="OK" and result~="AlreadyCommitted" then return result end
					if deps.Epochs and code=="ACCEPTED" then update(item,{action="ConfirmSource",id=id,owner=userId,epoch=t.epoch or 1}) end
				end
			end
		end
		local b=readBook(item)
		for id,t in pairs(profile(userId).data.market.transfers) do
			local o=b.orders[id]
			if deps.Epochs and t.state~="PREPARED" and b.receipts[id] and b.receipts[id].state=="ACCEPTED" and not b.receipts[id].sourceConfirmed then update(item,{action="ConfirmSource",id=id,owner=userId,epoch=t.epoch or 1}) end
			if t.state=="EXPORTED" and o and not deps.Orders.active(o) then
				local result=commit(userId,"Outcome",{id=id,outcome="ACCEPTED",closed=true})
				if result~="OK" and result~="AlreadyCommitted" then return result end
			end
		end
		-- A bounded batch leaves full wallets/inventories as durable pending claims.
		local count=0;local claims={}
		for _,claim in pairs(b.claims) do if claim.owner==userId then table.insert(claims,claim) end end
		table.sort(claims,function(a: any,z: any) return a.sequence<z.sequence end)
		for _,c in ipairs(claims) do
			if c.owner==userId and c.state=="PENDING" then
				if count>=12 then break end;count+=1
				local code=commit(userId,"Claim",{itemId=item,claim=c})
					if code=="OK" or code=="AlreadyCommitted" then update(item,{action="Ack",id=c.id,owner=userId,epoch=b.epoch}) else return code end
			end
		end
		if deps.Epochs and current.archivedThrough>0 then
			local floor=((profile(userId).data.market.floors or {})[item] or 0)
			if floor<current.archivedThrough then return commit(userId,"Compact",{itemId=item,through=current.archivedThrough}) end
		end
		return "OK"
	end
	function S.Create(userId: number,requestId: string,p: any,expectedEpoch: number?): string
		local invalid=deps.Orders.validate(p);if invalid then return invalid end
		local epoch=config.Epoch
		if deps.Epochs then
			local b=readBook(p.itemId);epoch=b.epoch
			if (expectedEpoch or 1)~=epoch then return "EpochExpired" end
			if b.phase~="ACTIVE" then return "EpochClosing" end
			if b.mode=="PAUSED" then return "MarketPaused" elseif b.mode=="READ_ONLY" then return "MarketReadOnly" end
			local recovered=S.RecoverPlayer(userId,p.itemId);if recovered~="OK" then return recovered end
		end
		local r=profile(userId);local id=tostring(userId)..":"..(if deps.Epochs then tostring(epoch)..":" else "")..requestId
		local existing=r.data.market.transfers[id]
		if existing and not util.equal(existing.payload,p) then return "RequestConflict" end
		if not existing then
			-- Validate the disposable candidate before consuming a durable admission ticket.
			local candidate,result=deps.Escrow.apply(r,"Reserve",{id=id,payload=p,epoch=if deps.Epochs then epoch else nil})
			if not candidate then return result.code end
			local _,code=update(p.itemId,{action="Prepare",id=id,owner=userId,payload=p,epoch=epoch})
			if code~="CREATED" then return if code=="ABORTED" then "RequestExpired" else code end
			local saved=commit(userId,"Reserve",{id=id,payload=p,epoch=if deps.Epochs then epoch else nil})
			if saved~="OK" and saved~="AlreadyCommitted" then return saved end
		end
		return S.RecoverPlayer(userId,p.itemId)
	end
	function S.Cancel(userId: number,item: string,id: string): string
		profile(userId)
		local _,code=update(item,{action="Cancel",id=id,owner=userId,epoch=readBook(item).epoch})
		if code~="OK" then return code end
		return S.RecoverPlayer(userId,item)
	end
	function S.Read(userId: number,item: string,period: string): any
		profile(userId)
		local b=readBook(item)
		return if deps.Epochs then deps.Epochs.project(b,userId,deps.Now(),period) else deps.MarketData.project(b,userId,deps.Now(),period)
	end
	local recoveryCursor: any={}
	function S.RecoverBook(item: string)
		-- Index rebuild and expiry are safe even after lease expiry or duplicate workers.
		local b=deps.Store.Read("b:"..item..":"..config.Epoch)
		if not b then return end
		-- A market worker may READ immutable reservations; it never writes foreign profiles.
		-- Admission tickets make the orphan discoverable without scanning all player keys.
		if deps.ReadProfile then
			local ids={};for id,receipt in pairs(b.receipts) do if receipt.state=="CREATED" then table.insert(ids,id) end end;table.sort(ids)
			for _=1,math.min(2,#ids) do
					recoveryCursor[item]=(recoveryCursor[item] or 0)%#ids+1
					local id=ids[recoveryCursor[item]];local receipt=b.receipts[id]
					local source=deps.ReadProfile(receipt.owner)
					local transfer=source and source.data.market and source.data.market.transfers[id]
					if transfer and transfer.state=="PREPARED" and util.equal(transfer.payload,receipt.payload) then
						b=update(item,{action="Deposit",id=id,owner=receipt.owner,payload=receipt.payload,epoch=transfer.epoch or 1})
					end
			end
		end
		for _,o in pairs(b.orders) do if deps.Orders.active(o) and o.expiresAt<=deps.Now() then b=update(item,{action="Recover",epoch=b.epoch});break end end
		if deps.Epochs then
			b=deps.Epochs.normalize(b,item,deps.Now())
			if b.phase=="ACTIVE" and (util.count(b.receipts)>=config.BookOrders or deps.Now()-b.openedAt>=config.EpochSeconds) then b=update(item,{action="CloseEpoch",epoch=b.epoch})
			elseif b.phase=="CLOSING" then b=update(item,{action="Reconcile",epoch=b.epoch})
			elseif b.phase=="RECONCILED" then b=update(item,{action="Archive",epoch=b.epoch})
			elseif b.phase=="ARCHIVED" then b=update(item,{action="StartEpoch",epoch=b.epoch}) end
		end
		pcall(deps.Changed,item,b)
	end
	function S.Operator(action: string,item: string,args: any): any
		assert(deps.Epochs,"HardeningNotEnabled");assert(config.Items[item],"NonTradable")
		local b=readBook(item)
		if action=="AuditEpoch" then return deps.Epochs.invariants(b) end
		if action=="MarketHealth" then return deps.Epochs.metrics(b,deps.Now()) end
		if action=="RebuildIndex" then deps.Changed(item,b);return deps.Epochs.metrics(b,deps.Now()) end
		if action=="RecoveryAssist" then S.RecoverBook(item);return deps.Epochs.metrics(readBook(item),deps.Now()) end
		assert(({CloseEpoch=true,Reconcile=true,Archive=true,StartEpoch=true,SetMode=true})[action],"InvalidOperatorAction")
		local nextBook,code=update(item,{action=action,epoch=b.epoch,mode=args and args.mode})
		return {code=code,health=deps.Epochs.metrics(nextBook,deps.Now())}
	end
	return S
end
