--!strict
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0)
local player=game.Players.LocalPlayer
local client=player:WaitForChild("PlayerScripts"):WaitForChild("Client")
assert(client:WaitForChild("ClientBootstrap").Disabled,"Normal bootstrap must be disabled")
local lab=workspace:WaitForChild("PartyPresentationLab",60)
assert(lab and lab:GetAttribute("Synthetic")==true and lab:GetAttribute("OwnerUserId")==player.UserId)
local deadline=os.clock()+60
repeat task.wait(.1) until lab:GetAttribute("Ready")==true or os.clock()>deadline
assert(lab:GetAttribute("Ready")==true,"Synthetic lab failed to become ready")
assert(lab:GetAttribute("PlayerOnlyCombatProbe")==true and lab:GetAttribute("CompanionCount")==0,"Player-only fixture required")
for _,v in ipairs(workspace:GetDescendants()) do
 if v:IsA("Model") then assert(v:GetAttribute("GuildborneHero")~=true,"Companion present in player-only fixture") end
end
local gui=Instance.new("ScreenGui");gui.Name="PartyPresentationWarning";gui.ResetOnSpawn=false;gui.DisplayOrder=100;gui.Parent=player.PlayerGui
local banner=Instance.new("TextLabel");banner.Size=UDim2.new(1,0,0,28);banner.BackgroundColor3=Color3.fromRGB(67,29,20)
banner.TextColor3=Color3.new(1,1,1);banner.TextSize=14;banner.Text="PLAYER-ONLY LOCAL PROBE • No companion AI • No earned progress or rewards • Stop Play to discard";banner.Parent=gui
local handles:{any}={};local stopped=false
local audio:any=nil
local function cleanup()
 if stopped then return end;stopped=true
 for _,h in ipairs(handles)do if type(h)=="table" and type(h.Destroy)=="function" then pcall(h.Destroy)end end
 if audio then pcall(audio.Destroy)end
 gui:Destroy()
end
script.Destroying:Connect(cleanup)
lab:GetAttributeChangedSignal("Ready"):Connect(function()if lab:GetAttribute("Ready")~=true then cleanup()end end)
local ok,problem=xpcall(function()
 local c=client.Controllers
 audio=require(c.AudioController)
 audio.Start()
 table.insert(handles,require(c.HeroAnimator)())
 table.insert(handles,require(c.EnemyAnimator)())
 table.insert(handles,require(c.CombatController)())
 table.insert(handles,require(c.PlayerCombatController)())
 table.insert(handles,require(c.FriendlyNpcAnimator)())
 local ready=game.ReplicatedStorage.GuildborneRemotes.LabReady :: RemoteEvent
 ready:FireServer()
end,debug.traceback)
if not ok then cleanup();warn(problem)end
