--!strict
-- Temporary human membership only. NPC teams and personal Guild ownership stay separate.
return function(ui:any)
 local confirmation:string?=nil
 local previousRevision:number?=nil
 return function(snapshot:any,busy:boolean)
  local state=snapshot and snapshot.humanParty
  local function T(key:string,values:any?):string return ui.T(key,values)end
  local header=ui.card(ui.scroll,"Human Party");header.Name="HumanPartyPanel"
  ui.button(header,"Back to Guild",not busy,function()ui.navigate("Guild")end)
  ui.button(header,"Manage my NPC heroes",not busy,function()ui.navigate("Party")end)
  if not state or not state.available then ui.text(header,"Human parties are unavailable here. Please try again later.",16);return end
  if previousRevision~=state.revision then confirmation=nil;previousRevision=state.revision end
  local connected=not busy and snapshot.status=="Active"
  local recovery=not busy and (snapshot.status=="Active" or snapshot.status=="Saving" or snapshot.status=="Degraded")
  local leader=state.partyId~=nil and state.leaderUserId==state.localUserId
  local directory:any={}
  for _,entry in ipairs(state.directory or {})do local p:any=entry;directory[p.userId]=p end
  for _,entry in ipairs(state.members or {})do local p:any=entry;directory[p.userId]=p end
  local function identity(parent:any,userId:string)
   local player=directory[userId]
   local name=if player then tostring(player.displayName).." (@"..tostring(player.username)..")" else T("Player")
   local label=ui.text(parent,"",17);label.Text=name;label.RichText=false
  end
  local function send(action:string,args:any)
   args.partyRevision=state.revision;ui.act(action,args)
  end
  local function action(parent:any,label:string,command:string,args:any,enabled:boolean,confirmKey:string?)
   local armed=confirmKey~=nil and confirmation==confirmKey
   local b=ui.button(parent,if armed then T("Confirm: {action}",{action=T(label)})else T(label),enabled,function()
    if confirmKey and not armed then confirmation=confirmKey;ui.render();return end
    confirmation=nil;send(command,args)
   end)
   b.RichText=false;b.Name=command.."_"..tostring(args.targetUserId or args.inviteId or "Self")
  end
  ui.text(header,"This preview supports invitations and party membership. Shared travel and shared combat rewards are not available yet.",15)
  ui.text(header,"Each player keeps their own Guild and up to five NPC heroes. Party leaders cannot change another player's heroes or items.",15)
  if state.partyId then
   ui.text(header,T("Players: {count}/{limit}",{count=#state.members,limit=state.capacity}),18)
   local own:any=nil;for _,entry in ipairs(state.members)do local p:any=entry;if p.userId==state.localUserId then own=p end end
   if own then action(header,if own.ready then "Mark not ready"else "Mark ready","HumanPartySetReady",{ready=not own.ready},connected)end
   ui.text(header,"Ready only signals your party status. It does not accept travel.",14)
   action(header,"Leave party","HumanPartyLeave",{},recovery,"leave")
   if leader then action(header,"Disband party","HumanPartyDisband",{},recovery,"disband")end
  else ui.text(header,"You are playing solo. Invite another player to form a party.",16)end
  if confirmation then ui.button(header,"Cancel",not busy,function()confirmation=nil;ui.render()end)end
  for _,entry in ipairs(state.members or {})do
   local member:any=entry
   local row=ui.card(ui.scroll,if member.userId==state.leaderUserId then "Party leader"else "Party member")
   row.Name="HumanPartyMember_"..member.userId;identity(row,member.userId)
   ui.text(row,T("NPC heroes: {count}",{count=member.heroCount}),15)
   ui.text(row,if member.connectionState=="Reconnecting"then "Reconnecting — place reserved briefly"elseif member.ready then "Ready"else "Not ready",15)
   if leader and member.userId~=state.localUserId then
    action(row,"Make party leader","HumanPartyTransferLeader",{targetUserId=member.userId},connected and member.connectionState=="Connected","leader:"..member.userId)
    action(row,"Remove from party","HumanPartyKick",{targetUserId=member.userId},recovery,"kick:"..member.userId)
   end
  end
  local incoming=ui.card(ui.scroll,"Party invitations");incoming.Name="HumanPartyInvitations"
  if #(state.incomingInvites or {})==0 then ui.text(incoming,"No invitations waiting.",15)end
  for _,entry in ipairs(state.incomingInvites or {})do
   local invite:any=entry;identity(incoming,invite.fromUserId)
   local valid=invite.expiresAt>snapshot.serverTime
   ui.text(incoming,if valid then "Invitation expires shortly. The server checks availability when you accept."else "Invitation expired.",14)
   action(incoming,"Accept invitation","HumanPartyAccept",{inviteId=invite.inviteId},connected and valid and not state.partyId)
   action(incoming,"Decline invitation","HumanPartyDecline",{inviteId=invite.inviteId},recovery and valid)
  end
  local pending:any={}
  for _,entry in ipairs(state.outgoingInvites or {})do local invite:any=entry;if invite.expiresAt>snapshot.serverTime then pending[invite.targetUserId]=true end end
  local available=ui.card(ui.scroll,"Players in this server");available.Name="HumanPartyDirectory"
  local others=0
  for _,entry in ipairs(state.directory or {})do
   local person:any=entry;if person.userId==state.localUserId then continue end
   others+=1;identity(available,person.userId)
   ui.text(available,T("NPC heroes: {count}",{count=person.heroCount}),15)
   local room=not state.partyId or #state.members<state.capacity
   action(available,if pending[person.userId]then "Invitation sent"else "Invite to party","HumanPartyInvite",{targetUserId=person.userId},connected and person.available and room and (not state.partyId or leader) and not pending[person.userId])
  end
  if others==0 then ui.text(available,"No other players are available in this server.",15)end
  if state.partyId and #state.members>=state.capacity then ui.text(available,"Party is full.",15)
  elseif state.partyId and not leader then ui.text(available,"Only the party leader can invite players.",15)end
 end
end
