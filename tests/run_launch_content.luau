--!strict
local util=require("../src/shared/Util/TableUtil")
local passed=0
local function test(name:string,callback:any)
 local ok,problem=pcall(callback);assert(ok,name..": "..tostring(problem));passed+=1;print("PASS "..name)
end
local function eq(a:any,b:any)assert(util.equal(a,b),"Expected "..tostring(b)..", got "..tostring(a))end
require("./launch_content")(test,eq)
print(passed.." launch-content checks passed; synthetic policy evidence only.")
