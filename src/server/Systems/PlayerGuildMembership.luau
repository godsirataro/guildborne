--!strict
-- Staged record transitions. Caller supplies atomic per-record revision/lease writes.
-- Proofs are trusted server record reads, never client payloads. No live adapter yet.
local M={}
local function id(v:any):boolean return type(v)=="string"and #v>0 and #v<=64 and v:match("^[%w_:%-]+$")~=nil end
local function user(v:any):boolean return type(v)=="string"and v:match("^[1-9]%d*$")~=nil and #v<=16 and (tonumber(v)or math.huge)<=9007199254740991 end
local function finite(v:any):boolean return type(v)=="number"and v==v and v>=0 and v<1e12 end
local ranks={Master=4,Officer=3,Commander=2,Member=1}
local function active(g:any,u:string):any local m=g.members[u];return if m and m.state=="Active"then m else nil end
local function invitePower(g:any,u:string):boolean local m=active(g,u);return m~=nil and (m.role=="Master"or m.role=="Officer")end
local function count(g:any):number local n=0;for _,m in pairs(g.members)do if m.state~="Revoked"then n+=1 end end;return n end
function M.newSlot():any return {generation=0,state="Empty"}end
function M.reserve(slot:any,guildId:string,operationId:string):(boolean,string)
 if not id(guildId)or not id(operationId)then return false,"InvalidOperation"end
 if slot.state~="Empty"then
  return if slot.guildId==guildId and slot.operationId==operationId then true else false,if slot.guildId==guildId and slot.operationId==operationId then "AlreadyReserved"else "MembershipOccupied"
 end
 if slot.generation>=2147483647 then return false,"GenerationExhausted"end
 slot.generation+=1;slot.state="Reserved";slot.guildId=guildId;slot.operationId=operationId;return true,"Reserved"
end
function M.newGuild(guildId:string,founder:string,slot:any,capacity:number?):any
 assert(id(guildId)and user(founder)and slot.state=="Reserved"and slot.guildId==guildId,"FounderReservationRequired")
 local cap=capacity or 50;assert(cap%1==0 and cap>=2 and cap<=50,"InvalidCapacity")
 return {version=1,id=guildId,capacity=cap,leader=founder,leaderEpoch=1,nextInvite=1,nextTransfer=1,fences={[founder]=slot.generation},members={[founder]={state="Pending",role="Master",operationId=slot.operationId,generation=slot.generation}},invites={}}
end
function M.invite(g:any,actor:string,target:string,now:number,ttl:number):(any?,string)
 if not user(target)or not finite(now)or not finite(ttl)or ttl<1 or ttl>86400 then return nil,"InvalidInvite"end
 if not invitePower(g,actor)then return nil,"PermissionDenied"end
 if g.nextInvite>=2147483647 then return nil,"CounterExhausted"end
 if g.members[target]then return nil,"AlreadyMember"end
 if count(g)>=g.capacity then return nil,"GuildFull"end
 for key,v in pairs(g.invites)do if v.expiresAt<=now then g.invites[key]=nil end end
 local pending=0;for _ in pairs(g.invites)do pending+=1 end
 if pending>=100 then return nil,"InviteLimit"end
 local token=g.id..":invite:"..g.nextInvite;g.nextInvite+=1
 g.invites[token]={target=target,inviter=actor,expiresAt=now+ttl}
 return {guildId=g.id,token=token,target=target,expiresAt=now+ttl},"Invited"
end
function M.prepareJoin(g:any,target:string,token:string,slot:any,now:number):(boolean,string)
 if not user(target)or slot.guildId~=g.id then return false,"ReservationRequired"end
 local existing=g.members[target]
 if existing then
  if existing.state=="Revoked"then return false,"MembershipRevoked"end
  return existing.operationId==slot.operationId and existing.generation==slot.generation,if existing.operationId==slot.operationId and existing.generation==slot.generation then "AlreadyPrepared"else "AlreadyMember"
 end
 if not finite(now)or slot.state~="Reserved"or slot.guildId~=g.id or not id(slot.operationId)then return false,"ReservationRequired"end
 if slot.generation<=(g.fences[target]or 0)then return false,"StaleMembership"end
 local invite=g.invites[token]
 if not invite or invite.target~=target or now>=invite.expiresAt then return false,"InviteExpired"end
 if not invitePower(g,invite.inviter)then return false,"InvitationRevoked"end
 if count(g)>=g.capacity then return false,"GuildFull"end
 g.members[target]={state="Pending",role="Member",operationId=slot.operationId,generation=slot.generation};g.fences[target]=slot.generation;g.invites[token]=nil
 return true,"Prepared"
end
function M.activateSlot(slot:any,g:any,u:string):(boolean,string)
 local member=g.members[u]
 if not member or slot.guildId~=g.id or member.operationId~=slot.operationId or member.generation~=slot.generation then return false,"MembershipMismatch"end
 if member.state~="Pending"and member.state~="Active"then return false,"MembershipRevoked"end
 if slot.state=="Active"then return true,"AlreadyActive"end
 if slot.state~="Reserved"then return false,"ReservationRequired"end
 slot.state="Active";return true,"Activated"
