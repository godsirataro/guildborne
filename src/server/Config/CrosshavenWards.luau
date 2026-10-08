--!strict
-- Guaranteed temporary tools; camp defense never requires a recruited class.
return {
 Targets={"left","centre","right"},Warning=3,Recovery=4,Interval=1,Duration=40,
 TargetHealth=100,ImpactDamage=35,HealAmount=35,RequiredSuccesses=3,MaxMistakes=2,
 Labels={left={"West ward","เกราะตะวันตก"},centre={"Central ward","เกราะกลาง"},right={"East ward","เกราะตะวันออก"}},
 Roles={Guard={"Shield before impact","กางโล่ก่อนแรงกระแทก"},Mend={"Restore after impact","ฟื้นฟูหลังแรงกระแทก"},Combined={"Shield → restore → shield","ป้องกัน → ฟื้นฟู → ป้องกัน"}},
}
