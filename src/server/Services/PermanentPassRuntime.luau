--!strict
-- No platform calls/listeners while disabled or the catalog contains only zero IDs.
return function(deps:any)
 local S={Joined=function(_player:Player)end,Request=function(_player:Player,_packet:any):string return "PurchaseUnavailable" end,Remove=function(_player:Player)end}
 if deps.Enabled~=true or #deps.Catalog.Order==0 then return S end
 local players=game:GetService("Players")
 local market=game:GetService("MarketplaceService")
 local prompt=require(script.Parent.PermanentPassPrompt)({Enabled=true,Data=deps.Data,Offers=deps.Offers,Now=os.time,Clock=os.clock,LeaseSafetySeconds=deps.LeaseSafetySeconds,
  Owns=function(userId:number,passId:number):boolean return market:UserOwnsGamePassAsync(userId,passId) end,
  Spatial=function(userId:number):string?local player=players:GetPlayerByUserId(userId);if not player then return "Closing" end;return deps.World.ValidateIntent(player,"RequestPermanentPass",{}) end,
  Prompt=function(userId:number,passId:number)local player=assert(players:GetPlayerByUserId(userId));market:PromptGamePassPurchase(player,passId)end})
 S.Request=function(player:Player,packet:any):string return prompt.Request(player.UserId,packet.revision,packet.args.kind,packet.args.key)end
 S.Remove=function(player:Player)prompt.Remove(player.UserId)end
 local restore=require(script.Parent.PermanentPassRestore)({Enabled=true,Catalog=deps.Catalog,Data=deps.Data,
  Owns=function(userId:number,passId:number):boolean return market:UserOwnsGamePassAsync(userId,passId) end,
  Notify=function(userId:number)local player=players:GetPlayerByUserId(userId);if player then deps.Network.Send(player) end end})
 local function run(player:Player,passId:number?)
  local session=deps.Data.Sessions[player.UserId]
  for attempt=1,3 do
   if player.Parent~=players or not session or deps.Data.Sessions[player.UserId]~=session or session.closing then return end
   local code=restore.Restore(player.UserId,passId)
   if code=="OK" or code=="SessionChanged" or code=="Closing" then return end
   if attempt<3 then task.wait(attempt*3) end
  end
  -- Durable pending writes also recover through the existing profile heartbeat.
  -- Platform ownership outages are retried on the next join, never guessed as paid.
 end
 S.Joined=function(player:Player)task.spawn(run,player,nil)end
 market.PromptGamePassPurchaseFinished:Connect(function(player:Player,passId:number,purchased:boolean)
  if player.Parent~=players then return end
  prompt.Finished(player.UserId,passId)
  if deps.Catalog.ById[passId] then deps.Network.Send(player,if purchased then "PurchaseVerificationPending" else "PurchaseCancelled") end
  if purchased and deps.Catalog.ById[passId] then task.spawn(run,player,passId) end
 end)
 return S
end
