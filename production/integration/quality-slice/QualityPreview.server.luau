--!strict
-- Local opt-in only. The main game's staging runtime is never rewritten.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId == 0 and game.GameId == 0)
local server = game.ServerScriptService:WaitForChild("Server")
local runtime = require(server.Config.Runtime)
assert(runtime.StudioPersistence == "Memory" and next(runtime.AllowedDataStoreUniverses) == nil)
local assets = game.ReplicatedStorage:WaitForChild("QualityPreviewAssets")
assets:SetAttribute("IsolatedMemory", true)
if assets:GetAttribute("EnableWorldSlice") == true then
	local data = require(server.Services.WorldQualityAssets)
	local datasetName = assets:GetAttribute("WorldDataset")
	assert(type(datasetName) == "string", "Missing reviewed world dataset")
	local dataset = assets:FindFirstChild(datasetName)
	assert(dataset and dataset:GetAttribute("SourceSha256") == data.sourceMeshSha256
		and assets:GetAttribute("WorldSourceSha256") == data.sourceMeshSha256, "World source hash mismatch")
	local world = workspace:WaitForChild("GuildborneWorld", 60)
	assert(world, "Normal world bootstrap did not complete")
	assert(world:WaitForChild("Greenwood", 60), "Greenwood bootstrap did not complete")
	local init = server.Services:FindFirstChild("WorldQualitySlice")
	assert(init and init:IsA("ModuleScript"), "Quality world module missing")
	local handle = require(init)(world)
	script.Destroying:Connect(function()
		assets:SetAttribute("WorldCollisionReady", false)
		handle.destroy()
	end)
	assets:SetAttribute("WorldCollisionSourceSha256", handle.sourceMeshSha256)
	assets:SetAttribute("WorldCollisionReady", true)
end
