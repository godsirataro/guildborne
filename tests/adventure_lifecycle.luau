--!strict
return function(test:any,eq:any)
    local make=require("../src/server/Systems/AdventureLifecycle")
    local catalog=require("../src/server/Config/AdventureEncounters")
    local function fixture():any
        local sequence=0
        return make(catalog,7,function()sequence+=1;return "death:"..sequence end,18)
    end
    test("regional death captures immutable members and one stable reward ticket",function()
        local s=fixture();local members={"player","a:Warrior"}
        eq(s.death("greenwood_scout",7,members,10),true);members[1]="foreign"
        local ticket=s.claim("greenwood_scout",10);eq(ticket.members,{"a:Warrior","player"})
        eq(pcall(function()ticket.members[1]="foreign"end),false)
        eq(s.claim("greenwood_scout",11),nil);eq(s.death("greenwood_scout",7,{},11),false)
        eq(s.respawn("greenwood_scout",100),false)
        eq(s.finish(ticket,"Retry",11),true);eq(s.claim("greenwood_scout",12),nil)
        local retry=s.claim("greenwood_scout",13);eq(retry.deathId,ticket.deathId);eq(retry.generation,ticket.generation)
        eq(s.finish(ticket,"Committed",14),false)
        eq(s.finish(retry,"Committed",14),true);eq(s.finish(retry,"Committed",15),false)
        eq(s.respawn("greenwood_scout",27.99),false);eq(s.respawn("greenwood_scout",28),true)
        eq(s.read("greenwood_scout").generation,2);eq(s.death("greenwood_scout",7,{"player"},30),true)
        assert(s.claim("greenwood_scout",30).deathId~=ticket.deathId)
        eq(s.finish(retry,"Committed",31),false)
    end)
    test("regional reward pending survives switching encounters and cannot respawn on uncertainty",function()
        local s=fixture();eq(s.death("forest_captain",7,{"player"},0),true)
        local ticket=s.claim("forest_captain",0)
        eq(s.death("quarry_guardian",7,{"player"},1),true)
        local second=s.claim("quarry_guardian",1);assert(second.deathId~=ticket.deathId)
        for i=1,8 do
            eq(s.finish(ticket,"Retry",i*60),true)
            eq(s.respawn("forest_captain",i*60+40),false)
            ticket=s.claim("forest_captain",i*60+31);assert(ticket)
            eq(ticket.deathId,"death:1")
        end
        eq(s.finish(second,"Committed",600),true);eq(s.respawn("quarry_guardian",600),true)
        eq(s.read("forest_captain").state,"Pending")
    end)
    test("regional lifecycle rejects invalid owner party time and unknown encounters atomically",function()
        local s=fixture()
        eq(s.death("fake",7,{},0),false);eq(s.death("greenwood_scout",8,{"player"},0),false)
        eq(s.death("greenwood_scout",7,{"player","player"},0),false)
        eq(s.death("greenwood_scout",7,{"1","2","3","4","5","6","7"},0),false)
        eq(s.death("greenwood_scout",7,{"player"},0/0),false)
        eq(s.read("greenwood_scout").state,"Alive")
        eq(s.death("greenwood_scout",7,{},0),true);eq(s.claim("greenwood_scout",0),nil)
        eq(s.respawn("greenwood_scout",18),true)
        eq(s.death("greenwood_scout",7,{"player"},20),true)
        local ticket=s.claim("greenwood_scout",20)
        eq(s.finish(ticket,"Unknown",21),false);eq(s.respawn("greenwood_scout",100),false)
        eq(s.finish(ticket,"Rejected",22),true);eq(s.respawn("greenwood_scout",38),true)
        s.close();s.close();eq(s.read("greenwood_scout"),nil);eq(s.finish(ticket,"Committed",100),false)
        eq(s.death("greenwood_scout",7,{"player"},100),false)
    end)
    test("regional lifecycle contains exactly the twelve configured encounter slots",function()
        local s=fixture();local total=0
        for region,definition in pairs(catalog.Regions) do for _,entry in ipairs(definition.Encounters) do
            total+=1;eq(s.read(entry.Asset).region,region);eq(s.read(entry.Asset).state,"Alive")
        end end
        eq(total,12)
    end)
end
