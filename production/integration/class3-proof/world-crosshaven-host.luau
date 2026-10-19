--!nocheck
-- Exact delivery/API/repeat-callback slices, not full world/art/native execution.
local function eq(a,b)assert(a==b,tostring(a).." ~= "..tostring(b))end
local count=0
local function test(name,f)f();count+=1;print("PASS "..name)end
local function fixture()
 local f={notices={},valid=true,removes=0,outcome="Rejected",reason="ReceiptHistoryUnavailable"}
 local character={};local player={UserId=42,Character=character}
 local session={epoch=1,token="a",state="Active",record={data={}}}
 local trial={Destroy=function()f.destroyed=true end,Snapshot=function()return {status="Won"}end}
 local e={trial=trial,trialProof=true,trialToken={},trialCharacter=character,trialPath="warlord",session=session,epoch=1,token="a",pendingObjective="complete_borrowed_mastery",puzzles={},sets={},art={model={SetAttribute=function()end}}}
 e.trialGuard=function()return f.valid end
 e.pending=function()if f.deliver then f.deliver()end;return f.outcome,f.reason end
 local entries={[player]=e};local S={}
 local deps={Class3Proof={},Data={Sessions={[42]=session},FlushAudit=function()end}}
 local function current(p,entry)return if entries[p]==entry and session.state=="Active"then session else nil end
 local function clock()return 1 end
 local function notify(_,proof,code)table.insert(f.notices,{proof=proof,code=code,active=S.Active(player)})end
 -- CROSS_STOP
 function S.Remove(p)f.removes+=1;entries[p]=nil;stopActivity(e)end
 -- CROSS_API
 local function tick()
  for player,e in pairs(entries)do
   -- CROSS_DELIVERY
  end
 end
 local function startMastery(_)return f.startReason or "Class3TrialUnavailable"end
 -- CROSS_REPEAT
 f.entry=e;f.player=player;f.session=session;f.deps=deps;f.tick=tick;f.world=S;f.repeatCallback=repeatCallback
 return f
end
test("Crosshaven exact delivery refusal clears activity before notifying precise reason",function()
 local f=fixture();f.tick();eq(f.world.Active(f.player),false);eq(f.world.Class3State(f.player),nil)
 eq(#f.notices,1);eq(f.notices[1].proof,true);eq(f.notices[1].code,"ReceiptHistoryUnavailable");eq(f.notices[1].active,false)
end)
test("Crosshaven physical guard loss after delivery reports while replacements stay silent",function()
 for _,kind in ipairs({"physical","session","character"})do
  local f=fixture();f.outcome="Committed"
  f.deliver=function()
   if kind=="physical"then f.valid=false elseif kind=="session"then f.deps.Data.Sessions[42]={epoch=1,token="a"}else f.player.Character={}end
  end
  f.tick();eq(f.world.Active(f.player),false)
  if kind=="physical"then eq(#f.notices,1);eq(f.notices[1].code,"ActorNotReady");eq(f.notices[1].active,false)else eq(#f.notices,0)end
 end
end)
test("Crosshaven degraded saving refuses cancellation and retains bounded reason",function()
 local f=fixture();f.session.state="Degraded";f.outcome="Retry";f.reason="SavePending";f.tick()
 eq(f.world.Intent(f.player,"CancelClass3Trial",{}),"SavePending")
 local state=f.world.Class3State(f.player);eq(state.actorId,"player");eq(state.pathId,"warlord");eq(state.status,"Saving");eq(state.problem,"SavePending")
 eq(f.world.Active(f.player),true)
end)
test("Crosshaven authored repeat refusal uses Class3 notification channel",function()
 local f=fixture();f.startReason="ReturnToCrosshaven";f.repeatCallback({})
 eq(#f.notices,1);eq(f.notices[1].proof,true);eq(f.notices[1].code,"ReturnToCrosshaven")
end)
print(count.." source-extracted Crosshaven callback checks passed; not full world or Studio acceptance")
