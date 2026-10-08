--!strict
local make=require("../src/shared/Data/IslandPlacement")
return function(test: any,eq: any)
    local function rules()
        return make({width=12,height=12,spawn={x=1,z=1},reserved={{x=0,z=0,w=3,d=3}},plots={home={x=0,z=0,w=6,d=12},east={x=6,z=0,w=6,d=12}},buildings={hall={w=3,d=2},wall={w=1,d=12}},maxBuildings=8})
    end
    test("island building needs owned footprint and preserves reserved arrival area",function()
        local p=rules();local b={kind="hall",x=4,z=4,rotation=0}
        local ok,code=p.validate({home=true},{},b);eq(ok,false);eq(code,"PlotLocked")
        eq(p.validate({home=true,east=true},{},b),true)
        b.x=0;b.z=0;local _,reserved=p.validate({home=true},{},b);eq(reserved,"ReservedAccess")
        b.x=11;b.z=4;local _,outside=p.validate({home=true,east=true},{},b);eq(outside,"OutsideIsland")
    end)
    test("island relocation excludes exactly the owned moving footprint",function()
        local p=rules();local existing={a={kind="hall",x=3,z=4,rotation=0}}
        local b={kind="hall",x=3,z=4,rotation=1}
        local _,overlap=p.validate({home=true,east=true},existing,b);eq(overlap,"BuildingOverlap")
        eq(p.validate({home=true,east=true},existing,b,"a"),true)
        local _,foreign=p.validate({home=true,east=true},existing,b,"foreign");eq(foreign,"BuildingNotOwned")
    end)
    test("island edit cannot sever the portal route to an existing hall",function()
        local p=rules();local existing={a={kind="hall",x=8,z=5,rotation=0}}
        local b={kind="wall",x=5,z=0,rotation=1}
        -- Rotation0 spans the island north/south, with its entrance to the east.
        b.rotation=0
        local _,blocked=p.validate({home=true,east=true},existing,b)
        -- North-facing wall at boundary has no legal entrance even before route search.
        eq(blocked,"EntranceBlocked")
        local gate=make({width=12,height=12,spawn={x=1,z=1},reserved={},plots={all={x=0,z=0,w=12,d=12}},buildings={hall={w=3,d=2},barrier={w=12,d=1}}})
        local _,path=gate.validate({all=true},{a={kind="hall",x=4,z=8,rotation=0}},{kind="barrier",x=0,z=5,rotation=0})
        eq(path,"AccessBlocked")
    end)
    test("island rejects nonfinite inputs and diagonal-only access",function()
        local p=rules()
        for _,n in ipairs({0/0,math.huge,-1,.5}) do eq(p.validate({home=true},{},{kind="hall",x=n,z=4,rotation=0}),false) end
        local diagonal=make({width=6,height=6,spawn={x=0,z=0},reserved={},plots={a={x=0,z=0,w=2,d=2},b={x=2,z=2,w=4,d=4}},buildings={hut={w=1,d=1}}})
        local _,code=diagonal.validate({a=true,b=true},{},{kind="hut",x=3,z=4,rotation=0});eq(code,"AccessBlocked")
    end)
    test("island route clearance rejects passages too narrow for the configured actor",function()
        local config={width=12,height=14,spawn={x=1,z=1},reserved={},plots={all={x=0,z=0,w=12,d=14}},buildings={hut={w=1,d=1},barrier={w=10,d=1}},clearance=0}
        local existing={a={kind="hut",x=4,z=10,rotation=0}};local candidate={kind="barrier",x=0,z=5,rotation=0}
        eq(make(config).validate({all=true},existing,candidate),true)
        config.clearance=1;local _,code=make(config).validate({all=true},existing,candidate);eq(code,"AccessBlocked")
    end)
end
