--!strict
local U=require("../src/shared/Util/TableUtil")
local passed=0
local function test(name:string,f:any)local ok,problem=pcall(f);assert(ok,name..": "..tostring(problem));passed+=1;print("PASS "..name)end
local function eq(a:any,b:any)assert(U.equal(a,b),"Expected "..tostring(b)..", got "..tostring(a))end
require("./shared_combat_coordinator")(test,eq)
print(passed.." shared combat coordinator checks passed (pure, not Studio integration).")
-- A generated local harness supplies unmodified HeroService closures because the
-- standalone Luau CLI cannot require Roblox service modules or read source files.
return function(makePaths:any)
	local before=passed
	require("./shared_combat_coordinator")(test,eq,makePaths)
	print((passed-before).." HeroService source-harness checks passed (mock scheduler, not Studio).")
end
