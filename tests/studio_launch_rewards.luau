-- Client-side network smoke; local unpublished Memory candidate only.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0)
local remotes=game.ReplicatedStorage:WaitForChild("GuildborneRemotes")
local revision=0;local rows={};local latest=nil
local function send(action,args)
 local id="launch-"..game:GetService("HttpService"):GenerateGUID(false)
 local response=nil
 local connection=remotes.State.OnClientEvent:Connect(function(v)if v.requestId==id then response=v end end)
 remotes.Command:FireServer({version=1,requestId=id,revision=revision,action=action,args=args or {}})
 local untilAt=os.clock()+10;repeat task.wait(.1)until response or os.clock()>untilAt
 connection:Disconnect();assert(response,"Request timed out: "..action)
 revision=response.revision;latest=response
 table.insert(rows,{action=action,code=response.code or response.resultCode,status=response.status,revision=revision})
 task.wait(.35)
 return response
end
local initial=send("GetState")
assert(initial.catalog.ReleaseContent.MaxLevel==35 and #initial.catalog.CampaignChapter.Chapters==12)
assert(initial.data.launchRewards.daily.claimable,"Use a fresh Memory play session")
local herbs=initial.data.inventory.stacks.herb or 0
local first=send("ClaimDailyReward")
assert(first.data.inventory.stacks.herb==herbs+2 and first.data.launchRewards.daily.claims==1)
local repeatClaim=send("ClaimDailyReward")
assert(repeatClaim.data.inventory.stacks.herb==herbs+2 and repeatClaim.data.launchRewards.daily.claims==1)
send("ClaimSeasonReward",{seasonId="launch_preview_01",tier=1,track="free"})
assert(latest.data.inventory.stacks.herb==herbs+2)
send("ClaimSeasonReward",{seasonId="launch_preview_01",tier=1,track="premium"})
assert(latest.data.inventory.stacks.herb==herbs+2 and not latest.data.launchRewards.premiumAvailable)
send("SetLanguage",{language="th"});assert(latest.data.language=="th")
return {kind="Studio Memory network smoke",requests=rows,herbs=latest.data.inventory.stacks.herb,dailyClaims=latest.data.launchRewards.daily.claims,level=latest.data.character.level,chapters=#latest.catalog.CampaignChapter.Chapters,publicAcceptance=false}
