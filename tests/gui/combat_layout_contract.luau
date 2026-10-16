--!strict
-- Real layout arithmetic; not an engine render or physical-device acceptance.
local Layout=require("../../src/shared/Data/CombatHudLayout")
local count=0
for _,width in ipairs({320,390,600,740,900,1024,1366}) do
 for _,height in ipairs({280,340,500,640,844}) do
  local layout=Layout(width,height)
  assert(layout.cardHeight>=44,"Actor targets must remain touch sized")
  if not layout.collapsed then
   local rows=math.ceil(6/layout.columns)
   assert((rows-1)*layout.cardStride+layout.cardHeight<=layout.selectionHeight,"Six actual cards must fit the declared roster")
  end
  if width>=900 and height>=640 then
   assert(layout.cardWidth>=184 and layout.cardHeight>=60,"Desktop must retain readable portrait/name space")
   assert(64+layout.selectionHeight<height-layout.healthBottom-layout.healthHeight,"Roster must not touch actor context")
  end
  count+=1
 end
end
print("PASS combat portrait layout contract: "..count.." viewport cases")
