local s=_G.FoundationProbe;assert(s and not s.started);s.started=true
local A=require(game.ReplicatedStorage.Shared.Presentation.ModularAppearance.LocalActorPreview)
local P=require(game.ReplicatedStorage.Shared.Presentation.ModularAppearance.LocalGeometryPreview)
task.spawn(function()
 for i=1,140 do
  local row={t=workspace:GetServerTimeNow(),actors={}}
  for index,actor in ipairs(s.actors) do
   local h=A.Get(actor);if not h then s.error="HANDLE_LOST";break end
   local joints={}
   for _,v in ipairs(h.Model:GetDescendants()) do if v:IsA("Motor6D") and (v.Name=="LeftElbow" or v.Name=="LeftKnee") then local x,y,z=v.C0:ToOrientation();joints[v.Name]={x=x,y=y,z=z} end end
   local p=actor.HumanoidRootPart.Position
   table.insert(row.actors,{id=if index==1 then "player" else actor:GetAttribute("AdventurerId"),p={p.X,p.Y,p.Z},joints=joints,diagnostics=h:GetDiagnostics(),hp=actor:GetAttribute("CombatHealth")})
  end
  row.backings=P.BackingResourceCount();row.refs=P.ResourceCount()
  table.insert(s.samples,row);task.wait(.05)
 end
 s.finished=true
end)
local p=s.actors[1].HumanoidRootPart.Position;s.actors[1].Humanoid:MoveTo(p+Vector3.new(0,0,25))
return {sampling=true,actors=2,backings=P.BackingResourceCount(),refs=P.ResourceCount(),ordinaryMoveTo=true}