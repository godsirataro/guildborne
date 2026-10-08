--!strict
local util=require("../src/shared/Util/TableUtil")
local passed=0
local function test(name:string,callback:any)
 local ok,problem=pcall(callback);assert(ok,name..": "..tostring(problem));passed+=1;print("PASS "..name)
end
local function eq(actual:any,expected:any)assert(util.equal(actual,expected),"Expected "..tostring(expected)..", got "..tostring(actual))end
require("./novice_story")(test,eq)
require("./novice_trials")(test,eq)
require("./novice_trial_combat")(test,eq)
require("./novice_receipt_adapter")(test,eq)
require("./novice_trial_manager")(test,eq)
require("./novice_trial_input")(test,eq)
require("./novice_lessons")(test,eq)
print(tostring(passed).." Novice story tests passed.")
