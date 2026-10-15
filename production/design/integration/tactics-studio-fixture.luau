assert(game.PlaceId==0 and game.GameId==0,"Local only")
local server=game.ServerScriptService.Server
assert(require(server.Config.Runtime).StudioPersistence=="Memory")
local world=workspace.GuildborneWorld
local root=Instance.new("Model");root.Name="TacticalAcceptanceFixture";root.Parent=world
local floor=Instance.new("Part");floor.Name="Ground";floor.Anchored=true;floor.Size=Vector3.new(100,2,150);floor.Position=Vector3.new(1000,-1,35);floor.Parent=root
local Rig=require(server.Services.HeroRig)
local char=Rig.Build("Warrior");char.Name="FixtureLeader";char.Parent=root;char:PivotTo(CFrame.new(1000,3,23))
local attrs={}
local player={UserId=-90901,Character=char,GetAttribute=function(_,key)return attrs[key]end,SetAttribute=function(_,key,value)attrs[key]=value end}
local util=require(game.ReplicatedStorage.Shared.Util.TableUtil)
local content=require(server.Config.Content)
local expansion=require(game.ReplicatedStorage.Shared.Data.Expansion)
local gear=require(game.ReplicatedStorage.Shared.Data.Equipment)(content,expansion)
local data=require(server.Systems.ProfileSchema)(content,util,gear,expansion).new(player.UserId,1).data
data.character.classId="Warrior";data.character.level=10
local classes={"Knight","Warrior","Archer","Mage","Priest"}
for _,class in ipairs(classes)do
 local id="a:"..class
 data.adventurers[id]={id=id,classId=class,name="Fixture "..class,level=10,xp=0,condition="Healthy",equipmentSlots={},rank="F"}
 data.progression.recruitedClasses[class]=true
 table.insert(data.party.adventurerIds,id)
end
local rewards=0
local before={};for _,v in game.ServerStorage:GetChildren()do before[v]=true end
local service=require(server.Services.HeroService)(game.ServerStorage.GuildborneArtKit,function()end,function()rewards+=1 end,function()end)
local results={}
local ok,problem=pcall(function()
 service.Add(player,root,Vector3.new(1000,0,0))
 service.Character(player,char)
 service.Sync(player,data,true)
 service.Travel(player)
 task.wait(1)
 for _,class in ipairs(classes)do
  local id="a:"..class
  local accepted,reason=service.PlayerAction(player,"Hold",id)
  assert(accepted,class..":"..tostring(reason))
 end
 task.wait(.5)
 local held={}
 for _,class in ipairs(classes)do local e=service.CompanionEvidence(player,"a:"..class);held[class]=e.position;assert(e.order=="Hold")end
 char:PivotTo(CFrame.new(1010,3,23))
 task.wait(2)
 for _,class in ipairs(classes)do
  local e=service.CompanionEvidence(player,"a:"..class)
  local drift=(e.position-held[class]).Magnitude
  assert(drift<2.5,class.." Hold drift "..drift)
  table.insert(results,{class=class,holdDrift=drift})
  assert(service.PlayerAction(player,"Regroup","a:"..class))
 end
 task.wait(3)
 local T=require(server.Systems.HeroTactics)
 for slot,class in ipairs(classes)do
  local e=service.CompanionEvidence(player,"a:"..class)
  local offset=T.offset(class,slot)
  local desired=char.PrimaryPart.CFrame:PointToWorldSpace(Vector3.new(offset.x,0,offset.z))
  local delta=e.position-desired
  local distance=Vector2.new(delta.X,delta.Z).Magnitude
  results[slot].formationDistance=distance
  assert(distance<4,class.." formation "..distance)
  assert(service.PlayerAction(player,"TacticDefensive","a:"..class))
 end
 task.wait(.3)
 for _,class in ipairs(classes)do assert(root.Heroes[class]:GetAttribute("TacticalPreset")=="Defensive")end
 assert(service.PlayerAction(player,"Hold","a:Knight"))
 local mentor=service.BeginMentor(player,"a:Knight");assert(mentor)
 local accepted,reason=service.PlayerAction(player,"Regroup","a:Knight")
 assert(not accepted and reason=="NotReady")
 service.EndMentor(player)
 service.Travel(player)
 task.wait(.5)
 for _,class in ipairs(classes)do assert(service.CompanionEvidence(player,"a:"..class).order==nil)end
 data.party.adventurerIds={}
 service.Sync(player,data,true)
 task.wait(.3)
 assert(service.CompanionEvidence(player,"a:Knight")==nil)
 assert(rewards==0,"fixture minted rewards")
end)
pcall(service.Remove,player)
root:Destroy()
for _,v in game.ServerStorage:GetChildren()do if not before[v] and v.Name=="GuildborneAwayHeroes"then v:Destroy()end end
return {ok=ok,problem=if ok then nil else tostring(problem),results=results,rewardCalls=rewards,synthetic=true,cleanup=world:FindFirstChild("TacticalAcceptanceFixture")==nil}

