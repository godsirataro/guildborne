--!strict
-- Visual/input fixture only. Temporary eligibility, no profile writes or rewards.
return function():any
 assert(game:GetService("RunService"):IsStudio()and game.PlaceId==0 and game.GameId==0)
 local server=game.ServerScriptService.Server
 assert(require(server.Config.Runtime).StudioPersistence=="Memory")
 local player=assert(game.Players:GetPlayers()[1]);assert(not workspace:FindFirstChild("NoviceTrial_"..player.UserId))
 local eligible={progression={novice={claimed=3,objectives={}}},character={level=7},party={adventurerIds={}},quests={},expansion={tower={}},settings={language="th"}}
 local options=require(server.Services.NoviceLessonFactory)("defeat_keeper")
 local api:any=nil
 api=require(server.Services.NoviceTrialArena)(player,eligible,"Warrior",game:GetService("HttpService"):GenerateGUID(false),Vector3.new(0,25,2500),function(receipt:any):boolean
  api.model:SetAttribute("FixtureReceipt",receipt.args.objective);return true
 end,nil,options)
 api.model:SetAttribute("FixtureOnly",true)
 return {fixture=true,profileWrites=0,position=tostring(player.Character:GetPivot().Position)}
end
