--!strict
-- Presentation clock only. Server combat owns damage and cooldowns.
local T = { Duration = .62, Release = .10, Contact = .24, Recovery = .26 }
local function finite(n: number): boolean
	return n == n and math.abs(n) < math.huge
end
function T.active(age: number): boolean
	return finite(age) and age >= 0 and age <= T.Duration
end
-- Only a new, live server timestamp may start presentation. Missing/reordered
-- observations cannot manufacture another cast; this never authorizes damage.
function T.accept(stamp: any, now: number, previous: number?): boolean
	return typeof(stamp)=="number" and finite(stamp) and finite(now)
		and T.active(now-stamp) and (previous==nil or stamp>previous)
end
-- An observed action can schedule only markers that have not elapsed already.
function T.markerDelay(stamp: any, now: number, at: number): number?
	if typeof(stamp)~="number" or not finite(stamp) or not finite(now) or not finite(at)
		or at<0 or at>T.Duration then return nil end
	local age=now-stamp
	local due=stamp+at
	if not T.active(age) or not finite(due) or now>due then return nil end
	return math.max(0,due-now)
end
-- Injectable scheduler used by the runtime and deterministic timing tests.
-- current owns actor/generation cancellation; this function never grants a hit.
function T.scheduleMarker(stamp: any, at: number, clock: () -> number,
	schedule: (number, () -> ()) -> (), current: () -> boolean, emit: () -> ()): boolean
	local delay=T.markerDelay(stamp,clock(),at)
	if delay==nil then return false end
	local due=(stamp :: number)+at
	local delivered=false
	schedule(delay,function()
		if delivered then return end
		delivered=true
		local now=clock()
		if finite(now) and now>=due and now-due<=.2 and current() then emit() end
	end)
	return true
end
function T.phase(age: number): string
	if not T.active(age) then return "Idle" end
	if age < T.Release then return "Anticipation" end
	if age < T.Contact then return "Release" end
	if age < T.Recovery then return "Contact" end
	return "Recovery"
end
-- A late observation never replays earlier markers. A replacement action gets its
-- own cursor; calling twice at the same age produces no repeated presentation.
function T.crossed(previous: number, current: number): {string}
	local result: {string} = {}
	if not finite(previous) or not finite(current) or current < previous or current > T.Duration then return result end
	for _, entry in ipairs({{name="release", at=T.Release}, {name="contact", at=T.Contact}, {name="recovery", at=T.Recovery}}) do
		if previous < entry.at and current >= entry.at then table.insert(result, entry.name) end
	end
	return result
end
return table.freeze(T)
