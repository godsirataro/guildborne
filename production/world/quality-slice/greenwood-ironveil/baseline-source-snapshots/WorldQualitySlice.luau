--!strict
-- Explicit standalone preview only. Nothing in normal bootstrap invokes this.
local Quality=require(game.ReplicatedStorage.Shared.Config.WorldQuality)
local Runtime=require(script.Parent.Parent.Config.Runtime)
local active: {[Instance]: any} = {}
-- A frozen copy for controller-owned preview metadata; never client approval.
local function immutableCopy(value: any): any
	if type(value) ~= "table" then return value end
	local copy: any = {}
	for key, child in pairs(value) do copy[key] = immutableCopy(child) end
	return table.freeze(copy)
end
return function(parent: Instance): any
	assert(game:GetService("RunService"):IsServer(), "Server collision authority required")
	assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0, "Standalone Studio only")
	assert(Runtime.StudioPersistence=="Memory" and next(Runtime.AllowedDataStoreUniverses)==nil, "Memory-only preview required")
	if active[parent] then return active[parent] end
	local data=require(script.Parent.WorldQualityAssets)
	Quality.validate(data)
	local region=parent:FindFirstChild("Greenwood")
	assert(region and region:IsA("Model"), "Missing existing Greenwood")
	assert(not region:FindFirstChild("WorldQualityCollision"), "Unowned quality collision already exists")
	local changed: {any} = {}
	local folder=Instance.new("Folder")
	folder.Name="WorldQualityCollision"
	local result: any={folder=folder,disabledDecorationPhysics=0,colliders=0,sourceMeshSha256=data.sourceMeshSha256}
	result.reviewedArt=immutableCopy({sourceMeshSha256=data.sourceMeshSha256,expectedArt=data.expectedArt})
	local destroyed=false
	local corridorCleanup: (() -> ())? = nil
	local corridor: any = nil
	local ironveilCorridor: any = nil
	local ironveilCleanup: (() -> ())? = nil
	function result.destroy()
		if destroyed then return end
		destroyed=true
		if corridorCleanup then corridorCleanup() end
		if ironveilCleanup then ironveilCleanup() end
		for _,old in ipairs(changed) do
			local p=old.part
			if p.Parent then
				p.CanCollide=old.collide;p.CanQuery=old.query;p.CanTouch=old.touch
			end
		end
		folder:Destroy()
		active[parent]=nil
	end
	-- Explicit controller opt-in; existing preview initialization never opens the city.
	function result.buildContinuousCorridor(): any
		assert(not destroyed, "Destroyed preview handle")
		if corridor then return corridor end
		local spec=Quality.ContinuousCorridor
		Quality.validateCorridor(spec)
		local town=parent:FindFirstChild("City")
		assert(town and town:IsA("Folder"), "Missing existing City")
		assert(not parent:FindFirstChild("CityGreenwoodCorridor"), "Unowned corridor exists")
		local wall: Model? = nil
		for _,child in ipairs(town:GetChildren()) do
			if child:IsA("Model") and child.Name=="CityWall" and (child:GetPivot().Position-Vector3.new(0,0,-625)).Magnitude<.01 then
				assert(wall==nil,"Ambiguous south wall");wall=child
			end
		end
		assert(wall,"Expected existing south wall")
		local kit=game:GetService("ServerStorage"):FindFirstChild("CityKit")
		local archSource=kit and kit:FindFirstChild("CityArch")
		assert(archSource and archSource:IsA("Model"),"Missing original CityArch template")
		local geometry=Instance.new("Model");geometry.Name="CityGreenwoodCorridor"
		geometry:SetAttribute("LocalPreviewOnly",true)
		local gate: Model? = nil
		local expected: {any} = {}
		local floorParts: {BasePart}={}
		local released=false
		local function cleanup()
			if released then return end
			released=true
			if wall and wall.Parent==nil then
				if town.Parent then wall.Parent=town else wall:Destroy() end
			end
			geometry:Destroy();corridor=nil;corridorCleanup=nil
		end
		local success,err=pcall(function()
			local arch=archSource:Clone();gate=arch;arch.Parent=geometry;arch.Name="ContinuousSouthGate"
			arch:PivotTo(CFrame.new(0,0,-625))
			for _,p in ipairs(arch:GetDescendants()) do if p:IsA("BasePart") then
				table.insert(expected,{part=p,parent=p.Parent,size=p.Size,cframe=p.CFrame,query=p.CanQuery,collide=p.CanCollide})
			end end
			assert(#expected==5,"Unexpected original gate structure")
			for _,def in ipairs(spec.parts) do
				local part=Instance.new("WedgePart");part.Name=def.name;part.Anchored=true
				part.Size=Vector3.new(table.unpack(def.size));part.CFrame=CFrame.new(table.unpack(def.cframe))
				part.Color=Color3.new(table.unpack(def.color));part.Material=if def.collision then Enum.Material.Ground else Enum.Material.Grass
				part.CanCollide=def.collision;part.CanQuery=def.collision;part.CanTouch=false;part.CastShadow=false
				part.TopSurface=Enum.SurfaceType.Smooth;part.BottomSurface=Enum.SurfaceType.Smooth;part.Parent=geometry
				if def.collision then
					table.insert(floorParts,part)
					table.insert(expected,{part=part,parent=geometry,size=part.Size,cframe=part.CFrame,query=true,collide=true})
				end
			end
			geometry:SetAttribute("RouteId",spec.id);geometry:SetAttribute("FromZone","City");geometry:SetAttribute("ToZone","Greenwood")
			geometry:SetAttribute("WalkWidth",24);geometry:SetAttribute("NavigationPointKind","FloorCenter")
			geometry:SetAttribute("NavigationBelowFloor",4);geometry:SetAttribute("NavigationAboveFloor",14)
			local navigation=Instance.new("Folder");navigation.Name="NavigationNodes";navigation.Parent=geometry
			for i,point in ipairs(spec.centerline) do
				local value=Instance.new("Vector3Value");value.Name=string.format("%03d",i);value.Value=Vector3.new(table.unpack(point))
				value:SetAttribute("Index",i);value.Parent=navigation
			end
			local function box(def: any): any return {cframe=CFrame.new(table.unpack(def.cframe)),size=Vector3.new(table.unpack(def.size))} end
			local volumes={};for _,def in ipairs(spec.volumes) do table.insert(volumes,box(def)) end
			local route: any={id=spec.id,fromZone="City",toZone="Greenwood",geometry=geometry,volumes=volumes,
				entries={City=box(spec.entries.City),Greenwood=box(spec.entries.Greenwood)},
				safeRecovery={City=CFrame.new(0,5,-720),Greenwood=CFrame.new(0,7,1505)}}
			function route.isReady(): boolean
				if destroyed or released or geometry.Parent~=parent or not gate or gate.Parent~=geometry or not wall or wall.Parent~=nil then return false end
				for _,value in ipairs(expected) do
					local part=value.part
					if part.Parent~=value.parent or not part.Anchored or part.CanCollide~=value.collide or part.CanQuery~=value.query
						or part.Size~=value.size or part.CFrame~=value.cframe then return false end
				end
				return #floorParts==spec.colliderCount
			end
			geometry.Parent=parent
			local ownedWall=wall :: Model
			ownedWall.Parent=nil
			corridorCleanup=cleanup;corridor=route
		end)
		if not success then cleanup();error(tostring(err)) end
		return corridor
	end
	-- Separate opt-in for the second reviewed edge. This owns only its new Model;
	-- no City walls, existing region geometry or travel activation are changed.
	function result.buildGreenwoodIronveilCorridor(): any
		assert(not destroyed, "Destroyed preview handle")
		if ironveilCorridor then return ironveilCorridor end
		local spec=Quality.GreenwoodIronveilCorridor
		Quality.validateCorridor(spec)
		local ironveil=parent:FindFirstChild("Ironveil")
		assert(region.Parent==parent and ironveil and ironveil:IsA("Model"), "Missing corridor regions")
		assert(not parent:FindFirstChild("GreenwoodIronveilCorridor"), "Unowned corridor exists")
		local geometry=Instance.new("Model");geometry.Name="GreenwoodIronveilCorridor"
		local released=false
		local function cleanup()
			if released then return end
			released=true;geometry:Destroy();ironveilCorridor=nil;ironveilCleanup=nil
		end
		local success,err=pcall(function()
			local expected: {any}={}
			local nodes: {any}={}
			local metadata={LocalPreviewOnly=true,RouteId=spec.id,FromZone=spec.fromZone,ToZone=spec.toZone,
				WalkWidth=24,NavigationPointKind="FloorCenter",NavigationBelowFloor=4,NavigationAboveFloor=14}
			for key,value in pairs(metadata) do geometry:SetAttribute(key,value) end
			for _,def in ipairs(spec.parts) do
				local part=Instance.new("WedgePart");part.Name=def.name;part.Anchored=true
				part.Size=Vector3.new(table.unpack(def.size));part.CFrame=CFrame.new(table.unpack(def.cframe))
				part.Color=Color3.new(table.unpack(def.color));part.Material=if def.collision then Enum.Material.Ground else Enum.Material.Grass
				part.CanCollide=def.collision;part.CanQuery=def.collision;part.CanTouch=false;part.CastShadow=false
				part.TopSurface=Enum.SurfaceType.Smooth;part.BottomSurface=Enum.SurfaceType.Smooth;part.Parent=geometry
				table.insert(expected,{part=part,name=part.Name,size=part.Size,cframe=part.CFrame,collision=def.collision})
			end
			local navigation=Instance.new("Folder");navigation.Name="NavigationNodes";navigation.Parent=geometry
			for i,point in ipairs(spec.centerline) do
				local value=Instance.new("Vector3Value");value.Name=string.format("%03d",i);value.Value=Vector3.new(table.unpack(point))
				value:SetAttribute("Index",i);value.Parent=navigation
				table.insert(nodes,{node=value,name=value.Name,value=value.Value,index=i})
			end
			local function box(def: any): any return {cframe=CFrame.new(table.unpack(def.cframe)),size=Vector3.new(table.unpack(def.size))} end
			local volumes={};for _,def in ipairs(spec.volumes) do table.insert(volumes,box(def)) end
			local route: any={id=spec.id,fromZone=spec.fromZone,toZone=spec.toZone,geometry=geometry,ownedModel=geometry,
				volumes=volumes,entries={Greenwood=box(spec.entries.Greenwood),Ironveil=box(spec.entries.Ironveil)},
				safeRecovery={Greenwood=CFrame.new(table.unpack(spec.safeRecovery.Greenwood)),Ironveil=CFrame.new(table.unpack(spec.safeRecovery.Ironveil))}}
			function route.isReady(): boolean
				if destroyed or released or geometry.Parent~=parent or geometry.Name~="GreenwoodIronveilCorridor"
					or parent:FindFirstChild("Greenwood")~=region or parent:FindFirstChild("Ironveil")~=ironveil then return false end
				if #geometry:GetChildren()~=#expected+1 or #geometry:GetDescendants()~=#expected+1+#nodes then return false end
				for key,value in pairs(metadata) do if geometry:GetAttribute(key)~=value then return false end end
				local colliders=0
				for _,record in ipairs(expected) do
					local part=record.part
					if part.Parent~=geometry or part.Name~=record.name or not part.Anchored or part.CanTouch
						or part.CanCollide~=record.collision or part.CanQuery~=record.collision
						or part.Size~=record.size or part.CFrame~=record.cframe then return false end
					if record.collision then colliders+=1 end
				end
				if navigation.Parent~=geometry or navigation.Name~="NavigationNodes" or #navigation:GetChildren()~=#nodes then return false end
				for _,record in ipairs(nodes) do
					local node=record.node
					if node.Parent~=navigation or node.Name~=record.name or node.Value~=record.value or node:GetAttribute("Index")~=record.index then return false end
				end
				return colliders==spec.colliderCount
			end
			route.destroy=cleanup
			geometry.Parent=parent;ironveilCleanup=cleanup;ironveilCorridor=route
		end)
		if not success then cleanup();error(tostring(err)) end
		return ironveilCorridor
	end
	local ok,problem=pcall(function()
		folder:SetAttribute("LocalPreviewOnly",true)
		folder:SetAttribute("SourceMeshSha256",data.sourceMeshSha256)
		folder.Parent=region
		for _,c in ipairs(data.colliders) do
			local part: BasePart=if c.kind=="WedgePart" then Instance.new("WedgePart") else Instance.new("Part")
			part.Name=c.name;part.Anchored=true;part.Transparency=1
			part.Size=Vector3.new(c.size[1],c.size[2],c.size[3]);part.CFrame=CFrame.new(table.unpack(c.cframe))
			part.CanCollide=true;part.CanQuery=true;part.CanTouch=false;part.Parent=folder
			if c.name=="StableApron" then
				local ground=region:FindFirstChild("Island")
				if ground and ground:IsA("BasePart") then part.Color=ground.Color;part.Material=ground.Material;part.Transparency=0 end
			end
			result.colliders+=1
		end
		for _,child in ipairs(region:GetChildren()) do
			if child:IsA("BasePart") and Quality.isDecoration(child.Name,child.ClassName) then
				table.insert(changed,{part=child,collide=child.CanCollide,query=child.CanQuery,touch=child.CanTouch})
				child.CanCollide=false;child.CanQuery=false;child.CanTouch=false
				result.disabledDecorationPhysics+=1
			end
		end
	end)
	if not ok then result.destroy();error(tostring(problem)) end
	active[parent]=result
	return result
end
