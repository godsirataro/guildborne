--!strict
-- Original native geometry: silhouettes remain distinct without imported asset IDs.
local V=Vector3.new
local stone=Color3.fromRGB(80,91,113)
local steel=Color3.fromRGB(128,145,163)
local gold=Color3.fromRGB(196,157,78)
local violet=Color3.fromRGB(133,109,177)
local blue=Color3.fromRGB(91,179,203)
return function(model: Model,role: string)
	local folder=Instance.new("Folder");folder.Name="EnemyAppearance";folder.Parent=model
	local function piece(name: string,size: Vector3,position: Vector3,color: Color3,angle: number?,neon: boolean?): Part
		local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=CFrame.new(position)*CFrame.Angles(0,0,angle or 0)
		p.Color=color;p.Material=if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
		p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=not neon;p.Parent=folder;return p
	end
	local boss=role=="Spire Warden"
	local ranged=role=="Echo Archer"
	local tint=if boss then gold elseif ranged then blue else violet
	for _,side in ipairs({-1,1}) do
		piece("Boot",V(.7,.5,1),V(side*.48,.3,-.1),stone)
		piece("Greave",V(.58,1.1,.65),V(side*.48,1.05,0),steel)
		piece("Arm",V(.52,1.5,.65),V(side*1.1,2.4,0),stone,side*.12)
		piece("Shoulder",V(if boss then 1.3 else .8,.55,1.1),V(side*1.1,3.05,0),tint,side*.14)
		piece("Eye",V(.22,.13,.08),V(side*.3,3.85,-.66),tint,nil,true)
	end
	piece("Torso",V(1.65,1.65,.95),V(0,2.2,0),stone)
	piece("ChestPlate",V(1.25,1.05,.2),V(0,2.35,-.56),steel)
	piece("ChestRune",V(.2,.65,.08),V(0,2.4,-.71),tint,nil,true)
	piece("Belt",V(1.75,.24,1.02),V(0,1.58,0),tint)
	piece("Helm",V(1.3,1.15,1.15),V(0,3.7,0),stone)
	piece("Brow",V(1.5,.18,.25),V(0,4,-.59),steel)
	piece("Cape",V(1.5,2.3,.16),V(0,2.25,.61),if ranged then Color3.fromRGB(44,80,96) else Color3.fromRGB(72,55,99))
	if boss then
		for _,side in ipairs({-1,1}) do piece("CrownProng",V(.23,.85,.35),V(side*.58,4.43,0),gold,-side*.2) end
		piece("CrownCenter",V(.28,.7,.35),V(0,4.35,-.5),gold)
		piece("HammerShaft",V(.18,3.1,.18),V(1.48,1.8,-.2),steel)
		piece("HammerHead",V(1.75,.85,.9),V(1.48,3.25,-.2),stone)
		piece("HammerRune",V(.3,.5,.08),V(1.48,3.25,-.7),gold,nil,true)
	elseif ranged then
		piece("HoodPeak",V(.95,.35,.9),V(0,4.33,.1),blue)
		for _,side in ipairs({-1,1}) do piece("BowLimb",V(.16,1.2,.2),V(-1.55,2.2+side*.52,-.4),steel,side*-.4) end
		piece("BowString",V(.04,2.1,.04),V(-1.8,2.2,-.4),gold)
		piece("Quiver",V(.55,1.35,.5),V(.6,2.75,.92),stone,.15)
		for i=1,3 do piece("Arrow",V(.06,.7,.06),V(.43+i*.12,3.6,.92),gold) end
	else
		piece("Shield",V(1.35,1.9,.28),V(-1.45,2.2,-.55),steel)
		piece("ShieldRune",V(.2,1.4,.08),V(-1.45,2.2,-.74),violet,nil,true)
		piece("SwordGrip",V(.15,.6,.15),V(1.45,1.7,-.2),stone)
		piece("SwordGuard",V(.65,.14,.25),V(1.45,2.02,-.2),gold)
		piece("SwordBlade",V(.25,1.75,.14),V(1.45,2.95,-.2),steel)
	end
	model:SetAttribute("VisualRole",role)
end
