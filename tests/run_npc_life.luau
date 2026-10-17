--!strict
local count=0
require("./npc_life")(function(name:string,run:any)
    local ok,err=pcall(run);assert(ok,name..": "..tostring(err));count+=1;print("PASS "..name)
end,function(actual:any,expected:any)assert(actual==expected,"expected "..tostring(expected)..", got "..tostring(actual))end)
print(tostring(count).." NPC life tests passed")
