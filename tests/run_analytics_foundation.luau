--!strict
local Util=require("../src/shared/Util/TableUtil")
local count=0
require("./analytics_foundation")(function(name:string,f:any)f();count+=1;print("PASS "..name)end,function(a:any,b:any)assert(Util.equal(a,b),"Values differ")end)
print("Analytics foundation checks passed: "..count)
