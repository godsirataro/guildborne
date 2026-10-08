--!strict
return function(test:any,eq:any,harness:any,util:any,schema:any)
    local function setup():any
        local h=harness();h.setup()
        for _,id in ipairs({"timber","stone","herb","iron_ore"}) do h.data().inventory.stacks[id]=50 end
        eq(h.send("PlaceBuilding",{kind="warehouse",x=6.25,z=-3.75,rotation=1}),"OK")
        return h
    end
    test("layout switching reuses owned buildings and stores extras without material changes",function()
        local h=setup();eq(h.send("SaveBuildLayout",{slot=1}),"OK")
        eq(h.send("PlaceBuilding",{kind="forge",x=8.25,z=2,rotation=0}),"OK")
        eq(h.send("SaveBuildLayout",{slot=2}),"OK")
        local inventory=util.copy(h.data().inventory);local saved=util.copy(h.data().expansion.layouts)
        eq(h.send("MoveBuilding",{buildingId="b:1",x=6,z=2,rotation=0}),"OK")
        eq(h.data().expansion.layouts,saved)
        eq(h.send("ApplyBuildLayout",{slot=1}),"OK")
        eq(h.data().expansion.buildings["b:1"].x,6.25);eq(h.data().expansion.buildings["b:2"],nil)
        eq(h.data().expansion.storage["b:2"].kind,"forge")
        local command=h.command("ApplyBuildLayout",{slot=2})
        eq(h.service.Execute(1,command),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
        eq(util.count(h.data().expansion.buildings),2);eq(h.data().expansion.storage,{})
        eq(h.data().inventory,inventory);eq(h.data().expansion.nextBuilding,3)
        eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"layouts-rejoin"),"OK")
        eq(h.data().expansion.layouts,saved);eq(h.data().inventory,inventory)
    end)
    test("stale layouts cannot recreate dismantled buildings and deletion is replay safe",function()
        local h=setup();eq(h.send("SaveBuildLayout",{slot=1}),"OK")
        eq(h.send("DismantleBuilding",{buildingId="b:1"}),"OK")
        local before=util.copy(h.data());eq(h.send("ApplyBuildLayout",{slot=1}),"LayoutBuildingMissing");eq(h.data(),before)
        local command=h.command("DeleteBuildLayout",{slot=1})
        eq(h.service.Execute(1,command),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
        eq(h.data().expansion.layouts["1"],nil);eq(h.send("ApplyBuildLayout",{slot=1}),"LayoutNotFound")
    end)
    test("layout apply rechecks land permission and rejects invalid geometry atomically",function()
        local h=setup();eq(h.send("SaveBuildLayout",{slot=1}),"OK")
        local p=h.data().expansion.layouts["1"]["b:1"];p.x=-11;p.z=-3
        local before=util.copy(h.data());eq(h.send("ApplyBuildLayout",{slot=1}),"PlotLocked");eq(h.data(),before)
        p.x=99;p.z=99;before=util.copy(h.data())
        eq(h.send("ApplyBuildLayout",{slot=1}),"InvalidPlacement");eq(h.data(),before)
    end)
    test("layout requests accept only a bounded slot and no client building payload",function()
        local h=setup();local before=util.copy(h.data())
        eq(h.send("SaveBuildLayout",{slot=0}),"InvalidLayoutSlot")
        eq(h.send("SaveBuildLayout",{slot=4}),"InvalidLayoutSlot")
        eq(h.send("SaveBuildLayout",{slot=1,placements={}}),"InvalidRequest")
        eq(h.send("ApplyBuildLayout",{slot=1,ownerId="another"}),"InvalidRequest")
        eq(h.data(),before)
    end)
    test("layout save apply and delete recover uncertain commits without premature changes",function()
        for _,action in ipairs({"SaveBuildLayout","ApplyBuildLayout","DeleteBuildLayout"}) do for _,mode in ipairs({"before","after"}) do
            local h=setup()
            if action~="SaveBuildLayout" then eq(h.send("SaveBuildLayout",{slot=1}),"OK") end
            if action=="ApplyBuildLayout" then eq(h.send("MoveBuilding",{buildingId="b:1",x=8,z=2,rotation=0}),"OK") end
            local before=util.copy(h.data());h.mode=mode;local command=h.command(action,{slot=1})
            eq(h.service.Execute(1,command),"SavePending");eq(h.data(),before)
            h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
            eq(h.data().inventory,before.inventory);eq(schema.validate(h.service.Sessions[1].record,1),true)
            if action=="ApplyBuildLayout" then eq(h.data().expansion.buildings["b:1"].x,6.25)
            else eq(h.data().expansion.layouts["1"]~=nil,action=="SaveBuildLayout") end
        end end
    end)
    test("layout schema bounds slots positions and excludes embedded entitlements",function()
        local h=setup();eq(h.send("SaveBuildLayout",{slot=1}),"OK")
        local record=util.copy(h.service.Sessions[1].record)
        record.data.expansion.layouts["4"]={};eq(schema.validate(record,1),false)
        record.data.expansion.layouts["4"]=nil
        record.data.expansion.layouts["1"]["b:1"].entitlement=true;eq(schema.validate(record,1),false)
        record.data.expansion.layouts["1"]["b:1"].entitlement=nil
        record.data.expansion.layouts["1"]["b:1"].x=6.1;eq(schema.validate(record,1),false)
    end)
end