end
function M.activateMember(g:any,u:string,slot:any):(boolean,string)
 local member=g.members[u]
 if not member or slot.state~="Active"or slot.guildId~=g.id or member.operationId~=slot.operationId or member.generation~=slot.generation then return false,"MembershipMismatch"end
 if member.state=="Active"then return true,"AlreadyActive"end
 if member.state~="Pending"then return false,"MembershipRevoked"end
 member.state="Active";return true,"Activated"
end
function M.can(g:any,u:string,capability:string):boolean
 local m=active(g,u);if not m then return false end
 if capability=="Participate"or capability=="View"then return true end
 if capability=="Invite"then return m.role=="Master"or m.role=="Officer"end
 if capability=="Command"then return m.role=="Master"or m.role=="Commander"end
 if capability=="AssignRoles"or capability=="Transfer"then return m.role=="Master"end
 return false
end
function M.setRole(g:any,actor:string,target:string,role:string):(boolean,string)
 if not M.can(g,actor,"AssignRoles")then return false,"PermissionDenied"end
 local member=active(g,target)
 if not member or target==g.leader or role=="Master"or not ranks[role]then return false,"InvalidRoleChange"end
 member.role=role;return true,"RoleChanged"
end
function M.revoke(g:any,actor:string,target:string,operationId:string):(boolean,string)
 if not id(operationId)then return false,"InvalidOperation"end
 local member=g.members[target];if not member then return false,"NotMember"end
 if member.state=="Revoked"then return member.revokeOperation==operationId,if member.revokeOperation==operationId then "AlreadyRevoked"else "MembershipRevoked"end
 if target==g.leader then return false,"TransferLeadershipFirst"end
 if actor~=target then
  local who=active(g,actor)
  if not who or not invitePower(g,actor)or ranks[who.role]<=ranks[member.role]then return false,"PermissionDenied"end
 end
 member.state="Revoked";member.revokeOperation=operationId
 if g.transfer and g.transfer.target==target then g.transfer=nil end
 return true,"Revoked"
end
function M.clearSlot(slot:any,g:any,u:string):(boolean,string)
 local member=g.members[u]
 if not member or member.state~="Revoked"or member.operationId~=slot.operationId or member.generation~=slot.generation or slot.guildId~=g.id then return false,"RevocationRequired"end
 slot.state="Empty";slot.guildId=nil;slot.operationId=nil;return true,"Cleared"
end
function M.abortJoin(g:any,u:string,slot:any,operationId:string):(boolean,string)
 if not id(operationId)then return false,"InvalidOperation"end
 local member=g.members[u]
 if not member and user(u)and slot.state=="Reserved"and slot.guildId==g.id and slot.generation>(g.fences[u]or 0)then
  member={state="Pending",role="Member",operationId=slot.operationId,generation=slot.generation}
  g.members[u]=member;g.fences[u]=slot.generation
 end
 if not member or member.state~="Pending"or slot.guildId~=g.id or member.operationId~=slot.operationId or member.generation~=slot.generation then return false,"PendingJoinRequired"end
 member.state="Revoked";member.revokeOperation=operationId
 for token,invite in pairs(g.invites)do if invite.target==u then g.invites[token]=nil end end
 if u==g.leader then g.abandoned=true end
 return true,"JoinAborted"
end
function M.finishRemoval(g:any,u:string,slot:any):(boolean,string)
 local member=g.members[u]
 if not member then return true,"AlreadyRemoved"end
 if member.state~="Revoked"then return false,"RevocationRequired"end
 -- A newer reservation also proves the old membership slot was released.
 if slot.generation<member.generation or (slot.generation==member.generation and slot.state~="Empty")then return false,"SlotStillOccupied"end
 g.members[u]=nil;return true,"Removed"
end
function M.offerTransfer(g:any,actor:string,target:string,now:number):(any?,string)
 if not finite(now)or not M.can(g,actor,"Transfer")or actor~=g.leader then return nil,"PermissionDenied"end
 if target==actor or not active(g,target)then return nil,"RecipientRequired"end
 if g.nextTransfer>=2147483647 or g.leaderEpoch>=2147483647 then return nil,"CounterExhausted"end
 local token=g.id..":transfer:"..g.nextTransfer;g.nextTransfer+=1
 g.transfer={token=token,from=actor,target=target,epoch=g.leaderEpoch,expiresAt=now+300}
 return table.clone(g.transfer),"Offered"
end
function M.acceptTransfer(g:any,actor:string,token:string,now:number):(boolean,string)
 local offer=g.transfer
 if not finite(now)or not offer or offer.token~=token or offer.target~=actor or offer.epoch~=g.leaderEpoch or offer.from~=g.leader or now>=offer.expiresAt then return false,"TransferUnavailable"end
 if g.leaderEpoch>=2147483647 then return false,"CounterExhausted"end
 local old,new=active(g,g.leader),active(g,actor);if not old or not new then return false,"RecipientRequired"end
 old.role="Officer";new.role="Master";g.leader=actor;g.leaderEpoch+=1;g.transfer=nil;return true,"Transferred"
end
return M
