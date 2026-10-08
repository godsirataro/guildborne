--!strict
local rules=require("../src/shared/Data/Expansion")
local protocol=require("../src/shared/Network/Protocol")
local place=require("../src/shared/Data/LandBuildingPlacement")(rules,require("../src/shared/Data/IslandPlacement"),require("../src/shared/Config/GuildIslandLayout"))
return function(test:any,eq:any)
    local function data():any return {expansion={buildings={}},guildLand={plots={}}} end
    test("paid land placement preserves legacy coordinates and requires opened land",function()
        local d=data();eq(place(d,"warehouse",6,-4,0),true)
        local ok,reason=place(d,"warehouse",-11,-3,0);eq(ok,false);eq(reason,"PlotLocked")
        d.guildLand.plots.grove={questUnlocked=true,entitlement={reference="fixture"}};eq(place(d,"warehouse",-11,-3,0),false)
        d.guildLand.plots.grove.opened=true;eq(place(d,"warehouse",-11,-3,0),true)
        for rotation=0,3 do eq(place(d,"warehouse",-11,-3,rotation),true) end
    end)
    test("paid land footprints cannot cross a locked neighboring plot or block access",function()
        local d=data();d.guildLand.plots.grove={opened=true}
        local ok,reason=place(d,"warehouse",-11,0,0);eq(ok,false);eq(reason,"PlotLocked")
        d.guildLand.plots.quarry={opened=true};eq(place(d,"warehouse",-11,0,0),true)
        ok,reason=place(d,"warehouse",-6,-3,0);eq(ok,false);eq(reason,"ReservedAccess")
        eq(place(d,"warehouse",-13,-3,3),false) -- west-facing entrance at edge
    end)
    test("paid land moves preserve ownership and reject overlap",function()
        local d=data();d.guildLand.plots.grove={opened=true};d.expansion.buildings.a={kind="warehouse",x=6,z=-4,rotation=0}
        eq(place(d,"warehouse",-11,-3,0,"a"),true)
        d.expansion.buildings.a={kind="warehouse",x=-11,z=-3,rotation=0}
        eq(place(d,"warehouse",-11,-3,1,"a"),true)
        eq(place(d,"forge",-11,-3,0),false)
        eq(place(d,"warehouse",6,-4,0,"a"),true)
        local ok,reason=place(d,"warehouse",-11,-3,0,"foreign");eq(ok,false);eq(reason,"BuildingNotOwned")
    end)
    test("client land projection and server opened state agree on build preview",function()
        local server=data();server.guildLand.plots.summit={opened=true}
        local client=data();client.guildLand.plots.summit={status="Buildable"}
        for x=-13,-7 do for z=7,11 do for rotation=0,3 do
            local a,ac=place(server,"forge",x,z,rotation);local b,bc=place(client,"forge",x,z,rotation);eq(a,b);eq(ac,bc)
        end end end
        for _,value in ipairs({math.huge,0/0,-200,.5}) do eq(place(server,"forge",value,8,0),false) end
    end)
    test("two stud placement accepts exact quarters and preserves overlap and access lanes",function()
        local d=data();eq(place(d,"warehouse",6.25,-3.75,0),true)
        d.expansion.buildings.a={kind="warehouse",x=6.25,z=-3.75,rotation=0}
        eq(place(d,"forge",8,-3.75,0),false);eq(place(d,"forge",8.25,-3.75,0),true)
        eq(place(d,"forge",8.25,-1.75,0),false)
        eq(place(d,"forge",8.25,.25,0),false);eq(place(d,"forge",8.25,.75,0),false)
        eq(place(d,"forge",8.25,1,0),true)
        d.guildLand.plots.grove={opened=true};eq(place(d,"forge",-10.75,-2.75,1),true)
        for _,x in ipairs({6.1,6.125,math.huge,0/0}) do eq(place(d,"forge",x,-3,0),false) end
    end)
    test("placement protocol allows bounded quarter grid but keeps other quantities integral",function()
        for _,action in ipairs({"PlaceBuilding","MoveBuilding","RestoreBuilding"}) do
            local args:any={x=6.25,z=-3.75,rotation=1}
            if action=="PlaceBuilding" then args.kind="forge" else args.buildingId="b:1" end
            local packet:any={version=1,requestId="fine",revision=0,action=action,args=args}
            eq(protocol.validate(packet),true)
            for _,value in ipairs({6.1,6.125,101,math.huge,0/0}) do args.x=value;eq(protocol.validate(packet),false) end
            args.x=6.25;args.rotation=.25;eq(protocol.validate(packet),false)
        end
        eq(protocol.validate({version=1,requestId="fine",revision=0,action="ContributeGuildPlot",args={plotId="grove",itemId="timber",amount=.25}}),false)
    end)
end
