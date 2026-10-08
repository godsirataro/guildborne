--!strict
-- Generated regional geometry. RegionalWorld binds travel; encounter authority is separate.
local V=Vector3.new
type Piece={name:string,size:Vector3,pos:Vector3,color:Color3,collide:boolean,wedge:boolean,yaw:number}
type Marker={name:string,pos:Vector3,role:string}
type Route={name:string,points:{Vector3}}
type Region={id:string,parts:{Piece},markers:{Marker},routes:{Route}}
local regions:{Region}={
{id="Greenwood",parts={
{name="Island",size=V(220,4,200),pos=V(0,0,0),color=Color3.fromRGB(74,117,72),collide=true,wedge=false,yaw=0},
{name="Landing",size=V(28,4,26),pos=V(0,0,113),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="BossRise",size=V(96,4,50),pos=V(0,4,-70),color=Color3.fromRGB(100,78,56),collide=true,wedge=false,yaw=0},
{name="RootAscent",size=V(20,4,25),pos=V(0,4.0,-32.5),color=Color3.fromRGB(180,153,108),collide=true,wedge=true,yaw=180},
{name="Trail",size=V(18,4,90),pos=V(-60,0.04999999999999982,10),color=Color3.fromRGB(180,153,108),collide=true,wedge=false,yaw=0},
{name="Trail",size=V(18,4,90),pos=V(60,0.04999999999999982,10),color=Color3.fromRGB(180,153,108),collide=true,wedge=false,yaw=0},
{name="CrossTrail",size=V(138,4,18),pos=V(0,0.06000000000000005,50),color=Color3.fromRGB(180,153,108),collide=true,wedge=false,yaw=0},
{name="CrossTrail",size=V(138,4,18),pos=V(0,0.06000000000000005,-25),color=Color3.fromRGB(180,153,108),collide=true,wedge=false,yaw=0},
{name="ArrivalTrail",size=V(18,4,46),pos=V(0,0.04999999999999982,78),color=Color3.fromRGB(180,153,108),collide=true,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(-90,8,75),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(-90,13,75),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(-90,18,75),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(-90,22,75),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(85,8,72),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(85,13,72),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(85,18,72),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(85,22,72),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(-89,8,18),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(-89,13,18),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(-89,18,18),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(-89,22,18),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(90,8,5),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(90,13,5),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(90,18,5),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(90,22,5),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(-85,8,-50),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(-85,13,-50),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(-85,18,-50),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(-85,22,-50),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(87,8,-60),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(87,13,-60),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(87,18,-60),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(87,22,-60),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(-45,8,8),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(-45,13,8),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(-45,18,8),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(-45,22,8),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(42,8,12),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(42,13,12),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(42,18,12),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(42,22,12),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(-95,8,-83),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(-95,13,-83),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(-95,18,-83),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(-95,22,-83),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(95,8,-87),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(95,13,-87),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(95,18,-87),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(95,22,-87),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(-37,12,-77),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(-37,17,-77),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(-37,22,-77),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(-37,26,-77),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Trunk",size=V(3,12,3),pos=V(37,12,-77),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="Canopy",size=V(13,6,13),pos=V(37,17,-77),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(10,6,10),pos=V(37,22,-77),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
{name="Canopy",size=V(6,6,6),pos=V(37,26,-77),color=Color3.fromRGB(55,96,63),collide=false,wedge=false,yaw=0},
},markers={
{name="Arrival",pos=V(0,2,105),role="Arrival"},
{name="ScoutCamp",pos=V(-60,2,10),role="Melee"},
{name="ArcherCamp",pos=V(60,2,10),role="Ranged"},
{name="BoarTrail",pos=V(0,2,10),role="Charge"},
{name="ForestCaptain",pos=V(0,6,-70),role="Boss"},
},routes={
{name="Main",points={V(0,2.05,112),V(0,2.05,50),V(0,2.06,-20),V(0,6,-45),V(0,6,-70)}},
{name="WestLoop",points={V(0,2.06,50),V(-60,2.06,50),V(-60,2.06,-18),V(0,2.06,-18)}},
{name="EastLoop",points={V(0,2.06,50),V(60,2.06,50),V(60,2.06,-18),V(0,2.06,-18)}},
}},
{id="Ironveil",parts={
{name="Island",size=V(240,4,220),pos=V(0,0,0),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Landing",size=V(28,4,24),pos=V(0,0,122),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="MidTerrace",size=V(220,4,160),pos=V(0,4,-30),color=Color3.fromRGB(177,143,88),collide=true,wedge=false,yaw=0},
{name="UpperTerrace",size=V(190,4,105),pos=V(0,8,-57.5),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="QuarryAscent",size=V(20,4,25),pos=V(0,4.0,62.5),color=Color3.fromRGB(180,153,108),collide=true,wedge=true,yaw=180},
{name="SummitAscent",size=V(20,4,25),pos=V(0,8.0,7.5),color=Color3.fromRGB(180,153,108),collide=true,wedge=true,yaw=180},
{name="CrystalBase",size=V(7,3,7),pos=V(-82,3.5,80),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(-84,7.5,80),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(-82,10.0,80),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(-80,8.5,80),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="CrystalBase",size=V(7,3,7),pos=V(82,3.5,80),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(80,7.5,80),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(82,10.0,80),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(84,8.5,80),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="CrystalBase",size=V(7,3,7),pos=V(-85,7.5,22),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(-87,11.5,22),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(-85,14.0,22),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(-83,12.5,22),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="CrystalBase",size=V(7,3,7),pos=V(85,7.5,22),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(83,11.5,22),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(85,14.0,22),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(87,12.5,22),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="CrystalBase",size=V(7,3,7),pos=V(-72,11.5,-48),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(-74,15.5,-48),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(-72,18.0,-48),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(-70,16.5,-48),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="CrystalBase",size=V(7,3,7),pos=V(72,11.5,-48),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(70,15.5,-48),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(72,18.0,-48),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(74,16.5,-48),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="CrystalBase",size=V(7,3,7),pos=V(-60,11.5,-90),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(-62,15.5,-90),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(-60,18.0,-90),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(-58,16.5,-90),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="CrystalBase",size=V(7,3,7),pos=V(60,11.5,-90),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(58,15.5,-90),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(60,18.0,-90),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(62,16.5,-90),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=45},
{name="QuarryWall",size=V(7,15,145),pos=V(-106,13,-26),color=Color3.fromRGB(52,61,79),collide=true,wedge=false,yaw=0},
{name="QuarryWall",size=V(7,15,145),pos=V(106,13,-26),color=Color3.fromRGB(52,61,79),collide=true,wedge=false,yaw=0},
{name="GantryPost",size=V(4,18,4),pos=V(-44,19,-80),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="GantryBrace",size=V(4,3,20),pos=V(-44,27,-73),color=Color3.fromRGB(116,79,50),collide=false,wedge=false,yaw=0},
{name="GantryPost",size=V(4,18,4),pos=V(44,19,-80),color=Color3.fromRGB(116,79,50),collide=true,wedge=false,yaw=0},
{name="GantryBrace",size=V(4,3,20),pos=V(44,27,-73),color=Color3.fromRGB(116,79,50),collide=false,wedge=false,yaw=0},
{name="GantryCrossbeam",size=V(92,4,4),pos=V(0,29,-80),color=Color3.fromRGB(116,79,50),collide=false,wedge=false,yaw=0},
},markers={
{name="Arrival",pos=V(0,2,115),role="Arrival"},
{name="RaiderCamp",pos=V(-52,6,25),role="Melee"},
{name="StoneGuard",pos=V(45,10,-25),role="Guard"},
{name="ShamanCamp",pos=V(-45,10,-50),role="Support"},
{name="QuarryGuardian",pos=V(0,10,-70),role="Boss"},
},routes={
{name="Main",points={V(0,2,120),V(0,2,75),V(0,6,50),V(0,6,20),V(0,10,-5),V(0,10,-70)}},
{name="MidLoop",points={V(0,6,40),V(-52,6,40),V(-52,6,5),V(0,6,30)}},
{name="UpperLoop",points={V(0,10,-20),V(45,10,-20),V(45,10,-68),V(0,10,-68)}},
}},
{id="Ashen",parts={
{name="Island",size=V(220,4,220),pos=V(0,0,0),color=Color3.fromRGB(52,61,79),collide=true,wedge=false,yaw=0},
{name="Landing",size=V(28,4,26),pos=V(0,0,123),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="CentralSanctum",size=V(90,4,50),pos=V(0,3,0),color=Color3.fromRGB(112,86,155),collide=true,wedge=false,yaw=0},
{name="SanctumAscent",size=V(20,3,20),pos=V(0,3.5,35.0),color=Color3.fromRGB(180,153,108),collide=true,wedge=true,yaw=180},
{name="BossSanctum",size=V(90,4,55),pos=V(0,6,-72.5),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="WardenAscent",size=V(20,3,20),pos=V(0,6.5,-35.0),color=Color3.fromRGB(180,153,108),collide=true,wedge=true,yaw=180},
{name="WardenRampFoundation",size=V(20,3,20),pos=V(0,3.5,-35),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="SideCourt",size=V(45,4,70),pos=V(-72,3,0),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Bridge",size=V(4.5,4,16),pos=V(-47.25,3,0),color=Color3.fromRGB(180,153,108),collide=true,wedge=false,yaw=0},
{name="CrystalBase",size=V(7,3,7),pos=V(-72,6.5,-24),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(-74,10.5,-24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(-72,13.0,-24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(-70,11.5,-24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="CrystalBase",size=V(7,3,7),pos=V(-72,6.5,24),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(-74,10.5,24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(-72,13.0,24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(-70,11.5,24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="SideCourt",size=V(45,4,70),pos=V(72,3,0),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Bridge",size=V(4.5,4,16),pos=V(47.25,3,0),color=Color3.fromRGB(180,153,108),collide=true,wedge=false,yaw=0},
{name="CrystalBase",size=V(7,3,7),pos=V(72,6.5,-24),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(70,10.5,-24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(72,13.0,-24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(74,11.5,-24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="CrystalBase",size=V(7,3,7),pos=V(72,6.5,24),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="Crystal",size=V(2,5,2),pos=V(70,10.5,24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,10,2),pos=V(72,13.0,24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="Crystal",size=V(2,7,2),pos=V(74,11.5,24),color=Color3.fromRGB(80,202,216),collide=false,wedge=false,yaw=45},
{name="SanctumColumn",size=V(5,19,5),pos=V(-38,17.5,-52),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="ColumnCrown",size=V(8,2,8),pos=V(-38,28,-52),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=0},
{name="SanctumColumn",size=V(5,19,5),pos=V(-38,17.5,-90),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="ColumnCrown",size=V(8,2,8),pos=V(-38,28,-90),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=0},
{name="SanctumColumn",size=V(5,19,5),pos=V(38,17.5,-52),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="ColumnCrown",size=V(8,2,8),pos=V(38,28,-52),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=0},
{name="SanctumColumn",size=V(5,19,5),pos=V(38,17.5,-90),color=Color3.fromRGB(96,105,119),collide=true,wedge=false,yaw=0},
{name="ColumnCrown",size=V(8,2,8),pos=V(38,28,-90),color=Color3.fromRGB(216,174,76),collide=false,wedge=false,yaw=0},
{name="BrokenSpire",size=V(8,24,8),pos=V(-91,14,-80),color=Color3.fromRGB(112,86,155),collide=true,wedge=false,yaw=0},
{name="BrokenSpire",size=V(8,24,8),pos=V(-91,14,75),color=Color3.fromRGB(112,86,155),collide=true,wedge=false,yaw=0},
{name="BrokenSpire",size=V(8,24,8),pos=V(91,14,-80),color=Color3.fromRGB(112,86,155),collide=true,wedge=false,yaw=0},
{name="BrokenSpire",size=V(8,24,8),pos=V(91,14,75),color=Color3.fromRGB(112,86,155),collide=true,wedge=false,yaw=0},
{name="WardenArch",size=V(82,5,6),pos=V(0,29,-90),color=Color3.fromRGB(96,105,119),collide=false,wedge=false,yaw=0},
},markers={
{name="Arrival",pos=V(0,2,115),role="Arrival"},
{name="SentinelCourt",pos=V(-72,5,0),role="Melee"},
{name="CasterCourt",pos=V(72,5,0),role="Spell"},
{name="HoundApproach",pos=V(0,2,65),role="Charge"},
{name="ArcaneWarden",pos=V(0,8,-70),role="Boss"},
},routes={
{name="Main",points={V(0,2,120),V(0,2,45),V(0,5,25),V(0,5,-25),V(0,8,-45),V(0,8,-70)}},
{name="WestCourt",points={V(0,5,0),V(-72,5,0),V(-72,5,10)}},
{name="EastCourt",points={V(0,5,0),V(72,5,0),V(72,5,10)}},
}},
}
return function(): Folder
    local folder=Instance.new("Folder");folder.Name="AdventureMapKit"
    for _,def in ipairs(regions) do
        local model=Instance.new("Model");model.Name=def.id;model.WorldPivot=CFrame.identity
        model:SetAttribute("Region",def.id);model:SetAttribute("EncountersEnabled",false);model:SetAttribute("ArtVersion",1)
        for _,piece in ipairs(def.parts) do
            local p:BasePart=if piece.wedge then Instance.new("WedgePart") else Instance.new("Part")
            p.Name=piece.name;p.Size=piece.size;p.CFrame=CFrame.new(piece.pos)*CFrame.Angles(0,math.rad(piece.yaw),0)
            p.Color=piece.color;p.Material=Enum.Material.SmoothPlastic;p.Anchored=true
            p.CanCollide=piece.collide;p.CanQuery=piece.collide;p.CanTouch=false;p.Parent=model
        end
        local markers=Instance.new("Folder");markers.Name="EncounterMarkers";markers.Parent=model
        for _,entry in ipairs(def.markers) do
            local p=Instance.new("Part");p.Name=entry.name;p.Size=V(1,1,1);p.CFrame=CFrame.new(entry.pos)
            p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false
            p:SetAttribute("Role",entry.role);p.Parent=markers
        end
        local routes=Instance.new("Folder");routes.Name="ReviewRoutes";routes.Parent=model
        for _,entry in ipairs(def.routes) do
            local path=Instance.new("Folder");path.Name=entry.name;path.Parent=routes
            for index,pos in ipairs(entry.points) do
                local point=Instance.new("Vector3Value");point.Name=tostring(index);point.Value=pos;point.Parent=path
            end
        end
        model.Parent=folder
    end
    return folder
end
