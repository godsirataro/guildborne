--!strict
local U=require("../src/shared/Util/TableUtil");local count=0
require("./shared_combat_rewards")(function(name:string,run:any)run();count+=1;print("PASS "..name)end,function(a:any,b:any)assert(U.equal(a,b),"Values differ")end)
print("Shared combat rewards checks passed: "..count)
