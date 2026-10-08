--!strict
local Kit=require(script.Parent.ArtKit)
local Art=require(game.ReplicatedStorage.Shared.Config.Art)
local C=Art.Palette
local V=Vector3.new
local CityKit={}
function CityKit.Build(): Folder
	local folder=Instance.new("Folder");folder.Name="CityKit"
	local function model(name: string): Model
		local m=Instance.new("Model");m.Name=name;m.WorldPivot=CFrame.identity;m.Parent=folder;return m
	end
	local function p(m: Model,n: string,s: Vector3,v: Vector3,c: Color3,solid: boolean?): Part
		return Kit.Part(m,n,s,v,c,Enum.Material.SmoothPlastic,solid)
	end
	local hall=model("CityHouse")
	p(hall,"Foundation",V(58,.8,42),V(0,.4,0),C.Stone,true)
	p(hall,"RearWall",V(56,20,1),V(0,10,-20),C.Timber,true)
	for _,side in ipairs({-1,1}) do
		p(hall,"SideWall",V(1,20,40),V(side*28,10,0),C.Timber,true)
		p(hall,"FrontWall",V(20,20,1),V(side*18,10,20),C.Timber,true)
		for _,z in ipairs({-20,0,20}) do p(hall,"TimberPost",V(1.3,22,1.3),V(side*28,11,z),C.Wood) end
		local roof=p(hall,"PitchedRoof",V(32,1.2,48),V(side*14,25,0),C.Roof)
		roof.CFrame*=CFrame.Angles(0,0,-side*math.rad(20))
		p(hall,"Window",V(7,7,.3),V(side*18,12,20.7),Art.UI.Background)
		p(hall,"WindowMullion",V(.5,7,.4),V(side*18,12,20.9),C.Gold)
	end
	p(hall,"Ridge",V(1,1,49),V(0,30,0),C.Gold)
	p(hall,"DoorLintel",V(16,5,1.5),V(0,18,20),C.Wood,true)
	local arch=model("CityArch")
	for _,x in ipairs({-18,18}) do p(arch,"StonePier",V(5,26,7),V(x,13,0),C.Stone,true);p(arch,"Capital",V(7,2,9),V(x,26,0),C.Gold) end
	p(arch,"ArchCrown",V(41,5,7),V(0,29,0),C.Stone,true)
	local stall=model("MarketStall")
	p(stall,"Counter",V(12,3,5),V(0,1.5,0),C.Timber,true)
	for _,x in ipairs({-6,6}) do p(stall,"Post",V(.6,9,.6),V(x,4.5,0),C.Wood) end
	p(stall,"Awning",V(15,.6,10),V(0,9,0),Color3.fromRGB(180,108,55))
	local wall=model("CityWall")
	p(wall,"StoneWall",V(40,18,5),V(0,9,0),C.Stone,true)
	for _,x in ipairs({-16,-8,0,8,16}) do p(wall,"Merlon",V(4,3,6),V(x,19.5,0),C.Stone) end
	local planter=model("Planter")
	p(planter,"StoneBed",V(12,2,8),V(0,1,0),C.Stone,true)
	p(planter,"Hedge",V(10,3,6),V(0,3,0),C.Grass)
	local tower=model("GateTower")
	p(tower,"TowerBase",V(28,5,30),V(0,2.5,0),C.Stone,true)
	p(tower,"TowerShaft",V(23,66,25),V(0,36,0),Color3.fromRGB(107,120,133),true)
	p(tower,"Crown",V(31,6,33),V(0,70,0),C.Stone,true)
	for _,x in ipairs({-12,0,12}) do p(tower,"Battlement",V(6,7,33),V(x,76,0),C.Stone) end
	local banner=model("DistrictBanner")
	p(banner,"Pole",V(.7,18,.7),V(0,9,0),C.Wood)
	p(banner,"Cloth",V(7,11,.3),V(0,11,0),C.Roof)
	local diamond=p(banner,"GuildDiamond",V(2.3,2.3,.5),V(0,12,.3),C.Gold);diamond.CFrame*=CFrame.Angles(0,0,math.pi/4)
	p(banner,"Blade",V(.5,5,.6),V(0,12,.6),C.Parchment)
	return folder
end
return CityKit
