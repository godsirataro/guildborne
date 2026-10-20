--!strict
-- Read-only sampler for the isolated player-only weapon/action lab.
-- Does not move actors, send commands, grant rewards or alter animation.
local Run = game:GetService("RunService")
local Adapter = require(game.ReplicatedStorage.Shared.Presentation.ModularAppearance.LocalActorPreview)
local Preview = require(game.ReplicatedStorage.Shared.Presentation.ModularAppearance.LocalGeometryPreview)
local Probe = { Samples = {} :: {any}, Running = false, Label = "" }
local originals: {[Model]: any} = {}
function Probe.Remember(actor: Model)
	assert(not originals[actor],"ALREADY_CAPTURED")
	local entry:any={parts={},welds={},decals={},root=actor:FindFirstChild("HumanoidRootPart"),humanoid=actor:FindFirstChildOfClass("Humanoid"),gear=actor:FindFirstChild("EquippedWeapon")}
	for _,v in actor:GetDescendants() do
		if v:IsA("BasePart") then
			entry.parts[v]={size=v.Size,anchored=v.Anchored,massless=v.Massless,collide=v.CanCollide,touch=v.CanTouch,query=v.CanQuery,group=v.CollisionGroup,ltm=v.LocalTransparencyModifier,transparency=v.Transparency,parent=v.Parent}
		elseif v:IsA("WeldConstraint") then entry.welds[v]={p0=v.Part0,p1=v.Part1,parent=v.Parent}
		elseif v:IsA("Decal") then entry.decals[v]=v.Transparency end
	end
	originals[actor]=entry
end
function Probe.Compare(actor: Model, restored: boolean): any
	local entry=originals[actor];assert(entry,"ORIGINAL_CAPTURE_REQUIRED")
	local errors={};local parts,weapons,welds=0,0,0
	if actor:FindFirstChild("HumanoidRootPart")~=entry.root or actor:FindFirstChildOfClass("Humanoid")~=entry.humanoid or actor:FindFirstChild("EquippedWeapon")~=entry.gear then table.insert(errors,"IDENTITY_CHANGED") end
	for v,p in entry.parts do
		parts+=1
		if v.Parent~=p.parent or v.Size~=p.size or v.Anchored~=p.anchored or v.Massless~=p.massless or v.CanCollide~=p.collide or v.CanTouch~=p.touch or v.CanQuery~=p.query or v.CollisionGroup~=p.group or v.Transparency~=p.transparency then table.insert(errors,v.Name..":PHYSICS_OR_STRUCTURE_CHANGED") end
		local weapon=entry.gear and v:IsDescendantOf(entry.gear)
		if weapon then weapons+=1 end
		local handle=Adapter.Get(actor)
		local presentation=if handle then handle:GetWeaponModel() else nil
		local expected=if not restored and weapon and presentation then 1 else p.ltm
		if (restored or weapon) and v.LocalTransparencyModifier~=expected then table.insert(errors,v.Name..":LTM_POLICY_MISMATCH") end
	end
	for v,p in entry.welds do welds+=1;if v.Parent~=p.parent or v.Part0~=p.p0 or v.Part1~=p.p1 then table.insert(errors,"WELD_CHANGED") end end
	if restored then for v,t in entry.decals do if v.Transparency~=t then table.insert(errors,"DECAL_NOT_RESTORED") end end end
	return {actor=actor:GetFullName(),restored=restored,parts=parts,weaponParts=weapons,welds=welds,errors=errors}
end
local function vector(v: Vector3): {number} return {v.X,v.Y,v.Z} end
local function frame(v: CFrame): {number} return {v:GetComponents()} end
local function boxDistance(part: BasePart, point: Vector3): number
	local p = part.CFrame:PointToObjectSpace(point)
	local h = part.Size / 2
	return Vector3.new(math.max(0,math.abs(p.X)-h.X),math.max(0,math.abs(p.Y)-h.Y),math.max(0,math.abs(p.Z)-h.Z)).Magnitude
