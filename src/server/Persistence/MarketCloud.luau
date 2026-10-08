--!strict
local DSS=game:GetService("DataStoreService")
local MS=game:GetService("MemoryStoreService")
local Messages=game:GetService("MessagingService")
local Http=game:GetService("HttpService")
return function(namespace: string,config: any,orders: any)
	assert(#namespace<32)
	local store=DSS:GetDataStore("GB_Market_"..namespace)
	local cache: any={};local metrics={reads=0,writes=0,indexWrites=0,notifications=0,failures=0}
	local A: any={Metrics=metrics,Health={durable="Unknown",index="Unknown",messages="Unknown"}}
	local breaker=require(script.Parent.Parent.Systems.MarketHealth)(config,os.clock);A.Breaker=breaker
	local lastWrite: any={}
	function A.CanMaintain(): boolean
		return breaker.allow() and breaker.budget(DSS:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync),DSS:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync),true)
	end
	local function retry(fn: any): any
		local last: any
		for attempt=1,3 do
			local ok,value=pcall(fn)
			if ok then A.Health.durable="OK";return value end
			last=value;metrics.failures+=1;breaker.failed(tostring(value));breaker.retries+=1
			if attempt<3 then task.wait(.5*2^(attempt-1)+math.random()*.2) end
		end
		A.Health.durable="Unavailable";error(tostring(last))
	end
	A.Store={
		Read=function(key: string): any
			local entry=cache[key];if entry and os.clock()-entry.at<config.CacheSeconds then return entry.value end
			local value=retry(function()
				if DSS:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)<=config.BudgetReserve then breaker.throttles+=1;error("MarketBudgetReservedForProfiles") end
				metrics.reads+=1;local options=Instance.new("DataStoreGetOptions");options.UseCache=false
				return store:GetAsync(key,options)
			end)
			cache[key]={value=value,at=os.clock()};return value
		end,
		Update=function(key: string,transform: any): any
			assert(breaker.allow(),"MarketCircuitOpen")
			local now=os.clock();local slot=math.max(now,(lastWrite[key] or -math.huge)+config.ItemWriteInterval)
			assert(slot-now<=config.MaxItemQueueSeconds,"MarketHotItemBusy")
			lastWrite[key]=slot -- Reserve a distinct slot before yielding; no simultaneous waiter burst.
			if slot>now then task.wait(slot-now) end
			local value=retry(function()
				if not breaker.budget(DSS:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync),DSS:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync)) then error("MarketBudgetReservedForProfiles") end
				metrics.writes+=1
				local committed = store:UpdateAsync(key,function(raw)
					local candidate=transform(raw);if not candidate then return nil end
					assert(#Http:JSONEncode(candidate)<=config.BookBytes,"MarketBytes")
					return candidate
				end)
				assert(committed ~= nil, "MarketWriteNotCommitted")
				return committed
			end)
			breaker.success()
			cache[key]={value=value,at=os.clock()};return value
		end,
	}
	local function publish(item: string,book: any)
		metrics.indexRebuildCount=(metrics.indexRebuildCount or 0)+1
		-- Two bounded depth snapshots per item, sharded by item AND side. No user IDs.
		for _,side in ipairs({"BUY","SELL"}) do
			local map=MS:GetSortedMap("GBM:"..namespace..":"..item..":"..side)
			local rows={}
			for _,o in ipairs(orders.sorted(book,side)) do
				if #rows>=config.Depth then break end
				table.insert(rows,{price=o.price,quantity=o.remaining,sequence=o.sequence})
			end
			local ok=pcall(function()
				metrics.indexWrites+=1
				map:UpdateAsync("depth",function(old: any): (any,any)
					if old and old.revision>book.revision then return nil,nil end
					return {revision=book.revision,rows=rows},book.revision
				end,config.IndexTTL)
			end)
			A.Health.index=if ok then "OK" else "Unavailable"
			if ok then metrics.projectionAt=os.time() end
		end
		local ok=pcall(function() metrics.notifications+=1;Messages:PublishAsync("GBM:"..namespace,{item=item,revision=book.revision}) end)
		A.Health.messages=if ok then "OK" else "Unavailable"
	end
	local queued: any={}
	function A.Changed(item: string,book: any)
		local pending=queued[item];queued[item]=book
		if pending then return end
		task.delay(2,function() local newest=queued[item];queued[item]=nil;publish(item,newest) end)
	end
	function A.Subscribe()
		local ok,connection=pcall(function() return Messages:SubscribeAsync("GBM:"..namespace,function(message)
			local d: any=message.Data
			if type(d)=="table" and config.Items[d.item] then cache["b:"..d.item..":"..config.Epoch]=nil end
		end) end)
		A.Health.messages=if ok then "OK" else "Unavailable";return if ok then connection else nil
	end
	return A
end
