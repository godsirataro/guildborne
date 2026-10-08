--!strict
-- Presentation policy only. No damage, timing authority, prices or gameplay RNG.
local C={
 Version=1,
 QualityAttribute="GuildborneVFXQuality", -- local client override: Auto, High, Low
 ReducedMotionAttribute="GuildborneReducedIdleMotion",
 Distance={Detail=55,Cull=100,Telegraph=150},
 Budget={Desktop=48,Touch=30,Primary=16,Telegraph=16},
 Palette={Warrior=Color3.fromRGB(210,117,62),Knight=Color3.fromRGB(116,154,178),Archer=Color3.fromRGB(139,181,99),Mage=Color3.fromRGB(164,124,193),Priest=Color3.fromRGB(211,180,109)},
 Fire=Color3.fromRGB(231,111,38),Core=Color3.fromRGB(241,225,185),Gold=Color3.fromRGB(195,159,90),
 FireTexture="rbxasset://textures/particles/fire_main.dds",
 SmokeTexture="rbxasset://textures/particles/smoke_main.dds",
 SparkTexture="rbxasset://textures/particles/sparkles_main.dds",
 Primary={
  Warrior={Physical="Warrior.PowerStrike"},Knight={Taunt="Knight.Taunt"},
  Archer={Physical="Archer.PiercingShot"},Mage={Magic="Mage.Fireball"},Priest={Heal="Priest.Heal"},
 },
 TelegraphId="Enemy.Telegraph",
}
function C.resolve(class: string,effect: string): string
 local map=C.Primary[class]
 return if map and map[effect] then map[effect] else class.."."..effect
end
return C
