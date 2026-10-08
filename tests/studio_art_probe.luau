--!strict
-- Manual Studio SERVER probe, after one player joins. Never mapped into the place.
assert(game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsServer(), "Studio server required")
local Art = require(game.ReplicatedStorage.Shared.Config.Art)
local templates = game:GetService("ServerStorage"):WaitForChild("GuildborneArtKit")
assert(#templates:GetChildren() == 25, "Expected exactly 25 templates")
for _, instance in ipairs(templates:GetDescendants()) do
	assert(not instance:IsA("BaseScript"), "No executable scripts in props")
	if instance:IsA("BasePart") then
		assert(instance.Anchored and not instance.CanTouch, "Static art must be anchored and non-touching")
	end
end
local plot = workspace:WaitForChild("GuildborneWorld"):FindFirstChild("PersonalGuild") :: Model
assert(plot, "Join first")
local parts, solids, lights, particles, prompts, heroPrompts = 0, 0, 0, 0, 0, 0
for _, instance in ipairs(plot:GetDescendants()) do
	if instance:IsA("BasePart") then
		parts += 1
		if instance.CanCollide then solids += 1 end
	elseif instance:IsA("Light") then lights += 1
	elseif instance:IsA("ParticleEmitter") then particles += 1
	elseif instance:IsA("ProximityPrompt") then
		if instance.Name == "InspectHero" then
			heroPrompts += 1
			assert(string.find(instance.ActionText, "ดูข้อมูล"), "Hero prompt must include Thai")
		else
			prompts += 1
			assert(string.find(instance.ActionText, "เปิด"), "Prompt must include Thai")
		end
	end
end
assert(parts <= Art.PartBudgetPerPlot and parts == plot:GetAttribute("ArtPartCount"), "Part budget/count mismatch")
assert(prompts == 4 and lights == 0 and particles == 0, "Unexpected gameplay/light/effect growth")
assert(heroPrompts <= 5, "Too many visible heroes")
local spawn = plot:FindFirstChild("GuildSpawn") :: SpawnLocation
local origin = spawn.Position - Vector3.new(0, 1, 23)
local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Include; params.FilterDescendantsInstances = { plot:FindFirstChild("Environment") :: Instance }
params.RespectCanCollide = true
-- Avatar-width sweeps through both route junctions and the Hall entrance.
for _, offset in ipairs({ -1.5, 0, 1.5 }) do
	local segments = {
		{ Vector3.new(offset,3,23), Vector3.new(offset,3,-23) },
		{ Vector3.new(-22,3,-3+offset), Vector3.new(22,3,-3+offset) },
		{ Vector3.new(-22,3,18+offset), Vector3.new(22,3,18+offset) },
	}
	for _, segment in ipairs(segments) do
		assert(not workspace:Raycast(origin+segment[1], segment[2]-segment[1], params), "Walking route obstructed")
	end
end
print("GBART PASS", game:GetService("HttpService"):JSONEncode({ templates=25, parts=parts, solidParts=solids, prompts=prompts, heroPrompts=heroPrompts, lights=lights, particles=particles, clearRouteSweeps=9 }))
