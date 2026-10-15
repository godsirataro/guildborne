-- Server-side local Studio fixture; real Network module with fake dependencies.
-- No profile writes, actual Party mutations, travel or reward requests.
assert(game.PlaceId==0 and game.GameId==0)
local players=game:GetService("Players")
local player=assert(players:GetPlayers()[1],"One local client required")
local rs=game:GetService("ReplicatedStorage")
local before={};for _,x in rs:GetChildren()do before[x]=true end
local counts={intent=0,execute=0,spatial=0,novice=0,committed=0,audit=0,errors=0}
local profile={state="Active",record={revision=7,data={}}}
local fail=false
local deps={Mode="FIXTURE",Protocol=require(rs.Shared.Network.Protocol),
 Data={Sessions={[player.UserId]=profile},Execute=function()counts.execute+=1;error("No profile writes")end,
 FlushAudit=function()counts.audit+=1 end},
 Project=function()return {revision=7,status="Active"}end,
 Content={NoviceActionProblem=function()counts.novice+=1;return "NoviceGateFixture"end},
 World={Update=function()end,ValidateIntent=function()counts.spatial+=1;return "SpatialFixture"end,
 IntentCommitted=function()counts.committed+=1 end},
 Log=function()counts.errors+=1 end,
 HumanParty={State=function()return {available=true,revision=1,capacity=6}end,
 Intent=function(_,action,args,requestId)
  counts.intent+=1;assert(action:sub(1,10)=="HumanParty" and args.partyRevision==1 and type(requestId)=="string")
  if fail then error("Injected Party failure")end
  return "OK"
 end}}
local folder
local ok,result=pcall(function()
 local network=require(game.ServerScriptService.Server.Services.NetworkService)(deps)
 for _,x in rs:GetChildren()do if not before[x] and x.Name=="GuildborneRemotes" then folder=x end end
 assert(folder);folder.Name="HumanPartyNetworkFixture"
 local actions={
  HumanPartyInvite={targetUserId="200"},HumanPartyAccept={inviteId="fixture"},HumanPartyDecline={inviteId="fixture"},
  HumanPartyLeave={},HumanPartyDisband={},HumanPartyKick={targetUserId="200"},HumanPartyTransferLeader={targetUserId="200"},HumanPartySetReady={ready=true}}
 for action,args in pairs(actions)do args.partyRevision=1;network.Intent(player,action,args);network.Remove(player)end
 assert(counts.intent==8 and counts.novice==0 and counts.spatial==0)
 network.Intent(player,"HumanPartyLeave",{partyRevision=-1})
 assert(counts.intent==8,"Invalid wire reached runtime")
 fail=true;network.Intent(player,"HumanPartyLeave",{partyRevision=1})
 assert(counts.errors==1 and profile.state=="Active","Social failure damaged profile session")
 network.Intent(player,"TravelZone",{zone="Guild"})
 assert(counts.novice==1,"Social branch bypassed ordinary progression gate")
 assert(counts.execute==0 and counts.committed==0 and counts.audit==0)
 network.Remove(player)
 return {synthetic=true,noProfileWrites=true,counts=counts,profileRevision=profile.record.revision}
end)
if folder then folder:Destroy()end
assert(ok,tostring(result));return result
