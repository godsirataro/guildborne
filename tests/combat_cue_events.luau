-- Pure selector contract; no Studio, audio playback or combat acceptance.
local C=require("../src/shared/Presentation/CombatCueEvents")
return function(presentation: any?)
    local s=C.new()
    assert(C.ActionTTL==require("../src/shared/Presentation/ActionTimeline").Duration)
    local invalid: {any}={false,"10",0/0,math.huge,-math.huge,0,-1}
    for _,bad in ipairs(invalid) do
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

    -- Optional actual-controller helpers, extracted by the documented local runner.
    -- Standard cue tests above always run; this is no duplicate policy model.
    if presentation then
        local cards,mode=presentation.visibleHealthCards,presentation.overheadMode
        local function fixture()
            local function node(kind: string,parent: any,name: string): any
                local n: any={ClassName=kind,Parent=parent,Name=name,Visible=true,Enabled=true,
                    AbsoluteSize={X=150,Y=50},AbsolutePosition={X=8,Y=64},children={},attributes={}}
                function n:IsA(class: string): boolean return self.ClassName==class or (class=="GuiObject" and (self.ClassName=="Frame" or self.ClassName=="TextButton")) end
                function n:FindFirstChild(key: string): any return self.children[key] end
                function n:GetAttribute(key: string): any return self.attributes[key] end
                if parent then parent.children[name]=n end
                return n
            end
            local pg=node("PlayerGui",nil,"PlayerGui")
            local hud=node("ScreenGui",pg,"GuildbornePlayerCombatUI")
            local selection=node("Frame",hud,"CompanionSelection")
            local card=node("TextButton",selection,"Actor2");card.attributes.ActorId="hero-a"
            local track=node("Frame",card,"HealthTrack");track.AbsoluteSize={X=130,Y=4}
            return pg,hud,selection,card,track
        end
        local viewport={X=1280,Y=720}
        local pg,hud,selection,card,track=fixture()
        assert(cards(pg,viewport)["hero-a"])
        assert(mode(true,true,true,true,true,false)=="off")
        assert(mode(true,true,true,true,true,true)=="compact")
        assert(mode(true,true,false,false,true,false)=="off","Own player card should suppress redundant label")
        assert(mode(true,true,false,false,false,false)=="full","Player needs HUD-absent fallback")
        print("PASS party label visible card and transient feedback policy")
        for _,target in ipairs({hud,selection,card,track}) do
            if target==hud then target.Enabled=false else target.Visible=false end
            local covered=cards(pg,viewport)["hero-a"]==true
            assert(not covered and mode(true,true,true,true,covered,false)=="full","Hidden card must restore full overhead")
            target.Enabled=true;target.Visible=true
        end
        print("PASS disabled HUD and each hidden ancestor restore fallback")
        card.attributes.ActorId="hero-b"
        assert(not cards(pg,viewport)["hero-a"] and cards(pg,viewport)["hero-b"],"Reused party slot retained old actor")
        card.Visible=false
        assert(not cards(pg,viewport)["hero-b"],"Collapsed unselected card suppressed overhead")
        card.Visible=true;card.attributes.ActorId="player"
        assert(cards(pg,viewport).player and not cards(pg,viewport)["hero-b"])
        print("PASS slot reuse, collapse and exact player identity")
        for _,position in ipairs({{X=-1,Y=64},{X=1200,Y=64},{X=8,Y=719},{X=8,Y=-1}}) do
            track.AbsolutePosition=position
            assert(not cards(pg,viewport).player,"Offscreen HP track suppressed fallback")
        end
        track.AbsolutePosition={X=8,Y=64};track.AbsoluteSize={X=0,Y=4}
        assert(not cards(pg,viewport).player)
        track.AbsoluteSize={X=130,Y=4};card.AbsoluteSize={X=0,Y=0}
        assert(not cards(pg,viewport).player)
        print("PASS offscreen and unlaid-out cards do not claim HP coverage")
        pg,hud,selection,card,track=fixture()
        hud.Parent=nil;assert(not cards(pg,viewport)["hero-a"])
        hud.Parent=pg;track.Parent=nil;assert(not cards(pg,viewport)["hero-a"])
        track.Parent=card;card.attributes.ActorId="";assert(next(cards(pg,viewport))==nil)
        card.attributes.ActorId=false;assert(next(cards(pg,viewport))==nil)
        pg.children.GuildbornePlayerCombatUI=nil;assert(next(cards(pg,viewport))==nil)
        print("PASS removed HUD, detached track and invalid identities fall back")
        assert(mode(false,true,true,true,true,true)=="off","Foreign actor privacy changed")
        assert(mode(true,false,true,true,false,true)=="off","Invalid HP became visible")
        assert(mode(true,true,true,false,false,true)=="off","Nonfollowing hero became visible")
        assert(mode(true,true,false,false,false,true)=="full","Enemy action/warning label was compacted")
        assert(mode(true,true,false,false,false,false)=="full","Enemy health label disappeared")
        print("PASS owner, membership, invalid HP and enemy policy preserved")
    end
end
