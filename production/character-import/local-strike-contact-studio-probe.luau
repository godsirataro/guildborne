--!strict
-- Read-only Blade-versus-visible-Block surface sampler for the player-only lab.
-- Wedge Point and hidden combat proxies are deliberately not approximated.
local Run=game:GetService("RunService")
local modules=game.ReplicatedStorage.Shared.Presentation.ModularAppearance
local Base=require(modules.FoundationWeaponActionProbe)
local Adapter=require(modules.LocalActorPreview)
local Geometry=require(modules.LocalContactGeometry)
local Probe={Samples={} :: {any},Running=false,Label=""}
local target: Model?=nil
local parts: {BasePart}={}
local partSet: {[BasePart]: boolean}={}
local bodyNames={Boot=true,Leg=true,Arm=true,PointedEar=true,Eye=true,Tunic=true,Belt=true,Head=true,Nose=true}
function Probe.BindTarget(model: Model): any
	assert(not Probe.Running and Run:IsStudio() and Run:IsClient() and game.PlaceId==0 and game.GameId==0)
	assert(model:IsDescendantOf(workspace) and model:GetAttribute("GuildborneEnemy")==true
		and model:GetAttribute("OwnerUserId")==game.Players.LocalPlayer.UserId,"OWNED_LAB_ENEMY_REQUIRED")
	local candidate: {BasePart}={}
	for _,v in ipairs(model:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency<1 and v.LocalTransparencyModifier<1 then
			assert(v.Parent==model and bodyNames[v.Name] and v:IsA("Part") and v.Shape==Enum.PartType.Block
				and not v:FindFirstChildWhichIsA("DataModelMesh"),"EXACT_VISIBLE_BLOCK_BODY_REQUIRED")
			table.insert(candidate,v)
		end
	end
	assert(#candidate>0,"VISIBLE_BODY_REQUIRED")
	parts=candidate;target=model;partSet={}
	for _,part in ipairs(parts) do partSet[part]=true end
	return {target=model:GetFullName(),visibleBlocks=#parts,scope="EXACT_BLADE_BLOCK_TO_VISIBLE_BODY_BLOCKS",point="UNSUPPORTED_WEDGE_NOT_APPROXIMATED"}
end
function Probe.Capture(): any
	local started=os.clock()
	local row=Base.Capture()
	assert(target and target:IsDescendantOf(workspace),"BOUND_TARGET_REMOVED")
	assert(target:GetAttribute("GuildborneEnemy")==true
		and target:GetAttribute("OwnerUserId")==game.Players.LocalPlayer.UserId,"TARGET_IDENTITY_CHANGED")
	local visible=0
	for _,v in ipairs(target:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency<1 and v.LocalTransparencyModifier<1 then
			assert(partSet[v],"VISIBLE_TARGET_MEMBERSHIP_CHANGED");visible+=1
		end
	end
	assert(visible==#parts,"VISIBLE_TARGET_MEMBERSHIP_CHANGED")
	local handle=Adapter.Get(game.Players.LocalPlayer.Character :: Model);assert(handle)
	local weapon=handle:GetWeaponModel();assert(weapon)
	local blade=weapon:FindFirstChild("Blade") :: BasePart
	local closest:any=nil
	local bodies={};local intersections={}
	for index,part in ipairs(parts) do
		assert(part.Parent==target and part.Transparency<1 and part.LocalTransparencyModifier<1,"TARGET_SURFACE_CHANGED")
		local measured=Geometry.MeasureParts(blade,part)
		assert(measured.supported,"UNSUPPORTED_TARGET_SURFACE:"..tostring(measured.status))
		local item={index=index,name=part.Name,gap=measured.gap,intersects=measured.intersects,
			cf={part.CFrame:GetComponents()},size={part.Size.X,part.Size.Y,part.Size.Z}}
		table.insert(bodies,item)
		if measured.intersects then table.insert(intersections,index) end
		if not closest or measured.gap<closest.gap then closest={index=index,name=part.Name,gap=measured.gap,
			witnessA=measured.witnessA,witnessB=measured.witnessB} end
	end
	row.surface={target=target:GetFullName(),targetHealth=target:GetAttribute("CombatHealth"),visibleBlocks=#parts,
		bladeCF={blade.CFrame:GetComponents()},bladeSize={blade.Size.X,blade.Size.Y,blade.Size.Z},
		closest=closest,intersections=intersections,bodies=bodies,pointSupported=false}
	row.captureSeconds=os.clock()-started
	return row
end
function Probe.Start(label: string,seconds: number,interval: number): number
	assert(not Probe.Running and target and seconds>0 and seconds<=10 and interval>=1/120 and interval<=.25)
	Probe.Samples={};Probe.Running=true;Probe.Label=label
	local deadline=os.clock()+seconds;local nextSample=0
	local connection: RBXScriptConnection?=nil
	connection=Run.RenderStepped:Connect(function()
		local now=os.clock()
		if not Probe.Running or now>=deadline then Probe.Running=false;if connection then connection:Disconnect() end;return end
		if now<nextSample then return end;nextSample=now+interval
		task.defer(function()
			if not Probe.Running then return end
			local ok,result=pcall(Probe.Capture)
			if ok then table.insert(Probe.Samples,result) else
				Probe.Running=false;Probe.Label=label..":FAILED:"..tostring(result)
				if connection then connection:Disconnect() end
			end
		end)
	end)
	return seconds
end
return Probe
