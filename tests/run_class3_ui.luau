--!strict
local U=require("../src/shared/Util/TableUtil")
local passed=0
local function eq(a:any,b:any)assert(U.equal(a,b),"Values differ")end
local function test(name:string,run:()->())run();passed+=1;print("PASS "..name)end
require("./class3_ui")(test,eq)
require("./class3_proof")(test,eq)
print(string.format("%d Class3 projection/domain checks passed; native UI acceptance remains pending.",passed))
