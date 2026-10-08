--!strict
-- Public navigation geometry only. Travel authority remains server-side.
local City = {}
local Civic=if script then require(script.Parent.CivicCities)else require("./CivicCities")
City.Bounds = {MinX=-460,MaxX=460,MinZ=-1640,MaxZ=-620}
City.RoadWidths = {Primary=32,Secondary=18,Service=10}
City.Districts = {
	{Id="Plaza",Name="Central Plaza",X=0,Z=-1100,Radius=130},
	{Id="Guild",Name="Guild District",X=-300,Z=-1100,Radius=160},
	{Id="Market",Name="Market / Craft District",X=300,Z=-1100,Radius=160},
	{Id="Tavern",Name="Tavern District",X=-140,Z=-820,Radius=150},
	{Id="Tower",Name="Tower Gate",X=0,Z=-1510,Radius=150},
	{Id="Warp",Name="Guild Zone Warp",X=0,Z=-680,Radius=100},
}
City.Destinations = {
	City={Id="CentralCity",Spawn="CentralCitySpawn",X=0,Y=5,Z=-720,FallbackX=0,FallbackZ=-750},
	Guild={Id="PersonalGuild",Spawn="PersonalGuildSpawn",X=0,Y=5,Z=23,FallbackX=0,FallbackZ=14},
	Greenwood={Id="Greenwood",Spawn="GreenwoodSpawn",X=0,Y=7,Z=1505,FallbackX=0,FallbackZ=1495,GroundY=2},
	Ironveil={Id="Ironveil",Spawn="IronveilSpawn",X=500,Y=7,Z=1515,FallbackX=500,FallbackZ=1505,GroundY=2},
	Ashen={Id="Ashen",Spawn="AshenSpawn",X=1000,Y=7,Z=1515,FallbackX=1000,FallbackZ=1505,GroundY=2},
}
for _,id in ipairs(Civic.Order)do
 local d=(Civic.Definitions :: any)[id];
 (City.Destinations :: any)[id]={Id=id,Spawn=id.."Spawn",X=d.X,Y=4,Z=d.Z+108,FallbackX=d.X,FallbackZ=d.Z+100,GroundY=0}
end
-- Public stop names and fixed return landings; clients cannot submit coordinates.
City.GuildPortalStops={
 Arrival={Name="Guild Zone Warp",X=0,Z=-680,ReturnX=0,ReturnZ=-720,FallbackX=0,FallbackZ=-750},
 GuildDistrict={Name="Guild District Portal",X=-300,Z=-1080,ReturnX=-300,ReturnZ=-1068,FallbackX=-300,FallbackZ=-1060},
 MarketDistrict={Name="Market District Portal",X=300,Z=-1080,ReturnX=300,ReturnZ=-1068,FallbackX=300,FallbackZ=-1060},
 TowerDistrict={Name="Tower District Portal",X=0,Z=-1490,ReturnX=0,ReturnZ=-1502,FallbackX=0,FallbackZ=-1510},
}
City.GuildPortalOrder={"GuildDistrict","MarketDistrict","TowerDistrict"}
City.RegionOrder={"Greenwood","Ironveil","Ashen"}
City.Regions={
	Greenwood={X=0,Z=1400,HalfWidth=112,Back=102,Front=128,CityGateZ=-1450},
	Ironveil={X=500,Z=1400,HalfWidth=122,Back=112,Front=136,CityGateZ=-1390},
	Ashen={X=1000,Z=1400,HalfWidth=112,Back=112,Front=138,CityGateZ=-1330},
}
-- Chapter04's private court is a separate pocket of Ashen, not surface combat land.
-- Its floor/walls exist only for admitted owners. Falling still uses TravelService's
-- Y < -15 recovery; quest prompts independently enforce session and ownership.
City.RegionAnnexes={
 Ashen={{MinX=1835,MaxX=2165,MinZ=1235,MaxZ=1565}},
}
function City.region(x:number,z:number):string?
	for _,id in ipairs(City.RegionOrder) do local d=City.Regions[id]
		if x>=d.X-d.HalfWidth and x<=d.X+d.HalfWidth and z>=d.Z-d.Back and z<=d.Z+d.Front then return id end
	end
	for _,id in ipairs(City.RegionOrder)do
		for _,b in ipairs(City.RegionAnnexes[id]or {})do
			if x>=b.MinX and x<=b.MaxX and z>=b.MinZ and z<=b.MaxZ then return id end
		end
	end
	return nil
end
function City.contains(x: number,z: number): boolean
	local b=City.Bounds
	return x>=b.MinX and x<=b.MaxX and z>=b.MinZ and z<=b.MaxZ
end
function City.regionCombat(region:string,x:number,y:number,z:number):boolean
    local d=City.Regions[region]
    return d~=nil and x==x and y==y and z==z and x>d.X-d.HalfWidth+3 and x<d.X+d.HalfWidth-3
        and z>d.Z-d.Back+3 and z<d.Z+90 and y>=1 and y<=35
end
function City.district(x: number,z: number): string?
	if not City.contains(x,z) then return nil end
	local name="Central City";local nearest=math.huge
	for _,d in ipairs(City.Districts) do
		local distance=(x-d.X)^2+(z-d.Z)^2
		if distance<d.Radius^2 and distance<nearest then nearest=distance;name=d.Name end
	end
	return name
end
function City.allowsCombat(x: number,y: number,z: number,originX: number,originY: number): boolean
	return not City.contains(x,z) and math.abs(x-originX)<39 and z>48 and z<117 and y-originY> -3 and y-originY<=24
end
return City