end
function Probe.Capture(): any
	assert(Run:IsStudio() and Run:IsClient() and game.PlaceId==0 and game.GameId==0)
	local lab = workspace:FindFirstChild("PartyPresentationLab")
	assert(lab and lab:GetAttribute("Synthetic")==true and lab:GetAttribute("Ready")==true)
	assert(lab:GetAttribute("PlayerOnlyCombatProbe")==true and lab:GetAttribute("CompanionCount")==0,"PLAYER_ONLY_FIXTURE_REQUIRED")
	for _,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") then assert(v:GetAttribute("GuildborneHero")~=true,"COMPANION_PRESENT") end
	end
	local actor = game.Players.LocalPlayer.Character :: Model
	local handle = Adapter.Get(actor)
	assert(handle,"PLAYER_PREVIEW_REQUIRED")
	local root = actor:FindFirstChild("HumanoidRootPart") :: BasePart
	local hand = handle.Model:FindFirstChild("RightHand") :: BasePart
	local socket = hand:FindFirstChild("RightGripAttachment") :: Attachment
	assert(socket and socket:GetAttribute("SourceDerived")==true,"SOURCE_GRIP_REQUIRED")
	local gear = actor:FindFirstChild("EquippedWeapon") :: Model
	local grip = gear:FindFirstChild("Grip") :: BasePart
	assert(actor:GetAttribute("WeaponId")=="training_sword" and grip,"EXISTING_TRAINING_SWORD_REQUIRED")
	local weld = grip:FindFirstChildWhichIsA("WeldConstraint") :: WeldConstraint
	assert(weld and weld.Part0 and weld.Part1==grip,"EXISTING_WEAPON_WELD_REQUIRED")
	local displayed=handle:GetWeaponModel();assert(displayed,"DISPLAY_WEAPON_REQUIRED")
	local displayedGrip=displayed:FindFirstChild("Grip") :: BasePart
	local displayDelta=socket.WorldCFrame:ToObjectSpace(displayedGrip.CFrame)
	local _,displayAngle=displayDelta:ToAxisAngle()
	local delta = socket.WorldCFrame:ToObjectSpace(grip.CFrame)
	local _,angle = delta:ToAxisAngle()
	local row:any = {
		t=workspace:GetServerTimeNow(),root=vector(root.Position),sourceSocket=frame(socket.WorldCFrame),
		displayGrip=frame(displayedGrip.CFrame),displaySocketCenter=displayDelta.Position.Magnitude,displaySocketBoxGap=boxDistance(displayedGrip,socket.WorldPosition),displayRelativeAngle=displayAngle,displayGripTransparency=displayedGrip.Transparency,displayGripLTM=displayedGrip.LocalTransparencyModifier,
		originalHand=frame((weld.Part0 :: BasePart).CFrame),grip=frame(grip.CFrame),gripSize=vector(grip.Size),
		socketToGripCenter=delta.Position.Magnitude,socketToGripBox=boxDistance(grip,socket.WorldPosition),
		relativeAngle=angle,handCenterToGripBox=boxDistance(grip,hand.Position),
		weaponLTM=grip.LocalTransparencyModifier,weaponTransparency=grip.Transparency,
		actionAt=actor:GetAttribute("ActionAt"),actionEffect=actor:GetAttribute("ActionEffect"),
		basicAttackCount=actor:GetAttribute("BasicAttackCount"),damageDealt=actor:GetAttribute("DamageDealt"),
		health=actor:GetAttribute("CombatHealth"),references=Preview.ResourceCount(),backings=Preview.BackingResourceCount(),
		joints={},diagnostics=handle:GetDiagnostics(),
	}
	for _,name in {"RightShoulder","RightElbow","RightWrist","LeftKnee","RightKnee"} do
		local joint = handle.Model:FindFirstChild(name,true) :: Motor6D
		assert(joint and joint:IsA("Motor6D"))
		row.joints[name]={c0=frame(joint.C0),transform=frame(joint.Transform)}
	end
	local target=actor:GetAttribute("ActionTargetPosition")
	if typeof(target)=="Vector3" then
		row.actionTarget=vector(target)
		local blade=gear:FindFirstChild("Blade") :: BasePart
		local point=gear:FindFirstChild("Point") :: BasePart
		row.bladeBoxToTarget=boxDistance(blade,target)
		row.pointBoxToTarget=boxDistance(point,target)
		row.displayBladeBoxToTarget=boxDistance(displayed:FindFirstChild("Blade") :: BasePart,target)
		row.displayPointBoxToTarget=boxDistance(displayed:FindFirstChild("Point") :: BasePart,target)
	end
	return row
end
function Probe.Start(label: string, seconds: number, interval: number): number
	assert(not Probe.Running and seconds>0 and seconds<=15 and interval>=1/120 and interval<=.25)
	Probe.Samples={};Probe.Label=label;Probe.Running=true
	local stop=os.clock()+seconds
	local nextSample=0
	local connection: RBXScriptConnection?=nil
	connection=Run.RenderStepped:Connect(function()
		local now=os.clock()
		if not Probe.Running or now>=stop then
			Probe.Running=false;if connection then connection:Disconnect() end;return
		end
		if now<nextSample then return end
		nextSample=now+interval
		-- Observe after the adapter's render callbacks; never reposition it for the test.
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
