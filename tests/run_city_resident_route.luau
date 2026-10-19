--!strict
local count=0
local function test(name:string,fn:any)
	local ok,err=pcall(fn)
	assert(ok,name..": "..tostring(err));count+=1;print("PASS "..name)
end
local function eq(a:any,b:any) assert(a==b,"expected "..tostring(b)..", got "..tostring(a)) end
require("./city_resident_route")(test,eq)
print(tostring(count).." city resident route checks passed; pure simulation only.")
