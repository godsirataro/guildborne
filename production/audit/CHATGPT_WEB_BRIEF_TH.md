# Guildborne — Feature inventory, Roadmap และ Website brief

ข้อมูล ณ 14 ตุลาคม 2026 (Asia/Bangkok) สำหรับแนบให้ ChatGPT Web

เอกสารนี้เป็นภาพรวมผลิตภัณฑ์จากซอร์สและแผนล่าสุด ไม่ใช่ประกาศเปิดเกม รายการครอบคลุมกลุ่มฟีเจอร์ของเกม ไม่ใช่สัญญาว่าทุกไอเทม/เควสต์/asset พร้อมใช้งานแล้ว สถานะโดยรวม: **Local candidate in progress / ยังไม่พร้อม Public**

Repository: https://github.com/godsirataro/guildborne

Branch: `codex/guildborne-agentic-production-20261009` — ให้อ่าน branch นี้ก่อน `main` เพราะมีงานล่าสุด เอกสาร README และ phase เก่าบางส่วนยังเป็นประวัติ ไม่ใช่สถานะปัจจุบัน หาก ChatGPT เปิด private repository ไม่ได้ ให้แนบไฟล์นี้พร้อมเอกสารอ้างอิงท้ายไฟล์

## 1. เกมคืออะไร

Guildborne เป็น original fantasy RPG บน Roblox ผู้เล่นลงต่อสู้เองและสั่งทีมฮีโร่ NPC ได้สูงสุด 5 คน มีการพัฒนาอาชีพ สำรวจโลก ทำเควสต์ เก็บทรัพยากร คราฟต์ และสร้าง Guild/Hall บนเกาะส่วนตัว ตัวเกมใช้ Roblox-native UI รองรับภาษาไทยและอังกฤษ เว็บไซต์เป็นหน้าแนะนำเกม/ติดตามการพัฒนาแยกจาก UI ในเกม

คำศัพท์ที่ต้องใช้ให้ตรงกัน:

- **Personal Guild**: ผู้เล่นมนุษย์เจ้าของหนึ่งคน + ฮีโร่ NPC ของตน + Hall/เกาะ ไม่มีสมาชิกมนุษย์คนอื่น
- **Hero team**: ฮีโร่ NPC สูงสุด 5 คนต่อเจ้าของ ไม่ใช่ Party ผู้เล่นจริง
- **Human Party**: กลุ่มชั่วคราวสูงสุด 6 ผู้เล่นรวมผู้นำ เป็นข้อกำหนดก่อน Public แต่ยังไม่ได้ implement
- **Federation / สมาพันธ์**: การรวมตัวแบบถาวรข้ามผู้เล่น/Personal Guild อยู่หลังเปิดเกม
- **Solo**: ไม่ต้องเข้า Human Party และยังพาฮีโร่ของตนได้
- **Appearance race**: Human, Elf, Orc, Dwarf เป็นรูปลักษณ์ ไม่ใช่การเปลี่ยนโบนัส ancestry เดิม; Wizard ใช้รูปลักษณ์ Human

## 2. วิธีอ่านสถานะ

| ป้าย | ความหมาย |
|---|---|
| มีซอร์ส / รอรับรอง | มี implementation ใน repository ต้องผ่านการเล่นและเกณฑ์ release ที่เกี่ยวข้องอีก |
| ทดสอบบางส่วน | มีรายงานการทดสอบเฉพาะ scenario/candidate ไม่ใช่ผ่านทั้งเกม |
| กำลังพัฒนา | มี foundation/preview แต่ยังมีงานที่ขาด |
| วางแผนก่อน Public | เป็น launch requirement ที่ยังไม่ครบ |
| หลังเปิดเกม | เก็บไว้ใน roadmap ยังไม่เปิดให้ใช้ใน launch |
| ปิดใช้งาน | อาจมีโค้ดแล้ว แต่ยังไม่อนุญาตให้เปิดใช้จริง |

การมีไฟล์, ผ่าน automated tests, import เข้า Roblox, ผ่าน Studio, ผ่านมือถือจริง, human UAT และเปิด Public เป็นคนละสถานะ ห้ามรวมเป็นคำว่า Done ช่อง target date ใช้ `TBD` จนกว่าจะมีวันที่อนุมัติ ไม่แสดงเปอร์เซ็นต์ความพร้อมรวมที่ไม่ได้วัด

