--!strict
-- Temporary human membership only. No profile, combat or reward authority.
return function(deps:any):any
 local now=deps.Now
 local inviteSeconds=deps.InviteSeconds or 60
 local graceSeconds=deps.GraceSeconds or 30
 local users:any={};local parties:any={};local invites:any={}
 local revision=0;local serial=0
 local S={}
 local function copy(t:any):any
  if type(t)~="table" then return t end
  local out={};for k,v in pairs(t)do out[k]=copy(v)end;return out
 end
 local function bump()revision+=1 end
 local function nextId(prefix:string):string serial+=1;return prefix..tostring(serial)end
 function S.ValidUserId(id:any):boolean
  if type(id)~="string" or #id>17 or not id:match("^%-?%d+$")then return false end
  local value=tonumber(id)
  return value~=nil and value~=0 and value%1==0 and math.abs(value)<=9007199254740991 and tostring(value)==id
 end
 local function eraseInvites(partyId:string?,userId:string?)
  for id,invite in pairs(invites)do
   if (partyId and invite.partyId==partyId) or (userId and (invite.fromUserId==userId or invite.targetUserId==userId)) then invites[id]=nil end
  end
 end
 local function resetReady(p:any)for _,id in ipairs(p.members)do users[id].ready=false end end
 local function removeMember(id:string)
  local user=users[id];local p=user and user.partyId and parties[user.partyId]
  if not p then return end
  eraseInvites(p.id,nil);user.partyId=nil;user.ready=false
  local index=table.find(p.members,id);if index then table.remove(p.members,index)end
  if #p.members==0 then parties[p.id]=nil;return end
  if p.leaderUserId==id then
   p.leaderUserId=p.members[1]
   for _,other in ipairs(p.members)do if users[other].connected then p.leaderUserId=other;break end end
  end
  resetReady(p)
 end
 function S.Step()
  local changed=false;local at=now()
  for id,invite in pairs(invites)do if at>=invite.expiresAt then invites[id]=nil;changed=true end end
  local expired={};for id,user in pairs(users)do if not user.connected and at>=user.untilAt then table.insert(expired,id)end end
  table.sort(expired)
  for _,id in ipairs(expired)do removeMember(id);eraseInvites(nil,id);users[id]=nil;changed=true end
  if changed then bump()end
 end
 function S.Add(id:string,identity:any,session:any):boolean
  if not S.ValidUserId(id) or session==nil then return false end
  S.Step()
  local user=users[id]
  if not user then user={ready=false,requests={},requestOrder={}};users[id]=user end
  if user.session~=nil and user.session~=session then user.requests={};user.requestOrder={} end
  local eligible=identity.eligible~=false
  local changed=user.eligible~=eligible or not user.connected or user.session~=session or user.displayName~=identity.displayName or user.username~=identity.username or user.heroCount~=identity.heroCount
  user.connected=true;user.untilAt=nil;user.session=session;user.eligible=eligible
  user.displayName=identity.displayName;user.username=identity.username;user.heroCount=identity.heroCount
  if changed then bump()end
  return true
 end
 function S.Remove(id:string,session:any)
  local user=users[id];if not user or not user.connected or user.session~=session then return end
  user.connected=false;user.untilAt=now()+graceSeconds;user.ready=false
  eraseInvites(nil,id)
  local p=user.partyId and parties[user.partyId]
  if p then
   resetReady(p)
   if p.leaderUserId==id then
    for _,other in ipairs(p.members)do if users[other].connected then p.leaderUserId=other;eraseInvites(p.id,nil);break end end
   end
  end
  bump()
 end
 function S.Revision():number return revision end
 function S.State(id:string):any
  local user=users[id];local p=user and user.partyId and parties[user.partyId]
  local state:any={available=user~=nil and user.connected==true,revision=revision,capacity=6,localUserId=id,members={},incomingInvites={},outgoingInvites={},directory={}}
  local function member(otherId:string):any
   local other=users[otherId]
   return {userId=otherId,displayName=other.displayName,username=other.username,heroCount=other.heroCount,connectionState=if other.connected then "Connected" else "Reconnecting",ready=other.ready==true}
  end
  if p then
   state.partyId=p.id;state.leaderUserId=p.leaderUserId
   for _,otherId in ipairs(p.members)do table.insert(state.members,member(otherId))end
  end
  for _,invite in pairs(invites)do
   if invite.targetUserId==id then table.insert(state.incomingInvites,copy(invite))end
   if invite.fromUserId==id then table.insert(state.outgoingInvites,copy(invite))end
  end
  for otherId,other in pairs(users)do if other.connected and otherId~=id then
   local row=member(otherId);row.ready=nil;row.connectionState=nil;row.available=other.partyId==nil and other.eligible
   table.insert(state.directory,row)
  end end
  for _,rows in ipairs({state.incomingInvites,state.outgoingInvites})do table.sort(rows,function(a:any,b:any)return a.inviteId<b.inviteId end)end
  table.sort(state.directory,function(a:any,b:any)return a.userId<b.userId end)
  return state
 end
 local actions={HumanPartyInvite=true,HumanPartyAccept=true,HumanPartyDecline=true,HumanPartyLeave=true,HumanPartyDisband=true,HumanPartyKick=true,HumanPartyTransferLeader=true,HumanPartySetReady=true}
 local function perform(id:string,action:string,args:any):string
  local user=users[id];local p=user.partyId and parties[user.partyId]
  if action=="HumanPartyInvite" then
   local target=users[args.targetUserId]
   if args.targetUserId==id or not target or not target.connected or not target.eligible then return "HumanPartyUnavailable"end
   if p and p.leaderUserId~=id then return "HumanPartyLeaderRequired"end
   if target.partyId then return "HumanPartyAlreadyMember"end
   if p and #p.members>=6 then return "HumanPartyFull"end
   local outgoing,incoming=0,0
   for _,invite in pairs(invites)do
    if invite.fromUserId==id then outgoing+=1;if invite.targetUserId==args.targetUserId then return "HumanPartyInvitePending"end end
    if invite.targetUserId==args.targetUserId then incoming+=1 end
   end
   if outgoing>=6 or incoming>=6 then return "HumanPartyInviteLimit"end
   if not p then local pid=nextId("party:");p={id=pid,leaderUserId=id,members={id}};parties[pid]=p;user.partyId=pid end
   local iid=nextId("invite:")
   invites[iid]={inviteId=iid,fromUserId=id,targetUserId=args.targetUserId,partyId=p.id,expiresAt=now()+inviteSeconds}
   return "OK"
  elseif action=="HumanPartyAccept" or action=="HumanPartyDecline" then
   local invite=invites[args.inviteId]
   if not invite or invite.targetUserId~=id then return "HumanPartyInviteExpired"end
   if action=="HumanPartyDecline"then invites[args.inviteId]=nil;return "OK"end
   if user.partyId then return "HumanPartyAlreadyMember"end
   local targetParty=parties[invite.partyId]
   if not targetParty or targetParty.leaderUserId~=invite.fromUserId or not users[invite.fromUserId].connected then return "HumanPartyInviteExpired"end
   if #targetParty.members>=6 then return "HumanPartyFull"end
   user.partyId=targetParty.id;table.insert(targetParty.members,id);resetReady(targetParty)
   -- Other outstanding invitations stay valid, but the revision fence rechecks capacity.
   eraseInvites(nil,id)
   return "OK"
  end
  if not p then return "HumanPartyNotMember"end
  if action=="HumanPartyLeave"then removeMember(id);eraseInvites(nil,id);return "OK"end
  if action=="HumanPartySetReady"then user.ready=args.ready;return "OK"end
  if p.leaderUserId~=id then return "HumanPartyLeaderRequired"end
  if action=="HumanPartyDisband"then
   eraseInvites(p.id,nil)
   for _,other in ipairs(p.members)do users[other].partyId=nil;users[other].ready=false end
   parties[p.id]=nil;return "OK"
  end
  local target=users[args.targetUserId]
  if args.targetUserId==id or not target or target.partyId~=p.id then return "HumanPartyNotMember"end
  if action=="HumanPartyKick"then removeMember(args.targetUserId);return "OK"end
  if not target.connected or not target.eligible then return "HumanPartyUnavailable"end
  p.leaderUserId=args.targetUserId;eraseInvites(p.id,nil);resetReady(p);return "OK"
 end
 function S.Intent(id:string,session:any,action:string,args:any,requestId:string):string
  S.Step()
  local user=users[id]
  if not user or not user.connected or user.session~=session then return "HumanPartyUnavailable"end
  if not actions[action] or type(args)~="table" or type(requestId)~="string" or #requestId<1 or #requestId>64 then return "InvalidRequest"end
  local fields={partyRevision=true}
  if action=="HumanPartyInvite" or action=="HumanPartyKick" or action=="HumanPartyTransferLeader"then fields.targetUserId=true;if not S.ValidUserId(args.targetUserId)then return "InvalidRequest"end
  elseif action=="HumanPartyAccept" or action=="HumanPartyDecline"then fields.inviteId=true;if type(args.inviteId)~="string" or #args.inviteId>64 then return "InvalidRequest"end
  elseif action=="HumanPartySetReady"then fields.ready=true;if type(args.ready)~="boolean"then return "InvalidRequest"end end
  for key in pairs(args)do if not fields[key]then return "InvalidRequest"end end
  if type(args.partyRevision)~="number" or args.partyRevision%1~=0 or args.partyRevision<0 or args.partyRevision>1000000000 then return "InvalidRequest"end
  local fingerprint=action..":"..tostring(args.partyRevision)..":"..tostring(args.targetUserId or args.inviteId or args.ready)
  local prior=user.requests[requestId]
  if prior then return if prior.fingerprint==fingerprint then prior.code else "InvalidRequest"end
  local recovery={HumanPartyLeave=true,HumanPartyDecline=true,HumanPartyDisband=true,HumanPartyKick=true}
  local code=if args.partyRevision~=revision then "HumanPartyStale" elseif not user.eligible and not recovery[action] then "HumanPartyUnavailable" else perform(id,action,args)
  if code=="OK"then bump()end
  user.requests[requestId]={fingerprint=fingerprint,code=code};table.insert(user.requestOrder,requestId)
  if #user.requestOrder>64 then user.requests[table.remove(user.requestOrder,1)]=nil end
  return code
 end
 return S
end
