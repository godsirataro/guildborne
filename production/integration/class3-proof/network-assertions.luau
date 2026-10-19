--!strict
-- Executed after source insertion by network-source-tests.py; no Roblox/Studio evidence.
local realRequire=require
local U=realRequire("../../src/shared/Util/TableUtil")
local Protocol=realRequire("../../src/shared/Network/Protocol")
local L=realRequire("../../src/shared/Config/Localization")
local checks=0
local function eq(a:any,b:any)assert(U.equal(a,b),"expected "..tostring(b)..", got "..tostring(a))end
local function test(name:string,fn:any)fn();checks+=1;print("PASS "..name)end
-- INSERT GATE
-- INSERT CODE
local Players={};local ReplicatedStorage={}
local game={GetService=function(_self:any,name:string)return if name=="Players"then Players elseif name=="ReplicatedStorage"then ReplicatedStorage else {GenerateGUID=function()return "generated"end}end}
local remotes={}
local Instance={new=function(kind:string):any
 local item:any={kind=kind};item.OnServerEvent={Connect=function(_self:any,callback:any)item.receive=callback end}
 item.FireClient=function(_self:any,player:any,view:any)item.last=U.copy(view)end
 table.insert(remotes,item);return item
end}
local task={defer=function(fn:any)fn()end}
local script={Parent={Parent={Systems={PlayerCombatInput="../../src/server/Systems/PlayerCombatInput"}},Services={HeroMentorWorld="mock-hero",HeroMentorReceiptAdapter="mock-receipt"}}}
local function context(enabled:boolean?,launch:boolean?):any
 local h:any={heroActive=false,playerActive=false,heroState=nil,playerState=nil,executed=0,flushed=0,heroCalls=0,playerCalls=0,baselineCalls=0,inCombat=false,reward=nil}
 local player={UserId=1,Parent=Players};h.player=player
 local mentorWorld:any=nil
 local crosshavenWorld:any={Active=function()return h.playerActive end,Class3State=function()return h.playerState end,
  Intent=function(_p:any,action:string,args:any)h.playerCalls+=1;h.lastKind="player";return if action=="CancelClass3Trial" and h.playerState and h.playerState.status=="Saving" then "SavePending"else "OK"end}
 local hero:any={Active=function()return h.heroActive end,Class3State=function()return h.heroState end,State=function()return h.heroState end,
  Intent=function(_p:any,action:string,args:any)h.heroCalls+=1;h.lastKind="hero";return if action=="CancelClass3Trial" and h.heroState and h.heroState.status=="Saving"then "SavePending"else "OK"end,Remove=function()end}
 local Data:any={Sessions={[1]={state="Active",record={revision=1,data={novice=true}}}},Execute=function()h.executed+=1;return "OK"end,Refresh=function()h.refreshed=true;return "OK"end,FlushAudit=function()h.flushed+=1 end}
 local World:any={ValidateIntent=function(_p:any,action:string)h.baselineCalls+=1;return h.baseProblem end,Remove=function()end,
  CampaignContext=function()return {model={GetAttribute=function()return h.inCombat end}}end,SharedRewardState=function()return h.reward end,
  Update=function()end,IntentCommitted=function()end}
 local HeroTrials={};local Class3Proof={};local class3Enabled=enabled~=false;local launchEnabled=launch==true
 local Release={problem=function()return h.releaseProblem end};local Expansion={usesNoviceProgression=function(d:any)return d.novice end}
 local sharedMentorActive:any=nil
 local class3Notify=function()end;local makeClass3Receipt=function()end
 local Network:any=nil
 local function require(path:any):any if path=="mock-hero"then return function(deps:any)h.heroDeps=deps;return hero end end;return realRequire(path)end
 -- INSERT ADMISSION
 -- INSERT ROUTING
 local factory=(function()
 -- INSERT NETWORK
 end)()
 Network=factory({Protocol=Protocol,Data=Data,World=World,Mode="test",Log=function()end,Load=function()return "OK"end,
  Project=function()return {data={hallLevel=11},status="Active"}end})
 h.world=World;h.data=Data;h.network=Network;h.admission=trialAdmission
 h.send=function(action:string,args:any?,extra:any?):any
  Network.Remove(player)
  local command
  local state
  for _,remote in ipairs(remotes)do if remote.Name=="Command"then command=remote elseif remote.Name=="State"then state=remote end end
  local packet:any={version=1,requestId="public",revision=1,action=action,args=args or {}}
  for key,value in pairs(extra or {})do packet[key]=value end
  command.receive(player,packet);return state.last
 end
 return h