## 3. Feature inventory

### ผู้เล่น อาชีพ และฮีโร่

| ID | ฟีเจอร์และขอบเขต | สถานะ/ช่วง |
|---|---|---|
| F01 | เริ่ม Novice Lv1, tutorial และบทเรียนก่อนเลือกอาชีพ | มีซอร์ส + เส้นทางบางส่วนทดสอบใน Memory |
| F02 | Class1 ที่ Lv10: Warrior, Knight, Archer, Mage, Priest ผ่านเงื่อนไข/เควสต์จริง | ก่อน Public; ยังต้องรับรองครบทุกอาชีพ |
| F03 | Class2 ที่ Lv35 พร้อม mentor story/trial | มีซอร์ส; เส้นทางผู้เล่น Berserker เคยทดสอบบางส่วน |
| F04 | 10 Class2 paths: Berserker, Duelist, Guardian, Paladin, Ranger, Sniper, Elementalist, Spellblade, Cleric, Oracle | อยู่ใน launch catalog; ไม่ใช่รับรองครบทุกสาย |
| F05 | Class3 ที่ Lv70 และพัฒนาถึง Lv100 ไม่มี Class4 | หลังเปิดเกม; launch จำกัด Lv35 |
| F06 | Skill trees, จัด active skills, cooldowns, SP และ AP, reset/respec ที่คืนงบเดิม | มีซอร์ส; รอ balance/route acceptance |
| F07 | กติกาปัจจุบัน 1 SP และ 3 AP ต่อเลเวลหลัง Lv1; เก็บ earned legacy progression | ข้อกำหนด; ห้ามเปลี่ยน save เก่าให้เสียสิทธิ์ |
| F08 | รับสมัครฮีโร่ที่ tavern หลัง Class1/Hall story; ฮีโร่ใหม่ Novice ruleset เริ่ม Lv10 | มีซอร์ส; ต้องตรวจ pacing เส้นทางจริง |
| F09 | ทีม NPC สูงสุด 5 คน, follow/formation/สั่งเป้าหมายและบทบาทต่อสู้ | มีซอร์ส; full-party acceptance ยังเหลือ |
| F10 | ฮีโร่มี XP/level/class/skill/status/equipment ของตน และรองรับฮีโร่ซ้ำแบบแยก instance | มีซอร์ส; ห้ามใช้ชื่อฮีโร่เป็น ownership |
| F11 | Hero Class2 mentor proof/trial แยก subject และ path, UI train/advance/cancel | มีซอร์ส + scoped fixtures; normal hero Lv35 route ยังต้องรับรอง |
| F12 | Hero identity, bonds/personal stories และ reward-once | identity มีซอร์ส; bonds/personal stories เป็นงาน narrative ที่วางแผน ยังไม่ยืนยัน playable implementation |
| F13 | ส่งทีม expedition แบบจับเวลา, กลับมารับรางวัล, เก็บ active snapshot | มีซอร์ส; save/rejoin acceptance ของ candidate ล่าสุดยังต้องตรวจ |

### ต่อสู้ โลก และเนื้อเรื่อง

