--!nocheck
-- Fake host tests source-loaded by world-check.py; no Roblox execution claim.
local mt={}
local function V(x,y,z)return setmetatable({X=x,Y=y,Z=z},mt)end
mt.__index=function(v,k)if k=="Magnitude"then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z)elseif k=="Unit"then local n=v.Magnitude;return V(v.X/n,v.Y/n,v.Z/n)end end
mt.__add=function(a,b)return V(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
mt.__sub=function(a,b)return V(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
mt.__mul=function(a,b)return V(a.X*b,a.Y*b,a.Z*b)end
local CFrame={new=function(p)return {Position=p}end,lookAt=function(p)return {Position=p}end}
local callbacks,queue={},{}
local RunService={Heartbeat={Connect=function(_,f)table.insert(callbacks,f);return {Disconnect=function()end}end}}
local Players={};local Http={GenerateGUID=function()return "trial"end}
local Server={Systems={CombatTargeting="target",CombatDamage="damage",CombatAbilities="ability"}}
local Rules={Abilities={}};local Combat={};local Gear={loadout=function()return {}end,extras=function()return {}end}
local Stats={hero=function()return {}end}
local function require(_)return function()end end
local function object(kind)
 local o={Parent=true,attributes={},kind=kind,Position=V(0,0,0)}
 function o:SetAttribute(k,v)self.attributes[k]=v end
 function o:GetAttribute(k)return self.attributes[k]end
 function o:IsA(k)return self.kind==k end
 function o:GetPivot()return {Position=self.Position}end
 function o:PivotTo(c)self.Position=c.Position;if self.root then self.root.Position=c.Position end end
 function o:IsDescendantOf(parent)return self.Parent==parent end
 function o:Destroy()self.Parent=nil end
 o.Triggered={Connect=function(_,f)o.trigger=f;return {Disconnect=function()end}end}
 return o
end
local Instance={new=object};local workspace={GetServerTimeNow=function()return 1 end}
local Color3={fromRGB=function()return {}end,new=function()return {}end}
local UDim2={fromOffset=function()return {}end,fromScale=function()return {}end}
local task={spawn=function(f)table.insert(queue,f)end}
local function warn(_)end
-- WORLD_FACTORY_SOURCE
local function eq(a,b)assert(a==b,tostring(a).." ~= "..tostring(b))end
local count=0
local function test(name,f)f();count+=1;print("PASS "..name)end
local function fixture()
 callbacks={};queue={}
 local f={notices={},oldNotices={},combat="Active",outcome="Retry",reason="SavePending"}
 local character=object("Model");character.root=object("BasePart");local hum={Health=100}
 function character:FindFirstChild(k)return if k=="HumanoidRootPart"then self.root else nil end
 function character:FindFirstChildOfClass(_)return hum end
 local hero=object("Model");hero.PrimaryPart={Anchored=true};local heroParent=object("Model");hero.Parent=heroParent
 local player=object("Player");player.Parent=Players;player.UserId=42;player.Character=character;player:SetAttribute("CurrentZone","Guild")
 local session={epoch=1,token="a",state="Active",record={data={}}};local data={Sessions={[42]=session}}
 local trial={}
 local function start(_,owner,actor,path,id,now)return {actorId=actor,pathId=path,hero={classId="Warrior",level=70,name="Hero"},status="Active"}end
 trial.start=start;trial.startClass3=function(...)local r=start(...);r.proof={};return r end
 trial.matches=function()return true end;trial.class3ActivityProblem=function()return nil end
 trial.sessionView=function(e)return if e then {actorId=e.run.actorId,status="Active"}else nil end
 trial.receipt=function()return {}end
 trial.combat=function()return {actor={stats={AttackRange=4,MaxHealth=100}},patient={health=100},step=function()return f.combat end,snapshot=function()return {heroHealth=100,enemyHealth=0,effect=true}end}end
 local deps={Data=data,Trial=trial,Class3Proof={},World={CampaignContext=function()return {origin=V(0,0,0),model=object("Model")}end,BeginHeroMentor=function()return hero end,EndHeroMentor=function()hero.Parent=heroParent end},
  MakeClass3Receipt=function()return function()if f.deliver then f.deliver()end;return f.outcome,f.reason end end,
  MakeReceipt=function()return function()return f.outcome,f.reason end end,
  AdmissionProblem=function()return f.admission end,
  Notify=function(_,code)table.insert(f.oldNotices,code or "empty")end,
  Class3Notify=function(_,code)table.insert(f.notices,{code=code,state=f.world.Class3State(player)})end}
 f.world=makeWorld(deps);f.player=player;f.session=session;f.data=data;f.character=character;f.hum=hum
 function f.start(class3)return f.world.Intent(player,if class3 then "StartClass3Trial"else "StartHeroMentor",{actorId="h:1",pathId="warlord"})end
 function f.tick()for _,cb in ipairs(callbacks)do cb(.1)end end
 function f.deliverQueued()local tasks=queue;queue={};for _,cb in ipairs(tasks)do cb()end end
 return f
end
test("world admission blocks both trial kinds before arena acquisition",function()
 for _,class3 in ipairs({true,false})do local f=fixture();f.admission="BorrowedTrialActive";eq(f.start(class3),"BorrowedTrialActive");eq(f.world.Active(f.player),false)end
end)
test("world separates legacy state and rejects wrong-kind cancellation",function()
 for _,class3 in ipairs({true,false})do
  local f=fixture();eq(f.start(class3),"OK")
  eq(f.world.State(f.player)==nil,class3);eq(f.world.Class3State(f.player)~=nil,class3)
  eq(f.world.Intent(f.player,if class3 then "CancelHeroMentor"else "CancelClass3Trial",{}),"InvalidAction");eq(f.world.Active(f.player),true)
  eq(f.world.Intent(f.player,if class3 then "CancelClass3Trial"else "CancelHeroMentor",{}),"OK");eq(f.world.Active(f.player),false)
  if class3 then eq(f.notices[#f.notices].state,nil);eq(#f.oldNotices,0)end
 end
end)
test("world pending preserves exact error and cancellation refuses degraded save",function()
 local f=fixture();eq(f.start(true),"OK");f.combat="Won";f.tick();f.deliverQueued()
 eq(f.world.Class3State(f.player).status,"Saving");eq(f.world.Class3State(f.player).problem,"SavePending")
 f.session.state="Degraded";eq(f.world.Intent(f.player,"CancelClass3Trial",{}),"SavePending");eq(f.world.Active(f.player),true)
 eq(f.notices[#f.notices].code,"SavePending")
end)
test("world rejected receipt notifies precise reason only after clearing activity",function()
 local f=fixture();eq(f.start(true),"OK");f.outcome="Rejected";f.reason="ReceiptHistoryUnavailable";f.combat="Won";f.tick();f.deliverQueued()
 eq(f.world.Class3State(f.player),nil);eq(f.notices[#f.notices].code,"ReceiptHistoryUnavailable");eq(f.notices[#f.notices].state,nil)
end)
test("world stale session after receipt yields no new session callback",function()
 local f=fixture();eq(f.start(true),"OK");f.outcome="Committed";f.reason="OK";f.combat="Won";f.tick()
 local notices=#f.notices;f.deliver=function()f.data.Sessions[42]={epoch=1,token="a",state="Active",record={data={}}}end
 f.deliverQueued();eq(#f.notices,notices);eq(f.world.Active(f.player),false)
end)
test("world same-session guard loss clears activity and notifies",function()
 local f=fixture();eq(f.start(true),"OK");f.hum.Health=0;f.tick();eq(f.world.Active(f.player),false)
 eq(f.notices[#f.notices].code,"HeroMentorCancelled");eq(f.notices[#f.notices].state,nil)
end)
test("world physical guard loss during delivery notifies but replaced character stays silent",function()
 for _,mode in ipairs({"death","movement","replacement"})do
  local f=fixture();eq(f.start(true),"OK");f.outcome="Committed";f.combat="Won";f.tick();local before=#f.notices
  f.deliver=function()
   if mode=="death"then f.hum.Health=0 elseif mode=="movement"then f.character.root.Position=V(900,0,0)else f.player.Character=object("Model")end
  end
  f.deliverQueued();eq(f.world.Active(f.player),false)
  if mode=="replacement"then eq(#f.notices,before)else eq(#f.notices,before+1);eq(f.notices[#f.notices].code,"ActorNotReady");eq(f.notices[#f.notices].state,nil)end
 end
end)
print(count.." source-loaded hero world checks passed; no Studio acceptance")
