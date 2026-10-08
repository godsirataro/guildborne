--!strict
local Config=require(game.ReplicatedStorage.Shared.Config.City)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local Art=require(game.ReplicatedStorage.Shared.Config.Art)
local Kit=require(script.Parent.ArtKit)
local V=Vector3.new
local C=Art.Palette
return function(town: Folder,templates: Folder,open: any,prompt: any): any
	local modular=require(script.Parent.CityKit).Build();modular.Parent=game.ServerStorage
	local interiors=require(script.Parent.CityInteriorKit)();interiors.Parent=modular
	local S:any={npcs={}}
	require(script.Parent.IslandScenery)(town)
	local function p(parent: Instance,n: string,size: Vector3,pos: Vector3,color: Color3,solid: boolean?): Part
		return Kit.Part(parent,n,size,pos,color,Enum.Material.SmoothPlastic,solid)
	end
	local function asset(name: string,pos: Vector3,angle: number?,parent: Instance?,scale: number?): Model
		local source=modular:FindFirstChild(name) or templates:FindFirstChild(name)
		local m=(source :: Model):Clone();if scale then m:ScaleTo(scale) end
		m:PivotTo(CFrame.new(pos)*CFrame.Angles(0,math.rad(angle or 0),0));m.Parent=parent or town;return m
	end
	local reserved: {{x: number,z: number,hx: number,hz: number}}={}
	local function streetHouse(pos: Vector3,angle: number,scale: number)
		local turned=math.abs(angle)%180==90
		local hx=(if turned then 24 else 29)*scale
		local hz=(if turned then 29 else 24)*scale
		for _,r in ipairs(reserved) do
			if math.abs(pos.X-r.x)<hx+r.hx+8 and math.abs(pos.Z-r.z)<hz+r.hz+8 then return end
		end
		asset("CityHouse",pos,angle,nil,scale)
	end
	local function sign(parent: Instance,name: string,pos: Vector3)
		local anchor=p(parent,name,V(8,4,.5),pos,C.Wood,false)
		Kit.Label(anchor,name,Locale.translate("th",name),3)
		return anchor
	end
	local function future(parent: Instance,name: string,pos: Vector3)
		local anchor=sign(parent,name,pos)
		prompt(anchor,if name=="Guildborne Exchange" then "Open market" else "Coming in a future phase",function(player) open(player,if name=="Guildborne Exchange" then "Market" else "CityFuture") end)
	end
	p(town,"CityFoundation",V(920,8,1020),V(0,-4,-1130),C.Stone,true).Material=Enum.Material.Slate
	p(town,"CityGround",V(912,.3,1012),V(0,.15,-1130),Color3.fromRGB(112,128,102),true).Material=Enum.Material.Grass
	local roads=Instance.new("Folder");roads.Name="Roads";roads.Parent=town
	local function road(name: string,a: Vector3,b: Vector3,width: number)
		local part=p(roads,name,V(width,.3,(b-a).Magnitude+width), (a+b)/2+V(0,.4,0),C.StoneLight,true)
		part.CFrame=CFrame.lookAt(part.Position,part.Position+(b-a));part.Material=Enum.Material.Cobblestone
		part:SetAttribute("RouteWidth",width)
	end
	road("GrandAvenue",V(0,0,-680),V(0,0,-1530),32)
	road("GuildMarketAvenue",V(-350,0,-1100),V(350,0,-1100),32)
	road("TavernApproach",V(0,0,-820),V(-205,0,-820),32)
	for _,x in ipairs({-300,300}) do
		road("DistrictLane",V(x,0,-960),V(x,0,-1130),18)
		local outer=x+math.sign(x)*40
		road("DistrictBypassEntry",V(x,0,-1120),V(outer,0,-1120),10)
		road("DistrictBypass",V(outer,0,-1120),V(outer,0,-1270),10)
		road("ServiceLane",V(x-80,0,-1215),V(x+80,0,-1215),10)
	end
	road("GardenWalk",V(-193,0,-820),V(-193,0,-1100),18)
	local districtFolders={}
	for _,d in ipairs(Config.Districts) do
		local f=Instance.new("Folder");f.Name=d.Id;f:SetAttribute("DistrictId",d.Id);f.Parent=town;districtFolders[d.Id]=f
		p(f,"Courtyard",V(if d.Id=="Plaza" then 180 else 110,.2,if d.Id=="Plaza" then 180 else 100),V(d.X,.6,d.Z),C.StoneLight,true)
		sign(f,d.Name,V(d.X+24,4,d.Z+40))
	end
	local plaza=districtFolders.Plaza
	-- Offset monument preserves the north/south arrival sightline and direct walking route.
	p(plaza,"MonumentPlinth",V(18,3,18),V(36,2,-1130),C.Stone,true)
	p(plaza,"GuildMonument",V(5,48,5),V(36,27,-1130),C.Gold,true)
	p(plaza,"SwordGuard",V(26,3,7),V(36,38,-1130),C.Gold)
	local crest=p(plaza,"GuildCrest",V(14,14,3),V(36,21,-1125),C.Roof);crest.CFrame*=CFrame.Angles(0,0,math.pi/4)
	for _,def in ipairs({{name="Guild District",x=-70,z=-1090},{name="Market / Craft District",x=70,z=-1090},{name="Tower Gate",x=22,z=-1180},{name="Tavern District",x=-22,z=-1010},{name="Guild Zone Warp",x=22,z=-1010}}) do sign(plaza,def.name,V(def.x,4,def.z)) end
	for _,def in ipairs({{id="Guild",name="Guild Administration",x=-300,z=-1170,angle=0,color=Color3.fromRGB(66,103,145)},
		{id="Tavern",name="The Hearth and Banner",x=-140,z=-870,angle=0,color=C.Roof},
		{id="Market",name="Guildborne Exchange",x=300,z=-1180,angle=0,color=Color3.fromRGB(178,112,57)},
		{id="Market",name="Blacksmith",x=370,z=-1000,angle=90,color=Color3.fromRGB(119,87,66)},
		{id="Market",name="Alchemy Shop",x=235,z=-1000,angle=0,color=Color3.fromRGB(91,127,110)}}) do
		local f=districtFolders[def.id];local m=asset("CityHouse",V(def.x,1,def.z),def.angle,f);m.Name=def.name
		table.insert(reserved,{x=def.x,z=def.z,hx=if def.angle==90 then 28 else 29,hz=if def.angle==90 then 29 else 28})
		for _,source in ipairs(interiors:GetChildren()) do
			if source:IsA("Model") and source:GetAttribute("BuildingName")==def.name then
				local furnishing=source:Clone();furnishing.Name="Interior";furnishing:PivotTo(m:GetPivot());furnishing.Parent=m
			end
		end
		for _,part in ipairs(m:GetChildren()) do if part:IsA("BasePart") and part.Name=="PitchedRoof" then part.Color=def.color end end
		local entry=V(def.x,4,def.z+28);if def.angle==90 then entry=V(def.x+28,4,def.z) end
		future(f,def.name,entry)
		for _,side in ipairs({-1,1}) do local b=asset("DistrictBanner",V(def.x+side*36,1,def.z+24),0,f);
			(b:FindFirstChild("Cloth") :: BasePart).Color=def.color end
	end
	future(districtFolders.Guild,"Guild Registry",V(-330,4,-1070));future(districtFolders.Guild,"Guild Rankings",V(-275,4,-1070))
	asset("CityHouse",V(-385,1,-1240),0,districtFolders.Guild,.8).Name="FutureGuildHall"
	for _,x in ipairs({255,330,380}) do asset("MarketStall",V(x,1,-1060),0,districtFolders.Market) end
	for _,x in ipairs({-175,-110}) do asset("Table",V(x,1,-820),0,districtFolders.Tavern);asset("Bench",V(x,1,-814),0,districtFolders.Tavern) end
	asset("QuestBoard",V(-190,1,-830),90,districtFolders.Tavern)
	-- District silhouettes differ even when their timber shell uses the same kit.
	asset("CityArch",V(-300,1,-1135),0,districtFolders.Guild)
	p(districtFolders.Guild,"CouncilSpire",V(12,44,12),V(-300,45,-1180),C.Stone,true)
	p(districtFolders.Guild,"CouncilCrown",V(20,4,20),V(-300,69,-1180),C.Gold)
	p(districtFolders.Tavern,"HearthChimney",V(9,38,9),V(-158,20,-880),C.Stone,true)
	asset("MarketStall",V(278,1,-1148),0,districtFolders.Market)
	asset("MarketStall",V(322,1,-1148),0,districtFolders.Market)
	p(districtFolders.Market,"ForgeChimney",V(9,40,9),V(360,21,-1010),C.Stone,true)
	local tower=districtFolders.Tower
	for _,x in ipairs({-43,43}) do asset("GateTower",V(x,1,-1560),0,tower) end
	asset("CityArch",V(0,1,-1550),0,tower)
	p(tower,"SealedGate",V(31,24,3),V(0,13,-1552),Color3.fromRGB(56,70,86),true)
	p(tower,"GateRune",V(2,17,.3),V(0,16,-1550),Color3.fromRGB(109,190,195)).Material=Enum.Material.Neon
	future(tower,"Expeditions beyond the gate",V(22,4,-1515))
	for x=-440,440,40 do asset("CityWall",V(x,0,-1635));asset("CityWall",V(x,0,-625)) end
	for z=-1595,-665,40 do asset("CityWall",V(-455,0,z),90);asset("CityWall",V(455,0,z),90) end
	-- Repeated street frontage, trees and furniture break long routes into readable blocks.
	for _,z in ipairs({-760,-920,-1000,-1260,-1380,-1480}) do
		for _,side in ipairs({-1,1}) do
			asset("Lantern",V(side*24,1,z),0,nil,1.8)
			asset("Planter",V(side*42,1,z))
			asset("TreeA",V(side*62,1,z),0,nil,1.6)
			if z<-1200 then streetHouse(V(side*125,1,z),if side<0 then 90 else -90,.7) end
		end
	end
	for _,x in ipairs({-220,-140,140,220}) do for _,z in ipairs({-1060,-1140}) do asset("TreeB",V(x,1,z),0,nil,1.4);asset("Bench",V(x,1,z+8)) end end
	-- Close street frontages frame the avenue; outer garden courts remain expansion space.
	for _,z in ipairs({-755,-825,-915,-985}) do
		streetHouse(V(93,1,z),-90,.85)
		if z==-755 or z==-985 then streetHouse(V(-93,1,z),90,.85) end
	end
	for _,side in ipairs({-1,1}) do
		for _,x in ipairs({160,225}) do
			streetHouse(V(side*x,1,-1190),0,.85)
			streetHouse(V(side*x,1,-1010),180,.75)
		end
		for _,z in ipairs({-1260,-1350,-1440}) do
			streetHouse(V(side*230,1,z),if side<0 then 90 else -90,1)
		end
	end
	for _,z in ipairs({-760,-945,-1290,-1430}) do
		sign(town,"Central Plaza",V(-24,4,z));sign(town,if z< -1100 then "Tower Gate" else "Guild Zone Warp",V(24,4,z))
	end
	local rig=require(script.Parent.HeroRig)
	for _,def in ipairs(({{name="Mira",class="Priest",x=250,z=-1030,tab="Journal"},{name="City Herald",class="Knight",x=-45,z=-1080,tab="Journal"},
		{name="Expedition Master",class="Archer",x=-175,z=-840,tab="Dispatch"},{name="City Guard",class="Knight",x=-23,z=-1525},
		{name="City Guard",class="Knight",x=23,z=-1525},{name="Merchant",class="Warrior",x=330,z=-1050},
		{name="Adventurer",class="Mage",x=-110,z=-830},{name="Craftsperson",class="Warrior",x=390,z=-980}} :: {{name: string,class: string,x: number,z: number,tab: string?}})) do
		local m=rig.Build(def.class);m.Name=def.name;m:PivotTo(CFrame.new(def.x,4,def.z));m:SetAttribute("CityAmbience",true);m.Parent=town
		require(script.Parent.CityNpcAppearance)(m,def.name)
		local humanoid=m:FindFirstChildOfClass("Humanoid");if humanoid then humanoid.EvaluateStateMachine=false end
		for _,part in ipairs(m:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false;part.CanTouch=false;part.CanQuery=false end end
		(m.PrimaryPart :: BasePart).Anchored=true
		local root=m.PrimaryPart :: BasePart;Kit.Label(root,def.name,Locale.translate("th",def.name),5)
		if def.tab then
			if def.tab=="Journal" then root:SetAttribute("QuestNPC",def.name);game:GetService("CollectionService"):AddTag(root,"GuildborneQuestNPC") end
			prompt(root,"Talk",function(player) open(player,if def.tab=="Journal" then "JournalNPC:"..def.name else def.tab) end);S.npcs[def.name]=root
		end
	end
	for name,root in pairs(require(script.Parent.FriendlyCityNpcs)(town,open,prompt)) do S.npcs[name]=root end
	return S
end
