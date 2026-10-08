--!strict
-- Deterministic private training state. Adapter supplies measured time, owner proximity
-- and current-session checks; this module never changes a player, profile or real health.
return function(config:any,role:string,startedAt:number):any
 local function finite(n:any):boolean return type(n)=="number"and n==n and math.abs(n)<1e12 end
 assert(finite(startedAt)and startedAt>=0,"InvalidTime")
 assert(role=="Guard"or role=="Mend"or role=="Combined","InvalidRole")
 for _,key in ipairs({"Warning","Recovery","Interval","Duration","TargetHealth","ImpactDamage","HealAmount","RequiredSuccesses","MaxMistakes"})do assert(finite(config[key])and config[key]>0,"InvalidConfig "..key)end
 assert(config.RequiredSuccesses%1==0 and config.MaxMistakes%1==0 and config.HealAmount>=config.ImpactDamage)
 local lanes={};local health={};for _,id in ipairs(config.Targets)do assert(type(id)=="string"and #id>0 and not health[id]);table.insert(lanes,id);health[id]=config.TargetHealth end
 assert(#lanes==3,"Three targets required")
 local warningTime=config.Warning;local recoveryTime=config.Recovery;local interval=config.Interval;local duration=config.Duration
 local maximum=config.TargetHealth;local damage=config.ImpactDamage;local heal=config.HealAmount;local required=config.RequiredSuccesses;local allowedMistakes=config.MaxMistakes
 local status="Active";local phase="Ready";local cue:any=nil;local last=startedAt;local nextAt=startedAt+1
 local successes=0;local mistakes=0;local waves=0;local reason:string?=nil
 local S={}
 local function finish(state:string,why:string?)status=state;reason=why;phase="Finished";cue=nil end
 local function resolve(ok:boolean,now:number)
  if ok then successes+=1 else mistakes+=1 end
  if successes>=required then finish("Completed",nil)
  elseif mistakes>=allowedMistakes then finish("Failed","TooManyMistakes")
  else phase="Ready";cue=nil;nextAt=now+interval end
 end
 function S.snapshot():any
  local hp={};for id,value in pairs(health)do hp[id]=value end
  return {status=status,phase=phase,role=role,successes=successes,mistakes=mistakes,waves=waves,health=hp,maxHealth=maximum,reason=reason,
   cue=if cue then {target=cue.target,role=cue.role,impactAt=cue.impactAt,expiresAt=cue.expiresAt,acted=cue.acted} else nil}
 end
 function S.step(now:number,current:boolean,ownerAlive:boolean,ownerNear:boolean):string
  if status~="Active"then return status end
  if not finite(now)or now<last then return "InvalidTime"end;last=now
  if not current then finish("Cancelled","SessionChanged");return status end
  if not ownerAlive then finish("Failed","OwnerDefeated");return status end
  if not ownerNear then finish("Cancelled","LeftLesson");return status end
  if now-startedAt>=duration then finish("Failed","TimeExpired");return status end
  if phase=="Warning"and now>=cue.impactAt then
   if cue.role=="Guard"then
    if not cue.acted then health[cue.target]=math.max(0,health[cue.target]-damage)end
    resolve(cue.acted,now)
   else
    health[cue.target]=math.max(0,health[cue.target]-damage);phase="Recovery"
    -- Recovery is tied to the original impact time, not to a late heartbeat.
    if now>=cue.expiresAt then resolve(false,now)end
   end
  elseif phase=="Recovery"and now>=cue.expiresAt then resolve(false,now)end
  if status=="Active"and phase=="Ready"and now>=nextAt then
   waves+=1;local action=if role=="Combined"then (if waves%2==1 then "Guard"else "Mend")else role
   cue={target=lanes[(waves-1)%#lanes+1],role=action,impactAt=now+warningTime,expiresAt=now+warningTime+recoveryTime,acted=false};phase="Warning"
  end
  return status
 end
 function S.act(action:string,target:string,now:number):(boolean,string)
  if status~="Active"then return false,status end
  if not finite(now)or now<last then return false,"InvalidTime"end
  if now-startedAt>=duration then return false,"TimeExpired"end
  if not health[target]then return false,"UnknownTarget"end
  if action~="Guard"and action~="Mend"then return false,"UnknownAction"end
  if not cue then return false,"NoCue"end
  if action~=cue.role then return false,"WrongRole"end
  if target~=cue.target then return false,"WrongTarget"end
  if cue.acted then return false,"AlreadyActed"end
  if action=="Guard"then
   if phase~="Warning"or now>=cue.impactAt then return false,"TooLate"end
   last=now;cue.acted=true;return true,"ShieldReady"
  end
  if phase~="Recovery"then return false,"WaitForImpact"end
  if now>=cue.expiresAt then return false,"TooLate"end
  last=now;cue.acted=true;health[target]=math.min(maximum,health[target]+heal);resolve(true,now);return true,"Recovered"
 end
 function S.cancel()if status=="Active"then finish("Cancelled","Cancelled")end end
 return S
end
