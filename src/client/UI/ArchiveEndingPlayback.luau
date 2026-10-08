--!strict
-- Optional viewport-only replay. No world camera, controls, character or server writes.
local Run=game:GetService("RunService")
local Config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local Motion=require(game.ReplicatedStorage.Shared.Presentation.ArchiveEndingMotion)
return function(preview:ViewportFrame,model:Model,frame:(number)->(),changed:(boolean)->(),manual:boolean?):any
 local original:{[BasePart]:CFrame}={}
 for _,p in ipairs(model:GetDescendants())do if p:IsA("BasePart")then original[p]=p.CFrame end end
 local playing=false;local destroyed=false;local elapsed=0;local tick:RBXScriptConnection?=nil
 local connections:{RBXScriptConnection}={};local S:any={}
 local ending=model:GetAttribute("Ending");local id=if type(ending)=="string"then ending else "unknown"
 local function visible():boolean
  local node:Instance?=preview
  while node do
   if node:IsA("GuiObject")and not node.Visible then return false end
   if node:IsA("ScreenGui")and not node.Enabled then return false end
   node=node.Parent
  end
  return preview:IsDescendantOf(game)
 end
 local function restore()
  for part,base in pairs(original)do if part.Parent then part.CFrame=base end end
  if preview.Parent then frame(0)end
 end
 function S.Stop()
  playing=false;if tick then tick:Disconnect();tick=nil end
  restore();if not destroyed then changed(false)end
 end
 function S.Step(dt:number)
  if not playing or destroyed then return end
  if not visible()or workspace:GetAttribute(Config.ReducedMotionAttribute)==true then S.Stop();return end
  if dt~=dt or dt<0 or dt==math.huge then return end
  elapsed=math.min(Motion.Duration,elapsed+dt)
  local sample=Motion.sample(id,elapsed,false)
  for part,base in pairs(original)do if part.Parent then
   if part.Name=="ArchiveRing"then
    part.CFrame=CFrame.new(0,6,-10)*CFrame.Angles(0,0,sample.ring)*CFrame.new(0,-6,10)*base
   elseif part.Name=="Canopy"or part.Name=="GardenLeaf"or part.Name=="Flower"then part.CFrame=base*CFrame.Angles(0,0,sample.leaves)
   elseif part.Name=="OpenLedger"then part.CFrame=base*CFrame.Angles(sample.pages,0,0)
   end
  end end
  frame(sample.orbit)
  if sample.finished then S.Stop()end
 end
 function S.Play():boolean
  if destroyed or workspace:GetAttribute(Config.ReducedMotionAttribute)==true or not visible()then return false end
  S.Stop();elapsed=0;playing=true;changed(true)
  if not manual then tick=Run.RenderStepped:Connect(S.Step)end
  return true
 end
 function S.IsPlaying():boolean return playing end
 function S.Destroy()
  if destroyed then return end
  S.Stop();destroyed=true
  for _,connection in ipairs(connections)do connection:Disconnect()end
  table.clear(connections);table.clear(original)
 end
 table.insert(connections,workspace:GetAttributeChangedSignal(Config.ReducedMotionAttribute):Connect(function()
  if workspace:GetAttribute(Config.ReducedMotionAttribute)==true then S.Stop()end
 end))
 table.insert(connections,preview.Destroying:Connect(S.Destroy))
 return S
end
