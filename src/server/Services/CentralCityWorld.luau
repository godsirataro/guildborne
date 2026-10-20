--!strict
local Config=require(game.ReplicatedStorage.Shared.Config.City)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local Art=require(game.ReplicatedStorage.Shared.Config.Art)
local Kit=require(script.Parent.ArtKit)
local V=Vector3.new
local C=Art.Palette
local ResidentRoute=require(script.Parent.Parent.Systems.CityResidentRoute)
-- Bounded nonquest residents owned by this builder. No escort/session receipts.
local function startResident(town:Folder,model:Model,definition:any?):boolean
	local root=model.PrimaryPart
	if not root then return false end
	local def=definition or {groundY=.7,points={{x=-110,z=-830},{x=-110,z=-828},{x=-184,z=-828}},yaw=0,lookAt={x=-190,z=-830},activity="BoardVisit"}
	local groundY=def.groundY
	local minX,maxX,minZ,maxZ=math.huge,-math.huge,math.huge,-math.huge
	for _,point in ipairs(def.points) do
		minX=math.min(minX,point.x-4);maxX=math.max(maxX,point.x+4)
		minZ=math.min(minZ,point.z-4);maxZ=math.max(maxZ,point.z+4)
	end
	local function bounds(part:BasePart):any
		local cf,size=part.CFrame,part.Size*.5
		local r,u,l=cf.RightVector,cf.UpVector,cf.LookVector
		local h=V(math.abs(r.X)*size.X+math.abs(u.X)*size.Y+math.abs(l.X)*size.Z,
			math.abs(r.Y)*size.X+math.abs(u.Y)*size.Y+math.abs(l.Y)*size.Z,
			math.abs(r.Z)*size.X+math.abs(u.Z)*size.Y+math.abs(l.Z)*size.Z)
		local p=cf.Position
		return {minX=p.X-h.X,maxX=p.X+h.X,minY=p.Y-h.Y,maxY=p.Y+h.Y,minZ=p.Z-h.Z,maxZ=p.Z+h.Z}
	end
	local footBottom=math.huge
	local left,right=model:FindFirstChild("Left Leg"),model:FindFirstChild("Right Leg")
	if not left or not left:IsA("BasePart") or not right or not right:IsA("BasePart") then return false end
	for _,p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") and (p==left or p==right or p.Name=="Boot") then footBottom=math.min(footBottom,bounds(p).minY) end
	end
	local footOffset=root.Position.Y-footBottom
	if footOffset~=footOffset or footOffset<1 or footOffset>6 then return false end
	local bodyTop=footBottom
	for _,p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			local b=bounds(p)
			bodyTop=math.max(bodyTop,b.maxY)
			local x=math.max(math.abs(b.minX-root.Position.X),math.abs(b.maxX-root.Position.X))
			local z=math.max(math.abs(b.minZ-root.Position.Z),math.abs(b.maxZ-root.Position.Z))
			-- Reserve .5 studs for the bounded local gait. A changed rig needs review.
			if x~=x or z~=z or math.sqrt(x*x+z*z)+.5>3 then return false end
		end
	end
	local bodyHeight=bodyTop-footBottom+.1
	if bodyHeight~=bodyHeight or bodyHeight<=0 or bodyHeight>20 then return false end
	local rootY=groundY+footOffset
	local route=if def.station then assert(ResidentRoute.station(def.points[1],def.yaw,8,6))
		else assert(ResidentRoute.new(def.points,def.yaw,def.lookAt))
	-- Explicit presentation capability: never impersonate a hero or a quest NPC.
	model:SetAttribute("CityResidentRoute",true)
	model:SetAttribute("CityResidentGroundY",groundY)
	model:SetAttribute("CityResidentDistance",0)
	model:SetAttribute("CityResidentActivity",def.activity)
	model:SetAttribute("CityResidentClock",0)
	local initial=route.snapshot()
	model:SetAttribute("CityResidentStatus",initial.status)
	model:PivotTo(CFrame.new(initial.x,rootY,initial.z)*CFrame.Angles(0,initial.yaw,0))
	game:GetService("CollectionService"):AddTag(model,"GuildborneFriendlyNPC")
	local parts:{[BasePart]:boolean}={}
	local heroes:{[Model]:boolean}={}
	local connections:{RBXScriptConnection}={}
	local dead=false
	local function addPart(p:Instance) if p:IsA("BasePart") and not p:IsDescendantOf(model) then parts[p]=true end end
	local function addHero(p:Instance)
		if p:IsA("Model") and p:GetAttribute("GuildborneHero")==true then heroes[p]=true end
	end
	for _,p in ipairs(town:GetDescendants()) do addPart(p) end
	for _,p in ipairs(workspace:GetDescendants()) do addHero(p) end
	table.insert(connections,town.DescendantAdded:Connect(addPart))
	table.insert(connections,town.DescendantRemoving:Connect(function(p) if p:IsA("BasePart") then parts[p]=nil end end))
	table.insert(connections,workspace.DescendantAdded:Connect(addHero))
	table.insert(connections,workspace.DescendantRemoving:Connect(function(p) if p:IsA("Model") then heroes[p]=nil end end))
	local function stop()
		if dead then return end;dead=true;route.destroy()
		for _,connection in ipairs(connections) do connection:Disconnect() end
		table.clear(connections);table.clear(parts);table.clear(heroes)
		if model.Parent then model:SetAttribute("EscortMoving",false);model:SetAttribute("CityResidentStatus","Stopped") end
	end
	table.insert(connections,model.Destroying:Connect(stop))
	table.insert(connections,town.Destroying:Connect(stop))
	local elapsed=0
	local travelled=0
	table.insert(connections,game:GetService("RunService").Heartbeat:Connect(function(dt:number)
		if dead then return end
		if not model:IsDescendantOf(town) or not town:IsDescendantOf(workspace) or root.Parent==nil then stop();return end
		if dt~=dt or dt<0 or dt==math.huge then return end
		elapsed+=dt;if elapsed<.1 then return end
		-- Discard stall debt. A late tick may never jump across a player or furniture.
		local step=math.min(elapsed,.1);elapsed=0
		local before=route.snapshot();local nextState=route.propose(step)
		local players=game:GetService("Players"):GetPlayers()
		local nearby=false
		for _,player in ipairs(players) do
			local p=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if p and p:IsA("BasePart") and (p.Position-root.Position).Magnitude<=160 then nearby=true;break end
		end
		if not nearby then
			local state=route.step(step,false,false)
			model:SetAttribute("EscortMoving",false)
			model:SetAttribute("CityResidentStatus",state.status)
			model:SetAttribute("CityResidentReason",state.reason)
			return -- Far residents do no furniture or character bounds work.
		end
		local boxes={};local supportedFrom=false;local supportedTo=false;local valid=#players<=100
		local scanned=0
		-- Direct bounds include visible CanQuery=false/CanCollide=false furniture.
		-- Floors are support only when flat and at this resident's reviewed height.
		for part in pairs(parts) do
			scanned+=1;if scanned>16384 then valid=false;break end
			if not part.Parent then parts[part]=nil;continue end
			if part.Transparency>=1 and not part.CanCollide then continue end
			local b=bounds(part)
			for _,value in pairs(b) do
				if value~=value or math.abs(value)>1e6 then valid=false;break end
			end
			if not valid then break end
			if b.maxX<minX or b.minX>maxX or b.maxZ<minZ or b.minZ>maxZ then continue end
			if math.abs(part.CFrame.UpVector.Y)> .9999 and math.abs(b.maxY-groundY)<=.025 then
				local function supports(point:any):boolean
					local localPoint=part.CFrame:PointToObjectSpace(V(point.x,groundY,point.z))
					return math.abs(localPoint.X)<=part.Size.X*.5-.6 and math.abs(localPoint.Z)<=part.Size.Z*.5-.6
				end
				supportedFrom=supportedFrom or supports(before);supportedTo=supportedTo or supports(nextState)
			elseif b.maxY>groundY+.025 then table.insert(boxes,b) end
			if #boxes>400 then valid=false;break end
		end
		local function body(actor:Model)
			local p=actor.PrimaryPart or actor:FindFirstChild("HumanoidRootPart")
			if not p or not p:IsA("BasePart") then valid=false;return end
			-- Character geometry may be noncollidable and nonqueryable. GetBoundingBox
			-- reads all parts rather than relying on overlap-query eligibility.
			local cf,size=actor:GetBoundingBox();local r,u,l=cf.RightVector,cf.UpVector,cf.LookVector
			local h=V(math.abs(r.X)*size.X+math.abs(u.X)*size.Y+math.abs(l.X)*size.Z,
				math.abs(r.Y)*size.X+math.abs(u.Y)*size.Y+math.abs(l.Y)*size.Z,
				math.abs(r.Z)*size.X+math.abs(u.Z)*size.Y+math.abs(l.Z)*size.Z)*.5
			local margin=1
			-- Filter using the complete bound, not root distance: a remote root can
			-- still own a limb/accessory that reaches this sweep.
			if cf.X~=cf.X or cf.Y~=cf.Y or cf.Z~=cf.Z or h.X~=h.X or h.Y~=h.Y or h.Z~=h.Z
				or math.abs(cf.X)>1e6 or math.abs(cf.Y)>1e6 or math.abs(cf.Z)>1e6
				or h.Magnitude==math.huge or h.Magnitude>100 then valid=false;return end
			if cf.X+h.X+margin<math.min(before.x,nextState.x)-3 or cf.X-h.X-margin>math.max(before.x,nextState.x)+3
				or cf.Z+h.Z+margin<math.min(before.z,nextState.z)-3 or cf.Z-h.Z-margin>math.max(before.z,nextState.z)+3 then return end
			table.insert(boxes,{minX=cf.X-h.X-margin,maxX=cf.X+h.X+margin,minY=cf.Y-h.Y,maxY=cf.Y+h.Y,minZ=cf.Z-h.Z-margin,maxZ=cf.Z+h.Z+margin})
		end
		if nearby then
			for _,player in ipairs(players) do if player.Character then body(player.Character) end end
			local count=0
			for hero in pairs(heroes) do
				count+=1;if count>500 then valid=false;break end
				if hero:IsDescendantOf(workspace) then body(hero) else heroes[hero]=nil end
			end
		end
		local blocked,reason=ResidentRoute.sweptBlocked(before,nextState,3,groundY+.026,groundY+bodyHeight,boxes)
		local clear=valid and supportedFrom and supportedTo and not blocked
		local state=route.step(step,nearby,clear)
		local dx,dz=state.x-before.x,state.z-before.z
		local distance=math.sqrt(dx*dx+dz*dz)
		if clear and nearby then model:PivotTo(CFrame.new(state.x,rootY,state.z)*CFrame.Angles(0,state.yaw,0)) end
		model:SetAttribute("EscortMoving",distance>0)
		travelled+=distance
		model:SetAttribute("CityResidentDistance",travelled)
		model:SetAttribute("CityResidentClock",state.clock)
		model:SetAttribute("CityResidentStatus",state.status)
		model:SetAttribute("CityResidentReason",if not valid then "InvalidGeometry" elseif not supportedFrom or not supportedTo then "UnsupportedGround" elseif blocked then reason else state.reason)
	end))
	return true
