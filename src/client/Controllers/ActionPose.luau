--!strict
-- Shared R6/R15 cosmetic choreography; never moves the authoritative root.
local function ease(x: number): number
	x=math.clamp(x,0,1);return x*x*(3-2*x)
end
return function(class: string,effect: string,age: number,jointName: string): CFrame?
	if age<0 or age>.62 then return nil end
	local wind=ease(age/.10)
	local release=ease((age-.10)/.14)
	local settle=1-ease((age-.26)/.36)
	local charge=wind*(1-release);local strike=release*settle
	-- Brief recoil accent without freezing locomotion or moving the authoritative root.
	local recoil=math.sin(math.clamp((age-.24)/.16,0,1)*math.pi)*settle
	local n=jointName:gsub(' ','');local left=n:find('Left')~=nil
	local sign=if left then -1 else 1
	local x,y,z=0,0,0
	local support=effect=='Heal' or effect=='Guard' or effect=='Taunt'
	if n:find('Shoulder') then
		if class=='Knight' and support then x=if left then -1.2*charge-1.4*strike else -.6*charge-.9*strike;z=sign*.22*(charge+strike)
		elseif support then x=-1.1*charge-1.7*strike;z=sign*(.35*charge+.65*strike)
		elseif class=='Archer' then x=-1.35*(charge+strike)+.24*recoil;y=sign*(.8*charge+.3*strike);z=if left then -.2*strike else .8*charge-.25*strike
		elseif class=='Mage' or class=='Priest' then x=-.9*charge-1.8*strike;y=sign*.4*charge;z=sign*(.8*charge+.2*strike)
		elseif left then x=-.45*charge-.65*strike;z=-.3*strike
		else x=-2.3*charge+.5*strike;y=-.65*charge+1.1*strike;z=.6*charge-.9*strike end
	elseif n=='RootJoint' or n=='Waist' then
		if support then x=.1*charge-.12*strike
		elseif class=='Archer' then y=.55*charge+.25*strike
		elseif class=='Mage' or class=='Priest' then x=.22*charge-.3*strike+.12*recoil;y=-.25*charge+.3*strike
		else x=.18*charge-.22*strike;y=-.65*charge+(if effect=='Area' then 1.1 else .65)*strike;z=-.1*strike end
	elseif n=='Neck' then x=-.12*charge+.08*strike;y=.18*charge-.15*strike
	elseif n:find('Hip') then x=sign*(.15*charge-.22*strike);z=sign*.09*(charge+strike)
	elseif n:find('Elbow') then x=-.45*charge-.12*strike
	else return nil end
	local shift=if class=="Warrior" and not support and (n=="RootJoint" or n=="Waist") then Vector3.new(0,-.23*charge+.06*recoil,-.18*strike) else Vector3.zero
	return CFrame.new(shift)*CFrame.Angles(x,y,z)
end