| ID | ฟีเจอร์และขอบเขต | สถานะ/ช่วง |
|---|---|---|
| F14 | Player combat และ companion combat: melee/ranged/magic/heal/tank/support | มีซอร์ส; server เป็นผู้ตัดสินผล |
| F15 | Ability targeting, damage/heal/status, aggro/leash, death/recovery, safe zones | มีซอร์ส; balance และ full-route QA ต่อเนื่อง |
| F16 | ศัตรูหลาย archetype, bosses, phase/telegraph และรางวัลที่รับครั้งเดียว | มี catalog/implementation; final encounter acceptance ไม่ครบ |
| F17 | เล่น Solo พร้อมฮีโร่และเล่นกับคนอื่นใน supported shared PvE | Solo foundation มี; shared multi-owner PvE ยังเป็นงานก่อน Public |
| F18 | Human Party 1–6: invite/accept/decline/expire, leave/kick/disband, leader transfer, rejoin grace | วางแผนก่อน Public / ยังไม่ implement |
| F19 | Party roster/ready check/ยอมรับการเดินทางและ instance recovery | วางแผนก่อน Public |
| F20 | Solo/Party/เจ้าของพร้อม NPC เข้าร่วม encounter เดียวกันได้ โดยไม่บังคับเข้าปาร์ตี้ | วางแผนก่อน Public; capacity ยังต้องวัด |
| F21 | แบ่ง EXP/Gold/stackable loot จากงบ encounter เดิมตามผู้เล่นที่มีสิทธิ์; NPC นับให้เจ้าของ | design proposal ก่อน Public; eligibility/rounding ยังต้องกำหนด |
| F22 | ของชิ้นเดียวแจกเพียงครั้งเดียว; quest/class key item แยกสิทธิ์รายคน; durable pending reward/retry | design proposal ก่อน Public; ไม่ใช่ระบบที่เปิดแล้ว |
| F23 | เมืองหลัก/สถาบัน: tavern, forge, quest hall, market และทางเชื่อม/portal/map/navigation | มีซอร์สและรายงาน fixture; รับรองบริการใน full game แยกต่างหาก |
| F24 | เมือง Crownford, Sylvaris, Deepforge, Astralis, Crosshaven, Ironroot | มี world content; launch resolver มี allowlist ไม่เท่ากับทุกกิจกรรมเปิด |
| F25 | Adventure regions เช่น Greenwood และ Ironveil; เนื้อหาพื้นที่หลัง launch จำกัดตาม release policy | มีซอร์ส; launch boundary implement แล้ว |
| F26 | Main campaign: launch 2 arcs / 12 campaign steps; เก็บ catalog 6 arcs เพื่อรองรับข้อมูลเดิมและ expansion | launch source มี + บางเส้นทางทดสอบ; arcs ถัดไปหลังเปิด |
| F27 | Main/side/secret/world/class/hero quest families, journal, tracker, NPC prerequisite hints, turn-in/rewards | มีหลายระบบ; เนื้อหาที่ออกแบบไว้ไม่เท่ากับ playable ครบ |
| F28 | Borin blacksmith: รับงาน คราฟต์ ingots สองชิ้น เคลมและเดินทาง Deepforge | normal local route เคยทดสอบบน candidate ที่รายงานไว้ |
| F29 | Friendly NPC talk/work/travel/interruption/recovery และเมืองมีชีวิต | มีระบบ/การ bind บางส่วน; motion/contact/audio/art ยังต้องตรวจ |
| F30 | Bestiary และข้อมูลการสำรวจ/ศัตรู | มีซอร์ส; presentation ต้องตรง release boundary |
| F31 | Tower 10 ชั้น, advanced paths และ late-game encounters | มี legacy foundation; tower ถูกจำกัดใน launch candidate ปัจจุบัน |
| F32 | แคมเปญส่วนต่อไป, Class3, ending/story memory และ progression ถึง100 | หลังเปิดเกม; มีซอร์สบางส่วน ไม่ประกาศว่าเปิดแล้ว |

### Guild เกาะ สิ่งของ และเศรษฐกิจ

