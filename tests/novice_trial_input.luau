--!strict
return function(test:any,eq:any)
 local make=require("../src/server/Systems/NoviceTrialInput")
 test("Novice input accepts only owner attack intents with finite monotonic clocks",function()
  local accept=make(7)
  local invalid:{any}={"Victory","NoviceTrial","NoviceObjective","Damage","",{},123}
  for _,action in ipairs(invalid)do eq(accept(7,action,1,0),false)end
  eq(accept(8,"Basic",1,0),false);eq(accept(7,"Basic",1,1),false)
  eq(accept(7,"Basic",math.huge,0),false);eq(accept(7,"Basic",0/0,0),false)
  eq(accept(7,"Basic",1,0),true);eq(accept(7,"Ability",.9,0),false);eq(accept(7,"Ability",1,0),true)
  eq(accept(7,"Return",1,0),true)
 end)
 test("Novice input budget is bounded and foreign spam cannot consume owner tokens",function()
  local accept=make(7)
  for i=1,100 do eq(accept(i+10,"Basic",1,0),false)end
  for _=1,8 do eq(accept(7,"Basic",1,0),true)end
  local ok,code=accept(7,"Basic",1,0);eq(ok,false);eq(code,"RateLimited")
  eq(accept(7,"Ability",1.2,0),true);eq(accept(7,"Ability",1.2,0),false)
  eq(accept(7,"Ability",3,0),true)
 end)
end
