--!strict
-- Server encounter intent generator. Adapters own locomotion, damage validation and persistence.
return function(patterns:any)
    local B={}
    local function distance(a:any,b:any):number
        local x,z=a.x-b.x,a.z-b.z;return math.sqrt(x*x+z*z)
    end
    local function valid(actor:any,target:any):boolean
        return target~=nil and target.active==true and target.owner==actor.owner and target.health>0
            and math.abs(target.position.y-actor.position.y)<=6
    end
    local function move(actor:any,target:any,dt:number,reason:string,now:number):any
        local speed=actor.speed*(if (actor.slowUntil or 0)>now then .45 else 1)
        local d=distance(actor.position,target);local step=math.min(d,speed*math.clamp(dt,0,.25))
        return {kind="Move",reason=reason,x=actor.position.x+(target.x-actor.position.x)*step/math.max(d,.001),
            z=actor.position.z+(target.z-actor.position.z)*step/math.max(d,.001)}
    end
    function B.step(actor:any,opponents:{any},allies:{any},now:number,dt:number,visible:any):any
        if now~=now or now==math.huge or dt~=dt or dt<0 then return {kind="Wait"} end
        if actor.health<=0 or not actor.active then patterns.cancel(actor,now);return {kind="Dead"} end
        local target=nil;local nearest=actor.detect;local bestScore= -math.huge
        if distance(actor.position,actor.home)<=actor.leash then
            for _,candidate in ipairs(opponents) do
                if valid(actor,candidate) and visible(actor,candidate) then
                    local d=distance(actor.position,candidate.position)
                    local threat=(actor.threat and actor.threat[candidate.id]) or 0
                    local taunted=(actor.tauntUntil or 0)>now and actor.tauntTarget and actor.tauntTarget.id==candidate.id
                    local score=(if taunted then 1e12 else 0)+threat*100+(if actor.targetId==candidate.id then 2 else 0)-d
                    if d<=actor.detect and (score>bestScore or (score==bestScore and (not target or candidate.id<target.id))) then target=candidate;nearest=d;bestScore=score end
                end
            end
        end
        if not target then
            patterns.cancel(actor,now);actor.targetId=nil
            if distance(actor.position,actor.home)>.5 then return move(actor,actor.home,dt,"Leash",now) end
            return {kind="Idle",recover=true}
        end
        actor.targetId=target.id
        if actor.pendingPattern then
            local p=patterns.take(actor,now)
            if p then return {kind="Impact",pattern=p} end
            return {kind="Wait"}
        end
        if actor.role=="Support" and now>=(actor.nextAttack or 0) then
            local best=nil;local deficit=0
            for _,ally in ipairs(allies) do
                if ally~=actor and valid(actor,ally) and distance(actor.position,ally.position)<=actor.range and visible(actor,ally) then
                    local missing=ally.maxHealth-ally.health
                    if missing>=ally.maxHealth*.2 and (missing>deficit or (missing==deficit and (not best or ally.id<best.id))) then best=ally;deficit=missing end
                end
            end
            if best then actor.nextAttack=now+actor.interval;return {kind="Heal",targetId=best.id,amount=math.min(deficit,actor.power)} end
        end
        if nearest>actor.range then return move(actor,target.position,dt,"Approach",now) end
        if (actor.role=="Ranged" or actor.role=="Spell" or actor.role=="Support") and nearest<6 then
            local p=actor.position;local d=math.max(nearest,.001)
            local retreat={x=p.x+(p.x-target.position.x)/d*3,z=p.z+(p.z-target.position.z)/d*3}
            if distance(retreat,actor.home)<actor.leash then return move(actor,retreat,dt,"KeepDistance",now) end
        end
        local pattern=patterns.begin(actor,target.position,now)
        if pattern then return {kind="Telegraph",pattern=pattern} end
        if actor.role=="Boss" or actor.role=="Charge" or actor.role=="Spell" then return {kind="Wait"} end
        if now<(actor.nextAttack or 0) then return {kind="Wait"} end
        actor.nextAttack=now+actor.interval
        return {kind="Basic",targetId=target.id,power=actor.power}
    end
    return B
end
