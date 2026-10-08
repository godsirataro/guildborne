--!strict
local Rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
local Content=require(script.Parent.Parent.Config.Content)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local Appearance=require(game.ReplicatedStorage.Shared.Presentation.BuildingAppearance)
local furnitureSync=require(script.Parent.FurnitureWorld)
local V=Vector3.new
return function(open: any,intent: any)
	local S={}
	local function part(parent: Instance,name: string,size: Vector3,cf: CFrame,color: Color3): Part
		local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Anchored=true;p.Material=Enum.Material.Wood;p.Parent=parent;return p
	end
	local function label(p: BasePart,text: string)
		local g=Instance.new("BillboardGui");g.Size=UDim2.fromOffset(180,55);g.StudsOffset=V(0,4,0);g.MaxDistance=50;g.Parent=p
		local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=.2;t.BackgroundColor3=Color3.fromRGB(25,32,30);t.TextColor3=Color3.fromRGB(233,204,140);t.TextWrapped=true;t.TextSize=14;t.Font=Enum.Font.GothamMedium;t.Text=text;t.Parent=g
	end
	function S.add(player: Player,plot: any)
		local f=Instance.new("Folder");f.Name="Expansion";f.Parent=plot.model.Environment;plot.expansionFolder=f;plot.built={};plot.nodes={}
		part(f,"BuildGround",V(64,2,80),CFrame.new(plot.origin+V(64,-1,0)),Color3.fromRGB(102,124,89)).Material=Enum.Material.Grass
		part(f,"ReservedAccess",V(65,.15,8),CFrame.new(plot.origin+V(62,.1,4)),Color3.fromRGB(171,155,116)).Material=Enum.Material.Ground
		for id,def in pairs(Rules.Nodes) do
			if def.Region then continue end
			local color=if id=="wood" then Color3.fromRGB(133,91,57) elseif id=="herbs" then Color3.fromRGB(110,179,103) else Color3.fromRGB(130,143,151)
			local p=part(f,"Resource_"..id,V(3,3,3),CFrame.new(plot.origin+V(def.X,1.5,def.Z)),color);p.CanCollide=false
			p.Shape=if id=="wood" then Enum.PartType.Cylinder else Enum.PartType.Ball
			p:SetAttribute("ResourceNodeId",id)
			local name=Content.Items[def.Item].Name
			label(p,name.." / "..Locale.translate("th",name))
			local prompt=Instance.new("ProximityPrompt");prompt.Name="Gather";prompt.ActionText="Gather / เก็บ";prompt.ObjectText=name;prompt.HoldDuration=.5;prompt.MaxActivationDistance=9;prompt.RequiresLineOfSight=false;prompt.Parent=p
			prompt.Triggered:Connect(function(who) if who==player then intent(player,"GatherResource",{nodeId=id}) end end)
			plot.nodes[id]=p
		end
		local portal=part(f,"TowerPortal",V(6,9,1),CFrame.new(plot.origin+V(-27,4.5,34)),Color3.fromRGB(132,113,207));portal.Material=Enum.Material.Neon;portal.CanCollide=false
		label(portal,"Spire of Echoes · 10 floors\nหอคอยเสียงสะท้อน · 10 ชั้น")
		local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Tower / หอคอย";prompt.MaxActivationDistance=9;prompt.RequiresLineOfSight=false;prompt.Parent=portal
		prompt.Triggered:Connect(function(who) if who==player then open(player,"Tower") end end)
		plot.model:SetAttribute("PlotOrigin",plot.origin)
	end
	function S.sync(plot: any,data: any)
		local e=data.expansion;if not e then return end
		furnitureSync(plot,data)
		for id,m in pairs(plot.built) do if not e.buildings[id] then m:Destroy();plot.built[id]=nil end end
		for id,b in pairs(e.buildings) do
			local m=plot.built[id];local def=Rules.Buildings[b.kind]
			local theme=b.theme or "human"
			if m and m:GetAttribute("BuildingTheme")~=theme then m:Destroy();plot.built[id]=nil;m=nil end
			if not m then
				m=Instance.new("Model");m.Name=id;m:SetAttribute("BuildingKind",b.kind);m.Parent=plot.expansionFolder;plot.built[id]=m
				local color=if b.kind=="warehouse" then Color3.fromRGB(146,111,67) elseif b.kind=="quarters" then Color3.fromRGB(107,130,144) else Color3.fromRGB(106,104,101)
				local floor=part(m,"Foundation",V(14,1,14),CFrame.new(0,.5,0),color);m.PrimaryPart=floor
				part(m,"Roof",V(15,1,15),CFrame.new(0,8,0),color:Lerp(Color3.new(0,0,0),.3))
				for _,x in ipairs({-6,6}) do for _,z in ipairs({-6,6}) do part(m,"Post",V(1,7,1),CFrame.new(x,4,z),color) end end
				part(m,"Workstation",V(6,2,3),CFrame.new(0,2,-4),color:Lerp(Color3.new(1,1,1),.15))
				label(floor,def.Name.."\n"..({warehouse="คลังวัสดุ",quarters="ที่พักฮีโร่",forge="โรงตีเหล็ก"})[b.kind])
				Appearance.apply(m,theme)
			end
			m:PivotTo(CFrame.new(plot.origin+V((b.x+1)*8,.5,(b.z+1)*8))*CFrame.Angles(0,b.rotation*math.pi/2,0))
		end
		local warehouse=false;for _,b in pairs(e.buildings) do if b.kind=="warehouse" then warehouse=true end end
		plot.model:SetAttribute("WarehouseCapacity",if warehouse then 200 else 100)
	end
	function S.validate(player: Player,plot: any,action: string,args: any): string?
		if action=="AllocateStatus" or action=="ResetBuildPoints" then
			if not Content.StatusAllocationAvailable then return "StatusUnavailable" end
			local character=player.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
			if not plot or not character or not root or not root:IsA("BasePart") or not plot.hallStation then return "ActorNotReady" end
			if (character:GetAttribute("CombatHealth") or 0)<=0 then return "Downed" end
			local distance=(root.Position-plot.hallStation.Position).Magnitude
			if plot.model:GetAttribute("InCombat") or distance~=distance or distance>24 then return "ReturnToHallForPoints" end
			return nil
		end
		if not ({DismantleFurniture=true,CraftFurniture=true,PlaceFurniture=true,StoreFurniture=true,GatherResource=true,PlaceBuilding=true,MoveBuilding=true,MoveGuildHall=true,StoreBuilding=true,RestoreBuilding=true,UnlockBuildingTheme=true,ApplyBuildingTheme=true,SaveBuildLayout=true,ApplyBuildLayout=true,DeleteBuildLayout=true,DismantleBuilding=true,CraftItem=true,AdvanceClass=true,LearnSkill=true,EquipSkill=true,ResetSkills=true,SelectRace=true,StartTower=true,EnterTowerFloor=true})[action] then return nil end
		local character=player.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
		if not plot or not character or not root or not root:IsA("BasePart") then return "ActorNotReady" end
		if (character:GetAttribute("CombatHealth") or 1)<=0 then return "Downed" end
		if action=="GatherResource" then
			local humanoid=character:FindFirstChildOfClass("Humanoid");if not humanoid or humanoid.Health<=0 then return "ActorNotReady" end
			local definition=Rules.Nodes[args.nodeId];if definition and definition.Region and player:GetAttribute("CurrentZone")~=definition.Region then return "ResourceTooFar" end
			local node=plot.nodes[args.nodeId];local distance=if node then (root.Position-node.Position).Magnitude else math.huge
			if distance~=distance or distance>12 then return "ResourceTooFar" end
		elseif action=="DismantleFurniture" or action=="CraftFurniture" or action=="PlaceFurniture" or action=="StoreFurniture" or action=="PlaceBuilding" or action=="MoveBuilding" or action=="DismantleBuilding" or action=="MoveGuildHall" or action=="StoreBuilding" or action=="RestoreBuilding" or action=="UnlockBuildingTheme" or action=="ApplyBuildingTheme" or action=="SaveBuildLayout" or action=="ApplyBuildLayout" or action=="DeleteBuildLayout" or action=="CraftItem" or action=="AdvanceClass" or action=="LearnSkill" or action=="EquipSkill" or action=="ResetSkills" or action=="SelectRace" or action=="StartTower" then
			if plot.model:GetAttribute("InCombat") or (root.Position-plot.origin).Magnitude>165 then return "ReturnToGuild" end
		end
		return nil
	end
	return S
end
