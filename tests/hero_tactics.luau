--!strict
return function(test:any,eq:any)
 local T=require("../src/server/Systems/HeroTactics")
 local Input=require("../src/server/Systems/PlayerCombatInput")
 local U=require("../src/shared/Util/TableUtil")
 local function distance(a:any,b:any):number return math.abs(a.x-b.x)end
 local targeting=require("../src/server/Systems/CombatTargeting")(distance)
 local function actor(id:string,kind:string,x:number):any return {id=id,kind=kind,owner=1,x=x,active=true,health=100,state="Idle",detectionRange=40}end
 test("balanced tactics retains existing targeting while defensive bounds protection",function()
  local a=actor("h:1","Hero",0);local leader=actor("player","Hero",0)
  local close=actor("near","Enemy",3);local threat=actor("threat","Enemy",10);threat.target=leader
  local distant=actor("far","Enemy",30);local all={distant,close,threat}
  eq(T.select(a,leader,all,targeting,true,true,0,distance),targeting.enemy(a,all,nil,40,0))
  T.apply(a,"TacticDefensive",0);eq(T.select(a,leader,all,targeting,true,true,0,distance),threat)
  threat.owner=2;eq(T.select(a,leader,all,targeting,true,true,0,distance),close)
  eq(T.select(a,leader,{distant},targeting,true,true,0,distance),nil)
  a.tauntUntil=10;a.tauntTarget=distant;eq(T.select(a,leader,{close,distant},targeting,true,true,0,distance),nil)
 end)
 test("manual overrides supersede presets without modifying health stats or cooldowns",function()
  local a=actor("h:1","Hero",0);a.cooldowns={heal=99};a.stats={Attack=7};local leader=actor("player","Hero",0);local e=actor("e","Enemy",25)
  T.apply(a,"TacticDefensive",0);T.apply(a,"Focus",0);a.focusTarget=e
  eq(T.select(a,leader,{e},targeting,true,true,0,distance),e)
  local before=U.copy({a.health,a.stats,a.cooldowns})
  for _,order in ipairs({"Hold","Regroup","Retreat"})do T.apply(a,order,7);eq(T.select(a,leader,{e},targeting,true,true,0,distance),nil)end
  eq({a.health,a.stats,a.cooldowns},before)
  T.apply(a,"Hold",7);eq(a.holdPoint,7);T.apply(a,"TacticBalanced",0);eq(a.holdPoint,nil);eq(a.order,nil)
  T.apply(a,"Hold",5);T.clear(a);eq(a.holdPoint,nil);eq(a.order,nil)
 end)
 test("tactical decisions preserve engagement leash and focus validity",function()
  local a=actor("h:1","Hero",0);local leader=actor("player","Hero",0);local e=actor("e","Enemy",4)
  T.apply(a,"Focus",0);a.focusTarget=e
  eq(T.select(a,leader,{e},targeting,true,false,0,distance),nil)
  eq(T.select(a,leader,{e},targeting,false,true,0,distance),nil)
  e.active=false;eq(T.select(a,leader,{e},targeting,true,true,0,distance),nil)
 end)
 test("formation offsets separate five same-role heroes and place ranged behind tanks",function()
  for _,class in ipairs({"Knight","Warrior","Archer","Mage","Priest"})do
   local seen={};for slot=1,5 do local p=T.offset(class,slot);local key=p.x..":"..p.z;eq(seen[key],nil);seen[key]=true end
  end
  local mixed={"Warrior","Mage","Priest","Knight","Archer"}
  for i=1,5 do for j=i+1,5 do local a,b=T.offset(mixed[i],i),T.offset(mixed[j],j);assert(math.abs(a.x-b.x)>=3)end end
  assert(T.offset("Knight",1).z<T.offset("Warrior",1).z)
  assert(T.offset("Warrior",1).z<T.offset("Priest",1).z)
 end)
 test("tactics protocol has no client position target skill or stat authority",function()
  for _,action in ipairs({"Hold","TacticBalanced","TacticDefensive"})do
   eq(Input.valid({action=action,actorId="h:1"}),true)
   for _,field in ipairs({"position","target","owner","skill","stats"})do local p:any={action=action,actorId="h:1"};p[field]=1;eq(Input.valid(p),false)end
  end
  eq(Input.valid({action="TacticAggressive",actorId="h:1"}),false)
  local B=require("../src/shared/Config/CombatBindings");eq(B.action("J","Keyboard"),nil);eq(B.action("K","Keyboard"),"Hold");eq(B.hint("Hold","Keyboard")," [K]");eq(B.action("DPadRight","Gamepad1"),"Hold")
 end)
 test("tactic feedback has English and Thai explanations",function()
  local L=require("../src/shared/Config/Localization")
  for _,key in ipairs({"TacticBalanced","TacticDefensive","TacticHolding","TacticRegrouping","TacticProtecting","TacticGuarding","TacticCooldown","TacticEvading"})do
   for _,language in ipairs({"en","th"})do assert(L.translate(language,key)~=key)end
  end
 end)
end
