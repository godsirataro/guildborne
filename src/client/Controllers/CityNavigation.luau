--!strict
local Players=game:GetService("Players")
local Input=game:GetService("UserInputService")
local City=require(game.ReplicatedStorage.Shared.Config.City)
local Civic=require(game.ReplicatedStorage.Shared.Config.CivicCities)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local Art=require(game.ReplicatedStorage.Shared.Config.Art)
local MenuRouter=require(script.Parent.Parent.UI.MenuRouter)
local Waypoint=require(game.ReplicatedStorage.Shared.Data.CityWaypoint)
local QuestTarget=require(game.ReplicatedStorage.Shared.Data.QuestTracker)
local Rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
local QuestRoute=require(game.ReplicatedStorage.Shared.Data.QuestRoute)(City,Rules,Waypoint,function(region:string,marker:string):any
 local world=workspace:FindFirstChild("GuildborneWorld")
 local area=world and world:FindFirstChild(region)
 local markers=area and area:FindFirstChild("EncounterMarkers")
 local point=markers and markers:FindFirstChild(marker)
 return if point and point:IsA("BasePart") then {x=point.Position.X,z=point.Position.Z} else nil
end)
local Symbol=require(script.Parent.Parent.UI.SymbolIcon)
local districtSymbols={Plaza="plaza",Guild="guild_home",Market="exchange",Tavern="tavern",Tower="tower",Warp="portal"}
return function()
	local player=Players.LocalPlayer;local language="en"
	local selected: any=nil;local snapshot: any=nil;local arrivedUntil=0;local mapRegion:string?=nil
	local mapCivic:string?=nil
	local connections: {RBXScriptConnection}={}
	local function connect(signal: RBXScriptSignal,callback: any) table.insert(connections,signal:Connect(callback)) end
	local gui=Instance.new("ScreenGui");gui.Name="CityNavigation";gui.ResetOnSpawn=false;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.DisplayOrder=20;gui.Parent=player:WaitForChild("PlayerGui")
	local function label(parent: Instance,key: string,size: UDim2,pos: UDim2): TextLabel
		local t=Instance.new("TextLabel");t.Size=size;t.Position=pos;t.Text=key;t.TextSize=16;t.TextWrapped=true;t.Font=Enum.Font.GothamMedium;t.BackgroundColor3=Art.UI.Background;t.TextColor3=Art.UI.Text;t.BorderSizePixel=0;t.Parent=parent;return t
	end
	local toggle=Instance.new("TextButton");toggle.Name="CityMapButton";toggle.Size=UDim2.fromOffset(130,48);toggle.Position=UDim2.new(1,-138,0,60);toggle.BackgroundColor3=Art.UI.Background;toggle.TextColor3=Art.UI.Accent;toggle.TextSize=16;toggle.Parent=gui
	local banner=label(gui,"",UDim2.new(0,130,0,64),UDim2.new(1,-138,0,112));banner.Name="DistrictName";banner.TextSize=14
	local direction=label(gui,"↑",UDim2.fromOffset(40,40),UDim2.new(1,-90,0,180));direction.Name="WaypointDirection";direction.TextSize=30;direction.BackgroundTransparency=1;direction.TextColor3=Art.UI.Accent;direction.Visible=false
	local panel=Instance.new("Frame");panel.Name="CityMap";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.Size=UDim2.fromScale(.94,.78);panel.BackgroundColor3=Art.UI.Background;panel.Visible=false;panel.Parent=gui
	MenuRouter.register("Map",panel)
	local limit=Instance.new("UISizeConstraint");limit.MaxSize=Vector2.new(650,650);limit.Parent=panel
	local title=label(panel,"",UDim2.new(1,-60,0,48),UDim2.fromOffset(4,0))
	local close=Instance.new("TextButton");close.Name="CloseMap";close.Text="×";close.TextSize=26;close.Size=UDim2.fromOffset(48,48);close.Position=UDim2.new(1,-48,0,0);close.BackgroundColor3=Art.UI.Background;close.TextColor3=Art.UI.Text;close.Parent=panel
	local scroll=Instance.new("ScrollingFrame");scroll.Name="MapScroll";scroll.Size=UDim2.new(1,-16,1,-110);scroll.Position=UDim2.fromOffset(8,50);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=5;scroll.CanvasSize=UDim2.fromOffset(0,400);scroll.Parent=panel
	local map=Instance.new("Frame");map.Name="DistrictMap";map.Size=UDim2.new(1,-6,0,400);map.BackgroundColor3=Color3.fromRGB(54,68,61);map.ClipsDescendants=true;map.Parent=scroll
	local function point(x: number,z: number): UDim2 return UDim2.fromScale((x+460)/920,(z+1640)/1020) end
	local avenue=Instance.new("Frame");avenue.Size=UDim2.fromScale(.035,.86);avenue.Position=UDim2.fromScale(.482,.07);avenue.BackgroundColor3=Art.Palette.StoneLight;avenue.BorderSizePixel=0;avenue.Parent=map
	local cross=avenue:Clone();cross.Size=UDim2.fromScale(.77,.025);cross.Position=UDim2.fromScale(.115,.517);cross.Parent=map
	local nodes={}
	local function select(name: string,x: number,z: number) selected={name=name,x=x,z=z,zone=mapCivic or mapRegion or "City"};arrivedUntil=0;panel.Visible=false end
	local civicMap=require(script.Parent.Parent.UI.CivicMapView)(scroll,select)
	for _,d in ipairs(City.Districts) do
		local node=Instance.new("TextButton");node.Name="Guide_"..d.Id;node.Text=d.Name;node.Size=UDim2.new(.30,0,0,44);node.Position=point(d.X,d.Z)
		node.BackgroundColor3=Art.UI.Button;node.TextColor3=Art.UI.Text;node.Font=Enum.Font.GothamMedium;node.TextWrapped=true;node.AnchorPoint=Vector2.new(.5,.5);node.TextSize=14;node.Parent=map;nodes[d.Name]=node
		local icon=Symbol(node,"ui.map."..districtSymbols[d.Id],18,Art.UI.Accent)
		if icon then icon.Position=UDim2.new(.5,-9,0,-21) end
		connect(node.Activated,function() select(d.Name,d.X,d.Z) end)
	end
	local marker=label(map,"●",UDim2.fromOffset(22,22),point(0,-720));marker.Name="PlayerPosition";marker.AnchorPoint=Vector2.new(.5,.5);marker.TextColor3=Color3.fromRGB(255,224,102);marker.BackgroundTransparency=1;marker.ZIndex=3
	local regionalMap=Instance.new("Frame");regionalMap.Name="RegionalMap";regionalMap.Size=map.Size;regionalMap.BackgroundColor3=Color3.fromRGB(42,58,56);regionalMap.ClipsDescendants=true;regionalMap.Visible=false;regionalMap.Parent=scroll
	local function regionalPoint(region:string,x:number,z:number):UDim2
		local d=City.Regions[region];return UDim2.fromScale(.1+.8*(x-d.X+d.HalfWidth)/(2*d.HalfWidth),.1+.8*(z-d.Z+d.Back)/(d.Back+d.Front))
	end
	local regionNodes:{any}={}
	for _,region in ipairs(City.RegionOrder) do
		local d=City.Regions[region];local landing=City.Destinations[region]
		local entries={{id="return_"..region,name="Central City",x=landing.X,z=landing.Z+12}}
		for id,node in pairs(Rules.Nodes) do if node.Region==region then table.insert(entries,{id=id,name=({timber="Timber",stone="Stone",iron_ore="Iron Ore",herb="Herb"})[node.Item],x=d.X+node.X,z=d.Z+node.Z}) end end
		for _,entry in ipairs(entries) do
			local node=Instance.new("TextButton");node.Name="GuideResource_"..entry.id;node.Size=UDim2.new(.24,0,0,44);node.Position=regionalPoint(region,entry.x,entry.z);node.AnchorPoint=Vector2.new(.5,.5);node.BackgroundColor3=Art.UI.Button;node.TextColor3=Art.UI.Text;node.TextSize=15;node.TextWrapped=true;node.Visible=false;node.Parent=regionalMap
			node.TextScaled=true;local fontLimit=Instance.new("UITextSizeConstraint");fontLimit.MinTextSize=12;fontLimit.MaxTextSize=15;fontLimit.Parent=node
			table.insert(regionNodes,{button=node,region=region,name=entry.name})
			connect(node.Activated,function()select(entry.name,entry.x,entry.z)end)
		end
	end
	local regionalMarker=marker:Clone();regionalMarker.Name="RegionalPlayerPosition";regionalMarker.Parent=regionalMap
	local hint=label(panel,"",UDim2.new(1,-16,0,54),UDim2.new(0,8,1,-56))
	local questGuide=Instance.new("TextButton");questGuide.Name="GuideQuestNPC";questGuide.Size=UDim2.new(.75,-12,0,44);questGuide.Position=UDim2.fromOffset(8,50)
	questGuide.BackgroundColor3=Art.UI.Button;questGuide.TextColor3=Art.UI.Accent;questGuide.TextSize=15;questGuide.TextWrapped=true;questGuide.Parent=panel
	local clear=Instance.new("TextButton");clear.Name="ClearWaypoint";clear.Size=UDim2.new(.25,-12,0,44);clear.Position=UDim2.new(.75,4,0,50)
	clear.BackgroundColor3=Art.UI.Card;clear.TextColor3=Art.UI.Text;clear.TextSize=14;clear.Parent=panel
	scroll.Position=UDim2.fromOffset(8,100)
	connect(questGuide.Activated,function()
		if snapshot and snapshot.data then selected={quest=true};arrivedUntil=0;panel.Visible=false end
	end)
	connect(clear.Activated,function() selected=nil;arrivedUntil=0;panel.Visible=false end)
	local future=false
	local function refresh()
		toggle.Text=Locale.translate(language,if mapRegion then "Region Map" else "City Map")
		title.Text=Locale.translate(language,if future then "Coming in a future phase" else mapCivic or mapRegion or "Central City")
		hint.Text=Locale.translate(language,if future then "Recruitment and crafting remain at your Personal Guild." elseif mapRegion then "Resource sites and return portal. Gold dot: you. Follow the paths and avoid enemy warnings." else "Tap a district for directions. Gold dot: you. Follow streets around buildings.")
		questGuide.Text=Locale.translate(language,"Guide to quest objective");clear.Text=Locale.translate(language,"Clear route")
		questGuide.Visible=not future;clear.Visible=not future
		if mapCivic then hint.Text=Locale.translate(language,"Landmark and return portals. Gold dot: you.")end
		map.Visible=not future and mapRegion==nil and mapCivic==nil;regionalMap.Visible=not future and mapRegion~=nil
		civicMap.frame.Visible=not future and mapCivic~=nil;civicMap.update(mapCivic,language)
		for _,entry in ipairs(regionNodes) do entry.button.Visible=entry.region==mapRegion;entry.button.Text=Locale.translate(language,entry.name) end
		for key,node in pairs(nodes) do node.Text=Locale.translate(language,key) end
	end
	local function show()
		future=false;panel.Visible=not panel.Visible;refresh()
		if panel.Visible and mapRegion then scroll.CanvasPosition=Vector2.new(0,math.max(0,regionalMap.AbsoluteSize.Y*.71-scroll.AbsoluteSize.Y*.5)) end
	end
	connect(toggle.Activated,show);connect(close.Activated,function() panel.Visible=false end)
	connect(Input.InputBegan,function(key,processed) if not processed and key.KeyCode==Enum.KeyCode.N and toggle.Visible then show() end end)
	connect((game.ReplicatedStorage:WaitForChild("GuildborneRemotes"):WaitForChild("State") :: RemoteEvent).OnClientEvent,function(view)
		snapshot=view
		if view.data then language=view.data.language or "en" end
		if view.navigate=="CityFuture" then future=true;panel.Visible=true end
		refresh()
	end)
	refresh()
	gui.Destroying:Connect(function() for _,connection in ipairs(connections) do connection:Disconnect() end;table.clear(connections) end)
	task.spawn(function() while gui.Parent do
		task.wait(.2);if not gui.Parent then break end
		local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		local short=gui.AbsoluteSize.Y<450
		panel.Size=UDim2.fromScale(.94,if short then .96 else .78)
		scroll.Size=UDim2.new(1,-16,1,if short then -140 else -160)
		hint.Size=UDim2.new(1,-16,0,if short then 34 else 54);hint.Position=UDim2.new(0,8,1,if short then -36 else -56)
		local mapHeight=math.max(if root and City.region(root.Position.X,root.Position.Z) then 260 else 480,scroll.AbsoluteSize.Y)
		map.Size=UDim2.new(1,-6,0,mapHeight);scroll.CanvasSize=UDim2.fromOffset(0,mapHeight)
		regionalMap.Size=map.Size
		civicMap.frame.Size=map.Size
		local district=root and City.district(root.Position.X,root.Position.Z)
		local region=root and City.region(root.Position.X,root.Position.Z)
		local civic:string?=nil
		if root then for _,id in ipairs(Civic.Order)do if Civic.contains(id,root.Position.X,root.Position.Z)then civic=id;break end end end
		if civic~=mapCivic then mapCivic=civic;selected=nil;scroll.CanvasPosition=Vector2.zero;refresh()end
		if region~=mapRegion then mapRegion=region;scroll.CanvasPosition=if region then Vector2.new(0,math.max(0,mapHeight*.71-scroll.AbsoluteSize.Y*.5)) else Vector2.zero;refresh() end
		toggle.Visible=(district~=nil or region~=nil or civic~=nil) and (not MenuRouter.isBlocking() or panel.Visible)
		banner.Visible=(toggle.Visible or ((region~=nil or civic~=nil) and not MenuRouter.isBlocking())) and not panel.Visible
		local fightingRegion=region and root and player:GetAttribute("RegionalCombatEnabled")==region and City.regionCombat(region,root.Position.X,root.Position.Y,root.Position.Z)
		banner.Text=if region then Locale.translate(language,region)..(if fightingRegion then "" else " · "..Locale.translate(language,"Safe zone")) elseif district then Locale.translate(language,district).." · "..Locale.translate(language,"Safe zone") else ""
		if civic then banner.Text=Locale.translate(language,civic).." · "..Locale.translate(language,"Safe zone")end
		direction.Visible=false
		local target=selected
		if selected and selected.quest and root and snapshot and snapshot.data then
			local pin=player.PlayerGui:GetAttribute("GuildbornePinnedQuest")
			local quest=QuestTarget(snapshot.data,snapshot.catalog,if type(pin)=="string" then pin else nil)
			target=QuestRoute(quest,snapshot.catalog,root.Position.X,root.Position.Z)
			if civic then local d=(Civic.Definitions :: any)[civic];target={name="Central City",x=d.X-58,z=d.Z+88,zone=civic,kind="Portal",final=false}end
		end
		if root and (district or region or civic) and target and target.x then
			local distance,arrived=Waypoint.progress(root.Position.X,root.Position.Z,target.x,target.z)
			if target.zone~=(civic or region or "City") then selected=nil
			elseif arrived then
				if selected.quest then banner.Text=Locale.translate(language,target.name).."\n"..Locale.translate(language,if target.kind=="Enemy" then "Watch enemy attack warnings" else "Interact at destination") else selected=nil;arrivedUntil=os.clock()+3 end
			else
				banner.Text=Locale.translate(language,target.name).."\n"..Locale.translate(language,"{distance} studs",{distance=distance})
				local camera=workspace.CurrentCamera
				if camera then
					local look=camera.CFrame.LookVector;local forward=Vector3.new(look.X,0,look.Z)
					if forward.Magnitude<.001 then local up=camera.CFrame.UpVector;forward=Vector3.new(up.X,0,up.Z) end
					forward=forward.Unit;local delta=Vector3.new(target.x-root.Position.X,0,target.z-root.Position.Z)
					direction.Rotation=Waypoint.heading(delta:Dot(forward:Cross(Vector3.yAxis)),-delta:Dot(forward));direction.Visible=banner.Visible
				end
			end
		elseif not district and not region and not civic and selected and not selected.quest then selected=nil end
		if banner.Visible and os.clock()<arrivedUntil then banner.Text=Locale.translate(language,"Destination reached") end
		if root then marker.Position=point(root.Position.X,root.Position.Z);marker.Visible=district~=nil end
		if root and region then regionalMarker.Position=regionalPoint(region,root.Position.X,root.Position.Z);regionalMarker.Visible=true else regionalMarker.Visible=false end
		if root and civic then civicMap.update(civic,language,root.Position.X,root.Position.Z)end
	end end)
end
