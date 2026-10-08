--!strict
return function(test:any,eq:any,harness:any,util:any,content:any)
    local describe=require("../src/shared/Data/JournalViewState")
    local rewards=require("../src/server/Config/AdventureRewards")
    local adapter=require("../src/server/Services/AdventureRewardAdapter")
    local supplyIds={"borga_greenwood_timber","mogra_greenwood_herbs","rukk_ironveil_stone","rukk_ironveil_ore","mogra_ashen_herbs","borga_ashen_stone"}
    test("regional supply quests stay disabled outside the owned offline build",function()
        local h=harness();h.setup();local npc=require("../src/shared/Data/QuestNpcState")
        for _,id in ipairs(supplyIds) do
            local def=content.Journal[id];h.data().settlement.journal[def.Requires]={state="Claimed",progress=content.Journal[def.Requires].Count}
            eq(h.send("AcceptTask",{questId=id}),"RegionalEncountersUnavailable")
            local catalog=util.copy(content);catalog.JournalOrder={id}
            eq(npc(h.data(),catalog,def.NPC),nil)
        end
    end)
    test("six regional supply quests count exact accepted node commits and retain gathered materials",function()
        local original=content.RegionalCombatAvailable;content.RegionalCombatAvailable=true
        local ok,problem=pcall(function()
            local nodes=require("../src/shared/Data/Expansion").Nodes
            for _,id in ipairs(supplyIds) do for _,mode in ipairs({"before","after"}) do
                local h=harness();h.setup();local def=content.Journal[id];local nodeId=def.Event:sub(8);local node=nodes[nodeId]
                eq(h.send("AcceptTask",{questId=id}),"QuestLocked")
                h.data().settlement.journal[def.Requires]={state="Claimed",progress=content.Journal[def.Requires].Count}
                eq(h.send("GatherResource",{nodeId=nodeId}),"OK")
                eq(h.send("AcceptTask",{questId=id}),"OK");eq(h.data().settlement.journal[id].progress,0)
                eq(h.send("GatherResource",{nodeId="wood"}),"OK");eq(h.data().settlement.journal[id].progress,0)
                eq(h.send("GatherResource",{nodeId=nodeId}),"ResourceCooling");eq(h.data().settlement.journal[id].progress,0)
                eq(h.send("ClaimTask",{questId=id}),"TaskIncomplete")
                for n=1,2 do
                    h.now+=20;local command=h.command("GatherResource",{nodeId=nodeId});h.mode=mode
                    eq(h.service.Execute(1,command),"SavePending");eq(h.data().settlement.journal[id].progress,n-1)
                    h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
                    eq(h.data().settlement.journal[id].progress,n)
                end
                local gold=h.data().currencies.gold;local materials=h.data().inventory.stacks[node.Item]
                local xp=h.data().adventurers["a:Warrior"].xp;local command=h.command("ClaimTask",{questId=id});h.mode=mode
                eq(h.service.Execute(1,command),"SavePending");eq(h.data().currencies.gold,gold)
                h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.Execute(1,command),"AlreadyCommitted")
                eq(h.data().currencies.gold,gold+8);eq(h.data().adventurers["a:Warrior"].xp,xp+6)
                eq(h.data().inventory.stacks[node.Item],materials)
                eq(h.service.Close(1),"OK");eq(h.service.Load(1,"supply-rejoin"),"OK")
                eq(h.send("ClaimTask",{questId=id}),"QuestNotActive");eq(h.data().currencies.gold,gold+8)
            end end
        end)
        content.RegionalCombatAvailable=original;assert(ok,tostring(problem))
    end)
    test("regional contracts fail closed outside enabled combat and stay out of NPC offers",function()
        local h=harness();h.setup()
        eq(content.RegionalCombatAvailable,false)
        h.data().settlement.journal.company_reinforcement={state="Claimed",progress=1}
        eq(h.send("AcceptTask",{questId="greenwood_watch"}),"RegionalEncountersUnavailable")
        eq(h.data().settlement.journal.greenwood_watch,nil)
        eq(describe.describe(h.data(),content,"greenwood_watch").unavailable,true)
        local catalog=util.copy(content);catalog.JournalOrder={"greenwood_watch"}
        eq(require("../src/shared/Data/QuestNpcState")(h.data(),catalog,"Ghar"),nil)
        h.data().progression.tutorialStep="done"
        eq(require("../src/shared/Data/QuestTracker")(h.data(),catalog,nil),nil)
    end)
    test("regional contract chain counts accepted matching commits and survives uncertain rewards without duplicates",function()
        content.RegionalCombatAvailable=true
        local ok,problem=pcall(function()
            local h=harness();h.setup();local grant=adapter(h.service,1,rewards,util)
            eq(h.send("AcceptTask",{questId="greenwood_watch"}),"QuestLocked")
            h.data().settlement.journal.company_reinforcement={state="Claimed",progress=1}
            local generation=0
            local function kill(id:string):any generation+=1;return {owner=1,encounterId=id,deathId="contract:"..generation,generation=generation,members={"a:Warrior"}} end
            eq(grant(kill("greenwood_scout")),"Committed")
            local pairsToCheck={{"greenwood_watch","greenwood_scout"},{"greenwood_captain","forest_captain"},{"ironveil_watch","quarry_raider"},{"ironveil_guardian","quarry_guardian"},{"ashen_watch","arcane_sentinel"},{"ashen_warden","arcane_warden"}}
            for _,pair in ipairs(pairsToCheck) do
                local id,enemy=pair[1],pair[2];local def=content.Journal[id]
                eq(h.send("AcceptTask",{questId=id}),"OK");eq(h.data().settlement.journal[id].progress,0)
                eq(h.send("ClaimTask",{questId=id}),"TaskIncomplete")
                eq(grant(kill("greenwood_archer")),"Committed");eq(h.data().settlement.journal[id].progress,0)
                for i=1,def.Count do
                    local ticket=kill(enemy);h.mode="after"
                    eq(grant(ticket),"Retry");eq(h.data().settlement.journal[id].progress,i-1)
                    h.mode="ok";eq(grant(ticket),"Committed");eq(grant(ticket),"Committed")
                    eq(h.data().settlement.journal[id].progress,i)
                end
                local gold=h.data().currencies.gold;local xp=h.data().adventurers["a:Warrior"].xp
                local command=h.command("ClaimTask",{questId=id});h.mode="after"
                eq(h.service.Execute(1,command),"SavePending");eq(h.data().currencies.gold,gold)
                h.mode="ok";eq(h.service.Refresh(1),"OK")
                eq(h.service.Execute(1,command),"AlreadyCommitted")
                eq(h.data().currencies.gold,gold+def.Gold);eq(h.data().adventurers["a:Warrior"].xp,xp+def.XP)
                eq(h.data().settlement.journal[id].state,"Claimed")
            end
            eq(h.service.Close(1),"OK");eq(h.service.Load(1,"contract-rejoin"),"OK")
            eq(h.send("ClaimTask",{questId="ashen_warden"}),"QuestNotActive")
        end)
        content.RegionalCombatAvailable=false
        assert(ok,tostring(problem))
    end)
end
