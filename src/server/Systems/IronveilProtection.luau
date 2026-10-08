--!strict
-- Measured-time safety-shutter encounter, not an enemy combat simulation.
-- World adapter must check owner, live session and proximity before block().
return function(config:any,startedAt:number):any
 assert(type(startedAt)=="number"and startedAt==startedAt and startedAt>=0 and startedAt<math.huge)
 local status="Active";local health=config.Health;local blocks=0;local hazards=0;local last=startedAt;local nextAt=startedAt+(config.Preparation or 1);local warning:any=nil
 local valid={};for _,id in ipairs(config.Lanes)do valid[id]=true end
 local S={}
 function S.snapshot():any
  return {status=status,health=health,blocks=blocks,hazards=hazards,warning=if warning then {lane=warning.lane,impactAt=warning.impactAt,blocked=warning.blocked}else nil}
 end
 function S.step(now:number,ownerAlive:boolean,current:boolean):string
  if status~="Active"then return status end
  if type(now)~="number"or now~=now or now==math.huge or now<last then return "InvalidTime"end
  last=now
  if not current then status="Cancelled";return status end
  if not ownerAlive then status="Failed";return status end
  if warning and now>=warning.impactAt then
   if warning.blocked then blocks+=1 else health-=1 end
   warning=nil;nextAt=now+config.Interval
   if health<=0 then status="Failed";return status end
   if blocks>=config.RequiredBlocks then status="Completed";return status end
  end
  if now-startedAt>=config.Duration then status="Failed";warning=nil;return status end
  if not warning and now>=nextAt then
   hazards+=1;warning={lane=config.Lanes[(hazards-1)%#config.Lanes+1],impactAt=now+config.Warning,blocked=false}
  end
  return status
 end
 function S.block(lane:string,now:number):(boolean,string)
  if status~="Active"then return false,status end
  if not valid[lane]then return false,"UnknownLane"end
  if type(now)~="number"or now~=now or now==math.huge or now<last then return false,"InvalidTime"end
  -- A late request never protects an already-expired warning.
  if not warning or now>=warning.impactAt then return false,"NoActiveWarning"end
  if warning.blocked then return false,"AlreadyBlocked"end
  if warning.lane~=lane then return false,"WrongLane"end
  last=now;warning.blocked=true;return true,"Blocked"
 end
 function S.cancel()if status=="Active"then status="Cancelled";warning=nil end end
 return S
end
