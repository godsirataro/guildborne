--!strict
local points=require("../src/shared/Data/StatusPoints")
return function(test:any,eq:any,harness:any,util:any,content:any,schema:any,gear:any,progression:any,combat:any)
    local function enabled(fn:any)
        local old=content.StatusAllocationAvailable;content.StatusAllocationAvailable=true
        local ok,reason=pcall(fn);content.StatusAllocationAvailable=old;assert(ok,tostring(reason))
    end
    local function setup():any
        local h=harness();h.setup();eq(h.send("SelectPlayerClass",{classId="Warrior"}),"OK")
        h.quest("trail_watch");h.quest("timber_escort")
        for _=1,25 do eq(h.service.CommitCombat(1,h.command("CombatReward"),{"player"}),"OK");h.service.FlushAudit(1) end
        return h
    end
    test("status level budgets soft caps and malformed allocation boundaries",function()
        eq(points.budget(1),0);eq(points.budget(10),27);eq(points.budget(35),102);eq(points.budget(100),297)
        eq(points.effective(40),40);eq(points.effective(80),64);eq(points.effective(150),85)
        eq(points.validate(100,{STR=150,VIT=147}),true);eq(points.validate(100,{STR=150,VIT=148}),false)
        local invalid:{any}={{STR=-1},{DEX=.5},{INT=151},{WIS=0/0},{GOLD=1},{VIT="1"}}
        for _,bad in ipairs(invalid) do eq(points.validate(100,bad),false) end
    end)
    test("status allocation is offline-gated and level-derived separately per actor",function() enabled(function()
        local h=setup();local before=util.copy(h.data());content.StatusAllocationAvailable=false
        eq(h.send("AllocateStatus",{actorId="player",stat="VIT",amount=1}),"StatusUnavailable");eq(h.data(),before)
        content.StatusAllocationAvailable=true
        local c=h.command("AllocateStatus",{actorId="player",stat="VIT",amount=3})
        eq(h.service.Execute(1,c),"OK");eq(h.service.Execute(1,c),"AlreadyCommitted")
        eq(h.send("AllocateStatus",{actorId="player",stat="VIT",amount=1}),"NotEnoughStatusPoints")
        eq(h.send("AllocateStatus",{actorId="a:Warrior",stat="STR",amount=3}),"OK")
        eq(h.data().character.statusAllocations,{VIT=3});eq(h.data().adventurers["a:Warrior"].statusAllocations,{STR=3})
        eq(h.data().currencies,before.currencies);eq(h.data().inventory,before.inventory)
        eq(h.send("AllocateStatus",{actorId="foreign",stat="VIT",amount=1}),"ActorNotReady")
        eq(h.send("AllocateStatus",{actorId="player",stat="GOLD",amount=1}),"InvalidAllocation")
        eq(h.send("AllocateStatus",{actorId="player",stat="VIT",amount=-1}),"InvalidAllocation")
        eq(h.send("AllocateStatus",{actorId="player",stat="VIT",amount=.5}),"InvalidRequest")
    end) end)
    test("status copied profile validation rejects corrupt spends without modifying legacy saves",function()
        local h=setup();local record=util.copy(h.service.Sessions[1].record)
        eq(schema.validate(record,1),true);record.data.character.statusAllocations={VIT=4};eq(schema.validate(record,1),false)
        record.data.character.statusAllocations={VIT=3};eq(schema.validate(record,1),true)
        record.data.adventurers["a:Warrior"].statusAllocations={STR=4};eq(schema.validate(record,1),false)
        eq(h.data().character.statusAllocations,nil)
    end)
    test("status uncertain writes and reset replays retain exact per-entity budget on rejoin",function() enabled(function()
        for _,mode in ipairs({"before","after"}) do
            local h=setup();local before=util.copy(h.data());h.mode=mode
            local c=h.command("AllocateStatus",{actorId="player",stat="VIT",amount=3})
            eq(h.service.Execute(1,c),"SavePending");eq(h.data(),before);h.mode="ok";eq(h.service.Refresh(1),"OK")
            eq(h.service.Execute(1,c),"AlreadyCommitted");eq(h.data().character.statusAllocations,{VIT=3})
            eq(h.send("LearnSkill",{actorId="player",skillId="vitality"}),"OK")
            eq(h.send("ResetSkills",{actorId="player"}),"UseBuildPointReset")
            local xp=h.data().character.xp;local gold=h.data().currencies.gold
            h.mode=mode;local reset=h.command("ResetBuildPoints",{actorId="player"})
            eq(h.service.Execute(1,reset),"SavePending");h.mode="ok";eq(h.service.Refresh(1),"OK")
            eq(h.service.Execute(1,reset),"AlreadyCommitted");eq(h.data().character.statusAllocations,nil)
            eq(h.data().expansion.actors.player.skills,{});eq(h.data().character.xp,xp);eq(h.data().currencies.gold,gold)
            eq(h.send("ResetBuildPoints",{actorId="player"}),"NoPointsToReset")
            local committed=util.copy(h.data());h.service.Close(1);h.service=h.make();eq(h.service.Load(1,"status-rejoin"),"OK");eq(h.data(),committed)
            eq(h.send("AllocateStatus",{actorId="player",stat="STR",amount=3}),"OK")
            eq(h.send("AllocateStatus",{actorId="player",stat="VIT",amount=1}),"NotEnoughStatusPoints")
        end
    end) end)
    test("status edits cannot change expedition snapshots or unavailable heroes",function() enabled(function()
        local h=setup();eq(h.send("StartQuest",{questId="trail_watch"}),"OK");local before=util.copy(h.data())
        eq(h.send("AllocateStatus",{actorId="a:Warrior",stat="STR",amount=1}),"FinishYourExpedition")
        eq(h.send("ResetBuildPoints",{actorId="player"}),"FinishYourExpedition");eq(h.data(),before)
        h.now=h.data().quests.active.completeAt;eq(h.send("CompleteQuest",{runId=h.data().quests.active.runId}),"OK")
        local copied=util.copy(h.data());copied.adventurers["a:Warrior"].condition="Injured"
        local service=require("../src/server/Services/StatusPointService")(content,points,require("../src/shared/Data/Expansion"))
        eq(service.apply(copied,"AllocateStatus",{actorId="a:Warrior",stat="STR",amount=1},function()end),"HeroUnavailable")
        copied.adventurers["a:Warrior"].condition=nil;copied.expansion.tower.active={state="Ready"}
        eq(service.apply(copied,"ResetBuildPoints",{actorId="player"},function()end),"LeaveTowerFirst")
    end) end)
    test("status bonuses use identical projected and combat totals with no allocation baseline drift",function()
        local h=setup();local d=h.data();local actor=d.character
        local baseline=progression.stats(d,actor);actor.statusAllocations={VIT=3}
        local shown=progression.stats(d,actor);local loadout=gear.loadout(d,actor)
        local stats=require("../src/server/Systems/CombatStats")(content,combat,gear).hero(actor.classId,actor.level,loadout.weapon,loadout.armor,loadout.accessory,gear.extras(d,actor))
        eq(shown.Health,baseline.Health+6);eq(shown.Health,stats.MaxHealth);eq(shown.Attack,stats.Attack);eq(shown.Defense,stats.Defense)
        eq(points.bonuses("Warrior",{STR=40}).Attack,10);eq(points.bonuses("Mage",{STR=40}).Attack,0)
        eq(points.bonuses("Archer",{DEX=40}).Attack,10);eq(points.bonuses("Priest",{INT=40}).Attack,10)
        eq(points.bonuses("Priest",{WIS=40}).HealPower,20);eq(points.bonuses("Knight",{WIS=40}).GuardBonus,.04)
    end)
    test("Wisdom changes actual healing and timed guard without bypassing cooldown ownership or expiry",function()
        local config=util.copy(combat);config.Abilities.bulwark.Group=true
        local stats=require("../src/server/Systems/CombatStats")(content,config,gear)
        local target=require("../src/server/Systems/CombatTargeting")(function(a:any,b:any)return math.abs(a.x-b.x)end)
        local damage=require("../src/server/Systems/CombatDamage")(stats,target,function()end)
        local ability=require("../src/server/Systems/CombatAbilities")(config,target,damage,function()end)
        local function actor(class:string):any
            return {class=class,kind="Hero",owner=1,active=true,state="Idle",x=0,health=1,stats={Attack=4,Defense=0,MaxHealth=100,HealPower=20,GuardBonus=.04},cooldowns={}}
        end
        local priest=actor("Priest");local knight=actor("Knight");local ally=actor("Warrior");local foreign=actor("Warrior");foreign.owner=2
        eq(ability.cast(priest,"heal",ally,{},0),true);eq(ally.health,37)
        eq(ability.cast(priest,"heal",ally,{},1),false);eq(ally.health,37)
        knight.allowedAbilities={"bulwark"};knight.allies={knight,ally,foreign}
        local enemy={kind="Enemy",owner=1,active=true,state="Idle",x=2,health=100,stats={Attack=100,Defense=0,MaxHealth=100},threat={}}
        eq(ability.cast(knight,"bulwark",enemy,{enemy},0),true)
        eq(knight.guardMultiplier,.51);eq(ally.guardMultiplier,.51);eq(foreign.guardUntil,nil)
        knight.health=100;eq(damage.hit(enemy,knight,5,1,1),51)
        knight.health=100;eq(damage.hit(enemy,knight,5,1,100),100)
    end)
    test("offline class advancement refunds existing SP and AP once without granting a new budget",function() enabled(function()
        local h=setup();h.quest("quarry_patrol")
        local d=h.data();d.personalGuild.buildings.guildHall=6;d.character.level=30;d.character.xp=1450
        eq(h.send("LearnSkill",{actorId="player",skillId="vitality"}),"OK")
        eq(h.send("AllocateStatus",{actorId="player",stat="VIT",amount=3}),"OK")
        local gold=h.data().currencies.gold
        eq(h.send("AdvanceClass",{actorId="player",pathId="berserker"}),"OK")
        eq(h.data().character.statusAllocations,nil);eq(h.data().expansion.actors.player.skills,{})
        eq(h.data().character.level,30);eq(h.data().character.xp,1450);eq(h.data().currencies.gold,gold)
        eq(h.send("AllocateStatus",{actorId="player",stat="VIT",amount=87}),"OK")
        eq(h.send("AdvanceClass",{actorId="player",pathId="berserker"}),"InvalidClassPath")
        eq(h.data().character.statusAllocations,{VIT=87});eq(h.send("AllocateStatus",{actorId="player",stat="VIT",amount=1}),"NotEnoughStatusPoints")
    end) end)
end
