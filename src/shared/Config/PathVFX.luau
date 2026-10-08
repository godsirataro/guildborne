--!strict
-- Original visual identities for existing arts; no combat authority or cloud assets.
local Expansion=require(script.Parent.Parent.Data.Expansion)
local families={
 cleave={Pattern="Whirl",Color=Color3.fromRGB(221,122,64)},
 lunge={Pattern="Thrust",Color=Color3.fromRGB(229,193,123)},
 bulwark={Pattern="Bastion",Color=Color3.fromRGB(133,182,213)},
 radiance={Pattern="Dawn",Color=Color3.fromRGB(239,203,111)},
 volley={Pattern="Rain",Color=Color3.fromRGB(136,184,103)},
 snipe={Pattern="Sight",Color=Color3.fromRGB(115,204,188)},
 nova={Pattern="Orbit",Color=Color3.fromRGB(178,138,224)},
 arcane_slash={Pattern="Rune",Color=Color3.fromRGB(123,191,224)},
 renewal={Pattern="Sanctuary",Color=Color3.fromRGB(222,201,135)},
 judgment={Pattern="Fate",Color=Color3.fromRGB(185,161,232)},
 commander_art={Pattern="Banner",Color=Color3.fromRGB(220,146,107)},
 rune_knight_art={Pattern="Rune",Color=Color3.fromRGB(141,188,219)},
 bard_art={Pattern="Harmony",Color=Color3.fromRGB(167,209,150)},
 shadow_dancer_art={Pattern="Eclipse",Color=Color3.fromRGB(191,136,220)},
}
local catalog: {[string]:any}={}
for id,ability in pairs(Expansion.Abilities) do
 local family=families[(id:gsub("_master$",""))]
 assert(family,"Missing visual family: "..id)
 catalog[id]={Id="Path."..id,Pattern=family.Pattern,Color=family.Color,Tier=ability.Tier,Class=ability.Class,Effect=ability.Effect}
end
local P={Catalog=catalog}
function P.resolve(id:any,class:string,effect:string):any
 local entry=if type(id)=="string" then catalog[id] else nil
 return if entry and entry.Class==class and entry.Effect==effect then entry else nil
end
return P
