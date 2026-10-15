--!strict
return function(test:any,eq:any)
 local Make=require("../src/server/Systems/HumanParty")
 local Runtime=require("../src/server/Services/HumanPartyRuntime")
 local function fixture(count:number):any
  local time=100;local seq=0;local c=Make({Now=function()return time end});local keys={}
  for i=1,count do keys[tostring(i)]={};c.Add(tostring(i),{displayName="P"..i,username="user"..i,heroCount=5},keys[tostring(i)])end
  local f:any={c=c,keys=keys}
  function f.call(id:string,action:string,args:any?,revision:number?,request:string?):string
   seq+=1;local packet:any=args or {};packet.partyRevision=revision or c.Revision()
   return c.Intent(id,keys[id],"HumanParty"..action,packet,request or "r"..seq)
  end
  function f.join(leader:string,id:string)
   eq(f.call(leader,"Invite",{targetUserId=id}),"OK")
   local invite=c.State(id).incomingInvites[1]
   eq(f.call(id,"Accept",{inviteId=invite.inviteId}),"OK")
  end
  function f.advance(seconds:number)time+=seconds;c.Step()end
  return f
 end
 test("human party six-owner cap retains five companions per owner and rejects seventh",function()
  local f=fixture(8);for i=2,6 do f.join("1",tostring(i))end
  local view=f.c.State("1");eq(#view.members,6);for _,m in ipairs(view.members)do eq(m.heroCount,5)end
  eq(f.call("1","Invite",{targetUserId="7"}),"HumanPartyFull");eq(f.c.State("7").partyId,nil)
  eq(f.c.State("8").partyId,nil);eq(f.c.State("8").available,true)
 end)
 test("final slot competing accepts are fenced then capacity checked",function()
  local f=fixture(7);for i=2,5 do f.join("1",tostring(i))end
  eq(f.call("1","Invite",{targetUserId="6"}),"OK");eq(f.call("1","Invite",{targetUserId="7"}),"OK")
  local rev=f.c.Revision();local six=f.c.State("6").incomingInvites[1];local seven=f.c.State("7").incomingInvites[1]
  eq(f.call("6","Accept",{inviteId=six.inviteId},rev),"OK")
  eq(f.call("7","Accept",{inviteId=seven.inviteId},rev),"HumanPartyStale")
  eq(f.call("7","Accept",{inviteId=seven.inviteId}),"HumanPartyFull");eq(#f.c.State("1").members,6)
 end)
 test("request replay cannot recreate an invite or alter another incarnation",function()
  local f=fixture(3);local rev=f.c.Revision()
  eq(f.call("1","Invite",{targetUserId="2"},rev,"same"),"OK")
  local invite=f.c.State("2").incomingInvites[1]
  eq(f.call("2","Decline",{inviteId=invite.inviteId}),"OK")
  eq(f.call("1","Invite",{targetUserId="2"},rev,"same"),"OK");eq(#f.c.State("2").incomingInvites,0)
  eq(f.call("1","Invite",{targetUserId="3"},rev,"same"),"InvalidRequest")
  eq(f.call("1","Disband"),"OK");f.join("3","1")
  eq(f.call("1","Invite",{targetUserId="2"},rev,"same"),"OK");eq(#f.c.State("2").incomingInvites,0)
 end)
 test("bounded replay eviction still rejects old revisions and ineligible recovery remains usable",function()
  local f=fixture(2);f.join("1","2");local oldRevision=f.c.Revision()
  eq(f.call("1","SetReady",{ready=true},oldRevision,"old-ready"),"OK")
  for i=1,65 do eq(f.call("1","SetReady",{ready=false},nil,"later"..i),"OK")end
  eq(f.call("1","SetReady",{ready=true},oldRevision,"old-ready"),"HumanPartyStale")
  eq(f.c.State("1").members[1].ready,false)
  f.c.Add("1",{displayName="P1",username="user1",heroCount=5,eligible=false},f.keys["1"])
  eq(f.call("1","SetReady",{ready=true}),"HumanPartyUnavailable")
  eq(f.call("1","Leave"),"OK");eq(f.c.State("2").leaderUserId,"2")
 end)
 test("leadership permissions readiness resets and snapshot isolation",function()
  local f=fixture(3);f.join("1","2");f.join("1","3")
  eq(f.call("2","Kick",{targetUserId="3"}),"HumanPartyLeaderRequired")
  eq(f.call("2","Disband"),"HumanPartyLeaderRequired")
  eq(f.call("2","SetReady",{ready=true}),"OK")
  eq(f.call("1","TransferLeader",{targetUserId="2"}),"OK")
  local state=f.c.State("1");eq(state.leaderUserId,"2");for _,m in ipairs(state.members)do eq(m.ready,false)end
  state.members[1].heroCount=999;eq(f.c.State("1").members[1].heroCount,5)
  eq(f.call("2","Kick",{targetUserId="1"}),"OK");eq(f.c.State("1").partyId,nil)
  eq(f.call("2","Leave"),"OK");eq(f.c.State("3").leaderUserId,"3")
 end)
 test("invite ownership expiry and bounded inbox reject abuse",function()
  local f=fixture(9)
  eq(f.call("1","Invite",{targetUserId="2"}),"OK");local invite=f.c.State("2").incomingInvites[1]
  eq(f.call("3","Accept",{inviteId=invite.inviteId}),"HumanPartyInviteExpired")
  f.advance(59);eq(#f.c.State("2").incomingInvites,1);f.advance(1);eq(#f.c.State("2").incomingInvites,0)
  eq(f.call("2","Accept",{inviteId=invite.inviteId}),"HumanPartyInviteExpired")
  for i=1,6 do eq(f.call(tostring(i),"Invite",{targetUserId="9"}),"OK")end
  eq(f.call("7","Invite",{targetUserId="9"}),"HumanPartyInviteLimit")
 end)
 test("disconnect transfers leader retains slot during grace and fences old session",function()
  local f=fixture(3);f.join("1","2");f.join("1","3")
  local old=f.keys["1"];f.c.Remove("1",old);eq(f.c.State("2").leaderUserId,"2")
  eq(f.c.State("2").members[1].connectionState,"Reconnecting")
  f.advance(29);local replacement={};f.keys["1"]=replacement
  f.c.Add("1",{displayName="P1",username="user1",heroCount=5},replacement)
  f.c.Remove("1",old);eq(f.c.State("1").available,true);eq(#f.c.State("1").members,3)
  eq(f.c.Intent("1",old,"HumanPartyLeave",{partyRevision=f.c.Revision()},"stale"),"HumanPartyUnavailable")
  f.c.Remove("1",replacement);f.advance(30);eq(#f.c.State("2").members,2)
  f.c.Add("1",{displayName="P1",username="user1",heroCount=5},{})
  eq(f.c.State("1").partyId,nil)
 end)
 test("canonical Studio user ids supported and malformed action arguments rejected",function()
  local f=fixture(2)
  for _,id in ipairs({"-1","1","9007199254740991"})do eq(f.c.ValidUserId(id),true)end
  for _,id in ipairs({"0","01","-0","1.0","1e3","9007199254740992"})do eq(f.c.ValidUserId(id),false)end
  eq(f.call("1","SetReady",{ready="yes"}),"InvalidRequest")
  eq(f.call("1","Invite",{targetUserId="2",ownerId="2"}),"InvalidRequest")
  eq(f.call("1","Invite",{targetUserId="1"}),"HumanPartyUnavailable")
 end)
 test("runtime fences live players disabled mode profile state and stale removal",function()
  local time=100;local list:any={};local players:any={}
  function players:GetPlayers():any local out={};for _,p in pairs(list)do table.insert(out,p)end;return out end
  function players:GetPlayerByUserId(id:number):any return list[id]end
  local Data:any={Sessions={}};local calls=0;local runtime:any
  for i=1,2 do list[i]={UserId=i,Name="u"..i,DisplayName="P"..i};Data.Sessions[i]={state="Active",epoch=1,token="t"..i,record={data={party={adventurerIds={"h:1"}}}}}end
  local U=require("../src/shared/Util/TableUtil");local before=U.copy(Data.Sessions[1].record)
  runtime=Runtime({Enabled=true,Data=Data,Players=players,Core=Make,Now=function()return time end,Notify=function(p:any)calls+=1;runtime.State(p)end})
  runtime.Add(list[1]);runtime.Add(list[2]);local count=calls;runtime.Step();eq(calls,count)
  local rev=runtime.State(list[1]).revision
  eq(runtime.Intent(list[1],"HumanPartyInvite",{targetUserId="2",partyRevision=rev},"invite"),"OK")
  eq(#runtime.State(list[2]).incomingInvites,1);eq(Data.Sessions[1].record,before)
  local invite=runtime.State(list[2]).incomingInvites[1]
  eq(runtime.Intent(list[2],"HumanPartyAccept",{inviteId=invite.inviteId,partyRevision=runtime.State(list[2]).revision},"accept"),"OK")
  Data.Sessions[1].state="Saving";Data.Sessions[1].busy=true;runtime.Step();time+=31;runtime.Step()
  eq(runtime.State(list[1]).leaderUserId,"1");eq(#runtime.State(list[1]).members,2)
  eq(runtime.State(list[1]).members[1].connectionState,"Connected")
  eq(runtime.Intent(list[1],"HumanPartyInvite",{targetUserId="2",partyRevision=runtime.State(list[1]).revision},"saving"),"HumanPartyUnavailable")
  Data.Sessions[1].state="Degraded";runtime.Step();time+=31;runtime.Step()
  eq(runtime.State(list[1]).leaderUserId,"1");eq(#runtime.State(list[1]).members,2)
  Data.Sessions[1].state="Active";Data.Sessions[1].busy=false;runtime.Step()
  local absent=list[2];list[2]=nil;runtime.Remove(absent)
  eq(runtime.State(list[1]).members[2].connectionState,"Reconnecting")
  eq(runtime.Intent(list[1],"HumanPartyKick",{targetUserId="2",partyRevision=runtime.State(list[1]).revision},"kick"),"OK")
  eq(#runtime.State(list[1]).members,1)
  local old=list[1];list[1]={UserId=1,Name="u1",DisplayName="P1"};Data.Sessions[1].epoch=2
  runtime.Add(list[1]);runtime.Remove(old);eq(runtime.State(list[1]).available,true)
  eq(runtime.Intent(old,"HumanPartyLeave",{partyRevision=runtime.State(list[1]).revision},"old"),"HumanPartyUnavailable")
  Data.Sessions[1].state="LeaseLost";runtime.Step();eq(runtime.State(list[1]).available,false)
  local off=Runtime({Enabled=false,Data=Data,Players=players,Core=Make,Notify=function()error("disabled notification")end})
  off.Add(list[1]);off.Step();eq(off.State(list[1]).available,false)
  eq(off.Intent(list[1],"HumanPartyLeave",{},"off"),"HumanPartyUnavailable")
 end)
end
