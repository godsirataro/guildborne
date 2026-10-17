-- Real production cursor with real shared clock policy; no Roblox simulation.
local Timeline=require("../src/shared/Presentation/ActionTimeline")
local create=require("../src/shared/Presentation/NoviceActionPresentation")
local cursor=create(Timeline.accept)
assert(not cursor.observe(10,10.1,false),"Missing payload consumed cast")
assert(cursor.observe(10,10.2,true),"Delayed complete payload lost")
assert(not cursor.observe(10,10.3,true),"Duplicate replayed")
assert(not cursor.observe(9.9,10.3,true),"Reordered live cast replayed")
local invalid: {any} = {false,"10",0/0,math.huge,-math.huge,20,9}
for _,stamp in ipairs(invalid) do
    assert(not cursor.observe(stamp,10.3,true),"Invalid timestamp consumed")
end
assert(not cursor.observe(nil,10.3,true))
assert(not cursor.observe(10.1,0/0,true))
assert(not cursor.observe(10.1,math.huge,true))
assert(cursor.observe(10.2,10.3,true),"Invalid/future observations poisoned cursor")
assert(not cursor.observe(11,11.1,false))
assert(not cursor.observe(11,11.7,true),"Expired delayed payload replayed")
assert(cursor.observe(11.8,11.9,true))
-- Cancellation does not erase the consumed timestamp. A fresh arena does.
assert(not cursor.observe(nil,12,true))
assert(not cursor.observe(11.8,12,true),"Cancelled cast restarted")
cursor.reset()
assert(cursor.observe(11.8,12,true),"New arena inherited old cursor")
-- Independent arenas/controllers must not share the cursor.
local other=create(Timeline.accept)
assert(other.observe(11.8,12,true))
assert(not cursor.observe(11.8,12,true))
print("PASS novice presentation cursor: delayed payload, duplicate/reordered, invalid/future/expired, cancellation and lifecycle isolation")