end
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
	-- Follow the reserved east approach around the stalls to the rotated forge door.
	road("ForgeApproach",V(350,0,-1100),V(410,0,-1100),18)
	road("ForgeEastLane",V(410,0,-1100),V(410,0,-1000),18)
	road("ForgeThreshold",V(410,0,-1000),V(390,0,-1000),12)
	-- The Exchange front wall is at z=-1160; its courtyard ends at z=-1150.
	road("ExchangeThreshold",V(300,0,-1130),V(300,0,-1160),12)
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
		if def.name=="The Hearth and Banner" or def.name=="Blacksmith" then
			sign(f,def.name,entry)
			local crafting=def.name=="Blacksmith"
			local tab=if crafting then "Crafting" else "Tavern"
			local position=m:GetPivot():PointToWorldSpace(if crafting then V(8,3,4) else V(-5,3,2))
			local anchor=p(m,if crafting then "CityForgeStation" else "CityTavernStation",V(.2,.2,.2),position,C.Gold,false)
			anchor.Transparency=1;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false
			anchor:SetAttribute("CityService",tab);anchor:SetAttribute("MaxServiceDistance",14)
			Kit.Label(anchor,tab,Locale.translate("th",tab),3)
			prompt(anchor,tab,function(player)open(player,tab)end)
			if crafting then
				S.craftingStation=anchor
				game:GetService("CollectionService"):AddTag(anchor,"GuildborneCityCraftingStation")
			else S.tavernStation=anchor end
		else future(f,def.name,entry) end
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
	-- Street lanterns preserve navigation rhythm; landscape uses irregular planted groves.
	for _,z in ipairs({-760,-920,-1000,-1260,-1380,-1480}) do
		for _,side in ipairs({-1,1}) do
			asset("Lantern",V(side*24,1,z),0,nil,1.8)
			if z<-1200 then streetHouse(V(side*125,1,z),if side<0 then 90 else -90,.7) end
		end
	end
	for _,x in ipairs({-220,-140,140,220}) do for _,z in ipairs({-1060,-1140}) do asset("Bench",V(x,1,z+8)) end end
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
	local resident:Model?=nil
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
		if def.name=="Adventurer" and not def.tab then resident=m end
		if def.tab then
			if def.tab=="Journal" then root:SetAttribute("QuestNPC",def.name);game:GetService("CollectionService"):AddTag(root,"GuildborneQuestNPC") end
			prompt(root,"Talk",function(player) open(player,if def.tab=="Journal" then "JournalNPC:"..def.name else def.tab) end);S.npcs[def.name]=root
		end
	end
	for name,root in pairs(require(script.Parent.FriendlyCityNpcs)(town,open,prompt)) do S.npcs[name]=root end
	require(script.Parent.CityLandscape)(town)
	if resident then startResident(town,resident) end
	-- Original civilian silhouettes built from the existing procedural R6 rig.
	-- Held items are welded scenery, never Tools, inventory or quest identities.
	local function ambient(name:string,class:string,activity:string):Model
		local m=rig.Build(class);m.Name=name
		m:SetAttribute("CityAmbience",true);m:SetAttribute("CityResidentActivity",activity)
		m:SetAttribute("AssetProvenance","Guildborne procedural HeroRig and original local primitive props")
		local remove={Quiver=true,Arrow=true,Breastplate=true,Pauldron=true,HelmetRidge=true}
		for _,child in ipairs(m:GetChildren()) do if remove[child.Name] then child:Destroy() end end
		local h=m:FindFirstChildOfClass("Humanoid");if h then h.EvaluateStateMachine=false end
		for _,part in ipairs(m:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide=false;part.CanTouch=false;part.CanQuery=false end
		end
		return m
	end
	local function armPose(m:Model,name:string,angle:number)
		local motor=m:FindFirstChild(name,true) :: Motor6D
		local arm=motor.Part1 :: BasePart
		motor.C0*=CFrame.Angles(angle,0,0)
		local cf=(motor.Part0 :: BasePart).CFrame*motor.C0*motor.C1:Inverse()
		local delta=cf*arm.CFrame:Inverse()
		for _,w in ipairs(m:GetDescendants()) do
			if w:IsA("WeldConstraint") and w.Part0==arm and w.Part1 then w.Part1.CFrame=delta*w.Part1.CFrame end
		end
		arm.CFrame=cf
	end
	local function held(m:Model,name:string,size:Vector3,limb:BasePart,relative:CFrame,color:Color3):Part
		local part=Kit.Part(m,name,size,V(0,0,0),color,Enum.Material.SmoothPlastic,false)
		part.Anchored=false;part.Massless=true;part.CFrame=limb.CFrame*relative
		local weld=Instance.new("WeldConstraint");weld.Part0=limb;weld.Part1=part;weld.Parent=part
		return part
	end
	local porter=ambient("Tavin Reed","Archer","MarketStockRun")
	local carryAngle=.9 -- lowered working grip keeps hand corners inside radius 3
	local porterTorso=porter:FindFirstChild("Torso") :: BasePart
	porterTorso.Color=Color3.fromRGB(159,110,63)
	armPose(porter,"Left Shoulder",carryAngle)
	local porterArm=porter:FindFirstChild("Left Arm") :: BasePart
	held(porter,"ClothBundle",V(1.6,1.4,.65),porterTorso,CFrame.new(0,.05,.95),Color3.fromRGB(181,141,82))
	for _,x in ipairs({-.55,.55}) do
		held(porter,"BundleStrap",V(.14,1.55,.1),porterTorso,CFrame.new(x,.05,1.31),C.Wood)
	end
	held(porter,"StockSlate",V(.85,.12,.65),porterArm,CFrame.new(.25,-.95,0),C.Wood)
	held(porter,"SlateTally",V(.55,.03,.35),porterArm,CFrame.new(.25,-.87,0),C.Parchment)
	porter.Parent=town
	if not startResident(town,porter,{groundY=.7,points={{x=340,z=-1080},{x=340,z=-1070},{x=330,z=-1070}},yaw=math.pi,lookAt={x=330,z=-1060},activity="MarketStockRun"}) then porter:Destroy() end
	local inspector=ambient("Edda Flint","Warrior","ForgeInspection")
	local torso=inspector:FindFirstChild("Torso") :: BasePart
	torso.Color=Color3.fromRGB(90,113,121)
	local cap=inspector:FindFirstChild("Helmet") :: BasePart;cap.Color=C.Wood
	armPose(inspector,"Left Shoulder",carryAngle);armPose(inspector,"Right Shoulder",carryAngle)
	local leftArm=inspector:FindFirstChild("Left Arm") :: BasePart
	local rightArm=inspector:FindFirstChild("Right Arm") :: BasePart
	held(inspector,"InspectorsApron",V(1.55,1.7,.15),torso,CFrame.new(0,-.3,-.62),C.Wood)
	held(inspector,"SteelSample",V(1.7,.18,.45),leftArm,CFrame.new(.85,-.95,0)*CFrame.Angles(-carryAngle,0,0),C.Iron)
	local gauge=held(inspector,"GaugeRail",V(1.3,.12,.14),rightArm,CFrame.new(-.65,-.95+.3*math.cos(carryAngle),-.3*math.sin(carryAngle))*CFrame.Angles(-carryAngle,0,0),C.Gold)
	held(inspector,"GaugeCrosspiece",V(.12,.12,.9),gauge,CFrame.new(-.55,0,0),C.Gold)
	held(inspector,"FixedGaugeJaw",V(.12,.4,.14),gauge,CFrame.new(-.55,-.2,.3),C.Gold)
	local jaw=Kit.Part(inspector,"SlidingGaugeJaw",V(.12,.4,.14),V(0,0,0),C.Gold,Enum.Material.SmoothPlastic,false)
	jaw.Anchored=false;jaw.Massless=true;jaw.CFrame=gauge.CFrame*CFrame.new(-.55,-.2,-.38)
	local joint=Instance.new("Motor6D");joint.Name="InspectionJaw";joint.Part0=gauge;joint.Part1=jaw;joint.C0=CFrame.new(-.55,-.2,-.38);joint.Parent=gauge
	inspector.Parent=town
	if not startResident(town,inspector,{groundY=.3,points={{x=370,z=-1040}},yaw=0,station=true,activity="ForgeInspection"}) then inspector:Destroy() end
	return S
end
