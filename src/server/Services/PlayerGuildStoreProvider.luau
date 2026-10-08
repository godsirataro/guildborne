--!strict
-- Explicitly injected DataStore handle only. This module never opens a store and
-- is not bound in ServerBootstrap. The validated store owns failure classification.
return function(dataStore:any):any
	local provider={}
	function provider.Get(key:string):any
		local options=Instance.new("DataStoreGetOptions");options.UseCache=false
		return dataStore:GetAsync(key,options)
	end
	function provider.Update(key:string,transform:any):any
		return dataStore:UpdateAsync(key,function(current:any,info:any):any
			local nextValue=transform(current)
			if nextValue==nil then return nil end
			-- Preserve existing platform metadata when a conditional callback reruns.
			return nextValue,if info then info:GetUserIds()else {},if info then info:GetMetadata()else {}
		end)
	end
	return provider
end
