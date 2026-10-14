-- Client probe in the local Memory-only full game. No saves or rewards.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0)
local player=game.Players.LocalPlayer
local controllers=player:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Controllers")
local pose=require(controllers.ActionPose)
local count=0
for _,class in ipairs({"Warrior","Archer","Mage","Priest","Knight"})do
 for _,joint in ipairs({"Right Shoulder","Left Shoulder","RightShoulder","LeftShoulder","Waist","RootJoint","Neck","RightHip","LeftElbow"})do
  for _,age in ipairs({0,.1,.24,.26,.62})do
   local value=pose(class,"Physical",age,joint)
   if value then for _,component in ipairs({value:GetComponents()})do assert(component==component and math.abs(component)<math.huge)end end
   count+=1
  end
  assert(pose(class,"Physical",0/0,joint)==nil)
  assert(pose(class,"Physical",math.huge,joint)==nil)
 end
end
local Audio=require(controllers.AudioController)
-- The MCP probe can have a distinct require cache from running LocalScripts.
-- Test this module instance against the existing scene, then remove our instance.
Audio.Destroy()
local baseline=0;for _,v in ipairs(game.SoundService:GetChildren())do if v.Name=="GuildborneAudio"then baseline+=1 end end
Audio.Destroy();Audio.Start();Audio.Destroy();Audio.Start()
local folders=0;for _,v in ipairs(game.SoundService:GetChildren())do if v.Name=="GuildborneAudio"then folders+=1 end end
Audio.Destroy()
assert(folders==baseline+1)
return {status="PASS_LOCAL_PRESENTATION_PROBE",finitePoseSamples=count,probeAudioFolders=folders-baseline,
 audioListeningAccepted=false,weaponGripFitAccepted=false,productionIDsAssigned=false}
