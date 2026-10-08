--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Lighting = game:GetService("Lighting")
local Art = require(ReplicatedStorage.Shared.Config.Art)
local Kit = require(script.Parent.ArtKit)
local C = Art.Palette
local V = Vector3.new
local IslandLayout=require(ReplicatedStorage.Shared.Config.GuildIslandLayout)
local LandWorld=require(script.Parent.GuildLandWorld)
local HallWorld=require(script.Parent.GuildHallWorld)
local World = {}

function World.new(onOpen: (Player, string) -> (), reward: any, towerResult: any, intent: any,regionalRewardFactory:any?)
	local folder = Instance.new("Folder"); folder.Name = "GuildborneWorld"; folder.Parent = workspace
	local templates = Kit.Build(); templates.Parent = ServerStorage
	local expansion=require(script.Parent.ExpansionWorld)(onOpen,intent)
	local heroes = require(script.Parent.HeroService)(templates, onOpen, reward,towerResult,regionalRewardFactory)
	Lighting.ClockTime = 10.5; Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(111, 114, 109)
	Lighting.OutdoorAmbient = Color3.fromRGB(142, 148, 134)
	Lighting.ColorShift_Top = Color3.fromRGB(248, 222, 184)
	Lighting.GlobalShadows = true; Lighting.EnvironmentDiffuseScale = .65; Lighting.EnvironmentSpecularScale = .25
	local grade = Instance.new("ColorCorrectionEffect"); grade.Name = "GuildborneDaylight"
	grade.TintColor = Color3.fromRGB(255, 245, 228); grade.Contrast = .04; grade.Saturation = -.06; grade.Parent = Lighting
	local city=require(script.Parent.CityWorld)(folder,templates,onOpen,intent)
	city.regions=require(script.Parent.RegionalWorld)(folder,city.town,intent,templates)
	city.portals=table.clone(city.guildAccessPortals)
	for _,region in pairs(city.regions) do table.insert(city.portals,region.entry);table.insert(city.portals,region.exit) end
	local civic=require(script.Parent.CivicCityWorld)(folder,city.town,intent,onOpen)
	city.civicRegions=civic.regions
	for _,portal in ipairs(civic.portals)do table.insert(city.portals,portal)end
	for _,portal in ipairs(civic.guildPortals)do table.insert(city.guildAccessPortals,portal)end
	local plots: { [Player]: any } = {}
	local occupied: { [number]: boolean } = {}
	local service = {}
	local travel=require(script.Parent.TravelService)(city,plots,heroes)
	local visits=require(script.Parent.IslandVisits)(plots,travel,nil,city.guildAccessPortals)
	function service.Add(player: Player)
		if plots[player] then return end
		local slot = 0
		while occupied[slot] do slot += 1 end
		occupied[slot] = true
		local origin = city.origin(slot)
		local model = Instance.new("Model"); model.Name = "PersonalGuild"; model:SetAttribute("OwnerUserId", player.UserId); model.Parent = folder
		local env = Instance.new("Folder"); env.Name = "Environment"; env.Parent = model
		local groups: { [string]: Folder } = {}
		for _,name in ipairs({"Buildings", "Props", "Nature", "Resources", "Gameplay"}) do
			local g=Instance.new("Folder"); g.Name=name; g.Parent=env; groups[name]=g
		end
		local function put(asset: string, group: string, pos: Vector3, angle: number?): Model
			local source = templates:FindFirstChild(asset) :: Model
			local m=source:Clone(); m:PivotTo(CFrame.new(origin+pos)*CFrame.Angles(0,math.rad(angle or 0),0)); m.Parent=groups[group]; return m
		end
		local function part(group: string, name: string, size: Vector3, pos: Vector3, color: Color3, solid: boolean?): Part
			return Kit.Part(groups[group],name,size,origin+pos,color,Enum.Material.SmoothPlastic,solid)
		end
		local ground=part("Nature","Ground",Art.PlotSize,V(0,-1,0),C.Grass,true); ground.Material=Enum.Material.Grass
		local camp=part("Nature","GoblinCampGround",V(78,2,74),V(0,-1,80),C.Grass,true); camp.Material=Enum.Material.Grass
		part("Gameplay","CampPath",V(10,.14,52),V(0,.08,62),C.Path)
		part("Gameplay","CampClearing",V(58,.15,42),V(0,.1,91),C.Path)
		local campSign=put("Signpost","Props",V(8,0,47),180)
		Kit.Label(campSign:FindFirstChild("Sign") :: BasePart,"Goblin Camp · companions fight","ค่ายก็อบลิน · ทีมต่อสู้อัตโนมัติ",3)
		for _,p in ipairs({V(-33,0,60),V(33,0,66),V(-33,0,108),V(33,0,110)}) do put("TreeA","Nature",p) end
		part("Nature","EarthSkirt",V(79,5,87),V(0,-4,0),C.Wood,true)
		part("Gameplay","MainPath",V(9,.12,61),V(0,.06,5.5),C.Path)
		part("Gameplay","CrossPath",V(44,.13,7),V(0,.07,-3),C.Path)
		part("Gameplay","TrainingPath",V(42,.13,6),V(0,.07,18),C.Path)
		local plaza=part("Gameplay","Plaza",V(19,.14,19),V(0,.08,6),C.StoneLight)
		plaza.CFrame*=CFrame.Angles(0,math.pi/4,0)
		local medallion=part("Gameplay","GuildMedallion",V(4,.16,4),V(0,.1,6),C.Gold); medallion.CFrame*=CFrame.Angles(0,math.pi/4,0)
		-- Low paving and open sightlines keep the route readable from the spawn.
		for _,x in ipairs({-5.1,5.1}) do
			for _,z in ipairs({-7,0,13,22,30}) do part("Props","PathEdging",V(.55,.25,4),V(x,.13,z),C.Stone) end
		end
		local hall=put("GuildHallLv1","Buildings",V(0,0,-24))
		put("QuestBoard","Gameplay",V(20,0,-6),-12)
		local tavern=Instance.new("Model"); tavern.Name="Tavern"; tavern.Parent=groups.Buildings
		local function tavernPart(name: string, size: Vector3, position: Vector3, color: Color3, solid: boolean?): Part
			return Kit.Part(tavern,name,size,origin+position,color,Enum.Material.Wood,solid)
		end
		tavernPart("Floor",V(23,.4,18),V(-23,.2,-15),C.Timber,true)
		tavernPart("RearWall",V(23,6,.6),V(-23,3,-24),C.Wood,true)
		for _,x in ipairs({-34,-12}) do
			tavernPart("SideWall",V(.5,5,14),V(x,2.5,-17),C.Timber,true)
			tavernPart("PorchPost",V(.55,10,.55),V(x,5,-6),C.Wood,true)
		end
		local roof=tavernPart("BurgundyRoof",V(25,.5,20),V(-23,10.5,-15),C.Roof)
		roof.CFrame*=CFrame.Angles(math.rad(-8),0,0)
		tavernPart("Lintel",V(23,.5,.6),V(-23,9.5,-6),C.Wood)
		put("Table","Props",V(-23,.4,-21)); put("Bench","Props",V(-23,.4,-23))
		put("GuildBanner","Props",V(-34,0,-4)); put("SupplyCrate","Resources",V(22,0,17))
		put("WoodenCrate","Props",V(26,0,19)); put("Barrel","Props",V(26,0,15))
		put("TimberLogs","Resources",V(27,0,25)); put("IronOreNode","Resources",V(22,0,26))
		part("Gameplay","TrainingSand",V(17,.14,15),V(-21,.08,19),C.Path)
		put("TrainingDummy","Gameplay",V(-24,0,17),-15)
		put("TrainingDummy","Gameplay",V(-18,0,22),15)
		-- Static scout reference: this slice has timed expeditions, no world combat.
		local scout=put("GoblinScout","Gameplay",V(-27,.35,25),25)
		part("Props","ScoutPlinth",V(4,.5,3),V(-27,.25,25),C.Stone)
		local scoutHead=scout:FindFirstChild("Head") :: BasePart
		Kit.Label(scoutHead,"Goblin Scout · study","ก็อบลินลาดตระเวน · ตัวอย่าง",2)
		-- Readable starter silhouettes displayed together beside inventory.
		part("Props","WeaponRack",V(7,.35,1.4),V(17,1.8,19),C.Wood)
		for i,name in ipairs({"IronSword","TrainingBow","PriestStaff"}) do put(name,"Props",V(12+i*2.2,1.9,19)) end
		for _,x in ipairs({-8,8}) do put("GuildBanner","Props",V(x,0,31),180) end
		local exit=put("Signpost","Props",V(0,0,36),180)
		Kit.Label(exit:FindFirstChild("Sign") :: BasePart,"Goblin Camp ahead","ค่ายก็อบลินอยู่ข้างหน้า",2)
		local training=put("Signpost","Props",V(-13,0,23))
		Kit.Label(training:FindFirstChild("Sign") :: BasePart,"Training yard · display","ลานฝึก · จัดแสดง",1.8)
		for _,p in ipairs({V(-10,0,-12),V(10,0,-12),V(25,0,-4),V(-26,0,-1)}) do put("Lantern","Props",p) end
		for i,p in ipairs({V(-33,0,-30),V(33,0,-30),V(-33,0,-15),V(34,0,2),V(-34,0,7),V(33,0,33),V(-33,0,36)}) do
			put("Tree"..string.char(65+(i%3)),"Nature",p,i*37)
			put("Rock"..string.char(65+(i%3)),"Nature",p+V(3,0,3),i*23)
		end
		for _,x in ipairs({-37,37}) do for _,z in ipairs({-20,-12,12,20,28}) do put("Fence","Props",V(x,0,z),90) end end
		for _,x in ipairs({-26,-18,18,26}) do put("Fence","Props",V(x,0,39)) end
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "PersonalGuildSpawn"; spawn.Size = V(6,1,6); spawn.Position = origin+V(0,1,23)
		spawn.Anchored=true; spawn.Transparency=1; spawn.CanCollide=false; spawn.CanTouch=false
		spawn.Neutral=true; spawn.Duration=0; spawn.Enabled=false; spawn.Parent=model; player.RespawnLocation=spawn
		local function station(name: string, thai: string, tab: string, position: Vector3)
			local anchor=part("Gameplay",name,V(.5,.5,.5),position,C.Gold); anchor.Transparency=1
			if tab~="Guild" then Kit.Label(anchor,name,thai,if tab=="Party" then 7 else 3) end
			local prompt=Instance.new("ProximityPrompt"); prompt.Name="Open"..tab
			prompt.ActionText="Open / เปิด"; prompt.ObjectText=name.." / "..thai
			prompt.MaxActivationDistance=9; prompt.RequiresLineOfSight=false; prompt.Parent=anchor
			prompt.Triggered:Connect(function(actor)
				local root=actor.Character and actor.Character:FindFirstChild("HumanoidRootPart")
				if actor==player and root and root:IsA("BasePart") and (root.Position-anchor.Position).Magnitude<=14 then onOpen(actor,tab) end
			end)
			return anchor
		end
		station("Quest Board","กระดานภารกิจ","Quests",V(20,4,-3))
		station("Tavern / Recruitment","โรงเตี๊ยม / จ้างฮีโร่","Tavern",V(-23,4,-3))
		station("Inventory","คลัง","Inventory",V(20,3,18))
		local hallStation=station("Guild Hall","หอกิลด์","Guild",V(0,3,-13))
		local function move(character: Model)
			heroes.Character(player,character)
			local root=character:WaitForChild("HumanoidRootPart",10)
			-- CharacterAdded can precede the engine's final spawn pivot.
			task.wait(.5)
			if root and model.Parent and player.Parent and player.Character==character then
				travel.Respawn(player)
			end
		end
		heroes.Add(player,model,origin)
		local connection=player.CharacterAdded:Connect(move)
		plots[player]={spawn=spawn,model=model,slot=slot,hall=hall,hallStation=hallStation,level=1,origin=origin,buildings=groups.Buildings,connection=connection}
		expansion.add(player,plots[player]);visits.add(player,city.add(player,slot))
		for _,region in pairs(city.regions) do for id,node in pairs(region.nodes) do plots[player].nodes[id]=node end end
		if player.Character then task.spawn(move,player.Character) end
		local count=0
		for _,v in ipairs(model:GetDescendants()) do if v:IsA("BasePart") then count+=1 end end
		model:SetAttribute("ArtPartCount",count)
	end
	function service.Update(player: Player, level: number, data: any?, active: boolean?)
		local plot=plots[player]
		if plot and not data then visits.update(player,{},false);return end
		if plot and data then heroes.Sync(player,data,active==true);expansion.sync(plot,data);LandWorld.sync(plot,data);visits.update(player,data,active==true) end
		if plot then
			local position=data and data.expansion and data.expansion.hallPosition
			HallWorld(plot,templates,level,position,data and data.expansion and data.expansion.hallTheme)
			require(script.Parent.GuildIdentityWorld)(plot.hall,data)
			plot.model:SetAttribute("HallLevel",level);plot.model:SetAttribute("TavernLevel",data and data.settlement.tavernLevel or 1)
			local count=0
			for _,v in ipairs(plot.model:GetDescendants()) do if v:IsA("BasePart") then count+=1 end end
			plot.model:SetAttribute("ArtPartCount",count)
		end
	end
	function service.IntentCommitted(player: Player,action: string,args: any)
		local plot=plots[player];local c=player.Character
		if action=="TravelZone" then travel.Travel(player,args.zone) end
		if action=="GatherResource" and plot and c and plot.nodes[args.nodeId] then
			c:SetAttribute("ActionAt",workspace:GetServerTimeNow());c:SetAttribute("Action","Gather");c:SetAttribute("ActionEffect","Basic");c:SetAttribute("ActionTargetPosition",plot.nodes[args.nodeId].Position)
		end
	end
	function service.ValidateIntent(player: Player,action: string,args: any): string?
		if action=="RequestPermanentPass" then return expansion.validate(player,plots[player],"CraftItem",{}) end
		if action=="TravelZone" then return travel.Validate(player,args.zone) end
		local problem=city.validate(player,plots[player],action,args);if problem then return problem end
		if action=="UpgradeGuildHall" or action=="UpgradeTavern" or action=="UpgradeQuarters" or action=="UnlockGuildPlot" or action=="ContributeGuildPlot" or action=="OpenGuildPlot" then return expansion.validate(player,plots[player],"CraftItem",{}) end
		return expansion.validate(player,plots[player],action,args)
	end
	function service.PlayerAction(player: Player, action: string, actorId: string?): (boolean, string)
		return heroes.PlayerAction(player, action, actorId)
	end
	function service.CampaignContext(player:Player):any?
		local plot=plots[player];return if plot then {origin=plot.origin,model=plot.model} else nil
	end
	function service.CompanionEvidence(player:Player,actorId:string):any? return heroes.CompanionEvidence(player,actorId) end
	function service.RefreshCampaignCompanions(player:Player)heroes.Travel(player)end
	function service.IslandDirectory(player:Player):{any} return visits.directory(player) end
	function service.IslandVisitors(player:Player):{any} return visits.roster(player) end
	function service.KickIslandVisitor(player:Player,visitorId:string):string
		local id=tonumber(visitorId);if not id or id%1~=0 or math.abs(id)>9007199254740991 then return "VisitorNotPresent" end
		local visitor=game.Players:GetPlayerByUserId(id);if not visitor then return "VisitorNotPresent" end
		local _,reason=visits.kick(player,visitor);return reason
	end
	function service.VisitIsland(player:Player,ownerId:string):string
		local id=tonumber(ownerId);if not id or id%1~=0 or math.abs(id)>9007199254740991 then return "IslandUnavailable" end
		local owner=game.Players:GetPlayerByUserId(id);if not owner or not plots[owner] then return "IslandUnavailable" end
		return visits.enter(player,owner)
	end
	function service.Remove(player: Player)
		visits.remove(player)
		travel.Remove(player);heroes.Remove(player)
		local plot=plots[player]
		if plot then
			for _,visitor in ipairs(game.Players:GetPlayers()) do local c=visitor.Character
				if visitor~=player and c then local p=c:GetPivot().Position-plot.origin;local bounds=IslandLayout.Bounds;if p.X>=bounds.minX and p.X<=bounds.maxX and p.Z>=bounds.minZ and p.Z<=bounds.maxZ then travel.Travel(visitor,"Guild") end end end
			city.remove(player);plot.connection:Disconnect(); plot.model:Destroy(); occupied[plot.slot]=nil; plots[player]=nil end
	end
	return service
end
return World
