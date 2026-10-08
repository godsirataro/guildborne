--!strict
-- Staged adapter contract: read(kind,key)->value,status (Found/Missing/Unavailable).
-- createOperation(key,value) atomically returns existing-or-created immutable data.
-- update(kind,key,callback) invokes callback on latest isolated data and commits only
-- when callback returns true. Returns committed copy, status (Committed/Rejected/
-- Unavailable), reason. Unavailable may mean committed: callers retry the same ID.
-- All adapter keys/proofs stay server-side. No live DataStore binding here.
return function(store:any,Membership:any)
	local Coordinator={}
	function Coordinator.accept(userId:string,guildId:string,token:string,operationId:string,now:number):(string,string)
		local function validId(value:any):boolean return type(value)=="string"and #value>0 and #value<=64 and value:match("^[%w_:%-]+$")~=nil end
		if type(userId)~="string"or #userId>16 or not userId:match("^[1-9]%d*$")or (tonumber(userId)or math.huge)>9007199254740991
			or not validId(guildId)or not validId(operationId)or type(token)~="string"or #token==0 or #token>96
			or type(now)~="number"or now~=now or now<0 or now>=1e12 then return "Rejected","InvalidRequest"end
		local key=userId..":"..operationId
		local operation,status=store.read("Operation",key)
		if status=="Unavailable"then return "Pending","ReadOperation"end
		if status=="Missing"then
			local slot,slotStatus=store.read("Slot",userId)
			if slotStatus~="Found"then return "Pending","ReadSlot"end
			if slot.state~="Empty"then return "Rejected","MembershipOccupied"end
			if slot.generation>=2147483647 then return "Rejected","GenerationExhausted"end
			local created,createdStatus=store.createOperation(key,{userId=userId,guildId=guildId,token=token,id=operationId,generation=slot.generation+1,state="Joining"})
			if createdStatus~="Found"then return "Pending","CreateOperation"end
			operation=created
		end
		if not operation or operation.userId~=userId or operation.guildId~=guildId or operation.token~=token or operation.id~=operationId then return "Rejected","OperationMismatch"end
		if operation.state=="Completed"then return "Completed","PreviouslyCompleted"end
		if operation.state=="Cancelling"or operation.state=="Cancelled"then return "Cancelled",operation.state end
		if operation.state~="Joining"then return "Rejected","InvalidOperationState"end
		local slot,writeStatus,reason=store.update("Slot",userId,function(current:any):(boolean,string)
			if current.generation==operation.generation and current.guildId==guildId and current.operationId==operationId and (current.state=="Reserved"or current.state=="Active")then return true,"AlreadyReserved"end
			if current.state~="Empty"or current.generation~=operation.generation-1 then return false,"ReservationSuperseded"end
			return Membership.reserve(current,guildId,operationId)
		end)
		if writeStatus~="Committed"then return if writeStatus=="Rejected"then "Rejected"else "Pending",reason or "ReserveSlot"end
		local guild,guildStatus,joinReason=store.update("Guild",guildId,function(current:any):(boolean,string)
			return Membership.prepareJoin(current,userId,token,slot,now)
		end)
		if guildStatus~="Committed"then return if guildStatus=="Rejected"then "NeedsCancellation"else "Pending",joinReason or "PrepareMember"end
		local activated,activateStatus,activateReason=store.update("Slot",userId,function(current:any):(boolean,string)
			return Membership.activateSlot(current,guild,userId)
		end)
		if activateStatus~="Committed"then return if activateStatus=="Rejected"then "NeedsRecovery"else "Pending",activateReason or "ActivateSlot"end
		local _,memberStatus,memberReason=store.update("Guild",guildId,function(current:any):(boolean,string)
			return Membership.activateMember(current,userId,activated)
		end)
		if memberStatus~="Committed"then return if memberStatus=="Rejected"then "NeedsRecovery"else "Pending",memberReason or "ActivateMember"end
		local _,finalStatus=store.update("Operation",key,function(current:any):(boolean,string)
			if current.id~=operationId or current.generation~=operation.generation then return false,"OperationMismatch"end
			if current.state~="Joining"and current.state~="Completed"then return false,"CancellationStarted"end
			current.state="Completed";return true,"Completed"
		end)
		if finalStatus~="Committed"then return "Pending","FinalizeOperation"end
		return "Completed","Joined"
	end
	return Coordinator
end
