--!strict
-- Exploration districts unlocked by earned envoy charters; services remain in Central City.
local Shared=game.ReplicatedStorage.Shared
local Civic=require(Shared.Config.CivicCities)
local City=require(Shared.Config.City)
local Locale=require(Shared.Config.Localization)
local Content=require(script.Parent.Parent.Config.Content)
local Kit=require(script.Parent.ArtKit)
local V=Vector3.new
return function(parent:Instance,town:Instance,intent:any,open:any):any
 local districts=require(script.Parent.CivicDistrictKit)(require(script.Parent.CivicLandmarkKit))
 local regions={};local portals={};local guildPortals={}
 local cast=require(script.Parent.CityCharacterKit)(true)
 local castOrder={"marshal_elian","arborist_vaela","smith_borin","cartographer_nyra","harbormaster_sela","steward_roka"}
 local speakers=require(Shared.Config.FriendlyNpcs)
 local function gate(container:Instance,name:string,pos:Vector3,destination:string,detail:string?):BasePart
  local p=Kit.Part(container,name,V(5,6,.3),pos,Color3.fromRGB(119,186,205),Enum.Material.Neon,false)
  p.Transparency=.65;p.CanQuery=false;p.CanTouch=false;p:SetAttribute("TravelDestination",destination)
  game:GetService("CollectionService"):AddTag(p,"GuildborneTravelPortal")
  local label=Kit.Label(p,name,Locale.translate("th",name),5)
  if detail then label.Text=name.." · "..Locale.translate("th",name).."\n"..detail.."\n"..Locale.translate("th",detail);(label.Parent :: BillboardGui).Size=UDim2.fromOffset(240,82)end
  local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Travel / เดินทาง";prompt.ObjectText=Locale.translate("th",name).." / "..name;prompt.RequiresLineOfSight=false;prompt.MaxActivationDistance=10;prompt.Parent=p
  prompt.Triggered:Connect(function(player)
   local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart")
   if root and root:IsA("BasePart")and(root.Position-p.Position).Magnitude<=14 then intent(player,"TravelZone",{zone=destination})end
  end)
  table.insert(portals,p);return p
 end
 for index,id in ipairs(Civic.Order)do
  local d=(Civic.Definitions :: any)[id];local model=districts:FindFirstChild(id) :: Model
  model.Parent=parent;model:PivotTo(CFrame.new(d.X,0,d.Z));model:SetAttribute("ReviewOnly",nil);model:SetAttribute("CivicExploration",true)
  for _,v in ipairs(model:GetDescendants())do if v:IsA("BillboardGui")then v:Destroy()end end
  local entry=gate(town,id,V((index-3.5)*70,4,-644),id,Content.Journal[d.Quest].Name)
  local exit=gate(model,"Central City",V(d.X-58,4,d.Z+88),"City")
  local guild=gate(model,"Guild Zone Warp",V(d.X+58,4,d.Z+88),"Guild");table.insert(guildPortals,guild)
  local visit=Instance.new("ProximityPrompt");visit.ActionText="Visit islands / เยี่ยมเกาะ";visit.ObjectText="Guild islands / เกาะกิลด์";visit.KeyboardKeyCode=Enum.KeyCode.R;visit.GamepadKeyCode=Enum.KeyCode.ButtonY;visit.MaxActivationDistance=10;visit.RequiresLineOfSight=false;visit.Parent=guild
  visit.Triggered:Connect(function(player)local c=player.Character;if c and(c:GetPivot().Position-guild.Position).Magnitude<=14 then open(player,"Islands")end end)
  for _,name in ipairs({"Market","Forge","Tavern","QuestHall"})do
   local marker=model:FindFirstChild(name) :: BasePart
   if marker then
    if name=="Market"or name=="Tavern"then
     Kit.Label(marker,if name=="Market"then "Guildborne Exchange"else "Tavern",if name=="Market"then "ตลาดแลกเปลี่ยนกิลด์บอร์น"else "โรงเตี๊ยม",3)
     marker:SetAttribute("CivicService",name)
     local service=Instance.new("ProximityPrompt");service.Name="OpenCivicService";service.ActionText=if name=="Market"then "Open market / เปิดตลาด"else "Recruitment / รับสมัคร";service.ObjectText=id.." · "..name;service.KeyboardKeyCode=Enum.KeyCode.R;service.GamepadKeyCode=Enum.KeyCode.ButtonY;service.RequiresLineOfSight=false;service.MaxActivationDistance=10;service.Parent=marker
     service.Triggered:Connect(function(player)local c=player.Character;if c and(c:GetPivot().Position-marker.Position).Magnitude<=14 then open(player,name)end end)
    else Kit.Label(marker,name.." · Guild island workshop",Locale.translate("th",name).." · ใช้โรงงานที่เกาะกิลด์",3)end
   end
  end
  local arrival=model:FindFirstChild("Arrival") :: BasePart
  Kit.Label(arrival,id.." · Safe zone",d.Thai.." · เขตปลอดภัย",4)
  local hostId="host_"..string.lower(id);local speaker=speakers[hostId]
  local host=cast:FindFirstChild(castOrder[index]) :: Model;host.Name=hostId;host.Parent=model
  host:PivotTo(CFrame.lookAt(V(speaker.x,0,speaker.z),V(d.X,0,d.Z+108)))
  host:SetAttribute("NpcId",hostId);host:SetAttribute("WorkMotionIdentity",castOrder[index]);host:SetAttribute("CivicHost",id)
  local root=assert(host.PrimaryPart);Kit.Label(root,speaker.name,speaker.nameTh,6)
  local talk=Instance.new("ProximityPrompt");talk.ActionText="Talk / พูดคุย";talk.ObjectText=speaker.name.." / "..speaker.nameTh;talk.MaxActivationDistance=10;talk.RequiresLineOfSight=false;talk.Parent=root
  talk.Triggered:Connect(function(player)local c=player.Character;if c and(c:GetPivot().Position-root.Position).Magnitude<=14 then host:SetAttribute("GreetingAt",workspace:GetServerTimeNow());open(player,"FriendlyNPC:"..hostId)end end)
  game:GetService("CollectionService"):AddTag(host,"GuildborneFriendlyNPC")
  local spawn=Instance.new("SpawnLocation");spawn.Name=(City.Destinations :: any)[id].Spawn;spawn.Position=V(d.X,.5,d.Z+108);spawn.Size=V(6,1,6);spawn.Anchored=true;spawn.Transparency=1;spawn.CanCollide=false;spawn.CanQuery=false;spawn.CanTouch=false;spawn.Enabled=false;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=model
  regions[id]={model=model,spawn=spawn,entry=entry,exit=exit,guild=guild}
 end
 districts:Destroy();cast:Destroy();return {regions=regions,portals=portals,guildPortals=guildPortals}
end