| ID | ฟีเจอร์และขอบเขต | สถานะ/ช่วง |
|---|---|---|
| F33 | Personal Guild/Hall เริ่มต้นฟรีและเกาะส่วนตัว เข้าถึงจากเมือง | มีซอร์ส; launch route/ownership QA ต่อเนื่อง |
| F34 | Hall เพิ่ม level cap: Hall1=20, +5 ต่อ Hall จน Hall17=100; Hall18–20 ผลอื่น | มี ruleset; launch candidate จำกัด Hall4/Lv35 |
| F35 | Housing/hero capacity และอาคาร utility | มี foundation; balance/visual acceptance ต่อเนื่อง |
| F36 | Build Mode: วาง/หมุน/ย้าย/เก็บ/นำกลับ, costs/materials, server placement validation | มีซอร์ส; multiplayer/device acceptance ยังเหลือ |
| F37 | ขยายที่ดิน/quest rights/purchase rights/material delivery/buildable state แยกกัน | มี foundation; purchase fulfillment ยังไม่เปิด |
| F38 | ธีมเกาะ/อาคาร/สิทธิ์ theme และการย้ายไม่ล้าง ownership | มี foundation; ครบทุก theme/fit/art ยังเหลือ |
| F39 | Furniture crafting/placement/storage/recycling และ collision footprint | มี implementation/asset studies; indoor/final polish ยังเหลือ |
| F40 | Island directory, private/friends/public access, owner-online visits, remove guest และ safe return | current-server foundation; cross-server/real-client acceptance ยังเหลือ |
| F41 | Inventory: item stacks/instances/materials, filter/compare, full-bag state | มีซอร์ส |
| F42 | แยก equipment ของ player/แต่ละ hero; weapon/armor/accessory, equip/unequip/transfer และ visible gear | มีซอร์ส; modular appearance fit ยังต้องรับรอง |
| F43 | Gathering, recipes, crafting, Gold shop, confirmed sale และ currency/material costs | มีซอร์ส; replay/value integrity สำคัญ |
| F44 | Gold/XP/quest first-clear rewards และ persistence/recovery | มีซอร์ส; latest candidate cloud/rejoin acceptance ไม่อนุมานจากอดีต |
| F45 | Global player market: orders, escrow, partial fills, cancel, claims, reference prices/history | โค้ด Phase4.5 มี; ปิด public และอยู่หลัง launch |
| F46 | Market recovery/fencing/idempotency/epochs/circuit breakers และ conservation | มีระบบ + historical evidence; live cross-server qualification ยังเหลือ |
| F47 | Federation: รวม Personal Guild/ผู้เล่นอิสระ, บทบาท/คำสั่ง/ถอนตัว | หลังเปิด; legacy PlayerGuild modules ไม่ใช่ฟีเจอร์ launch ที่เสร็จแล้ว |
| F48 | Guild conflict/war/territory, roster locking, result-once, timed/capped benefits | หลังเปิด; ไม่โฆษณาว่าเปิด PvP/war แล้ว |

### รูปลักษณ์ UI เสียง และบริการเกม

| ID | ฟีเจอร์และขอบเขต | สถานะ/ช่วง |
|---|---|---|
| F49 | 4 cosmetic races: Human, Elf, Orc, Dwarf | required Public; source catalog มี การ import ครบยังไม่ผ่าน |
| F50 | 13 body presets และ 20 palettes; Beta เลือก 8 presets ก่อน | catalog/targets; ไม่ใช่ 13 models ที่ import เสร็จ |
| F51 | 15 R15 core parts; เสื้อ/กางเกง/ผม/เครา/หู/เขี้ยว/gear แยกชิ้น; modesty coverage | pipeline/บาง candidate มี; cages/fit/runtime imports ยังเหลือ |
| F52 | Customization, preview และ server-validated cosmetic ownership; fair combat proxies | มีซอร์ส/preview; asset bindings ยังไม่ครบ |
| F53 | Native title/HUD/hero commands/status/skill tree/inventory/map/quest/build/reward panels | มี native UI; เว็บไม่ใช้แทน UI ในเกม |
| F54 | TH/EN, responsive layouts, loading/empty/error/retry/unavailable states | มี implementation บางส่วน; ต้องตรวจครบทุก route/ภาษา |
| F55 | Accessibility: readability, non-color cues, safe areas, reduced motion/flashes/input support | เป้าหมาย/งานรับรอง; ไม่อ้าง physical touch/controller ผ่านแล้ว |
| F56 | Animation: locomotion/attack/cast/NPC work; shared semantic action timing/cancellation | มี integration และ contact studies; final class/body coverage ยังเหลือ |
| F57 | Skill VFX/projectiles/impacts/healing/boss warnings, cleanup และ quality budgets | มีซอร์ส; heavy-party/device readability ยังต้องวัด |
| F58 | UI/combat/world audio, spatial cues/mix/concurrency และ transition | มี hooks/ต้นฉบับบางส่วน; runtime IDs/listening acceptance ยังไม่ครบ |
| F59 | Free daily check-in 7-step UTC cycle ขาดวันไม่รีเซ็ตลำดับ | มี local preview implementation; ยังไม่ใช่ live rewards |
| F60 | Season/Battle Pass: 6 story-earned preview tiers, free/premium tracks | free preview มี; priced season/rollover/entitlement ยังไม่ครบ |
| F61 | Premium shop/Pass/Product และ PvE buffs ตาม caps ไม่ข้าม class/Hall/content gates ไม่ใช้ใน war | launch requirement; ราคา/IDs/entitlement/live sales ยังไม่พร้อม |
| F62 | Save migration, session ownership, retry/load recovery, replay-safe claims, anti-exploit validation | มีระบบ; ต้องตรวจ current candidate และ old/new/bad saves |
| F63 | Performance/streaming/bounded AI/UI/VFX budgets, mobile target 30FPS บนอุปกรณ์ขั้นต่ำที่ระบุ | acceptance target; ยังไม่ใช่คำรับรองทุกอุปกรณ์ |
| F64 | Devlogs/feedback/first-session funnel/retention/incident monitoring | website/liveops proposal; ใช้ข้อมูลจริง ไม่สร้างยอดผู้เล่นปลอม |

