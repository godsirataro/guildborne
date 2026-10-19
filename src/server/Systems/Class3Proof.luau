--!strict
-- Private domain only. Trusted trial producers own combat and session fencing;
-- the existing transaction executor owns revision checks, replay and persistence.
return function(rules:any,util:any,campaign:any?)
 local S={}
 local function id(value:any):boolean
  return type(value)=="string" and #value>0 and #value<=48 and value:match("^[%w_:%-]+$")~=nil
 end
 local function mode(actorId:any,sourceKind:any,objective:any):boolean
  return (sourceKind=="actor_mastery" and objective==nil)
   or (sourceKind=="crosshaven_mastery" and actorId=="player" and objective=="complete_borrowed_mastery")
 end
 function S.problem(data:any,actorId:any,pathId:any):string?
  if type(actorId)~="string" then return "ActorNotReady" end
  local actor=rules.actor(data,actorId)
  if not actor or not actor.classId then return "ActorNotReady" end
  local path=if type(pathId)=="string" then rules.Paths[pathId] else nil
  local build=rules.build(data,actorId)
  local parent=build.path and rules.Paths[build.path]
  if not path or path.Tier~=3 or build.tier~=2 or not parent or parent.Tier~=2 or parent.Class~=actor.classId then return "InvalidClassPath" end
  return rules.advanceProblem(data,actor,build,pathId)
 end
 function S.hasProof(data:any,actorId:any,pathId:any):boolean
  if type(actorId)~="string" then return false end
  local proof=rules.build(data,actorId).class3Proof
  return rules.validClass3Proof(data,actorId,proof) and proof.pathId==pathId
 end
 function S.advanceProblem(data:any,actorId:any,pathId:any):string?
  local problem=S.problem(data,actorId,pathId);if problem then return problem end
  if rules.usesNoviceProgression(data) and not S.hasProof(data,actorId,pathId) then return "Class3ProofRequired" end
  return nil
 end
 function S.capture(data:any,actorId:any,pathId:any,trialId:any,sourceKind:any,storyObjective:any?):(any?,string?)
  if not id(trialId) or not mode(actorId,sourceKind,storyObjective) or not data.profile or not util.integer(data.profile.userId,1,9007199254740991) then return nil,"InvalidReceipt" end
  if not rules.usesNoviceProgression(data) then return nil,"Class3TrialUnavailable" end
  local problem=S.problem(data,actorId,pathId);if problem then return nil,problem end
  return {owner=data.profile.userId,actorId=actorId,pathId=pathId,trialId=trialId,sourceKind=sourceKind,storyObjective=storyObjective,
   expectedActor=util.copy(rules.actor(data,actorId)),expectedBuild=util.copy(rules.build(data,actorId)),status="Active"},nil
 end
 function S.receipt(run:any):any?
  if type(run)~="table" or run.status~="Won" or not id(run.trialId) then return nil end
  return {owner=run.owner,requestId="class3:"..run.trialId,action="Class3Proof",args={actorId=run.actorId,pathId=run.pathId,
   trialId=run.trialId,sourceKind=run.sourceKind,storyObjective=run.storyObjective,expectedActor=util.copy(run.expectedActor),expectedBuild=util.copy(run.expectedBuild)}}
 end
 function S.apply(record:any,command:any):(any,any,any)
  local function reject(code:string):(any,any,any) return nil,{code=code},{} end
  if type(command)~="table" or command.action~="Class3Proof" or type(command.args)~="table" then return reject("InvalidReceipt") end
  local a=command.args;local data=record.data
  for key in pairs(a)do
   if key~="actorId" and key~="pathId" and key~="trialId" and key~="sourceKind" and key~="storyObjective" and key~="expectedActor" and key~="expectedBuild" then return reject("InvalidReceipt") end
  end
  if not id(a.trialId) or type(a.actorId)~="string" or type(a.pathId)~="string"
   or not mode(a.actorId,a.sourceKind,a.storyObjective) or type(a.expectedActor)~="table" or type(a.expectedBuild)~="table"
   or not util.integer(command.owner,1,9007199254740991) or command.owner~=data.profile.userId
   or command.requestId~="class3:"..a.trialId then return reject("InvalidReceipt") end
  local proof=rules.build(data,a.actorId).class3Proof
  if proof and proof.trialId==a.trialId then
   if not rules.validClass3Proof(data,a.actorId,proof) or proof.pathId~=a.pathId or proof.sourceKind~=a.sourceKind then return reject("RequestConflict") end
   -- This small saved proof cannot acknowledge an exact transaction replay.
   return reject("Class3AlreadyProven")
  end
  if not rules.usesNoviceProgression(data) then return reject("Class3TrialUnavailable") end
  local problem=S.problem(data,a.actorId,a.pathId);if problem then return reject(problem) end
  if not util.equal(rules.actor(data,a.actorId),a.expectedActor) or not util.equal(rules.build(data,a.actorId),a.expectedBuild) then return reject("Class3ActorChanged") end
  local candidate,events
  if a.storyObjective then
   if not campaign then return reject("Class3CampaignUnavailable") end
   local result
   candidate,result,events=campaign.receipt(record,{action="CampaignObjective",args={objective=a.storyObjective}})
   if not candidate then return reject(result.code) end
  else candidate=util.copy(record);events={} end
  candidate.data.expansion.actors[a.actorId].class3Proof={version=1,actorId=a.actorId,pathId=a.pathId,trialId=a.trialId,sourceKind=a.sourceKind}
  table.insert(events,{name="class3_proof_completed",payload={actorId=a.actorId,pathId=a.pathId}})
  return candidate,{code="OK"},events
 end
 return S
end
