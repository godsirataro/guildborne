--!strict
local Util=require("../src/shared/Util/TableUtil")
local count=0
local function eq(a:any,b:any)assert(Util.equal(a,b),"Values differ: "..tostring(a).." / "..tostring(b))end
require("./launch_rewards")(function(name:string,f:any)f();count+=1;print("PASS "..name)end,eq)
print("Launch rewards tests passed: "..count)
