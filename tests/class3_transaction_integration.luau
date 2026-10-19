--!strict
-- Actual transaction service and full profile schema; disposable in-memory provider only.
return function(test:any,eq:any)
 local U=require("../src/shared/Util/TableUtil")
 local C=require("../src/server/Config/Content")
 local E=require("../src/shared/Data/Expansion")
 local catalog=require("../src/server/Config/CampaignSequence")({require("../src/server/Config/ChapterOne"),require("../src/server/Config/ChapterTwo"),require("../src/server/Config/ChapterThree"),require("../src/server/Config/ChapterFour"),require("../src/server/Config/ChapterFive")})
 local ctx=require("./novice_context")(catalog)
 local proof=require("../src/server/Systems/Class3Proof")(E,U,ctx.Campaign)
 local Adapter=require("../src/server/Services/Class3ProofReceiptAdapter")
 local Make=require("../src/server/Services/PlayerDataService")
 local noop=function()end
 local base=ctx.Schema.new(1,1000);local d=base.data
 for i,ch in ipairs(ctx.Config.Chapters)do
  if i==6 then assert(ctx.Story.trialWon(d,"Warrior")==nil);assert(ctx.Story.selectClass(d,"Warrior",noop)==nil)end
  for _,id in ipairs(ch.Objectives)do assert(ctx.Story.observe(d,id,if id=="caravan_choice"then "rescue"else nil)==nil)end
  assert(ctx.Story.claim(d,ch.Id,if i==6 then "Knight"else nil,noop)==nil)
 end
 local upgrade=require("../src/server/Services/PersonalGuildService")(C,require("../src/server/Services/EconomyService")(C,U),true,catalog)
 local choices={allocate_timber="workers",choose_motto="discovery",choose_crest="compass",choose_joint_review="council",choose_bridge_route="direct",choose_witness_route="guard",renew_tower_oath="compassion",choose_tower_door="moon"}
 for i=1,24 do
  local ch=catalog.Chapters[i];if ch.Hall and d.personalGuild.buildings.guildHall<ch.Hall then assert(upgrade(d,noop)==nil)end
  for _,id in ipairs(ch.Objectives)do assert(ctx.Campaign.observe(d,id,choices[id])==nil)end
  assert(ctx.Campaign.claim(d,ch.Id,if ch.Recruit then "Priest"else nil,noop)==nil)
 end
 assert(upgrade(d,noop)==nil);assert(ctx.Campaign.observe(d,"meet_crosshaven_mentor")==nil)
 d.expansion.actors.player={tier=2,path="berserker",skills={}};d.character.tier=2;d.character.classPathId="berserker"
 d.expansion.tower.highest=5;d.quests.firstClears.quarry_patrol=true
 assert(ctx.Schema.validate(base,1))
 local function fixture(enabled:boolean?):any
  local f:any={records={["p:1"]=U.copy(base)},mode="ok",committed=0,transforms=0,applyCalls=0}
  local config=U.copy(require("../src/server/Config/Runtime"));config.MaxAttempts=1
  local store={Update=function(key:string,transform:any):any
   if f.before then f.before()end
   if f.mode=="before"then error("before write")end
   if f.replay then transform(U.copy(f.records[key]))end
   f.transforms+=1;local value=transform(U.copy(f.records[key]))
   if value then f.records[key]=U.copy(value)end
   if f.after then f.after()end
   if f.mode=="after"then error("after write")end
   return U.copy(value)
  end}
  function f.make():any
   return Make({Util=U,Config=config,Content=C,Schema=ctx.Schema,Protocol=require("../src/shared/Network/Protocol"),Store=store,AuditStore=store,
    Class3Proof=if enabled==false then nil else {apply=function(r:any,c:any)f.applyCalls+=1;return proof.apply(r,c)end},
    Now=function()return 1000 end,Wait=noop,Jitter=function()return 0 end,Log=noop,OnCommitted=function()f.committed+=1 end})
  end
  f.service=f.make();eq(f.service.Load(1,"first"),"OK")
  function f.receipt(combined:boolean?,trial:string?):any
   local run=assert(proof.capture(f.service.Sessions[1].record.data,"player","warlord",trial or "trial-a",if combined==false then "actor_mastery"else "crosshaven_mastery",if combined==false then nil else "complete_borrowed_mastery"))
   run.status="Won";return proof.receipt(run)
  end
  function f.command(receipt:any):any local c=U.copy(receipt);c.version=1;c.revision=f.service.Sessions[1].record.revision;return c end
  function f.deliver(receipt:any):any local s=f.service.Sessions[1];return Adapter(f.service,1,receipt,U,{session=s,epoch=s.epoch,token=s.token},function()return true end)end
  return f
 end
 test("Class3 transaction combines objective and proof once without reward or class grants",function()
  local f=fixture();local before=U.copy(f.records["p:1"].data);local c=f.command(f.receipt());f.replay=true
  eq(f.service.CommitClass3Proof(1,c),"OK");local saved=f.records["p:1"]
  eq(saved.data.progression.campaign.objectives.complete_borrowed_mastery,true);eq(saved.data.expansion.actors.player.class3Proof.pathId,"warlord")
  eq(saved.data.character,before.character);eq(saved.data.currencies,before.currencies);eq(saved.data.inventory,before.inventory)
  eq(saved.data.personalGuild,before.personalGuild);eq(saved.revision,base.revision+1);eq(#saved.audit.outbox,2)
  eq(f.service.CommitClass3Proof(1,c),"AlreadyCommitted");eq(f.applyCalls,1);eq(f.committed,1)
  c.args.pathId="commander";eq(f.service.CommitClass3Proof(1,c),"RequestConflict");eq(f.applyCalls,1)
 end)
 test("Class3 transaction exact envelope and absent dependency refuse before store",function()
  for _,mutate in ipairs({function(c:any)c.owner=2 end,function(c:any)c.owner=-1 end,function(c:any)c.owner=0/0 end,function(c:any)c.extra=true end,function(c:any)c.version=2 end,function(c:any)c.revision=0/0 end,function(c:any)c.requestId="wrong"end,function(c:any)c.args.extra=true end,function(c:any)c.args.sourceKind="fake"end,function(c:any)c.args.expectedActor=nil end})do
   local f=fixture();local c=f.command(f.receipt());mutate(c);local count=f.transforms
   eq(f.service.CommitClass3Proof(1,c),"InvalidReceipt");eq(f.transforms,count);eq(f.applyCalls,0)
  end
  local f=fixture(false);eq(f.service.CommitClass3Proof(1,f.command(f.receipt())),"InvalidAction")
 end)
 test("Class3 failed objective or stale actor produces no half candidate",function()
  for _,kind in ipairs({"objective","actor"})do
   local f=fixture();local c=f.command(f.receipt());local s=f.service.Sessions[1]
   if kind=="objective"then s.record.data.progression.campaign.objectives.meet_crosshaven_mentor=nil else s.record.data.character.xp+=1 end
   f.records["p:1"]=U.copy(s.record);local before=U.copy(f.records)
   local code=f.service.CommitClass3Proof(1,c);assert(code~="OK");eq(f.records,before);eq(f.committed,0)
  end
 end)
 test("Class3 before and after write uncertainty retries immutable command exactly once",function()
  for _,mode in ipairs({"before","after"})do
   local f=fixture();local receipt=f.receipt();local deliver=f.deliver(receipt);local before=U.copy(f.records["p:1"].data)
   f.mode=mode;eq(deliver(),"Retry");local pending=U.copy(f.service.Sessions[1].pending.command)
   if mode=="before"then eq(f.records["p:1"].data,before)else eq(f.records["p:1"].data.progression.campaign.objectives.complete_borrowed_mastery,true)end
   receipt.args.pathId="wrong";f.mode="ok";f.replay=true;eq(deliver(),"Committed");eq(f.applyCalls,1)
   eq(f.records["p:1"].operations.recentResults[1].command,pending);eq(#f.records["p:1"].audit.outbox,2)
   eq(deliver(),"Committed");eq(f.committed,1)
  end
 end)
 test("Class3 proof-only commits never reopen story or grant progression",function()
  local f=fixture();local before=U.copy(f.records["p:1"].data);local receipt=f.receipt(false)
  eq(f.deliver(receipt)(),"Committed");local after=f.records["p:1"].data
  eq(after.progression,before.progression);eq(after.character,before.character);eq(after.currencies,before.currencies)
  eq(after.inventory,before.inventory);eq(#f.records["p:1"].audit.outbox,1)
 end)
 test("Class3 rejoin retains saved proof and rejects old-session pending delivery",function()
  local f=fixture();local receipt=f.receipt(false);local stale=f.deliver(receipt)
  eq(f.deliver(receipt)(),"Committed");eq(f.service.Close(1),"OK");f.service=f.make();eq(f.service.Load(1,"second"),"OK")
  eq(proof.hasProof(f.service.Sessions[1].record.data,"player","warlord"),true)
  eq(stale(),"Rejected");local count=f.transforms
  local c=f.command(receipt);eq(f.service.CommitClass3Proof(1,c),"Class3AlreadyProven");eq(f.transforms,count)
 end)
 test("Class3 retired uncertain history refresh refuses without rebase or fabricated ack",function()
  local f=fixture();local deliver=f.deliver(f.receipt());f.mode="after";eq(deliver(),"Retry")
  f.records["p:1"].operations.recentResults={};f.mode="ok";local before=U.copy(f.records["p:1"])
  local outcome,code=deliver();eq(outcome,"Rejected");eq(code,"ReceiptHistoryUnavailable")
  eq(f.records["p:1"],before);eq(f.committed,0);eq(f.applyCalls,1);eq(f.service.Sessions[1].state,"Active")
 end)
 test("Class3 changed exact session during yielding prewrite provider cannot write",function()
  local f=fixture();local c=f.command(f.receipt());local before=U.copy(f.records["p:1"])
  f.before=function()coroutine.yield()end
  local result;local thread=coroutine.create(function()result=f.service.CommitClass3Proof(1,c)end)
  assert(coroutine.resume(thread));eq(coroutine.status(thread),"suspended")
  local replacement=U.copy(f.service.Sessions[1]);f.service.Sessions[1]=replacement
  assert(coroutine.resume(thread));eq(result,"SessionChanged");eq(f.records["p:1"],before);eq(f.committed,0)
 end)
 test("Class3 replacement after durable write suppresses stale local adoption and callbacks",function()
  local f=fixture();local c=f.command(f.receipt());local old=f.service.Sessions[1];local replacement
  f.after=function()replacement=U.copy(old);f.service.Sessions[1]=replacement end
  eq(f.service.CommitClass3Proof(1,c),"SessionChanged");eq(f.service.Sessions[1],replacement);eq(replacement.record.revision,base.revision)
  eq(f.records["p:1"].revision,base.revision+1);eq(f.committed,0)
 end)
 test("Class3 owned hero transaction stays isolated from same-class hero and player story",function()
  local f=fixture();local session=f.service.Sessions[1];local data=session.record.data
  local actorId=data.progression.novice.founderHero;local hero=data.adventurers[actorId]
  hero.level=70;hero.xp=3450;data.expansion.actors[actorId]={tier=2,path="guardian",skills={}}
  local other=U.copy(hero);other.id="h:99";other.equipmentSlots={};data.adventurers[other.id]=other;data.settlement.nextHero=100
  data.expansion.actors[other.id]={tier=2,path="guardian",skills={}}
  assert(ctx.Schema.validate(session.record,1));f.records["p:1"]=U.copy(session.record)
  local before=U.copy(data);local run=assert(proof.capture(data,actorId,"fortress","hero-trial","actor_mastery"));run.status="Won"
  eq(f.deliver(proof.receipt(run))(),"Committed");local saved=f.records["p:1"].data
  eq(proof.hasProof(saved,actorId,"fortress"),true);eq(proof.hasProof(saved,other.id,"fortress"),false)
  eq(saved.progression,before.progression);eq(saved.character,before.character);eq(saved.adventurers,before.adventurers)
 end)
 test("Class3 store expiry refuses combined mutation and preserves both fields absent",function()
  local f=fixture();local c=f.command(f.receipt());f.records["p:1"].session.leaseExpiresAt=999
  local before=U.copy(f.records["p:1"]);eq(f.service.CommitClass3Proof(1,c),"LeaseLost")
  eq(f.records["p:1"],before);eq(f.committed,0)
 end)
 test("Class3 pending snapshot survives caller mutation while provider yields",function()
  local f=fixture();local c=f.command(f.receipt());local original=U.copy(c)
  f.before=function()coroutine.yield()end
  local result;local thread=coroutine.create(function()result=f.service.CommitClass3Proof(1,c)end)
  assert(coroutine.resume(thread));c.args.pathId="commander";c.owner=2;c.revision=999
  assert(coroutine.resume(thread));eq(result,"OK")
  eq(f.records["p:1"].operations.recentResults[1].command,original)
  eq(f.records["p:1"].data.expansion.actors.player.class3Proof.pathId,"warlord")
 end)

 test("Class3 same-session lease loss during prewrite yield blocks durable write and adapter acknowledgement",function()
  local f=fixture();local deliver=f.deliver(f.receipt());local before=U.copy(f.records["p:1"])
  f.before=function()coroutine.yield()end
  local outcome,code;local thread=coroutine.create(function()outcome,code=deliver()end)
  assert(coroutine.resume(thread));eq(coroutine.status(thread),"suspended")
  f.service.Sessions[1].state="LeaseLost"
  assert(coroutine.resume(thread));eq(outcome,"Rejected");eq(code,"LeaseLost")
  eq(f.records["p:1"],before);eq(f.committed,0);eq(f.service.Sessions[1].record.revision,base.revision)
 end)
 test("Class3 postwrite lease loss preserves durable proof but suppresses adoption callbacks and world acknowledgement",function()
  local f=fixture();local deliver=f.deliver(f.receipt());local session=f.service.Sessions[1]
  f.after=function()coroutine.yield()end
  local outcome,code;local thread=coroutine.create(function()outcome,code=deliver()end)
  assert(coroutine.resume(thread));eq(coroutine.status(thread),"suspended");session.state="LeaseLost"
  assert(coroutine.resume(thread));eq(outcome,"Rejected");eq(code,"LeaseLost")
  eq(f.records["p:1"].revision,base.revision+1);eq(session.record.revision,base.revision);eq(session.state,"LeaseLost");eq(f.committed,0)
  eq(proof.hasProof(f.records["p:1"].data,"player","warlord"),true)
 end)
 test("Class3 closing during inflight save retains durable completion but adapter refuses stale acknowledgement",function()
  local f=fixture();local deliver=f.deliver(f.receipt());local session=f.service.Sessions[1]
  f.before=function()coroutine.yield()end
  local outcome,code;local thread=coroutine.create(function()outcome,code=deliver()end)
  assert(coroutine.resume(thread));eq(coroutine.status(thread),"suspended")
  eq(f.service.Close(1),"Busy");eq(session.closing,true)
  assert(coroutine.resume(thread));eq(outcome,"Rejected");eq(code,"SessionChanged")
  eq(f.records["p:1"].revision,base.revision+1);eq(f.committed,1)
  f.before=nil;eq(f.service.Close(1),"OK");f.service=f.make();eq(f.service.Load(1,"rejoined"),"OK")
  eq(proof.hasProof(f.service.Sessions[1].record.data,"player","warlord"),true)
  eq(deliver(),"Rejected");eq(f.committed,1)
 end)

end
