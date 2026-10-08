--!strict
local Catalog=require("../src/shared/Config/BuildingThemes")
local Make=require("../src/shared/Data/BuildingThemeRights")
return function(test:any,eq:any,harness:any,util:any,schema:any,content:any,progression:any)
    local function setup():any
        local h=harness();h.setup()
        for _,id in ipairs({"timber","stone","herb"}) do h.data().inventory.stacks[id]=50 end
        eq(h.send("PlaceBuilding",{kind="quarters",x=6.25,z=-3.75,rotation=1}),"OK")
        h.data().expansion.buildings["b:1"].level=2
        return h
    end
    local function quest(h:any)
        eq(h.send("AcceptTask",{questId="borga_hearth"}),"OK")
        eq(h.send("ClaimTask",{questId="borga_hearth"}),"OK")
    end
    test("theme quest rights require claimed quest and never accept client payment proof",function()
        local h=setup();local before=util.copy(h.data())
        eq(h.send("UnlockBuildingTheme",{themeId="orc"}),"ThemeQuestRequired")
        eq(h.send("UnlockBuildingTheme",{themeId="mage"}),"ThemePurchaseUnavailable")
        eq(h.send("ApplyBuildingTheme",{themeId="mage",buildingId="b:1"}),"ThemeNotOwned")
        eq(h.send("GrantBuildingTheme",{themeId="mage"}),"InvalidRequest")
        eq(h.send("UnlockBuildingTheme",{themeId="mage",receipt="fake"}),"InvalidRequest");eq(h.data(),before)
        eq(h.send("AcceptTask",{questId="borga_hearth"}),"OK")
        eq(h.send("UnlockBuildingTheme",{themeId="orc"}),"ThemeQuestRequired")
    end)
    test("theme application preserves upgrades identity storage layouts and materials on rejoin",function()
        local h=setup();quest(h);eq(h.send("UnlockBuildingTheme",{themeId="orc"}),"OK")
        eq(h.send("SaveBuildLayout",{slot=1}),"OK")
        local before=util.copy(h.data().expansion.buildings["b:1"]);local inventory=util.copy(h.data().inventory)
        local command=h.command("ApplyBuildingTheme",{themeId="orc",buildingId="b:1"})
        eq(h.service.Execute(1,command),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
        before.theme="orc";eq(h.data().expansion.buildings["b:1"],before);eq(h.data().inventory,inventory)
        eq(h.send("StoreBuilding",{buildingId="b:1"}),"OK")
        eq(h.send("ApplyBuildingTheme",{themeId="human",buildingId="b:1"}),"OK")
        eq(h.data().expansion.storage["b:1"].theme,"human")
        eq(h.send("ApplyBuildingTheme",{themeId="orc",buildingId="b:1"}),"OK")
        eq(h.send("ApplyBuildLayout",{slot=1}),"OK");eq(h.data().expansion.buildings["b:1"],before)
        eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"theme-rejoin"),"OK")
        eq(h.data().expansion.buildings["b:1"],before);eq(h.data().inventory,inventory)
    end)
    test("theme unlock and apply wait for durable commit and reconcile retries",function()
        for _,action in ipairs({"UnlockBuildingTheme","ApplyBuildingTheme"}) do for _,mode in ipairs({"before","after"}) do
            local h=setup();quest(h)
            if action=="ApplyBuildingTheme" then eq(h.send("UnlockBuildingTheme",{themeId="orc"}),"OK") end
            local args:any={themeId="orc"};if action=="ApplyBuildingTheme" then args.buildingId="b:1" end
            local before=util.copy(h.data());h.mode=mode;local command=h.command(action,args)
            eq(h.service.Execute(1,command),"SavePending");eq(h.data(),before)
            h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
            eq(h.data().inventory,before.inventory);eq(schema.validate(h.service.Sessions[1].record,1),true)
        end end
    end)
    test("trusted theme adapter rejects unconfigured products and duplicate payment references",function()
        local e={buildings={}};local rules=Make(Catalog)
        eq(rules.recordVerified(e,"mage",123,"receipt"),"InvalidEntitlement")
        local configured=util.copy(Catalog);configured.Themes.mage.ProductId=123;configured.Themes.elf.ProductId=456
        rules=Make(configured)
        eq(rules.recordVerified(e,"mage",123,"receipt"),"OK")
        eq(rules.recordVerified(e,"mage",123,"receipt"),"AlreadyCommitted")
        eq(rules.recordVerified(e,"elf",456,"receipt"),"EntitlementConflict")
        eq(rules.validate(e),true)
        configured.Themes.mage.ProductId=789;eq(Make(configured).validate(e),true) -- retain previously verified ownership
    end)
    test("theme schema rejects unowned appearance and forged-shaped ownership records",function()
        local h=setup();local record=util.copy(h.service.Sessions[1].record)
        record.data.expansion.buildings["b:1"].theme="mage";eq(schema.validate(record,1),false)
        record.data.expansion.themeRights={mage=true};eq(schema.validate(record,1),false)
        record.data.expansion.themeRights={mage={source="Quest",quest="borga_hearth"}};eq(schema.validate(record,1),false)
        record.data.expansion.themeRights={mage={source="Purchase",productId=123,reference="trusted-fixture"}};eq(schema.validate(record,1),true)
    end)
    test("theme projection exposes boolean ownership without purchase references",function()
        local h=setup();h.data().expansion.themeRights={mage={source="Purchase",productId=123,reference="private-theme-receipt"}}
        local project=require("../src/server/Systems/ViewProjection")(content,progression,util)
        local view=project(h.service.Sessions[1],"test",h.now)
        eq(view.data.expansion.themeRights,{mage=true})
        view.data.expansion.themeRights.mage=false;eq(h.data().expansion.themeRights.mage.reference,"private-theme-receipt")
    end)
    test("Hall theme uses owned rights and preserves level placement layouts and materials",function()
        local h=setup();local original=util.copy(h.data())
        eq(h.send("ApplyBuildingTheme",{themeId="mage",buildingId="guildHall"}),"ThemeNotOwned");eq(h.data(),original)
        quest(h);eq(h.send("UnlockBuildingTheme",{themeId="orc"}),"OK")
        eq(h.send("MoveGuildHall",{x=6,z=1,rotation=0}),"OK")
        eq(h.send("SaveBuildLayout",{slot=1}),"OK")
        local inventory=util.copy(h.data().inventory);local level=h.data().personalGuild.buildings.guildHall
        eq(h.send("ApplyBuildingTheme",{themeId="orc",buildingId="guildHall"}),"OK")
        eq(h.send("MoveGuildHall",{x=-2,z=-4.5,rotation=0}),"OK")
        eq(h.send("ApplyBuildLayout",{slot=1}),"OK")
        eq(h.data().expansion.hallTheme,"orc");eq(h.data().expansion.hallPosition,{x=6,z=1,rotation=0})
        eq(h.data().inventory,inventory);eq(h.data().personalGuild.buildings.guildHall,level)
        eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"hall-theme"),"OK")
        eq(h.data().expansion.hallTheme,"orc")
        eq(h.send("ApplyBuildingTheme",{themeId="human",buildingId="guildHall"}),"OK")
    end)
    test("uncertain Hall theme changes reconcile without early presentation state",function()
        for _,mode in ipairs({"before","after"}) do
            local h=setup();quest(h);eq(h.send("UnlockBuildingTheme",{themeId="orc"}),"OK")
            local before=util.copy(h.data());h.mode=mode
            local command=h.command("ApplyBuildingTheme",{themeId="orc",buildingId="guildHall"})
            eq(h.service.Execute(1,command),"SavePending");eq(h.data(),before)
            h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
            eq(h.data().expansion.hallTheme,"orc");eq(h.data().inventory,before.inventory)
        end
    end)
    test("Hall appearance schema rejects unknown unowned and non-string selections",function()
        local h=setup()
        local invalidThemes:{any}={"mage","fake",true,5}
        for _,theme in ipairs(invalidThemes) do
            local record=util.copy(h.service.Sessions[1].record);record.data.expansion.hallTheme=theme
            eq(schema.validate(record,1),false)
        end
        local record=util.copy(h.service.Sessions[1].record);record.data.expansion.hallTheme="human";eq(schema.validate(record,1),true)
    end)
end
