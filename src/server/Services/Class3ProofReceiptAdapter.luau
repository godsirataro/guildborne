--!strict
-- Private delivery only. Start fence is captured before combat; proof is never an ack.
return function(data:any,userId:number,receipt:any,util:any,startFence:any,guard:any):any
 if type(receipt)~="table" or receipt.owner~=userId or receipt.action~="Class3Proof"
  or type(receipt.requestId)~="string" or #receipt.requestId<1 or #receipt.requestId>64 or type(receipt.args)~="table"
  or type(startFence)~="table" or type(startFence.session)~="table" or startFence.epoch==nil or startFence.token==nil or type(guard)~="function" then
  return function()return "Rejected","InvalidReceipt"end
 end
 local fixed=util.copy(receipt)
 local started,epoch,token=startFence.session,startFence.epoch,startFence.token
 local operationId=tostring(epoch)..":"..fixed.requestId
 local command:any=nil;local uncertain=false;local busy=false;local terminal:string?=nil;local finalCode:string?=nil
 local function finish(outcome:string,code:string):(string,string)terminal=outcome;finalCode=code;return outcome,code end
 local function fence():string?
  local s=data.Sessions[userId]
  if s~=started or s.epoch~=epoch or s.token~=token or s.closing then return "SessionChanged"end
  if s.state=="LeaseLost" then return "LeaseLost"end
  if s.state=="Closing" or s.state=="Closed" then return "SessionChanged"end
  -- A context guard must not yield into a different character/session.
  local thread=coroutine.create(guard);local ok,valid=coroutine.resume(thread)
  if coroutine.status(thread)~="dead" then coroutine.close(thread);return "ActorNotReady"end
  if not ok or valid~=true then return "ActorNotReady"end
  s=data.Sessions[userId]
  if s~=started or s.epoch~=epoch or s.token~=token or s.closing then return "SessionChanged"end
  if s.state=="LeaseLost" then return "LeaseLost"end
  if s.state=="Closing" or s.state=="Closed" then return "SessionChanged"end
  return nil
 end
 local function retained():any
  local operations=started.record and started.record.operations
  for _,operation in ipairs(if operations then operations.recentResults or {} else {})do
   if operation.id==operationId then return operation end
  end
  return nil
 end
 local function run():(string,string)
  local problem=fence();if problem then return finish("Rejected",problem)end
  if started.busy then return "Retry","Busy"end
  if uncertain or started.state=="Degraded"then
   local ok,code=pcall(data.Refresh,userId)
   problem=fence();if problem then return finish("Rejected",problem)end
   if not ok then return "Retry","RefreshUnavailable"end
   if code~="OK"then return "Retry",if type(code)=="string"then code else "RefreshUnavailable"end
   if uncertain and command and not retained() and started.record.revision~=command.revision then
    return finish("Rejected","ReceiptHistoryUnavailable")
   end
  end
  if started.busy then return "Retry","Busy"end
  if started.state~="Active" or not started.record then return "Retry",started.problem or started.state or "ProfileNotReady"end
  if not command then
   local operation=retained()
   -- Preserve our payload, taking only the old revision for executor conflict checks.
   command={version=1,owner=userId,requestId=fixed.requestId,action="Class3Proof",
    revision=if operation and operation.command then operation.command.revision else started.record.revision,args=util.copy(fixed.args)}
  end
  problem=fence();if problem then return finish("Rejected",problem)end
  local ok,code=pcall(data.CommitClass3Proof,userId,util.copy(command))
  problem=fence();if problem then return finish("Rejected",problem)end
  if not ok then uncertain=true;return "Retry","CommitUnavailable"end
  if code=="OK" or code=="AlreadyCommitted"then return finish("Committed",code)end
  if code=="SavePending"then uncertain=true;return "Retry",code end
  if code=="Busy" or code=="AuditBacklog" or code=="LeaseExpiring" or code=="StaleRevision"then
   if not uncertain then command=nil end
   if code=="AuditBacklog"then
    pcall(data.FlushAudit,userId)
    problem=fence();if problem then return finish("Rejected",problem)end
   end
   return "Retry",code
  end
  return finish("Rejected",if type(code)=="string"then code else "InvalidReceipt")
 end
 return function():(string,string)
  if terminal then return terminal,finalCode :: string end
  if busy then return "Retry","Busy"end
  busy=true
  local ok,outcome,code=pcall(run);busy=false
  if not ok then uncertain=command~=nil;return "Retry","ReceiptUnavailable"end
  return outcome,code
 end
end
