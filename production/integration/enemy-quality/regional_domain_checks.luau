-- Focused real server-domain regressions, not native animation acceptance.
local count=0
local Util=require("../../../src/shared/Util/TableUtil")
local function test(name,run)
    run();count+=1;print("PASS "..name)
end
local function eq(actual,expected)
    assert(Util.equal(actual,expected),"Expected "..tostring(expected)..", got "..tostring(actual))
end
require("../../../tests/adventure_patterns")(test,eq)
require("../../../tests/adventure_brain")(test,eq)
require("../../../tests/adventure_lifecycle")(test,eq)
local catalog=require("../../../src/server/Config/AdventureEncounters")
local tuning=require("../../../src/server/Config/AdventureEnemyProfiles")
test("Ironveil canonical authored pair preserves entry identity and combat tuning",function()
    eq(catalog.Regions.Ironveil.Encounters[1].Asset,"quarry_raider")
    eq(catalog.Regions.Ironveil.Encounters[4].Asset,"quarry_guardian")
    eq(catalog.Regions.Ironveil.Encounters[4].Role,"Boss")
    eq(tuning.quarry_raider.health,210);eq(tuning.quarry_raider.power,18);eq(tuning.quarry_raider.interval,1.5)
    eq(tuning.quarry_guardian.health,950);eq(tuning.quarry_guardian.power,32);eq(tuning.quarry_guardian.speed,8)
end)
print("PASS regional focused domain checks: "..count.." cases; no Studio/device proof")
