--!strict
local U=require("../src/shared/Util/TableUtil")
local count=0
local function test(name:string,fn:any)local ok,err=pcall(fn);assert(ok,name..": "..tostring(err));count+=1;print("PASS "..name)end
local function eq(a:any,b:any)assert(U.equal(a,b),"expected "..tostring(b)..", got "..tostring(a))end
require("./class3_transaction_integration")(test,eq)
print(tostring(count).." Class3 transaction integration checks passed; fake store only.")
