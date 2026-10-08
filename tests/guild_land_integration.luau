--!strict
return function(test: any,eq: any,harness: any,util: any,schema: any,land: any,content: any,progression: any)
    test("v6 to v7 migration adds only empty land state and leaves input unchanged",function()
        local current=schema.new(1,1000);local old=util.copy(current);old.schemaVersion=6;old.data.guildLand=nil
        local saved=util.copy(old);local migrated,code=schema.migrate(old)
        eq(code,"OK");eq(old,saved);eq(migrated,current);eq(schema.validate(migrated,1),true)
        eq(schema.migrate(migrated),migrated)
        old.data.guildLand={version=1,plots={}};local invalid,problem=schema.migrate(old)
        eq(invalid,nil);eq(problem,"MigrationFailed")
    end)
    test("land unlock uses committed quest state and normal request replay protection",function()
        local h=harness();h.setup();local before=util.copy(h.data())
        eq(h.send("UnlockGuildPlot",{plotId="grove"}),"QuestLocked");eq(h.data(),before)
        h.quest("trail_watch");local command=h.command("UnlockGuildPlot",{plotId="grove"})
        eq(h.service.Execute(1,command),"OK");local unlocked=util.copy(h.data())
        eq(h.service.Execute(1,command),"AlreadyCommitted");eq(h.data(),unlocked)
        eq(land.describe(h.data().guildLand,"grove").canPurchase,false)
        eq(h.send("ContributeGuildPlot",{plotId="grove",itemId="herb",amount=2}),"PurchaseRequired")
        eq(h.data(),unlocked);eq(h.send("OpenGuildPlot",{plotId="grove"}),"PurchaseRequired")
        eq(h.data(),unlocked);eq(schema.validate(h.service.Sessions[1].record,1),true)
    end)
    test("payment grants are not accepted as client protocol commands",function()
        local h=harness();h.setup();local before=util.copy(h.data())
        eq(h.send("RecordGuildEntitlement",{plotId="grove",productId=123}),"InvalidRequest")
        eq(h.send("ContributeGuildPlot",{plotId="grove",itemId="herb",amount=-1}),"QuestLocked")
        eq(h.data(),before)
    end)
    test("land material receipt replay and rejoin preserve exactly one inventory debit",function()
        local h=harness();h.setup();h.quest("trail_watch");h.send("UnlockGuildPlot",{plotId="grove"})
        -- Explicit trusted-payment fixture, never an exposed grant command.
        h.data().guildLand.plots.grove.entitlement={productId=123,reference="verified-fixture"}
        local command=h.command("ContributeGuildPlot",{plotId="grove",itemId="herb",amount=2})
        eq(h.service.Execute(1,command),"OK");eq(h.data().inventory.stacks.herb,nil)
        eq(h.service.Execute(1,command),"AlreadyCommitted");eq(h.data().guildLand.plots.grove.delivered.herb,2)
        eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"land-rejoin"),"OK")
        eq(h.data().inventory.stacks.herb,nil);eq(h.data().guildLand.plots.grove.delivered.herb,2)
        eq(h.data().guildLand.plots.grove.entitlement.reference,"verified-fixture")
    end)
    test("uncertain land material commits recover without premature or duplicate delivery",function()
        for _,mode in ipairs({"before","after"}) do
            local h=harness();h.setup();h.quest("trail_watch");h.send("UnlockGuildPlot",{plotId="grove"})
            h.data().guildLand.plots.grove.entitlement={productId=123,reference="verified-fixture"}
            -- Persist the fixture through an unrelated normal commit before fault injection.
            eq(h.send("SetLanguage",{language="en"}),"OK")
            h.mode=mode;local command=h.command("ContributeGuildPlot",{plotId="grove",itemId="herb",amount=2})
            eq(h.service.Execute(1,command),"SavePending");eq(h.data().inventory.stacks.herb,2)
            eq(h.data().guildLand.plots.grove.delivered.herb,nil)
            h.mode="ok";eq(h.service.Refresh(1),"OK")
            eq(h.data().inventory.stacks.herb,nil);eq(h.data().guildLand.plots.grove.delivered.herb,2)
            eq(h.service.Execute(1,command),"AlreadyCommitted")
        end
    end)
    test("land building relocation persists identity level inventory and replay across rejoin",function()
        local h=harness();h.setup()
        for _,id in ipairs({"timber","stone","herb"}) do h.data().inventory.stacks[id]=50 end
        eq(h.send("PlaceBuilding",{kind="quarters",x=6,z=-4,rotation=0}),"OK")
        local before=util.copy(h.data())
        eq(h.send("MoveBuilding",{buildingId="b:1",x=-11,z=-3,rotation=1}),"PlotLocked");eq(h.data(),before)
        -- Trusted paid/opened fixture, not a client entitlement command.
        h.data().guildLand.plots.grove={questUnlocked=true,entitlement={productId=123,reference="paid-building-fixture"},delivered={timber=24,herb=8},opened=true}
        h.data().expansion.buildings["b:1"].level=2
        eq(h.send("SetLanguage",{language="en"}),"OK")
        local inventory=util.copy(h.data().inventory);local command=h.command("MoveBuilding",{buildingId="b:1",x=-11,z=-3,rotation=1})
        eq(h.service.Execute(1,command),"OK");eq(h.data().inventory,inventory)
        eq(h.data().expansion.buildings["b:1"],{kind="quarters",level=2,x=-11,z=-3,rotation=1})
        eq(h.service.Execute(1,command),"AlreadyCommitted");eq(schema.validate(h.service.Sessions[1].record,1),true)
        eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"land-building-rejoin"),"OK")
        eq(h.data().expansion.buildings["b:1"].x,-11);eq(h.data().expansion.buildings["b:1"].level,2)
        eq(h.data().inventory,inventory);eq(h.send("MoveBuilding",{buildingId="b:1",x=6,z=-4,rotation=0}),"OK")
    end)
    test("uncertain land building movement reconciles without losing the existing building",function()
        for _,mode in ipairs({"before","after"}) do
            local h=harness();h.setup();h.data().inventory.stacks.timber=50;h.data().inventory.stacks.stone=50
            eq(h.send("PlaceBuilding",{kind="warehouse",x=6,z=-4,rotation=0}),"OK")
            h.data().guildLand.plots.grove={questUnlocked=true,entitlement={productId=123,reference="paid-move-fixture"},delivered={timber=24,herb=8},opened=true}
            eq(h.send("SetLanguage",{language="en"}),"OK");local inventory=util.copy(h.data().inventory)
            h.mode=mode;local command=h.command("MoveBuilding",{buildingId="b:1",x=-11,z=-3,rotation=0})
            eq(h.service.Execute(1,command),"SavePending");eq(h.data().expansion.buildings["b:1"].x,6)
            h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.data().expansion.buildings["b:1"].x,-11)
            eq(h.data().inventory,inventory);eq(h.data().expansion.nextBuilding,2)
            eq(h.service.Execute(1,command),"AlreadyCommitted")
        end
    end)
    test("land projection exposes requirements but never payment references",function()
        local h=harness();h.setup();h.quest("trail_watch");h.send("UnlockGuildPlot",{plotId="grove"})
        h.data().guildLand.plots.grove.entitlement={productId=123,reference="private-purchase-reference"}
        local project=require("../src/server/Systems/ViewProjection")(content,progression,util,nil,nil,{rules=land,catalog=require("../src/server/Config/GuildLand")})
        local view=project(h.service.Sessions[1],"test",h.now);local plot=view.data.guildLand.plots.grove
        eq(plot.purchased,true);eq(plot.status,"MaterialsRequired");eq(plot.entitlement,nil)
        eq(plot.reference,nil);eq(plot.productId,nil);eq(plot.materials.timber,24)
        plot.materials.timber=900;eq(require("../src/server/Config/GuildLand").grove.materials.timber,24)
    end)
    test("island access mode is owner-scoped validated and save-atomic",function()
        for _,mode in ipairs({"before","after"}) do
            local h=harness();h.setup();local before=util.copy(h.data())
            eq(h.send("SetGuildAccess",{mode="AnyoneCanBuild"}),"InvalidAccessMode");eq(h.data(),before)
            eq(h.send("SetGuildAccess",{mode="Public",ownerId="2"}),"InvalidRequest");eq(h.data(),before)
            h.mode=mode;local command=h.command("SetGuildAccess",{mode="Friends"})
            eq(h.service.Execute(1,command),"SavePending");eq(h.data().guildLand.accessMode,nil)
            h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.data().guildLand.accessMode,"Friends")
            eq(h.service.Execute(1,command),"AlreadyCommitted");eq(h.service.Close(1),"OK")
            h.service=h.make();eq(h.service.Load(1,"access-rejoin"),"OK");eq(h.data().guildLand.accessMode,"Friends")
            eq(h.send("SetGuildAccess",{mode="Private"}),"OK");eq(schema.validate(h.service.Sessions[1].record,1),true)
            local bad=util.copy(h.service.Sessions[1].record);bad.data.guildLand.accessMode="bad";eq(schema.validate(bad,1),false)
        end
    end)
end
