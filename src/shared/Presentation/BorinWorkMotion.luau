--!strict
-- Procedural adaptation of the reviewed Borin v2 anticipation/strike/rebound curve.
-- Source: tools/blender_borin_forge.py; this is not an imported animation or art rig.
local M = {Cycle=2, InteractSeconds=12, RecoverSeconds=.6, FadeSeconds=.25, CullDistance=100, DetailDistance=55}
export type State = {mode:string, weight:number, clock:number, lastTime:number?, contactIndex:number}
local function finite(n:number):boolean return n==n and math.abs(n)<math.huge end
function M.new():State return {mode="Idle",weight=0,clock=0,lastTime=nil,contactIndex=-1} end
-- Head-only attention in root-local space (-Z forward). Behind/absent speakers
-- release toward neutral instead of flipping at the atan2 seam. No root motion.
function M.lookYaw(yaw:number,dt:number,x:number?,z:number?):number
 if not finite(yaw) or not finite(dt) then return 0 end
 local limit=math.rad(55);local target=0
 if x and z and finite(x) and finite(z) and z<-.05 then
  target=math.clamp(math.atan2(-x,-z),-limit,limit)
 end
 local current=math.clamp(yaw,-limit,limit)
 local value=current+(target-current)*(1-math.exp(-math.clamp(dt,0,.1)/.18))
 return if math.abs(value)<1e-5 then 0 else value
end
-- Generic civic activity blend only; it never owns a pose or advances Borin's strike clock.
function M.activityWeight(weight:number,dt:number,working:boolean,suspended:boolean):number
 if suspended or not finite(weight) or not finite(dt) then return 0 end
 local bounded=math.clamp(weight,0,1);local elapsed=math.clamp(dt,0,.1)
 return if working then math.min(1,bounded+elapsed/M.RecoverSeconds) else math.max(0,bounded-elapsed/M.FadeSeconds)
end
function M.lift(clock:number):number
 if not finite(clock) or clock<0 then return 0 end
 local phase=(clock%M.Cycle)/M.Cycle
 if phase<.30 then return 1 elseif phase<.50 then return 1-((phase-.30)/.20)^2
 elseif phase<.60 then return .10*math.sin((phase-.50)/.10*math.pi/2) end
 local u=(phase-.60)/.40;return .10+.90*u*u*(3-2*u)
end
function M.step(s:State,now:number,interactUntil:number?,visible:boolean,reduced:boolean,moving:boolean,workEnabled:boolean?):any
 if not finite(now) then return {mode="Idle",weight=0,lift=0,contact=false} end
 local gap=if s.lastTime then now-s.lastTime else 0
 local dt=math.clamp(gap,0,.1);s.lastTime=now
 local interacting=interactUntil~=nil and finite(interactUntil) and interactUntil>now
 if not visible or reduced or moving then
  s.mode="Idle";s.weight=0;s.clock=0;s.contactIndex=-1
 elseif interacting then
  s.mode="Interact";s.weight=math.max(0,s.weight-dt/M.FadeSeconds)
 elseif workEnabled==false then
  s.mode="Idle";s.weight=math.max(0,s.weight-dt/M.FadeSeconds);s.contactIndex=-1
  if s.weight==0 then s.clock=0 end -- Keep the last pose while fading, then reset.
 else
  if s.mode=="Interact" or s.mode=="Idle" then s.mode="Recover";s.clock=0;s.contactIndex=-1 end
  if s.mode=="Recover" then
   s.weight=math.min(1,s.weight+dt/M.RecoverSeconds)
   if s.weight>=1 then s.mode="Work" end
  elseif s.mode=="Work" then s.clock+=dt end
 end
 local index=math.floor((s.clock-1)/M.Cycle)
 local contact=s.mode=="Work" and s.weight==1 and index>s.contactIndex and gap>0 and gap<=.2
 -- Advance even after a long stalled frame: never replay a backlog of contact effects.
 s.contactIndex=index
 return {mode=s.mode,weight=s.weight,lift=M.lift(s.clock),contact=contact,clock=s.clock}
end
return M
