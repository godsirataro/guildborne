--!strict
local Space=require("../src/server/Systems/CombatSpace")(require("../src/shared/Config/City"))
local TargetFactory=require("../src/server/Systems/CombatTargeting")
local DamageFactory=require("../src/server/Systems/CombatDamage")
return function(test:any,eq:any)
    local function fixture():any
        local s={origin={X=200,Y=0,Z=0}}
        local function actor(kind:string,z:number):any
            return {id=kind,kind=kind,owner=1,session=s,root={Position={X=200,Y=4,Z=z}},active=true,health=100,state="Idle",stats={Attack=10,Defense=0,MaxHealth=100},threat={}}
        end
        local target=TargetFactory(function(a:any,b:any)return math.abs(a.root.Position.Z-b.root.Position.Z)end,Space.hostile)
        local emitted=0
        local damage=DamageFactory({damage=function()return 10 end,valid=function()return true end},target,function()emitted+=1 end)
        return {s=s,hero=actor("Hero",50),enemy=actor("Enemy",52),target=target,damage=damage,emitted=function()return emitted end}
    end
    test("AI and damage cannot cross camp safe boundary in either direction",function()
        local f=fixture();eq(f.damage.hit(f.enemy,f.hero,20,1,0),10)
        f.hero.root.Position.Z=48;eq(f.target.enemy(f.enemy,{f.hero},nil,20,1),nil)
        eq(f.damage.hit(f.enemy,f.hero,20,1,1),0);eq(f.damage.hit(f.hero,f.enemy,20,1,1),0)
        eq(f.hero.health,90);eq(f.enemy.health,100);eq(f.emitted(),1)
        f.hero.root.Position.Z=50;f.enemy.root.Position.Z=48;eq(f.damage.hit(f.hero,f.enemy,20,1,2),0)
    end)
    test("camp geometry rejects all edges and foreign session or absent authority",function()
        local f=fixture()
        for _,p in ipairs({{X=239,Y=4,Z=60},{X=161,Y=4,Z=60},{X=200,Y=-3,Z=60},{X=200,Y=24.01,Z=60},{X=200,Y=4,Z=117},{X=0,Y=4,Z=-1100},{X=math.huge,Y=4,Z=60},{X=0/0,Y=4,Z=60}}) do eq(Space.contains(f.s,p),false) end
        eq(Space.contains(f.s,{X=238.99,Y=24,Z=116.99}),true)
        f.enemy.session={origin=f.s.origin};eq(Space.hostile(f.hero,f.enemy),false)
        f.enemy.session=nil;f.hero.session=nil;eq(Space.hostile(f.hero,f.enemy),false)
    end)
    test("friendly recovery targeting remains available outside combat",function()
        local f=fixture();f.hero.root.Position.Z=23
        eq(f.target.valid(f.hero,f.hero,0,true),true)
        eq(f.damage.heal(f.hero,f.hero,0,10,0),0)
        f.hero.health=70;eq(f.damage.heal(f.hero,f.hero,0,10,0),10)
        f.enemy.owner=2;eq(f.target.valid(f.hero,f.enemy,100),false)
    end)
    test("regional damage requires server activation and excludes arrival docks and other regions",function()
        local f=fixture();f.s.adventureRegion="Greenwood"
        local p={X=0,Y=5,Z=1410};eq(Space.contains(f.s,p),false)
        f.s.adventureEnabled=true;eq(Space.contains(f.s,p),true)
        for _,bad in ipairs({{X=0,Y=5,Z=1490},{X=0,Y=7,Z=1505},{X=500,Y=5,Z=1410},{X=0,Y=36,Z=1410},{X=0,Y=0,Z=1410}}) do eq(Space.contains(f.s,bad),false) end
        f.s.adventureRegion="Ironveil";eq(Space.contains(f.s,{X=500,Y=12,Z=1350}),true)
        f.s.adventureRegion="Ashen";eq(Space.contains(f.s,{X=1000,Y=11,Z=1330}),true)
        f.s.adventureRegion="fake";eq(Space.contains(f.s,p),false)
    end)
end
