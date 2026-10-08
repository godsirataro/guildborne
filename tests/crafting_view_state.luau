--!strict
return function(test:any,eq:any)
 local describe=require("../src/shared/Data/CraftingViewState")
 local content=require("../src/server/Config/Content");local util=require("../src/shared/Util/TableUtil")
 local rules=require("../src/shared/Data/Expansion")
 local service=require("../src/server/Services/ExpansionService")(content,util,require("../src/server/Services/EconomyService")(content,util),rules)
 local catalog={Items=content.Items,EquipmentLimit=content.Limits.Equipment,StackLimit=content.Limits.Stack}
 local function ready(id:string):any
  return {hallLevel=3,personalGuild={buildings={guildHall=3}},inventory={stacks=util.copy(rules.Recipes[id].Cost),equipment={},nextEquipmentSequence=1},expansion={buildings={one={kind="forge"}}}}
 end
 test("crafting readiness matches authoritative outcome for every recipe and capacity boundary",function()
  for _,id in ipairs(rules.RecipeOrder) do for _,mode in ipairs({"ready","forge","hall","materials","equipment","stack","sequence"}) do
   local d=ready(id);local recipe=rules.Recipes[id]
   if mode=="forge"then d.expansion.buildings={}
   elseif mode=="hall"then d.hallLevel=1;d.personalGuild.buildings.guildHall=1
   elseif mode=="materials"then for item in pairs(recipe.Cost) do d.inventory.stacks[item]-=1;break end
   elseif mode=="equipment"then for i=1,catalog.EquipmentLimit do d.inventory.equipment[tostring(i)]={} end
   elseif mode=="stack"then d.inventory.stacks[recipe.Item]=catalog.StackLimit
   elseif mode=="sequence"then d.inventory.nextEquipmentSequence=1000000000 end
   local before=util.copy(d);local state=describe(d,catalog,rules,id,false);eq(d,before)
   local candidate=util.copy(d);local problem=service.apply(candidate,"CraftItem",{recipeId=id},0,function()end)
   eq(state.canCraft,problem==nil,id.." "..mode)
   if not problem then eq(candidate.inventory.nextEquipmentSequence,d.inventory.nextEquipmentSequence+1) end
  end end
 end)
 test("crafting materials expose exact shortage and retain stable sorted labels",function()
  local d=ready("iron_ingot");d.inventory.stacks.iron_ore=1
  local s=describe(d,catalog,rules,"iron_ingot",false)
  eq(s.materials,{{id="iron_ore",owned=1,needed=3,missing=2},{id="stone",owned=1,needed=1,missing=0}})
  eq(s.canCraft,false);d.inventory.stacks.iron_ore=3;eq(describe(d,catalog,rules,"iron_ingot",false).canCraft,true)
  eq(describe(d,catalog,rules,"iron_ingot",true).problem,"Waiting for the current action.")
 end)
end
