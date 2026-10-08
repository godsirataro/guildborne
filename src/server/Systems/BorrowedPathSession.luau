--!strict
-- Temporary Class2/Class3 lesson eligibility; never changes saved class/path/skill allocation.
return function(expansion:any,util:any,makeTrial:any,pathId:string,mastery:boolean?)
 local path=assert(expansion.Paths[pathId],"Unknown borrowed path");assert(path.Tier==(if mastery then 3 else 2),"Borrowed trial tier mismatch")
 local objective=if mastery then "complete_borrowed_mastery" else "complete_borrowed_path"
 local mentor=if mastery then "meet_crosshaven_mentor" else "meet_class_mentor"
 local goals={skill_used=1,dodge=if mastery then 2 else 1,victory=1}
 local base=makeTrial({Duration=180,MaxDistance=45,MaxEvents=256,Classes={[path.Class]={Goals=goals}}},util)
 local S={Goals=goals,check=base.check,observe=base.observe}
 function S.start(data:any,userId:number,classId:string,runId:string,now:number):(any?,string?)
  local campaign=data.progression and data.progression.campaign
  if classId~=path.Class or data.character.classId~=classId then return nil,"InvalidClassPath"end
  if type(runId)~="string"or #runId<1 or #runId>55 or not runId:match("^[%w_:%-]+$")or not util.integer(userId,1,9007199254740991)or type(now)~="number"or now~=now or now<0 or now==math.huge then return nil,"InvalidTrial"end
  if not campaign or campaign.claimed~=(if mastery then 24 else 11) or not campaign.objectives[mentor] or campaign.objectives[objective] then return nil,"WrongObjective"end
  if data.character.level<(if mastery then 70 else 35) or data.personalGuild.buildings.guildHall<(if mastery then 11 else 4) then return nil,"ClassTrialLocked"end
  if data.quests.active or data.expansion.tower.active then return nil,"FinishExpedition"end
  return {id=runId,owner=userId,classId=classId,startedAt=now,expiresAt=now+180,status="Active",progress={},events={},eventCount=0},nil
 end
 function S.receipt(run:any,now:number,condition:any):(any?,string?)
  local receipt,problem=base.receipt(run,now,condition);if not receipt then return nil,problem end
  return {owner=run.owner,requestId=(if mastery then "mastery:" else "borrowed:")..run.id,action="CampaignObjective",args={objective=objective}},nil
 end
 return S
end
