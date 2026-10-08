--!strict
-- Pure server geometry and timing for regional encounter adapters. No rewards/network inputs.
local definitions: {[string]:{any}}={
    forest_captain={
        {name="Antler Cleave",shape="Cone",radius=10,halfAngle=55,duration=1.1,recovery=1.5},
        {name="Root Burst",shape="Circle",radius=8,duration=1.5,recovery=2},
    },
    quarry_guardian={
        {name="Hammer Fall",shape="Circle",radius=6,targeted=true,duration=1.4,recovery=1.8},
        {name="Fault Line",shape="Line",length=22,width=5,duration=1.7,recovery=2.2},
    },
    arcane_warden={
        {name="Rune Lance",shape="Line",length=24,width=3,duration=1.2,recovery=1.8},
        {name="Hollow Nova",shape="Ring",radius=13,innerRadius=5,duration=2,recovery=2.4},
    },
    greenwood_boar={{name="Boar Rush",shape="Line",length=18,width=4,duration=1,recovery=2.5}},
    rune_hound={{name="Rune Pounce",shape="Circle",radius=4,targeted=true,duration=.9,recovery=2.2}},
    rune_caster={{name="Rune Flare",shape="Circle",radius=4,targeted=true,duration=1.1,recovery=2}},
}
local A={}
local function finite(x:any):boolean return type(x)=="number" and x==x and math.abs(x)<1e7 end
local function position(p:any):boolean return type(p)=="table" and finite(p.x) and finite(p.y) and finite(p.z) end
function A.begin(actor:any,target:any,now:number):any
    local defs=definitions[actor.templateId]
    if not defs or not finite(now) or not position(actor.position) or not position(target) or actor.health<=0
        or actor.pendingPattern or now<(actor.nextPattern or 0) then return nil end
    local phase=if actor.health<=actor.maxHealth*.5 then 2 else 1
    local index=if phase==2 then 1+(actor.patternCount or 0)%#defs else 1
    local p=table.clone(defs[index]);local origin=if p.targeted then target else actor.position
    p.x=origin.x;p.y=origin.y;p.z=origin.z
    local dx,dz=target.x-actor.position.x,target.z-actor.position.z;local length=math.sqrt(dx*dx+dz*dz)
    p.dx=if length>.001 then dx/length else 0;p.dz=if length>.001 then dz/length else -1
    p.due=now+p.duration;p.expires=p.due+.5;p.phase=phase
    actor.pendingPattern=p;actor.patternCount=(actor.patternCount or 0)+1
    return table.clone(p) -- caller/UI cannot redirect the committed footprint
end
function A.contains(p:any,target:any):boolean
    if not position(target) or math.abs(target.y-p.y)>6 then return false end
    local x,z=target.x-p.x,target.z-p.z;local square=x*x+z*z
    if p.shape=="Circle" then return square<=p.radius*p.radius end
    if p.shape=="Ring" then return square>=p.innerRadius*p.innerRadius and square<=p.radius*p.radius end
    local forward=x*p.dx+z*p.dz
    if p.shape=="Line" then
        local side=x*(-p.dz)+z*p.dx
        return forward>=0 and forward<=p.length and math.abs(side)<=p.width/2
    end
    if p.shape=="Cone" then
        return square<=p.radius*p.radius and (square<.000001 or forward/math.sqrt(square)>=math.cos(math.rad(p.halfAngle)))
    end
    return false
end
function A.take(actor:any,now:number):any
    local p=actor.pendingPattern
    if not finite(now) or not p or now<p.due then return nil end
    actor.pendingPattern=nil;actor.nextPattern=now+p.recovery
    if actor.health<=0 or now>p.expires then return nil end
    return table.clone(p)
end
function A.cancel(actor:any,now:number)
    local p=actor.pendingPattern
    if p then
        actor.pendingPattern=nil
        if finite(now) then actor.nextPattern=math.max(actor.nextPattern or 0,now+p.recovery) end
    end
end
return A
