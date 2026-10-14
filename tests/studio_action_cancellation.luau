-- Local fixture: action VFX scheduling only, no combat or profile mutations.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0)
local controllers=game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Controllers")
local factory=require(controllers.SkillEffects)
local camera=assert(workspace.CurrentCamera)
local quality=require(game.ReplicatedStorage.Shared.Config.VFXConfig).QualityAttribute
local originalQuality=workspace:GetAttribute(quality)
local spawned={}
local connection=workspace.DescendantAdded:Connect(function(p)
 if p:IsA("BasePart") and p.Name=="GuildborneSkillEffect"then table.insert(spawned,p)end
end)
local fixtures={}
local function actor()
 local m=Instance.new("Model");m.Name="ActionCancellationFixture"
 local p=Instance.new("Part");p.Anchored=true;p.CanCollide=false;p.CFrame=camera.CFrame*CFrame.new(0,0,-12);p.Parent=m;m.PrimaryPart=p
 m:SetAttribute("ClassId","Mage");m:SetAttribute("ActionEffect","Magic");m:SetAttribute("CombatHealth",100)
 m:SetAttribute("ActionTargetPosition",p.Position+Vector3.new(0,0,-5));m:SetAttribute("ActionAt",workspace:GetServerTimeNow());m.Parent=workspace
 table.insert(fixtures,m);return m
end
local ok,result=pcall(function()
 for _,mode in ipairs({"replace","death","stream"})do
  local m=actor();local cast=factory();local before=#spawned;cast(m);assert(#spawned>before,"Fixture must actually spawn anticipation")
  local initial=#spawned
  if mode=="replace"then m:SetAttribute("ActionAt",workspace:GetServerTimeNow()+1)
  elseif mode=="death"then m:SetAttribute("CombatHealth",0)
  else m.Parent=nil end
  task.wait(.45);assert(#spawned==initial,"Delayed effect survived "..mode);m:Destroy()
 end
 local m=actor();local cast=factory();cast(m);task.wait(.11)
 local duplicateCount=#spawned;cast(m);assert(#spawned==duplicateCount,"Same live action replayed")
 task.wait(.7)
 local initial=#spawned;cast(m);task.wait(.4);assert(#spawned==initial,"Repeated or stale action replayed")
 m:SetAttribute("ActionAt",0/0);cast(m);assert(#spawned==initial,"Nonfinite action accepted")
 m:SetAttribute("ActionAt",workspace:GetServerTimeNow()+10);cast(m);assert(#spawned==initial,"Future action accepted")
 for _,level in ipairs({"High","Low"})do
  workspace:SetAttribute(quality,level)
  local late=actor();late:SetAttribute("ClassId","Warrior");late:SetAttribute("ActionEffect","Physical");late:SetAttribute("ActionAt",workspace:GetServerTimeNow()-.5)
  local warrior=factory();warrior(late);local anticipation=#spawned;task.wait(.35)
  assert(#spawned==anticipation,"Expired warrior markers replayed: "..level)
 end
 return {status="PASS_LOCAL_VFX_CANCELLATION",replacement=true,death=true,streamRemoval=true,duplicateAndStale=true,nonfiniteAndFuture=true,expiredWarriorMarkers=true,serverDamageTested=false}
end)
connection:Disconnect()
workspace:SetAttribute(quality,originalQuality)
for _,m in ipairs(fixtures)do m:Destroy()end
for _,p in ipairs(spawned)do p:Destroy()end
assert(ok,result);return result
