--!strict
-- Reject malformed persisted authority instead of silently repairing roles.
local Schema={}
local roles={Master=true,Officer=true,Commander=true,Member=true}
local states={Pending=true,Active=true,Revoked=true}
local function integer(v:any,min:number,max:number):boolean return type(v)=="number"and v==v and v%1==0 and v>=min and v<=max end
local function id(v:any):boolean return type(v)=="string"and #v>0 and #v<=64 and v:match("^[%w_:%-]+$")~=nil end
local function user(v:any):boolean return type(v)=="string"and #v<=16 and v:match("^[1-9]%d*$")~=nil and (tonumber(v)or math.huge)<=9007199254740991 end
local function timestamp(v:any):boolean return type(v)=="number"and v==v and v>=0 and v<1000000086400 end
function Schema.slot(s:any):(boolean,string)
	if type(s)~="table"or not integer(s.generation,0,2147483647)then return false,"InvalidSlot"end
	if s.state=="Empty"then return s.guildId==nil and s.operationId==nil,"EmptySlot"end
	if (s.state~="Reserved"and s.state~="Active")or s.generation<1 or not id(s.guildId)or not id(s.operationId)then return false,"InvalidReservation"end
	return true,"Valid"
end
function Schema.guild(g:any):(boolean,string)
	if type(g)~="table"or g.version~=1 or not id(g.id)or not user(g.leader)or not integer(g.capacity,2,50)then return false,"InvalidGuild"end
	for _,key in ipairs({"leaderEpoch","nextInvite","nextTransfer"})do if not integer(g[key],1,2147483647)then return false,"InvalidCounter"end end
	if type(g.members)~="table"or type(g.fences)~="table"or type(g.invites)~="table"then return false,"InvalidCollections"end
	if g.abandoned~=nil and g.abandoned~=true then return false,"InvalidAbandonment"end
	if g.creation~=nil then
		local c=g.creation
		if type(c)~="table"or not user(c.founder)or not integer(c.generation,1,2147483647)or not id(c.operationId)or not integer(g.fences[c.founder],c.generation,2147483647)then return false,"InvalidCreation"end
	end
	local masters,occupied=0,0
	for uid,generation in pairs(g.fences)do if not user(uid)or not integer(generation,1,2147483647)then return false,"InvalidFence"end end
	for uid,m in pairs(g.members)do
		if not user(uid)or type(m)~="table"or not states[m.state]or not roles[m.role]or not id(m.operationId)or not integer(m.generation,1,2147483647)then return false,"InvalidMember"end
		if g.fences[uid]~=m.generation then return false,"FenceMismatch"end
		if m.state=="Revoked"then if not id(m.revokeOperation)then return false,"MissingRevocation"end
		else
			occupied+=1
			if m.role=="Master"then masters+=1;if uid~=g.leader then return false,"LeaderMismatch"end end
		end
	end
	if occupied>g.capacity then return false,"CapacityExceeded"end
	if g.abandoned then
		if occupied~=0 then return false,"AbandonedWithMembers"end
	elseif masters~=1 then return false,"MasterRequired"end
	local invites=0
	for token,offer in pairs(g.invites)do
		invites+=1
		if type(token)~="string"or #token==0 or #token>96 or type(offer)~="table"or not user(offer.target)or not user(offer.inviter)or not timestamp(offer.expiresAt)then return false,"InvalidInvite"end
	end
	if invites>100 then return false,"InviteLimit"end
	local transfer=g.transfer
	if transfer~=nil then
		if type(transfer)~="table"or type(transfer.token)~="string"or #transfer.token==0 or #transfer.token>96 or not user(transfer.target)or transfer.from~=g.leader or transfer.epoch~=g.leaderEpoch or not timestamp(transfer.expiresAt)then return false,"InvalidTransfer"end
		local target=g.members[transfer.target]
		if not target or target.state~="Active"or transfer.target==g.leader then return false,"InvalidRecipient"end
	end
	return true,"Valid"
end
-- Logical keys are internal identities, not raw DataStore keys. A future adapter
-- must encode/hash them to bounded platform keys and validate the stored identity.
function Schema.operation(o:any,key:string?):(boolean,string)
	if type(o)~="table"or not id(o.id)or not id(o.guildId)then return false,"InvalidOperation"end
	local expected:string
	if o.state=="Removing"or o.state=="Removed"then
		if not user(o.actorId)or not user(o.targetId)or not integer(o.actorGeneration,1,2147483647)or not integer(o.targetGeneration,1,2147483647)then return false,"InvalidRemoval"end
		expected="remove:"..tostring(#o.guildId)..":"..o.guildId..":"..o.id
	else
		if not user(o.userId)or not integer(o.generation,1,2147483647)then return false,"InvalidOperationOwner"end
		if o.state=="Creating"or o.state=="Created"then
			if not integer(o.capacity,2,50)then return false,"InvalidCapacity"end
		elseif o.state=="Joining"or o.state=="Completed"or o.state=="Cancelling"or o.state=="Cancelled"then
			if type(o.token)~="string"or #o.token<1 or #o.token>96 then return false,"InvalidInvitation"end
		else return false,"InvalidOperationState"end
		expected=o.userId..":"..o.id
	end
	if key~=nil and key~=expected then return false,"OperationKeyMismatch"end
	return true,"Valid"
end
return Schema
