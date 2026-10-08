--!strict
local Journal=require("../src/shared/Data/JournalViewState")
return function(test: any,eq: any)
    local catalog={Journal={intro={Count=1},herbs={Count=5,Item="herb",Requires="intro"},kills={Count=3}}}
    test("journal item progress reflects stock but claimed quests stay complete",function()
        local d={settlement={journal={herbs={state="Active",progress=5}}},inventory={stacks={herb=2}}}
        eq(Journal.describe(d,catalog,"herbs").progress,2);eq(Journal.describe(d,catalog,"herbs").ready,false)
        d.inventory.stacks.herb=9;eq(Journal.describe(d,catalog,"herbs").progress,5);eq(Journal.describe(d,catalog,"herbs").ready,true)
        d.settlement.journal.herbs.state="Claimed";d.inventory.stacks.herb=0
        local state=Journal.describe(d,catalog,"herbs");eq(state.progress,5);eq(state.ready,false);eq(state.state,"Claimed")
        eq(d.inventory.stacks.herb,0);eq(d.settlement.journal.herbs.progress,5)
    end)
    test("journal available filter excludes locked and accepted tasks",function()
        local d: any={settlement={journal={}},inventory={stacks={}}}
        eq(Journal.describe(d,catalog,"missing"),nil)
        eq(Journal.matches(Journal.describe(d,catalog,"herbs"),"Available"),false)
        eq(Journal.matches(Journal.describe(d,catalog,"intro"),"Available"),true)
        d.settlement.journal.intro={state="Active",progress=1}
        eq(Journal.describe(d,catalog,"herbs").locked,true)
        d.settlement.journal.intro.state="Claimed"
        eq(Journal.matches(Journal.describe(d,catalog,"herbs"),"Available"),true)
    end)
    test("journal ready filter is an active subset and event progress is bounded",function()
        local d={settlement={journal={kills={state="Active",progress=8}}},inventory={stacks={}}}
        local state=Journal.describe(d,catalog,"kills");eq(state.progress,3)
        for _,filter in ipairs({"All","Active","Ready"}) do eq(Journal.matches(state,filter),true) end
        eq(Journal.matches(state,"Claimed"),false)
        d.settlement.journal.kills.state="Claimed";state=Journal.describe(d,catalog,"kills")
        eq(Journal.matches(state,"Ready"),false);eq(Journal.matches(state,"Claimed"),true)
    end)
end
