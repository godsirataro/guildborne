assert(game.PlaceId==0 and game.GameId==0)
local remotes=game.ReplicatedStorage.GuildborneRemotes
local replies={}
local connection=remotes.State.OnClientEvent:Connect(function(v)if v.requestId then replies[v.requestId]=v end end)
local function send(p)
 replies[p.requestId]=nil;remotes.Command:FireServer(p)
 local deadline=os.clock()+5;while not replies[p.requestId] and os.clock()<deadline do task.wait(.05)end
 return assert(replies[p.requestId],"No response")
end
local ok,result=pcall(function()
 local before=send({version=1,requestId="disband-read",revision=0,action="GetState",args={}})
 assert(#before.humanParty.members==6)
 local packet={version=1,requestId="repeat-real-disband",revision=before.revision,action="HumanPartyDisband",args={partyRevision=before.humanParty.revision}}
 local first=send(packet);local again=send(packet)
 assert(first.code=="OK" and again.code=="OK")
 assert(#first.humanParty.members==0 and #again.humanParty.members==0)
 assert(first.revision==before.revision and again.revision==before.revision)
 return {first=first.code,replay=again.code,profileRevision=again.revision,partyRevisionFirst=first.humanParty.revision,partyRevisionReplay=again.humanParty.revision,solo=true}
end)
connection:Disconnect();assert(ok,tostring(result));return game.HttpService:JSONEncode(result)
