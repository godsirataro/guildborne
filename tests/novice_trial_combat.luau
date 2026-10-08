--!strict
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local config=require("../src/server/Config/Combat");local trialConfig=require("../src/server/Config/NoviceTrials")
 local gear=require("../src/shared/Data/Equipment")(content,require("../src/shared/Data/Expansion"),require("../src/shared/Data/StatusPoints"))
 local stats=require("../src/server/Systems/CombatStats")(content,config,gear)
 local create=require("../src/server/Systems/NoviceTrialCombat")({Util=util,Content=content,Combat=config,Stats=stats,
  Trials=require("../src/server/Systems/NoviceTrialSession")(trialConfig,util),Targeting=require("../src/server/Systems/CombatTargeting"),Damage=require("../src/server/Systems/CombatDamage"),Abilities=require("../src/server/Systems/CombatAbilities")})
 local data={progression={novice={claimed=5}},character={level=10},party={adventurerIds={}},quests={},expansion={tower={}}}
 test("all five trial simulations earn lessons from real combat callbacks and produce one stable receipt",function()
  for _,classId in ipairs(content.AdventurerOrder)do
   local sim:any=create(data,1,classId,"battle1",100);local baseZ=if classId=="Warrior"or classId=="Knight"then 4 elseif classId=="Archer"then 16 else 12
   local p={x=0,y=0,z=baseZ};local ended=false
   for tick=1,1400 do
    local now=100+tick*.2;local s=sim.snapshot()
    if s.status~="Active"then eq(s.status,"Won");ended=true;break end
    if s.warning then
     -- Synthetic movement strategy, not a native avatar/physics acceptance claim.
     p={x=s.warning.x+8,y=0,z=s.warning.z}
    else p={x=0,y=0,z=baseZ} end
    eq(sim.step(now,p,true,true),nil)
    s=sim.snapshot();if s.status~="Active"then continue end
    local goals=trialConfig.Classes[classId].Goals;local lessons=true
    for kind,needed in pairs(goals)do if kind~="victory" and (s.progress[kind]or 0)<needed then lessons=false end end
    if classId=="Mage"or classId=="Knight"or classId=="Priest"then sim.input("Ability",now)end
    if lessons or classId=="Warrior"or classId=="Archer"or classId=="Knight"then sim.input("Basic",now)end
   end
   assert(ended,classId.." did not finish");local s=sim.snapshot();eq(s.enemyHealth,0);assert(s.playerHealth>0)
   local receipt,problem=sim.receipt(380);eq(problem,nil);eq(receipt.args.classId,classId);eq(sim.receipt(381),receipt)
   local before=util.copy(s);eq(sim.input("Basic",381),false);eq(sim.snapshot(),before)
  end
 end)
 test("trial combat uses range cooldown real restored health and fresh server samples",function()
  local sim:any=create(data,1,"Priest","battle1",100)
  eq(sim.input("Ability",101),false)
  eq(sim.step(101,{x=0,y=0,z=30},true,true),nil);eq(sim.input("Ability",101),false);eq(sim.snapshot().patientHealth,30)
  eq(sim.step(102,{x=0,y=0,z=12},true,true),nil);eq(sim.input("Ability",102),true)
  local s=sim.snapshot();assert(s.patientHealth>30);eq(s.progress.heal,math.min(40,s.patientHealth-30))
  eq(sim.input("Ability",102),false);eq(sim.snapshot(),s)
  eq(sim.step(103,{x="bad",y=0,z=0},true,true),"InvalidTrialSample")
  eq(sim.step(99,{x=0,y=0,z=0},true,true),"InvalidTrialSample");eq(sim.snapshot(),s)
 end)
 test("committed trial warning deals normal damage when not dodged and isolation failure stops combat",function()
  local sim:any=create(data,1,"Warrior","battle1",100);local p={x=0,y=0,z=4}
  eq(sim.step(102,p,true,true),nil);local before=sim.snapshot();assert(before.warning)
  eq(sim.step(103.3,p,true,true),nil);local after=sim.snapshot();assert(after.playerHealth<before.playerHealth);eq(after.progress.dodge,nil)
  eq(sim.step(104,p,false,true),"SoloTrialRequired");eq(sim.input("Basic",104),false);eq(sim.receipt(104),nil)
  sim=create(data,1,"Archer","battle2",100);eq(sim.step(101,{x=0,y=0,z=46},true,true),"TrialLeftArena")
  sim=create(data,1,"Mage","battle3",100);sim.cancel();eq(sim.input("Ability",101),false);eq(sim.snapshot().status,"Failed")
 end)
 test("trial input explains range and cooldown without damage or progress on rejected attacks",function()
  local sim:any=create(data,1,"Warrior","feedback1",100)
  eq(sim.step(101,{x=0,y=0,z=20},true,true),nil)
  local before=sim.snapshot();local ok,reason=sim.input("Basic",101);eq(ok,false);eq(reason,"OutOfRange");eq(sim.snapshot(),before)
  ok,reason=sim.input("Ability",101);eq(ok,false);eq(reason,"OutOfRange");eq(sim.snapshot(),before)
  eq(sim.step(101.1,{x=0,y=0,z=4},true,true),nil);eq(sim.input("Basic",101.1),true)
  before=sim.snapshot();ok,reason=sim.input("Basic",101.1);eq(ok,false);eq(reason,"Cooldown");eq(sim.snapshot(),before)
  eq(sim.input("Ability",101.1),true);before=sim.snapshot();ok,reason=sim.input("Ability",101.1);eq(ok,false);eq(reason,"Cooldown");eq(sim.snapshot(),before)
 end)
end