Public presets: Human STANDARD/HEAVY/SLIM/ATHLETIC; Elf GRACEFUL/STURDY/RANGER; Orc STANDARD/HEAVY/LEAN; Dwarf COMPACT/STOUT/BROAD. Beta ใช้สองตัวแรกของแต่ละเผ่า รวม8; ไม่สร้างชื่อ ELF_STANDARD หรือ DWARF_STANDARD ขึ้นใหม่

รายละเอียด catalog ที่ใช้ทำหน้าเว็บเพิ่มเติมได้ โดยยังต้องคงป้ายสถานะ:

- Class2 mapping: Warrior→Berserker/Duelist; Knight→Guardian/Paladin; Archer→Ranger/Sniper; Mage→Elementalist/Spellblade; Priest→Cleric/Oracle
- Class3 catalog หลังเปิด: Warlord, Sword Saint, Fortress, Holy Sentinel, Wild Warden, Deadeye, Archmage, Arcane Knight, High Priest, Prophet; special-path catalog มี Commander, Rune Knight, Bard, Shadow Dancer ไม่ใช่ launch promise
- Story catalog หลังสอง arcs แรก: Ashen, Tower, Crosshaven, Archive Heart; การเข้าเมือง Crosshaven ได้ไม่ได้แปลว่า campaign arc หลังเปิดแล้ว
- อาคาร: Hall, Warehouse, Hero Quarters, Blacksmith; plots: Grove Terrace, Quarry Terrace, Summit Terrace
- Themes: Human Hearth, Elven Canopy, Dwarven Forge, Orc Welcome, Mage Observatory, Crosshaven Commons; purchase IDs ยังไม่พร้อม
- Furniture catalog มีโต๊ะ/เก้าอี้/เตียง/ม้านั่ง/ตู้หนังสือ/พรม/ธง/กระถาง/โคมคริสตัล/แท่นโชว์; roster มี rank F→SSS และ tavern scouting/hiring foundation
- สำคัญ: `Content.StatusAllocationAvailable=false`; runtime journey preview toggles และ permanent purchase activation ยังปิดโดย default จึงห้ามอ่านแถว skill/status/hero ว่าเปิดใช้ทุก environment แล้ว

## 4. Timeline / Roadmap แบบมี exit gate

นี่คือลำดับการส่งมอบ ไม่ใช่ประมาณระยะเวลาที่ผ่านการประเมินทีมแล้ว ทุกวันเริ่ม/สิ้นสุดเป็น TBD และบางงานทำขนานกันได้ หากต้องการ calendar ให้ ChatGPT เสนอเป็น scenario พร้อมสมมติฐานกำลังคนและความเสี่ยง ห้ามนำไปแสดงเป็นวันสัญญาเปิดเกม

