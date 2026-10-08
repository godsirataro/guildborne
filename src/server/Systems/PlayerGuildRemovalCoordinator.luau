--!strict
-- Staged leave/kick coordinator. Server-authenticated actor and expected generations
-- are mandatory. Canonical revocation precedes slot release; journals never expire here.
return function(store:any,Membership:any)
	local C={}
	local function user(v:any):boolean return type(v)=="string"and #v<=16 and v:match("^[1-9]%d*$")~=nil and (tonumber(v)or math.huge)<=9007199254740991 end
	local function id(v:any):boolean return type(v)=="string"and #v>0 and #v<=64 and v:match("^[%w_:%-]+$")~=nil end
	local function generation(v:any):boolean return type(v)=="number"and v>=1 and v<=2147483647 and v%1==0 end
	function C.remove(actorId:string,actorGeneration:number,guildId:string,targetId:string,targetGeneration:number,operationId:string):(string,string)
		if not user(actorId)or not user(targetId)or not generation(actorGeneration)or not generation(targetGeneration)or not id(guildId)or not id(operationId)then return "Rejected","InvalidRequest"end
		local key="remove:"..tostring(#guildId)..":"..guildId..":"..operationId
		local expected={id=operationId,actorId=actorId,actorGeneration=actorGeneration,guildId=guildId,targetId=targetId,targetGeneration=targetGeneration}
		local function matches(value:any):boolean
			if type(value)~="table"then return false end
			for k,v in pairs(expected)do if value[k]~=v then return false end end;return true
		end
		local op,status=store.read("Operation",key)
		if status=="Unavailable"then return "Pending","ReadOperation"end
		if status=="Missing"then
			local candidate=table.clone(expected);candidate.state="Removing"
			local created,createdStatus=store.createOperation(key,candidate)
			if createdStatus~="Found"then return "Pending","CreateOperation"end
			op=created
		end
		if not matches(op)then return "Rejected","OperationMismatch"end
		if op.state=="Removed"then return "Removed","PreviouslyRemoved"end
		if op.state~="Removing"then return "Rejected","InvalidOperationState"end
		local guild,revoked,reason=store.update("Guild",guildId,function(current:any):(boolean,string)
			local member=current.members[targetId]
			if not member then
				if (current.fences[targetId]or 0)>=targetGeneration then return true,"AlreadyRemoved"end
				return false,"MembershipMissing"
			end
			if member.generation>targetGeneration then return true,"Superseded"end
			if member.generation~=targetGeneration then return false,"MembershipConflict"end
			-- Completing our own already-written revocation is safe after the actor
			-- changes roles or leaves. A different revocation belongs to recovery.
			if member.state=="Revoked"then
				return member.revokeOperation==operationId,if member.revokeOperation==operationId then "AlreadyRevoked"else "RevocationConflict"
			end
			local actor=current.members[actorId]
			if not actor or actor.state~="Active"or actor.generation~=actorGeneration then return false,"ActorChanged"end
			if member.state~="Active"then return false,"MembershipNotActive"end
			return Membership.revoke(current,actorId,targetId,operationId)
		end)
		if revoked~="Committed"then return if revoked=="Rejected"then "Rejected"else "Pending",reason or "RevokeMembership"end
		local slot,cleared,clearReason=store.update("Slot",targetId,function(current:any):(boolean,string)
			if current.generation>targetGeneration or (current.generation==targetGeneration and current.state=="Empty")then return true,"AlreadyReleased"end
			if current.generation~=targetGeneration or current.guildId~=guildId then return false,"MembershipConflict"end
			return Membership.clearSlot(current,guild,targetId)
		end)
		if cleared~="Committed"then return if cleared=="Rejected"then "NeedsRecovery"else "Pending",clearReason or "ClearSlot"end
		local _,removed,removeReason=store.update("Guild",guildId,function(current:any):(boolean,string)
			local member=current.members[targetId]
			if not member or member.generation>targetGeneration then return true,"AlreadyRemoved"end
			if member.generation~=targetGeneration or member.state~="Revoked"or member.revokeOperation~=operationId then return false,"RevocationConflict"end
			return Membership.finishRemoval(current,targetId,slot)
		end)
		if removed~="Committed"then return if removed=="Rejected"then "NeedsRecovery"else "Pending",removeReason or "FinishRemoval"end
		local _,finished=store.update("Operation",key,function(current:any):(boolean,string)
			if not matches(current)or (current.state~="Removing"and current.state~="Removed")then return false,"OperationMismatch"end
			current.state="Removed";return true,"Removed"
		end)
		if finished~="Committed"then return "Pending","FinalizeRemoval"end
		return "Removed","Removed"
	end
	return C
end
