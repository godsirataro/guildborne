--!strict
-- Disposable native physics fixture. Synthetic eligibility/roster, NOT earned progression.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0)
local server=game.ServerScriptService.Server
assert(server.ServerBootstrap.Disabled,"Normal bootstrap must be disabled before this fixture starts")
assert(not workspace:FindFirstChild("GuildborneWorld"),"Never create competing world runtimes")
local runtime=require(server.Config.Runtime)
assert(runtime.StudioPersistence=="Memory" and next(runtime.AllowedDataStoreUniverses)==nil)
local report=Instance.new("StringValue");report.Name="ContinuousPartyFixtureReport";report.Parent=workspace
local result:any={status="RUNNING",scope="NATIVE_SYNTHETIC_PARTY_NOT_EARNED_GAMEPLAY",rewardCalls=0,segments={},samples=0,maxSeparation=0,notifications={}}
local http=game:GetService("HttpService")
local function save()report.Value=http:JSONEncode(result)end
save()
local world:any=nil
local player:Player?=nil
local ok,problem=xpcall(function()
 local players=game:GetService("Players")
 local owner=players:GetPlayers()[1] or players.PlayerAdded:Wait();player=owner
 local character=owner.Character or owner.CharacterAdded:Wait()
 local root=character:WaitForChild("HumanoidRootPart") :: BasePart
 local humanoid=character:WaitForChild("Humanoid") :: Humanoid
 local shared=game.ReplicatedStorage.Shared
 local content=require(server.Config.Content)
 local expansion=require(shared.Data.Expansion)
 local gear=require(shared.Data.Equipment)(content,expansion)
 local schema=require(server.Systems.ProfileSchema)(content,require(shared.Util.TableUtil),gear,expansion)
 local record=schema.new(owner.UserId,1)
 local data=record.data
 data.character.classId="Warrior";data.character.level=10;data.character.xp=450
 data.personalGuild.buildings.guildHall=1 -- synthetic fixture setup, never earned progression
 data.party.adventurerIds={}
 local classes={"Knight","Warrior","Archer","Mage","Priest"}
 for _,class in ipairs(classes)do
  local id="a:"..class
  data.adventurers[id]={id=id,classId=class,name="Fixture "..class,level=10,xp=450,condition="Healthy",equipmentSlots={},rank="F"}
  data.progression.recruitedClasses[class]=true;table.insert(data.party.adventurerIds,id)
 end
 local session={state="Active",record=record,epoch=1,token="isolated-native-fixture"}
 local function reward()result.rewardCalls+=1 end
 world=require(server.Services.WorldService).new(function()end,reward,reward,function()end,nil,nil,nil,nil,{
  Session=function(p:any)return if p==owner then session else nil end,
  Gate=function(p:any,s:any,from:string,to:string)
   if p~=owner or s~=session or owner.Character~=character then return "FixtureIdentityChanged" end
   if not ((from=="City" and to=="Greenwood")or(from=="Greenwood" and to=="City"))then return "InvalidZone" end
   return nil
  end,
  Notify=function(_p:any,code:string)table.insert(result.notifications,code)end,
 })
 world.Add(owner);task.wait(1)
 world.Update(owner,data.personalGuild.buildings.guildHall,data,true)
 world.IntentCommitted(owner,"TravelZone",{zone="City"}) -- setup only; never used while walking
 task.wait(3)
 root:SetNetworkOwner(nil);humanoid.WalkSpeed=16;humanoid.AutoJumpEnabled=false
 local scene=workspace.GuildborneWorld
 local island=scene:FindFirstChild("PersonalGuild") :: Model
 local heroes=island:FindFirstChild("Heroes") :: Folder
 local baseline:any={}
 for _,class in ipairs(classes)do baseline[class]=heroes[class]:GetAttribute("RecoveryCount")or 0 end
 result.initialRecoveries=baseline
 local direction:any=nil
 local previousPosition=root.Position
 local function beginDirection(from:string,to:string)
  direction={from=from,to=to,spawn=owner.RespawnLocation}
 end
 local function sample()
  assert(owner.Character==character and humanoid.Health>0 and root.Position.Y> -5,"Leader replaced/died/fell")
  local out={}
  for _,class in ipairs(classes)do
   local e=assert(world.CompanionEvidence(owner,"a:"..class),"Missing "..class)
   local count=heroes[class]:GetAttribute("RecoveryCount")or 0
   local distance=(e.position-root.Position).Magnitude
   result.maxSeparation=math.max(result.maxSeparation,distance)
   table.insert(out,{class=class,health=e.health,recoveries=count,gap=distance,x=e.position.X,y=e.position.Y,z=e.position.Z})
   result.heroes=out
   assert(e.health>0 and e.position.Y> -5,class.." died/fell")
   assert(count==baseline[class],class.." auto-recovered/teleported")
   assert(distance<40,class.." lost leader")
  end
  result.samples+=1
  result.position={x=root.Position.X,y=root.Position.Y,z=root.Position.Z}
  result.zone=owner:GetAttribute("CurrentZone")
  result.walkingContext=character:GetAttribute("WalkingRouteContext")
  result.respawn=owner.RespawnLocation and owner.RespawnLocation:GetFullName()
  local displacement=(root.Position-previousPosition).Magnitude;previousPosition=root.Position
  result.maxSampleDisplacement=math.max(result.maxSampleDisplacement or 0,displacement)
  assert(displacement<=35,"Unexpected player displacement/recovery")
  assert(#result.notifications==0,"Unexpected travel rejection/recovery notification")
  if direction then
   assert(result.zone==direction.from or result.zone==direction.to,"Unexpected zone")
   if result.walkingContext then
    assert(result.walkingContext=="city_greenwood_west|"..direction.from.."|"..direction.to,"Wrong walking direction")
    assert(result.zone==direction.from and owner.RespawnLocation==direction.spawn,"Transit changed source zone/respawn")
   end
  end
  assert(result.rewardCalls==0,"Unexpected reward callback")
 end
 local function walk(label:string,goal:Vector3)
  result.activeSegment=label
  local deadline=os.clock()+(goal-root.Position).Magnitude/12+12
  local refresh=0
  repeat
   if os.clock()>=refresh then humanoid:MoveTo(goal);refresh=os.clock()+1 end
   sample();save();task.wait(.2)
  until Vector2.new(root.Position.X-goal.X,root.Position.Z-goal.Z).Magnitude<1.5 or os.clock()>deadline
  assert(os.clock()<=deadline,"Leader stalled: "..label)
  table.insert(result.segments,{label=label,zone=owner:GetAttribute("CurrentZone"),context=character:GetAttribute("WalkingRouteContext")})
 end
 local nodes=scene.CityGreenwoodCorridor.NavigationNodes:GetChildren()
 table.sort(nodes,function(a,b)return a:GetAttribute("Index")<b:GetAttribute("Index")end)
 walk("City approach",Vector3.new(0,4,-720))
 beginDirection("City","Greenwood")
 for i,node in ipairs(nodes)do walk("Out "..i,(node :: Vector3Value).Value+Vector3.new(0,3,0))end
 walk("Greenwood landing",Vector3.new(0,5,1505))
 task.wait(1.2);sample();save()
 assert(result.zone=="Greenwood" and result.walkingContext==nil,"Destination commit/stationary context failed")
 assert(owner.RespawnLocation and owner.RespawnLocation:IsDescendantOf(scene.Greenwood),"Wrong Greenwood respawn")
 beginDirection("Greenwood","City")
 for i=#nodes,1,-1 do walk("Back "..i,(nodes[i] :: Vector3Value).Value+Vector3.new(0,3,0))end
 walk("City return",Vector3.new(0,4,-720))
 task.wait(1.2);sample();save()
 assert(result.zone=="City" and result.walkingContext==nil,"City return/stationary context failed")
 assert(owner.RespawnLocation and owner.RespawnLocation:IsDescendantOf(scene.City),"Wrong City respawn")
end,debug.traceback)
result.status=if ok then "PASS_NATIVE_FIXTURE" else "FAIL_NATIVE_FIXTURE"
result.error=if ok then nil else tostring(problem)
save()
-- Retain failed geometry/actors for inspection; cleanup is stopping this disposable Play.
