--!strict
local Lifecycle = {}
function Lifecycle.claimDeath(enemy: any): boolean
	if enemy.kind~="Enemy" or enemy.health~=0 or enemy.state~="Dead" or enemy.rewardClaimed then return false end
	enemy.rewardClaimed=true
	return true
end
return Lifecycle
