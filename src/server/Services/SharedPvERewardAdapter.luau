--!strict
-- Trusted settlement repository only. No world activation or MarkDelivered calls.
return function(deps:any):any
 local data,repo,claims,util=deps.Data,deps.Repository,deps.Claims,deps.Util
 assert(type(deps.Namespace)=="string"and #deps.Namespace>0 and #deps.Namespace<=24 and deps.Namespace:match("^[%w_%-]+$"),"InvalidNamespace")
 local pending:any={};local busy:any={};local nextAttempt=0
 local function live(userId:number,s:any,token:any,epoch:any):boolean
  return data.Sessions[userId]==s and s.token==token and s.epoch==epoch and not s.closing
 end
 local A={}
 function A.Remove(userId:number,session:any)
  local p=pending[userId];if p and p.session==session then pending[userId]=nil end
  local b=busy[userId];if b and b.session==session then b.cancelled=true;busy[userId]=nil end
 end
 function A.Sweep()
  for owner,p in pairs(pending)do if data.Sessions[owner]~=p.session or p.session.closing then A.Remove(owner,p.session)end end
  for owner,b in pairs(busy)do if data.Sessions[owner]~=b.session or b.session.closing then A.Remove(owner,b.session)end end
 end
 function A.Deliver(userId:number,encounterId:any):(string,string)
  if not util.integer(userId,-9007199254740991,9007199254740991)or userId==0 or type(encounterId)~="string"or #encounterId<1 or #encounterId>64 or not encounterId:match("^[%w_%-]+$")then return "Rejected","InvalidRecipient"end
  A.Sweep()
  if busy[userId]then return "Retry","Busy"end
  local s=data.Sessions[userId]
  if not s or s.closing or s.busy then return "Retry","ProfileNotReady"end
  local token,epoch=s.token,s.epoch
  if util.count(busy)>=32 then return "Retry","AdapterCapacity"end
  local marker={session=s,cancelled=false};busy[userId]=marker
  local function done(status:string,code:string):(string,string)if busy[userId]==marker then busy[userId]=nil end;return status,code end
  if s.state=="Degraded"then
   local ok=pcall(data.Refresh,userId)
   if marker.cancelled or not live(userId,s,token,epoch)then return done("Retry","SessionChanged")end
   if not ok then return done("Retry","RefreshUnavailable")end
  end
  if s.state~="Active"or s.busy then return done("Retry",s.problem or s.state)end
  -- Read is authoritative and may yield. A prior uncertain command remains immutable.
  local ok,record,status=pcall(repo.Read,encounterId)
  if marker.cancelled or not live(userId,s,token,epoch)then return done("Retry","SessionChanged")end
  if s.state~="Active"or s.busy or s.pending then return done("Retry",s.problem or (if s.busy then "Busy"else s.state))end
  if not ok or status~="Found"then return done("Retry",if ok then status or "ReadUnavailable"else "ReadUnavailable")end
  if type(record)~="table"or record.version~=2 or type(record.allocations)~="table"or type(record.snapshot)~="table"or record.snapshot.encounterId~=encounterId or record.snapshot.xpPolicy~="equal-actors-v1"then return done("Rejected","InvalidSettlement")end
  local allocation=nil
  for _,a in ipairs(record.allocations)do if a.ownerId==userId then allocation=a;break end end
  if not allocation then return done("Rejected","NotRecipient")end
  local claim={namespace=deps.Namespace,encounterId=encounterId,settlementVersion=2,xpPolicy="equal-actors-v1",allocation=util.copy(allocation)}
  if not claims.validateClaim(claim,userId)then return done("Rejected","InvalidSettlement")end
  local p=pending[userId]
  if p and (p.session~=s or p.token~=token or p.epoch~=epoch)then pending[userId]=nil;p=nil end
  -- A completed thrown call with no pending save cannot later commit an old revision.
  -- Resolve only against the same active fenced profile, never rebase pending writes.
  if p and not util.equal(p.command.args,claim)and s.state=="Active"and not s.busy and not s.pending and claims.check(s.record,p.command.args)=="AlreadyCommitted"then pending[userId]=nil;p=nil end
  if p and p.uncertain and s.state=="Active"and not s.busy and not s.pending and s.record.revision~=p.command.revision and claims.check(s.record,p.command.args)==nil then
   local operationId=tostring(epoch)..":"..p.command.requestId;local found=false
   for _,operation in ipairs(s.record.operations.recentResults)do if operation.id==operationId and util.equal(operation.command,p.command)then found=true;break end end
   if not found then pending[userId]=nil;p=nil end
  end
  if p and not util.equal(p.command.args,claim)then return done("Retry","PendingOtherClaim")end
  if not p then
   if util.count(pending)>=32 then return done("Retry","AdapterCapacity")end
   local used:any={};for _,operation in ipairs(s.record.operations.recentResults)do used[operation.id]=true end
   local requestId=nil
   -- No yield between choosing a fresh unused attempt and execute; public IDs may be arbitrary.
   for _=1,#s.record.operations.recentResults+1 do
    nextAttempt+=1;if nextAttempt>1000000000 then return done("Retry","AdapterCapacity")end
    local candidate="shared-attempt:"..tostring(nextAttempt)
    if not used[tostring(epoch)..":"..candidate]then requestId=candidate;break end
   end
   if not requestId then return done("Retry","AdapterCapacity")end
   p={session=s,token=token,epoch=epoch,uncertain=false,command={version=1,requestId=requestId,action="CommitSharedPvE",revision=s.record.revision,args=claim}}
   pending[userId]=p
  end
  local committed,code=pcall(data.CommitSharedPvE,userId,p.command)
  if marker.cancelled or not live(userId,s,token,epoch)then return done("Retry","SessionChanged")end
  if not committed then p.uncertain=true;return done("Retry","CommitUnavailable")end
  if code=="OK"or code=="AlreadyCommitted"then pending[userId]=nil;return done("Committed",code)end
  if code=="SavePending"then p.uncertain=true;return done("Retry",code)end
  if not p.uncertain then pending[userId]=nil end
  return done("Retry",code)
 end
 return A
end
