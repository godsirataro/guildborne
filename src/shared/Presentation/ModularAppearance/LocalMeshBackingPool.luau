--!strict
-- Single-flight, reference-counted immutable backing. No resource survives its last owner.
-- Injectable wait/dispose functions keep lifecycle tests independent of the engine.
return function(waitForCompletion: () -> (),dispose: (any) -> ())
	local entries: {[string]: any}={}
	local pool={}
	local function retire(entry: any)
		if entry.references~=0 or entry.pending then return end
		if entries[entry.key]==entry then entries[entry.key]=nil end
		if entry.resource then
			local resource=entry.resource;entry.resource=nil;dispose(resource)
		end
	end
	function pool.Release(entry: any)
		assert(entry.references>0,"BACKING_REFERENCE_UNDERFLOW")
		entry.references-=1
		retire(entry)
	end
	function pool.Acquire(key: string,register: (any) -> (),alive: () -> boolean,create: () -> any): any
		assert(alive(),"LOCAL_PREVIEW_CANCELLED")
		local entry=entries[key]
		local ownsCreation=entry==nil
		if not entry then
			entry={key=key,references=0,pending=true}
			entries[key]=entry
		end
		entry.references+=1
		register(entry) -- Enroll before create/wait can yield; cancellation releases this reference.
		if ownsCreation then
			local ok,result=pcall(create)
			entry.pending=false
			if ok and result then entry.resource=result
			else
				entry.problem=if ok then "BACKING_CREATION_RETURNED_NIL" else tostring(result)
				if entries[key]==entry then entries[key]=nil end
			end
			retire(entry)
		else
			while entry.pending do
				assert(alive(),"LOCAL_PREVIEW_CANCELLED")
				waitForCompletion()
			end
		end
		assert(alive(),"LOCAL_PREVIEW_CANCELLED")
		assert(not entry.problem,entry.problem)
		assert(entry.resource,"LOCAL_PREVIEW_CANCELLED")
		return entry.resource
	end
	function pool.Count(): number
		local count=0
		for _,entry in pairs(entries) do if entry.resource then count+=1 end end
		return count
	end
	function pool.PendingCount(): number
		local count=0
		for _,entry in pairs(entries) do if entry.pending then count+=1 end end
		return count
	end
	return pool
end
