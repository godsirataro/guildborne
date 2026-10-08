--!strict
-- Cosmetic role cues welded to existing rigs; no scripts, collision or abilities.
local V=Vector3.new
local gold=Color3.fromRGB(209,171,84)
local parchment=Color3.fromRGB(230,215,177)
local leather=Color3.fromRGB(105,67,44)
return function(model: Model,name: string)
	local torso=model:FindFirstChild("Torso") :: BasePart?
	local head=model:FindFirstChild("Head") :: BasePart?
	if not torso or not head then return end
	local old=model:FindFirstChild("CityRoleVisual");if old then old:Destroy() end
	local folder=Instance.new("Folder");folder.Name="CityRoleVisual";folder.Parent=model
	local function part(label: string,size: Vector3,offset: Vector3,color: Color3,limb: BasePart?,angle: number?)
		local target=limb or torso
		local p=Instance.new("Part");p.Name=label;p.Size=size;p.CFrame=target.CFrame*CFrame.new(offset)*CFrame.Angles(0,0,angle or 0)
		p.Color=color;p.Material=Enum.Material.SmoothPlastic;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=folder
		local w=Instance.new("WeldConstraint");w.Part0=target;w.Part1=p;w.Parent=p;return p
	end
	if name=="Mira" then
		for _,p in ipairs(model:GetChildren()) do if p:IsA("BasePart") and (p.Name=="Stole" or p.Name=="GuildClasp") then p.Color=Color3.fromRGB(92,159,117) end end
		part("HerbalSatchel",V(.65,.8,.35),V(.8,-.65,-.68),leather)
		for i=1,3 do part("HerbStem",V(.1,.6,.12),V(.55+i*.12,-.1,-.76),Color3.fromRGB(114,184,113),nil,(i-2)*.25) end
		part("RemedyBelt",V(1.6,.16,.14),V(0,-.5,-.6),gold)
	elseif name=="City Herald" then
		part("HeraldSash",V(.38,2.1,.18),V(0,0,-.76),Color3.fromRGB(75,140,174),nil,-.5)
		part("Scroll",V(.75,.95,.25),V(-1.4,-.7,-.65),parchment)
		part("ScrollSeal",V(.2,.2,.1),V(-1.4,-.85,-.83),gold)
	elseif name=="Expedition Master" then
		part("MapCase",V(1.2,.8,.18),V(0,-.15,-.7),parchment)
		part("MapRoute",V(.7,.07,.05),V(0,-.1,-.82),leather,nil,.3)
		part("FieldPack",V(1.3,1.6,.6),V(0,.15,.9),leather)
	elseif name=="City Guard" then
		part("GuardShield",V(1.2,1.65,.25),V(-1.5,-.15,-.55),Color3.fromRGB(70,100,145))
		part("ShieldCross",V(.17,1.3,.08),V(-1.5,-.15,-.72),gold)
		part("Plume",V(.22,.65,.7),V(0,.98,.1),Color3.fromRGB(153,70,62),head)
	elseif name=="Merchant" then
		part("MerchantApron",V(1.65,2,.2),V(0,-.35,-.75),Color3.fromRGB(180,129,66))
		part("CoinPurse",V(.55,.65,.35),V(.75,-.55,-.86),leather)
		part("PurseClasp",V(.23,.16,.08),V(.75,-.3,-1.07),gold)
	elseif name=="Craftsperson" then
		part("ForgeApron",V(1.65,2.1,.2),V(0,-.35,-.75),leather)
		part("GogglesBand",V(1.35,.12,1.2),V(0,.4,0),leather,head)
		for _,side in ipairs({-1,1}) do part("GoggleLens",V(.35,.3,.16),V(side*.3,.32,-.63),gold,head) end
		part("HammerHandle",V(.12,1,.12),V(1.4,-.8,-.5),leather)
		part("HammerHead",V(.65,.3,.3),V(1.4,-.28,-.5),Color3.fromRGB(135,150,159))
	else
		part("TravelPack",V(1.25,1.6,.7),V(0,.1,.9),leather)
		part("Bedroll",V(1.6,.45,.6),V(0,1,.9),parchment)
	end
	model:SetAttribute("CityRole",name)
end
