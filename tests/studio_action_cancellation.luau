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
 local hand=Instance.new("Part");hand.Name="RightHand";hand.Anchored=true;hand.CanCollide=false;hand.CFrame=p.CFrame*CFrame.new(1,0,0);hand.Parent=m
 m:SetAttribute("ClassId","Warrior");m:SetAttribute("ActionEffect","Physical");m:SetAttribute("ActionAbilityId","power_strike");m:SetAttribute("CombatHealth",100)
 m:SetAttribute("ActionTargetPosition",p.Position+Vector3.new(0,0,-5));m:SetAttribute("ActionAt",workspace:GetServerTimeNow());m.Parent=workspace
 table.insert(fixtures,m);return m
end
local ok,result=pcall(function()
 workspace:SetAttribute(quality,"High")
 for _,class in ipairs({"Warrior","Mage"})do
 for _,mode in ipairs({"replace","death","stream","cancel","humanoidDeath"})do
  local m=actor()
  if class=="Mage"then m:SetAttribute("ClassId","Mage");m:SetAttribute("ActionEffect","Magic");m:SetAttribute("ActionAbilityId","fireball")end
  local cast=factory();local before=#spawned;cast(m);assert(#spawned>before,"Fixture must actually spawn anticipation")
  local initial=#spawned
  if mode=="replace"then m:SetAttribute("ActionAt",workspace:GetServerTimeNow()+1)
  elseif mode=="death"then m:SetAttribute("CombatHealth",0)
  elseif mode=="cancel"then m:SetAttribute("ActionAt",nil)
  elseif mode=="humanoidDeath"then local h=Instance.new("Humanoid");h.Parent=m;h.Health=0
  else m.Parent=nil end
  task.wait(.45);assert(#spawned==initial,"Delayed effect survived "..mode);m:Destroy()
 end
 end
 local m=actor();local cast=factory();cast(m);task.wait(.11)
 local duplicateCount=#spawned;cast(m);assert(#spawned==duplicateCount,"Same live action replayed")
 task.wait(.7)
 local initial=#spawned;cast(m);task.wait(.4);assert(#spawned==initial,"Repeated or stale action replayed")
 m:SetAttribute("ActionAt",0/0);cast(m);assert(#spawned==initial,"Nonfinite action accepted")
 m:SetAttribute("ActionAt",workspace:GetServerTimeNow()+10);cast(m);assert(#spawned==initial,"Future action accepted")
 m:SetAttribute("ActionAt",nil);cast(m);assert(#spawned==initial,"Missing server stamp accepted")
 for _,level in ipairs({"High","Low"})do
  workspace:SetAttribute(quality,level)
  local late=actor();late:SetAttribute("ClassId","Warrior");late:SetAttribute("ActionEffect","Physical");late:SetAttribute("ActionAt",workspace:GetServerTimeNow()-.5)
  local warrior=factory();local before=#spawned;warrior(late);task.wait(.35)
  assert(#spawned==before,"Expired warrior anticipation/release/contact replayed: "..level)
  local fresh=actor();local accepted=factory();local start=#spawned;accepted(fresh);task.wait(.35)
  assert(#spawned>start,"Accepted Power Strike produced no cues: "..level)
  local observed=#spawned;accepted(fresh);assert(#spawned==observed,"Accepted Power Strike replayed: "..level)
  fresh:SetAttribute("ActionAt",workspace:GetServerTimeNow()-.5);accepted(fresh)
  assert(#spawned==observed,"Out-of-order Power Strike replayed: "..level)
  task.wait(.8)
 end
 task.wait(1)
 for _,p in ipairs(spawned)do assert(p.Parent==nil,"Effect survived bounded lifetime")end
 workspace:SetAttribute(quality,"High")
 local interrupted=actor();factory()(interrupted)
 local hand=interrupted:FindFirstChild("RightHand")
 local deadline=os.clock()+.4
 repeat task.wait(.01) until hand:FindFirstChild("GuildborneCastTrail") or os.clock()>deadline
 assert(hand:FindFirstChild("GuildborneCastTrail"),"Accepted release did not create weapon trail")
 interrupted:SetAttribute("CombatHealth",0)
 task.wait(.08)
 assert(not hand:FindFirstChild("GuildborneCastTrail") and not hand:FindFirstChild("GuildborneTrailRoot") and not hand:FindFirstChild("GuildborneTrailTip"),"Death retained weapon trail/attachments")
 return {status="PASS_LOCAL_VFX_CANCELLATION",ability="power_strike",replacement=true,death=true,streamRemoval=true,cancel=true,humanoidDeath=true,duplicateAndStale=true,nonfiniteAndFuture=true,expiredWarriorMarkers=true,acceptedHighLow=true,cleanup=true,serverDamageTested=false}
end)
connection:Disconnect()
workspace:SetAttribute(quality,originalQuality)
for _,m in ipairs(fixtures)do m:Destroy()end
for _,p in ipairs(spawned)do p:Destroy()end
assert(ok,result);return result
