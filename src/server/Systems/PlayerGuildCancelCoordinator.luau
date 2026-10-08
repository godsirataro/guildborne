--!strict
-- Staged companion to PlayerGuildJoinCoordinator. Same trusted conditional store.
-- Cancellation fences the original generation before releasing its user slot.
-- An accepted, completed join must use the separate leave/removal workflow.
return function(store:any,Membership:any)
	local C={}
	function C.cancel(userId:string,guildId:string,operationId:string):(string,string)
		local function id(value:any):boolean return type(value)=="string"and #value>0 and #value<=64 and value:match("^[%w_:%-]+$")~=nil end
		if type(userId)~="string"or #userId>16 or not userId:match("^[1-9]%d*$")or (tonumber(userId)or math.huge)>9007199254740991 or not id(guildId)or not id(operationId)then return "Rejected","InvalidRequest"end
		local key=userId..":"..operationId
		local op,status=store.read("Operation",key)
		if status=="Unavailable"then return "Pending","ReadOperation"end
		if status~="Found"then return "Rejected","UnknownOperation"end
		if not op or op.userId~=userId or op.guildId~=guildId or op.id~=operationId then return "Rejected","OperationMismatch"end
		if op.state=="Completed"then return "Rejected","AlreadyJoined"end
		if op.state=="Cancelled"then return "Cancelled","PreviouslyCancelled"end
		if op.state~="Joining"and op.state~="Cancelling"then return "Rejected","InvalidOperationState"end
		local _,marked,markReason=store.update("Operation",key,function(current:any):(boolean,string)
			if current.userId~=userId or current.guildId~=guildId or current.id~=operationId or current.generation~=op.generation then return false,"OperationMismatch"end
			if current.state=="Completed"then return false,"AlreadyJoined"end
			if current.state~="Joining"and current.state~="Cancelling"and current.state~="Cancelled"then return false,"InvalidOperationState"end
			if current.state~="Cancelled"then current.state="Cancelling"end;return true,"Cancelling"
		end)
		if marked~="Committed"then return if marked=="Rejected"then "Rejected"else "Pending",markReason or "MarkCancellation"end
		-- Even a never-reserved journal consumes its pinned generation. An accept
		-- already in flight cannot reserve the same generation after we finish.
		local _,reserved,reserveReason=store.update("Slot",userId,function(slot:any):(boolean,string)
			if slot.generation>op.generation then return true,"Superseded"end
			if slot.generation==op.generation then
				if slot.state=="Empty"or (slot.guildId==guildId and slot.operationId==operationId)then return true,"AlreadyReserved"end
				return false,"ReservationConflict"
			end
			if slot.state~="Empty"or slot.generation~=op.generation-1 then return false,"ReservationConflict"end
			return Membership.reserve(slot,guildId,operationId)
		end)
		if reserved~="Committed"then return if reserved=="Rejected"then "NeedsRecovery"else "Pending",reserveReason or "ReserveCancellation"end
		local proof={state="Reserved",generation=op.generation,guildId=guildId,operationId=operationId}
		local guild,revoked,revokeReason=store.update("Guild",guildId,function(g:any):(boolean,string)
			local member=g.members[userId]
			if (g.fences[userId]or 0)>op.generation then return true,"Superseded"end
			if not member and (g.fences[userId]or 0)==op.generation then return true,"AlreadyRemoved"end
			if member then
				if member.generation~=op.generation or member.operationId~=operationId then return false,"MembershipConflict"end
				if member.state=="Revoked"then return true,"AlreadyRevoked"end
				if member.state=="Active"then return Membership.revoke(g,userId,userId,operationId)end
			end
			return Membership.abortJoin(g,userId,proof,operationId)
		end)
		if revoked~="Committed"then return if revoked=="Rejected"then "NeedsRecovery"else "Pending",revokeReason or "RevokeMembership"end
		local slot,cleared,clearReason=store.update("Slot",userId,function(current:any):(boolean,string)
			if current.generation>op.generation or (current.generation==op.generation and current.state=="Empty")then return true,"AlreadyReleased"end
			if current.generation~=op.generation or current.guildId~=guildId or current.operationId~=operationId then return false,"ReservationConflict"end
			return Membership.clearSlot(current,guild,userId)
		end)
		if cleared~="Committed"then return if cleared=="Rejected"then "NeedsRecovery"else "Pending",clearReason or "ClearSlot"end
		local _,removed,removeReason=store.update("Guild",guildId,function(current:any):(boolean,string)
			local member=current.members[userId]
			if not member or member.generation>op.generation then return true,"AlreadyRemoved"end
			if member.generation~=op.generation or member.operationId~=operationId then return false,"MembershipConflict"end
			return Membership.finishRemoval(current,userId,slot)
		end)
		if removed~="Committed"then return if removed=="Rejected"then "NeedsRecovery"else "Pending",removeReason or "FinishRemoval"end
		local _,finished=store.update("Operation",key,function(current:any):(boolean,string)
			if current.userId~=userId or current.guildId~=guildId or current.id~=operationId or current.generation~=op.generation or (current.state~="Cancelling"and current.state~="Cancelled")then return false,"OperationMismatch"end
			current.state="Cancelled";return true,"Cancelled"
		end)
		if finished~="Committed"then return "Pending","FinalizeCancellation"end
		return "Cancelled","Cancelled"
	end
	return C
end
