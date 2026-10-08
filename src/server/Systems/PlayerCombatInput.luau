--!strict
-- Exact, tiny intent protocol. No client targets, stats, positions, clocks or rewards.
local Input = {}
local actions={Basic=true,Ability=true,Ability1=true,Ability2=true,Ability3=true,Focus=true,Regroup=true,Retreat=true}
function Input.valid(packet: any): boolean
	if type(packet) ~= "table" or type(packet.action)~="string" or not actions[packet.action] then return false end
	local count = 0
	for key in pairs(packet) do if key ~= "action" and key ~= "actorId" then return false end; count += 1 end
	if packet.actorId ~= nil then
		if type(packet.actorId) ~= "string" or #packet.actorId > 64 or not packet.actorId:match("^[%w_:%-]+$") then return false end
	end
	return count == (if packet.actorId == nil then 1 else 2)
end
function Input.accept(bucket: any, now: number): boolean
	bucket.tokens = math.min(4, bucket.tokens + math.max(0, now - bucket.at) * 4); bucket.at = now
	if bucket.tokens < 1 then return false end
	bucket.tokens -= 1; return true
end
return Input
