-- Run only in the disposable InventoryReview Client VM after Play.
-- Uses real engine Instances and the fixture's actual production modules.
local player = game:GetService("Players").LocalPlayer
local UI = player.PlayerScripts.Client.UI
local Preview = require(UI.Components.InventoryActorPreview)
local Pane = require(UI.Components.InventoryPane)
local results = {}
local screen = Instance.new("ScreenGui")
screen.Name = "InventoryNativeRegression"
screen.Parent = player.PlayerGui
local host = Instance.new("Frame")
host.Size = UDim2.fromOffset(744, 600)
host.Parent = screen
local hero = Instance.new("Model")
hero.Name = "InventoryRegressionHero"
hero:SetAttribute("GuildborneHero", true)
hero:SetAttribute("OwnerUserId", player.UserId)
hero:SetAttribute("AdventurerId", "native-regression")
local part = Instance.new("Part")
part.Anchored = true; part.CanCollide = false
part.Position = Vector3.new(1000, 1000, 1000)
part.Parent = hero; hero.Parent = workspace
local function checkPortrait(id, data, expected)
	local handle = Preview(host, {actorId = id, data = data, T = function(s) return s end})
	task.wait(1.2)
	local world = handle.viewport:FindFirstChildOfClass("WorldModel")
	local count, scripts = 0, 0
	for _, node in world:GetDescendants() do
		if node:IsA("BasePart") then
			count += 1
			assert(node.Anchored and not node.CanCollide and not node.CanTouch and not node.CanQuery)
		end
		if node:IsA("LuaSourceContainer") then scripts += 1 end
	end
	assert(scripts == 0)
	assert((count > 0) == expected)
	assert(handle.frame.PreviewUnavailable.Visible == not expected)
	handle.destroy()
	assert(handle.frame.Parent == nil and world.Parent == nil)
	return count
end
local ok, failure = pcall(function()
	local character = assert(player.Character)
	local before = character.Archivable
	local status = character:FindFirstChildOfClass("Humanoid"):FindFirstChild("Status")
	local parts = checkPortrait("player", {}, true)
	assert(character.Archivable == before)
	table.insert(results, {case = "actual_player", parts = parts, rootArchivable = before,
		statusIsModel = status and status:IsA("Model"), statusArchivable = status and status.Archivable})
	local data = {adventurers = {["native-regression"] = {}}}
	checkPortrait("native-regression", data, true)
	table.insert(results, {case = "owned_hero", pass = true})
	part.Archivable = false
	checkPortrait("native-regression", data, false)
	table.insert(results, {case = "incomplete_visual_fallback", pass = true})
	part.Archivable = true; hero:SetAttribute("OwnerUserId", player.UserId + 1)
	checkPortrait("native-regression", data, false)
	table.insert(results, {case = "foreign_hero_fallback", pass = true})
	hero:Destroy()
	checkPortrait("native-regression", data, false)
	table.insert(results, {case = "missing_hero_fallback", pass = true})
	local pane = Pane(host, {title = "Regression", actors = {}, slots = {}, items = {}, filters = {}, T = function(s) return s end})
	for _, width in {744, 280, 968, 744, 280, 968} do
		host.Size = UDim2.fromOffset(width, 600)
		task.wait(.1)
		local seen = {}
		for _, child in pane:GetChildren() do
			assert(not seen[child.Name], "Duplicate " .. child.Name)
			seen[child.Name] = true
		end
		assert(seen.InventoryHeading and seen.ItemGrid)
	end
	pane:Destroy()
	task.wait(1.2)
	assert(#host:GetChildren() == 0)
	table.insert(results, {case = "resize_and_cleanup", pass = true})
end)
hero:Destroy(); screen:Destroy()
assert(ok, tostring(failure))
return results
