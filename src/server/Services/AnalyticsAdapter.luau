--!strict
-- Providers are injected; telemetry failures never change a committed outcome.
return function(providers: { any }, log: any, contract:any?, defer:any?)
	local Adapter = {}
	local schedule=defer or function(callback:any) task.defer(callback) end
	local pending=0
	function Adapter.Emit(name: string, payload: any, player: Player?)
		pcall(log, name, payload)
		for _, provider in ipairs(providers) do
			local ok = pcall(provider, name, payload, player)
			if not ok then pcall(log, "analytics_deferred", { event = name }) end
		end
	end
	-- Additive product stream: strict schema, no forwarding of raw business payloads.
	function Adapter.Product(name:string,payload:any,player:Player?):boolean
		if not contract or pending>=32 then return false end
		local valid,safe=pcall(contract.sanitize,name,payload)
		if not valid or not safe then return false end
		-- Contract values are bounded scalars. Snapshot before handing work to the scheduler.
		local snapshot={};for k,v in pairs(safe)do snapshot[k]=v end
		local deliveries=table.clone(providers)
		local function copy():any return table.clone(snapshot) end
		pending+=1
		local released=false
		local function release()
			if not released then released=true;pending-=1 end
		end
		local queued=pcall(schedule,function()
			-- The slot stays occupied while any provider yields, bounding outstanding work.
			pcall(function()
				pcall(log,name,copy())
				for _,provider in ipairs(deliveries)do
					local ok=pcall(provider,name,copy(),player)
					if not ok then pcall(log,"analytics_deferred",{event=name})end
				end
			end)
			release()
		end)
		if not queued then release() end
		return queued
	end
	return Adapter
end
