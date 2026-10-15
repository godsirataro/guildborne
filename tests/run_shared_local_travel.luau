--!strict
local count=0
local function eq(a:any,b:any)assert(a==b,"Expected "..tostring(b)..", got "..tostring(a))end
local function test(name:string,f:any)local ok,problem=pcall(f);assert(ok,name..": "..tostring(problem));count+=1;print("PASS "..name)end
require("./shared_local_travel")(test,eq)
print(count.." local travel rule checks passed (no Studio adapter acceptance).")
