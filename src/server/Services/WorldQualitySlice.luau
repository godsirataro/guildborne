--!strict
-- Explicit standalone preview only. Nothing in normal bootstrap invokes this.
local Quality=require(game.ReplicatedStorage.Shared.Config.WorldQuality)
local Runtime=require(script.Parent.Parent.Config.Runtime)
local active: {[Instance]: any} = {}
return function(parent: Instance): any
	assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0, "Standalone Studio only")
	assert(Runtime.StudioPersistence=="Memory" and next(Runtime.AllowedDataStoreUniverses)==nil, "Memory-only preview required")
	if active[parent] then return active[parent] end
	local data=require(script.Parent.WorldQualityAssets)
	Quality.validate(data)
	local region=parent:FindFirstChild("Greenwood")
	assert(region and region:IsA("Model"), "Missing existing Greenwood")
	local art=parent:FindFirstChild("QualitySourceArt")
	assert(art and art:IsA("Folder") and art:GetAttribute("LocalPreviewOnly")==true, "Import reviewed source art first")
	for _,name in ipairs(data.expectedArtNames) do
		local part=art:FindFirstChild(name)
		assert(part and part:IsA("MeshPart") and type(part:GetAttribute("SourceMeshId"))=="string", "Missing imported art: "..name)
	end
	-- Fail before hiding anything when an older art placement is still loaded.
	for _,expected in ipairs(data.expectedArt or {}) do
		local part=art:FindFirstChild(expected.name) :: MeshPart
		assert(part:GetAttribute("SourceMeshId")==expected.meshId,"Wrong mesh revision: "..expected.name)
		assert((part.Position-Vector3.new(table.unpack(expected.position))).Magnitude<.1,"Art position differs: "..expected.name)
		local components={part.CFrame:GetComponents()}
		for i,value in ipairs(expected.rotation) do assert(math.abs(components[i+3]-value)<.001,"Art rotation differs: "..expected.name) end
	end
	assert(not region:FindFirstChild("WorldQualityCollision"), "Unowned quality collision already exists")
	local changed: {any} = {}
	local folder=Instance.new("Folder")
	folder.Name="WorldQualityCollision"
	local result: any={folder=folder,hiddenDecorations=0,colliders=0,sourceMeshSha256=data.sourceMeshSha256}
	local destroyed=false
	function result.destroy()
		if destroyed then return end
		destroyed=true
		for _,old in ipairs(changed) do
			local p=old.part
			if p.Parent then
				p.Transparency=old.transparency;p.CanCollide=old.collide;p.CanQuery=old.query;p.CanTouch=old.touch
			end
		end
		folder:Destroy()
		active[parent]=nil
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
				table.insert(changed,{part=child,transparency=child.Transparency,collide=child.CanCollide,query=child.CanQuery,touch=child.CanTouch})
				child.Transparency=1;child.CanCollide=false;child.CanQuery=false;child.CanTouch=false
				result.hiddenDecorations+=1
			end
		end
	end)
	if not ok then result.destroy();error(tostring(problem)) end
	active[parent]=result
	return result
end
