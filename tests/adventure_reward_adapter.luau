--!strict
return function(test:any,eq:any,harness:any,util:any)
    local factory=require("../src/server/Services/AdventureRewardAdapter")
    local rewards=require("../src/server/Config/AdventureRewards")
    local function ticket():any return {owner=1,encounterId="forest_captain",deathId="regional-death",generation=1,members={"a:Warrior"}}end
    test("regional reward adapter saves real domain candidate once across repeated callbacks",function()
        local h=harness();h.setup();local grant=factory(h.service,1,rewards,util);local t=ticket()
        eq(grant(t),"Committed");eq(grant(t),"Committed");eq(h.data().currencies.gold,12);eq(h.data().inventory.stacks.timber,2)
        local changed=util.copy(t);changed.members={"foreign"};eq(grant(changed),"Rejected")
        changed=util.copy(t);changed.deathId="new";eq(grant(changed),"Rejected")
        changed.generation=2;eq(grant(changed),"Committed");eq(h.data().currencies.gold,24)
        eq(grant(t),"Rejected");eq(h.data().currencies.gold,24)
    end)
    test("regional reward adapter preserves exact command through before and after write uncertainty",function()
        for _,mode in ipairs({"before","after"}) do
            local h=harness();h.setup();local grant=factory(h.service,1,rewards,util);local t=ticket();h.mode=mode
            eq(grant(t),"Retry");eq(h.data().currencies.gold,0)
            local pending=util.copy(h.service.Sessions[1].pending.command)
            h.mode="ok";eq(grant(t),"Committed");eq(h.data().currencies.gold,12)
            local found=false
            for _,operation in ipairs(h.service.Sessions[1].record.operations.recentResults) do if operation.command.requestId==pending.requestId then eq(operation.command,pending);found=true end end
            eq(found,true);eq(grant(t),"Committed");eq(h.data().inventory.stacks.timber,2)
        end
    end)
    test("regional reward adapter waits for busy profile and rejects cross-session replay",function()
        local h=harness();h.setup();local grant=factory(h.service,1,rewards,util);local t=ticket()
        h.service.Sessions[1].busy=true;eq(grant(t),"Retry");h.service.Sessions[1].busy=false
        eq(h.send("SetLanguage",{language="th"}),"OK");eq(grant(t),"Committed")
        t=ticket();t.encounterId="quarry_guardian";t.deathId="pending-other"
        h.service.Sessions[1].busy=true;eq(grant(t),"Retry");h.service.Sessions[1].busy=false
        eq(h.service.Close(1),"OK");eq(h.service.Load(1,"new-session"),"OK")
        eq(grant(t),"Rejected");eq(h.data().currencies.gold,12)
    end)
    test("regional reward adapter keeps unknown exceptions pending and never refreshes their revision",function()
        local h=harness();h.setup();local original=h.service.CommitCombat;local commands={};local calls=0
        h.service.CommitCombat=function(userId:any,command:any,members:any,id:any)
            calls+=1;table.insert(commands,util.copy(command))
            if calls==1 then local code=original(userId,command,members,id);eq(code,"OK");error("transport failed after commit") end
            return original(userId,command,members,id)
        end
        local grant=factory(h.service,1,rewards,util);local t=ticket()
        eq(grant(t),"Retry");eq(h.data().currencies.gold,12)
        eq(h.send("SetLanguage",{language="th"}),"OK")
        eq(grant(t),"Committed");eq(commands[1],commands[2]);eq(h.data().currencies.gold,12)
    end)
end
