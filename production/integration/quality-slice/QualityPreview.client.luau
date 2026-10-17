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
		local allocated: any = nil
		local presentation: any = nil
		local ok, result = pcall(function()
			local data = require(dataset.Data :: ModuleScript)
			local isWorld = assets:GetAttribute("EnableWorldSlice") == true and dataset.Name == assets:GetAttribute("WorldDataset")
			local parent: Instance = workspace
			if isWorld then parent = assert(workspace:WaitForChild("GuildborneWorld", 60), "Missing world") end
			local handle = importer.create(data, parent, own)
			allocated = handle
			if isWorld then
				local contract = require(assets:WaitForChild("WorldArtContract") :: ModuleScript)
				assert(dataset:GetAttribute("SourceSha256") == contract.sourceMeshSha256, "World art hash mismatch")
				assert(handle.placements == #contract.expectedArt, "World art count mismatch")
				for _, expected in ipairs(contract.expectedArt) do
					local part = handle.folder:FindFirstChild(expected.name)
					assert(part and part:IsA("MeshPart") and part:GetAttribute("SourceMeshId") == expected.meshId, "World mesh mismatch")
					assert((part.Position - Vector3.new(table.unpack(expected.position))).Magnitude < .1, "World mesh position mismatch")
					local components = {part.CFrame:GetComponents()}
					for i, value in ipairs(expected.rotation) do assert(math.abs(components[i+3]-value)<.001, "World mesh rotation mismatch") end
				end
				local deadline = os.clock() + 60
				while not closed and assets:GetAttribute("WorldCollisionReady") ~= true and os.clock() < deadline do task.wait(.1) end
				assert(not closed and assets:GetAttribute("WorldCollisionReady") == true, "World collision not ready")
				assert(assets:GetAttribute("WorldCollisionSourceSha256") == contract.sourceMeshSha256, "World collision hash mismatch")
				local region = assert(parent:FindFirstChild("Greenwood"), "Missing Greenwood")
				local changes: {any} = {}
				local restored = false
				local function restore()
					if restored then return end
					restored = true
					for _, old in ipairs(changes) do if old.part.Parent then old.part.LocalTransparencyModifier = old.value end end
				end
				local connection = assets:GetAttributeChangedSignal("WorldCollisionReady"):Connect(function()
					if assets:GetAttribute("WorldCollisionReady") ~= true then
						restore(); handle.destroy()
						dataset:SetAttribute("PreviewState", "COLLISION_REMOVED")
					end
				end)
				presentation = {destroy=function() connection:Disconnect(); restore() end}
				own(presentation)
				local quality = require(game.ReplicatedStorage.Shared.Config.WorldQuality)
				for _, part in ipairs(region:GetChildren()) do
					if part:IsA("BasePart") and quality.isDecoration(part.Name, part.ClassName) then
						table.insert(changes, {part=part, value=part.LocalTransparencyModifier})
						part.LocalTransparencyModifier = 1
					end
				end
			end
			return handle
		end)
		if closed then return end
		if ok then
			result.folder.Name = "QualityArt_" .. dataset.Name
			dataset:SetAttribute("PreviewState", "READY_LOCAL_ONLY")
			dataset:SetAttribute("Placements", result.placements)
			dataset:SetAttribute("Triangles", result.triangles)
		else
			if presentation then presentation.destroy() end
			if allocated then allocated.destroy() end
			dataset:SetAttribute("PreviewState", "FAILED")
			dataset:SetAttribute("PreviewError", tostring(result))
			warn("Quality local art preview failed: " .. tostring(result))
		end
		dataset:SetAttribute("LoadSeconds", os.clock()-started)
	end
end
