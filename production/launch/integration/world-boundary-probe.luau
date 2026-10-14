-- Read-only live instance checks in the unpublished Memory candidate.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0)
local world=workspace:WaitForChild("GuildborneWorld")
local entry=world.City.Ashen;assert(entry:GetAttribute("ReleaseUnavailable")==true)
assert(entry:FindFirstChildOfClass("ProximityPrompt").Enabled==false)
local count=0
for _,v in ipairs(world.Ashen:GetChildren())do
 if v:GetAttribute("ResourceNodeId") then
  assert(v:GetAttribute("ReleaseUnavailable")==true)
  assert(v:FindFirstChildOfClass("ProximityPrompt").Enabled==false);count+=1
 end
end
assert(count==2)
local exit=world.Ashen:FindFirstChild("Central City")
assert(exit and exit:GetAttribute("TravelDestination")=="City")
assert(exit:GetAttribute("ReleaseUnavailable")==false and exit:FindFirstChildOfClass("ProximityPrompt").Enabled)
assert(world.City.Greenwood:FindFirstChildOfClass("ProximityPrompt").Enabled)
assert(world.City.Ironveil:FindFirstChildOfClass("ProximityPrompt").Enabled)
local tower=world.PersonalGuild.Environment.Expansion.TowerPortal
assert(tower:GetAttribute("ReleaseUnavailable")==true and tower:FindFirstChildOfClass("ProximityPrompt").Enabled)
local label=tower:FindFirstChildWhichIsA("TextLabel",true)
assert(label and label.Text:find("Lv1–35",1,true))
return {status="PASS",blockedEntry="Ashen",blockedNodes=count,cityReturn=true,greenwood=true,ironveil=true,towerRecoveryPanel=true,persistence="Memory",publicAcceptance=false}
