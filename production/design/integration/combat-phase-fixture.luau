assert(game.PlaceId==0 and game.GameId==0)
local server=game.ServerScriptService.Server
local Rig=require(server.Services.HeroRig)
local Config=require(server.Config.Combat)
local root,service,s,player
local calls=0;local release=false;local completed=false
local result={}
local ok,problem=pcall(function()
root=Instance.new("Model");root.Name="CombatPhaseFixture";root.Parent=workspace.GuildborneWorld
local origin=Vector3.new(3000,0,3000)
local floor=Instance.new("Part");floor.Anchored=true;floor.Size=Vector3.new(80,2,140);floor.Position=origin+Vector3.new(0,-1,60);floor.Parent=root
local char=Rig.Build("Warrior");char.Parent=root;char:PivotTo(CFrame.new(origin+Vector3.new(0,3,23)))
player={UserId=-90903,Character=char,GetAttribute=function()return nil end,SetAttribute=function()end}
service=require(server.Services.CombatService)(game.ServerStorage.GuildborneArtKit,function()
 calls+=1
 local deadline=os.clock()+8
 repeat task.wait()until release or os.clock()>deadline
 completed=true
 return release
end,function()error("Unexpected tower reward")end)
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={floor}
s={origin=origin,plot=root,params=params,alive=true,active=true,heroes={},characterData={classId="Warrior",level=10,xp=0,raceId="Human"},playerBuild={tier=1,skills={}},playerLoadout={}}
 service.Add(s,player)
 service.Step(player,s,char.PrimaryPart,false,os.clock(),function()end)
 local enemy=s.enemies[1];local generation=enemy.generation
 local stamp=os.clock();enemy.health=0;enemy.state="Dead";enemy.downedAt=stamp-Config.Goblin.RespawnSeconds-1;enemy.participants={"a:Warrior"};enemy.playerParticipated=true
 service.Step(player,s,char.PrimaryPart,false,stamp,function()end)
 task.wait()
 assert(calls==1 and enemy.rewardPending and enemy.health==0)
 for _=1,4 do service.Step(player,s,char.PrimaryPart,false,os.clock(),function()end)end
 assert(calls==1 and enemy.generation==generation and enemy.health==0,"Pending death replayed or respawned")
 result.pendingBlocksRespawn=true;result.rewardCalls=calls
 release=true
 local deadline=os.clock()+2
 repeat task.wait()until completed or os.clock()>deadline
 assert(completed and enemy.rewardDone and not enemy.rewardPending)
 service.Step(player,s,char.PrimaryPart,false,os.clock(),function()end)
 assert(enemy.generation==generation+1 and enemy.health==enemy.stats.MaxHealth)
 result.confirmedRespawn=true
 local p=s.playerCombat
 p.health=0;p.downedAt=os.clock()-Config.DownSeconds-1
 service.Step(player,s,char.PrimaryPart,false,os.clock(),function()end)
 assert(p.health==p.stats.MaxHealth*.5 and p.state=="Recover")
 result.playerRecovery=true
 p.lastHit=os.clock()-Config.RecoveryDelay-1;local before=p.health
 service.Step(player,s,char.PrimaryPart,false,os.clock(),function()end)
 assert(p.health>before and p.health<=p.stats.MaxHealth)
 result.passiveRecovery=true
 assert(s.allies and #s.allies==0 and p.active==false)
 result.invalidPlayerInactive=true
end)
if s then s.alive=false end
release=true
local deadline=os.clock()+2
while calls>0 and not completed and os.clock()<deadline do task.wait()end
local drained=calls==0 or completed
local teardownOK,teardownProblem=pcall(function()if service and s then service.Remove(player,s)end end)
for _,enemy in ipairs(if s then s.enemies or {} else {})do enemy.model:Destroy()end
if root then root:Destroy()end
return {ok=ok and drained and teardownOK,problem=if not ok then tostring(problem)elseif not drained then "CallbackNotDrained"elseif not teardownOK then tostring(teardownProblem)else nil,results=result,synthetic=true,injectedDeath=true,profileWrites=0,callbackDrained=drained,cleanup=workspace.GuildborneWorld:FindFirstChild("CombatPhaseFixture")==nil}
