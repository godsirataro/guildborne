--!strict
local Actions = game:GetService("ContextActionService")
local Input = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- A Title-only input entry point. MenuRouter still owns selection and traversal.
local TitleKeyboardFocus = {}
function TitleKeyboardFocus.bind(root: Frame, screen: ScreenGui, focusCurrent: () -> ())
	local action = "GuildborneTitleKeyboardFocus"
	local bound, destroyed = false, false
	local connections: {RBXScriptConnection} = {}
	local function active(): boolean
		return not destroyed and root.Parent ~= nil and screen.Parent ~= nil and root.Visible and screen.Enabled
	end
	local function refresh()
		if active() and not bound then
			Actions:BindActionAtPriority(action, function(_, state: Enum.UserInputState)
				if not active() or Input:GetFocusedTextBox() or GuiService.MenuIsOpen then
					return Enum.ContextActionResult.Pass
				end
				if state == Enum.UserInputState.Begin then focusCurrent() end
				return Enum.ContextActionResult.Sink
			end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Tab)
			bound = true
		elseif not active() and bound then
			Actions:UnbindAction(action); bound = false
		end
	end
	local function destroy()
		if destroyed then return end
		destroyed = true; refresh()
		for _, connection in ipairs(connections) do connection:Disconnect() end
		table.clear(connections)
	end
	table.insert(connections, root:GetPropertyChangedSignal("Visible"):Connect(refresh))
	table.insert(connections, screen:GetPropertyChangedSignal("Enabled"):Connect(refresh))
	table.insert(connections, root.AncestryChanged:Connect(refresh))
	table.insert(connections, screen.AncestryChanged:Connect(refresh))
	table.insert(connections, root.Destroying:Connect(destroy))
	table.insert(connections, screen.Destroying:Connect(destroy))
	refresh()
	return {destroy = destroy}
end
return TitleKeyboardFocus
