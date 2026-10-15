assert(game.PlaceId==0 and game.GameId==0)
local server=game.ServerScriptService.Server
assert(require(server.Config.Runtime).StudioPersistence=="Memory")
local world=workspace.GuildborneWorld
local Rig=require(server.Services.HeroRig)
local Identity=require(server.Systems.SharedEncounterIdentity)
local templates=game.ServerStorage.GuildborneArtKit
local root,shared,registry,encounter
local result={synthetic=true,profileWrites=0,owners=2,companionsPerOwner=5}
local ok,problem=pcall(function()
 root=Instance.new("Model");root.Name="SharedCombatContextFixture";root.Parent=world
 local origin=Vector3.new(5000,0,5000)
 local ground=Instance.new("Part");ground.Anchored=true;ground.Size=Vector3.new(100,2,150);ground.Position=origin+Vector3.new(0,-1,70);ground.Parent=root
 registry=Identity();encounter=assert(registry.create())
 local enemyFactory=require(server.Services.EnemyService)(templates)
 local spawned=enemyFactory.create(root,origin,0)
 local scout=spawned[1];for i=2,#spawned do spawned[i].model:Destroy()end
 scout.plot=root;scout.home=origin+Vector3.new(0,3,80);scout.model:PivotTo(CFrame.new(scout.home))
 assert(registry.addEnemy(encounter,scout))
 local scene={plot=root,origin=origin,enemies={scout},alive=true}
 local live,owners={},{}
 local recovered,observed=0,0
 local effects={}
 local context={SceneToken={},EncounterToken=encounter,Scene=scene,Policy=registry.policy(),
  Contains=function(actor)
   local p=actor.root.Position-origin
   return actor.model.Parent~=nil and math.abs(p.X)<45 and p.Y>0 and p.Y<40 and p.Z>45 and p.Z<115
  end,
  IsCurrent=function(id,session)return live[id]==session end,
  Observe=function(event,a,b,value)observed+=1;table.insert(effects,{event=event,sourceOwner=a.owner,targetOwner=b.owner,value=value})end,
  Recover=function(actor,amount)assert(amount>0);if actor.kind=="Hero"then recovered+=amount end end}
 shared=require(server.Services.CombatService)(templates,function()error("Legacy reward called")end,function()error("Tower reward called")end,nil,nil,context)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={ground}
 local classes={"Warrior","Knight","Archer","Mage","Priest"}
 for index=1,2 do
  local id=-91900-index;local char=Rig.Build("Warrior");char.Parent=root;char:PivotTo(CFrame.new(origin+Vector3.new((index-1)*4,3,70)))
  local player={UserId=id,Character=char,GetAttribute=function()return nil end,SetAttribute=function()end}
  local state={origin=origin,plot=root,params=params,alive=true,active=true,heroes={},enemies={},characterData={classId="Warrior",level=10,xp=0,raceId="Human"},playerBuild={tier=1,skills={}},playerLoadout={}}
  for slot,class in ipairs(classes)do
   local model=Rig.Build(class);model.Parent=root;model:PivotTo(CFrame.new(origin+Vector3.new((index-1)*10+slot,3,68)))
   local hero={model=model,root=model.PrimaryPart,humanoid=model:FindFirstChildOfClass("Humanoid"),state="Following",slot=slot,generation=0,home=model:GetPivot()}
   state.heroes["a:"..class]=hero
   shared.Sync(hero,{id="a:"..class,class=class,level=10,state="Following",build={tier=1,skills={}}},player,state)
  end
  local session={};live[id]=session;owners[index]={player=player,state=state,session=session}
 end
 local function walk(_state,hero,goal)hero.humanoid:MoveTo(goal)end
 local stamp=os.clock()
 for _,o in ipairs(owners)do
  local handle,actors=shared.PrepareSharedOwner(o.player,o.state,o.player.Character.PrimaryPart,true,stamp,walk,o.session)
  assert(handle,tostring(actors));o.handle=handle;o.actors=actors;assert(#actors==6)
  o.registration=assert(registry.addOwner(encounter,o.player.UserId))
  for _,actor in ipairs(actors)do assert(registry.addActor(encounter,o.registration,actor))end
  assert(shared.RegisterSharedOwner(handle))
  for _,hero in pairs(o.state.heroes)do hero.combat.order="Hold";hero.combat.holdPoint=hero.root.Position end
 end
 assert(owners[1].actors[1]~=owners[2].actors[1])
 assert(shared.StepSharedEnemies(stamp));assert(not shared.StepSharedEnemies(stamp))
 for _,o in ipairs(owners)do assert(shared.StepSharedOwner(o.handle));assert(not shared.StepSharedOwner(o.handle));assert(shared.FinishSharedOwner(o.handle));assert(not shared.FinishSharedOwner(o.handle));assert(#o.state.enemies==0)end
 result.oncePerStamp=true
 -- Explicit fixture positions and deficit; actual command/LOS/damage/heal code remains unchanged.
 local one,two=owners[1],owners[2]
 one.player.Character:PivotTo(CFrame.new(scout.root.Position+Vector3.new(0,0,-3)))
 local wall=Instance.new("Part");wall.Name="LOSBarrier";wall.Anchored=true;wall.Size=Vector3.new(8,10,.4);wall.Position=(scout.root.Position+one.state.playerCombat.root.Position)*.5+Vector3.new(0,1,0);wall.Parent=root
 local beforeHP=scout.health
 local blocked,blockedReason=shared.PlayerAction(one.state,"Basic",stamp+1,"player")
 assert(not blocked and blockedReason=="NoTarget" and scout.health==beforeHP,"LOS permitted damage")
 wall:Destroy()
 local hit,hitReason=shared.PlayerAction(one.state,"Basic",stamp+1,"player")
 assert(hit,tostring(hitReason));assert(scout.health<beforeHP,"No effective shared damage")
 local hitHP=scout.health
 assert(not shared.PlayerAction(one.state,"Basic",stamp+1,"player"));assert(scout.health==hitHP,"Cooldown duplicate damage")
 local injured=two.state.playerCombat;injured.health=math.floor(injured.stats.MaxHealth*.4)
 local beforeHeal=injured.health
 local heal,healReason=shared.PlayerAction(one.state,"Ability",stamp+1,"a:Priest")
 assert(heal,tostring(healReason));assert(injured.health>beforeHeal,"Cross-owner heal absent")
 assert(not shared.PlayerAction(one.state,"Hold",stamp+1,"foreign-only-hero"))
 result.damage=beforeHP-hitHP;result.crossOwnerHealing=injured.health-beforeHeal;result.lineOfSightBlocked=true;result.duplicateAttackBlocked=true;result.foreignActorRejected=true;result.effects=effects

 local first=owners[1];local actor=first.state.heroes["a:Warrior"].combat
 actor.health=actor.stats.MaxHealth-7;actor.cooldowns.power_strike=stamp+100
 local hp=actor.health
 local nextHandle=assert(shared.PrepareSharedOwner(first.player,first.state,first.player.Character.PrimaryPart,true,stamp+1,walk,first.session))
 assert(actor.health==hp and actor.cooldowns.power_strike==stamp+100)
 assert(not shared.StepSharedOwner(first.handle));assert(shared.RegisterSharedOwner(nextHandle))
 result.preserveHealthCooldowns=true
 local accepted=shared.PlayerAction(first.state,"Hold",stamp+1,"a:Warrior");assert(accepted)
 first.player.Character:PivotTo(CFrame.new(origin+Vector3.new(100,3,70)))
 assert(not shared.PlayerAction(first.state,"Hold",stamp+1,"a:Warrior"));first.player.Character:PivotTo(CFrame.new(origin+Vector3.new(0,3,70)))
 live[first.player.UserId]=nil
 assert(not shared.PlayerAction(first.state,"Hold",stamp+1,"a:Warrior"))
 shared.DetachSharedOwner(first.player.UserId,first.session);registry.removeOwner(first.registration)
 assert(not shared.StepSharedOwner(nextHandle));assert(scout.model.Parent==root)
 assert(shared.PlayerAction(owners[2].state,"Hold",stamp+1,"a:Warrior"))
 result.detachRetainsOtherOwner=true;result.boundsAndCurrentFence=true
 result.observedEvents=observed;result.neutralHeroRecovery=recovered
end)
if shared then shared.CloseShared()end
if registry and encounter then registry.close(encounter)end
if root then root:Destroy()end
result.ok=ok;result.problem=if ok then nil else tostring(problem)
result.cleanup=world:FindFirstChild("SharedCombatContextFixture")==nil
return result
