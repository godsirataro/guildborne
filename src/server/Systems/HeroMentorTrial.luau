--!strict
-- Temporary, server-owned hero combat. No client observations and no profile mutations.
return function(rules:any,util:any,class3:any?)
 local S={}
 local wonRuns=setmetatable({}, {__mode="k"})
 local function id(v:any):boolean return type(v)=="string" and #v>0 and #v<=48 and v:match("^[%w_:%-]+$")~=nil end
 function S.problem(data:any,actorId:string,pathId:string):string?
  local hero=data.adventurers[actorId];local path=rules.Paths[pathId]
  if actorId=="player" or not hero then return "HeroUnavailable" end
  if not path or path.Tier~=2 or path.Class~=hero.classId then return "InvalidClassPath"end
  if not rules.usesNoviceProgression(data) then return "HeroMentorUnavailable"end
  if rules.build(data,actorId).tier~=1 then return "InvalidClassPath"end
  if hero.level<35 or data.personalGuild.buildings.guildHall<4 then return "ClassTrialLocked"end
  if hero.condition and hero.condition~="Healthy" then return "HeroUnavailable"end
  for _,job in pairs(data.settlement.jobs)do if table.find(job.members,actorId)then return "HeroUnavailable"end end
  if data.quests.active or data.expansion.tower.active then return "FinishExpedition"end
  if not data.quests.firstClears.quarry_patrol then return "AdvancementLocked"end
  if not table.find(data.party.adventurerIds,actorId) then return "PartyRequired"end
  return nil
 end
 -- Read-only presentation uses the same eligibility rules as private receipt/advancement.
 function S.presentation(data:any):any
  local actors={}
  if not rules.usesNoviceProgression(data) then return actors end
  for actorId,hero in pairs(data.adventurers)do
   local paths={};local proof=rules.build(data,actorId).mentorProof
   for pathId,path in pairs(rules.Paths)do if path.Tier==2 and path.Class==hero.classId then
    local ready=proof~=nil and proof.pathId==pathId
    local problem=S.problem(data,actorId,pathId)
    paths[pathId]={ready=ready,problem=problem,advanceProblem=problem or (if ready then nil else "HeroMentorRequired")}
   end end
   actors[actorId]=paths
  end
  return actors
 end
 function S.sessionView(entry:any):any?
  if not entry then return nil end
  return {status=if entry.delivery then "Saving" else "Active",actorId=entry.run.actorId,pathId=entry.run.pathId}
 end
 function S.start(data:any,owner:number,actorId:string,pathId:string,runId:string,now:number):(any?,string?)
  local problem=S.problem(data,actorId,pathId);if problem then return nil,problem end
  if not id(runId) or not util.integer(owner,1,9007199254740991) or type(now)~="number" or now~=now or now<0 or now==math.huge then return nil,"InvalidTrial"end
  return {id=runId,owner=owner,actorId=actorId,pathId=pathId,hero=util.copy(data.adventurers[actorId]),build=util.copy(rules.build(data,actorId)),startedAt=now,expiresAt=now+180,status="Active"},nil
 end
 function S.class3ActivityProblem(data:any,actorId:string):string?
  local hero=data.adventurers[actorId]
  if actorId=="player" or not hero then return "HeroUnavailable" end
  if hero.condition and hero.condition~="Healthy" then return "HeroUnavailable" end
  for _,job in pairs(data.settlement.jobs)do if table.find(job.members,actorId)then return "HeroUnavailable"end end
  if data.quests.active or data.expansion.tower.active then return "FinishExpedition"end
  if not table.find(data.party.adventurerIds,actorId)then return "PartyRequired"end
  return nil
 end
 function S.class3Problem(data:any,actorId:string,pathId:string):string?
  if not class3 then return "Class3TrialUnavailable" end
  local activity=S.class3ActivityProblem(data,actorId);if activity then return activity end
  if not rules.usesNoviceProgression(data) then return "Class3TrialUnavailable" end
  return class3.problem(data,actorId,pathId)
 end
 function S.startClass3(data:any,owner:number,actorId:string,pathId:string,runId:string,now:number):(any?,string?)
  local problem=S.class3Problem(data,actorId,pathId);if problem then return nil,problem end
  if owner~=data.profile.userId or not id(runId) or type(now)~="number" or now~=now or now<0 or now==math.huge then return nil,"InvalidTrial"end
  local proof,err=class3.capture(data,actorId,pathId,runId,"actor_mastery");if not proof then return nil,err end
  return {id=runId,owner=proof.owner,actorId=actorId,pathId=pathId,hero=util.copy(proof.expectedActor),build=util.copy(proof.expectedBuild),proof=proof,startedAt=now,expiresAt=now+180,status="Active"},nil
 end
 function S.matches(data:any,run:any):boolean
  return (if run.proof then data.profile.userId==run.owner and S.class3Problem(data,run.actorId,run.pathId)==nil else S.problem(data,run.actorId,run.pathId)==nil) and util.equal(data.adventurers[run.actorId],run.hero) and util.equal(rules.build(data,run.actorId),run.build)
 end
 function S.receipt(run:any):any?
  if run.status~="Won" then return nil end
  if run.proof then
   if not class3 or not wonRuns[run] then return nil end
   local proof=util.copy(run.proof);proof.status="Won";return class3.receipt(proof)
  end
  return {owner=run.owner,requestId="mentor:"..run.id,action="HeroMentorProof",args={actorId=run.actorId,pathId=run.pathId,trialId=run.id,hero=util.copy(run.hero),build=util.copy(run.build)}}
 end
 function S.commit(record:any,command:any):(any,any,any)
  local a=command.args;local d=record.data
  if command.action~="HeroMentorProof" or type(a)~="table" or not id(a.trialId) then return nil,{code="InvalidReceipt"},{}end
  local problem=S.problem(d,a.actorId,a.pathId);if problem then return nil,{code=problem},{}end
  if not util.equal(d.adventurers[a.actorId],a.hero) or not util.equal(rules.build(d,a.actorId),a.build) then return nil,{code="HeroChanged"},{}end
  local copy=util.copy(record);local builds=copy.data.expansion.actors
  builds[a.actorId]=builds[a.actorId] or {tier=1,skills={}}
  if builds[a.actorId].mentorProof and builds[a.actorId].mentorProof.pathId==a.pathId then return nil,{code="HeroMentorAlreadyProven"},{}end
  builds[a.actorId].mentorProof={version=1,pathId=a.pathId,trialId=a.trialId}
  return copy,{code="OK"},{{name="hero_mentor_completed",payload={actorId=a.actorId,pathId=a.pathId}}}
 end
 -- Same ability/damage/target rules as the game. The world adapter supplies actual positions.
 function S.combat(run:any,deps:any):any
  local skill=rules.Paths[run.pathId].Skill;local def=rules.Abilities[skill]
  local actor:any={id=run.actorId,owner=run.owner,class=run.hero.classId,kind="Hero",active=true,state="Idle",stats=deps.stats,health=deps.stats.MaxHealth,cooldowns={},allowedAbilities={skill},position={x=0,y=0,z=4}}
  local enemyHP=math.max(600,math.ceil(deps.stats.Attack*12))
  local enemy:any={id="mentor_construct",owner=run.owner,kind="Enemy",active=true,state="Idle",stats={MaxHealth=enemyHP,Attack=8,Defense=0},health=enemyHP,threat={},position={x=0,y=0,z=0}}
  local patient:any={id="mentor_patient",owner=run.owner,kind="Hero",active=true,state="Idle",stats={MaxHealth=100,Defense=0},health=20,position={x=0,y=0,z=6}}
  actor.allies={actor,patient}
  local used,effect,victory=false,false,false;local mode="";local clock=run.startedAt;local hits=0;local nextHit=clock+2
  local function emit(name:string,a:any,b:any,value:any)
   if a==actor then
    if name=="hero_ability_used" and value==skill then used=true end
    if mode=="Ability" and name=="damage_dealt" and b==enemy and value>0 then effect=true end
    if mode=="Ability" and name=="healing_done" and b==patient and value>0 then effect=true end
    if name=="enemy_defeated" and b==enemy then victory=true end
   elseif a==enemy and b==actor and name=="damage_dealt" then
    hits+=1
    if def.Effect=="Guard" and (actor.guardUntil or 0)>clock and value>0 then effect=true end
   end
   if deps.emit then deps.emit(name,a,b,value)end
  end
  local target=deps.Targeting(function(a:any,b:any)local x,y,z=a.position.x-b.position.x,a.position.y-b.position.y,a.position.z-b.position.z;return math.sqrt(x*x+y*y+z*z)end)
  local damage=deps.Damage(deps.Stats,target,emit);local abilities=deps.Abilities(deps.config,target,damage,emit)
  local C={actor=actor,enemy=enemy,patient=patient}
  function C.step(now:number,position:any):string
   if run.status~="Active"then return run.status end
   if type(now)~="number" or now~=now or now<clock or now>=run.expiresAt then run.status="Failed";return run.status end
   clock=now
   for _,key in ipairs({"x","y","z"})do if type(position[key])~="number" or position[key]~=position[key] or math.abs(position[key])>40 then run.status="Failed";return run.status end end
   actor.position=util.copy(position)
   -- A support art must produce a real effect; a successful call alone is insufficient.
   if enemy.health>0 then
    mode="Ability";abilities.cast(actor,skill,if def.TargetType=="Ally"then patient else enemy,{enemy},now);mode=""
    if now>=nextHit then nextHit=now+3;damage.hit(enemy,actor,40,1,now)end
    -- Retaliation must be observed before the final blow, including high-level gear.
    if hits>=3 then mode="Basic";abilities.basic(actor,enemy,now);mode="" end
   end
   -- Cast emits its success event after damage. Evaluate only after the whole step.
   if actor.health<=0 then run.status="Failed"
   elseif victory then run.status=if used and effect and hits>=3 then "Won" else "Failed"end
   local outcome=run.status :: string
   if outcome=="Won" then wonRuns[run]=true end
   return run.status
  end
  function C.snapshot():any return {status=run.status,heroHealth=actor.health,enemyHealth=enemy.health,skill=skill,used=used,effect=effect,hits=hits}end
  return C
 end
 return S
end
