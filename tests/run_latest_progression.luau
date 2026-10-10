--!strict
-- Additional targeted suite; the existing game regression entrypoint is unchanged.
local passed=0
local function eq(actual:any,expected:any)
 assert(actual==expected,"Expected "..tostring(expected)..", got "..tostring(actual))
end
local function test(name:string,run:()->())
 run();passed+=1;print("PASS "..name)
end
require("./latest_progression_gates")(test,eq)
print(string.format("%d latest-progression checks passed; Studio visual acceptance separate.",passed))
