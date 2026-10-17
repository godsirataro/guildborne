--!strict
-- Read visible UI as well as router state: separate module copies may close a
-- map without owning the still-visible management menu's registry entry.
local Gate = {}
function Gate.blocked(playerGui: Instance, routerBlocking: boolean): boolean
	if routerBlocking or playerGui:GetAttribute("GuildborneMenuOpen") == true then return true end
	local main = playerGui:FindFirstChild("GuildborneUI")
	local management = main and main:FindFirstChild("ManagementPanel")
	return main ~= nil and main:IsA("ScreenGui") and main.Enabled
		and management ~= nil and management:IsA("GuiObject") and management.Visible
end
function Gate.toggleMap(panel: GuiObject, playerGui: Instance, routerBlocking: boolean): boolean
	-- Closing our own map must remain possible even while another menu blocks.
	if panel.Visible then panel.Visible = false; return true end
	if Gate.blocked(playerGui, routerBlocking) then return false end
	panel.Visible = true; return true
end
return Gate
