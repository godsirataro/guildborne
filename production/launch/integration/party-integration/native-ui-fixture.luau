-- Actual SliceUI with synthetic Party states; no mutation requests or profile writes.
-- Stop Play after this fixture to clear constructor input listeners.
assert(game.PlaceId==0 and game.GameId==0)
local p=game.Players.LocalPlayer;local pg=p.PlayerGui
local remotes=game.ReplicatedStorage.GuildborneRemotes
local snapshot
local connection=remotes.State.OnClientEvent:Connect(function(v)if v.data then snapshot=v end end)
remotes.Command:FireServer({version=1,requestId="party-ui-read",revision=0,action="GetState",args={}})
local deadline=os.clock()+8;while not snapshot and os.clock()<deadline do task.wait(.05)end
connection:Disconnect();assert(snapshot,"No live read-only snapshot")
local old={};for _,x in pg:GetChildren()do if x:IsA("ScreenGui")and x.Name=="GuildborneUI"then old[x]=x.Enabled;x.Enabled=false end end
local calls={}
local ui=require(p.PlayerScripts.Client.UI.SliceUI)(function(action,args)table.insert(calls,{action=action,args=args})end)
local gui;for _,x in pg:GetChildren()do if x.Name=="GuildborneUI"and old[x]==nil then gui=x end end
assert(gui);gui.Name="HumanPartyNativeFixture"
local function clone(x)if type(x)~="table"then return x end;local y={};for k,v in pairs(x)do y[k]=clone(v)end;return y end
local cases={};local ok,result=pcall(function()
 for _,language in ipairs({"en","th"})do
  local view=clone(snapshot);view.data.language=language;view.navigate="HumanParty"
  view.humanParty={available=true,revision=1,capacity=6,localUserId=tostring(p.UserId),members={},incomingInvites={},outgoingInvites={},directory={{userId="200",displayName="<b>Friend</b>",username="friend",heroCount=5,available=true}}}
  ui.Update(view)
  assert(gui:FindFirstChild("HumanPartyPanel",true))
  assert(not gui:FindFirstChild("HumanPartyAccept_fixture",true))
  local changed=clone(view);changed.navigate=nil;changed.humanParty.revision=2
  changed.humanParty.incomingInvites={{inviteId="fixture",fromUserId="200",targetUserId=tostring(p.UserId),expiresAt=changed.serverTime+60}}
  ui.Update(changed) -- no message, same persistent revision, no navigation
  local accept=assert(gui:FindFirstChild("HumanPartyAccept_fixture",true));assert(accept.Active,"Same-revision invitation not rendered")
  local full=clone(changed);full.humanParty.revision=3;full.humanParty.incomingInvites={};full.humanParty.partyId="fixture-party";full.humanParty.leaderUserId=tostring(p.UserId)
  for i=1,6 do table.insert(full.humanParty.members,{userId=if i==1 then tostring(p.UserId)else tostring(200+i),displayName="<b>Member"..i.."</b>",username="member"..i,heroCount=5,connectionState=if i==6 then "Reconnecting"else "Connected",ready=false})end
  ui.Update(full)
  assert(not gui:FindFirstChild("HumanPartyInvite_200",true).Active,"Full Party invites enabled")
  assert(gui:FindFirstChild("HumanPartyKick_206",true).Active,"Grace member cannot be removed")
  local panel=gui.ManagementPanel
  for _,width in ipairs({360,640})do
   panel.Size=UDim2.fromOffset(width,650);task.wait(.15)
   local checked=0
   for _,node in ipairs(panel.Content:GetDescendants())do
    if node:IsA("TextButton")then
     assert(node.TextBounds.X<=node.AbsoluteSize.X+1 and node.TextBounds.Y<=node.AbsoluteSize.Y+1,"Button clipped: "..node.Text);checked+=1
    elseif node:IsA("TextLabel")and node.Text:find("<b>",1,true)then assert(not node.RichText,"Player markup interpreted")end
   end
   table.insert(cases,{language=language,width=width,buttonsChecked=checked,sameProfileRevision=true,partyMembers=6})
  end
 end
 assert(#calls==0,"Fixture sent mutation callback")
 return {synthetic=true,actualSliceUI=true,noProfileWrites=true,mutationCalls=#calls,cases=cases}
end)
gui:Destroy();for oldGui,enabled in pairs(old)do oldGui.Enabled=enabled end
assert(ok,tostring(result));return result
