--!strict
local Util=require("../../src/shared/Util/TableUtil")
local count=0
local function eq(a:any,b:any)assert(Util.equal(a,b),"expected "..tostring(b)..", got "..tostring(a))end
local function test(name:string,callback:any)
 local ok,problem=pcall(callback);assert(ok,name..": "..tostring(problem));count+=1;print("PASS "..name)
end
require("./walking_route_context")(test,eq)
require("./walking_quest_routes")(test,eq)
require("../city_waypoint")(test,eq)
require("../quest_tracker")(test,eq)
print("SUMMARY "..count.." cases passed")
