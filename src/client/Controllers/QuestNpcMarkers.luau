--!strict
local Collection=game:GetService("CollectionService")
local Players=game:GetService("Players")
local Shared=game:GetService("ReplicatedStorage").Shared
local project=require(Shared.Data.QuestNpcState)
local Locale=require(Shared.Config.Localization)
return function()
	local markers: {[Instance]: BillboardGui}={};local snapshot: any=nil
	local function refresh(anchor: Instance,gui: BillboardGui)
		local name=anchor:GetAttribute("QuestNPC")
		local state=if snapshot and snapshot.status=="Active" and type(name)=="string" then project(snapshot.data,snapshot.catalog,name) else nil
		gui.Enabled=state~=nil
		if not state then return end
		local label=gui:FindFirstChild("State") :: TextLabel
		label.Text=state.symbol.."  "..Locale.translate(snapshot.data.language or "en",state.state)
		label.TextColor3=if state.priority==3 then Color3.fromRGB(121,225,175) elseif state.priority==2 then Color3.fromRGB(255,213,111) else Color3.fromRGB(206,218,235)
		gui:SetAttribute("QuestId",state.id);gui:SetAttribute("QuestState",state.state)
	end
	local function add(anchor: Instance)
		if not anchor:IsA("BasePart") or markers[anchor] then return end
		local gui=Instance.new("BillboardGui");gui.Name="QuestNPCMarker";gui.Adornee=anchor;gui.ResetOnSpawn=false
		gui.Size=UDim2.fromOffset(210,32);gui.StudsOffsetWorldSpace=Vector3.new(0,7.2,0);gui.MaxDistance=70;gui.AlwaysOnTop=false;gui.Enabled=false
		local label=Instance.new("TextLabel");label.Name="State";label.Size=UDim2.fromScale(1,1);label.BackgroundColor3=Color3.fromRGB(25,32,45)
		label.BackgroundTransparency=.15;label.BorderSizePixel=0;label.Font=Enum.Font.GothamBold;label.TextSize=16;label.TextWrapped=true;label.Parent=gui
		local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,6);corner.Parent=label
		gui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui");markers[anchor]=gui;refresh(anchor,gui)
	end
	local function remove(anchor: Instance) local gui=markers[anchor];if gui then gui:Destroy();markers[anchor]=nil end end
	local added=Collection:GetInstanceAddedSignal("GuildborneQuestNPC"):Connect(add)
	local removed=Collection:GetInstanceRemovedSignal("GuildborneQuestNPC"):Connect(remove)
	for _,anchor in ipairs(Collection:GetTagged("GuildborneQuestNPC")) do add(anchor) end
	return {
		Update=function(view: any) snapshot=view;for anchor,gui in pairs(markers) do refresh(anchor,gui) end end,
		Destroy=function() added:Disconnect();removed:Disconnect();for anchor in pairs(markers) do remove(anchor) end end,
	}
end
