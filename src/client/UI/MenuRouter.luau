--!strict
-- One client focus owner for native menus; no gameplay or persistence authority.
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local Input = game:GetService("UserInputService")
local Audio=require(script.Parent.Parent.Controllers.AudioController)
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
type Entry = { frame: GuiObject, pinned: boolean, lastSelection: GuiObject? }
local entries: {[string]: Entry} = {}
local updating = false
local Router = {}
local keyboardNavigation=Input:GetLastInputType().Name:sub(1,7)=="Gamepad"
local focusQueued=false
local function shown(object: GuiObject): boolean
	if not object.Parent then return false end
	local cursor: Instance?=object
	while cursor and cursor~=playerGui do
		if cursor:IsA("GuiObject") and not cursor.Visible then return false end
		if cursor:IsA("ScreenGui") and not cursor.Enabled then return false end
		cursor=cursor.Parent
	end
	return cursor==playerGui
end
local function visible(object: GuiObject): boolean return object.Active and object.Selectable and shown(object) end
local function current(): Entry?
	for _,entry in pairs(entries) do if shown(entry.frame) then return entry end end
	return nil
end
local function focus()
	if not keyboardNavigation or GuiService.MenuIsOpen then return end
	local entry=current()
	if not entry then return end
	local selected=GuiService.SelectedObject
	if selected and selected:IsDescendantOf(entry.frame) and visible(selected) then return end
	if entry.lastSelection and entry.lastSelection:IsDescendantOf(entry.frame) and visible(entry.lastSelection) then
		GuiService.SelectedObject=entry.lastSelection;return
	end
	for _,child in ipairs(entry.frame:GetDescendants()) do
		if child:IsA("GuiObject") and visible(child) then GuiService.SelectedObject=child;return end
	end
	GuiService.SelectedObject=nil
end
local function queueFocus()
	if focusQueued then return end;focusQueued=true
	task.defer(function() focusQueued=false;focus() end)
end
function Router.focusCurrent()
	keyboardNavigation=true;focus()
end
function Router.isBlocking(): boolean
	if playerGui:FindFirstChild("GuildborneBuildMode") then return true end
	for _, entry in pairs(entries) do if shown(entry.frame) then return true end end
	return false
end
local lastFrame:GuiObject?=nil
local function refresh(silent:any?)
	local blocked = Router.isBlocking()
	playerGui:SetAttribute("GuildborneMenuOpen", blocked)
	GuiService.TouchControlsEnabled = not blocked
	local entry=current();local frame=if entry then entry.frame else nil
	if frame~=lastFrame and silent~=true then Audio.Play(if frame then "modal_open" else "back") end
	lastFrame=frame
end
function Router.register(id: string, frame: GuiObject, pinned: boolean?)
	assert(entries[id] == nil, "Duplicate menu registration: " .. id)
	entries[id] = {frame = frame, pinned = pinned == true, lastSelection=nil}
	local registered=false
	local function changed()
		if updating then return end
		updating = true
		if frame.Visible then
			local denied = playerGui:FindFirstChild("GuildborneBuildMode") ~= nil
			for otherId, entry in pairs(entries) do
				if otherId ~= id and entry.pinned and entry.frame.Visible then denied = true end
			end
			if denied then frame.Visible = false
			else
				for otherId, entry in pairs(entries) do if otherId ~= id then entry.frame.Visible = false end end
			end
		end
		local selected=GuiService.SelectedObject
		if not frame.Visible and selected and selected:IsDescendantOf(frame) then GuiService.SelectedObject=nil end
		updating = false; refresh(not registered);queueFocus()
	end
	frame:GetPropertyChangedSignal("Visible"):Connect(changed)
	local candidates: {[Instance]: {RBXScriptConnection}}={}
	local function unwatch(child: Instance)
		local connections=candidates[child]
		if connections then for _,connection in ipairs(connections) do connection:Disconnect() end;candidates[child]=nil end
		queueFocus()
	end
	local function watch(child: Instance)
		if not candidates[child] and (child:IsA("GuiButton") or child:IsA("TextBox")) then
			local connections={child.AncestryChanged:Connect(queueFocus)}
			for _,property in ipairs({"Active","Selectable","Visible"}) do table.insert(connections,child:GetPropertyChangedSignal(property):Connect(queueFocus)) end
			candidates[child]=connections
		end
		queueFocus()
	end
	for _,child in ipairs(frame:GetDescendants()) do watch(child) end
	frame.DescendantAdded:Connect(watch)
	frame.DescendantRemoving:Connect(unwatch)
	frame.Destroying:Connect(function()
		for _,connections in pairs(candidates) do for _,connection in ipairs(connections) do connection:Disconnect() end end
		table.clear(candidates);entries[id] = nil; refresh();queueFocus()
	end)
	changed();registered=true
end
function Router.closeAll()
	for _, entry in pairs(entries) do if not entry.pinned then entry.frame.Visible = false end end
	refresh()
end
playerGui.ChildAdded:Connect(refresh); playerGui.ChildRemoved:Connect(refresh)
player.CharacterRemoving:Connect(function() task.defer(Router.closeAll) end)
local selectionConnections: {RBXScriptConnection}={}
GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
	for _,connection in ipairs(selectionConnections) do connection:Disconnect() end;table.clear(selectionConnections)
	local selected=GuiService.SelectedObject
	if selected then for _,entry in pairs(entries) do
		if selected:IsDescendantOf(entry.frame) and visible(selected) then entry.lastSelection=selected end
	end end
	if selected and selected:IsDescendantOf(playerGui) then
		for _,property in ipairs({"Active","Selectable"}) do table.insert(selectionConnections,selected:GetPropertyChangedSignal(property):Connect(queueFocus)) end
		table.insert(selectionConnections,selected.AncestryChanged:Connect(queueFocus))
		local cursor: Instance?=selected
		while cursor and cursor~=playerGui do
			if cursor:IsA("GuiObject") then table.insert(selectionConnections,cursor:GetPropertyChangedSignal("Visible"):Connect(queueFocus))
			elseif cursor:IsA("ScreenGui") then table.insert(selectionConnections,cursor:GetPropertyChangedSignal("Enabled"):Connect(queueFocus)) end
			cursor=cursor.Parent
		end
	end
	-- A destroyed control is replaced after the coalesced render finishes.
	if not selected then queueFocus() end
end)
Input.LastInputTypeChanged:Connect(function(kind: Enum.UserInputType)
	if kind.Name:sub(1,7)=="Gamepad" then keyboardNavigation=true;queueFocus()
	elseif kind==Enum.UserInputType.Touch or kind.Name:sub(1,5)=="Mouse" then
		keyboardNavigation=false
		local selected=GuiService.SelectedObject
		if selected then for _,entry in pairs(entries) do if selected:IsDescendantOf(entry.frame) then GuiService.SelectedObject=nil;break end end end
	end
end)
Input.InputBegan:Connect(function(input: InputObject,processed: boolean)
	if processed or Input:GetFocusedTextBox() or GuiService.MenuIsOpen then return end
	if input.KeyCode==Enum.KeyCode.Tab and current() then Router.focusCurrent()
	elseif input.KeyCode==Enum.KeyCode.ButtonB then Router.closeAll() end
end)
return Router