| Milestone | งานและ dependency | เงื่อนไขจบ | วัน |
|---|---|---|---|
| M0 Current snapshot | รวบรวมซอร์สล่าสุด ตรวจ baseline และแยก environment | reproducible candidate, local checks, independent review | ณ14 ต.ค.2026; ยังไม่ release |
| M1 Complete Lv1–35 route | Novice→Class1→Hall→heroes→2 arcs→Class2, Borin, ทุก class/hero mentor | เล่นด้วย input ปกติ ไม่มี grants/skip time, TH/EN, save/rejoin, ไม่มีทางตัน | TBD |
| M2 Beta presentation | 4 races/8 presets, rig/clothes/gear fit, skill motion/VFX/audio/NPC/city | real imports/load proof, fit tests, clips/listening/cancel cleanup | TBD; ทำคู่ M1/M3 ได้ |
| M3 Launch systems | Party6/shared Solo-Party encounters, durable split rewards, island permissions/visits, premium/season contracts | lifecycle/fault/replay/value tests, 2/4/6 clients + eligible outsiders, entitlement/rejoin | TBD; Party6 ยังไม่ implement |
| M4 Closed Beta | รวม M1–M3 แล้วทดสอบ route, old saves, platform, devices และผู้เล่นจริง | distinct live servers เมื่อเกี่ยวข้อง, Android/iOS30นาที, bounded memory, no critical issues | TBD |
| M5 Release Candidate | เพิ่มครบ13 presets, final content/commerce/assets, freeze revision, footage/rollback | same-build acceptance, human art/UAT, account/asset/product readiness | TBD |
| M6 Public Lv1–35 | เปิดเฉพาะ scope ที่ผ่าน gates | เจ้าของอนุมัติการ publish และ live commerce แบบเจาะจง | TBD; ยังไม่อนุมัติ |
| M7 Launch care | เฝ้า join/save/reward/tutorial/death/FPS, รับ feedback/แก้ incidents | 72ชั่วโมงแรกมีผู้รับผิดชอบ, review รายวันสัปดาห์แรก | สัมพันธ์กับวันเปิดจริง |
| M8 Expansion | chapters ถัดไป, Class3 Lv70→100, stories/world/tower ตาม scope review | content + save compatibility + play/device/UAT | หลังเปิด; TBD |
| M9 Social/war/economy | Federation, bounded wars/territory และเปิด market แยก gate | permission/settlement/recovery/conservation/cross-server qualification | หลังเปิด; ลำดับย่อย TBD |

Party6 พร้อมฮีโร่คนละ5 = ฝ่ายเดียวกัน36 actors ก่อนศัตรูและผู้เล่นนอก Party ตัวเลขนี้เป็น **stress scenario ที่ต้องทดสอบ** ไม่ใช่ supported server capacity และ6คือขนาด Party ไม่ใช่จำนวนผู้ร่วม encounter สูงสุดโดยอัตโนมัติ

## 5. Website ที่อยากให้ ChatGPT ช่วยออกแบบ

เป้าหมาย: คนใหม่เข้าใจเกมเร็ว, เห็นฟีเจอร์ทั้งหมดพร้อมสถานะ, ติดตาม roadmap/devlog และรู้ว่าอะไรยังไม่พร้อม

| หน้า/ส่วน | เนื้อหา |
|---|---|
| Home | Guildborne, fantasy RPG + five heroes, ภาพจริงพร้อมป้าย build, development status และทางไป Features/Roadmap |
| Features | cards/filter ตาม combat/heroes/progression/world/quests/guild/islands/items/social/appearance/liveops; ค้นหา/ดูรายละเอียด |
| Roadmap | Now/Next/Later + milestone timeline; แสดง dependencies, exit criteria, updated date และ TBD |
| Feature detail | คำอธิบายผู้เล่น, scope, status, target milestone, limitation, devlog/source/evidence links |
| World & Classes | cities/regions, Class1/Class2, เผ่า cosmetic, hero team; ระบุเนื้อหาที่ล็อก/อนาคต |
| Devlog | changelog ตามวันที่พร้อมภาพ/วิดีโอจาก candidate จริงและ known issues |
| FAQ | Guild vs Party vs Federation, Solo, platforms/languages, launch date TBD, marketplace/commerce status |
| Playtest / Community | เพิ่มเฉพาะลิงก์ที่เจ้าของให้และตรวจแล้ว; ถ้ายังไม่มี ใช้ข้อมูลวิธีติดตาม ไม่สร้างลิงก์/แบบฟอร์มปลอม |

