--!strict
-- Private phase authority. Positions/current-session/alive flags come from a server
-- world adapter; hit damage and IDs must come from server combat, never a Remote payload.
return function(config:any,util:any,patterns:any)
 config=util.copy(config)
 local function finite(n:any):boolean return type(n)=="number"and n==n and math.abs(n)<1e9 end
 local function point(p:any):boolean return type(p)=="table"and finite(p.x)and finite(p.y)and finite(p.z)end
 local function dist(a:any,b:any):number return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2+(a.z-b.z)^2)end
 local origin={x=0,y=0,z=0};local classes={Warrior=true,Knight=true,Archer=true,Mage=true,Priest=true}
 return function(data:any,owner:number,runId:string,modeId:string,now:number):(any?,string?)
  local mode=config.Modes[modeId];if not mode then return nil,"InvalidEncounter"end
  if not util.integer(owner,1,9007199254740991)or type(runId)~="string"or #runId<1 or #runId>55 or not runId:match("^[%w_:%-]+$")or not finite(now)or now<0 then return nil,"InvalidTrial"end
  local campaign=data.progression and data.progression.campaign
  if not campaign or campaign.claimed~=mode.Claimed or campaign.objectives[mode.Objective]or (mode.Prerequisite and not campaign.objectives[mode.Prerequisite])then return nil,"WrongObjective"end
  if not classes[data.character.classId]or data.character.level<mode.Level or data.personalGuild.buildings.guildHall<mode.Hall then return nil,"ClassTrialLocked"end
  if data.quests.active or data.expansion.tower.active then return nil,"FinishExpedition"end
  local status="Active";local phase="Ready";local stage=1;local seals=0;local rescues=0;local coreHealth=config.CoreHealth
  local started=now;local last=now;local sampleAt:number?=nil;local position:any=nil;local nextAt=now+1;local deadline=nextAt
  local warning:any=nil;local mistakes=0;local reason:string?=nil;local hitEvents={};local hitCount=0;local nextStrike=now;local rescuedStages={}
  local S={}
  local function finish(state:string,why:string?)status=state;phase="Finished";reason=why;warning=nil end
  local function advance(at:number)
   seals+=1
   if stage==#config.Patterns then finish("Won",nil)else stage+=1;phase="Ready";nextAt=at+config.RetryDelay;deadline=nextAt;coreHealth=config.CoreHealth end
  end
  local function retry(at:number,why:string)
   mistakes+=1;warning=nil
   if mistakes>=config.MaxMistakes then finish("Failed",why)else phase="Ready";nextAt=at+config.RetryDelay;deadline=nextAt;coreHealth=config.CoreHealth end
  end
  local function open(nextPhase:string,at:number)phase=nextPhase;deadline=at+config.Window;warning=nil end
  function S.snapshot():any
   return {status=status,phase=phase,stage=stage,seals=seals,rescues=rescues,mistakes=mistakes,reason=reason,deadline=deadline,expiresAt=started+config.Duration,coreHealth=coreHealth,coreMaxHealth=config.CoreHealth,
    warning=warning and util.copy(warning),target=if phase=="Rescue"then util.copy(config.RescuePoints[stage])elseif phase=="Mechanism"then util.copy(config.SealPoints[stage])elseif phase=="Attack"then util.copy(origin)else nil}
  end
  function S.step(at:number,p:any,current:boolean,alive:boolean):string
   if status~="Active"then return status end
   if not finite(at)or at<last or not point(p)then return "InvalidSample"end
   last=at;sampleAt=at;position=util.copy(p)
   if not current then finish("Cancelled","SessionChanged")elseif not alive then finish("Failed","Defeated")elseif dist(p,origin)>config.Radius then finish("Failed","LeftArena")elseif at>=started+config.Duration then finish("Failed","Expired")end
   if status~="Active"then return status end
   if phase=="Warning"and at>=deadline then
    if at-deadline>.5 then retry(at,"MissedImpactSample")
    elseif patterns.contains(warning,p)then retry(at,"WarningHit")
    else open(if mode.Rescue then "Rescue"else "Mechanism",at)end
   elseif phase~="Ready"and phase~="Warning"and at>=deadline then retry(at,"WindowExpired")end
   if status=="Active"and phase=="Ready"and at>=nextAt then
    warning=util.copy(config.Patterns[stage]);local center=if warning.targeted then p else origin
    warning.x=center.x;warning.y=center.y;warning.z=center.z
    local length=math.sqrt(p.x*p.x+p.z*p.z);warning.dx=if length>.001 then p.x/length else 0;warning.dz=if length>.001 then p.z/length else -1
    warning.duration=config.Warning;warning.due=at+config.Warning;deadline=warning.due;phase="Warning"
   end
   return status
  end
  local function gate(at:number):string?
   if status~="Active"then return status end
   if not finite(at)or at<last then return "InvalidClock"end
   if not sampleAt or at-sampleAt>.5 then return "SampleRequired"end
   if at>=started+config.Duration then return "Expired"end
   if at>=deadline then return "WindowExpired"end
   return nil
  end
  function S.act(action:string,at:number):(boolean,string)
   local problem=gate(at);if problem then return false,problem end
   local expected=if phase=="Rescue"then "Rescue"elseif phase=="Mechanism"then "Release"else nil
   if action~=expected then return false,"WrongPhase"end
   local target=if phase=="Rescue"then config.RescuePoints[stage]else config.SealPoints[stage]
   if dist(position,target)>config.InteractionRange then return false,"OutOfRange"end
   last=at
   if phase=="Rescue"then if not rescuedStages[stage]then rescuedStages[stage]=true;rescues+=1 end;open("Mechanism",at)elseif mode.Attack then open("Attack",at);nextStrike=at else advance(at)end
   return true,"OK"
  end
  function S.hit(hitId:string,amount:number,at:number):(boolean,string)
   local problem=gate(at);if problem then return false,problem end
   if phase~="Attack"then return false,"CoreShielded"end
   if type(hitId)~="string"or #hitId<1 or #hitId>64 or not hitId:match("^[%w_:%-]+$")or not finite(amount)or amount<=0 or amount>10000 then return false,"InvalidHit"end
   local previous=hitEvents[hitId]
   if previous then return false,if previous.amount==amount and previous.stage==stage then "AlreadyObserved"else "HitConflict"end
   if dist(position,origin)>config.StrikeRange then return false,"OutOfRange"end
   if at<nextStrike then return false,"Cooldown"end
   if hitCount>=config.MaxHitEvents then finish("Failed","EventLimit");return false,"EventLimit"end
   hitEvents[hitId]={amount=amount,stage=stage};hitCount+=1;last=at;nextStrike=at+config.StrikeInterval
   coreHealth=math.max(0,coreHealth-amount);if coreHealth==0 then advance(at)end
   return true,"OK"
  end
  function S.receipt(at:number,userId:number):(any?,string?)
   if userId~=owner then return nil,"ForeignTrial"end
   if not finite(at)or at<last or at>=started+config.Duration then return nil,"Expired"end
   if status~="Won"then return nil,"TrialIncomplete"end
   return {owner=owner,requestId="heart:"..runId,action="CampaignObjective",args={objective=mode.Objective}},nil
  end
  function S.cancel()if status=="Active"then finish("Cancelled","Cancelled")end end
  return S,nil
 end
end
