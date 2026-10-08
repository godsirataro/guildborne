--!strict
-- Isolated server combat simulation using the game's existing damage/ability rules.
-- Position, clock, solo state and avatar-alive flag must come from a world adapter.
return function(deps:any)
 local util,config,trials=deps.Util,deps.Combat,deps.Trials
 local function distance(a:any,b:any):number
  local x,y,z=a.position.x-b.position.x,a.position.y-b.position.y,a.position.z-b.position.z
  return math.sqrt(x*x+y*y+z*z)
 end
 local function position(p:any):boolean
  if type(p)~="table" then return false end
  for _,key in ipairs({"x","y","z"})do if type(p[key])~="number" or not deps.Stats.valid(math.abs(p[key])) then return false end end
  return true
 end
 return function(data:any,userId:number,classId:string,runId:string,now:number):(any?,string?)
  local run,problem=trials.start(data,userId,classId,runId,now);if not run then return nil,problem end
  local tuning=deps.Tuning or {}
  local stats=deps.Stats.hero(classId,tuning.Level or 10,deps.Content.Character.Classes[classId].Weapon)
  local actor:any={id="player",owner=userId,class=classId,kind="Hero",active=true,state="Idle",stats=stats,health=stats.MaxHealth,cooldowns={},position={x=0,y=0,z=16}}
  local enemyHP=tuning.EnemyHealth or 700
  local enemy:any={id="trial_sentinel",owner=userId,kind="Enemy",active=true,state="Idle",stats={MaxHealth=enemyHP,Attack=12,Defense=0},health=enemyHP,threat={},position={x=0,y=0,z=0}}
  local patient:any={id="practice_patient",owner=userId,kind="Hero",active=true,state="Idle",stats={MaxHealth=100},health=30,position={x=0,y=0,z=-10}}
  local serial=0;local actionMode="";local clock=now;local lastStep=now;local nextWarning=now+2;local warning:any=nil;local alone=true;local alive=true
  local function condition():any return {owner=userId,runId=runId,alone=alone,health=if alive then actor.health else 0,distance=distance(actor,{position={x=0,y=0,z=0}})} end
  local function evidence(kind:string,amount:number?)
   serial+=1
   trials.observe(run,{id="combat:"..serial,runId=runId,owner=userId,actorId="player",kind=kind,restoredHP=amount,distance=distance(actor,enemy)},clock,condition())
  end
  local function emit(name:string,a:any,b:any,value:any)
   if a~=actor then return end
   if name=="hero_ability_used"and deps.AbilityLessons then evidence("skill_used")end
   if name=="damage_dealt" and b==enemy then
    if actionMode=="Basic" then evidence(if classId=="Archer" then "ranged_hit" else "basic_hit")
    elseif actionMode=="Ability" and classId=="Mage" then evidence("ability_hit") end
   elseif name=="healing_done" and b==patient then evidence("heal",value)
   elseif name=="hero_ability_used" and value=="taunt" and enemy.tauntTarget==actor and enemy.tauntUntil>clock then evidence("taunt")
   elseif name=="enemy_defeated" and b==enemy then evidence("victory") end
  end
  local target=deps.Targeting(distance)
  local damage=deps.Damage(deps.Stats,target,emit)
  local abilities=deps.Abilities(config,target,damage,emit)
  local S={}
  function S.step(at:number,p:any,isAlone:boolean,avatarAlive:boolean):string?
   if run.status~="Active" then return if run.status=="Won" then "TrialComplete" else run.problem end
   if not position(p) or type(at)~="number" or at~=at or at<lastStep or at<clock or at==math.huge then return "InvalidTrialSample" end
   clock=at;actor.position=util.copy(p);alone=isAlone;alive=avatarAlive;lastStep=at
   local gate=trials.check(run,at,condition());if gate then return gate end
   if warning and at>=warning.impactAt then
    local dx,dz=p.x-warning.x,p.z-warning.z
    if dx*dx+dz*dz<=warning.radius*warning.radius then damage.hit(enemy,actor,45,1,at)
    else evidence("dodge") end
    warning=nil;nextWarning=at+3.8
    gate=trials.check(run,at,condition());if gate then return gate end
   end
   if not warning and at>=nextWarning and enemy.health>0 then warning={x=p.x,z=p.z,radius=6,startsAt=at,impactAt=at+1.2} end
   return nil
  end
  function S.input(action:string,at:number):(boolean,string)
   if run.status~="Active" then return false,if run.status=="Won" then "TrialComplete" else run.problem end
   if type(at)~="number" or at~=at or at<clock or at==math.huge then return false,"InvalidTrialSample" end
   -- Reject stale world samples rather than attacking from an old server position.
   if at-lastStep>.5 then return false,"TrialSampleRequired" end
   clock=at;local gate=trials.check(run,at,condition());if gate then return false,gate end
   if action=="Basic" then
    if at<(actor.nextAttack or 0)then return false,"Cooldown"end
    if distance(actor,enemy)>actor.stats.AttackRange then return false,"OutOfRange"end
    actionMode="Basic";local ok=abilities.basic(actor,enemy,at);actionMode=""
    return ok,if ok then "OK" else "AttackUnavailable"
   elseif action=="Ability" or action=="Ability1" then
    local def=config.Abilities[config.Classes[classId].Ability]
    if math.max(actor.cooldowns[def.Id]or 0,actor.nextAbility or 0)>at then return false,"Cooldown"end
    local abilityTarget=if def.TargetType=="Ally"then patient else enemy
    if distance(actor,abilityTarget)>def.Range then return false,"OutOfRange"end
    actionMode="Ability";local ok,code=abilities.cast(actor,config.Classes[classId].Ability,abilityTarget,{enemy},at);actionMode="";return ok,code
   end
   return false,"InvalidAction"
  end
  function S.snapshot():any
   return {id=run.id,classId=classId,status=run.status,problem=run.problem,progress=util.copy(run.progress),expiresAt=run.expiresAt,
    playerHealth=actor.health,playerMaxHealth=actor.stats.MaxHealth,enemyHealth=enemy.health,enemyMaxHealth=enemy.stats.MaxHealth,
    patientHealth=patient.health,patientMaxHealth=patient.stats.MaxHealth,warning=util.copy(warning),position=util.copy(actor.position),
    nextAttack=actor.nextAttack or 0,nextAbility=actor.nextAbility or 0}
  end
  function S.receipt(at:number):(any?,string?) return trials.receipt(run,at,condition())end
  function S.cancel():nil run.status="Failed";run.problem="TrialCancelled";warning=nil;return nil end
  return S,nil
 end
end
