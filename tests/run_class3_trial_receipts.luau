--!strict
local util=require("../src/shared/Util/TableUtil")
local passed=0
local function eq(actual:any,expected:any)assert(util.equal(actual,expected),"Expected "..tostring(expected)..", got "..tostring(actual))end
local function test(name:string,run:()->())run();passed+=1;print("PASS "..name)end
require("./class3_trial_receipts")(test,eq)
require("./borrowed_mastery")(test,eq)
require("./hero_mentor")(test,eq)
require("./class3_proof")(test,eq)
print(string.format("%d Class3 trial/domain/adapter checks passed; native and persistence integration remain pending.",passed))
