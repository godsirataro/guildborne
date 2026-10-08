--!strict
-- 25 reusable, anchored prototype assets. All coordinates are studs from ground pivot.
local Art = require(game:GetService("ReplicatedStorage").Shared.Config.Art)
local C = Art.Palette
local Kit = {}
local V = Vector3.new
local function model(name: string): Model
	local m = Instance.new("Model"); m.Name = name; m.WorldPivot = CFrame.identity
	m:SetAttribute("ArtPhase", "1.5"); return m
end
function Kit.Part(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?, solid: boolean?): Part
	local p = Instance.new("Part"); p.Name = name; p.Size = size; p.Position = position
	p.Anchored = true; p.CanCollide = solid == true; p.CanTouch = false; p.CanQuery = solid == true
	p.Color = color; p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth; p.Parent = parent
	return p
end
local function block(m: Instance, n: string, s: Vector3, p: Vector3, c: Color3, solid: boolean?): Part
	return Kit.Part(m, n, s, p, c, Enum.Material.Wood, solid)
end
local function beam(m: Instance, n: string, a: Vector3, b: Vector3, width: number, c: Color3): Part
	local p = block(m, n, V(width, width, (b-a).Magnitude), (a+b)/2, c)
	p.CFrame = CFrame.lookAt((a+b)/2, b); return p
end
local function cylinder(m: Instance, n: string, size: Vector3, p: Vector3, c: Color3): Part
	local part = block(m,n,size,p,c); part.Shape = Enum.PartType.Cylinder
	part.CFrame *= CFrame.Angles(0,0,math.pi/2); return part
end
function Kit.Label(anchor: BasePart, en: string, th: string, height: number?): TextLabel
	local g = Instance.new("BillboardGui"); g.Name = "BilingualSign"
	g.Size = UDim2.fromOffset(160, 46); g.StudsOffsetWorldSpace = V(0,height or 2.4,0)
	g.MaxDistance = 48; g.AlwaysOnTop = false; g.Parent = anchor
	local l = Instance.new("TextLabel"); l.Size = UDim2.fromScale(1,1)
	l.BackgroundColor3 = Art.UI.Background; l.BackgroundTransparency = 0.12
	l.TextColor3 = C.Parchment; l.TextSize = 14; l.Font = Enum.Font.GothamMedium
	l.TextWrapped = true; l.Text = en .. "\n" .. th; l.Parent = g
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,5); corner.Parent = l
	return l
end
local function banner(): Model
	local m = model("GuildBanner")
	block(m,"Pole",V(.22,7,.22),V(0,3.5,0),C.Wood)
	block(m,"Crossbar",V(3,.2,.25),V(0,6.6,0),C.Gold)
	Kit.Part(m,"Burgundy",V(2.5,3.8,.15),V(0,4.6,0),C.Roof,Enum.Material.Fabric)
	local badge = block(m,"GuildDiamond",V(.9,.9,.22),V(0,4.7,.12),C.Gold)
	badge.CFrame *= CFrame.Angles(0,0,math.pi/4)
	block(m,"CrestBlade",V(.18,1.9,.26),V(0,4.8,.18),C.Parchment)
	return m
