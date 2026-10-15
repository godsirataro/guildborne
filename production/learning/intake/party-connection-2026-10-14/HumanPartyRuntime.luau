--!strict
-- Same-server adapter. State is read-only; notification never runs during core mutation.
return function(deps:any):any
 local players=deps.Players or game:GetService("Players")
 local makeCore=deps.Core or require(script.Parent.Parent.Systems.HumanParty)
 local core=makeCore({Now=deps.Now or os.time,InviteSeconds=60,GraceSeconds=30})
 local present:any={};local sentRevision=-1;local notifying=false
 local S={}
 local function connected(player:any):boolean return player and players:GetPlayerByUserId(player.UserId)==player end
 local function sync(player:any):any?
  local id=tostring(player.UserId);local previous=present[id]
  local session=deps.Data.Sessions[player.UserId]
  if not connected(player) or not session or (session.state~="Active" and session.state~="Saving" and session.state~="Degraded") or session.closing or not session.record then
   if previous and previous.player==player then core.Remove(id,previous.key);present[id]=nil end
   return nil
  end
  if not previous or previous.player~=player or previous.epoch~=session.epoch or previous.token~=session.token then
   if previous then core.Remove(id,previous.key)end
   previous={player=player,key={},epoch=session.epoch,token=session.token};present[id]=previous
  end
  local ids=session.record.data.party and session.record.data.party.adventurerIds or {}
  core.Add(id,{displayName=player.DisplayName,username=player.Name,heroCount=#ids,eligible=session.state=="Active" and not session.busy},previous.key)
  return previous.key
 end
 local function notify()
  if notifying or core.Revision()==sentRevision then return end
  sentRevision=core.Revision();notifying=true
  for _,player in ipairs(players:GetPlayers())do
   -- The callback may send a projection, but cannot enter a half-mutated core.
   local ok,problem=pcall(deps.Notify,player)
   if not ok and deps.Log then deps.Log("human_party_notify_error",{problem=tostring(problem)})end
  end
  notifying=false
 end
 function S.State(player:any):any
  if deps.Enabled~=true then return {available=false,revision=0,capacity=6,localUserId=tostring(player.UserId),members={},incomingInvites={},outgoingInvites={},directory={}}end
  return core.State(tostring(player.UserId))
 end
 function S.Add(player:any)
  if deps.Enabled~=true then return end
  sync(player);notify()
 end
 function S.Remove(player:any)
  if deps.Enabled~=true then return end
  local id=tostring(player.UserId);local current=present[id]
  if current and current.player==player then core.Remove(id,current.key);present[id]=nil;notify()end
 end
 function S.Step()
  if deps.Enabled~=true then return end
  for _,player in ipairs(players:GetPlayers())do sync(player)end
  local gone={};for id,entry in pairs(present)do if not connected(entry.player)then table.insert(gone,id)end end
  for _,id in ipairs(gone)do local entry=present[id];core.Remove(id,entry.key);present[id]=nil end
  core.Step();notify()
 end
 function S.Intent(player:any,action:string,args:any,requestId:string):string
  if deps.Enabled~=true or not connected(player) then return "HumanPartyUnavailable"end
  local key=sync(player)
  if not key then notify();return "HumanPartyUnavailable"end
  if type(args)=="table" and args.targetUserId~=nil then
   if not core.ValidUserId(args.targetUserId) then return "InvalidRequest"end
   if action=="HumanPartyInvite" or action=="HumanPartyTransferLeader" then
    local target=players:GetPlayerByUserId(tonumber(args.targetUserId))
    if not target or not sync(target) then notify();return "HumanPartyUnavailable"end
   end
  end
  local code=core.Intent(tostring(player.UserId),key,action,args,requestId)
  notify();return code
 end
 return S
end
