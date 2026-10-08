--!strict
-- Bind one trusted server observation to one session and immutable transaction.
-- Never construct this adapter from a client payload or rebase an uncertain save.
return function(data:any,userId:number,receipt:any,util:any,chapter:any,content:any,campaign:any?):any
 local valid=type(receipt)=="table" and receipt.owner==userId and type(receipt.requestId)=="string" and #receipt.requestId>=1 and #receipt.requestId<=64 and type(receipt.args)=="table"
 if valid then
  for key in pairs(receipt)do if not ({owner=true,requestId=true,action=true,args=true})[key]then valid=false end end
  if campaign then
   valid=valid and receipt.action=="CampaignObjective"and type(receipt.args.objective)=="string"
   local known=false;for _,c in ipairs(campaign.Chapters)do if table.find(c.Objectives,receipt.args.objective)then known=true end end
   valid=valid and known
   for key in pairs(receipt.args)do if key~="objective"and key~="choice"then valid=false end end
   local choices=campaign.Choices[receipt.args.objective]
   if choices then valid=valid and type(receipt.args.choice)=="string"and choices[receipt.args.choice]==true
   elseif receipt.args.choice~=nil then valid=false end
  elseif receipt.action=="NoviceObjective"then
   valid=valid and type(receipt.args.objective)=="string" and chapter.ObjectiveLabels[receipt.args.objective]~=nil
   for key in pairs(receipt.args)do if key~="objective"and key~="branch"then valid=false end end
   if receipt.args.objective=="caravan_choice"then valid=valid and (receipt.args.branch=="rescue"or receipt.args.branch=="supplies")
   elseif receipt.args.branch~=nil then valid=false end
  elseif receipt.action=="NoviceTrial"then
   valid=valid and type(receipt.args.classId)=="string" and content.Character.Classes[receipt.args.classId]~=nil
   for key in pairs(receipt.args)do if key~="classId"then valid=false end end
  else valid=false end
 end
 if not valid then return function(): (string,string)return "Rejected","InvalidReceipt"end end
 local fixed=util.copy(receipt);local epoch:any=nil;local token:any=nil;local command:any=nil
 local uncertain=false;local outcome="";local finalCode="";local busy=false
 return function():(string,string)
  if outcome~="" then return outcome,finalCode end
  if busy then return "Retry","Busy"end
  local session=data.Sessions[userId]
  if not session or session.closing then return "Retry","ProfileNotReady"end
  if epoch==nil then epoch=session.epoch;token=session.token end
  if epoch~=session.epoch or token~=session.token then outcome="Rejected";finalCode="SessionChanged";return outcome :: string,finalCode :: string end
  if session.busy then return "Retry","Busy"end
  busy=true
  if session.state=="Degraded"then
   local refreshed=pcall(data.Refresh,userId)
   if not refreshed then busy=false;return "Retry","RefreshUnavailable"end
   session=data.Sessions[userId]
   if not session or session.epoch~=epoch or session.token~=token then busy=false;outcome="Rejected";finalCode="SessionChanged";return outcome :: string,finalCode :: string end
  end
  if session.state~="Active"or session.busy or session.closing then busy=false;return "Retry",session.state end
  command=command or {version=1,requestId=fixed.requestId,action=fixed.action,revision=session.record.revision,args=util.copy(fixed.args)}
  local ok,code=pcall(if campaign then data.CommitCampaign else data.CommitNovice,userId,command)
  busy=false
  if not ok then uncertain=true;return "Retry","CommitUnavailable"end
  if code=="OK"or code=="AlreadyCommitted"then outcome="Committed";finalCode=code;return outcome :: string,code end
  if code=="SavePending"then uncertain=true;return "Retry",code end
  if code=="Busy"or code=="AuditBacklog"or code=="LeaseExpiring"or code=="StaleRevision"then
   if not uncertain then command=nil end
   if code=="AuditBacklog"then pcall(data.FlushAudit,userId)end
   return "Retry",code
  end
  if uncertain then return "Retry",code end
  outcome="Rejected";finalCode=code;return outcome :: string,code
 end
end
