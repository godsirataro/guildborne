--!strict
local Colors = require(game.ReplicatedStorage.Shared.Config.Art).UI
local Config = require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local AudioConfig=require(game.ReplicatedStorage.Shared.Config.AudioConfig)
local Audio=require(script.Parent.Parent.Controllers.AudioController)
return function(parent: Instance, T: (string) -> string)
	local frame = Instance.new("Frame"); frame.Name = "PresentationSettings"
	frame.Size = UDim2.new(1, -8, 0, 0); frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundTransparency = 1; frame.Parent = parent
	local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, 10); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = frame
	local function button(name: string): TextButton
		local b = Instance.new("TextButton"); b.Name = name; b.Size = UDim2.new(1, 0, 0, 52)
		b.BackgroundColor3 = Colors.Card; b.TextColor3 = Colors.Text; b.TextWrapped = true
		b.Font = Enum.Font.GothamMedium; b.TextSize = 16; b.Parent = frame
		local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = b
		return b
	end
	local quality = button("VFXQuality"); local motion = button("IdleMotion")
	local mute=button("AudioMute")
	local volumeButtons: {[string]: TextButton}={}
	for _,key in ipairs({"Master","UI","Combat","Music"}) do
		local b=button("Audio"..key);volumeButtons[key]=b
		b.Activated:Connect(function()workspace:SetAttribute(AudioConfig.Attributes[key],((math.floor(Audio.Level(key)*4+.5)+1)%5)/4)end)
	end
	mute.Activated:Connect(function()workspace:SetAttribute(AudioConfig.Attributes.Muted,not workspace:GetAttribute(AudioConfig.Attributes.Muted))end)
	local hint = Instance.new("TextLabel"); hint.Size = UDim2.new(1, 0, 0, 44); hint.BackgroundTransparency = 1
	hint.TextColor3 = Colors.Muted; hint.TextWrapped = true; hint.Font = Enum.Font.Gotham; hint.TextSize = 13; hint.Parent = frame
	local function refresh()
		quality.Text = T("VFX quality") .. ": " .. T(if workspace:GetAttribute(Config.QualityAttribute) == "Low" then "Low" else "Auto")
		motion.Text = T("Idle motion") .. ": " .. T(if workspace:GetAttribute(Config.ReducedMotionAttribute) then "Reduced" else "Full")
		mute.Text=T("Audio")..": "..T(if workspace:GetAttribute(AudioConfig.Attributes.Muted) then "Muted" else "On")
		local labels={Master="Audio volume",UI="UI sounds",Combat="Combat sounds",Music="Music volume"}
		for key,b in pairs(volumeButtons) do b.Text=T(labels[key])..": "..math.floor(Audio.Level(key)*100+.5).."%" end
		hint.Text = T("Sound and visual settings apply to this session. Enemy warnings remain visible.")
	end
	quality.Activated:Connect(function() workspace:SetAttribute(Config.QualityAttribute, if workspace:GetAttribute(Config.QualityAttribute) == "Low" then "Auto" else "Low") end)
	motion.Activated:Connect(function() workspace:SetAttribute(Config.ReducedMotionAttribute, not workspace:GetAttribute(Config.ReducedMotionAttribute)) end)
	local qualityChanged = workspace:GetAttributeChangedSignal(Config.QualityAttribute):Connect(refresh)
	local motionChanged = workspace:GetAttributeChangedSignal(Config.ReducedMotionAttribute):Connect(refresh)
	local audioChanged: {RBXScriptConnection}={}
	for _,attribute in pairs(AudioConfig.Attributes) do table.insert(audioChanged,workspace:GetAttributeChangedSignal(attribute):Connect(refresh)) end
	frame.Destroying:Connect(function() qualityChanged:Disconnect(); motionChanged:Disconnect();for _,c in ipairs(audioChanged) do c:Disconnect() end end)
	refresh()
	return {frame = frame, refresh = refresh}
end
