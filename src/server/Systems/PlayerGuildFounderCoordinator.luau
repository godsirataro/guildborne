--!strict
-- Staged, roll-forward guild creation. createGuild mirrors createOperation:
-- atomically create only if absent, return existing-or-created copy and Found;
-- Unavailable can mean the write committed. Never replace an existing guild.
-- Names, fees, authentication and real storage remain separate release gates.
return function(store:any,Membership:any,capacity:number)
	assert(capacity%1==0 and capacity>=2 and capacity<=50,"InvalidCapacity")
	local C={}
	function C.create(userId:string,guildId:string,operationId:string):(string,string)
		local function id(v:any):boolean return type(v)=="string"and #v>0 and #v<=64 and v:match("^[%w_:%-]+$")~=nil end
		if type(userId)~="string"or #userId>16 or not userId:match("^[1-9]%d*$")or (tonumber(userId)or math.huge)>9007199254740991 or not id(guildId)or not id(operationId)then return "Rejected","InvalidRequest"end
		local key=userId..":"..operationId
		local op,status=store.read("Operation",key)
		if status=="Unavailable"then return "Pending","ReadOperation"end
		if status=="Missing"then
			local slot,slotStatus=store.read("Slot",userId)
			if slotStatus~="Found"then return "Pending","ReadSlot"end
			if slot.state~="Empty"then return "Rejected","MembershipOccupied"end
			if slot.generation>=2147483647 then return "Rejected","GenerationExhausted"end
			local created,createdStatus=store.createOperation(key,{userId=userId,guildId=guildId,id=operationId,generation=slot.generation+1,capacity=capacity,state="Creating"})
			if createdStatus~="Found"then return "Pending","CreateOperation"end;op=created
		end
		if not op or op.userId~=userId or op.guildId~=guildId or op.id~=operationId or op.capacity~=capacity then return "Rejected","OperationMismatch"end
		if op.state=="Created"then return "Created","PreviouslyCreated"end
		if op.state~="Creating"then return "Rejected","InvalidOperationState"end
		local _,reserved,reserveReason=store.update("Slot",userId,function(current:any):(boolean,string)
			if current.generation==op.generation and current.guildId==guildId and current.operationId==operationId and (current.state=="Reserved"or current.state=="Active")then return true,"AlreadyReserved"end
			if current.state~="Empty"or current.generation~=op.generation-1 then return false,"ReservationSuperseded"end
			return Membership.reserve(current,guildId,operationId)
		end)
		if reserved~="Committed"then return if reserved=="Rejected"then "NeedsRecovery"else "Pending",reserveReason or "ReserveSlot"end
		-- newGuild requires Reserved even when retrying an already activated slot.
		local proof={state="Reserved",generation=op.generation,guildId=guildId,operationId=operationId}
		local candidate=Membership.newGuild(guildId,userId,proof,capacity)
		candidate.creation={founder=userId,generation=op.generation,operationId=operationId}
		local guild,guildStatus=store.createGuild(guildId,candidate)
		if guildStatus~="Found"then return "Pending","CreateGuild"end
		local creation=guild and guild.creation
		if not guild or guild.id~=guildId or guild.abandoned or guild.capacity~=capacity or not creation or creation.founder~=userId or creation.generation~=op.generation or creation.operationId~=operationId then return "NeedsRecovery","GuildIdentityConflict"end
		local activated,activeStatus,activeReason=store.update("Slot",userId,function(current:any):(boolean,string)
			return Membership.activateSlot(current,guild,userId)
		end)
		if activeStatus~="Committed"then return if activeStatus=="Rejected"then "NeedsRecovery"else "Pending",activeReason or "ActivateSlot"end
		local _,memberStatus,memberReason=store.update("Guild",guildId,function(current:any):(boolean,string)
			local origin=current.creation
			if not origin or origin.founder~=userId or origin.generation~=op.generation or origin.operationId~=operationId then return false,"GuildIdentityConflict"end
			return Membership.activateMember(current,userId,activated)
		end)
		if memberStatus~="Committed"then return if memberStatus=="Rejected"then "NeedsRecovery"else "Pending",memberReason or "ActivateMember"end
		local _,finished=store.update("Operation",key,function(current:any):(boolean,string)
			if current.userId~=userId or current.guildId~=guildId or current.id~=operationId or current.generation~=op.generation or (current.state~="Creating"and current.state~="Created")then return false,"OperationMismatch"end
			current.state="Created";return true,"Created"
		end)
		if finished~="Committed"then return "Pending","FinalizeCreation"end
		return "Created","Created"
	end
	return C
end