end
local function hall(level: number): Model
	local m = model("GuildHallLv" .. level)
	local w = if level == 2 then 25 else 21
	Kit.Part(m,"Foundation",V(w+2,1,17),V(0,.5,0),C.Stone,Enum.Material.Slate,true)
	block(m,"RearWall",V(w,9,1),V(0,5.5,-7),C.Timber,true)
	for _,side in ipairs({-1,1}) do
		block(m,"SideWall",V(1,9,14),V(side*w/2,5.5,0),C.Timber,true)
		block(m,"FrontWall",V(w/2-3,9,1),V(side*(w/4+1.5),5.5,7),C.Timber,true)
		for _,z in ipairs({-7,7}) do block(m,"CornerPost",V(.8,10,.8),V(side*w/2,5.5,z),C.Wood) end
		block(m,"WindowRecess",V(3,3,.15),V(side*(w/4+1.5),6,7.6),Art.UI.Background)
		block(m,"WindowMullion",V(.18,3,.3),V(side*(w/4+1.5),6,7.75),C.Gold)
		block(m,"WindowSill",V(3.4,.25,.5),V(side*(w/4+1.5),4.4,7.7),C.Wood)
		local roof = block(m,"PitchedRoof",V(w/2+2,.65,19),V(side*(w/4+.4),12,0),C.Roof)
		roof.CFrame *= CFrame.Angles(0,0,-side*math.rad(24))
		beam(m,"GableRafter",V(0,14.4,9.6),V(side*(w/2+1.7),9.7,9.6),.45,C.Wood)
		local gable=Instance.new("WedgePart"); gable.Name="Gable"
		gable.Size=V(.6,4.4,w/2); gable.CFrame=CFrame.new(side*w/4,12,7)*CFrame.Angles(0,-side*math.pi/2,0)
		gable.Color=C.Timber; gable.Material=Enum.Material.Wood; gable.Anchored=true
		gable.CanCollide=false; gable.CanTouch=false; gable.CanQuery=false; gable.Parent=m
		if level == 2 then
			Kit.Part(m,"StoneButtress",V(2.4,6,2.6),V(side*(w/2+.3),3,6.5),C.Stone,Enum.Material.Slate,true)
			local b=banner(); b:PivotTo(CFrame.new(side*9,6,8)); b.Parent=m
		end
	end
	block(m,"Lintel",V(w+1,.6,1),V(0,9.8,7.5),C.Wood)
	block(m,"Ridge",V(.65,.65,20),V(0,14.5,0),if level==2 then C.Gold else C.Wood)
	block(m,"DoorHeader",V(6,2.7,1),V(0,8.9,7),C.Wood,true)
	for _,x in ipairs({-3,3}) do block(m,"DoorFrame",V(.5,6.5,1.3),V(x,4,7.4),C.Gold) end
	Kit.Part(m,"Threshold",V(7,.5,3),V(0,.25,9),C.StoneLight,Enum.Material.Slate,true)
	local crest = banner(); crest:ScaleTo(.65); crest:PivotTo(CFrame.new(0,8.3,8)); crest.Parent=m
	local anchor=block(m,"HallSign",V(4,.1,.1),V(0,10,8.5),C.Wood); anchor.Transparency=1
	Kit.Label(anchor,"Guild Hall · Lv"..level,"หอกิลด์ · ระดับ "..level,5.8)
	if level==2 then
		Kit.Part(m,"Chimney",V(2.2,9,2.2),V(8,12,-3),C.Stone,Enum.Material.Slate)
		block(m,"PorchCanopy",V(11,.5,4),V(0,7.4,10),C.Roof)
		for _,x in ipairs({-5,5}) do block(m,"PorchPost",V(.6,7,.6),V(x,3.5,11.5),C.Wood) end
	end
	return m
end
local function crate(name: string, supply: boolean): Model
	local m=model(name); block(m,"Box",V(3,2.7,3),V(0,1.35,0),C.Timber)
	for _,x in ipairs({-1.3,1.3}) do block(m,"Binding",V(.24,2.9,3.15),V(x,1.4,0),if supply then C.Gold else C.Wood) end
	beam(m,"Brace",V(-1.3,.2,1.55),V(1.3,2.6,1.55),.25,C.Wood)
	if supply then block(m,"DeliverySeal",V(.8,.8,.12),V(0,1.6,1.65),C.Parchment) end
	return m
