--!strict
-- Temporary Class2/Class3 lesson eligibility; never changes saved class/path/skill allocation.
return function(expansion:any,util:any,makeTrial:any,pathId:string,mastery:boolean?,proof:any?,currentData:any?)
 local path=assert(expansion.Paths[pathId],"Unknown borrowed path");assert(path.Tier==(if mastery then 3 else 2),"Borrowed trial tier mismatch")
 local objective=if mastery then "complete_borrowed_mastery" else "complete_borrowed_path"
 local mentor=if mastery then "meet_crosshaven_mentor" else "meet_class_mentor"
 local goals={skill_used=1,dodge=if mastery then 2 else 1,victory=1}
 local base=makeTrial({Duration=180,MaxDistance=45,MaxEvents=256,Classes={[path.Class]={Goals=goals}}},util)
 local S={Goals=goals}
 local wonRuns=setmetatable({},{__mode="k"})
 local effectRuns=setmetatable({},{__mode="k"})
 assert(not proof or mastery,"Class3 proof requires mastery")
 local function storyComplete(campaign:any):boolean
  return campaign~=nil and (campaign.claimed>24 or (campaign.claimed==24 and campaign.objectives[objective]==true))
 end
 function S.matches(data:any,run:any):boolean
  if not run.proof then return true end
  local campaign=data.progression and data.progression.campaign
  local storyReady=campaign and campaign.claimed==24 and campaign.objectives[mentor] and not campaign.objectives[objective]
  return data.profile and data.profile.userId==run.owner and proof.problem(data,"player",pathId)==nil
   and data.personalGuild.buildings.guildHall>=11 and not data.quests.active and not data.expansion.tower.active
   and util.equal(data.character,run.proof.expectedActor) and util.equal(expansion.build(data,"player"),run.proof.expectedBuild)
   and (if run.proof.sourceKind=="crosshaven_mastery" then storyReady==true else storyComplete(campaign))
 end
 function S.check(run:any,now:number,condition:any):string?
  if currentData then
   local data=currentData()
   if not data or not S.matches(data,run) then run.status="Failed";run.problem="Class3ActorChanged";return run.problem end
  end
  return base.check(run,now,condition)
 end
 function S.observe(run:any,event:any,now:number,condition:any):string?
  local gate=S.check(run,now,condition);if gate then return gate end
  if run.proof and event.kind=="victory" and not effectRuns[run]then run.status="Failed";run.problem="TrialLessonsIncomplete";return run.problem end
  local wasActive=run.status=="Active"
  local problem=base.observe(run,event,now,condition)
  if not problem and wasActive and run.status=="Won"then wonRuns[run]=true end
  return problem
 end
 -- Instrument the existing combat dependencies; never substitute a simulated win.
 -- Each Create call has its own run and cast context, including the arena's restart.
 function S.combatFactory(makeCombat:any,deps:any):any
  return function(data:any,userId:number,classId:string,runId:string,now:number):(any?,string?)
   local run:any=nil;local casting=false
   local bound=table.clone(deps);local trials=table.clone(S);bound.Trials=trials
   trials.start=function(...):(any?,string?)local value,problem=S.start(...);run=value;return value,problem end
   bound.Damage=function(stats:any,target:any,emit:any):any
    local damage=deps.Damage(stats,target,function(name:string,a:any,b:any,value:any)
     if run and run.proof and casting and a.id=="player" and a.owner==userId and type(value)=="number" and value>0
      and ((name=="damage_dealt" and b.kind=="Enemy") or name=="healing_done")then effectRuns[run]=true end
     emit(name,a,b,value)
    end)
    local hit=damage.hit
    damage.hit=function(a:any,b:any,range:number,multiplier:number,at:number):number
     local guarded=run and run.proof and expansion.Abilities[path.Skill].Effect=="Guard" and b.id=="player" and b.owner==userId
      and (b.guardUntil or 0)>at and (b.guardMultiplier or .55)<1
     local amount=hit(a,b,range,multiplier,at)
     if guarded and amount>0 then effectRuns[run]=true end
     return amount
    end
    return damage
   end
   bound.Abilities=function(config:any,target:any,damage:any,emit:any):any
    local abilities=deps.Abilities(config,target,damage,emit);local cast=abilities.cast
    abilities.cast=function(actor:any,id:string,targetActor:any,enemies:any,at:number):(boolean,string)
     casting=id==path.Skill
     local ok,code=cast(actor,id,targetActor,enemies,at);casting=false;return ok,code
    end
    return abilities
   end
   return makeCombat(bound)(data,userId,classId,runId,now)
  end
 end
 function S.start(data:any,userId:number,classId:string,runId:string,now:number):(any?,string?)
  local campaign=data.progression and data.progression.campaign
  if classId~=path.Class or data.character.classId~=classId then return nil,"InvalidClassPath"end
  if type(runId)~="string"or #runId<1 or #runId>55 or not runId:match("^[%w_:%-]+$")or not util.integer(userId,1,9007199254740991)or type(now)~="number"or now~=now or now<0 or now==math.huge then return nil,"InvalidTrial"end
  local proofEnabled=proof~=nil and expansion.usesNoviceProgression(data)
  local repeatProof=proofEnabled and storyComplete(campaign)
  if not repeatProof and (not campaign or campaign.claimed~=(if mastery then 24 else 11) or not campaign.objectives[mentor] or campaign.objectives[objective]) then return nil,"WrongObjective"end
  if data.character.level<(if mastery then 70 else 35) or data.personalGuild.buildings.guildHall<(if mastery then 11 else 4) then return nil,"ClassTrialLocked"end
  if data.quests.active or data.expansion.tower.active then return nil,"FinishExpedition"end
  local captured=nil
  if proofEnabled then
   if not data.profile or data.profile.userId~=userId then return nil,"InvalidTrial" end
   local problem=proof.problem(data,"player",pathId)
   if repeatProof and problem then return nil,problem end
   -- Latch story-only compatibility before combat for every proof-ineligible build.
   if not problem then
    local reason
    captured,reason=proof.capture(data,"player",pathId,runId,if repeatProof then "actor_mastery" else "crosshaven_mastery",if repeatProof then nil else objective)
    if not captured then return nil,reason end
   end
  end
  local run={id=runId,owner=userId,classId=classId,startedAt=now,expiresAt=now+180,status="Active",progress={},events={},eventCount=0,proof=captured}
  if currentData then local live=currentData();if not live or not S.matches(live,run)then return nil,"Class3ActorChanged"end end
  return run,nil
 end
 function S.receipt(run:any,now:number,condition:any):(any?,string?)
  local gate=S.check(run,now,condition);if gate then return nil,gate end
  local receipt,problem=base.receipt(run,now,condition);if not receipt then return nil,problem end
  if run.proof then
   if not wonRuns[run] then return nil,"TrialIncomplete"end
   run.proof.status="Won";return proof.receipt(run.proof),nil
  end
  return {owner=run.owner,requestId=(if mastery then "mastery:" else "borrowed:")..run.id,action="CampaignObjective",args={objective=objective}},nil
 end
 return S
end
