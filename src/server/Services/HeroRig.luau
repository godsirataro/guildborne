--!strict
-- Small original R6-style fantasy rigs. No asset downloads or per-NPC scripts.
local Art = require(game.ReplicatedStorage.Shared.Config.Art)
local Content = require(script.Parent.Parent.Config.Content)
local WeaponVisuals = require(script.Parent.WeaponVisuals)
local C = Art.Palette
local V = Vector3.new
local Rig = {}
function Rig.Build(class: string, templateId: string?): Model
	local m = Instance.new("Model"); m.Name = class
	local function part(name: string, size: Vector3, position: Vector3, color: Color3): Part
		local p = Instance.new("Part"); p.Name=name; p.Size=size; p.Position=position; p.Color=color
		p.Material=Enum.Material.SmoothPlastic; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
		p.Massless=true; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
		p.CollisionGroup="GuildborneHeroes"; p.Parent=m; return p
	end
	local skin=Color3.fromRGB(211,167,126)
	local cloth=if class=="Warrior" then C.Roof elseif class=="Archer" then C.Leaf elseif class=="Knight" then Color3.fromRGB(62,81,111) elseif class=="Mage" then Color3.fromRGB(87,67,118) else C.Parchment
	local root=part("HumanoidRootPart",V(1.5,2,1.3),V(0,3,0),cloth)
	root.Transparency=1; root.Massless=false; root.Anchored=true; root.CanCollide=true
	local torso=part("Torso",V(2,2,1),V(0,3,0),cloth)
	local head=part("Head",V(1.25,1.15,1.15),V(0,4.6,0),skin)
	local leftArm=part("Left Arm",V(.65,1.9,.75),V(-1.4,3,0),cloth)
	local rightArm=part("Right Arm",V(.65,1.9,.75),V(1.4,3,0),cloth)
	local leftLeg=part("Left Leg",V(.8,2,.8),V(-.5,1,0),C.Wood)
	local rightLeg=part("Right Leg",V(.8,2,.8),V(.5,1,0),C.Wood)
	local function joint(name: string, a: BasePart, b: BasePart, offset: Vector3)
		local j=Instance.new("Motor6D"); j.Name=name; j.Part0=a; j.Part1=b
		j.C0=CFrame.new(offset); j.C1=b.CFrame:ToObjectSpace(a.CFrame*j.C0); j.Parent=a
	end
	joint("RootJoint",root,torso,V(0,0,0)); joint("Neck",torso,head,V(0,1,0))
	joint("Left Shoulder",torso,leftArm,V(-1.4,.8,0)); joint("Right Shoulder",torso,rightArm,V(1.4,.8,0))
	joint("Left Hip",torso,leftLeg,V(-.5,-1,0)); joint("Right Hip",torso,rightLeg,V(.5,-1,0))
	local function detail(name: string, size: Vector3, position: Vector3, color: Color3, limb: BasePart?): Part
		local p=part(name,size,position,color)
		local weld=Instance.new("WeldConstraint"); weld.Part0=limb or torso; weld.Part1=p; weld.Parent=p
		return p
	end
	for _,side in ipairs({-1,1}) do
		detail("Eye",V(.12,.14,.06),V(side*.26,4.65,-.6),Art.UI.Background,head)
		detail("Hand",V(.62,.42,.72),V(side*1.4,2.05,0),skin,if side==-1 then leftArm else rightArm)
		detail("Boot",V(.86,.48,1),V(side*.5,.25,-.1),C.Wood,if side==-1 then leftLeg else rightLeg)
	end
	detail("Belt",V(2.08,.22,1.08),V(0,2.3,0),C.Wood)
	detail("GuildClasp",V(.32,.4,.12),V(0,3.6,-.57),C.Gold)
	if class=="Warrior" or class=="Knight" then
		detail("Breastplate",V(1.5,1.2,.24),V(0,3.25,-.57),C.Iron)
		for _,side in ipairs({-1,1}) do detail("Pauldron",V(.95,.55,1),V(side*1.4,3.8,0),C.Iron,if side==-1 then leftArm else rightArm) end
		detail("Helmet",V(1.4,.4,1.3),V(0,5.08,0),C.Iron,head)
		detail("HelmetRidge",V(.22,.25,1.35),V(0,5.36,0),C.Gold,head)
		if class=="Knight" then
			detail("GreatHelm",V(1.42,.55,.25),V(0,4.37,-.66),C.Iron,head)
			detail("Tabard",V(1.25,1.2,.2),V(0,1.95,-.65),cloth)
			detail("Mantle",V(2,2.8,.22),V(0,2.7,.67),cloth)
		end
	elseif class=="Archer" then
		detail("Hood",V(1.4,.4,1.35),V(0,5.08,.05),C.Leaf,head)
		detail("HoodBack",V(1.4,1.1,.3),V(0,4.55,.65),C.Leaf,head)
		detail("Cloak",V(1.8,2.7,.22),V(0,2.8,.65),C.Leaf)
		detail("Quiver",V(.65,1.8,.6),V(.7,3.2,.95),C.Timber)
		for _,x in ipairs({.5,.75,.95}) do detail("Arrow",V(.06,1,.06),V(x,4.3,.95),C.Parchment) end
	elseif class=="Priest" then
		detail("RobeSkirt",V(1.9,1.3,1.1),V(0,1.8,0),C.Parchment)
		for _,side in ipairs({-1,1}) do detail("Stole",V(.3,2.5,.15),V(side*.6,2.85,-.63),C.Roof) end
		detail("Hair",V(1.3,.32,1.2),V(0,5.08,.08),Color3.fromRGB(187,184,166),head)
		detail("Circlet",V(1.35,.15,1.27),V(0,4.99,0),C.Gold,head)
	else
		detail("MageRobe",V(1.9,1.2,1.1),V(0,1.75,0),cloth)
		detail("HatBrim",V(2,.18,1.8),V(0,5.15,0),cloth,head)
		detail("HatCrown",V(1,.8,1),V(0,5.6,0),cloth,head)
		detail("HatTip",V(.55,.6,.55),V(.15,6.25,0),cloth,head)
		detail("HatBand",V(1.05,.18,1.05),V(0,5.3,0),C.Gold,head)
	end
	local h=Instance.new("Humanoid"); h.Name="Humanoid"; h.RigType=Enum.HumanoidRigType.R6
	h.WalkSpeed=17; h.MaxHealth=100; h.Health=100; h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
	h.BreakJointsOnDeath=false; h.RequiresNeck=false; h.Parent=m
	m.PrimaryPart=root
	if templateId then require(script.Parent.HeroAppearance)(m,templateId) end
	return m
