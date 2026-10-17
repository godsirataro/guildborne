--!strict
-- Presentation cursor only. Inject the shared ActionTimeline.accept predicate.
-- Missing positions do not consume a server event; lifecycle reset is explicit.
return function(accept: (any, number, number?) -> boolean)
    local previous: number? = nil
    local api = {}
    function api.observe(stamp: any, now: number, payloadReady: boolean): boolean
        if not payloadReady or not accept(stamp, now, previous) then return false end
        previous = stamp
        return true
    end
    function api.reset()
        previous = nil
    end
    return api
end
