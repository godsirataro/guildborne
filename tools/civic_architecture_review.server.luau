-- Isolated six-city architecture fixture; no gameplay profile or paid APIs.
local kits=script.Parent.Services
local cities={"Crownford","Sylvaris","Deepforge","Astralis","Crosshaven","Ironroot"}
local origins={}
local districts=require(kits.CivicDistrictKit)(require(kits.CivicLandmarkKit));districts.Parent=workspace
for index,name in ipairs(cities)do
 local city=assert(districts:FindFirstChild(name)) :: Model;local x=(index-1)*400;city:PivotTo(CFrame.new(x,0,0));origins[name]={}
 for _,service in ipairs({"Market","Forge","Tavern","QuestHall"})do origins[name][service]=(city:FindFirstChild(service) :: BasePart).Position+Vector3.new(0,1,30)end
 for _,v in ipairs(city:GetDescendants())do if v:IsA("BillboardGui")then v:Destroy()end end
end
local spawn=Instance.new("SpawnLocation");spawn.Name="ArchitectureReviewSpawn";spawn.Size=Vector3.new(2,1,2);spawn.CFrame=CFrame.new(-58,.5,58);spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0;spawn.Transparency=1;spawn.CanCollide=false;spawn.Parent=workspace
local lighting=game:GetService("Lighting");lighting.ClockTime=14;lighting.Brightness=2;lighting.Ambient=Color3.fromRGB(145,145,145)
local remote=Instance.new("RemoteEvent");remote.Name="ArchitectureReviewDestination";remote.Parent=game.ReplicatedStorage
local last={}
remote.OnServerEvent:Connect(function(player,name,service)
 service=service or "Market"
 if type(name)~="string"or not origins[name]or type(service)~="string"or not origins[name][service]then return end
 local now=os.clock();if last[player]and now-last[player]<.5 then return end;last[player]=now
 local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart")
 if c and root and root:IsA("BasePart")then
  c:PivotTo(CFrame.new(origins[name][service]));root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
  player:SetAttribute("ArchitectureReviewCity",name);player:SetAttribute("ArchitectureReviewService",service);remote:FireClient(player,name,origins[name][service],service)
 end
end)
game.Players.PlayerRemoving:Connect(function(player)last[player]=nil end)
