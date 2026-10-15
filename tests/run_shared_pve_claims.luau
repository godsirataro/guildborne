--!strict
local U=require("../src/shared/Util/TableUtil")
local passed=0
local function test(name:string,f:any)local ok,problem=pcall(f);assert(ok,name..": "..tostring(problem));passed+=1;print("PASS "..name)end
local function eq(a:any,b:any)assert(U.equal(a,b),"Expected "..tostring(b)..", got "..tostring(a))end
require("./shared_pve_claims")(test,eq)
print(passed.." shared claims checks passed (injected, no cloud acceptance).")
