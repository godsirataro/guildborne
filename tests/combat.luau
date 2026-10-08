--!strict
local MakeStats=require("../src/server/Systems/CombatStats")
local MakeTarget=require("../src/server/Systems/CombatTargeting")
local MakeDamage=require("../src/server/Systems/CombatDamage")
local MakeAbilities=require("../src/server/Systems/CombatAbilities")
local Lifecycle=require("../src/server/Systems/EnemyLifecycle")
local Validate=require("../src/server/Systems/CombatValidator")
return function(test: any,eq: any,harness: any,util: any,content: any,config: any,protocol: any,schema: any,localization: any)
	local gear=require("../src/shared/Data/Equipment")(content)
	local stats=MakeStats(content,config,gear)
	local target=MakeTarget(function(a: any,b: any) return math.abs(a.x-b.x) end)
	local events={}
	local function emit(name: string,_a: any,_b: any,_v: any) table.insert(events,name) end
	local damage=MakeDamage(stats,target,emit)
	local abilities=MakeAbilities(config,target,damage,emit)
	local function hero(class: string,x: number?): any
		local s=stats.hero(class,1,nil)
		return {id=class,class=class,kind="Hero",owner=1,active=true,state="Follow",stats=s,health=s.MaxHealth,x=x or 0,cooldowns={},threatMultiplier=config.Classes[class].Threat}
	end
	local function enemy(x: number?): any
		return {id="g:1",kind="Enemy",owner=1,active=true,state="Idle",stats=config.Goblin,health=config.Goblin.MaxHealth,x=x or 2,cooldowns={},threat={}}
	end
	test("combat stats derive class level and compatible equipped weapon",function()
		local s=stats.hero("Warrior",3,"iron_sword"); eq(s.Attack,12); eq(s.MaxHealth,36); eq(s.Defense,4); eq(s.MoveSpeed,17)
		eq(stats.hero("Priest",1,"iron_sword"),nil)
	end)
	test("physical damage predictable and attack monotonic",function() eq(stats.damage(10,0),10); assert(stats.damage(20,3)>stats.damage(10,3)) end)
	test("defense mitigates with positive minimum",function() assert(stats.damage(10,7)<stats.damage(10,0)); eq(stats.damage(1,99999),1) end)
	test("invalid negative nonfinite stats and levels rejected",function()
		for _,n in ipairs({-1,0/0,math.huge}) do eq(stats.damage(n,1),0); eq(stats.damage(1,n),0); eq(stats.hero("Knight",n,nil),nil) end
		eq(stats.hero("Mage",1.5,nil),nil); eq(stats.hero("Bogus",1,nil),nil)
	end)
	test("healing cap and separate healing telemetry",function()
		local a,b=hero("Priest"),hero("Knight"); b.health=31
		eq(damage.heal(a,b,23,100,0),9); eq(b.health,40); eq(events[#events],"healing_done")
		eq(damage.heal(a,b,23,-2,0),0)
	end)
	test("ability cooldown authoritative and invalid cast does not consume",function()
		local a,b=hero("Mage"),enemy(100)
		eq(abilities.cast(a,"fireball",b,{b},0),false); eq(a.cooldowns.fireball,nil)
		b.x=15; eq(abilities.cast(a,"fireball",b,{b},0),true); eq(abilities.cast(a,"fireball",b,{b},1),false)
		eq(abilities.cast(a,"fireball",b,{b},8),true)
	end)
	test("target validates owner allegiance active state and nil",function()
		local a,b=hero("Warrior"),enemy(); b.owner=2; eq(target.valid(a,b,5),false)
		b.owner=1; b.active=false; eq(target.valid(a,b,5),false); eq(target.valid(a,nil,5),false)
		eq(target.valid(a,hero("Knight"),5),false)
	end)
	test("attack range and attack interval checked on server",function()
		local a,b=hero("Warrior"),enemy(6); eq(abilities.basic(a,b,0),false)
		b.x=5; eq(abilities.basic(a,b,0),true); local hp=b.health; eq(abilities.basic(a,b,.5),false); eq(b.health,hp)
	end)
	test("Knight threat and temporary taunt override expire",function()
		local k,w,e=hero("Knight"),hero("Warrior"),enemy()
		damage.hit(k,e,5,1,0); damage.hit(w,e,5,1,0)
		eq(target.enemy(e,{k,w},nil,22,0),k)
		e.threat[w.id]=100; eq(abilities.cast(k,"taunt",e,{e},1),true)
		eq(target.enemy(e,{k,w},w,22,2),k); eq(target.enemy(e,{k,w},k,22,5),w)
	end)
	test("Priest picks meaningful largest deficit skips full downed foreign distant",function()
		local p,k,w=hero("Priest"),hero("Knight"),hero("Warrior"); k.health=20; w.health=24
		eq(target.heal(p,{p,k,w},23),k); k.health=0; eq(target.heal(p,{p,k,w},23),w)
		w.x=24; eq(target.heal(p,{p,k,w},23),nil); w.x=0; w.owner=2; eq(target.heal(p,{p,k,w},23),nil)
		eq(abilities.cast(p,"heal",p,{},0),false); eq(p.cooldowns.heal,nil)
	end)
	test("enemy death latched once only and duplicate reward rejected",function()
		local e=enemy(); eq(Lifecycle.claimDeath(e),false); e.health=0; e.state="Dead"
		eq(Lifecycle.claimDeath(e),true); eq(Lifecycle.claimDeath(e),false)
	end)
	test("invalid ability and another class ability rejected",function()
		local a,b=hero("Mage"),enemy(); eq(abilities.cast(a,"unknown",b,{b},0),false); eq(abilities.cast(a,"taunt",b,{b},0),false)
	end)
	test("downed hero cannot attack cast or receive combat healing",function()
		local a,b=hero("Knight"),enemy(); a.health=0; a.state="Downed"
		eq(abilities.basic(a,b,0),false); eq(abilities.cast(a,"taunt",b,{b},0),false); eq(damage.heal(hero("Priest"),a,23,20,0),0)
	end)
	test("dead enemy cannot attack or receive additional damage",function()
		local a,b=hero("Warrior"),enemy(); b.health=0; b.state="Dead"
		eq(abilities.basic(b,a,0),false); eq(damage.hit(a,b,5,1,0),0)
	end)
	test("combat references resolve and bad configs fail startup",function()
		eq(Validate(content,config,stats),true); local bad=util.copy(config); bad.Classes.Mage.Ability="missing"
		eq(pcall(Validate,content,bad,stats),false)
		for _,def in pairs(config.Abilities) do assert(localization.Thai[def.Name]) end
	end)
	test("forged combat damage heal health stats and reward intents rejected",function()
		for _,action in ipairs({"DealDamage","Heal","SetHealth","SetStats","GiveKillReward","CombatReward","CastAbility"}) do
			eq(protocol.validate({version=1,requestId="forged",revision=0,action=action,args={}}),false)
		end
		local h=harness(); h.setup(); local r=util.copy(h.service.Sessions[1].record); r.data.adventurers["a:Warrior"].baseStats.Attack=999
		eq(schema.validate(r,1),false)
	end)
	local function command(h: any): any return {version=1,requestId="combat:death-1",revision=h.service.Sessions[1].record.revision,action="CombatReward",args={}} end
	test("combat reward commits Gold XP audit once and survives rejoin",function()
		local h=harness(); h.setup(); local c=command(h)
		eq(h.service.CommitCombat(1,c,{"a:Warrior"}),"OK"); eq(h.data().currencies.gold,3); eq(h.data().adventurers["a:Warrior"].xp,2)
		eq(h.service.CommitCombat(1,c,{"a:Warrior"}),"AlreadyCommitted"); eq(h.data().currencies.gold,3)
		eq(h.service.Close(1),"OK"); h.service=h.make(); eq(h.service.Load(1,"rejoin"),"OK"); eq(h.data().currencies.gold,3)
		eq(h.service.CommitCombat(1,c,{"a:Warrior"}),"StaleRevision")
	end)
	test("uncertain combat save reconciles without double Gold XP",function()
		local h=harness(); h.setup(); local c=command(h); h.mode="after"
		eq(h.service.CommitCombat(1,c,{"a:Warrior"}),"SavePending"); eq(h.data().currencies.gold,0)
		h.mode="ok"; eq(h.service.Refresh(1),"OK"); eq(h.service.CommitCombat(1,c,{"a:Warrior"}),"AlreadyCommitted")
		eq(h.data().currencies.gold,3); eq(h.data().adventurers["a:Warrior"].xp,2)
	end)
	test("reward capacity and foreign membership reject atomically",function()
		local h=harness(); h.setup(); eq(h.service.CommitCombat(1,command(h),{"foreign"}),"InvalidParty")
		eq(h.data().currencies.gold,0); eq(h.data().adventurers["a:Warrior"].xp,0)
		local makeReward=require("../src/server/Systems/CombatRewards")
		local economy=require("../src/server/Services/EconomyService")(content,util)
		local grant=makeReward(content,config,util,economy)
		local r=util.copy(h.service.Sessions[1].record); r.data.currencies.gold=content.Limits.Gold
		local before=util.copy(r); local candidate,result=grant(r,{"a:Warrior"})
		eq(candidate,nil); eq(result.code,"WalletFull"); eq(r,before)
		r.data.currencies.gold=0; r.data.adventurers["a:Warrior"].xp=content.Limits.XP
		before=util.copy(r); candidate,result=grant(r,{"a:Warrior"})
		eq(candidate,nil); eq(result.code,"XPCap"); eq(r,before)
	end)
    test("regional reward catalog covers art profiles with bounded existing item definitions",function()
        local rewards=require("../src/server/Config/AdventureRewards")
        local profiles=require("../src/server/Config/AdventureEnemyProfiles")
        local count=0;local events={}
        for id,reward in pairs(rewards) do
            assert(profiles[id]);count+=1
            assert(util.integer(reward.Gold,1,24) and util.integer(reward.XP,1,20));assert(not events[reward.Event]);events[reward.Event]=true
            for _,item in ipairs(reward.Items) do assert(content.Items[item.Id] and util.integer(item.Quantity,1,3)) end
        end
        eq(count,12);for id in pairs(profiles) do assert(rewards[id]) end
    end)
    test("regional rewards commit once with items and do not advance Goblin tasks",function()
        local h=harness();h.setup();h.data().settlement.journal.camp_threat={state="Active",progress=0}
        local c=command(h)
        eq(h.service.CommitCombat(1,c,{"a:Warrior"},"forest_captain"),"OK")
        eq(h.data().currencies.gold,12);eq(h.data().adventurers["a:Warrior"].xp,10)
        eq(h.data().inventory.stacks.timber,2);eq(h.data().settlement.journal.camp_threat.progress,0)
        eq(h.service.CommitCombat(1,c,{"a:Warrior"},"forest_captain"),"AlreadyCommitted")
        eq(h.data().currencies.gold,12);eq(h.data().inventory.stacks.timber,2)
        eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"region-reward"),"OK")
        eq(h.data().currencies.gold,12);eq(h.data().inventory.stacks.timber,2)
    end)
    test("regional reward uncertainty reconciles exactly once before and after writes",function()
        for _,mode in ipairs({"before","after"}) do
            local h=harness();h.setup();local before=util.copy(h.data());local c=command(h);h.mode=mode
            eq(h.service.CommitCombat(1,c,{"a:Warrior"},"quarry_guardian"),"SavePending");eq(h.data(),before)
            h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.CommitCombat(1,c,{"a:Warrior"},"quarry_guardian"),"AlreadyCommitted")
            eq(h.data().currencies.gold,18);eq(h.data().adventurers["a:Warrior"].xp,15);eq(h.data().inventory.stacks.iron_ore,2)
        end
    end)
    test("unknown regional rewards and inventory overflow never partially award",function()
        local h=harness();h.setup();local before=util.copy(h.data())
        eq(h.service.CommitCombat(1,command(h),{"a:Warrior"},"fake"),"InvalidEncounter");eq(h.data(),before)
        h.data().inventory.stacks.herb=content.Limits.Stack;before=util.copy(h.data())
        eq(h.service.CommitCombat(1,h.command("CombatReward"),{"a:Warrior"},"greenwood_boar"),"InventoryFull");eq(h.data(),before)
    end)

    test("combat sight blocks damage healing and selection without consuming cooldowns",function()
        local visible=false;local queries=0
        local sightTarget=MakeTarget(function(a:any,b:any)return math.abs(a.x-b.x)end,nil,function()queries+=1;return visible end)
        local sightDamage=MakeDamage(stats,sightTarget,function()end)
        local sightAbilities=MakeAbilities(config,sightTarget,sightDamage,function()end)
        local a,b=hero("Warrior"),enemy(2);local hp=b.health
        eq(sightDamage.hit(a,b,5,1,1),0);eq(b.health,hp)
        eq(sightAbilities.basic(a,b,1),false);eq(a.nextAttack,nil)
        eq(sightTarget.enemy(a,{b},nil,25,1),nil)
        local healer=hero("Priest");a.health=10
        eq(sightDamage.heal(healer,a,23,10,1),0);eq(a.health,10)
        local before=queries;b.owner=2;eq(sightTarget.valid(a,b,25),false);eq(queries,before)
        b.owner=1;visible=true;assert(sightDamage.hit(a,b,5,1,2)>0)
        eq(sightDamage.heal(healer,a,23,10,2),10)
    end)

end