end
function Rig.Equip(model: Model, weapon: string?, templates: Folder)
	local old=model:FindFirstChild("EquippedWeapon"); if old then old:Destroy() end
	model:SetAttribute("WeaponId",weapon)
	if not weapon then return end
	local def=Content.Items[weapon]
	local bow=def and def.Class=="Archer"
	local staff=def and (def.Class=="Mage" or def.Class=="Priest")
	local name=if bow then "TrainingBow" elseif staff then "PriestStaff" else "IronSword"
	local source=templates:FindFirstChild(name) :: Model
	local custom=WeaponVisuals(weapon)
	local gear=custom or source:Clone(); gear.Name="EquippedWeapon"; gear:ScaleTo(.65)
	local arm=(model:FindFirstChild("RightHand") or model:FindFirstChild("Right Arm")) :: BasePart?
	if not arm then gear:Destroy(); return end
	local grip=gear:FindFirstChild("Grip") or gear:FindFirstChild("Shaft")
	if grip and grip:IsA("BasePart") then
		gear.PrimaryPart=grip;gear:PivotTo(arm.CFrame*CFrame.new(0,-arm.Size.Y*.35,-.3))
	else gear:PivotTo(arm.CFrame*CFrame.new(if bow then -.5 else 0,-1.45,-.55)) end
	for _,p in ipairs(gear:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored=false; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Massless=true
			p.CollisionGroup="GuildborneHeroes"
			if weapon=="training_sword" and (p.Name=="Blade" or p.Name=="Point") then p.Color=C.Timber; p.Material=Enum.Material.Wood end
			if weapon=="mage_staff" and p.Name=="Focus" then p.Color=Color3.fromRGB(161,131,222) end
			if not custom and def and def.Tint and (p.Name=="Focus" or p.Name=="Blade" or p.Name=="Point" or bow) then p.Color=Color3.fromRGB(def.Tint[1],def.Tint[2],def.Tint[3]) end
			local weld=Instance.new("WeldConstraint"); weld.Part0=arm; weld.Part1=p; weld.Parent=p
		end
	end
	gear.Parent=model
end
function Rig.Outfit(model: Model, armor: string?, accessory: string?)
	require(script.Parent.WardrobeVisuals)(model,armor,accessory)
end
function Rig.Race(model: Model,race: string)
	if model:GetAttribute("RenderedRace")==race then return end
	local head=model:FindFirstChild("Head") :: BasePart?;if not head then return end
	local old=model:FindFirstChild("AncestryVisual");if old then old:Destroy() end
	local folder=Instance.new("Folder");folder.Name="AncestryVisual";folder.Parent=model
	if race~="Human" then
		for _,side in ipairs({-1,1}) do
			local p=Instance.new("Part");p.Name=if race=="Elf" then "ElvenEar" else "DwarvenBraid"
			p.Size=if race=="Elf" then Vector3.new(.55,.18,.25) else Vector3.new(.28,.85,.32)
			p.Color=if race=="Elf" then head.Color else Color3.fromRGB(106,70,46)
			p.CFrame=head.CFrame*CFrame.new(side*(if race=="Elf" then head.Size.X*.55 else .25),if race=="Elf" then .1 else -.6,if race=="Elf" then 0 else -.45)*CFrame.Angles(0,0,side*.25)
			p.Massless=true;p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=folder
			local w=Instance.new("WeldConstraint");w.Part0=head;w.Part1=p;w.Parent=p
		end
	end
	model:SetAttribute("RenderedRace",race)
end
return Rig
