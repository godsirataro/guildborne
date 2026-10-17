--!strict
local make=require("../src/shared/Data/NpcLifeSchedule")
local config=require("../src/shared/Config/NpcLifeDefinitions")
local entries=require("../src/shared/Config/FriendlyNpcs")
local catalog=require("../src/server/Config/Content")
return function(test:any,eq:any)
    local function copy(value:any):any
        if type(value)~="table" then return value end
        local result={};for k,v in pairs(value) do result[k]=copy(v) end;return result
    end
    local life=assert(make(config,entries,catalog))
    test("existing identities retain exact anchors aliases and journal hooks",function()
        eq(#config.Ids,16)
        for _,id in ipairs(config.Ids) do
            local e=entries[id];eq(life.resolve(e.name),id)
            local s=assert(life.sample(id,43200,0));eq(s.anchor.x,e.x);eq(s.anchor.z,e.z)
            local expected={};for q,d in pairs(catalog.Journal) do if d.NPC==e.name then table.insert(expected,q) end end
            table.sort(expected);eq(#s.questIds,#expected)
            for i,q in ipairs(expected) do eq(s.questIds[i],q) end
        end
        local b=assert(life.sample("Smith Borin",43200,0));eq(table.find(b.questIds,"borin_castings")~=nil,true);eq(b.poseOwner,"Borin")
        eq(#assert(life.sample("host_deepforge",43200,0)).questIds,0)
        eq(life.resolve("unknown"),nil);eq(life.sample("unknown",0,0),nil)
    end)
    test("invalid or ambiguous registry fails closed",function()
        local e=copy(entries);e.borga.name=e.mogra.name;eq(make(config,e,catalog),nil)
        e=copy(entries);e.borga.name="mogra";eq(make(config,e,catalog),nil)
        e=copy(entries);e.borga.x=0/0;eq(make(config,e,catalog),nil)
        e=copy(entries);e.mogra=nil;eq(make(config,e,catalog),nil)
        local c=copy(config);c.Ids[1]="unknown";eq(make(c,entries,catalog),nil)
        c=copy(config);c.Phases[2].start=0;eq(make(c,entries,catalog),nil)
        c=copy(config);c.NearExit=math.huge;eq(make(c,entries,catalog),nil)
    end)
    test("daily boundaries wrap while every actor stays accessible at its anchor",function()
        for _,row in ipairs({{0,"Rest"},{21599,"Rest"},{21600,"Work"},{64799,"Work"},{64800,"Social"},{79199,"Social"},{79200,"Rest"},{86400,"Rest"},{108000,"Work"}}) do
            local s=assert(life.sample("borga",row[1],200));eq(s.activity,row[2]);eq(s.accessible,true);eq(s.anchor.x,entries.borga.x);eq(s.routeEnabled,false)
        end
    end)
    test("definition arrays reject holes extra keys duplicate IDs and unsupported versions",function()
        for _,field in ipairs({"Ids","Phases"}) do
            local count=if field=="Ids" then 16 else 4
            for index=1,count do
                local c=copy(config);c[field][index]=nil;eq(make(c,entries,catalog),nil)
            end
            for _,key in ipairs({0,count+1,1.5,"extra"}) do
                local c=copy(config);c[field][key]=c[field][1];eq(make(c,entries,catalog),nil)
            end
        end
        local c=copy(config);c.Ids[2]=c.Ids[1];eq(make(c,entries,catalog),nil)
        c=copy(config);c.Version=nil;eq(make(c,entries,catalog),nil)
        for _,version in ipairs({0,2,"1",math.huge}) do
            c=copy(config);c.Version=version;eq(make(c,entries,catalog),nil)
        end
    end)
    test("interruption overrides phase and recovery resumes current schedule",function()
        eq(assert(life.sample("rukk",64799,2,nil,64801)).activity,"Interact")
        eq(assert(life.sample("rukk",64801,2,nil,64801)).activity,"Recover")
        eq(assert(life.sample("rukk",64802,2,nil,64801)).activity,"Social")
        eq(assert(life.sample("rukk",64800,2)).activity,"Social")
        eq(assert(life.sample("rukk",config.RecoverySeconds-.001,2,nil,0)).activity,"Recover")
        eq(assert(life.sample("rukk",config.RecoverySeconds,2,nil,0)).activity,"Rest")
    end)
    test("relevance hysteresis bounds detail without hiding far quest actors",function()
        eq(assert(life.sample("smith_borin",0,60,"Near")).tier,"Near")
        eq(assert(life.sample("smith_borin",0,65,"Near")).tier,"Mid")
        eq(assert(life.sample("smith_borin",0,150,"Far")).tier,"Far")
        eq(assert(life.sample("smith_borin",0,140,"Far")).tier,"Mid")
        eq(assert(life.sample("smith_borin",0,50,"Far")).tier,"Near")
        local s=assert(life.sample("smith_borin",0,100000));eq(s.tier,"Far");eq(s.updateSeconds,5);eq(s.backgroundEnabled,false);eq(s.accessible,true);eq(s.questCritical,true)
        eq(s.anchor.z,entries.smith_borin.z)
        eq(assert(life.sample("smith_borin",0,0)).updateSeconds,.1)
        eq(assert(life.sample("smith_borin",0,100)).updateSeconds,.5)
    end)
    test("constructor snapshots configuration identity anchors and journal hooks",function()
        local c,e,j=copy(config),copy(entries),copy(catalog)
        local snapshot=assert(make(c,e,j))
        local before=assert(snapshot.sample("smith_borin",43200,60,"Near"))
        c.Phases[2].activity="Rest";c.NearExit=55;c.DaySeconds=1;c.RecoverySeconds=5;c.Ids[1]="unknown"
        e.smith_borin.x=999;e.smith_borin.name="Changed"
        j.Journal.borin_castings=nil;j.Journal.fake={NPC="Smith Borin"}
        local after=assert(snapshot.sample("Smith Borin",43200,60,"Near"))
        eq(after.id,before.id);eq(after.legacyName,before.legacyName);eq(after.anchor.x,before.anchor.x)
        eq(after.activity,before.activity);eq(after.tier,before.tier);eq(#after.questIds,#before.questIds)
        for index,id in ipairs(before.questIds) do eq(after.questIds[index],id) end
        eq(assert(snapshot.sample("smith_borin",.6,0,nil,0)).activity,"Rest")
    end)
    test("bad samples fail closed and projections cannot change registry",function()
        for _,n in ipairs({-1,math.huge,-math.huge,0/0}) do
            eq(life.sample("borga",n,0),nil);eq(life.sample("borga",0,n),nil);eq(life.sample("borga",0,0,nil,n),nil)
        end
        eq(life.sample("borga",0,0,"unknown"),nil);eq(life.sample("borga","0",0),nil)
        local s=assert(life.sample("smith_borin",0,0));s.anchor.x=999
        eq(assert(life.sample("smith_borin",0,0)).anchor.x,entries.smith_borin.x)
        eq(pcall(function()s.questIds[1]="fake_reward"end),false)
    end)
end
