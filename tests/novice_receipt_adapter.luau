--!strict
return function(test:any,eq:any)
 local make=require("../src/server/Services/NoviceReceiptAdapter")
 local util=require("../src/shared/Util/TableUtil");local chapter=require("../src/server/Config/NoviceChapter");local content=require("../src/server/Config/Content")
 local function fixture():any
  local f:any={Sessions={[1]={epoch=2,token="session-a",state="Active",record={revision=3}}},calls={},mode="OK"}
  function f.CommitNovice(_id:number,command:any):string table.insert(f.calls,util.copy(command));return f.mode end
  function f.Refresh(_id:number)f.Sessions[1].state="Active"end
  function f.FlushAudit(_id:number)end
  return f
 end
 local function receipt():any return {owner=1,requestId="trial:a",action="NoviceTrial",args={classId="Mage"}}end
 test("Novice receipt adapter freezes payload and accepts one result",function()
  local f=fixture();local r=receipt();local send=make(f,1,r,util,chapter,content);r.args.classId="Priest"
  eq(send(),"Committed");eq(send(),"Committed");eq(#f.calls,1);eq(f.calls[1].args.classId,"Mage")
  local invalid={receipt(),receipt(),receipt(),receipt(),receipt()};invalid[1].owner=2;invalid[2].args.xp=450;invalid[3].action="ClaimNoviceChapter";invalid[4].requestId=string.rep("x",65);invalid[5].freeGold=500
  for _,v in ipairs(invalid)do eq(make(f,1,v,util,chapter,content)(),"Rejected")end;eq(#f.calls,1)
 end)
 test("Novice receipt retries preflight but never rebases an uncertain transaction",function()
  local f=fixture();local send=make(f,1,receipt(),util,chapter,content)
  f.mode="StaleRevision";eq(send(),"Retry");f.Sessions[1].record.revision=4
  f.mode="SavePending";eq(send(),"Retry");eq(f.calls[2].revision,4)
  f.Sessions[1].state="Degraded";f.Sessions[1].record.revision=5;f.mode="StaleRevision"
  eq(send(),"Retry");eq(f.calls[3].revision,4)
  f.mode="AlreadyCommitted";eq(send(),"Committed");eq(f.calls[4],f.calls[2]);eq(send(),"Committed");eq(#f.calls,4)
 end)
 test("Novice receipt rejects a changed session and validates branch observations",function()
  local f=fixture();f.mode="SavePending";local send=make(f,1,receipt(),util,chapter,content);eq(send(),"Retry")
  f.Sessions[1].token="session-b";local outcome,code=send();eq(outcome,"Rejected");eq(code,"SessionChanged");eq(#f.calls,1)
  for _,branch in ipairs({"rescue","supplies","xp"})do
   f=fixture();local r={owner=1,requestId="objective:caravan",action="NoviceObjective",args={objective="caravan_choice",branch=branch}}
   eq(make(f,1,r,util,chapter,content)(),if branch=="xp"then "Rejected"else "Committed")
  end
 end)
end
