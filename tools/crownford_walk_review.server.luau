-- Isolated architecture fixture. No gameplay profile or commerce systems.
local kits=script.Parent.Services
local districts=require(kits.CivicDistrictKit)(require(kits.CivicLandmarkKit))
local city=assert(districts:FindFirstChild("Crownford"));city.Parent=workspace;districts:Destroy()
for _,v in ipairs(city:GetDescendants())do if v:IsA("BillboardGui")then v:Destroy()end end
local spawn=Instance.new("SpawnLocation");spawn.Name="ArchitectureReviewSpawn";spawn.Size=Vector3.new(2,1,2);spawn.CFrame=CFrame.new(-58,.5,58);spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0;spawn.Transparency=1;spawn.CanCollide=false;spawn.Parent=workspace
local lighting=game:GetService("Lighting");lighting.ClockTime=14;lighting.Brightness=2;lighting.Ambient=Color3.fromRGB(145,145,145)
game:GetService("Players").PlayerAdded:Connect(function(player)
 local gui=Instance.new("ScreenGui");gui.Name="ArchitectureReview";gui.ResetOnSpawn=false
 local label=Instance.new("TextLabel");label.Size=UDim2.new(1,0,0,46);label.BackgroundColor3=Color3.fromRGB(23,35,47);label.TextColor3=Color3.new(1,1,1);label.TextSize=14;label.Font=Enum.Font.Gotham;label.TextWrapped=true;label.Text="Crownford architecture walk review · WASD / mouse · Market ahead; Tavern behind it · no gameplay profile";label.Parent=gui;gui.Parent=player:WaitForChild("PlayerGui")
end)