MVP website ที่เสนอ: Home + Features + Roadmap + Devlog + FAQ ใน responsive site รองรับ TH/EN เริ่มจาก content files ที่ review ได้ง่าย มี filter/status labels และไม่ต้องมีบัญชีผู้ใช้ ส่วน CMS/community login/feedback backend เป็นข้อเสนอภายหลัง ยังไม่ใช่ approved implementation

แนวภาพ: original fantasy guild journal, parchment/stone/wood/metal ที่อ่านง่าย มีพื้นที่ว่างและตัวอักษรชัด ไม่ยืม artwork คู่แข่ง ไม่ฝังข้อความทั้งหน้าเป็นรูป ลด motion บนมือถือและเคารพ reduced-motion ใช้ placeholder ที่ระบุชัดเมื่อไม่มีภาพจริง

CTA ช่วงนี้: “Explore features / ดูฟีเจอร์”, “View roadmap / ดูแผนพัฒนา”, “Read devlog / อ่านอัปเดต” ปุ่ม “Play now” ใช้เมื่อมี approved public link จริงเท่านั้น

## 6. Suggested content model

เสนอให้แต่ละ feature มี `id`, `titleTH`, `titleEN`, `category`, `summaryTH`, `summaryEN`, `implementationStatus`, `releaseAvailability`, `targetMilestone`, `targetDate` (null), `dependencies`, `acceptanceGates`, `sourcePaths`, `evidenceLinks`, `knownLimitations`, `lastReviewedAt` และ `publicCopyApproved` ไม่ใช้ status เดียวแทนทั้ง development และ availability

สถานะบนเว็บที่แนะนำ: Planned / In development / In testing / Released / Paused โดยจะขึ้น Released ได้เมื่อมี release evidence เท่านั้น ป้าย “Code implemented” แสดงในรายละเอียดได้ แต่ไม่เปลี่ยนเป็น Released อัตโนมัติ

เพิ่ม search, category/status/milestone filters, mobile-readable tables/cards, text alternatives, keyboard access, shareable feature URLs และวันที่อัปเดต ไม่จำเป็นต้องโชว์ internal task ledger, test tokens หรือข้อมูล profile ผู้เล่นบนเว็บ

## 7. Known gaps และสิ่งที่ห้ามกล่าวเกินหลักฐาน

- Party6/shared reward settlement ยังเป็น design requirement; `PartyService` ปัจจุบันคือ NPC team
- 13 body presets อยู่ใน catalog แต่ runtime import/fit/audio IDs ยังไม่ครบ
- Preview daily/season reward ไม่เท่ากับ live Premium/Battle Pass และยังไม่มีราคายืนยัน
- Historical Studio/fixture tests ไม่ใช่ current full-game UAT และไม่ใช่ physical-device/cross-server proof
- ไม่มีวันเปิดยืนยัน ไม่มี overall readiness percentage ที่วัดแล้ว ไม่รับประกันจำนวนผู้เล่น/รายได้/FPS ทุกเครื่อง
- Legacy PlayerGuild/war/market source ต้องแยกจาก approved launch availability
- Git commit/push เป็นการสำรองและแชร์ซอร์ส ไม่ใช่ Roblox publish, merge หรือ live commerce activation

## 8. Prompt พร้อมคัดลอกไป ChatGPT Web

