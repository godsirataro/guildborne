-- Pure selector contract; no Studio, audio playback or combat acceptance.
local C=require("../src/shared/Presentation/CombatCueEvents")
return function()
    local s=C.new()
    assert(C.ActionTTL==require("../src/shared/Presentation/ActionTimeline").Duration)
    for _,bad in ipairs({false,"10",0/0,math.huge,-math.huge,0,-1}) do
        assert(not C.admit(s,"action",bad,10,1,true))
        C.discard(s,"action",bad,10)
    end
    assert(not C.admit(s,"action",nil,10,1,true))
    assert(not C.admit(s,"action",10,0/0,1,true))
    assert(not C.admit(s,"action",10,10,-1,true))
    assert(not C.admit(s,"action",10,10,math.huge,true))
    assert(C.admit(s,"action",10,10,1,true))
    assert(not C.admit(s,"action",10,10.1,1,true))
    assert(not C.admit(s,"action",9.9,10.1,1,true))
    assert(C.admit(s,"hit",10,10.1,1,true),"Channels must be independent")
    print("PASS cue validation and per-channel monotonic admission")

    s=C.new()
    assert(not C.admit(s,"action",20,10,1,true))
    C.discard(s,"action",20,10)
    assert(C.admit(s,"action",10,10,1,true),"Future observation poisoned highwater")
    assert(C.admit(s,"action",20,20.1,1,true),"Formerly future stamp may become valid")
    assert(not C.admit(s,"action",30,40,1,true))
    assert(not C.admit(s,"action",29,29.1,1,true),"Expired observation failed to suppress regression")
    assert(not C.admit(s,"action",30,30.1,1,true),"Expired work revived after clock reversal")
    print("PASS future nonpoisoning and expired highwater")

    s=C.new()
    assert(not C.admit(s,"action",50,50,.5,false))
    assert(C.admit(s,"action",50,50.5,.5,true),"Delayed target at original TTL boundary")
    assert(not C.admit(s,"action",50,50.5,.5,true))
    assert(not C.admit(s,"action",51,51,.5,false))
    assert(not C.admit(s,"action",51,51.6,.5,true),"Readiness renewed TTL")
    assert(not C.admit(s,"action",52,52,1,false))
    assert(not C.admit(s,"action",52.1,52.1,1,false))
    assert(not C.admit(s,"action",52,52.2,1,true),"Pending older event survived newer observation")
    assert(C.admit(s,"action",52.1,52.2,1,true))
    print("PASS pending readiness, original TTL and supersession")

    s=C.new()
    assert(not C.admit(s,"action",60,60,1,false))
    C.discard(s,"action",60,60.1)
    assert(not C.admit(s,"action",60,60.2,1,true),"Revival replayed cancelled event")
    C.discard(s,"action",61,61)
    assert(not C.admit(s,"action",60.5,61,1,true))
    assert(C.admit(s,"action",62,62,1,true),"Cancellation blocked newer action")
    assert(C.admit(C.new(),"action",60,60,1,true),"New model must have independent state")
    print("PASS discard, retained lifecycle state and model isolation")

    for _,cancel in ipairs({function(state) C.admit(state,"action",nil,10.05,1,false) end,
        function(state) C.discard(state,"action",nil,10.05) end}) do
        s=C.new()
        assert(not C.admit(s,"action",10,10,1,false))
        cancel(s)
        assert(not C.admit(s,"action",10,10.1,1,true),"Removed attribute replayed pending stamp")
        assert(C.admit(s,"action",10.1,10.1,1,true),"Nil cancellation reset/blocked newer stamp")
    end
    s=C.new()
    assert(not C.admit(s,"action",10,10,1,false))
    assert(not C.admit(s,"action",11,10.1,1,true))
    C.discard(s,"action",0/0,10.1)
    assert(not C.admit(s,"action",10,0/0,1,true))
    assert(C.admit(s,"action",10,10.2,1,true),"Malformed/future observation cancelled pending work")
    print("PASS explicit nil cancellation without invalid-observation poisoning")

    assert(C.warningValid(10,11,10,"Windup"))
    assert(C.warningValid(10,11,10.99,"Windup"))
    for _,v in ipairs({{10,11,11,"Windup"},{10,11,9,"Windup"},{10,10,10,"Windup"},
        {10,9,10,"Windup"},{0,11,10,"Windup"},{10,11,10,"Idle"},{10,math.huge,10,"Windup"},
        {0/0,11,10,"Windup"},{10,11,0/0,"Windup"}}) do
        assert(not C.warningValid(v[1],v[2],v[3],v[4]))
    end
    assert(not C.warningValid(nil,11,10,"Windup"))
    assert(C.recent(10,10,0) and not C.recent(10,10.01,0))
    assert(not C.recent(11,10,1) and not C.recent(10,11.01,1))
    print("PASS warning state, finite clocks and interval boundaries")
end
