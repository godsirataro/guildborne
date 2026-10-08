--!strict
-- Course eligibility plus the same measured evidence checks used by solo trials.
return function(lessonId:string,lesson:any,util:any,makeTrial:any)
 local classes={};for _,id in ipairs({"Warrior","Knight","Archer","Mage","Priest"})do classes[id]={Goals=lesson.Goals}end
 local base=makeTrial({Duration=300,MaxDistance=45,MaxEvents=128,Classes=classes},util)
 local S={check=base.check,observe=base.observe}
 function S.start(data:any,userId:number,classId:string,runId:string,now:number):(any?,string?)
  local story=data.progression and data.progression.novice
  if not classes[classId]or (lesson.Class and lesson.Class~=classId)then return nil,"InvalidClass"end
  if type(runId)~="string"or #runId<1 or #runId>57 or not runId:match("^[%w_:%-]+$")or not util.integer(userId,1,9007199254740991)or type(now)~="number"or now~=now or now<0 or now==math.huge then return nil,"InvalidTrial"end
  if not story or story.claimed~=lesson.Claimed or data.character.level<lesson.Level or story.objectives[lessonId]then return nil,"WrongObjective"end
  if lesson.SelectedClass then if data.character.classId~=classId then return nil,"ClassTrialRequired"end
  elseif data.character.classId then return nil,"ClassAlreadySelected"end
  if #data.party.adventurerIds~=0 or data.quests.active or data.expansion.tower.active then return nil,"SoloTrialRequired"end
  return {id=runId,owner=userId,classId=classId,startedAt=now,expiresAt=now+300,status="Active",progress={},events={},eventCount=0},nil
 end
 function S.receipt(run:any,now:number,condition:any):(any?,string?)
  local receipt,problem=base.receipt(run,now,condition);if not receipt then return nil,problem end
  return {owner=run.owner,requestId="lesson:"..run.id,action="NoviceObjective",args={objective=lessonId}},nil
 end
 return S
end
