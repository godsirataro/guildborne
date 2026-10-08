--!strict
-- All economic mutations checkpoint one profile. The injected store may yield.
return function(deps: any)
	local Service: any = { Sessions = {} }
	local util, config = deps.Util, deps.Config

	local function attempt(store: any, key: string, transform: any, userId: number): (boolean, any)
		for index = 1, config.MaxAttempts do
			local ok, result = pcall(store.Update, key, transform, userId)
			if ok then return true, result end
			if index < config.MaxAttempts then deps.Wait(config.RetryBaseSeconds * 2 ^ (index - 1) + deps.Jitter()) end
		end
		return false, nil
	end

	local function owned(record: any, session: any): boolean
		return record and record.session.ownerToken == session.token and record.session.epoch == session.epoch
	end
	local function adopt(session: any, record: any)
		session.record = record
		session.epoch = record.session.epoch
		session.state = "Active"
		session.problem = nil
	end

	function Service.Load(userId: number, token: string): (string, any)
		local session = Service.Sessions[userId]
		if session and session.busy then return "Busy", nil end
		if session and session.state == "Active" then return "OK", session.record end
		if session and session.state ~= "LoadFailed" then return session.state, nil end
		if not session then
			session = { token = token, state = "Loading", epoch = 0, busy = false, closing = false }
			Service.Sessions[userId] = session
		end
		session.busy = true
		session.state = "Loading"
		local reason = "StorageUnavailable"
		local success, record = attempt(deps.Store, "p:" .. tostring(userId), function(raw: any)
			reason = "StorageUnavailable"
			local now = deps.Now()
			local candidate
			if raw == nil then candidate = deps.Schema.new(userId, now)
			else
				candidate, reason = deps.Schema.migrate(raw)
				if not candidate then return nil end
			end
			local valid
			valid, reason = deps.Schema.validate(candidate, userId)
			if not valid then return nil end
			local lease = candidate.session
			if lease.ownerToken and lease.ownerToken ~= session.token and lease.leaseExpiresAt > now then reason = "ProfileInUse"; return nil end
			-- Same token is a retry of this acquisition after an uncertain response.
			if lease.ownerToken ~= session.token then lease.epoch += 1 end
			lease.ownerToken = session.token
			lease.leaseExpiresAt = now + config.LeaseSeconds
			candidate.updatedAt = now
			return candidate
		end, userId)
		session.busy = false
		if not success or not record then
			session.state = "LoadFailed"; session.problem = if success then reason else "StorageUnavailable"
			pcall(deps.Log, "profile_load_failed", { reason = session.problem })
			return session.problem, nil
		end
		adopt(session, record)
		pcall(deps.Log, "profile_loaded", { revision = record.revision })
		return "OK", record
	end

	local function commit(userId: number, session: any): (string, any)
		local pending = session.pending
		local reason = "StorageUnavailable"
		local success, record = attempt(deps.Store, "p:" .. tostring(userId), function(current: any)
			reason = "StorageUnavailable"
			if not owned(current, session) then reason = "LeaseLost"; return nil end
			local now = deps.Now()
			if current.session.leaseExpiresAt <= now then reason = "LeaseLost"; return nil end
			for _, operation in ipairs(current.operations.recentResults) do
				if operation.id == pending.id then
					if not util.equal(operation.command, pending.command) then reason = "RequestConflict"; return nil end
					return current
				end
			end
			if current.revision ~= pending.command.revision then reason = "RevisionConflict"; return nil end
			if #current.audit.outbox + #pending.events > deps.Content.Limits.Audit then reason = "AuditBacklog"; return nil end
			local nextRecord = util.copy(current)
			nextRecord.data = util.copy(pending.candidate.data)
			nextRecord.revision += 1
			nextRecord.updatedAt = now
			nextRecord.contentVersion = deps.Content.Version
			nextRecord.session.leaseExpiresAt = now + config.LeaseSeconds
			nextRecord.operations.lastCommittedSequence += 1
			local result = util.copy(pending.result)
			result.revision = nextRecord.revision
			table.insert(nextRecord.operations.recentResults, { id = pending.id, command = util.copy(pending.command), result = result })
			while #nextRecord.operations.recentResults > deps.Content.Limits.RecentResults do table.remove(nextRecord.operations.recentResults, 1) end
			for _, event in ipairs(pending.events) do
				local entry = util.copy(event)
				entry.sequence = nextRecord.audit.nextSequence
				entry.eventId = tostring(userId) .. ":" .. tostring(entry.sequence)
				entry.operationId = pending.id
				entry.occurredAt = pending.now
				entry.contentVersion = deps.Content.Version
				nextRecord.audit.nextSequence += 1
				table.insert(nextRecord.audit.outbox, entry)
			end
			local valid
			valid, reason = deps.Schema.validate(nextRecord, userId)
			if not valid then return nil end
			return nextRecord
		end, userId)
		if not success then
			session.state = "Degraded"; session.problem = "SavePending"
			pcall(deps.Log, "profile_save_failed", { action = pending.command.action, reason = "SavePending" })
			return "SavePending", nil
		end
		if not record then
			-- Unexpected conflicts must not resume from the old local view.
			session.state = if reason == "AuditBacklog" then "Active" else "LeaseLost"
			session.problem = reason; session.pending = nil
			return reason, nil
		end
		adopt(session, record)
		local result = pending.result
		for _, operation in ipairs(record.operations.recentResults) do if operation.id == pending.id then result = operation.result; break end end
		session.pending = nil
		pcall(deps.Log, "profile_saved", { revision = record.revision, action = pending.command.action })
		-- Provider failures cannot strand a committed command or its busy flag.
		pcall(deps.OnCommitted, userId, pending.events)
		return "OK", result
	end

	local function execute(userId: number, command: any, serverApply: any?): (string, any)
		if not serverApply then
			local valid, code = deps.Protocol.validate(command)
			if not valid then return code, nil end
		end
		local session = Service.Sessions[userId]
		if not session then return "ProfileNotReady", nil end
		if session.busy then return "Busy", nil end
		if session.closing then return "Closing", nil end
		if session.state ~= "Active" then return session.problem or session.state, nil end
		if deps.Now() >= session.record.session.leaseExpiresAt - config.LeaseSafetySeconds then return "LeaseExpiring", nil end
		local operationId = tostring(session.epoch) .. ":" .. command.requestId
		for _, operation in ipairs(session.record.operations.recentResults) do
			if operation.id == operationId then
				if not util.equal(operation.command, command) then return "RequestConflict", nil end
				return "AlreadyCommitted", operation.result
			end
		end
		if command.revision ~= session.record.revision then return "StaleRevision", nil end
		local now = deps.Now()
		local candidate, result, events
		if serverApply then candidate, result, events = serverApply(session.record)
		else candidate, result, events = deps.Commands.apply(session.record, command, now) end
		if not candidate then return result.code, nil end
		if #session.record.audit.outbox + #events > deps.Content.Limits.Audit then return "AuditBacklog", nil end
		session.pending = { id = operationId, command = util.copy(command), candidate = candidate, result = result, events = events, now = now }
		session.busy = true; session.state = "Saving"
		local status, outcome = commit(userId, session)
		session.busy = false
		return status, outcome
	end
	function Service.Execute(userId: number, command: any): (string, any)
		return execute(userId, command, nil)
	end
	-- Server-only story observations. Public Protocol rejects both action names.
	-- Receipt args live inside the command so request replay/conflict compares them.
	function Service.CommitNovice(userId:number,command:any):(string,any)
		if not deps.NoviceStory or type(command)~="table" or (command.action~="NoviceObjective" and command.action~="NoviceTrial") then return "InvalidAction",nil end
		if type(command.requestId)~="string" or #command.requestId<1 or #command.requestId>64 or type(command.args)~="table" then return "InvalidRequest",nil end
		return execute(userId,command,function(record:any)return deps.NoviceStory.receipt(record,command)end)
	end
	function Service.CommitCampaign(userId:number,command:any):(string,any)
		if not deps.Campaign or type(command)~="table"or command.action~="CampaignObjective"then return "InvalidAction",nil end
		if type(command.requestId)~="string"or #command.requestId<1 or #command.requestId>64 or type(command.args)~="table"then return "InvalidRequest",nil end
		return execute(userId,command,function(record:any)return deps.Campaign.receipt(record,command)end)
	end
	function Service.CommitMarket(userId: number,action: string,payload: any): string
		if not deps.MarketEscrow then return "MarketUnavailable" end
		local session=Service.Sessions[userId]
		if not session or not session.record then return "ProfileNotReady" end
		local command={version=1,requestId="market:"..tostring(session.record.revision),action="Market"..action,revision=session.record.revision,args=payload}
		local code=execute(userId,command,function(record: any) return deps.MarketEscrow.apply(record,action,payload) end)
		return code
	end
	-- Private dependency-injected entry point; never dispatched by NetworkService.
	-- The caller retains this immutable command across retries, including its revision.
	function Service.CommitCombat(userId: number, command: any, members: {string},encounterId:string?): (string, any)
		if not deps.CombatRewards or command.action~="CombatReward" then return "InvalidAction",nil end
		return execute(userId,command,function(record: any) return deps.CombatRewards(record,members,encounterId) end)
	end

	function Service.CommitTower(userId: number,command: any,runId: string,floor: number,success: boolean): (string,any)
		if not deps.Expansion or command.action~="TowerResult" then return "InvalidAction",nil end
		return execute(userId,command,function(record: any) return deps.Expansion.finish(record,runId,floor,success) end)
	end

	-- Trusted receipt entry point. Durable purchase IDs outlive the recent command window.
	function Service.CommitElixir(userId: number,purchaseId: string,productId: number): string
		if deps.Content.Elixir.DeveloperProductId<=0 or productId~=deps.Content.Elixir.DeveloperProductId or type(purchaseId)~="string" or #purchaseId<1 or #purchaseId>128 then return "InvalidReceipt" end
		local session=Service.Sessions[userId];if not session or not session.record then return "ProfileNotReady" end
		if session.record.data.settlement.purchases[purchaseId]==productId then return "AlreadyCommitted" end
		local command={version=1,requestId="receipt:"..purchaseId,action="ElixirReceipt",revision=session.record.revision,args={}}
		local code=execute(userId,command,function(record: any)
			local copy=util.copy(record);local town=copy.data.settlement
			if town.elixirs>=99 or util.count(town.purchases)>=1000 then return nil,{code="InventoryFull"},{} end
			town.elixirs+=1;town.purchases[purchaseId]=productId
			return copy,{code="OK"},{{name="elixir_purchased",payload={productId=productId}}}
		end)
		return code
	end

	-- Private server ownership path; the public Protocol does not accept this action.
	function Service.CommitPermanentPass(userId:number,passId:number):string
		if not deps.PermanentEntitlements then return "PurchasesDisabled" end
		if type(passId)~="number" or passId~=passId or passId%1~=0 or passId<=0 or passId>9007199254740991 then return "UnknownPass" end
		local session=Service.Sessions[userId]
		if not session or not session.record then return "ProfileNotReady" end
		local command={version=1,requestId="pass:"..tostring(passId)..":"..tostring(session.record.revision),action="PermanentPassOwnership",revision=session.record.revision,args={passId=passId}}
		local code=execute(userId,command,function(record:any)return deps.PermanentEntitlements.apply(record,passId)end)
		return code
	end

	function Service.Refresh(userId: number): string
		local session = Service.Sessions[userId]
		if not session or session.state == "LoadFailed" or session.state == "LeaseLost" then return "ProfileNotReady" end
		if session.busy then return "Busy" end
		session.busy = true
		if session.pending then
			local code = commit(userId, session)
			session.busy = false
			return code
		end
		local reason = "StorageUnavailable"
		local success, record = attempt(deps.Store, "p:" .. tostring(userId), function(current: any)
			if not owned(current, session) or current.session.leaseExpiresAt <= deps.Now() then reason = "LeaseLost"; return nil end
			local copy = util.copy(current)
			copy.session.leaseExpiresAt = deps.Now() + config.LeaseSeconds
			return copy
		end, userId)
		session.busy = false
		if success and record then adopt(session, record); return "OK" end
		session.state = if success then "LeaseLost" else "Degraded"
		session.problem = if success then reason else "StorageUnavailable"
		return session.problem
	end

	function Service.FlushAudit(userId: number): string
		local session = Service.Sessions[userId]
		if not session or session.state ~= "Active" or session.busy or session.pending then return "Busy" end
		if #session.record.audit.outbox == 0 then return "OK" end
		session.busy = true
		local batch = util.copy(session.record.audit.outbox)
		local pages: any = {}
		for _, event in ipairs(batch) do
			local pageId = math.floor((event.sequence - 1) / config.AuditPageSize)
			pages[pageId] = pages[pageId] or {}
			table.insert(pages[pageId], event)
		end
		for pageId, events in pairs(pages) do
			local success = attempt(deps.AuditStore, "p:" .. tostring(userId) .. ":" .. tostring(pageId), function(raw: any)
				local page = util.copy(raw or { schemaVersion = 1, events = {} })
				for _, event in ipairs(events) do
					local key = tostring(event.sequence)
					if page.events[key] and not util.equal(page.events[key], event) then error("AuditConflict") end
					page.events[key] = event
				end
				return page
			end, userId)
			if not success then session.busy = false; deps.Log("audit_export_deferred", {}); return "AuditUnavailable" end
		end
		local through = batch[#batch].sequence
		local success, record = attempt(deps.Store, "p:" .. tostring(userId), function(current: any)
			if not owned(current, session) or current.session.leaseExpiresAt <= deps.Now() then return nil end
			local copy = util.copy(current)
			local remaining = {}
			for _, event in ipairs(copy.audit.outbox) do if event.sequence > through then table.insert(remaining, event) end end
			copy.audit.outbox = remaining
			copy.audit.exportedThrough = math.max(copy.audit.exportedThrough, through)
			return copy
		end, userId)
		session.busy = false
		if success and record then adopt(session, record); return "OK" end
		-- A failed acknowledgment only leaves an already archived outbox for safe retry.
		if success then session.state = "LeaseLost"; session.problem = "LeaseLost" end
		return "AuditAckPending"
	end

	function Service.Close(userId: number): string
		local session = Service.Sessions[userId]
		if not session then return "OK" end
		session.closing = true
		if session.busy then return "Busy" end
		if session.pending then
			session.busy = true
			local code = commit(userId, session)
			session.busy = false
			if code == "SavePending" then return code end
		end
		session.busy = true; session.state = "Closing"
		local success = attempt(deps.Store, "p:" .. tostring(userId), function(current: any)
			if not owned(current, session) then return nil end
			local copy = util.copy(current)
			copy.session.ownerToken = nil; copy.session.leaseExpiresAt = 0
			return copy
		end, userId)
		session.busy = false
		if success then Service.Sessions[userId] = nil; return "OK" end
		return "ClosePending"
	end
	return Service
end
