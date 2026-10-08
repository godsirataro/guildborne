--!strict
-- SERVER, Studio only, outside runtime tree. Start before entering camp with all five heroes.
assert(game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsServer())
local plot=workspace:WaitForChild("GuildborneWorld"):FindFirstChild("PersonalGuild") :: Model
local result: any={classes={},taunt=false,damage=false,healing=false,downed=false,samples=0}
local startDeaths=(plot:GetAttribute("enemy_defeated") or 0) :: number
local startRewards=(plot:GetAttribute("RewardsSaved") or 0) :: number
_G.GBCombatProbe=result
task.spawn(function()
	for _=1,600 do
		result.samples+=1
		local folder=plot:FindFirstChild("Heroes")
		if not folder then return end
		for _,instance in ipairs(folder:GetChildren()) do
			local m=instance :: Model
			if m:GetAttribute("HeroState")~="Following" then continue end
			local record=result.classes[m.Name] or {basic=0,ability=0,minHealth=10000,maxAttackDistance=0}
			result.classes[m.Name]=record
			record.basic=m:GetAttribute("BasicAttackCount") or 0; record.ability=m:GetAttribute("AbilityCount") or 0
			record.minHealth=math.min(record.minHealth,(m:GetAttribute("CombatHealth") or 10000) :: number)
			if m:GetAttribute("CombatState")=="Downed" then result.downed=true end
			if (m:GetAttribute("HealingDone") or 0)>0 then result.healing=true end
			if (m:GetAttribute("DamageDealt") or 0)>0 then result.damage=true end
			local at=m:GetAttribute("ActionAt")
			local position=m:GetAttribute("ActionTargetPosition")
			if at and at~=record.lastAction and typeof(position)=="Vector3" and m.PrimaryPart then
				record.lastAction=at
				record.maxAttackDistance=math.max(record.maxAttackDistance,(m.PrimaryPart.Position-position).Magnitude)
			end
			if m.PrimaryPart and not m.PrimaryPart.Anchored then assert(m.PrimaryPart:GetNetworkOwner()==nil,"Hero network ownership") end
		end
		for _,m in ipairs(plot:GetChildren()) do
			if m:GetAttribute("GuildborneEnemy") and m:GetAttribute("Taunted") and m:GetAttribute("CombatTarget")=="a:Knight" then result.taunt=true end
		end
		result.deaths=((plot:GetAttribute("enemy_defeated") or 0) :: number)-startDeaths
		result.rewards=((plot:GetAttribute("RewardsSaved") or 0) :: number)-startRewards
		task.wait(.1)
	end
	result.done=true
	print("GBCOMBAT OBSERVED",game:GetService("HttpService"):JSONEncode(result))
end)