end
local function weapon(name: string): Model
	local m=model(name)
	if name=="IronSword" then
		block(m,"Grip",V(.3,1,.3),V(0,.8,0),C.Wood)
		block(m,"Guard",V(1.5,.22,.4),V(0,1.4,0),C.Gold)
		Kit.Part(m,"Blade",V(.5,2.6,.16),V(0,2.8,0),C.Iron,Enum.Material.Metal)
		local tip=Instance.new("WedgePart"); tip.Name="Point"; tip.Size=V(.16,.6,.5)
		tip.CFrame=CFrame.new(0,4.4,0)*CFrame.Angles(0,math.pi/2,0); tip.Color=C.Iron
		tip.Material=Enum.Material.Metal; tip.Anchored=true; tip.CanCollide=false; tip.CanTouch=false; tip.CanQuery=false; tip.Parent=m
		block(m,"Pommel",V(.45,.3,.4),V(0,.15,0),C.Gold)
	elseif name=="TrainingBow" then
		local points={V(-.3,.2,0),V(.5,1,0),V(.8,2.2,0),V(.5,3.4,0),V(-.3,4.2,0)}
		for i=1,4 do beam(m,"Limb",points[i],points[i+1],.23,C.Timber) end
		beam(m,"String",points[1],points[5],.045,C.Parchment)
		block(m,"Grip",V(.3,.8,.32),V(.8,2.2,0),C.Wood)
	else
		block(m,"Shaft",V(.22,4.4,.22),V(0,2.2,0),C.Timber)
		block(m,"Collar",V(.6,.25,.5),V(0,4.1,0),C.Gold)
		local gem=Kit.Part(m,"Focus",V(.65,.9,.65),V(0,4.7,0),C.Magic,Enum.Material.Glass)
		gem.CFrame *= CFrame.Angles(0,0,math.pi/4)
		for _,x in ipairs({-.48,.48}) do block(m,"Prong",V(.18,1.1,.25),V(x,4.5,0),C.Gold) end
	end
	return m
