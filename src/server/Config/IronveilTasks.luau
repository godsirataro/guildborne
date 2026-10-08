--!strict
-- Server-owned prototype puzzle instructions; all information also has visual text.
return {
 Signal={Sequence={"triangle","diamond","cross"},Symbols={triangle="△",diamond="◇",cross="×"},SafeShaft="diamond",Instruction={"Read the signals: TRIANGLE → DIAMOND → CROSS. The diamond marks the safe shaft.","อ่านสัญญาณ: สามเหลี่ยม → ข้าวหลามตัด → กากบาท ทางที่มีข้าวหลามตัดคือทางปลอดภัย"}},
 Repair={Sequence={"support_2","support_1","support_3"},Instruction={"Shore the centre, then left, then right: 2 → 1 → 3.","ค้ำตรงกลางก่อน แล้วซ้าย และขวา: 2 → 1 → 3"}},
 Protection={Preparation=4,Duration=22,Health=3,Warning=2.5,Interval=4,RequiredBlocks=3,Lanes={"left","centre","right"},Instruction={"Watch the marked lane. Close its safety shutter before the warning ends. Block all three hazards.","ดูช่องที่มีสัญญาณเตือน แล้วปิดบานนิรภัยช่องนั้นก่อนหมดเวลา ป้องกันให้ครบสามครั้ง"}},
}
