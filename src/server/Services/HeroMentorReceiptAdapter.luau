--!strict
-- The world captures this epoch/token at trial START, not during receipt delivery.
return function(data:any,userId:number,receipt:any,util:any,epoch:any,token:any):any
 if type(receipt)~="table" or receipt.owner~=userId or receipt.action~="HeroMentorProof" or epoch==nil or token==nil then return function()return "Rejected","InvalidReceipt"end end
 local fixed=util.copy(receipt);local command:any=nil;local uncertain=false;local busy=false;local outcome="";local finalCode=""
 return function():(string,string)
  if outcome~=""then return outcome,finalCode end
  if busy then return "Retry","Busy"end
  local session=data.Sessions[userId]
  if not session then return "Retry","ProfileNotReady"end
  if session.epoch~=epoch or session.token~=token then outcome="Rejected";finalCode="SessionChanged";return outcome :: string,finalCode :: string end
  if session.closing then return "Retry","ProfileNotReady"end
  if session.busy then return "Retry","Busy"end
  busy=true
  if session.state=="Degraded"then
   local ok=pcall(data.Refresh,userId);if not ok then busy=false;return "Retry","RefreshUnavailable"end
   session=data.Sessions[userId]
   if not session or session.epoch~=epoch or session.token~=token then busy=false;outcome="Rejected";finalCode="SessionChanged";return outcome :: string,finalCode :: string end
  end
  if session.state~="Active" or session.busy or session.closing then busy=false;return "Retry",session.state end
  command=command or {version=1,requestId=fixed.requestId,action=fixed.action,revision=session.record.revision,args=util.copy(fixed.args)}
  local ok,code=pcall(data.CommitHeroMentor,userId,command);busy=false
  if not ok then uncertain=true;return "Retry","CommitUnavailable"end
  if code=="OK" or code=="AlreadyCommitted"then outcome="Committed";finalCode=code;return outcome :: string,code end
  if code=="SavePending"then uncertain=true;return "Retry",code end
  if code=="Busy" or code=="AuditBacklog" or code=="LeaseExpiring" or code=="StaleRevision"then
   if not uncertain then command=nil end
   if code=="AuditBacklog"then pcall(data.FlushAudit,userId)end
   return "Retry",code
  end
  if uncertain then return "Retry",code end
  outcome="Rejected";finalCode=code;return outcome :: string,code
 end
end
