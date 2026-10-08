--!strict
local Util = {}

function Util.copy(value: any): any
	if type(value) ~= "table" then return value end
	local result = {}
	for key, child in pairs(value) do result[key] = Util.copy(child) end
	return result
end

function Util.equal(a: any, b: any): boolean
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	for key, value in pairs(a) do
		if not Util.equal(value, b[key]) then return false end
	end
	for key in pairs(b) do if a[key] == nil then return false end end
	return true
end

function Util.count(value: any): number
	local count = 0
	for _ in pairs(value) do count += 1 end
	return count
end

function Util.integer(value: any, minimum: number, maximum: number): boolean
	return type(value) == "number" and value == value and value >= minimum
		and value <= maximum and value % 1 == 0
end

function Util.freeze(value: any): any
	if type(value) == "table" and not table.isfrozen(value) then
		for _, child in pairs(value) do Util.freeze(child) end
		table.freeze(value)
	end
	return value
end

return Util
