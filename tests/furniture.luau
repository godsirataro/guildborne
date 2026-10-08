--!strict
return function(test:any,eq:any,harness:any,util:any,schema:any)
    local function setup():any
        local h=harness();h.setup()
        for _,id in ipairs({"timber","stone","herb","iron_ore"}) do h.data().inventory.stacks[id]=80 end
        return h
    end
    test("furniture crafting charges once and preserves ownership through storage and rejoin",function()
        local h=setup();local command=h.command("CraftFurniture",{kind="hearth_chair"})
        eq(h.service.Execute(1,command),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
        eq(h.data().inventory.stacks.timber,78)
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=6,z=-4,rotation=0}),"OK")
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=6.25,z=-3.75,rotation=1}),"OK")
        eq(h.send("StoreFurniture",{furnitureId="f:1"}),"OK")
        eq(h.data().expansion.furniture["f:1"].stored,true)
        eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"furniture-rejoin"),"OK")
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=8,z=2,rotation=3}),"OK")
        eq(h.data().expansion.furniture["f:1"],{kind="hearth_chair",stored=false,x=8,z=2,rotation=3})
        eq(h.data().inventory.stacks.timber,78);eq(schema.validate(h.service.Sessions[1].record,1),true)
    end)
    test("furniture cannot bypass land ownership paths building collisions or collection authority",function()
        local h=setup();eq(h.send("CraftFurniture",{kind="hearth_chair"}),"OK")
        local before=util.copy(h.data())
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=-11,z=-3,rotation=0}),"PlotLocked")
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=6,z=0,rotation=0}),"InvalidPlacement")
        eq(h.send("PlaceFurniture",{furnitureId="foreign",x=6,z=-4,rotation=0}),"InvalidFurniture")
        eq(h.send("PlaceBuilding",{kind="hearth_chair",x=6,z=-4,rotation=0}),"InvalidBuilding")
        eq(h.data(),before)
        eq(h.send("MoveGuildHall",{x=6,z=-4,rotation=1}),"OK")
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=6,z=-4,rotation=0}),"InvalidPlacement")
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=9,z=-2,rotation=0}),"AccessBlocked")
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=9,z=2,rotation=0}),"OK")
        eq(h.send("MoveGuildHall",{x=8,z=2,rotation=0}),"InvalidPlacement")
    end)
    test("furniture uncertainty resolves craft place and store without material or identity duplication",function()
        for _,action in ipairs({"CraftFurniture","PlaceFurniture","StoreFurniture","DismantleFurniture"}) do for _,mode in ipairs({"before","after"}) do
            local h=setup()
            if action~="CraftFurniture" then eq(h.send("CraftFurniture",{kind="hearth_chair"}),"OK") end
            if action=="StoreFurniture" then eq(h.send("PlaceFurniture",{furnitureId="f:1",x=6,z=-4,rotation=0}),"OK") end
            local args:any=if action=="CraftFurniture" then {kind="hearth_chair"} elseif action=="StoreFurniture" or action=="DismantleFurniture" then {furnitureId="f:1"} else {furnitureId="f:1",x=6.25,z=-3.75,rotation=1}
            local before=util.copy(h.data());h.mode=mode;local command=h.command(action,args)
            eq(h.service.Execute(1,command),"SavePending");eq(h.data(),before)
            h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
            eq(util.count(h.data().expansion.furniture),if action=="DismantleFurniture" then 0 else 1);eq(h.data().expansion.nextFurniture,2)
            eq(h.data().inventory.stacks.timber,if action=="DismantleFurniture" then 79 else 78)
        end end
    end)
    test("furniture limits costs and malformed stored records fail closed",function()
        local h=setup();eq(h.send("CraftFurniture",{kind="free_fake"}),"InvalidFurniture")
        h.data().inventory.stacks.timber=0;eq(h.send("CraftFurniture",{kind="hearth_chair"}),"MissingMaterials")
        h.data().inventory.stacks.timber=80
        for _=1,32 do eq(h.send("CraftFurniture",{kind="hearth_chair"}),"OK") end
        local before=util.copy(h.data());eq(h.send("CraftFurniture",{kind="hearth_chair"}),"FurnitureLimit");eq(h.data(),before)
        local record=util.copy(h.service.Sessions[1].record);eq(schema.validate(record,1),true)
        record.data.expansion.furniture["f:1"].theme="paid_fake";eq(schema.validate(record,1),false)
        record=util.copy(h.service.Sessions[1].record);record.data.expansion.furniture["f:1"].rotation=4;eq(schema.validate(record,1),false)
        record=util.copy(h.service.Sessions[1].record);record.data.expansion.nextFurniture=1;eq(schema.validate(record,1),false)
        for _,id in ipairs({"f:0","f:01"}) do
            record=util.copy(h.service.Sessions[1].record)
            record.data.expansion.furniture[id]=record.data.expansion.furniture["f:1"];record.data.expansion.furniture["f:1"]=nil
            eq(schema.validate(record,1),false)
        end
    end)
    test("applying building layouts respects furniture that remains in place",function()
        local h=setup();eq(h.send("PlaceBuilding",{kind="warehouse",x=6,z=-4,rotation=0}),"OK")
        eq(h.send("SaveBuildLayout",{slot=1}),"OK");eq(h.send("StoreBuilding",{buildingId="b:1"}),"OK")
        h.data().expansion.layoutFurniture=nil -- historical building-only layout
        eq(h.send("CraftFurniture",{kind="hearth_chair"}),"OK");eq(h.send("PlaceFurniture",{furnitureId="f:1",x=6,z=-4,rotation=0}),"OK")
        local before=util.copy(h.data());eq(h.send("ApplyBuildLayout",{slot=1}),"InvalidPlacement");eq(h.data(),before)
        eq(h.send("StoreFurniture",{furnitureId="f:1"}),"OK");eq(h.send("ApplyBuildLayout",{slot=1}),"OK")
    end)
    test("furniture layouts restore owned identities store extras and reject recycled references",function()
        local h=setup();eq(h.send("CraftFurniture",{kind="hearth_chair"}),"OK")
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=6,z=-4,rotation=0}),"OK")
        eq(h.send("SaveBuildLayout",{slot=1}),"OK")
        eq(h.send("StoreFurniture",{furnitureId="f:1"}),"OK")
        eq(h.send("CraftFurniture",{kind="hearth_chair"}),"OK")
        eq(h.send("PlaceFurniture",{furnitureId="f:2",x=6,z=-4,rotation=0}),"OK")
        local inventory=util.copy(h.data().inventory)
        eq(h.send("ApplyBuildLayout",{slot=1}),"OK")
        eq(h.data().expansion.furniture["f:1"].stored,false);eq(h.data().expansion.furniture["f:2"].stored,true)
        eq(h.data().inventory,inventory)
        eq(h.send("DismantleFurniture",{furnitureId="f:1"}),"OK")
        local before=util.copy(h.data());eq(h.send("ApplyBuildLayout",{slot=1}),"LayoutFurnitureMissing");eq(h.data(),before)
        eq(h.send("DeleteBuildLayout",{slot=1}),"OK");eq(h.data().expansion.layoutFurniture["1"],nil)
    end)
    test("furniture layout save uncertainty keeps committed layout and ownership together",function()
        local h=setup();eq(h.send("CraftFurniture",{kind="hearth_chair"}),"OK")
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=6,z=-4,rotation=0}),"OK")
        eq(h.send("SaveBuildLayout",{slot=1}),"OK")
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=8,z=2,rotation=1}),"OK")
        local before=util.copy(h.data());h.mode="after";local command=h.command("ApplyBuildLayout",{slot=1})
        eq(h.service.Execute(1,command),"SavePending");eq(h.data(),before)
        h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
        eq(h.data().expansion.furniture["f:1"].x,6);eq(h.data().inventory,before.inventory)
        eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"layout-furniture-rejoin"),"OK")
        eq(h.data().expansion.layoutFurniture["1"]["f:1"].x,6)
    end)
    test("full furniture collection validates every footprint and shared routes without redundant searches",function()
        local h=setup();local record=util.copy(h.service.Sessions[1].record)
        local e=record.data.expansion;e.furniture={};e.nextFurniture=33
        for i=1,32 do e.furniture["f:"..i]={kind="hearth_chair",stored=false,x=6+(i-1)%8*.5,z=2+math.floor((i-1)/8)*.5,rotation=0} end
        eq(schema.validate(record,1),true)
        for id in pairs(e.furniture) do
            local invalid=util.copy(record);invalid.data.expansion.furniture[id].x=4
            eq(schema.validate(invalid,1),false)
        end
        local invalid=util.copy(record);invalid.data.expansion.furniture["f:2"]=util.copy(e.furniture["f:3"])
        eq(schema.validate(invalid,1),false)
        local rules=require("../src/shared/Data/Expansion")
        local calls=0;eq(rules.furniturePlacement(record.data,function()calls+=1;return true,"OK"end),true);eq(calls,1)
    end)
    test("furniture themes preserve owned identity through storage layouts and rejoin",function()
        local h=setup();eq(h.send("CraftFurniture",{kind="hearth_chair"}),"OK")
        local before=util.copy(h.data())
        eq(h.send("ApplyBuildingTheme",{themeId="mage",buildingId="f:1"}),"ThemeNotOwned");eq(h.data(),before)
        eq(h.send("ApplyBuildingTheme",{themeId="human",buildingId="f:999"}),"InvalidBuilding")
        eq(h.send("AcceptTask",{questId="borga_hearth"}),"OK");eq(h.send("ClaimTask",{questId="borga_hearth"}),"OK")
        eq(h.send("UnlockBuildingTheme",{themeId="orc"}),"OK")
        local inventory=util.copy(h.data().inventory)
        eq(h.send("ApplyBuildingTheme",{themeId="orc",buildingId="f:1"}),"OK")
        eq(h.send("PlaceFurniture",{furnitureId="f:1",x=6,z=-4,rotation=0}),"OK")
        eq(h.send("SaveBuildLayout",{slot=1}),"OK");eq(h.send("StoreFurniture",{furnitureId="f:1"}),"OK")
        eq(h.send("ApplyBuildLayout",{slot=1}),"OK")
        eq(h.data().expansion.furniture["f:1"].theme,"orc");eq(h.data().inventory,inventory)
        eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"furniture-theme"),"OK")
        eq(h.data().expansion.furniture["f:1"].theme,"orc")
        eq(h.send("ApplyBuildingTheme",{themeId="human",buildingId="f:1"}),"OK")
    end)
    test("furniture theme uncertainty and invalid saved appearance fail closed",function()
        for _,mode in ipairs({"before","after"}) do
            local h=setup();eq(h.send("CraftFurniture",{kind="hearth_chair"}),"OK")
            local invalid:{any}={"mage","unknown",true,3}
            for _,id in ipairs(invalid) do
                local record=util.copy(h.service.Sessions[1].record);record.data.expansion.furniture["f:1"].theme=id
                eq(schema.validate(record,1),false)
            end
            local before=util.copy(h.data());h.mode=mode
            local command=h.command("ApplyBuildingTheme",{themeId="human",buildingId="f:1"})
            eq(h.service.Execute(1,command),"SavePending");eq(h.data(),before)
            h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
            eq(h.data().expansion.furniture["f:1"].theme,"human");eq(h.data().inventory,before.inventory)
        end
    end)

end
