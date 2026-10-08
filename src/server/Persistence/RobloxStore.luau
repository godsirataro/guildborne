--!strict
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

return function(name: string, maximumBytes: number)
	local store = DataStoreService:GetDataStore(name)
	return {
		Read = function(key: string): any
			if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)<1 then error("StorageBudgetUnavailable") end
			local options=Instance.new("DataStoreGetOptions");options.UseCache=false
			return store:GetAsync(key,options)
		end,
		Update = function(key: string, transform: any, userId: number?): any
			-- Admission is conservative; Roblox may still throttle or fail after this check.
			if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync) < 1 then
				error("StorageBudgetUnavailable")
			end
			return store:UpdateAsync(key, function(current, info)
				local candidate = transform(current)
				if candidate == nil then return nil end
				if #HttpService:JSONEncode(candidate) > maximumBytes then error("RecordSizeLimit") end
				local ids = if userId and userId > 0 then { userId } else (if info then info:GetUserIds() else {})
				return candidate, ids, if info then info:GetMetadata() else {}
			end)
		end,
	}
end
