--!strict
-- Presentation clock only. Server combat owns damage and cooldowns.
local T = { Duration = .62, Release = .10, Contact = .24, Recovery = .26 }
local function finite(n: number): boolean
	return n == n and math.abs(n) < math.huge
end
function T.active(age: number): boolean
	return finite(age) and age >= 0 and age <= T.Duration
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
