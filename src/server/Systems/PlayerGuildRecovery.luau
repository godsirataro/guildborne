--!strict
-- Read-only recovery decisions. Adapters must re-read inside conditional writes.
-- An unavailable record is never equivalent to a confirmed missing record.
local Recovery = {}
function Recovery.next(slot:any, guild:any, userId:string, readStatus:string):string
	if readStatus ~= "Found" and readStatus ~= "Missing" then return "RetryRead" end
	if readStatus == "Missing" then
		return if slot.state == "Empty" then "Idle" else "InvestigateMissingGuild"
	end
	if type(guild) ~= "table" or type(guild.members) ~= "table" then return "Quarantine" end
	local member = guild.members[userId]
	if slot.state == "Empty" then
		if not member then return "Idle" end
		if member.state == "Revoked" and slot.generation >= member.generation then return "FinishRemoval" end
		return "Quarantine"
	end
	if slot.guildId ~= guild.id then
		if member and member.state == "Revoked" and slot.generation > member.generation then return "FinishRemoval" end
		if member then return "Quarantine" end
		return "ReadCurrentGuild"
	end
	if not member then
		return if slot.state == "Reserved" then "ResumeOrCancelReservation" else "Quarantine"
	end
	if member.generation ~= slot.generation or member.operationId ~= slot.operationId then return "Quarantine" end
	if member.state == "Revoked" then return "ClearSlot" end
	if slot.state == "Reserved" then
		return if member.state == "Pending" then "ActivateSlot" else "Quarantine"
	end
	if slot.state == "Active" then
		if member.state == "Pending" then return "ActivateMember" end
		if member.state == "Active" then return "Ready" end
	end
	return "Quarantine"
end
return Recovery
