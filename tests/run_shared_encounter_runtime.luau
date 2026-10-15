--!strict
local U=require("../src/shared/Util/TableUtil");local count=0
local function eq(a:any,b:any)assert(U.equal(a,b),"Expected "..tostring(b)..", got "..tostring(a))end
local function test(name:string,f:any)local ok,problem=pcall(f);assert(ok,name..": "..tostring(problem));count+=1;print("PASS "..name)end
require("./shared_encounter_runtime")(test,eq)
print(count.." shared runtime checks passed (injected synthetic evidence).")
