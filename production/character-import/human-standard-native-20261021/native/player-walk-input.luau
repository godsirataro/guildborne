local s=_G.FoundationProbe;assert(s and not s.started);s.started=true
local A=require(game.ReplicatedStorage.Shared.Presentation.ModularAppearance.LocalActorPreview)
local actor=s.actors[1];local start=actor.HumanoidRootPart.Position
task.spawn(function()
 for i=1,120 do
  local h=A.Get(actor);if not h then s.error="HANDLE_LOST";break end
  local model=h.Model
  local motors={};for _,v in ipairs(model:GetDescendants()) do if v:IsA("Motor6D") and (v.Name=="LeftElbow" or v.Name=="LeftKnee") then local x,y,z=v.C0:ToOrientation();motors[v.Name]={x=x,y=y,z=z} end end
  local p=actor.HumanoidRootPart.Position
  table.insert(s.samples,{t=workspace:GetServerTimeNow(),p={p.X,p.Y,p.Z},joints=motors,diagnostics=h:GetDiagnostics()})
  task.wait(.05)
 end
 s.finished=true
end)
actor.Humanoid:MoveTo(start+Vector3.new(0,0,14))
return {sampling=true,target={start.X,start.Y,start.Z+14}}