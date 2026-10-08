--!strict
-- Staged support lessons. All health is private training data, never avatar/profile HP.
return {
 Targets={"left","centre","right"},Warning=3,Recovery=4,Interval=1,Duration=40,
 TargetHealth=100,ImpactDamage=35,HealAmount=35,RequiredSuccesses=3,MaxMistakes=2,
 Labels={left={"Left trainee","ผู้ฝึกด้านซ้าย"},centre={"Centre trainee","ผู้ฝึกตรงกลาง"},right={"Right trainee","ผู้ฝึกด้านขวา"}},
 Roles={Guard={"Shield before impact","กางโล่ก่อนแรงกระแทก"},Mend={"Heal after impact","ฟื้นฟูหลังแรงกระแทก"},Combined={"Read the cue: guard or mend","อ่านสัญญาณแล้วป้องกันหรือฟื้นฟู"}},
}
