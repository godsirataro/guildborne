-- Runs the real localization module; no Roblox runtime or UI layout claims.
local Localization = require("../../src/shared/Config/Localization")
local cases = {
	{ "en", "AlreadyEquipped", nil, "Already equipped" },
	{ "th", "AlreadyEquipped", nil, "สวมใส่อยู่แล้ว" },
	{ "unknown", "AlreadyEquipped", nil, "Already equipped" },
	{ "en", "Requires Hall Lv{level}", { level = 3 }, "Requires Hall Lv3" },
	{ "en", "UnmappedRegressionKey", nil, "UnmappedRegressionKey" },
}
local failures = 0
for _, case in ipairs(cases) do
	local actual = Localization.translate(case[1], case[2], case[3])
	if actual == case[4] then
		print("PASS " .. case[1] .. " " .. case[2])
	else
		failures += 1
		print("FAIL " .. case[1] .. " " .. case[2] .. ": " .. actual)
	end
end
assert(failures == 0, tostring(failures) .. " localization regressions")
print(tostring(#cases) .. " localization checks passed")
