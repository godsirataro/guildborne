--!strict
-- Pure local guidance; never teleports, accepts quests or sends movement commands.
local W={}
W.NPCs={Mira={X=250,Z=-1030},["City Herald"]={X=-45,Z=-1080},["Expedition Master"]={X=-175,Z=-840},
    Borga={X=-150,Z=-837},Mogra={X=218,Z=-1034},Rukk={X=404,Z=-990},Ghar={X=39,Z=-1508},
    ["Marshal Elian"]={X=-70,Z=-1090},["Arborist Vaela"]={X=260,Z=-1088},["Smith Borin"]={X=370,Z=-958},
    ["Cartographer Nyra"]={X=-42,Z=-1460},["Harbormaster Sela"]={X=305,Z=-1052},["Steward Roka"]={X=-102,Z=-856}}
function W.progress(x: number,z: number,targetX: number,targetZ: number): (number,boolean)
	local dx,dz=targetX-x,targetZ-z
	local distance=math.sqrt(dx*dx+dz*dz)
	return math.floor(distance+.5),distance<=10
end
function W.heading(localX: number,localZ: number): number
	return math.deg(math.atan2(localX,-localZ))
end
return W
