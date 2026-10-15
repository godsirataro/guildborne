assert(game.PlaceId==0 and game.GameId==0)
local server=game.ServerScriptService.Server
local Rig=require(server.Services.HeroRig)
local root=Instance.new("Model");root.Name="TacticalDodgeFixture";root.Parent=workspace.GuildborneWorld
local geometry=Instance.new("Model");geometry.Name="Geometry";geometry.Parent=root
local floor=Instance.new("Part");floor.Name="Ground";floor.Anchored=true;floor.Size=Vector3.new(100,2,100);floor.Position=Vector3.new(0,21,1400);floor.Parent=geometry
local char=Rig.Build("Warrior");char.Name="FixtureLeader";char.Parent=root;char:PivotTo(CFrame.new(0,25,1410))
local player={UserId=-90902,Character=char,GetAttribute=function()return nil end,SetAttribute=function()end}
local service=require(server.Services.CombatService)(game.ServerStorage.GuildborneArtKit,function()error("no reward")end,function()end)
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={root};params.RespectCanCollide=true
local s={origin=Vector3.new(0,22,1360),plot=root,params=params,active=true,heroes={},enemies={},campEnemies={},characterData={classId="Warrior",level=10,xp=0,raceId="Human"},playerBuild={tier=1,skills={}},playerLoadout={}}
local classes={"Knight","Warrior","Archer","Mage","Priest"}
for i,class in ipairs(classes)do
 local m=Rig.Build(class);m.Parent=root;m:PivotTo(CFrame.new((i-3)*2,25,1400))
 local h={model=m,root=m.PrimaryPart,humanoid=m:FindFirstChildOfClass("Humanoid"),state="Following",slot=i,generation=0}
 s.heroes["a:"..class]=h
 service.Sync(h,{id="a:"..class,class=class,level=10,state="Following",build={tier=1,skills={}}},player,s)
end
local hazard={id="fixturehazard",owner=player.UserId,health=100,active=true}
local evade=require(server.Services.RegionalEvasion)(geometry,"Greenwood")
s.regionalEvasion=function(actor,_enemies,now)return evade(actor,{hazard},now)end
local function walk(_s,h,goal,_now)
 if h.root.Anchored then h.root.Anchored=false;h.root:SetNetworkOwner(nil)end
 h.humanoid:MoveTo(goal)
end
local result={}
local ok,problem=pcall(function()
 service.Step(player,s,char.PrimaryPart,true,os.clock(),walk)
 local anchors={}
 for _,class in ipairs(classes)do
  local h=s.heroes["a:"..class];assert(service.PlayerAction(s,"Hold",os.clock(),"a:"..class));anchors[class]=h.combat.holdPoint
 end
 local now=os.clock()
 hazard.pendingPattern={shape="Circle",x=0,y=22,z=1400,radius=8,due=now+2,expires=now+2.5}
 local seen={}
 for _=1,12 do
  service.Step(player,s,char.PrimaryPart,true,os.clock(),walk)
  for _,class in ipairs(classes)do if s.heroes["a:"..class].combat.state=="Evade"then seen[class]=true end end
  task.wait(.2)
 end
 hazard.pendingPattern=nil
 for _=1,20 do service.Step(player,s,char.PrimaryPart,true,os.clock(),walk);task.wait(.2)end
 for _,class in ipairs(classes)do
  local h=s.heroes["a:"..class];local delta=h.root.Position-anchors[class]
  local horizontal=Vector2.new(delta.X,delta.Z).Magnitude
  assert(seen[class],class.." never evaded")
  assert(h.combat.state=="Hold" and h.combat.order=="Hold",class.." did not resume")
  assert(horizontal<2.5,class.." return distance "..horizontal)
  table.insert(result,{class=class,evaded=seen[class],returnDistance=horizontal,health=h.combat.health})
 end
end)
root:Destroy()
return {ok=ok,problem=if ok then nil else tostring(problem),results=result,synthetic=true,injectedHazard=true,realRegionalEvasion=true,cleanup=workspace.GuildborneWorld:FindFirstChild("TacticalDodgeFixture")==nil}

