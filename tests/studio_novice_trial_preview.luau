--!strict
-- Standalone temporary eligibility fixture, not the player's saved profile.
-- Use real F/Q prompt inputs and avatar movement; never inject combat outcomes.
return function(classId:string,failDeliveries:number?):any
 assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0)
 assert(require(game.ServerScriptService.Server.Config.Runtime).StudioPersistence=="Memory")
 local player=assert(game.Players:GetPlayers()[1]);assert(not workspace:FindFirstChild("NoviceTrial_"..player.UserId))
 local eligible={progression={novice={claimed=5}},character={level=10},party={adventurerIds={}},quests={},expansion={tower={}},settings={language="en"}}
 local api:any=nil;local attempts=0;local accepted=0
 api=require(game.ServerScriptService.Server.Services.NoviceTrialArena)(player,eligible,classId,game:GetService("HttpService"):GenerateGUID(false),Vector3.new(0,25,2500),function(receipt:any,_snapshot:any):boolean
  attempts+=1;api.model:SetAttribute("FixtureDeliveryAttempts",attempts)
  if attempts<=(failDeliveries or 0)then return false end
  accepted+=1;api.model:SetAttribute("FixtureReceiptCount",accepted);api.model:SetAttribute("FixtureReceiptClass",receipt.args.classId);return true
 end)
 api.model:SetAttribute("FixtureOnly",true)
 local read=Instance.new("BindableFunction");read.Name="FixtureSnapshot";read.OnInvoke=function()return api.Snapshot()end;read.Parent=api.model
 local clean=Instance.new("BindableFunction");clean.Name="FixtureCleanup";clean.OnInvoke=function()api.Destroy();return true end;clean.Parent=api.model
 return {class=classId,profileWrites=0,eligibility="temporary fixture",position=tostring(player.Character:GetPivot().Position)}
end