end
function Kit.Build(): Folder
	local f=Instance.new("Folder"); f.Name="GuildborneArtKit"
	local function add(m: Model) m.Parent=f end
	add(hall(1)); add(hall(2)); add(banner())
	local board=model("QuestBoard")
	for _,x in ipairs({-3.4,3.4}) do block(board,"Post",V(.6,7,.6),V(x,3.5,0),C.Wood) end
	block(board,"NoticeBack",V(7,4,.5),V(0,4.5,0),C.Wood)
	block(board,"Cap",V(8,.5,1.6),V(0,7,0),C.Roof)
	for i=1,3 do
		block(board,"Parchment",V(1.55,2.2,.12),V((i-2)*2.1,4.6,.32),C.Parchment)
		block(board,"Seal",V(.35,.35,.15),V((i-2)*2.1,4,.41),C.Quest)
		block(board,"NoticeLine",V(1,.12,.14),V((i-2)*2.1,5,.4),C.Timber)
	end
	add(board)
	local dummy=model("TrainingDummy")
	block(dummy,"Base",V(3,.25,2),V(0,.125,0),C.Wood)
	block(dummy,"Post",V(.5,4,.5),V(0,2,0),C.Wood)
	block(dummy,"StrawBody",V(1.8,2,.9),V(0,3,0),C.Path)
	block(dummy,"Arms",V(4,.4,.4),V(0,3.5,0),C.Timber)
	block(dummy,"Head",V(1.1,1.1,1),V(0,4.7,0),C.Path)
	block(dummy,"Target",V(.65,.65,.15),V(0,3,.55),C.Roof); add(dummy)
	for _,name in ipairs({"IronSword","TrainingBow","PriestStaff"}) do add(weapon(name)) end
	local goblin=model("GoblinScout")
	for _,x in ipairs({-.45,.45}) do
		block(goblin,"Boot",V(.65,.5,1),V(x,.25,.1),C.Wood)
		block(goblin,"Leg",V(.55,1.2,.6),V(x,1,0),C.Goblin)
		local arm=block(goblin,"Arm",V(.5,1.7,.6),V(x*2.2,2.3,0),C.Goblin); arm.CFrame*=CFrame.Angles(0,0,x*.5)
		local ear=block(goblin,"PointedEar",V(.8,.45,.35),V(x*2,3.7,0),C.Goblin); ear.CFrame*=CFrame.Angles(0,0,x*.8)
		block(goblin,"Eye",V(.21,.16,.1),V(x*.6,3.8,.66),C.Parchment)
	end
	block(goblin,"Tunic",V(1.6,1.6,.85),V(0,2.1,0),C.Wood)
	block(goblin,"Belt",V(1.7,.23,.95),V(0,1.6,0),C.Gold)
	block(goblin,"Head",V(1.6,1.3,1.2),V(0,3.6,0),C.Goblin)
	block(goblin,"Nose",V(.4,.4,.4),V(0,3.6,.7),C.LeafLight); add(goblin)
	for i=1,3 do
		local tree=model("Tree"..string.char(64+i)); local h=8+i*2
		block(tree,"Trunk",V(1.2,h,1.2),V(0,h/2,0),C.Wood)
		if i==2 then
			for j=1,3 do
				local p=block(tree,"Tier",V(8-j*1.3,3,8-j*1.3),V(0,h-5+j*2,0),C.Leaf)
				p.CFrame*=CFrame.Angles(0,j*.5,0)
			end
		else
			for j=1,3 do
				local p=block(tree,"Crown",V(5.5,4.5,5.5),V((j-2)*2,h+(if j==2 then 1 else -1),0),if i==1 then C.Leaf else C.LeafLight)
				p.CFrame*=CFrame.Angles(.25,j*.6,.25)
			end
		end
		add(tree)
		local rock=model("Rock"..string.char(64+i))
		local p=Kit.Part(rock,"FacetedStone",V(2+i,1.6+i*.5,2.5+i*.4),V(0,1,0),C.Stone,Enum.Material.Slate)
		p.CFrame*=CFrame.Angles(.2,i*.6,.22); add(rock)
	end
	local fence=model("Fence")
	for _,x in ipairs({-3,3}) do block(fence,"Post",V(.5,3,.5),V(x,1.5,0),C.Wood) end
	for _,y in ipairs({1,2.4}) do block(fence,"Rail",V(6,.3,.35),V(0,y,0),C.Timber) end
	add(fence)
	local barrel=model("Barrel")
	cylinder(barrel,"Staves",V(3,2.2,2.2),V(0,1.5,0),C.Timber)
	for _,y in ipairs({.35,2.65}) do cylinder(barrel,"Band",V(.18,2.3,2.3),V(0,y,0),C.Iron) end
	add(barrel); add(crate("WoodenCrate",false)); add(crate("SupplyCrate",true))
	for _,name in ipairs({"Table","Bench"}) do
		local m=model(name); local h=if name=="Table" then 2.6 else 1.3; local depth=if name=="Table" then 3 else 1.2
		block(m,"Top",V(5,.35,depth),V(0,h,0),C.Timber)
		for _,x in ipairs({-1.8,1.8}) do block(m,"Leg",V(.5,h,depth-.3),V(x,h/2,0),C.Wood) end
		add(m)
	end
	local ore=model("IronOreNode")
	Kit.Part(ore,"Rock",V(4,2.8,3.5),V(0,1.2,0),C.Stone,Enum.Material.Slate)
	for i=1,3 do local p=Kit.Part(ore,"IronSeam",V(.6,1.4,1.1),V(i-2,2.4,.6),C.Iron,Enum.Material.Metal); p.CFrame*=CFrame.Angles(.2,0,.5) end
	add(ore)
	local logs=model("TimberLogs")
	for i=1,3 do
		local y=if i==3 then 1.7 else .65; local x=if i==3 then 0 else (i-1.5)*1.4
		local p=cylinder(logs,"Log",V(4,1.2,1.2),V(x,y,0),C.Timber); p.CFrame=CFrame.new(x,y,0)*CFrame.Angles(0,math.pi/2,0)
	end
	add(logs)
	local lantern=model("Lantern")
	block(lantern,"Post",V(.3,5,.3),V(0,2.5,0),C.Wood)
	block(lantern,"Arm",V(1.2,.25,.25),V(.45,5,0),C.Wood)
	Kit.Part(lantern,"WarmGlass",V(.6,.9,.6),V(.9,4.4,0),C.Quest,Enum.Material.SmoothPlastic)
	for _,y in ipairs({3.9,4.9}) do block(lantern,"Cap",V(.9,.2,.9),V(.9,y,0),C.Wood) end
	add(lantern)
	local post=model("Signpost")
	block(post,"Post",V(.35,4,.35),V(0,2,0),C.Wood)
	block(post,"Sign",V(3.5,1.2,.3),V(0,3.3,0),C.Timber); add(post)
	assert(#f:GetChildren()==25,"Art kit must stay within 25 asset families")
	return f
end
return Kit
