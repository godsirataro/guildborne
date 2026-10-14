-- Isolated Memory-only integration study. Authored local mesh, no uploaded asset ID.
-- The authoritative NPC, quest prompt, location and rewards stay on the server rig.
local Run=game:GetService("RunService")
local Collection=game:GetService("CollectionService")
local root=game.ReplicatedStorage:WaitForChild("IntegrationArt")
local player=game.Players.LocalPlayer
local Audio=require(player:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("AudioController"))
assert(game.PlaceId==0 and game.GameId==0,"Local preview only")
local active=nil
local building=false
local stopped=false
local failed=setmetatable({},{__mode="k"})
local function clear()
 if not active then return end
 local a=active;active=nil
 a.model:SetAttribute("DetailedBorinPreview",nil)
 for part,old in pairs(a.hidden)do if part.Parent then part.LocalTransparencyModifier=old end end
 for label,old in pairs(a.labels)do if label.Parent then label.StudsOffsetWorldSpace=old end end
 a.review:Destroy()
end
local function add(model)
 if stopped or building or active or failed[model] or model:GetAttribute("NpcId")~="smith_borin" then return end
 if not model.PrimaryPart or not model:IsDescendantOf(workspace)then return end
 building=true
 local review=nil
 local ok,result=pcall(function()
  review=require(root.NativeReview)()
  review:Add("borin",Vector3.zero,require(root.Data))
  require(root.Effects)(review)
 end)
 building=false
 if not ok or stopped or not model:IsDescendantOf(workspace) or not Collection:HasTag(model,"GuildborneFriendlyNPC")then
  if not ok then failed[model]=true;warn("Detailed Borin preview unavailable",result)end
  if review then review:Destroy()end
  return
 end
 local actor=review.actors[1]
 actor.part:SetAttribute("SourceSha256",root:GetAttribute("SourceSha256"))
 actor.part:SetAttribute("LocalAuthoredPreview",true)
 local hidden={};local labels={}
 for _,part in ipairs(model:GetDescendants())do
  if part:IsA("BasePart")then hidden[part]=part.LocalTransparencyModifier;part.LocalTransparencyModifier=1 end
  if part:IsA("BillboardGui")then labels[part]=part.StudsOffsetWorldSpace;part.StudsOffsetWorldSpace+=Vector3.new(0,2,0)end
 end
 model:SetAttribute("DetailedBorinPreview",true)
 local clock=model:GetAttribute("BorinLocalWorkClock")or 0
 active={model=model,review=review,actor=actor,hidden=hidden,labels=labels,time=clock,weight=1,lastStrike=math.floor((clock-1)/2)}
end
local added=Collection:GetInstanceAddedSignal("GuildborneFriendlyNPC"):Connect(add)
local removed=Collection:GetInstanceRemovedSignal("GuildborneFriendlyNPC"):Connect(function(model)if active and active.model==model then clear()end end)
local frame=Run.RenderStepped:Connect(function(dt)
 local a=active;if not a then return end
 local pivot=a.model.PrimaryPart
 if not pivot or not a.model:IsDescendantOf(workspace)then clear();return end
 local camera=workspace.CurrentCamera
 local far=not camera or (camera.CFrame.Position-pivot.Position).Magnitude>100
 local state=a.model:GetAttribute("BorinLocalPresentationState")or "Idle"
 a.weight=a.model:GetAttribute("BorinLocalWorkWeight")or 0
 a.time=a.model:GetAttribute("BorinLocalWorkClock")or 0
 a.actor.part.CFrame=pivot.CFrame*CFrame.new(0,.24,0)*CFrame.Angles(0,math.pi,0)
 a.actor.part.LocalTransparencyModifier=if far then 1 else 0
 a.review:Frame(a.time)
 for i,bone in ipairs(a.actor.bones)do
  local neutral=CFrame.new(table.unpack(a.actor.data.frames[1][i]))
  bone.Transform=neutral:Lerp(bone.Transform,a.weight)
 end
 if a.weight<.99 or far then
  for _,part in ipairs(a.review.effects.borin.parts)do part.Transparency=1 end
 end
 local strike=math.floor((a.time-1)/2)
 if strike<a.lastStrike then a.lastStrike=strike end
 if strike>a.lastStrike then
  a.lastStrike=strike
  if a.weight>.99 and not far and dt>0 and dt<=.2 then Audio.PlayFor(a.model,"forge_strike",a.actor.part.CFrame:PointToWorldSpace(Vector3.new(.35,2.70,1.45)))end
 end
 a.actor.part:SetAttribute("WorkState",state)
end)
script.Destroying:Connect(function()stopped=true;frame:Disconnect();added:Disconnect();removed:Disconnect();clear()end)
for _,model in ipairs(Collection:GetTagged("GuildborneFriendlyNPC"))do add(model)end
