--!strict
-- Local opt-in only. The main game's staging runtime is never rewritten.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId == 0 and game.GameId == 0)
local server = game.ServerScriptService:WaitForChild("Server")
local runtime = require(server.Config.Runtime)
assert(runtime.StudioPersistence == "Memory" and next(runtime.AllowedDataStoreUniverses) == nil)
local assets = game.ReplicatedStorage:WaitForChild("QualityPreviewAssets")
assets:SetAttribute("IsolatedMemory", true)
if assets:GetAttribute("EnableWorldSlice") == true then
	local world = workspace:WaitForChild("GuildborneWorld", 60)
	assert(world, "Normal world bootstrap did not complete")
	local init = server.Services:FindFirstChild("WorldQualitySlice")
	assert(init and init:IsA("ModuleScript"), "Quality world module missing")
	require(init)(world)
end
