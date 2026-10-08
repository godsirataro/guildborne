--!strict
-- Candidate first-class lessons. Combat adapters must derive every event server-side.
return {
 Duration=300,MaxDistance=45,MaxEvents=128,
 Classes={
  Warrior={Title="Stand Your Ground",Thai="ยืนหยัดด้วยคมดาบ",Goals={basic_hit=3,dodge=1,victory=1}},
  Knight={Title="Hold Their Attention",Thai="ดึงสายตาศัตรู",Goals={taunt=2,basic_hit=2,victory=1}},
  Archer={Title="Beyond the Reach",Thai="คมศรพ้นระยะ",Goals={ranged_hit=3,dodge=1,victory=1}},
  Mage={Title="Order in the Arcane",Thai="ควบคุมพลังเวท",Goals={ability_hit=3,dodge=1,victory=1}},
  Priest={Title="A Light That Remains",Thai="แสงที่ยังคงอยู่",Goals={heal=40,dodge=1,victory=1}},
 },
}
