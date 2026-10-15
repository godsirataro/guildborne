-- Synthetic profiles/players, real HeroService scheduler and physical companion rigs.
assert(game.PlaceId==0 and game.GameId==0,"Local only")
local server=game.ServerScriptService.Server
assert(require(server.Config.Runtime).StudioPersistence=="Memory")
local world=workspace.GuildborneWorld
local root=Instance.new("Model");root.Name="SharedHeroServiceFixture";root.Parent=world
local origin=Vector3.new(6000,0,6000)
local floor=Instance.new("Part");floor.Name="Ground";floor.Anchored=true;floor.Size=Vector3.new(350,2,180);floor.Position=origin+Vector3.new(0,-1,50);floor.Parent=root
local templates=game.ServerStorage.GuildborneArtKit
local enemies=require(server.Services.EnemyService)(templates).create(root,origin,0)
local scout=enemies[1];for i=2,#enemies do enemies[i].model:Destroy()end
scout.plot=root
-- Explicit long-lived fixture target; does not change game configuration.
scout.health=10000;scout.stats.MaxHealth=10000
local Rig=require(server.Services.HeroRig)
local util=require(game.ReplicatedStorage.Shared.Util.TableUtil)
local content=require(server.Config.Content)
local expansion=require(game.ReplicatedStorage.Shared.Data.Expansion)
local gear=require(game.ReplicatedStorage.Shared.Data.Equipment)(content,expansion)
local schema=require(server.Systems.ProfileSchema)(content,util,gear,expansion)
local owners,sessions={},{}
local rewards,effects=0,0
local before={};for _,v in game.ServerStorage:GetChildren()do before[v]=true end
local service=require(server.Services.HeroService)(templates,function()end,function()rewards+=1 end,function()rewards+=1 end,nil,nil,{
 Scene={plot=root,origin=origin,enemies={scout}},
 Session=function(player)return sessions[player.UserId]end,
 ContainsPosition=function(position)local p=position-origin;return math.abs(p.X)<50 and p.Z>40 and p.Z<130 and p.Y>0 and p.Y<30 end,
 Observe=function(name)if name=="damage_dealt"or name=="healing_done"then effects+=1 end end,
})
local results={synthetic=true,owners=2,companionsPerOwner=5,targetFixtureHP=10000}
local ok,problem=pcall(function()
 for index=1,2 do
  local plot=Instance.new("Model");plot.Name="Owner"..index;plot.Parent=root
  local char=Rig.Build("Warrior");char.Name="FixtureLeader";char.Parent=plot
  local attrs={}
  local player={UserId=-92900-index,Character=char,GetAttribute=function(_,key)return attrs[key]end,SetAttribute=function(_,key,value)attrs[key]=value end}
  local record=schema.new(player.UserId,1);local data=record.data
  data.character.classId="Warrior";data.character.level=10
  for _,class in ipairs({"Knight","Warrior","Archer","Mage","Priest"})do
   local id="a:"..class
   data.adventurers[id]={id=id,classId=class,name="Fixture "..class,level=10,xp=0,condition="Healthy",equipmentSlots={},rank="F"}
   data.progression.recruitedClasses[class]=true;table.insert(data.party.adventurerIds,id)
  end
  sessions[player.UserId]={record=record,token="fixture:"..index,epoch=1,state="Active"}
  service.Add(player,plot,origin+Vector3.new(if index==1 then -120 else 120,0,0))
  service.Character(player,char);service.Sync(player,data,true)
  char:PivotTo(CFrame.new(origin+Vector3.new(if index==1 then -10 else 10,3,65)))
  service.Travel(player)
  table.insert(owners,{player=player,plot=plot,data=data})
 end
 task.wait(2)
 assert(service.SharedStatus()=="Ready",service.SharedStatus())
 for _,o in ipairs(owners)do
  assert(o.plot:GetAttribute("SharedCombatStatus")=="Prepared",tostring(o.plot:GetAttribute("SharedCombatStatus")))
  assert(service.PlayerAction(o.player,"Hold","a:Knight"))
  assert(service.CompanionEvidence(o.player,"a:Knight").order=="Hold")
 end
 results.preparedBoth=true;results.ownedCommands=true
 local one,two=owners[1],owners[2]
 local beforeSaving=service.CompanionEvidence(one.player,"a:Knight").position
 sessions[one.player.UserId].state="Saving";service.Sync(one.player,one.data,false)
 task.wait(.6)
 local saving=service.CompanionEvidence(one.player,"a:Knight")
 results.savingDistance=(saving.position-beforeSaving).Magnitude
 assert(results.savingDistance<5,"Saving teleported follower")
 assert(one.plot:GetAttribute("SharedCombatStatus")=="Prepared")
 sessions[one.player.UserId].state="Degraded";task.wait(.4)
 assert(one.plot:GetAttribute("SharedCombatStatus")=="Prepared")
 sessions[one.player.UserId].state="Active";service.Sync(one.player,one.data,true)
 results.savingDegradedContinuity=true
 local old=sessions[one.player.UserId]
 sessions[one.player.UserId]={record=old.record,token="replacement",epoch=2,state="Active"}
 task.wait(.4)
 assert(service.SharedStatus()=="Ready",service.SharedStatus())
 assert(one.plot:GetAttribute("SharedCombatStatus")=="Prepared")
 results.sessionReplacement=true
 service.Remove(one.player);sessions[one.player.UserId]=nil;one.removed=true
 task.wait(.4)
 assert(scout.model.Parent==root and two.plot:GetAttribute("SharedCombatStatus")=="Prepared")
 assert(service.PlayerAction(two.player,"Regroup","a:Knight"))
 results.ownerRemovalPreservesOther=true
 two.player.Character:PivotTo(CFrame.new(origin+Vector3.new(120,3,20)));service.Travel(two.player)
 task.wait(.4)
 assert(two.plot:GetAttribute("SharedCombatStatus")==nil)
 assert(service.SharedStatus()=="Ready")
 results.exit=true
 assert(rewards==0,"Shared fixture reached legacy rewards")
end)
for _,o in ipairs(owners)do if not o.removed then pcall(service.Remove,o.player)end end
pcall(service.CloseShared)
root:Destroy()
for _,v in game.ServerStorage:GetChildren()do if not before[v]and v.Name=="GuildborneAwayHeroes"then v:Destroy()end end
results.ok=ok;results.problem=if ok then nil else tostring(problem);results.effects=effects;results.legacyRewardCalls=rewards
results.cleanup=world:FindFirstChild("SharedHeroServiceFixture")==nil
results.schedulerCleanup="Stop Play after fixture to disconnect its empty HeroService Heartbeat"
return results
