--!strict
-- Server-only bridge: clients select an action, never damage, targets, or hit IDs.
return function(deps:any)
 local util,config=deps.Util,deps.Combat
 return function(data:any,owner:number,runId:string,mode:string,now:number):(any?,string?)
  local run,problem=deps.Create(data,owner,runId,mode,now);if not run then return nil,problem end
  local class=data.character.classId
  local stats=deps.Stats.hero(class,data.character.level,deps.Content.Character.Classes[class].Weapon)
  if not stats then return nil,"InvalidStats"end
  local actor:any={id="player",owner=owner,class=class,kind="Hero",active=true,state="Idle",stats=stats,health=stats.MaxHealth,cooldowns={},position={x=0,y=0,z=16}}
  local enemy:any={id="archive_core",owner=owner,kind="Enemy",active=true,state="Idle",stats={MaxHealth=run.snapshot().coreMaxHealth,Defense=0},health=run.snapshot().coreHealth,threat={},position={x=0,y=0,z=0}}
  local clock=now;local sampleAt=now;local serial=0;local nextDamage=now;local receiptProblem:string?=nil
  local function distance(a:any,b:any):number local p,q=a.position,b.position;return math.sqrt((p.x-q.x)^2+(p.y-q.y)^2+(p.z-q.z)^2)end
  local targeting=deps.Targeting(distance)
  local function emit(name:string,a:any,b:any,amount:any)
   if name=="damage_dealt"and a==actor and b==enemy then
    serial+=1;local ok,code=run.hit("combat:"..serial,amount,clock)
    if not ok then receiptProblem=code;run.cancel()end
    nextDamage=clock+deps.EncounterConfig.StrikeInterval
   end
  end
  local damage=deps.Damage(deps.Stats,targeting,emit)
  local abilities=deps.Abilities(config,targeting,damage,emit)
  local S={}
  function S.step(at:number,p:any,current:boolean,alive:boolean):string
   local result=run.step(at,p,current,alive)
   if result=="InvalidSample"then return result end
   if at>=clock then clock=at;sampleAt=at;actor.position=util.copy(p)end
   return result
  end
  function S.act(action:string,at:number):(boolean,string)return run.act(action,at)end
  function S.input(action:string,at:number):(boolean,string)
   local view=run.snapshot()
   if view.status~="Active"then return false,view.status end
   if type(at)~="number"or at~=at or at==math.huge or at<clock then return false,"InvalidClock"end
   if at-sampleAt>.5 then return false,"SampleRequired"end
   if view.phase~="Attack"then return false,"CoreShielded"end
   if at>=view.deadline then return false,"WindowExpired"end
   if action~="Basic"and action~="Ability"then return false,"InvalidAction"end
   if at<nextDamage then return false,"Cooldown"end
   clock=at;enemy.health=view.coreHealth;enemy.state="Idle";enemy.active=true
   if distance(actor,enemy)>deps.EncounterConfig.StrikeRange then return false,"OutOfRange"end
   if action=="Basic"then
    if at<(actor.nextAttack or 0)then return false,"Cooldown"end
    if distance(actor,enemy)>stats.AttackRange then return false,"OutOfRange"end
    local ok=abilities.basic(actor,enemy,at)
    if receiptProblem then return false,receiptProblem end
    return ok,if ok then "OK"else "AttackUnavailable"
   end
   local id=config.Classes[class].Ability;local def=config.Abilities[id]
   local target=if def.TargetType=="Ally"then actor else enemy
   if distance(actor,target)>def.Range then return false,"OutOfRange"end
   local ok,code=abilities.cast(actor,id,target,{enemy},at)
   if receiptProblem then return false,receiptProblem end
   return ok,code
  end
  function S.snapshot():any local v=run.snapshot();v.nextAttack=math.max(actor.nextAttack or 0,nextDamage);v.nextAbility=math.max(actor.nextAbility or 0,nextDamage);v.combatHits=serial;return v end
  function S.receipt(at:number,userId:number):(any?,string?)return run.receipt(at,userId)end
  function S.cancel()run.cancel()end
  return S,nil
 end
end
