local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local player=Players.LocalPlayer
local model
for _,m in ipairs(game:GetService("CollectionService"):GetTagged("GuildborneFriendlyNPC")) do if m:GetAttribute("NpcId")=="smith_borin" then assert(not model,"duplicate");model=m end end
assert(model and model.PrimaryPart and not model:GetAttribute("DetailedBorinPreview"))
local root=model.PrimaryPart
local flash=assert(model:FindFirstChild("BorinContactFlash",true))
local tip=assert(model:FindFirstChild("BorinHammerContact",true))
local target=assert(model:FindFirstChild("BorinContactTarget",true))
local joints={}
for _,m in ipairs(model:GetDescendants()) do if m:IsA("Motor6D") and (m.Name=="RightUpperArm" or m.Name=="RightLowerArm" or m.Name=="RightHand") then joints[m.Name]=m end end
assert(joints.RightUpperArm and joints.RightLowerArm and joints.RightHand)
local start=workspace:GetServerTimeNow()
local prior={} local priorQuiet=false local rootStart=root.CFrame
local out={frames=0,workJointChanges={RightUpperArm=0,RightLowerArm=0,RightHand=0},quietArmChanges=0,forbiddenFlashFrames=0,rootChanges=0,rows={}}
local oldKey
repeat
Run.RenderStepped:Wait()
local now=workspace:GetServerTimeNow()
local mode=model:GetAttribute("BorinLocalPresentationState")
local weight=model:GetAttribute("BorinLocalWorkWeight")
local activity=model:GetAttribute("NpcLifeActivity")
local distance=(workspace.CurrentCamera.CFrame.Position-root.Position).Magnitude
local quiet=mode=="Idle" and weight==0
out.frames+=1
if root.CFrame~=rootStart then out.rootChanges+=1 end
if flash.Enabled and (mode~="Work" or distance>55) then out.forbiddenFlashFrames+=1 end
for name,joint in pairs(joints) do
if prior[name] and prior[name]~=joint.C0 then
if mode=="Work" then out.workJointChanges[name]+=1 end
if quiet and priorQuiet then out.quietArmChanges+=1 end
end
prior[name]=joint.C0
end
local key=tostring(mode)..":"..tostring(activity)..":"..tostring(flash.Enabled)
if key~=oldKey then
table.insert(out.rows,{t=now-start,mode=mode,activity=activity,weight=weight,clock=model:GetAttribute("BorinLocalWorkClock"),distance=distance,flash=flash.Enabled,gap=(tip.WorldPosition-target.WorldPosition).Magnitude})
oldKey=key
end
priorQuiet=quiet
until workspace:GetServerTimeNow()-start>=48
out.seconds=workspace:GetServerTimeNow()-start
return game:GetService("HttpService"):JSONEncode(out)