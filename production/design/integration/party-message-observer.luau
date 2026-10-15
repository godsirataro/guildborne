local messages=game.HttpService:JSONDecode([==[{"HumanPartyStale":"Party membership changed. Review the updated list and try again.","HumanPartyFull":"This party already has 6 players. Join another party or continue solo.","HumanPartyLeaderRequired":"Only the party leader can do that. Ask your leader to help.","HumanPartyAlreadyMember":"One of these players is already in a party. Review the party list.","HumanPartyInvitePending":"An invitation is already waiting for this player. Wait for their response.","HumanPartyInviteLimit":"Too many invitations are waiting. Wait for a response or let an invitation expire.","HumanPartyInviteExpired":"This invitation is no longer available. Ask for a new invitation.","HumanPartyNotMember":"That party membership is no longer current. Review the updated member list.","HumanPartyUnavailable":"That player or party action is temporarily unavailable. Wait a moment and try again."}]==])
local L=require(game.ReplicatedStorage.Shared.Config.Localization)
local result={samples={}};_G.GuildbornePartyRender=result
result.connection=game.ReplicatedStorage.GuildborneRemotes.State.OnClientEvent:Connect(function(view)
 if not messages[view.code]then return end
 task.defer(function()
  local expected=L.translate(view.data.language,messages[view.code]);local labels={}
  for _,label in ipairs(game.Players.LocalPlayer.PlayerGui:GetDescendants())do
   if label:IsA("TextLabel")and string.find(label.Text,expected,1,true)then
    local visible=label.Visible;local parent=label.Parent
    while parent do if parent:IsA("GuiObject")and not parent.Visible then visible=false end;parent=parent.Parent end
    table.insert(labels,{path=label:GetFullName(),visible=visible,text=label.Text,textFits=label.TextFits,bounds={label.TextBounds.X,label.TextBounds.Y},size={label.AbsoluteSize.X,label.AbsoluteSize.Y}})
   end
  end
  table.insert(result.samples,{code=view.code,language=view.data.language,labels=labels})
 end)
end)
return "Ready"
