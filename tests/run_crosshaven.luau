--!strict
local util=require("../src/shared/Util/TableUtil")
local n=0
local function test(name:string,callback:any)callback();n+=1;print("PASS "..name)end
local function eq(a:any,b:any)assert(util.equal(a,b),"Expected "..tostring(b)..", got "..tostring(a))end
require("./crosshaven_campaign")(test,eq)
require("./borrowed_mastery")(test,eq)
print(n.." Crosshaven campaign tests passed")
