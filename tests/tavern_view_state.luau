--!strict
return function(test:any,eq:any)
 local describe=require("../src/shared/Data/TavernViewState");local util=require("../src/shared/Util/TableUtil")
 local content=require("../src/server/Config/Content")
 local catalog={Tavern=content.Tavern,EquipmentLimit=content.Limits.Equipment}
 local function ready():any
  return {gold=1000,hallLevel=2,rosterCapacity=5,adventurers={},inventory={stacks={timber=5,stone=3},equipment={}},quests={},expansion={tower={}},settlement={tavernLevel=1,nextHero=1,nextOffer=2,offer={id="offer:1",classId="Warrior",rank="F"}}}
 end
 test("tavern candidate costs follow every rank and exact gold boundary without mutations",function()
  for index,rank in ipairs(content.Tavern.Ranks) do
   local d=ready();d.settlement.offer.rank=rank;d.gold=content.Tavern.HireCost+(index-1)*10
   local before=util.copy(d);local state=describe(d,catalog,false);eq(state.hireCost,d.gold);eq(state.hireProblem,nil);eq(d,before)
   d.gold-=1;eq(describe(d,catalog,false).hireProblem,"You need more Gold.")
  end
  local d=ready();d.gold=content.Tavern.ScoutCost;eq(describe(d,catalog,false).scoutProblem,nil)
  d.gold-=1;eq(describe(d,catalog,false).scoutProblem,"You need more Gold.")
  local changed=util.copy(catalog);changed.Tavern.ScoutCost=37;changed.Tavern.HireCost=43;d.gold=43
  eq(describe(d,changed,false).scoutCost,37);eq(describe(d,changed,false).hireCost,43)
 end)
 test("tavern readiness blocks roster, starting-weapon capacity, expeditions and recovery",function()
  local d=ready();eq(describe(d,catalog,false).hireProblem,nil)
  for i=1,5 do d.adventurers[tostring(i)]={} end
  eq(describe(d,catalog,false).scoutProblem,"Your roster is full.");eq(describe(d,catalog,false).hireProblem,"Your roster is full.")
  d.adventurers={};for i=1,content.Limits.Equipment do d.inventory.equipment[tostring(i)]={} end
  eq(describe(d,catalog,false).hireProblem,"Free one equipment slot for the starting weapon.");eq(describe(d,catalog,false).scoutProblem,nil)
  d.inventory.equipment={};d.quests.active={};eq(describe(d,catalog,false).hireProblem,"Finish your expedition first.")
  d.quests.active=nil;d.expansion.tower.active={};eq(describe(d,catalog,false).scoutProblem,"Finish your expedition first.")
  d.expansion.tower.active=nil;local state=describe(d,catalog,true)
  eq(state.hireProblem,"Waiting for the current action.");eq(state.scoutProblem,state.hireProblem);eq(state.upgradeProblem,state.hireProblem)
  d.settlement.offer=nil;eq(describe(d,catalog,false).hireProblem,"Scout a candidate first.")
 end)
 test("tavern upgrade readiness follows Hall, material and maximum-level gates",function()
  local d=ready();d.gold=100;eq(describe(d,catalog,false).upgradeProblem,nil)
  d.hallLevel=1;eq(describe(d,catalog,false).upgradeProblem,"Upgrade your Guild Hall first.")
  d.hallLevel=2;d.inventory.stacks.timber=4;eq(describe(d,catalog,false).upgradeProblem,"Gather the required materials first.")
  d.inventory.stacks.timber=5;d.inventory.stacks.stone=2;eq(describe(d,catalog,false).upgradeProblem,"Gather the required materials first.")
  d.inventory.stacks.stone=3;d.gold=99;eq(describe(d,catalog,false).upgradeProblem,"You need more Gold.")
  d.settlement.tavernLevel=5;eq(describe(d,catalog,false).upgradeProblem,"Tavern is at maximum level.")
 end)
end
