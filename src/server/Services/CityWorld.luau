--!strict
local V=Vector3.new
local Kit=require(script.Parent.ArtKit)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local Content=require(script.Parent.Parent.Config.Content)
local IslandLayout=require(game.ReplicatedStorage.Shared.Config.GuildIslandLayout)
return function(parent: Instance,templates: Folder,open: any,intent: any)
	local S:any={};local town=Instance.new("Folder");town.Name="City";town.Parent=parent
	local guild=Instance.new("Folder");guild.Name="GuildZone";guild.Parent=parent
	local function part(folder: Instance,name: string,size: Vector3,pos: Vector3,color: Color3): Part
		return Kit.Part(folder,name,size,pos,color,Enum.Material.SmoothPlastic,true)
	end
	local function prompt(anchor: BasePart,title: string,callback: any)
		local p=Instance.new("ProximityPrompt");p.ActionText=title.." / "..Locale.translate("th",title);p.ObjectText=anchor.Name;p.MaxActivationDistance=10;p.RequiresLineOfSight=false;p.Parent=anchor
		if title=="Talk" and anchor.Parent then p.ObjectText=anchor.Parent.Name end
		-- Companion inspection uses E; the Exchange keeps its own visible activation key.
		if title=="Open market" or title=="Visit islands" then p.KeyboardKeyCode=Enum.KeyCode.R;p.GamepadKeyCode=Enum.KeyCode.ButtonY end
		p.Triggered:Connect(function(player) local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root and root:IsA("BasePart") and (root.Position-anchor.Position).Magnitude<=14 then callback(player) end end)
	end
	local function portal(folder: Instance,name: string,pos: Vector3,color: Color3,destination: string): Part
		for _,x in ipairs({-5,5}) do part(folder,"PortalPillar",V(1,12,2),pos+V(x,1,0),Color3.fromRGB(94,104,119)) end
		part(folder,"PortalArch",V(11,1,2),pos+V(0,7,0),Color3.fromRGB(215,181,94))
		local p=part(folder,name,V(9,11,.4),pos,color);p.Material=Enum.Material.Neon;p.Transparency=.78;p.CanCollide=false
		p:SetAttribute("TravelDestination",destination)
		game:GetService("CollectionService"):AddTag(p,"GuildborneTravelPortal")
		Kit.Label(p,name,Locale.translate("th",name),7)
		prompt(p,"Travel",function(player) intent(player,"TravelZone",{zone=destination}) end);return p
	end
	local central=require(script.Parent.CentralCityWorld)(town,templates,open,prompt)
	S.town=town;S.npcs=central.npcs
	S.cityPortal=portal(town,"Guild Zone Warp",V(0,6,-680),Color3.fromRGB(121,163,244),"Guild")
	S.cityPortal:SetAttribute("CityReturnStop","Arrival")
	S.guildPortal=portal(guild,"Central City",V(-44,6,-65),Color3.fromRGB(121,163,244),"City")
	prompt(S.cityPortal,"Visit islands",function(player)open(player,"Islands")end)
	prompt(S.guildPortal,"Visit islands",function(player)open(player,"Islands")end)
 S.guildAccessPortals={S.cityPortal,S.guildPortal}
 local nav=require(game.ReplicatedStorage.Shared.Config.City)
 for _,id in ipairs(nav.GuildPortalOrder)do
  local stop=nav.GuildPortalStops[id]
  local gate=portal(town,stop.Name,V(stop.X,6,stop.Z),Color3.fromRGB(121,163,244),"Guild")
  gate:SetAttribute("CityReturnStop",id);table.insert(S.guildAccessPortals,gate)
  prompt(gate,"Visit islands",function(player)open(player,"Islands")end)
 end
	S.spawn=Instance.new("SpawnLocation");S.spawn.Name="CentralCitySpawn";S.spawn.Position=V(0,2,-720);S.spawn.Size=V(7,1,7);S.spawn.Anchored=true;S.spawn.Transparency=1;S.spawn.CanCollide=false;S.spawn.Neutral=true;S.spawn.Enabled=false;S.spawn.Duration=0;S.spawn.Parent=town
	local walkway=part(guild,"IslandPromenade",V(170,2,14),V(15,0,-65),Color3.fromRGB(141,131,112));local links={}
	function S.origin(slot: number): Vector3 return V(slot*IslandLayout.SlotSpacing,1,0) end
	function S.refresh()
		local last=0;local count=0;for _,link in pairs(links) do last=math.max(last,link.slot);count+=1 end
		local length=last*IslandLayout.SlotSpacing+170;walkway.Size=V(length,2,14);walkway.Position=V(-70+length/2,0,-65);guild:SetAttribute("OnlineIslands",count)
	end
	function S.add(player: Player,slot: number)
		local f=Instance.new("Folder");f.Name="IslandLink_"..player.UserId;f.Parent=guild
		local x=slot*IslandLayout.SlotSpacing+64;part(f,"IslandBridge",V(12,2,30),V(x,0,-49),Color3.fromRGB(155,130,88))
		for _,side in ipairs({-6,6}) do part(f,"BridgeRail",V(.5,2,26),V(x+side,2,-49),Color3.fromRGB(106,86,66)) end
		local sign=part(f,"IslandOwner",V(.2,.2,.2),V(x,3,-58),Color3.fromRGB(230,192,110));sign.Transparency=1
		Kit.Label(sign,player.DisplayName.." · Island "..(slot+1),"เกาะกิลด์ · "..player.DisplayName,4)
		links[player]={folder=f,slot=slot};S.refresh();return sign
	end
	function S.remove(player: Player) local link=links[player];if link then link.folder:Destroy();links[player]=nil;S.refresh() end end
	function S.validate(player: Player,plot: any,action: string,args: any): string?
		local station: BasePart?=nil
		if action=="AcceptTask" or action=="ClaimTask" then local def=Content.Journal[args.questId];if def and def.NPC then station=S.npcs[def.NPC];if not station then return "VisitStation" end end end
		if station then local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart")
			if not root or not root:IsA("BasePart") or (root.Position-station.Position).Magnitude>16 then return "VisitStation" end
			if plot and plot.model:GetAttribute("InCombat") then return "ReturnToGuild" end end
		return nil
	end
	return S
end
