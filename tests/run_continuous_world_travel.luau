--!strict
local count=0
local function eq(a:any,b:any)assert(a==b,"Expected "..tostring(b)..", got "..tostring(a))end
local function test(name:string,run:any)local ok,problem=pcall(run);assert(ok,name..": "..tostring(problem));count+=1;print("PASS "..name)end
require("./continuous_world_travel")(test,eq)
print(count.." continuous walking service checks passed (platform adapter, not Studio acceptance).")
