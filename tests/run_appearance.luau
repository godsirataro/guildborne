--!strict
local util=require("../src/shared/Util/TableUtil")
local passed=0
local function test(name: string,callback: any)
	local ok,problem=pcall(callback);assert(ok,name..": "..tostring(problem));passed+=1;print("PASS "..name)
end
local function eq(actual: any,expected: any)assert(util.equal(actual,expected),"Expected "..tostring(expected)..", got "..tostring(actual))end
require("./appearance")(test,eq)
print(passed.." appearance tests passed. Studio/import/device acceptance is separate.")
