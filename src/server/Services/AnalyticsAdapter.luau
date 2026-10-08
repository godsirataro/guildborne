--!strict
-- Providers are injected; telemetry failures never change a committed outcome.
return function(providers: { any }, log: any)
	local Adapter = {}
	function Adapter.Emit(name: string, payload: any, player: Player?)
		pcall(log, name, payload)
		for _, provider in ipairs(providers) do
			local ok = pcall(provider, name, payload, player)
			if not ok then pcall(log, "analytics_deferred", { event = name }) end
		end
	end
	return Adapter
end
