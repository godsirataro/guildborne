--!strict
-- Chapter 00 balance candidate. All objective receipts originate on the server.
return {
 Version=1,
 ObjectiveLabels={
  meet_courier={"Meet the courier","พบคนส่งสาร"},walk_route={"Follow the training path","เดินตามเส้นทางฝึก"},
  dodge_warning={"Move clear of the warning","หลบออกจากพื้นที่เตือน"},help_courier={"Help the courier","ช่วยคนส่งสาร"},
  practice_attack={"Practice a basic attack","ฝึกโจมตีพื้นฐาน"},dodge_area={"Dodge the area attack","หลบการโจมตีเป็นพื้นที่"},rescue_dummy={"Rescue the practice captive","ช่วยตัวประกันฝึก"},
  follow_tracks={"Follow the caravan tracks","ตามรอยขบวนเกวียน"},caravan_choice={"Choose who or what to rescue","เลือกช่วยคนหรือกู้เสบียง"},caravan_fallback={"Help recover what was left behind","กลับไปช่วยสิ่งที่เหลืออยู่"},
  defeat_keeper={"Defeat the Crossroads Keeper","ปราบผู้คุมทางแยก"},free_captive={"Free the captive","ปล่อยตัวผู้ถูกจับ"},inspect_false_crest={"Inspect the false guild crest","ตรวจตรากิลด์ปลอม"},
  try_Warrior={"Try Warrior training","ทดลองฝึกนักรบ"},try_Knight={"Try Knight training","ทดลองฝึกอัศวิน"},try_Archer={"Try Archer training","ทดลองฝึกนักธนู"},try_Mage={"Try Mage training","ทดลองฝึกนักเวท"},try_Priest={"Try Priest training","ทดลองฝึกนักบวช"},
  clear_abandoned_hall={"Clear the abandoned Hall alone","เคลียร์หอกิลด์ร้างด้วยตัวเอง"},register_guild={"Register your personal guild","ลงทะเบียนกิลด์ส่วนตัว"},
 },
 Chapters={
  {Id="MAIN_00_01",Level=1,XP=100,Title="The Unmarked",Thai="คนไม่มีตรา",Objectives={"meet_courier","walk_route","dodge_warning","help_courier"}},
  {Id="MAIN_00_02",Level=3,XP=100,Title="A Borrowed Weapon",Thai="อาวุธที่ยืมมา",Objectives={"practice_attack","dodge_area","rescue_dummy"}},
  {Id="MAIN_00_03",Level=5,XP=100,Title="The Caravan's Debt",Thai="หนี้ของขบวนเกวียน",Objectives={"follow_tracks","caravan_choice","caravan_fallback"}},
  {Id="MAIN_00_04",Level=7,XP=100,Title="The Crossroads Keeper",Thai="ผู้คุมทางแยก",Objectives={"defeat_keeper","free_captive","inspect_false_crest"}},
  {Id="MAIN_00_05",Level=9,XP=50,Title="Before the Oath",Thai="ก่อนคำสาบาน",Objectives={"try_Warrior","try_Knight","try_Archer","try_Mage","try_Priest"}},
  {Id="MAIN_00_06",Level=10,XP=0,Title="The Right to Found a Guild",Thai="สิทธิ์ที่จะตั้งกิลด์",Objectives={"clear_abandoned_hall","register_guild"}},
 },
 HeroXP=450, HeroLevel=10, HeroRank="F",
}
