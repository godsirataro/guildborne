--!strict
local util=require("../src/shared/Util/TableUtil");local passed=0
local function test(name:string,callback:any)local ok,problem=pcall(callback);assert(ok,name..": "..tostring(problem));passed+=1;print("PASS "..name)end
local function eq(a:any,b:any)assert(util.equal(a,b),"Expected "..tostring(b)..", got "..tostring(a))end
require("./campaign")(test,eq)
require("./campaign_continuation")(test,eq)
require("./ashen_campaign")(test,eq)
require("./tower_campaign")(test,eq)
require("./tower_lessons")(test,eq)
require("./tower_guardian")(test,eq)
require("./region_annexes")(test,eq)
require("./escort_run")(test,eq)
require("./ironveil_tasks")(test,eq)
require("./borrowed_paths")(test,eq)
print(passed.." campaign tests passed.")
