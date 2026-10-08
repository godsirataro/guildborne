--!strict
-- Read-only projection of the existing rules; learning still uses LearnSkill.
local Rules = require(game.ReplicatedStorage.Shared.Data.Expansion)
local Colors = require(game.ReplicatedStorage.Shared.Config.Art).UI
local Availability=require(script.Parent.SkillAvailability)
local positions = {
	vitality = Vector2.new(.5, .12), focus = Vector2.new(.23, .38), ward = Vector2.new(.77, .38),
	path_art = Vector2.new(.5, .64), master_art = Vector2.new(.5, .9),
}
return function(parent: Instance, build: any, level: number, blocked: boolean, T: any, learn: (string) -> ())
	local tree = Instance.new("Frame")
	tree.Name = "SkillTree"; tree.Size = UDim2.new(1, 0, 0, 360); tree.BackgroundTransparency = 1; tree.Parent = parent
	local lines: {{frame: Frame, from: Vector2, to: Vector2}} = {}
	for _, id in ipairs(Rules.SkillOrder) do
		local def = Rules.Skills[id]
		if def.Requires then
			local line = Instance.new("Frame"); line.Name = "Link_" .. id
			line.AnchorPoint = Vector2.new(.5, .5); line.BorderSizePixel = 0
			line.BackgroundColor3 = if build.skills[id] then Colors.Accent else Colors.Border
			line.Parent = tree
			table.insert(lines, {frame = line, from = positions[def.Requires], to = positions[id]})
		end
	end
	local function resize()
		for _, link in ipairs(lines) do
			local a, b = link.from * tree.AbsoluteSize, link.to * tree.AbsoluteSize
			local delta = b - a; link.frame.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
			link.frame.Size = UDim2.fromOffset(delta.Magnitude, 3); link.frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
		end
	end
	for _, id in ipairs(Rules.SkillOrder) do
		local def = Rules.Skills[id]
		local learned = build.skills[id] == true
		local reason,available=Availability(build,level,id,blocked)
		local node = Instance.new("TextButton"); node.Name = "Node_" .. id
		node.AnchorPoint = Vector2.new(.5, .5); node.Position = UDim2.fromScale(positions[id].X, positions[id].Y)
		node.Size = UDim2.new(.43, 0, 0, 66); node.ZIndex = 2
		node.BackgroundColor3 = if learned then Colors.Accent elseif available then Colors.Button else Colors.Card
		node.TextColor3 = if learned then Colors.Background else Colors.Text
		node.Text = T(id) .. " · " .. def.Cost .. "\n" .. T(reason)
		node.Font = Enum.Font.GothamMedium; node.TextSize = 14; node.TextWrapped = true
		node.Active = available; node.Selectable = available; node.AutoButtonColor = available; node.Parent = tree
		local round = Instance.new("UICorner"); round.CornerRadius = UDim.new(0, 10); round.Parent = node
		local stroke = Instance.new("UIStroke"); stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = if learned or available then Colors.Accent else Colors.Border; stroke.Parent = node
		node.Activated:Connect(function() if available then learn(id) end end)
	end
	tree:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize); resize()
	return tree
end