> ช่วยทำหน้าที่ Product Strategist, Information Architect และ UX/UI Designer สำหรับเว็บไซต์ Guildborne โดยใช้เอกสารที่แนบเป็นฐานข้อมูล โครงการเป็น Roblox fantasy RPG ที่มีซอร์สอยู่แล้ว ผู้เล่นหนึ่งคนพาฮีโร่ NPC ได้สูงสุด5คน Personal Guild มีเจ้าของมนุษย์คนเดียว; Human Party สูงสุด6คนเป็น launch requirement ที่ยังไม่ implement; Federation อยู่หลังเปิดเกม
>
> ต้องการเว็บนำเสนอเกม รวม features, timeline roadmap, devlogs, world/classes และ FAQ รองรับ TH/EN และมือถือ ช่วย (1) จัดกลุ่ม feature inventory โดยไม่ตัดเป้าหมายที่ยังไม่เสร็จ (2) เสนอ sitemap/user journeys (3) ร่างข้อความจริงแต่ละหน้า (4) ออกแบบ feature cards/status filters และ roadmap แบบ milestone/dependencies (5) เสนอ visual direction พร้อม wireframe (6) สร้าง content schema ที่ดูแลง่าย (7) แยก MVP website กับงานภายหลัง (8) ชี้ข้อมูลที่ขัดแย้ง/ยังขาด และแนะนำลำดับทำงาน
>
> แยก implementation, testing และ public availability เสมอ ข้อมูลที่ไม่มีให้ติด TBD/Needs confirmation ห้ามคิดวันเปิด ราคา รายได้ จำนวนผู้เล่น ภาพเกม หรือระดับความเสร็จขึ้นเอง หากเสนอระยะเวลา ให้เป็น scenario ตามสมมติฐานกำลังคนและไม่ใช้เป็น public commitment ห้ามเปลี่ยน design proposal ให้กลายเป็นฟีเจอร์ที่เสร็จแล้ว ยังไม่ต้อง publish/deploy หรือเชื่อมระบบชำระเงิน
>
> ใช้ production/LAUNCH_PLAN.md และ production/launch/integration/PARTY6_PLAN.md เหนือ README/phase summaries เก่า หากเปิด GitHub branch ไม่ได้ ให้ทำงานจากไฟล์แนบและแจ้งข้อจำกัด ห้ามอ้างว่าได้อ่าน repository ทั้งหมดหากยังไม่ได้อ่าน เริ่มจากสรุป positioning และ feature grouping แล้วทำ website proposal ที่นำไปพัฒนาต่อได้

## 9. Source map สำหรับตรวจสอบ/แนบเพิ่มเติม

Paths ด้านล่างเป็น repository-relative เพื่อให้ส่งต่อได้:

- Current scope: `production/LATEST_GOALS.md`, `production/LAUNCH_PLAN.md`, `production/launch/backlog.json`
- Co-op gap: `production/launch/integration/PARTY6_PLAN.md`, `src/server/Services/PartyService.luau`, `src/server/Services/RegionalCombat.luau`
- Release gates: `src/server/Config/ReleaseContent.luau`, `src/server/Systems/ReleasePolicy.luau`, `src/server/Config/Runtime.luau`
- Progression: `production/PROGRESSION_CONTRACT.md`, `src/server/Config/Content.luau`, `src/shared/Data/Expansion.luau`, `src/shared/Data/StatusPoints.luau`
- Latest route reports: `production/launch/integration/WORLD_ROUTE_UPDATE.md`, `BORIN_SKILL_UPDATE.md`, `HERO_MENTOR_UPDATE.md`, `HERO_MENTOR_UI_UPDATE.md` (สามชื่อหลังอยู่ใน directory เดียวกัน)
- Rewards: `src/server/Config/LaunchRewards.luau`, `src/server/Systems/LaunchRewards.luau`, `production/launch/rewards.md`
- Appearance: `docs/CHARACTER_ASSET_STATUS.md`, `src/shared/Data/AppearanceCatalog.luau`, `src/server/Services/CharacterAppearance/AppearanceAssetRegistry.luau`
- UI/source catalogs: `src/client/UI`, `src/shared/Data`, `src/server/Config`, `src/server/Services`
- Island scope: `docs/LAUNCH_GUILD_ISLANDS.md`, `docs/uat01/WORK_CHECKLIST.md`
- Market limitations: `docs/PHASE4_5_IMPLEMENTATION.md`, `docs/PHASE4_PRIVATE_SERVER_ACCEPTANCE.md`
- Evidence policy: `production/QUALITY_GATES.md`, `production/MERGE_READINESS.md`

ลำดับอ้างอิง: latest scope correction → current source/runtime policy → exact-candidate evidence → older phase summaries การมีชื่ออยู่ใน inventory ไม่รับรอง final art, localization, balance หรือ release
