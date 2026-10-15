-- Synthetic owner/profile, actual HeroService and Roblox physics; no earned progression proof.
return function()
 assert(game:GetService('RunService'):IsStudio() and game.PlaceId==0 and game.GameId==0)
 local server=game.ServerScriptService.Server
 local runtime=require(server.Config.Runtime)
 assert(runtime.StudioPersistence=='Memory' and next(runtime.AllowedDataStoreUniverses)==nil)
 local V=Vector3.new
 local world=workspace.GuildborneWorld
 local fixture=Instance.new('Model');fixture.Name='P1FiveHeroCityTraversal';fixture.Parent=world
 local service
 local result={synthetic=true,rewardCalls=0,segments={},maxSeparation=0,samples=0}
 local ok,problem=xpcall(function()
  local function building(name)
   for _,m in ipairs(world:GetDescendants())do
    if m:IsA('Model') and m.Name==name and m:FindFirstChild('Interior')then return m end
   end
   error('Missing building '..name)
  end
  local tavern,forge=building('The Hearth and Banner'),building('Blacksmith')
  local function point(m,z)return m:GetPivot():PointToWorldSpace(V(0,3,z))end
  local shared=game.ReplicatedStorage.Shared
  local content=require(server.Config.Content)
  local expansion=require(shared.Data.Expansion)
  local gear=require(shared.Data.Equipment)(content,expansion)
  local schema=require(server.Systems.ProfileSchema)(content,require(shared.Util.TableUtil),gear,expansion)
  local function reward()result.rewardCalls+=1 end
  service=require(server.Services.HeroService)(game.ServerStorage.GuildborneArtKit,function()end,reward,reward)
  local char=require(server.Services.HeroRig).Build('Warrior');char.Name='SyntheticLeader';char.Parent=fixture
  char:PivotTo(CFrame.new(0,4,-1100))
  local attrs={CurrentZone='City'}
  local owner={UserId=-93901,Character=char,GetAttribute=function(_,k)return attrs[k]end,SetAttribute=function(_,k,v)attrs[k]=v end}
  local data=schema.new(owner.UserId,1).data
  data.character.classId='Warrior';data.character.level=10;data.character.xp=450;data.party.adventurerIds={}
  local classes={'Knight','Warrior','Archer','Mage','Priest'}
  for _,class in ipairs(classes)do
   local id='a:'..class
   data.adventurers[id]={id=id,classId=class,name='Fixture '..class,level=10,xp=450,condition='Healthy',equipmentSlots={},rank='F'}
   data.progression.recruitedClasses[class]=true;table.insert(data.party.adventurerIds,id)
  end
  service.Add(owner,fixture,V(7000,0,6000));service.Character(owner,char);service.Sync(owner,data,true)
  local root=assert(char.PrimaryPart);local humanoid=assert(char:FindFirstChildOfClass('Humanoid'))
  root.Anchored=false;root:SetNetworkOwner(nil);humanoid.WalkSpeed=14;humanoid.AutoJumpEnabled=false
  service.Travel(owner);task.wait(2)
  local initial={}
  for _,class in ipairs(classes)do initial[class]=fixture.Heroes[class]:GetAttribute('RecoveryCount')or 0 end
  local function sample()
   assert(humanoid.Health>0 and root.Position.Y>-5,'Leader died/fell')
   local out={}
   for _,class in ipairs(classes)do
    local e=assert(service.CompanionEvidence(owner,'a:'..class),'Missing '..class)
    local recovery=fixture.Heroes[class]:GetAttribute('RecoveryCount')or 0
    local gap=(e.position-root.Position).Magnitude
    result.maxSeparation=math.max(result.maxSeparation,gap)
    table.insert(out,{class=class,x=e.position.X,y=e.position.Y,z=e.position.Z,recoveries=recovery,gap=gap})
    result.lastHeroes=out
    assert(e.health>0 and e.position.Y>-5,class..' died/fell')
    assert(recovery==initial[class],class..' auto-recovered/teleported')
    assert(gap<35,class..' lost leader')
   end
   result.samples+=1;assert(result.rewardCalls==0,'Unexpected rewards');return out
  end
  local function walk(label,goal)
   result.activeSegment=label
   local deadline=os.clock()+(goal-root.Position).Magnitude/12+10
   local refresh=0
   repeat
    if os.clock()>=refresh then humanoid:MoveTo(goal);refresh=os.clock()+1 end
    sample();task.wait(.1)
   until Vector2.new(root.Position.X-goal.X,root.Position.Z-goal.Z).Magnitude<1.5 or os.clock()>deadline
   result.leader={x=root.Position.X,y=root.Position.Y,z=root.Position.Z}
   assert(os.clock()<=deadline,'Leader stalled: '..label)
   table.insert(result.segments,{label=label,heroes=sample()})
  end
  local function allInside(m)
   local deadline=os.clock()+6;local inside=false
   repeat
    sample();inside=true
    for _,class in ipairs(classes)do
     local p=m:GetPivot():PointToObjectSpace(service.CompanionEvidence(owner,'a:'..class).position)
     inside=inside and math.abs(p.X)<7 and p.Z<18 and p.Z> -18
    end
    if not inside then task.wait(.1)end
   until inside or os.clock()>deadline
   assert(inside,'Not all five entered '..m.Name)
  end
  local function allOutside(m)
   local deadline=os.clock()+8;local outside=false
   repeat
    sample();outside=true
    for _,class in ipairs(classes)do
     local p=m:GetPivot():PointToObjectSpace(service.CompanionEvidence(owner,'a:'..class).position)
     outside=outside and p.Z>23
    end
    if not outside then task.wait(.1)end
   until outside or os.clock()>deadline
   assert(outside,'Not all five exited '..m.Name)
  end
  walk('Avenue to tavern',V(0,4,-820));walk('Tavern forecourt',V(-140,4,-820))
  walk('Tavern threshold',point(tavern,28));walk('Tavern interior',point(tavern,-12));allInside(tavern)
  walk('Tavern exit',point(tavern,50));allOutside(tavern);walk('Return avenue',V(0,4,-820));walk('Plaza',V(0,4,-1100))
  walk('Market avenue',V(300,4,-1100));walk('Forge outer approach',V(410,4,-1100))
  walk('Forge forecourt',V(410,4,-1000));walk('Forge threshold',point(forge,28))
  walk('Forge interior',point(forge,-12));allInside(forge);walk('Forge exit',point(forge,50));allOutside(forge)
  task.wait(2);result.finalHeroes=sample()
 end,debug.traceback)
 if service then service.Destroy()end
 fixture:Destroy();result.ok=ok;result.problem=if ok then nil else tostring(problem)
 result.cleanup=world:FindFirstChild('P1FiveHeroCityTraversal')==nil
 return result
end
