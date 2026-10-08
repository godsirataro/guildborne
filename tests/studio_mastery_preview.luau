--!strict
-- Isolated temporary eligibility only. No saved-profile mutations or awards.
return function(pathId:string,language:string?):any
 assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0)
 local server=game.ServerScriptService.Server
 assert(require(server.Config.Runtime).StudioPersistence=="Memory")
 local player=assert(game.Players:GetPlayers()[1]);assert(not workspace:FindFirstChild("NoviceTrial_"..player.UserId))
 local util=require(game.ReplicatedStorage.Shared.Util.TableUtil)
 local path=assert(require(game.ReplicatedStorage.Shared.Data.Expansion).Paths[pathId])
 local eligible={progression={campaign={claimed=24,objectives={meet_crosshaven_mentor=true}}},character={classId=path.Class,level=70},personalGuild={buildings={guildHall=11}},party={adventurerIds={}},quests={},expansion={tower={}},settings={language=language or "en"}}
 local before=util.copy(eligible);local options=require(server.Services.BorrowedPathFactory)(pathId,true)
 local api:any=nil;local count=0
 api=require(server.Services.NoviceTrialArena)(player,eligible,path.Class,game:GetService("HttpService"):GenerateGUID(false),Vector3.new(0,25,2500),function(receipt:any):boolean
  assert(receipt.action=="CampaignObjective"and receipt.args.objective=="complete_borrowed_mastery")
  assert(util.equal(eligible,before));count+=1;api.model:SetAttribute("FixtureReceiptCount",count);return true
 end,nil,options)
 api.model:SetAttribute("FixtureOnly",true);api.model:SetAttribute("FixturePath",pathId)
 local read=Instance.new("BindableFunction");read.Name="FixtureSnapshot";read.OnInvoke=function()assert(util.equal(eligible,before));return api.Snapshot()end;read.Parent=api.model
 local clean=Instance.new("BindableFunction");clean.Name="FixtureCleanup";clean.OnInvoke=function()api.Destroy();assert(util.equal(eligible,before));return true end;clean.Parent=api.model
 return {path=pathId,profileWrites=0,eligibility="temporary fixture",ability=api.model:GetAttribute("AbilityLabel"),goals=api.model:GetAttribute("DisplayGoals"),health=api.model:GetAttribute("DisplayHealth")}
end
