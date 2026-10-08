--!strict
-- Public map geometry; eligibility is checked on the server command candidate.
local C={}
C.Order={"Crownford","Sylvaris","Deepforge","Astralis","Crosshaven","Ironroot"}
C.Definitions={
 Crownford={X=0,Z=-4000,Quest="elian_charter",Thai="คราวน์ฟอร์ด"},
 Sylvaris={X=400,Z=-4000,Quest="vaela_seedlings",Thai="ซิลวาริส"},
 Deepforge={X=800,Z=-4000,Quest="borin_castings",Thai="ดีปฟอร์จ"},
 Astralis={X=1200,Z=-4000,Quest="nyra_stonecharts",Thai="แอสตราลิส"},
 Crosshaven={X=1600,Z=-4000,Quest="sela_shelter",Thai="ครอสเฮเวน"},
 Ironroot={X=2000,Z=-4000,Quest="roka_shared_pot",Thai="ไอรอนรูท"},
}
C.Services={
 Crownford={Market={X=-58,Z=28},Tavern={X=-58,Z=-28}},
 Sylvaris={Market={X=-60,Z=38},Tavern={X=-60,Z=-22}},
 Deepforge={Market={X=-62,Z=34},Tavern={X=-62,Z=-24}},
 Astralis={Market={X=-60,Z=42},Tavern={X=-60,Z=-20}},
 Crosshaven={Market={X=-56,Z=38},Tavern={X=-70,Z=-22}},
 Ironroot={Market={X=-64,Z=32},Tavern={X=-64,Z=-28}},
}
function C.contains(id:string,x:number,z:number):boolean
 local d=(C.Definitions :: any)[id]
 return d~=nil and x>=d.X-100 and x<=d.X+100 and z>=d.Z-125 and z<=d.Z+125
end
return C
