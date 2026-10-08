--!strict
-- Bounded static portraits of replicated actors; no source actor mutation or live rig.
local V=Vector3.new
return function(parent: Instance)
	local view=Instance.new("ViewportFrame");view.Name="Portrait";view.Size=UDim2.fromOffset(38,38);view.Position=UDim2.fromOffset(3,3)
	view.BackgroundTransparency=1;view.Active=false;view.Ambient=Color3.fromRGB(190,195,210)
	view.LightColor=Color3.fromRGB(255,232,199);view.LightDirection=V(-1,-1,-1);view.Parent=parent
	local camera=Instance.new("Camera");camera.FieldOfView=32;camera.Parent=view;view.CurrentCamera=camera
	local world=Instance.new("WorldModel");world.Parent=view
	local lastSource: Model?=nil;local signature="";local partCount=0
	local api={}
	function api.update(source: Model?)
		local head=source and source:FindFirstChild("Head")
		if not source or not head or not head:IsA("BasePart") then
			if lastSource then world:ClearAllChildren();lastSource=nil;signature="";partCount=0 end
			view.Visible=false;return
		end
		view.Visible=true
		local key=tostring(source:GetAttribute("ClassId"))..":"..tostring(source:GetAttribute("RaceId"))..":"..tostring(source:GetAttribute("ArmorId"))..":"..tostring(source:GetAttribute("AccessoryId"))..":"..tostring(source:GetAttribute("WeaponId"))..":"..tostring(source:GetAttribute("VisualTemplateId"))..":"..#source:GetChildren()
		if source==lastSource and signature==key then return end
		world:ClearAllChildren();lastSource=source;signature=key;partCount=0
		local low=V(-head.Size.X/2,-head.Size.Y/2,-head.Size.Z/2)
		local high=-low
		for _,part in ipairs(source:GetDescendants()) do
			if partCount>=64 then break end
			if not part:IsA("BasePart") or part.Transparency>=1 or (part.Position-head.Position).Magnitude>4 then continue end
			local copy=part:Clone();if not copy then continue end
			for _,child in ipairs(copy:GetDescendants()) do
				if not (child:IsA("SpecialMesh") or child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance")) then child:Destroy() end
			end
			copy.Anchored=true;copy.CanCollide=false;copy.CanTouch=false;copy.CanQuery=false;copy.LocalTransparencyModifier=0
			copy.CFrame=head.CFrame:ToObjectSpace(part.CFrame);copy.Parent=world;partCount+=1
			-- Frame the head and its accessories, keeping taller hats/crests inside the portrait.
			if copy.Position.Y>=-.65 then
				for _,x in ipairs({-.5,.5}) do for _,y in ipairs({-.5,.5}) do for _,z in ipairs({-.5,.5}) do
					local point=copy.CFrame:PointToWorldSpace(copy.Size*V(x,y,z))
					low=V(math.min(low.X,point.X),math.min(low.Y,point.Y),math.min(low.Z,point.Z))
					high=V(math.max(high.X,point.X),math.max(high.Y,point.Y),math.max(high.Z,point.Z))
				end end end
			end
		end
		local center=(low+high)/2;local size=high-low
		local distance=math.max(3.5,math.max(size.X,size.Y)*.575/math.tan(math.rad(camera.FieldOfView/2)))
		camera.CFrame=CFrame.lookAt(V(center.X,center.Y,low.Z-distance),center)
		view:SetAttribute("PortraitParts",partCount)
	end
	function api.destroy() view:Destroy();lastSource=nil end
	return api
end
