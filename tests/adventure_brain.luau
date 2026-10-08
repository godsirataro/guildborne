--!strict
return function(test:any,eq:any)
    local patterns=require("../src/server/Systems/AdventurePatterns")
    local B=require("../src/server/Systems/AdventureEnemyBrain")(patterns)
    local function make(id:string,role:string):any
        return {id=id,templateId=id,role=role,owner=1,active=true,health=100,maxHealth=100,position={x=0,y=2,z=0},home={x=0,y=2,z=0},detect=30,leash=35,speed=12,range=if role=="Melee" then 5 else 20,power=15,interval=2}
    end
    local function target(id:string,x:number,owner:number?):any
        return {id=id,owner=owner or 1,active=true,health=100,maxHealth=100,position={x=x,y=2,z=0}}
    end
    local function visible():boolean return true end
    test("regional brain excludes other owners hidden dead and high targets",function()
        local a=make("greenwood_scout","Melee");local b=target("wrong",2,2)
        eq(B.step(a,{b},{},0,.2,visible).kind,"Idle")
        b.owner=1;eq(B.step(a,{b},{},0,.2,function() return false end).kind,"Idle")
        b.health=0;eq(B.step(a,{b},{},0,.2,visible).kind,"Idle")
        b.health=100;b.position.y=9;eq(B.step(a,{b},{},0,.2,visible).kind,"Idle")
    end)
    test("regional approach is bounded and leash cancels committed patterns",function()
        local a=make("greenwood_scout","Melee");local t=target("player",20)
        local intent=B.step(a,{t},{},0,10,visible);eq(intent.kind,"Move");eq(intent.x,3)
        a=make("forest_captain","Boss");a.position.x=40;patterns.begin(a,t.position,0)
        intent=B.step(a,{t},{},.2,.2,visible);eq(intent.reason,"Leash");eq(a.pendingPattern,nil);assert(intent.x<40)
    end)
    test("regional ranged spacing and basic cooldown stay deterministic",function()
        local a=make("greenwood_archer","Ranged")
        local p=target("player",3);eq(B.step(a,{p},{},0,.2,visible).reason,"KeepDistance")
        p.position.x=10;local out=B.step(a,{target("z",10),p},{},0,.2,visible)
        eq(out.kind,"Basic");eq(out.targetId,"player");eq(B.step(a,{p},{},1,.2,visible).kind,"Wait")
        eq(B.step(a,{p},{},2,.2,visible).kind,"Basic")
    end)
    test("regional support heals valid wounded ally once without mutating health",function()
        local a=make("crystal_shaman","Support");local ally=target("friend",5);ally.health=50
        local before=ally.health;local out=B.step(a,{target("player",15)},{a,ally},0,.2,visible)
        eq(out.kind,"Heal");eq(out.targetId,"friend");eq(out.amount,15);eq(ally.health,before)
        eq(B.step(a,{target("player",15)},{a,ally},.5,.2,visible).kind,"Wait")
    end)
    test("regional boss windup cancels without target and releases only at due time",function()
        local a=make("arcane_warden","Boss");local p=target("player",10)
        local out=B.step(a,{p},{},0,.2,visible);eq(out.kind,"Telegraph")
        eq(B.step(a,{p},{},.8,.2,visible).kind,"Wait")
        eq(B.step(a,{p},{},1.2,.2,visible).kind,"Impact")
        eq(B.step(a,{p},{},1.3,.2,visible).kind,"Wait")
        eq(B.step(a,{p},{},4,.2,visible).kind,"Telegraph")
        eq(B.step(a,{},{},4.2,.2,visible).kind,"Idle");eq(a.pendingPattern,nil)
    end)
    test("regional threat and taunt select only visible owned targets within detection",function()
        local a=make("greenwood_scout","Melee");local near=target("near",3);local tank=target("tank",15)
        a.threat={tank=5};B.step(a,{near,tank},{},0,.2,visible);eq(a.targetId,"tank")
        a.tauntTarget=near;a.tauntUntil=2;B.step(a,{near,tank},{},1,.2,visible);eq(a.targetId,"near")
        B.step(a,{near,tank},{},2,.2,visible);eq(a.targetId,"tank")
        tank.owner=2;B.step(a,{near,tank},{},3,.2,visible);eq(a.targetId,"near")
        tank.owner=1;tank.position.x=31;B.step(a,{near,tank},{},4,.2,visible);eq(a.targetId,"near")
        tank.position.x=15;B.step(a,{near,tank},{},5,.2,function(_:any,b:any)return b.id~="tank"end);eq(a.targetId,"near")
    end)
    test("regional slow affects approach retreat and leash until its server deadline",function()
        local a=make("greenwood_scout","Melee");local t=target("player",20);a.slowUntil=5
        local out=B.step(a,{t},{},0,.2,visible);assert(math.abs(out.x-1.08)<.0001)
        out=B.step(a,{t},{},5,.2,visible);assert(math.abs(out.x-2.4)<.0001)
        a.position.x=40;out=B.step(a,{t},{},1,.2,visible);eq(out.reason,"Leash");assert(math.abs(out.x-38.92)<.0001)
        a=make("greenwood_archer","Ranged");a.slowUntil=5;t.position.x=3
        out=B.step(a,{t},{},1,.2,visible);eq(out.reason,"KeepDistance");assert(math.abs(out.x+1.08)<.0001)
    end)
end
