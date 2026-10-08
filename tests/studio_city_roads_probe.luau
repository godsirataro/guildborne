--!strict
-- Read-only traversability sampling, including both sides of a four-stud walking corridor.
return function(): any
	local town=workspace.GuildborneWorld.City
	local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={town};params.RespectCanCollide=true
	local report={};local blocked={};local samples=0
	for _,entry in ipairs(town.Roads:GetChildren()) do
		assert(entry:IsA("BasePart"));local road=entry :: BasePart
		local steps=math.ceil(road.Size.Z/4);local collisions=0
		for i=0,steps do
			local pos=road.CFrame:PointToWorldSpace(Vector3.new(0,4.4,-road.Size.Z/2+road.Size.Z*i/steps))
			local hits=workspace:GetPartBoundsInBox(CFrame.new(pos),Vector3.new(4,5,4),params)
			for _,part in ipairs(hits) do collisions+=1;blocked[part:GetFullName()]=true end;samples+=1
		end
		table.insert(report,{road=road.Name,collisions=collisions})
	end
	local paths={};for path in pairs(blocked) do table.insert(paths,path) end;table.sort(paths)
	assert(#paths==0,table.concat(paths,"\n"))
	return {roads=#report,samples=samples,blocked=0,corridorWidth=4,checkHeight=5,readOnly=true}
end
