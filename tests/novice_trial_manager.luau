--!strict
return function(test:any,eq:any)
 local make=require("../src/server/Services/NoviceTrialManager")
 local function fixture():any
  local f:any={created={},removed=0,notifications=0,deliveries=0,result="Committed",run=0}
  local data:any={Sessions={}}
  for i=1,3 do data.Sessions[i]={epoch=1,token="session:"..i,state="Active",record={data={}}}end
  function data.FlushAudit(_id:number)end
  f.data=data
  f.manager=make({Data=data,MaxArenas=2,Now=function()return 0 end,NewRunId=function()f.run+=1;return "run"..f.run end,
   Trials={start=function(_d:any,_id:number,class:string,_run:string,_now:number):(any?,string?)if class=="Mage"then return {},nil end;return nil,"InvalidClass"end},
   Origin=function(slot:number)return slot*220 end,
   CreateArena=function(player:any,_data:any,_class:string,runId:string,origin:any,complete:any)
    local a:any={status="Active",userId=player.UserId,runId=runId,origin=origin,complete=complete}
    function a.Snapshot()return {status=a.status}end
    function a.Destroy()f.removed+=1;a.destroyed=true end
    table.insert(f.created,a);return a
   end,
   MakeReceipt=function(_id:number,_r:any)return function()f.deliveries+=1;return f.result,"Fixture"end end,
   Notify=function(_p:any)f.notifications+=1 end})
  function f.win(index:number):boolean local a=f.created[index];a.status="Won";return a.complete({owner=a.userId,requestId="trial:"..a.runId,action="NoviceTrial",args={classId="Mage"}})end
  return f
 end
 test("Novice manager bounds arenas and releases slots on cancellation or session loss",function()
  local f=fixture();eq(f.manager.Start({UserId=1},"Invalid"),"InvalidClass");eq(#f.created,0)
  eq(f.manager.Start({UserId=1},"Mage"),"OK");eq(f.manager.Start({UserId=1},"Mage"),"TrialAlreadyActive")
  eq(f.manager.Start({UserId=2},"Mage"),"OK");eq(f.created[1].origin==f.created[2].origin,false)
  eq(f.manager.Start({UserId=3},"Mage"),"TrialCapacity");eq(f.manager.Stop({UserId=1}),"OK")
  eq(f.manager.Start({UserId=3},"Mage"),"OK");eq(f.manager.State(3).slot,1)
  f.data.Sessions[2].token="rejoined";f.manager.Step();eq(f.manager.State(2),nil);eq(f.removed,2)
 end)
 test("Novice manager retains pending victory and notifies once on receipt acceptance",function()
  local f=fixture();eq(f.manager.Start({UserId=1},"Mage"),"OK");f.result="Retry";eq(f.win(1),false)
  eq(f.manager.Stop({UserId=1}),"SavePending");eq(f.manager.Start({UserId=1},"Mage"),"SavePending")
  f.result="Committed";eq(f.win(1),true);eq(f.win(1),true);eq(f.deliveries,2);eq(f.notifications,1)
  eq(f.manager.Stop({UserId=1}),"OK");eq(f.win(1),false);eq(f.notifications,1)
 end)
 test("Novice manager rejects a mismatched receipt without writing",function()
  local f=fixture();eq(f.manager.Start({UserId=1},"Mage"),"OK")
  eq(f.created[1].complete({owner=2,requestId="trial:run1",action="NoviceTrial",args={classId="Mage"}}),false)
  eq(f.manager.State(1).delivery,"Rejected");eq(f.deliveries,0);eq(f.win(1),false)
 end)
end
