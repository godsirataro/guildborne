--!strict
-- Simulated Data boundary; actual transaction/domain coverage belongs to controller.
return function(test:any,eq:any)
 local U=require("../src/shared/Util/TableUtil")
 local Adapter=require("../src/server/Services/Class3ProofReceiptAdapter")
 local function fixture():any
  local f:any={calls={},refreshes=0,valid=true,mode="OK",refreshCode="OK"}
  local s={epoch=7,token="start",state="Active",record={revision=5,operations={recentResults={}}}}
  f.session=s;f.receipt={owner=42,requestId="class3:t1",action="Class3Proof",args={actorId="h:1",pathId="warlord",trialId="t1",sourceKind="actor_mastery",expectedActor={level=70},expectedBuild={tier=2}}}
  local data:any={Sessions={[42]=s}}
  function data.Refresh(_id:number)
   f.refreshes+=1;if f.onRefresh then f.onRefresh()end;return f.refreshCode
  end
  function data.CommitClass3Proof(id:number,c:any)
   eq(id,42);table.insert(f.calls,U.copy(c))
   if f.onCommit then f.onCommit(c)end
   -- Executor resolves retained exact operations before fresh domain eligibility.
   for _,op in ipairs(data.Sessions[id].record.operations.recentResults)do
    if op.id==tostring(data.Sessions[id].epoch)..":"..c.requestId then return if U.equal(op.command,c)then "AlreadyCommitted"else "RequestConflict"end
   end
   if f.domainRefusal then return f.domainRefusal end
   return f.mode
  end
  function data.FlushAudit(_id:number)if f.onFlush then f.onFlush()end;return "OK"end
  f.data=data;f.fence={session=s,epoch=s.epoch,token=s.token}
  f.make=function()return Adapter(data,42,f.receipt,U,f.fence,function()if f.onGuard then return f.onGuard()end;return f.valid end)end
  f.retain=function(command:any)table.insert(s.record.operations.recentResults,{id="7:class3:t1",command=U.copy(command),result={code="OK"}})end
  return f
 end
 test("Class3 adapter derives owner and snapshots payload before caller changes",function()
  local f=fixture();local deliver=f.make();f.receipt.args.pathId="deadeye";f.fence.epoch=99
  eq(deliver(),"Committed");eq(f.calls[1].owner,42);eq(f.calls[1].args.pathId,"warlord");eq(f.calls[1].revision,5)
  eq(deliver(),"Committed");eq(#f.calls,1)
  f=fixture();f.receipt.owner=9;eq(f.make()(),"Rejected");eq(#f.calls,0)
 end)
 test("Class3 adapter rejects replaced exact session epoch token or invalid context before calls",function()
  for _,mode in ipairs({"object","epoch","token","guard","closing"})do
   local f=fixture();local deliver=f.make()
   if mode=="object"then f.data.Sessions[42]=U.copy(f.session)elseif mode=="epoch"then f.session.epoch+=1 elseif mode=="token"then f.session.token="other"elseif mode=="guard"then f.valid=false else f.session.closing=true end
   eq(deliver(),"Rejected");eq(#f.calls,0);eq(f.refreshes,0)
  end
 end)
 test("Class3 uncertain receipt refreshes and retries identical revision payload",function()
  local f=fixture();f.mode="SavePending";local deliver=f.make();eq(deliver(),"Retry")
  local original=U.copy(f.calls[1]);f.receipt.args.expectedActor.level=99
  f.onRefresh=function()f.retain(original);f.session.record.revision=6 end
  f.domainRefusal="Class3ActorChanged"
  local outcome,code=deliver();eq(outcome,"Committed");eq(code,"AlreadyCommitted");eq(f.refreshes,1);eq(U.equal(original,f.calls[2]),true)
 end)
 test("Class3 retired uncertain history refuses terminally without guessing from saved proof",function()
  local f=fixture();f.mode="SavePending";local deliver=f.make();eq(deliver(),"Retry")
  f.onRefresh=function()f.session.record.revision=6;f.session.record.data={class3Proof=U.copy(f.receipt.args)}end
  local outcome,code=deliver();eq(outcome,"Rejected");eq(code,"ReceiptHistoryUnavailable");eq(#f.calls,1)
  f.session.record.revision=5;eq(deliver(),"Rejected");eq(f.refreshes,1)
 end)
 test("Class3 same revision without retained history may retry only the immutable command",function()
  local f=fixture();f.mode="SavePending";local deliver=f.make();eq(deliver(),"Retry")
  f.mode="OK";eq(deliver(),"Committed");eq(U.equal(f.calls[1],f.calls[2]),true)
 end)
 test("Class3 failed refresh cannot infer history retirement",function()
  local f=fixture();f.mode="SavePending";local deliver=f.make();eq(deliver(),"Retry")
  f.session.record.revision=6;f.refreshCode="StorageUnavailable";local outcome,code=deliver()
  eq(outcome,"Retry");eq(code,"StorageUnavailable");eq(#f.calls,1)
  f.refreshCode="OK";eq(select(2,deliver()),"ReceiptHistoryUnavailable")
 end)
 test("Class3 retained executor result precedes fresh eligibility and detects payload conflicts",function()
  for _,conflict in ipairs({false,true})do
   local f=fixture();local command={version=1,owner=42,requestId=f.receipt.requestId,action="Class3Proof",revision=3,args=U.copy(f.receipt.args)}
   if conflict then command.args.pathId="commander"end
   f.retain(command);f.domainRefusal="AdvancementLocked"
   local outcome,code=f.make()();eq(outcome,if conflict then "Rejected"else "Committed");eq(code,if conflict then "RequestConflict"else "AlreadyCommitted");eq(f.calls[1].revision,3)
  end
 end)
 test("Class3 yielding refresh and commit reject changed context and block reentry",function()
  for _,stage in ipairs({"refresh","commit"})do
   local f=fixture();local deliver=f.make()
   if stage=="refresh"then f.session.state="Degraded";f.onRefresh=function()coroutine.yield()end else f.onCommit=function()coroutine.yield()end end
   local outcome,code;local worker=coroutine.create(function()outcome,code=deliver()end)
   assert(coroutine.resume(worker));eq(coroutine.status(worker),"suspended");eq(select(2,deliver()),"Busy")
   f.valid=false;assert(coroutine.resume(worker));eq(outcome,"Rejected");eq(code,"ActorNotReady")
   eq(#f.calls,if stage=="refresh"then 0 else 1)
  end
 end)
 test("Class3 refresh cannot transfer pending receipt into a replacement session",function()
  local f=fixture();f.mode="SavePending";local deliver=f.make();eq(deliver(),"Retry")
  f.onRefresh=function()f.data.Sessions[42]=U.copy(f.session)end
  local outcome,code=deliver();eq(outcome,"Rejected");eq(code,"SessionChanged");eq(#f.calls,1)
 end)
 test("Class3 thrown commit freezes command and guard errors or yields fail closed",function()
  local f=fixture();f.onCommit=function()error("provider uncertain")end;local deliver=f.make()
  eq(select(2,deliver()),"CommitUnavailable");f.onCommit=nil;eq(deliver(),"Committed");eq(U.equal(f.calls[1],f.calls[2]),true)
  for _,mode in ipairs({"throw","yield"})do
   f=fixture();f.onGuard=function()if mode=="throw"then error("guard failed")else coroutine.yield()end;return true end
   eq(f.make()(),"Rejected");eq(#f.calls,0)
  end
 end)
 test("Class3 audit retry rechecks context after provider yields",function()
  local f=fixture();f.mode="AuditBacklog";f.onFlush=function()f.valid=false end
  local outcome,code=f.make()();eq(outcome,"Rejected");eq(code,"ActorNotReady")
 end)
 test("Class3 lost or closed session is terminal before and after refresh",function()
  for _,state in ipairs({"LeaseLost","Closing","Closed"})do
   for _,refresh in ipairs({false,true})do
    local f=fixture();local deliver=f.make()
    if refresh then
     f.mode="SavePending";eq(deliver(),"Retry")
     f.onRefresh=function()f.session.state=state;f.refreshCode="ProfileNotReady"end
    else f.session.state=state end
    local outcome,code=deliver();eq(outcome,"Rejected");eq(code,if state=="LeaseLost"then "LeaseLost"else "SessionChanged")
    local calls,refreshes=#f.calls,f.refreshes
    f.session.state="Active";eq(deliver(),"Rejected");eq(#f.calls,calls);eq(f.refreshes,refreshes)
   end
  end
 end)
end
