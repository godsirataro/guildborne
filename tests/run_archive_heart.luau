--!strict
local util=require("../src/shared/Util/TableUtil")
local n=0
local function test(name:string,callback:any)callback();n+=1;print("PASS "..name)end
local function eq(a:any,b:any)assert(util.equal(a,b),"Expected "..tostring(b)..", got "..tostring(a))end
require("./archive_heart_campaign")(test,eq)
require("./archive_heart_encounters")(test,eq)
require("./archive_heart_combat")(test,eq)
print(n.." Archive Heart tests passed")
