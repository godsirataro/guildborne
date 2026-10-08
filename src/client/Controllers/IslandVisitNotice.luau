--!strict
local Players=game:GetService("Players")
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local Colors=require(game.ReplicatedStorage.Shared.Config.Art).UI
local Audio=require(script.Parent.AudioController)
return function()
    local player=Players.LocalPlayer;local language="en"
    local gui=Instance.new("ScreenGui");gui.Name="IslandVisitNotice";gui.ResetOnSpawn=false;gui.DisplayOrder=50
    gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=player:WaitForChild("PlayerGui")
    local label=Instance.new("TextLabel");label.AnchorPoint=Vector2.new(.5,0);label.Position=UDim2.new(.5,0,0,64)
    label.Size=UDim2.new(.9,0,0,64);label.BackgroundColor3=Colors.Background;label.TextColor3=Colors.Text
    label.Font=Enum.Font.GothamMedium;label.TextSize=16;label.TextWrapped=true;label.Visible=false;label.Parent=gui
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=label
    local messages={IslandPrivate="This island is private.",FriendsOnly="This island welcomes the owner's friends only.",IslandFull="This island has reached its visitor limit.",
        IslandUnavailable="This island is temporarily unavailable.",IslandChanged="Island access changed. You returned to your guild.",OwnerLeft="The island owner left. You returned to your guild.",
        VisitBlocked="The owner has ended your visit.",IslandAccessDenied="Use the island bridge sign to request a visit.",VisitStation="Move closer to the island bridge sign.",
        VisitBusy="Please wait before requesting another island visit.",FriendshipUnavailable="Friendship could not be checked. Please try again.",
        TravelUnavailable="The arrival area is blocked. Please try again later.",VisitStarted="Island entry complete.",ReturnToGuild="Leave combat and the Tower before visiting.",ActorNotReady="Your character is not ready to travel."}
    local notice=player:GetAttributeChangedSignal("IslandVisitNoticeAt"):Connect(function()
        local stamp=player:GetAttribute("IslandVisitNoticeAt");local code=player:GetAttribute("IslandVisitProblem")
		Audio.Play("notification")
        label.Text=Locale.translate(language,messages[tostring(code)] or "This island is temporarily unavailable.");label.Visible=true
        task.delay(4,function()if gui.Parent and player:GetAttribute("IslandVisitNoticeAt")==stamp then label.Visible=false end end)
    end)
    local state=(game.ReplicatedStorage:WaitForChild("GuildborneRemotes"):WaitForChild("State") :: RemoteEvent).OnClientEvent:Connect(function(view)
        if view.data then language=view.data.language or "en" end
    end)
    gui.Destroying:Connect(function()notice:Disconnect();state:Disconnect()end)
end
