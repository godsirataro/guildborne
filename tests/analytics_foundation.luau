--!strict
return function(test:any,eq:any)
 local Contract=require("../src/server/Systems/AnalyticsContract")
 local Make=require("../src/server/Systems/OnboardingFunnel")
 local Adapter=require("../src/server/Services/AnalyticsAdapter")
 test("product analytics rejects arbitrary identifiers names fields and numeric hazards",function()
  local p={version=1,milestone="session_ready",elapsedSeconds=0}
  eq(Contract.sanitize("onboarding_milestone",p),p)
  eq(Contract.sanitize("user_123",p),nil)
  for _,field in ipairs({"userId","heroId","purchaseId","runId","encounterId","name","position","freeText"})do
   local q:any={version=1,milestone="session_ready",elapsedSeconds=0};q[field]="private";eq(Contract.sanitize("onboarding_milestone",q),nil)
  end
  for _,n in ipairs({0/0,math.huge,-math.huge,-1,86401,.1})do eq(Contract.sanitize("onboarding_milestone",{version=1,milestone="session_ready",elapsedSeconds=n}),nil)end
  p.milestone="anything";eq(Contract.sanitize("onboarding_milestone",p),nil)
 end)
 test("session funnel handles independent milestones replay rejoin and bounded clocks",function()
  local now=10;local events:any={}
  local f=Make({Now=function()return now end,Emit=function(_id:number,name:string,p:any)table.insert(events,{name=name,payload=p})end})
  eq(f.Observe(1,"combat_reward",{}),false);eq(f.Begin(1),true);eq(f.Begin(1),false)
  now=19.9;eq(f.Observe(1,"combat_reward",{}),true);eq(events[2].payload.elapsedSeconds,9)
  eq(f.Observe(1,"combat_reward",{}),false);eq(#events,2)
  now=1;eq(f.Observe(1,"campaign_chapter_claimed",{}),true);eq(events[3].payload.elapsedSeconds,0)
  now=100000;eq(f.Observe(1,"novice_class_selected",{}),true);eq(events[4].payload.elapsedSeconds,86400)
  for _,e in ipairs(events)do eq(Contract.sanitize(e.name,e.payload),e.payload)end
  f.End(1);eq(f.Observe(1,"combat_reward",{}),false);eq(f.Begin(1),true);eq(f.Observe(1,"combat_reward",{}),true)
  eq(events[#events].payload.milestone,"first_combat_reward")
 end)
 test("only effective player outcomes and accepted bounded orders count",function()
  local events:any={};local f=Make({Now=function()return 0 end,Emit=function(_id:number,_n:string,p:any)table.insert(events,p.milestone)end})
  f.Begin(-1)
  for _,n in ipairs({0,-1,0/0,math.huge})do eq(f.Observe(-1,"combat_player_heal",{amount=n}),false)end
  eq(f.Observe(-1,"combat_intent",{action="Ability"}),false)
  eq(f.Observe(-1,"hero_order_accepted",{order="arbitrary"}),false)
  eq(f.Observe(-1,"combat_player_heal",{amount=2}),true);eq(f.Observe(-1,"combat_player_damage",{amount=3}),false)
  eq(f.Observe(-1,"hero_order_accepted",{order="Hold"}),true)
  eq(f.Observe(-1,"novice_guild_founded",{}),true);eq(f.Observe(-1,"adventurer_recruited",{}),false)
  eq(#events,5)
 end)
 test("provider failures mutation and missing contract cannot leak or change delivery",function()
  local received:any={};local calls=0;local queue:any={}
  local a=Adapter({function(_n:string,p:any)p.private="x";error("outage")end,function(n:string,p:any)table.insert(received,{n=n,p=p})end},function()error("log outage")end,Contract,function(f:any)table.insert(queue,f)end)
  eq(a.Product("onboarding_milestone",{version=1,milestone="session_ready",elapsedSeconds=0}),true)
  eq(#received,0);queue[1]()
  eq(#received,1);eq(received[1].p.private,nil)
  eq(a.Product("onboarding_milestone",{version=1,milestone="session_ready",elapsedSeconds=0,userId=1}),false);eq(#received,1)
  local old=Adapter({function(_n:string,p:any)calls+=1;eq(p.original,true)end},function()end)
  old.Emit("existing_business_event",{original=true});eq(calls,1)
  eq(old.Product("onboarding_milestone",{}),false)
  local f=Make({Now=function()return 1 end,Emit=function()error("failed")end});eq(f.Begin(1),true);eq(f.Observe(1,"combat_reward",{}),true);eq(f.Observe(1,"combat_reward",{}),false)
 end)
 test("product defers yielding providers bounds pending work and snapshots inputs",function()
  local queue:any={};local received:any={};local logs=0
  local providers:any={function(_n:string,p:any)coroutine.yield("waiting");table.insert(received,p)end}
  local a=Adapter(providers,function()logs+=1 end,Contract,function(f:any)table.insert(queue,coroutine.create(f))end)
  local payload={version=1,milestone="session_ready",elapsedSeconds=4}
  for _=1,32 do eq(a.Product("onboarding_milestone",payload),true)end
  eq(logs,0);eq(#queue,32);eq(a.Product("onboarding_milestone",payload),false)
  payload.elapsedSeconds=99;providers[1]=function()error("mutated provider list")end
  local ok,reason=coroutine.resume(queue[1]);eq(ok,true);eq(reason,"waiting")
  eq(logs,1);eq(#received,0);eq(a.Product("onboarding_milestone",payload),false)
  eq(coroutine.resume(queue[1]),true);eq(received[1].elapsedSeconds,4)
  eq(a.Product("onboarding_milestone",payload),true);eq(#queue,33)
  for i=2,32 do eq(coroutine.resume(queue[i]),true);eq(coroutine.resume(queue[i]),true)end
  eq(#received,32)
 end)
 test("scheduler failures release product capacity without calling providers",function()
  local a=Adapter({function()error("must not run")end},function()end,Contract,function()error("scheduler unavailable")end)
  for _=1,40 do eq(a.Product("onboarding_milestone",{version=1,milestone="session_ready",elapsedSeconds=0}),false)end
 end)
 test("session lifecycle has bounded storage and invalid clocks fail closed",function()
  local f=Make({Now=function()return 1 end,Emit=function()end})
  for i=1,256 do eq(f.Begin(i),true)end;eq(f.Begin(257),false);f.End(1);eq(f.Begin(257),true)
  eq(f.Begin(0),false);eq(f.Begin(0/0),false)
  local bad=Make({Now=function()return math.huge end,Emit=function()error("must not emit")end});eq(bad.Begin(1),false)
 end)
end
