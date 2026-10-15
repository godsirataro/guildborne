--!strict
return function(test:any,eq:any)
 local Service=require("../src/server/Services/TravelService")
 local R=require("../src/server/Systems/TravelRules")({Destinations={Guild={X=0,Y=5,Z=23,FallbackX=0,FallbackZ=14}}})
 local function fixture():any return {state="Active",record={},epoch=1,token="a"}end
 local function adapter():any
  local vm:any={};vm.__index=function(v:any,k:string):any if k=="Magnitude"then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z)end;return nil end
  local function v(x:number,y:number,z:number):any return setmetatable({X=x,Y=y,Z=z},vm)end
  vm.__add=function(a:any,b:any)return v(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
  vm.__sub=function(a:any,b:any)return v(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
  local function cf(a:any,b:any,c:any):any return {Position=if type(a)=="number"then v(a,b,c)else a}end
  local function model():any return {Parent=true,attributes={},GetAttribute=function(self:any,k:string)return self.attributes[k]end}end
  local plotModel=model();local geometry=model();local town=model();local session=fixture();local now=0;local step:any
  local state:any={blocked={},moves=0,gate=nil,session=session,geometry=geometry,plotModel=plotModel}
  local root:any={Position=v(0,5,23)};local humanoid={Health=100};local character=model()
  function character:FindFirstChild(name:string)return if name=="HumanoidRootPart"then root else nil end
  function character:FindFirstChildOfClass(_name:string)return humanoid end
  function character:GetPivot()return cf(root.Position)end
  function character:PivotTo(target:any)root.Position=target.Position;state.moves+=1 end
  local player:any={Character=character,RespawnLocation="home",attributes={}}
  function player:SetAttribute(k:string,value:any)self.attributes[k]=value end
  local plot={model=plotModel,origin=v(0,0,0),spawn="home"};local plots={[player]=plot}
  local config:any={Destinations={Guild={X=0,Y=5,Z=23,FallbackX=0,FallbackZ=14}},Regions={},GuildPortalStops={},contains=function()return false end,region=function()return nil end}
  local world:any={}
  function world:Raycast(target:any,_delta:any,params:any)return if state.blocked[params.FilterDescendantsInstances[1]]or(state.blockX and target.X==state.blockX)then nil else {Position=v(target.X,0,target.Z)}end
  function world:GetPartBoundsInBox(_frame:any,_size:any,_params:any)return {}end
  local platform={Config=config,Civic={Definitions={}},Rules=require("../src/server/Systems/TravelRules")(config),Vector3={new=v,zero=v(0,0,0)},CFrame={new=cf,lookAt=function(a:any,_b:any)return cf(a)end},
   RaycastParams={new=function()return {}end},OverlapParams={new=function()return {}end},Enum={RaycastFilterType={Include=1}},Workspace=world,
   RunService={Heartbeat={Connect=function(_self:any,callback:any)step=callback end}},Now=function()return now end}
  local descriptor={Session=function(_p:any)return state.session end,Gate=function(_p:any,enter:boolean)return state.gate or(if enter and state.closed then "TravelUnavailable"else nil)end,Geometry=geometry,
   Entry=function(_p:any)return {Position=v(0,5,23),Parent=true}end,Exit={Position=v(100,5,100),Parent=true},Landing=v(100,5,100),Fallback=v(108,5,100),Contains=function(p:any)return p.X>=90 and p.X<=120 and p.Z>=90 and p.Z<=120 end,Recover=function()return state.faulted==true end}
  local heroes={Travel=function(_p:any)state.heroMoves=(state.heroMoves or 0)+1 end}
  local city={town=town,spawn="city",regions={},guildAccessPortals={}}
  local service=Service(city,plots,heroes,descriptor,platform)
  state.service=service;state.player=player;state.root=root;state.character=character;state.v=v;state.platform=platform;state.city=city;state.plots=plots;state.heroes=heroes
  state.step=function()now+=3;step(.5)end
  return state
 end
 test("local travel requires active unbusy session and explicit individual presence",function()
  local s=fixture();local c={}
  eq(R.localValidate(s,c,nil,true,true,false,false,false,10,nil),nil)
  eq(R.localValidate(s,c,nil,true,true,false,false,false,17,nil),"VisitStation")
  eq(R.localValidate(s,c,nil,true,true,false,false,false,0/0,nil),"VisitStation")
  s.busy=true;eq(R.localValidate(s,c,nil,true,true,false,false,false,0,nil),"ActorNotReady")
  s.busy=false;s.state="Saving";eq(R.localValidate(s,c,nil,true,true,false,false,false,0,nil),"ActorNotReady")
 end)
 test("local travel preserves novice mentor downed combat and tower refusals",function()
  local s=fixture();local c={}
  for _,gate in ipairs({"NoviceJourneyRequired","MentorActive"})do eq(R.localValidate(s,c,nil,true,true,false,false,false,0,gate),gate)end
  eq(R.localValidate(s,c,nil,true,false,false,false,false,0,nil),"ActorNotReady")
  eq(R.localValidate(s,c,nil,true,true,true,false,false,0,nil),"Downed")
  eq(R.localValidate(s,c,nil,true,true,false,true,false,0,nil),"ReturnToGuild")
  eq(R.localValidate(s,c,nil,true,true,false,false,true,0,nil),"FinishExpedition")
 end)
 test("local return is bound to exact connection epoch token and character",function()
  local s=fixture();local c={};local saved={session=s,epoch=s.epoch,token=s.token,character=c}
  eq(R.localCurrent(saved,s),true);eq(R.localCurrent(saved,fixture()),false)
  eq(R.localValidate(s,c,saved,false,true,false,false,false,0,nil),nil)
  eq(R.localValidate(s,{},saved,false,true,false,false,false,0,nil),"ActorNotReady")
  s.epoch=2;eq(R.localCurrent(saved,s),false);s.epoch=1;s.token="b";eq(R.localCurrent(saved,s),false)
  s.token="a";s.closing=true;eq(R.localCurrent(saved,s),false)
 end)
 test("repeated entry cannot replace saved return and absent return is rejected",function()
  local s=fixture();local c={};local saved={session=s,epoch=s.epoch,token=s.token,character=c}
  eq(R.localValidate(s,c,saved,true,true,false,false,false,0,nil),"AlreadyThere")
  eq(R.localValidate(s,c,nil,false,true,false,false,false,0,nil),"TravelUnavailable")
 end)
 test("legacy travel rules and cooldown remain unchanged",function()
  eq(R.validate("Guild",true,false,false,false,16),nil)
  eq(R.validate("SharedLocalCandidate",true,false,false,false,0),"InvalidZone")
  local b={};eq(R.accept(b,10),true);eq(R.accept(b,11),false);eq(R.accept(b,12),true)
  local x,y,z=R.resolve("Guild",true);eq(x,0);eq(y,5);eq(z,23)
 end)
 test("actual travel adapter enters and returns original transform and respawn once",function()
  local f=adapter();local s=f.service;local p=f.player
  eq(s.EnterLocal(p),true);eq(s.IsLocal(p),true);eq(f.root.Position.X,100);eq(p.attributes.CurrentZone,"SharedLocalCandidate")
  eq(s.EnterLocal(p),false);eq(s.ReturnLocal(p),true);eq(s.IsLocal(p),false);eq(f.root.Position.X,0);eq(f.root.Position.Z,23);eq(p.RespawnLocation,"home");eq(f.heroMoves,2)
 end)
 test("actual travel adapter blocked destination and injected gate do not move or snapshot",function()
  local f=adapter();f.blocked[f.geometry]=true;eq(f.service.EnterLocal(f.player),false);eq(f.moves,0);eq(f.service.IsLocal(f.player),false)
  f.blocked[f.geometry]=nil;f.gate="MentorActive";eq(f.service.EnterLocal(f.player),false);eq(f.moves,0)
 end)
 test("actual travel adapter recovers falling same connection and clears replacement snapshot",function()
  local f=adapter();assert(f.service.EnterLocal(f.player));f.root.Position=f.v(100,-20,100);f.step();eq(f.service.IsLocal(f.player),false);eq(f.root.Position.Z,23)
  assert(f.service.EnterLocal(f.player));f.session=fixture();eq(f.service.ReturnLocal(f.player),false);f.step();eq(f.service.IsLocal(f.player),false);eq(f.root.Position.X,0)
 end)
 test("actual travel adapter remove and ordinary travel never retain lab return",function()
  local f=adapter();assert(f.service.EnterLocal(f.player));f.service.Remove(f.player);eq(f.service.IsLocal(f.player),false)
  local legacy=Service(f.city,f.plots,f.heroes,nil,f.platform);eq(legacy.EnterLocal(f.player),false);eq(legacy.Travel(f.player,"Guild"),true);eq(f.root.Position.Z,23)
 end)
 test("actual travel adapter blocked saved transform falls back and respawn returns",function()
  local f=adapter();f.root.Position=f.v(7,5,23);assert(f.service.EnterLocal(f.player));f.blockX=7
  eq(f.service.ReturnLocal(f.player),true);eq(f.root.Position.X,0)
  f.step();assert(f.service.EnterLocal(f.player));local replacement=table.clone(f.character);f.player.Character=replacement
  eq(f.service.ReturnLocal(f.player),false);f.service.Respawn(f.player);eq(f.service.IsLocal(f.player),false);eq(f.root.Position.X,0)
 end)
 test("actual travel adapter scene closed gate rejects entry but permits safe exit",function()
  local f=adapter();assert(f.service.EnterLocal(f.player));f.closed=true
  eq(f.service.ReturnLocal(f.player),true);f.step();eq(f.service.EnterLocal(f.player),false);eq(f.service.IsLocal(f.player),false)
 end)
 test("actual adapter fault recovery ignores stale domain combat but waits for active session",function()
  local f=adapter();assert(f.service.EnterLocal(f.player));f.plotModel.attributes.InCombat=true;f.character.attributes.CombatHealth=0;f.root.Position=f.v(120,5,120)
  eq(f.service.ReturnLocal(f.player),false);f.step();eq(f.service.IsLocal(f.player),true)
  f.faulted=true;f.session.state="Saving";f.step();eq(f.service.IsLocal(f.player),true)
  f.session.state="Active";f.session.busy=true;f.step();eq(f.service.IsLocal(f.player),true)
  f.session.busy=false;f.step();eq(f.service.IsLocal(f.player),false);eq(f.root.Position.X,0);eq(f.character.attributes.CombatHealth,0)
 end)
 test("new character heartbeat cannot consume return before delayed spawn settle callback",function()
  local f=adapter();f.root.Position=f.v(5,5,26);assert(f.service.EnterLocal(f.player))
  f.player.Character=table.clone(f.character);f.root.Position=f.v(0,5,23)
  f.step();eq(f.service.IsLocal(f.player),true);eq(f.root.Position.X,0)
  -- Engine spawn pivot may happen after the first heartbeat, before World.Respawn.
  f.root.Position=f.v(0,5,23);f.service.Respawn(f.player)
  eq(f.service.IsLocal(f.player),false);eq(f.root.Position.X,5);eq(f.root.Position.Z,26)
 end)
 test("spawn settle callback during Saving retains authorized recovery until Active",function()
  local f=adapter();f.root.Position=f.v(6,5,26);assert(f.service.EnterLocal(f.player))
  f.player.Character=table.clone(f.character);f.root.Position=f.v(0,5,23);f.session.state="Saving"
  f.service.Respawn(f.player);f.step();eq(f.service.IsLocal(f.player),true)
  f.session.state="Active";f.step();eq(f.service.IsLocal(f.player),false);eq(f.root.Position.X,6)
 end)
end
