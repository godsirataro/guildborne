--!strict
-- Process-local Studio/test adapter. Never silently substituted for DataStore errors.
return function(util: any)
	local records: { [string]: any } = {}
	return {
		Read = function(key: string): any return util.copy(records[key]) end,
		Update = function(key: string, transform: any, _userId: number?): any
			local candidate = transform(util.copy(records[key]))
			if candidate == nil then return nil end
			records[key] = util.copy(candidate)
			return util.copy(candidate)
		end,
	}
end
