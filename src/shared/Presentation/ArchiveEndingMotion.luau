--!strict
-- Deterministic cosmetic storyboard, in seconds/radians/studs. No random state.
local M={Duration=8}
function M.sample(id:string,time:number,reduced:boolean):any
 local t=if type(time)=="number" and time==time and math.abs(time)<math.huge then math.clamp(time,0,M.Duration) else 0
 local envelope=if reduced then 0 else math.sin(math.pi*t/M.Duration)^2
 local valid=id=="preserve"or id=="transform"or id=="dismantle"
 if not valid then envelope=0 end
 return {time=t,finished=t>=M.Duration,orbit=.09*math.sin(t*.55)*envelope,
  ring=if id=="preserve"or id=="transform"then .075*math.sin(t*.9)*envelope else 0,
  leaves=if id=="transform"or id=="dismantle"then .035*math.sin(t*1.5)*envelope else 0,
  pages=if id=="preserve"then .055*math.sin(t*1.4)*envelope else 0}
end
return M
