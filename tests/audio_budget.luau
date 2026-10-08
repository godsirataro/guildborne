--!strict
local make=require("../src/shared/Data/AudioBudget")
local config=require("../src/shared/Config/AudioConfig")
return function(test: any,eq: any)
    test("audio bindings reject blank malformed zero and unsafe IDs",function()
        for _,id in ipairs({"","rbxassetid://0","https://example.com/a.wav","rbxassetid://-1","rbxassetid://nan","rbxassetid://9007199254740992"}) do eq(config.validAsset(id),false) end
        eq(config.validAsset(nil),false);eq(config.validAsset(123),false);eq(config.validAsset("rbxassetid://123"),true)
        for _,id in pairs(config.AssetIds) do eq(config.validAsset(id),true) end
    end)
    test("audio voice admission is bounded expires and releases without aliasing",function()
        local b=make(2);local first=b.Reserve("press",10,.2,.1);assert(first)
        eq(b.Reserve("press",10.05,.2,.1),nil)
        local second=b.Reserve("hit",10.05,.3,.1);assert(second)
        eq(b.Reserve("warning",10.1,.5,.1),nil);eq(b.Count(10.1),2)
        b.Release(first);local third=b.Reserve("warning",10.1,.5,.1);assert(third and third~=first)
        b.Release(first);eq(b.Count(10.2),2);eq(b.Count(10.4),1);eq(b.Count(11),0)
        b.Clear();eq(b.Count(11),0)
    end)
    test("audio invalid or backwards time cannot bypass rate and lifetime bounds",function()
        local b=make(2);assert(b.Reserve("x",10,1,.2))
        eq(b.Reserve("x",9,1,.2),nil);eq(b.Reserve("x",0/0,1,.2),nil);eq(b.Reserve("x",math.huge,1,.2),nil)
        eq(b.Reserve("x",10.3,-1,.2),nil);eq(b.Reserve("x",10.3,1,-1),nil)
        eq(b.Count(11.1),0)
    end)
    test("combat cue projection covers healing guard ranged frost and melee",function()
        eq(config.actionCue("Priest","Heal"),"heal_cast");eq(config.actionCue("Knight","Taunt"),"shield_block")
        eq(config.actionCue("Archer","Physical"),"bow_release");eq(config.actionCue("Mage","Slow"),"frost_cast")
        eq(config.actionCue("Mage","Magic"),"fire_cast");eq(config.actionCue("Warrior","Area"),"sword_swing")
        eq(config.hitCue("Archer"),"arrow_hit");eq(config.hitCue("Warrior"),"melee_hit");eq(config.hitCue(""),"melee_hit")
    end)
    test("audio feedback only reveals committed deltas once and ignores stale snapshots",function()
        local observe=require("../src/shared/Data/AudioFeedback")()
        local function view(revision:number,level:number,hero:boolean):any
            return {status="Active",revision=revision,code="OK",data={character={level=level},adventurers=if hero then {a={level=1}} else {}}}
        end
        eq(observe(view(4,3,true),true),nil)
        eq(observe(view(5,4,true),true),"level_up")
        eq(observe(view(5,4,true),true),nil)
        eq(observe(view(3,1,false),false),nil)
        eq(observe(view(6,4,true),true),"confirm")
        local recruited=view(7,4,true);recruited.data.adventurers.b={level=1}
        eq(observe(recruited,false),"recruit_reveal");eq(observe(recruited,true),nil)
        recruited.revision=8;recruited.result={reward={gold=1}}
        eq(observe(recruited,true),"reward")
        recruited.revision=9;eq(observe(recruited,false),nil)
    end)
    test("audio feedback keeps uncertain saves and passive errors silent",function()
        local observe=require("../src/shared/Data/AudioFeedback")()
        local view:any={status="Active",revision=0,code="OK",data={character={level=1},adventurers={}}}
        eq(observe(view,false),nil)
        view.status="SavePending";view.code="SavePending";view.data.character.level=2
        eq(observe(view,true),nil)
        view.status="Active";view.code="OK";view.revision=1
        eq(observe(view,false),"level_up")
        view.code="MissingMaterials";eq(observe(view,false),nil);eq(observe(view,true),"error")
        view.code="AlreadyCommitted";eq(observe(view,true),nil)
    end)
end
