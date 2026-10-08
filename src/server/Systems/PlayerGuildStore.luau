--!strict
-- Staged validated conditional store. Provider.Get must bypass cache; Provider.Update
-- must atomically retry a NON-YIELDING callback on current data, returning its
-- committed value or nil when cancelled. Throws may mean a write committed.
-- No provider, cloud credentials, DataStore name or runtime binding is created here.
return function(provider:any,keyFor:any,Schema:any,Membership:any)
	local function copy(v:any):any
		if type(v)~="table"then return v end;local out={};for k,x in pairs(v)do out[k]=copy(x)end;return out
	end
	local function valid(kind:string,key:string,data:any):boolean
		if kind=="Slot"then
			return key:match("^[1-9]%d*$")~=nil and #key<=16 and (tonumber(key)or math.huge)<=9007199254740991 and Schema.slot(data)
		elseif kind=="Guild"then return type(data)=="table"and data.id==key and Schema.guild(data)
		elseif kind=="Operation"then return Schema.operation(data,key)end
		return false
	end
	local function envelope(raw:any,kind:string,key:string):boolean
		return type(raw)=="table"and raw.version==1 and raw.kind==kind and raw.logicalKey==key
			and type(raw.revision)=="number"and raw.revision>=1 and raw.revision<=2147483647 and raw.revision%1==0 and valid(kind,key,raw.data)
	end
	local function physical(kind:string,key:string):string?
		if type(key)~="string"then return nil end
		local ok,value=pcall(keyFor,kind,key)
		return if ok and type(value)=="string"and #value>=1 and #value<=50 then value else nil
	end
	local S={}
	function S.read(kind:string,key:string):(any,string,string?)
		local address=physical(kind,key);if not address then return nil,"Unavailable","InvalidKey"end
		local ok,raw=pcall(provider.Get,address)
		if not ok then return nil,"Unavailable","ReadFailed"end
		if raw==nil then return nil,"Missing",nil end
		local checked,good=pcall(envelope,raw,kind,key)
		if not checked or not good then return nil,"Unavailable","InvalidRecord"end
		return copy(raw.data),"Found",nil
	end
	local function create(kind:string,key:string,data:any):(any,string,string?)
		local address=physical(kind,key);local checked,good=pcall(valid,kind,key,data)
		if not address or not checked or not good then return nil,"Unavailable","InvalidCandidate"end
		local ok,raw=pcall(provider.Update,address,function(current:any):any
			if current~=nil then
				if not envelope(current,kind,key)then return nil end
				return current
			end
			return {version=1,kind=kind,logicalKey=key,revision=1,data=copy(data)}
		end)
		if not ok or raw==nil then return nil,"Unavailable","CreateUnconfirmed"end
		local verified,isValid=pcall(envelope,raw,kind,key)
		if not verified or not isValid then return nil,"Unavailable","InvalidRecord"end
		return copy(raw.data),"Found",nil
	end
	function S.createOperation(key:string,value:any):(any,string,string?)return create("Operation",key,value)end
	function S.createGuild(key:string,value:any):(any,string,string?)return create("Guild",key,value)end
	function S.ensureSlot(userId:string):(any,string,string?)return create("Slot",userId,Membership.newSlot())end
	function S.update(kind:string,key:string,callback:any):(any,string,string?)
		local address=physical(kind,key);if not address then return nil,"Rejected","InvalidKey"end
		local rejection:string?=nil
		local ok,raw=pcall(provider.Update,address,function(current:any):any
			-- UpdateAsync can discard and rerun callbacks. Only the final invocation
			-- determines a rejection; previous candidate objects are never reused.
			rejection=nil
			if current==nil then rejection="MissingRecord";return nil end
			if not envelope(current,kind,key)then rejection="InvalidRecord";return nil end
			if current.revision>=2147483647 then rejection="RevisionExhausted";return nil end
			local candidate=copy(current.data);local accept,reason=callback(candidate)
			if accept~=true then rejection=reason or "Rejected";return nil end
			if not valid(kind,key,candidate)then rejection="InvalidCandidate";return nil end
			return {version=1,kind=kind,logicalKey=key,revision=current.revision+1,data=candidate}
		end)
		if not ok then return nil,"Unavailable","WriteUnconfirmed"end
		if raw==nil then return nil,if rejection then "Rejected"else "Unavailable",rejection or "WriteUnconfirmed"end
		local checked,good=pcall(envelope,raw,kind,key)
		if not checked or not good then return nil,"Unavailable","InvalidRecord"end
		return copy(raw.data),"Committed",nil
	end
	return S
end
