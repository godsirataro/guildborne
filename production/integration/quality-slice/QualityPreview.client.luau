--!strict
-- Bundled only into the isolated quality preview place, never the game project.
local RunService = game:GetService("RunService")
assert(RunService:IsStudio() and game.PlaceId == 0 and game.GameId == 0)
local assets = game.ReplicatedStorage:WaitForChild("QualityPreviewAssets")
assert(assets:GetAttribute("IsolatedMemory") == true)
local importer = require(assets:WaitForChild("NativeAssetPreview") :: ModuleScript)
local handles: {any} = {}
local closed = false
local function cleanup()
	closed = true
	for _, handle in ipairs(handles) do handle.destroy() end
	table.clear(handles)
end
script.Destroying:Connect(cleanup)
local function own(handle: any)
	if closed then handle.destroy(); error("Preview cancelled") end
	table.insert(handles, handle)
end
if assets:GetAttribute("BindEnemies") == true then
	local ok, problem = pcall(function()
		require(assets:WaitForChild("EnemyBindingPreview")).create(assets, workspace, own)
	end)
	if closed then return end
	assets:SetAttribute("EnemyBindingState", if ok then "READY_LOCAL_ONLY" else "FAILED")
	if not ok then assets:SetAttribute("EnemyBindingError", tostring(problem)) end
end
local images = assets:FindFirstChild("Images")
if images then
	local ok, handle = pcall(function()
		local data = require(images.Data :: ModuleScript)
		return require(assets.NativeImagePreview).create(data, game.Players.LocalPlayer:WaitForChild("PlayerGui"), own)
	end)
	if closed then return end
	if ok then
		images:SetAttribute("PreviewState", "READY_LOCAL_ONLY")
		images:SetAttribute("Images", handle.count)
	else
		images:SetAttribute("PreviewState", "FAILED")
		images:SetAttribute("PreviewError", tostring(handle))
		warn("Quality image preview failed: " .. tostring(handle))
	end
end
for _, dataset in ipairs(assets:GetChildren()) do
	if dataset:IsA("Folder") and dataset.Name ~= "Images" and dataset:GetAttribute("SkeletalReview") ~= true and dataset:FindFirstChild("Data") then
		local started = os.clock()
		local ok, result = pcall(function()
			local data = require(dataset.Data :: ModuleScript)
			return importer.create(data, workspace, own)
		end)
		if closed then return end
		if ok then
			result.folder.Name = "QualityArt_" .. dataset.Name
			dataset:SetAttribute("PreviewState", "READY_LOCAL_ONLY")
			dataset:SetAttribute("Placements", result.placements)
			dataset:SetAttribute("Triangles", result.triangles)
		else
			dataset:SetAttribute("PreviewState", "FAILED")
			dataset:SetAttribute("PreviewError", tostring(result))
			warn("Quality local art preview failed: " .. tostring(result))
		end
		dataset:SetAttribute("LoadSeconds", os.clock()-started)
	end
end
