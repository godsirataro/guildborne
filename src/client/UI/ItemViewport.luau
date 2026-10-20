--!strict
local build=require(game.ReplicatedStorage.Shared.Data.ItemVisuals)
return function(parent: Instance,id: string,edge: number?): ViewportFrame?
	local model=build(id);if not model then return nil end
	local pixels=edge or 80
	if pixels~=pixels or pixels==math.huge or pixels==-math.huge then pixels=80 end
	pixels=math.clamp(pixels,16,512)
	local view=Instance.new("ViewportFrame");view.Name="ItemPreview";view.Size=UDim2.fromOffset(pixels,pixels)
	view.BackgroundTransparency=1;view.Ambient=Color3.fromRGB(190,190,190);view.LightColor=Color3.new(1,1,.95);view.LightDirection=Vector3.new(-1,-2,-3)
	local world=Instance.new("WorldModel");world.Parent=view;model.Parent=world
	local bounds,size=model:GetBoundingBox();local radius=size.Magnitude/2
	local camera=Instance.new("Camera");camera.FieldOfView=35
	local direction=Vector3.new(1,.4,-3).Unit
	camera.CFrame=CFrame.lookAt(bounds.Position+direction*(radius/math.sin(math.rad(17.5))*1.12),bounds.Position)
	camera.Parent=view;view.CurrentCamera=camera;view:SetAttribute("ItemId",id);view.Parent=parent
	return view
end
