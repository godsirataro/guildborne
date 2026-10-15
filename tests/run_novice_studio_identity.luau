--!strict
local U=require("../src/shared/Util/TableUtil")
local passed=0
local function test(name:string,f:any)local ok,problem=pcall(f);assert(ok,name..": "..tostring(problem));passed+=1;print("PASS "..name)end
local function eq(a:any,b:any)assert(U.equal(a,b),"Expected "..tostring(b)..", got "..tostring(a))end
require("./novice_studio_identity")(test,eq)
print(passed.." Novice Studio identity checks passed (pure, not Studio integration).")
