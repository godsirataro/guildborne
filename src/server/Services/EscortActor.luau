--!strict
-- Server-driven physical presentation for EscortRun. No reward or profile access.
-- readEvidence must read the owning session and live character on the server.
local RunService=game:GetService("RunService")
local makeRun=require(script.Parent.Parent.Systems.EscortRun)
return function(model:Model,route:{Vector3},solids:{Instance},readEvidence:()->any,onComplete:(any)->(),manual:boolean?):any
 assert(model.PrimaryPart and #route>=2,"Escort requires a rooted model and route")
 local points={};for _,p in ipairs(route)do table.insert(points,{x=p.X,y=p.Y,z=p.Z})end
 local run=makeRun(points,5);local destroyed=false;local delivered=false
 local root=model.PrimaryPart :: BasePart
 assert(root.Anchored,"Escort root must be server anchored")
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances=solids;overlap.RespectCanCollide=true
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=solids;ray.RespectCanCollide=true
 local frame:RBXScriptConnection?=nil
 local S={}
 model:PivotTo(CFrame.new(route[1]));model:SetAttribute("EscortMoving",false)
 local function point(p:any):Vector3 return Vector3.new(p.x,p.y,p.z)end
 function S.Step(dt:number):any
  if destroyed then return run.snapshot()end
  local before=run.snapshot();local measured=readEvidence()
  if not model.Parent or not root.Parent then
   run.cancel("ModelRemoved");if frame then frame:Disconnect();frame=nil end;destroyed=true;return run.snapshot()
  end
  local position=point(before.position)
  local target=route[math.min(before.next,#route)]
  local delta=target-position;local span=delta.Magnitude
  local nextPosition=position+(if span>.001 then delta.Unit*math.min(span,5*math.min(dt,.25))else Vector3.zero)
  local blockers=workspace:GetPartBoundsInBox(CFrame.new(nextPosition+Vector3.new(0,2.8,0)),Vector3.new(3.4,5.4,3.4),overlap)
  local ground=workspace:Raycast(nextPosition+Vector3.new(0,1,0),Vector3.new(0,-2.5,0),ray)
  local ownerPosition=measured.position
  local state=run.step(dt,{ownerAlive=measured.alive==true,ownerDistance=if typeof(ownerPosition)=="Vector3"then (ownerPosition-position).Magnitude else 999999,exitDistance=if typeof(ownerPosition)=="Vector3"then (ownerPosition-route[#route]).Magnitude else 999999,npcAlive=measured.npcAlive~=false,blocked=#blockers>0 or ground==nil,sessionCurrent=measured.current==true})
  local nextPoint=point(state.position);local movement=nextPoint-position
  if movement.Magnitude>.001 then
   local flat=Vector3.new(movement.X,0,movement.Z)
   model:PivotTo(if flat.Magnitude>.001 then CFrame.lookAt(nextPoint,nextPoint+flat)else CFrame.new(nextPoint))
  end
  model:SetAttribute("EscortMoving",movement.Magnitude>.001);model:SetAttribute("EscortStatus",state.status);model:SetAttribute("EscortReason",state.reason)
  if state.status=="Completed"and not delivered then
   delivered=true
   -- Re-read the session before issuing evidence; the consumer must persist idempotently.
   local current=readEvidence()
   if current.current==true and current.alive==true then onComplete(state)end
  end
  if state.status=="Completed"or state.status=="Failed"or state.status=="Cancelled"then if frame then frame:Disconnect();frame=nil end end
  return state
 end
 function S.Snapshot():any return run.snapshot()end
 function S.Destroy()
  if destroyed then return end;destroyed=true
  if frame then frame:Disconnect();frame=nil end
  run.cancel("Destroyed");if model.Parent then model:SetAttribute("EscortMoving",false)end
 end
 if not manual then frame=RunService.Heartbeat:Connect(S.Step)end
 return S
end
