--!strict
local n=0
local function test(name:string,callback:any)callback();n+=1;print("PASS "..name)end
local function eq(a:any,b:any)assert(a==b,"Expected "..tostring(b)..", got "..tostring(a))end
require("./player_guild_membership")(test,eq)
require("./player_guild_recovery")(test,eq)
require("./player_guild_roster")(test,eq)
require("./player_guild_schema")(test,eq)
require("./player_guild_coordinator")(test,eq)
require("./player_guild_removal")(test,eq)
require("./player_guild_founder")(test,eq)
require("./player_guild_operations")(test,eq)
require("./player_guild_store")(test,eq)
print(n.." player guild tests passed")