end
test("Class3 candidate gate permits only explicit zero-ID Studio Memory full route",function()
 local runtime={Class3ProofCandidate=true,StudioPersistence="Memory"};local c={isStudio=true,placeId=0,gameId=0}
 eq(class3Candidate(runtime,c,true,false),true)
 for _,key in ipairs({"Class3ProofCandidate","StudioPersistence"})do local r=U.copy(runtime);r[key]=nil;eq(class3Candidate(r,c,true,false),false)end
 eq(class3Candidate(runtime,c,false,false),false);eq(class3Candidate(runtime,c,true,true),false)
 for key,value in pairs({isStudio=false,placeId=1,gameId=1})do local cc=U.copy(c);cc[key]=value;eq(class3Candidate(runtime,cc,true,false),false)end
 eq(class3Candidate({Class3ProofCandidate=true,StudioPersistence="DataStore"},c,true,false),false)
end)
test("Actual Network callbacks route bounded public starts and cancel without Execute",function()
 local h=context();eq(h.send("StartClass3Trial",{actorId="player",pathId="warlord"}).code,"OK");eq(h.lastKind,"player")
 eq(h.send("StartClass3Trial",{actorId="h:1",pathId="fortress"}).code,"OK");eq(h.lastKind,"hero")
 h.heroState={actorId="h:1",pathId="fortress",status="Active"};h.heroActive=true
 eq(h.send("CancelClass3Trial",{}).code,"OK");eq(h.executed,0)
 eq(h.send("StartClass3Trial",{actorId="h:1",pathId="fortress",owner=2}).code,"InvalidRequest")
 eq(h.send("StartClass3Trial",{actorId="h:1",pathId="fortress"},{owner=2}).code,"InvalidRequest")
 for _,args in ipairs({{actorId="",pathId="warlord"},{actorId=2,pathId="warlord"},{actorId=string.rep("a",65),pathId="warlord"},{actorId="player",pathId=string.rep("x",65)},{actorId="player",pathId="warlord",status="Won"}})do eq(h.send("StartClass3Trial",args).code,"InvalidRequest")end
 eq(h.send("CancelClass3Trial",{actorId="h:1"}).code,"InvalidRequest")
 eq(h.send("Class3Proof",{}).code,"InvalidRequest");eq(h.executed,0)
end)
test("Network state whitelist excludes trial secrets and receipt payload",function()
 local h=context();h.heroState={actorId="h:1",pathId="fortress",status="Saving",problem="SavePending",owner=1,token="secret",receipt={args={secret=true}},epoch=7}
 local state=h.send("GetState").data.class3Session
 eq(state,{actorId="h:1",pathId="fortress",status="Saving",problem="Class3SavePending"})
end)
test("Actual Bootstrap validator blocks starts and build mutations while Saving but allows recovery",function()
 local h=context();h.heroActive=true;h.heroState={actorId="h:1",pathId="fortress",status="Saving"}
 for _,action in ipairs({"StartClass3Trial","AdvanceClass","AllocateStatusPoints","TravelZone","StartHeroMentor"})do eq(h.world.ValidateIntent(h.player,action,{}),"Class3Busy")end
 for _,action in ipairs({"GetState","RetrySave","CancelClass3Trial"})do eq(h.world.ValidateIntent(h.player,action,{}),nil)end
 eq(h.send("CancelClass3Trial").code,"Class3SavePending");eq(h.send("RetrySave").code,"OK");eq(h.refreshed,true)
end)
test("Actual routing preserves wrong-kind cancellation and optional gating",function()
 local h=context();eq(h.world.Class3Intent(h.player,"CancelClass3Trial",{}),"InvalidAction")
 h.playerState={actorId="player",pathId="warlord",status="Active"};h.playerActive=true
 eq(h.world.ValidateIntent(h.player,"CancelHeroMentor",{}),"Class3Busy")
 eq(h.world.Class3Intent(h.player,"CancelClass3Trial",{}),"OK");eq(h.lastKind,"player");eq(h.heroCalls,0)
 local off=context(false);eq(off.send("StartClass3Trial",{actorId="player",pathId="warlord"}).code,"Class3TrialUnavailable");eq(off.executed,0)
 h=context();h.data.Sessions[1].busy=true;eq(h.send("StartClass3Trial",{actorId="player",pathId="warlord"}).code,"Class3ProfileNotReady")
 h=context();h.releaseProblem="LaunchContentUnavailable";eq(h.send("StartClass3Trial",{actorId="player",pathId="warlord"}).code,"Class3LaunchContentUnavailable");eq(h.playerCalls,0)
 h=context();h.data.Sessions[1].record.data.novice=false;eq(h.send("StartClass3Trial",{actorId="player",pathId="warlord"}).code,"Class3TrialUnavailable")
end)
test("Mutual exclusion and shared settlement use actual Bootstrap admission callback",function()
 local h=context();h.playerActive=true;eq(h.admission(h.player,true),"HeroMentorActive");h.playerActive=false
 h.heroActive=true;eq(h.admission(h.player,false),"HeroMentorActive");h.heroActive=false
 h.inCombat=true;eq(h.admission(h.player,true),"FinishExpedition");h.inCombat=false
 for _,status in ipairs({"PendingPreparation","PendingDelivery"})do h.reward={status=status};eq(h.admission(h.player,true),"SavePending")end
 h.reward=nil;eq(h.admission(h.player,true),nil)
 h.playerActive=true;eq(h.world.ValidateIntent(h.player,"AdvanceClass",{}),"Class3Busy")
end)
test("Server Class3 lifecycle mapping has actual bilingual translations",function()
 for _,code in ipairs({"HeroMentorStarted","HeroMentorSaving","HeroMentorComplete","HeroMentorCancelled","HeroMentorFailed","HeroChanged","HeroMentorUnavailable","ClassTrialLocked","HeroMentorActive","SavePending","SessionChanged","ReceiptHistoryUnavailable","ReturnToCrosshaven"})do
  local mapped=class3Code(code);for _,lang in ipairs({"en","th"})do assert(L.translate(lang,mapped)~=mapped,lang.." missing "..mapped)end
 end
end)
print(tostring(checks).." source-loaded network/routing checks passed; fake host only.")
