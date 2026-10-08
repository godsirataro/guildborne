--!strict
-- QA-only CLIENT probe. Requires five DirectorQA preview rigs; never mapped into the game.
assert(game:GetService("RunService"):IsStudio())
local Players=game:GetService("Players")
local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local fx=require(Players.LocalPlayer.PlayerScripts.Client.Controllers.SkillEffects)()
local folder=workspace:WaitForChild("DirectorQA")
local camera=workspace.CurrentCamera :: Camera
local originalType,originalCF=camera.CameraType,camera.CFrame
camera.CameraType=Enum.CameraType.Scriptable
camera.CFrame=CFrame.lookAt(Vector3.new(0,17,-278),Vector3.new(0,3,-308))
local definitions={Warrior="Physical",Archer="Physical",Mage="Magic",Knight="Taunt",Priest="Heal"}
local rigs: {Model}={}
for _,class in ipairs({"Warrior","Archer","Mage","Knight","Priest"}) do
 local m=folder:FindFirstChild(class) :: Model
 m:SetAttribute("ActionEffect",definitions[class]);m:SetAttribute("ActionTargetPosition",m:GetPivot().Position+Vector3.new(0,0,-5))
 table.insert(rigs,m)
end
local function counts(): any
 local out={Detail=0,Primary=0,Telegraph=0,emitters=0,trails=0}
 for _,p in workspace:GetChildren() do if p.Name=="GuildborneSkillEffect" then
  assert(p:IsA("BasePart") and not p.CanCollide and not p.CanTouch and not p.CanQuery)
  local bucket=p:GetAttribute("VFXBucket");out[bucket]+=1
  for _,child in p:GetDescendants() do if child:IsA("ParticleEmitter") then assert(child.Rate==0);out.emitters+=1 elseif child:IsA("Trail") then out.trails+=1 end end
 end end
 return out
end
local function observe(seconds: number): any
 local peak=counts();local deadline=os.clock()+seconds
 repeat task.wait(.025);for key,value in counts() do peak[key]=math.max(peak[key],value) end until os.clock()>=deadline
 return peak
end
local function clearCheck()
 task.wait(1.35);local c=counts();assert(c.Detail+c.Primary+c.Telegraph==0,"Effect leak")
 for _,m in rigs do assert(not m:FindFirstChild("GuildborneCastTrail",true),"Trail leak") end
end
clearCheck()
local result: any={device=game:GetService("UserInputService").TouchEnabled and "Touch" or "Desktop",solo={},groups={}}
workspace:SetAttribute(config.QualityAttribute,"High")
for _,m in rigs do
 m:SetAttribute("ActionAt",workspace:GetServerTimeNow());fx(m)
 result.solo[config.resolve(m.Name,definitions[m.Name])]=observe(.7);clearCheck()
end
for _,quality in ipairs({"High","Low"}) do
 workspace:SetAttribute(config.QualityAttribute,quality)
 for _,m in rigs do m:SetAttribute("ActionAt",workspace:GetServerTimeNow());fx(m) end
 result.groups[quality]=observe(.8);clearCheck()
 assert(result.groups[quality].Primary>0,"Missing compact team feedback")
end
workspace:SetAttribute(config.QualityAttribute,"High")
local copies={}
for i=1,16 do local m=rigs[3]:Clone();m:SetAttribute("GuildborneHero",false);m.Parent=folder;table.insert(copies,m);fx(m) end
fx(rigs[4],true);result.saturation=observe(.7);clearCheck()
assert(result.saturation.Telegraph==8,"Telegraph was starved")
assert(result.saturation.Primary<=config.Budget.Primary and result.saturation.Detail<=(if result.device=="Touch" then config.Budget.Touch else config.Budget.Desktop))
for _,m in copies do m:Destroy() end
camera.CFrame=CFrame.lookAt(Vector3.new(0,20,-240),Vector3.new(0,3,-305));fx(rigs[3]);result.far=observe(.55);clearCheck();assert(result.far.Primary>0 and result.far.Detail==0)
camera.CFrame=CFrame.lookAt(Vector3.new(0,20,-150),Vector3.new(0,3,-305));fx(rigs[3]);result.culled=observe(.1);assert(result.culled.Primary+result.culled.Detail==0)
workspace:SetAttribute(config.QualityAttribute,"Auto")
camera.CameraType=originalType;camera.CFrame=originalCF
result.cleaned=true;_G.VFXDirectorSamples=result
return result
