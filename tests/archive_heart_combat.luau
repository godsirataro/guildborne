--!strict
return function(test:any,eq:any)
 local util=require("../src/shared/Util/TableUtil");local config=require("../src/server/Config/ArchiveHeartEncounters")
 local content=require("../src/server/Config/Content");local combat=require("../src/server/Config/Combat")
 local gear=require("../src/shared/Data/Equipment")(content,require("../src/shared/Data/Expansion"),require("../src/shared/Data/StatusPoints"))
 local create=require("../src/server/Systems/ArchiveHeartCombat")({Util=util,Content=content,Combat=combat,EncounterConfig=config,
  Create=require("../src/server/Systems/ArchiveHeartEncounter")(config,util,require("../src/server/Systems/AdventurePatterns")),
  Stats=require("../src/server/Systems/CombatStats")(content,combat,gear),Targeting=require("../src/server/Systems/CombatTargeting"),Damage=require("../src/server/Systems/CombatDamage"),Abilities=require("../src/server/Systems/CombatAbilities")})
 local function profile(class:string):any return {character={classId=class,level=100},personalGuild={buildings={guildHall=17}},progression={campaign={claimed=35,objectives={}}},quests={},expansion={tower={}}}end
 local function open(s:any):number
  local at=s.snapshot().deadline;s.step(at,{x=0,y=0,z=16},true,true);local w=s.snapshot().warning
  local safe=if w.shape=="Line"then {x=10,y=0,z=0}elseif w.shape=="Ring"then {x=0,y=0,z=0}else {x=w.x+9,y=0,z=w.z}
  at=s.snapshot().deadline;s.step(at,safe,true,true)
  for _,action in ipairs({"Rescue","Release"})do at+=.1;s.step(at,s.snapshot().target,true,true);eq(s.act(action,at),true)end
  return at
 end
 test("Archive native-combat bridge completes all five roots with real CombatDamage basic events",function()
  for _,class in ipairs(content.AdventurerOrder)do
   local data=profile(class);local before=util.copy(data);local s=assert(create(data,1,class,"keeper",100));local at=100
   for stage=1,3 do
    at=open(s)
    while s.snapshot().phase=="Attack"do
     at+=2.3;s.step(at,{x=0,y=0,z=4},true,true);eq(s.input("Basic",at),true)
    end
    eq(s.snapshot().seals,stage)
   end
   eq(s.snapshot().status,"Won");assert(s.snapshot().combatHits>=3);eq(assert(s.receipt(at,1)).args.objective,"complete_keeper_of_names");eq(data,before)
  end
 end)
 test("Archive bridge shields cores and rejects stale distant invalid or premature attacks",function()
  local s=assert(create(profile("Warrior"),1,"gates","keeper",100));eq(select(2,s.input("Basic",100)),"CoreShielded")
  local at=open(s);s.step(at,{x=20,y=0,z=0},true,true);eq(select(2,s.input("Basic",at)),"OutOfRange")
  eq(select(2,s.input("Basic",at+1)),"SampleRequired");eq(select(2,s.input("hit:9999",at)),"InvalidAction")
  s.step(at+.1,{x=0,y=0,z=4},true,true);eq(s.input("Ability",at+.1),true)
  eq(s.snapshot().seals,1);eq(select(2,s.input("Basic",at+.1)),"CoreShielded")
  s.cancel();eq(select(2,s.input("Basic",at+.2)),"Cancelled")
 end)
 test("Archive support skills do not invent damage and hostile skills obey server ranges",function()
  for _,class in ipairs({"Knight","Priest","Mage","Archer"})do
   local s=assert(create(profile(class),1,class,"keeper",100));local at=open(s);s.step(at+.1,{x=0,y=0,z=4},true,true)
   local ok,code=s.input("Ability",at+.1)
   if class=="Priest"then eq(ok,false);eq(code,"NoDeficit");eq(s.snapshot().combatHits,0)
   elseif class=="Knight"then eq(ok,true);eq(s.snapshot().combatHits,0);eq(s.snapshot().phase,"Attack")
   else eq(ok,true);eq(s.snapshot().combatHits,1);eq(s.snapshot().seals,1)end
  end
 end)
end
