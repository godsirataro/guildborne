--!strict
-- Bounded voices and per-cue rate limits, independent of Roblox audio loading.
return function(capacity: number): any
    assert(capacity>=1 and capacity<=32 and capacity%1==0)
    local voices: {[number]: number}={};local ready: {[string]: number}={};local sequence=0;local latest=-math.huge
    local api={}
    local function finite(n: number): boolean return n==n and math.abs(n)<1e12 end
    function api.Count(now: number): number
        local count=0
        for id,expires in pairs(voices) do if expires<=now then voices[id]=nil else count+=1 end end
        for key,at in pairs(ready) do if at<=now then ready[key]=nil end end
        return count
    end
    function api.Reserve(key: string,now: number,duration: number,interval: number): number?
        if not finite(now) or not finite(duration) or not finite(interval) or now<latest or duration<=0 or interval<0 then return nil end
        latest=now
        if api.Count(now)>=capacity or now<(ready[key] or -math.huge) then return nil end
        sequence+=1;voices[sequence]=now+math.min(duration,10);ready[key]=now+math.min(interval,10)
        return sequence
    end
    function api.Release(id: number) voices[id]=nil end
    function api.Clear() table.clear(voices);table.clear(ready) end
    return api
end
