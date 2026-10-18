--!strict
-- Targeted pure-source regression. Native collector/Studio acceptance is separate.
local Util=require("../../src/shared/Util/TableUtil")
local passed=0
local function eq(actual:any,expected:any)
 assert(Util.equal(actual,expected),"expected "..tostring(expected)..", got "..tostring(actual))
end
local function test(name:string,callback:any)
 local ok,problem=pcall(callback)
 assert(ok,name..": "..tostring(problem))
 passed+=1;print("PASS "..name)
end
require("../city_waypoint")(test,eq)
require("../quest_tracker")(test,eq)
print("PASS targeted route/tracker "..passed)
