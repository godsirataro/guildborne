-- Injected test prelude supplies local action, arguments, requestId. Uses real client remotes only.
assert(game.PlaceId==0 and game.GameId==0)
local remotes=game.ReplicatedStorage.GuildborneRemotes
local responses={}
local c=remotes.State.OnClientEvent:Connect(function(v) if v.requestId then responses[v.requestId]=v end end)
local function call(action,args,revision,id)
 remotes.Command:FireServer({version=1,requestId=id,revision=revision,action=action,args=args})
 local untilAt=os.clock()+5
 while not responses[id] and os.clock()<untilAt do task.wait(.05) end
 return assert(responses[id],"Timed out "..id)
end
local ok,result=pcall(function()
 local before=call("GetState",{},0,requestId.."-read")
 local args=arguments
 if action=="HumanPartyAccept" and not args.inviteId then args.inviteId=assert(before.humanParty.incomingInvites[1],"No invite").inviteId end
 if action~="GetState" then args.partyRevision=args.partyRevision or before.humanParty.revision end
 local after=if action=="GetState" then before else call(action,args,before.revision,requestId)
 return {userId=game.Players.LocalPlayer.UserId,status=after.status,code=after.code,profileRevisionBefore=before.revision,profileRevisionAfter=after.revision,humanParty=after.humanParty}
end)
c:Disconnect();assert(ok,tostring(result));return game.HttpService:JSONEncode(result)
