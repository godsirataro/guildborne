--!strict
local count=0
local U=require("../src/shared/Util/TableUtil")
local function eq(a:any,b:any)assert(U.equal(a,b),"Expected "..tostring(b)..", got "..tostring(a))end
local function test(name:string,run:any)local ok,problem=pcall(run);assert(ok,name..": "..tostring(problem));count+=1;print("PASS "..name)end
require("./human_party")(test,eq)
print(count.." human party checks passed (local synthetic evidence).")
