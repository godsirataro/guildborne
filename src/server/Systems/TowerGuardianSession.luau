--!strict
-- Admission and authoritative combat evidence only; no profile writes.
return function(config:any,util:any,makeTrial:any):any
 local goals=util.copy(config.Goals);local classes={}
 for _,class in ipairs({"Warrior","Knight","Archer","Mage","Priest"})do classes[class]={Goals=goals}end
 local base=makeTrial({Duration=config.Duration,MaxDistance=config.MaxDistance,MaxEvents=config.MaxEvents,Classes=classes},util)
 local claimed,level,hall,duration,objective=config.Claimed,config.Level,config.Hall,config.Duration,config.Objective
 local S={Goals=util.copy(goals),check=base.check,observe=base.observe}
 function S.start(data:any,userId:number,classId:string,runId:string,now:number):(any?,string?)
  if not classes[classId]or data.character.classId~=classId then return nil,"InvalidClass"end
  if type(runId)~="string"or #runId<1 or #runId>55 or not runId:match("^[%w_:%-]+$")or not util.integer(userId,1,9007199254740991)or type(now)~="number"or now~=now or now<0 or now==math.huge then return nil,"InvalidTrial"end
  local campaign=data.progression and data.progression.campaign
  if not campaign or campaign.claimed~=claimed or campaign.objectives[objective]then return nil,"WrongObjective"end
  if data.character.level<level or data.personalGuild.buildings.guildHall<hall then return nil,"ClassTrialLocked"end
  if data.quests.active or data.expansion.tower.active then return nil,"FinishExpedition"end
  return {id=runId,owner=userId,classId=classId,startedAt=now,expiresAt=now+duration,status="Active",progress={},events={},eventCount=0},nil
 end
 function S.receipt(run:any,now:number,condition:any):(any?,string?)
  local receipt,problem=base.receipt(run,now,condition);if not receipt then return nil,problem end
  return {owner=run.owner,requestId="ledger:"..run.id,action="CampaignObjective",args={objective=objective}},nil
 end
 return S
end
