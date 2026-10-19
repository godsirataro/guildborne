--!strict
-- Cosmetic event admission only; never authorizes gameplay or damage.
local Timeline=if script then require(script.Parent.ActionTimeline) else require("./ActionTimeline")
local C={ActionTTL=Timeline.Duration}
type Channel={stamp:number,consumed:boolean}
export type State={[string]:Channel}
function C.finite(value:any):boolean
    return type(value)=="number" and value==value and math.abs(value)<math.huge
end
function C.recent(stamp:any,now:any,ttl:any):boolean
    return C.finite(stamp) and stamp>0 and C.finite(now) and C.finite(ttl) and ttl>=0
        and stamp<=now and now-stamp<=ttl
end
function C.warningValid(stamp:any,untilAt:any,now:any,combatState:any):boolean
    return combatState=="Windup" and C.finite(stamp) and stamp>0 and C.finite(untilAt)
        and C.finite(now) and untilAt>stamp and stamp<=now and now<untilAt
end
function C.new():State return {} end
local function observe(state:State,key:string,stamp:any,now:any):Channel?
    -- Explicit attribute removal cancels pending work without forgetting its
    -- highwater. Malformed/future numeric observations remain nonpoisoning.
    if stamp==nil then
        local pending=state[key]
        if pending then pending.consumed=true end
        return nil
    end
    if not C.finite(stamp) or stamp<=0 or not C.finite(now) or stamp>now then return nil end
    local channel=state[key]
    if channel and stamp<channel.stamp then return nil end
    if not channel or stamp>channel.stamp then
        local fresh:Channel={stamp=stamp,consumed=false}
        channel=fresh;state[key]=fresh
    end
    return channel
end
-- Readiness cannot renew the original timestamp's TTL. A newer observation
-- replaces pending older work. Expired observations also advance the highwater.
function C.admit(state:State,key:string,stamp:any,now:any,ttl:any,ready:boolean):boolean
    if stamp==nil then observe(state,key,stamp,now);return false end
    if not C.finite(ttl) or ttl<0 then return false end
    local channel=observe(state,key,stamp,now)
    if not channel or channel.consumed then return false end
    if not C.recent(stamp,now,ttl) then channel.consumed=true;return false end
    if not ready then return false end
    channel.consumed=true;return true
end
-- Death/ownership cancellation consumes observed work without emitting it.
-- Keep the state for the model's lifetime; only a new model gets a new state.
function C.discard(state:State,key:string,stamp:any,now:any)
    local channel=observe(state,key,stamp,now)
    if channel then channel.consumed=true end
end
return table.freeze(C)
