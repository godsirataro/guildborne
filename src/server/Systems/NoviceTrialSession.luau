--!strict
-- Server-only, temporary trial evidence. No RemoteEvent or profile writes.
-- The future combat/world adapter owns measurements, event IDs and isolation.
return function(config:any,util:any)
 local S={}
 local function id(v:any):boolean return type(v)=="string" and #v>0 and #v<=64 and v:match("^[%w_:%-]+$")~=nil end
 local function finite(v:any):boolean return type(v)=="number" and v==v and math.abs(v)<math.huge end
 function S.start(data:any,userId:number,classId:string,runId:string,now:number):(any?,string?)
  local story=data.progression and data.progression.novice
  if not config.Classes[classId] then return nil,"InvalidClass" end
  if not id(runId) or #runId>58 or not finite(now) or now<0 or not util.integer(userId,1,9007199254740991) then return nil,"InvalidTrial" end
  if not story or story.claimed~=5 or data.character.classId or data.character.level<10 then return nil,"ClassTrialLocked" end
  if #data.party.adventurerIds~=0 or data.quests.active or data.expansion.tower.active then return nil,"SoloTrialRequired" end
  return {id=runId,owner=userId,classId=classId,startedAt=now,expiresAt=now+config.Duration,status="Active",progress={},events={},eventCount=0},nil
 end
 function S.check(run:any,now:number,condition:any):string?
  if run.status=="Failed" then return run.problem end
  local problem:string?=nil
  if not finite(now) or now<run.startedAt or now>=run.expiresAt then problem="TrialExpired"
  elseif not condition or condition.owner~=run.owner or condition.runId~=run.id then return "ForeignTrial"
  elseif condition.alone~=true then problem="SoloTrialRequired"
  elseif not finite(condition.health) or condition.health<=0 then problem="TrialDefeated"
  elseif not finite(condition.distance) or condition.distance<0 or condition.distance>config.MaxDistance then problem="TrialLeftArena" end
  if problem then run.status="Failed";run.problem=problem end
  return problem
 end
 function S.observe(run:any,event:any,now:number,condition:any):string?
  local gate=S.check(run,now,condition);if gate then return gate end
  if type(event)~="table" or not id(event.id) or event.runId~=run.id or event.owner~=run.owner or event.actorId~="player" then return "InvalidTrialEvent" end
  local goal=config.Classes[run.classId].Goals[event.kind]
  if not goal then return "WrongTrialLesson" end
  local amount=1
  if event.kind=="heal" then
   -- Actual restored HP, after clamping to target maximum, supplied by combat authority.
   if not finite(event.restoredHP) or event.restoredHP<=0 or event.restoredHP>100 then return "InvalidTrialEvent" end
   amount=event.restoredHP
  elseif event.kind=="ranged_hit" then
   if not finite(event.distance) or event.distance<12 or event.distance>45 then return "RangeLessonRequired" end
  end
  local fingerprint={kind=event.kind,amount=amount,distance=event.distance}
  local previous=run.events[event.id]
  if previous then return if util.equal(previous,fingerprint) then "AlreadyObserved" else "TrialEventConflict" end
  if run.status=="Won" then return "TrialComplete" end
  if event.kind=="victory" then
   for kind,needed in pairs(config.Classes[run.classId].Goals)do
    if kind~="victory" and (run.progress[kind] or 0)<needed then run.status="Failed";run.problem="TrialLessonsIncomplete";return run.problem end
   end
  end
  if run.eventCount>=config.MaxEvents then run.status="Failed";run.problem="TrialEventLimit";return run.problem end
  run.events[event.id]=fingerprint;run.eventCount+=1
  run.progress[event.kind]=math.min(goal,(run.progress[event.kind] or 0)+amount)
  local complete=true;for kind,needed in pairs(config.Classes[run.classId].Goals)do if (run.progress[kind] or 0)<needed then complete=false end end
  if complete then run.status="Won" end
  return nil
 end
 function S.receipt(run:any,now:number,condition:any):(any?,string?)
  local gate=S.check(run,now,condition);if gate then return nil,gate end
  if run.status~="Won" then return nil,"TrialIncomplete" end
  -- Stable receipt; delivery/replay goes through PlayerDataService.CommitNovice.
  return {requestId="trial:"..run.id,action="NoviceTrial",args={classId=run.classId},owner=run.owner},nil
 end
 return S
end
