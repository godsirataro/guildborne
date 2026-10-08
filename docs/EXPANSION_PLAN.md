# แผนขยาย Guildborne — ตัวละคร ทีม และฐานกิลด์

> Launch scope decision — 2026-10-02: The user requires personal guild islands, portals in every launch city, public/friend visits, quest-gated Robux plot purchases with required material contributions, freely positioned buildings and purchasable permanent mixable building themes together in the FIRST public game release. See [authoritative scope and acceptance](LAUNCH_GUILD_ISLANDS.md). This supersedes older deferral of these specific systems, including theme monetization to Phase9; other release gates remain. Development resumed by the user on2026-10-03. Earlier15%quota pause is superseded; current evidence and remaining launch work are recorded in [the implementation checklist](uat01/WORK_CHECKLIST.md).

> Current decision (2026-09-29): Phase 2 is closed under the user-selected implementation/polish scope. Class 2 unlocks at level 30, Class 3 at 70; no Class 4. Actor cap is 100, unlocked at Guild Hall 20 (five levels per Hall). Existing quest/tower/path prerequisites still apply. Large shared city hub is the next Phase 3 priority. See [closure](PHASE2_CLOSURE.md).


> Current update — 2026-09-28: Current extension: [city, Hall/housing, ranked duplicate heroes, journal and offline jobs](CITY_GUILD_DISPATCH.md) is implemented after Phase 2.7. Earlier fixed roster/Hall limits below are historical. Hero rank is separate from class tier and prestige.

อัปเดต 2026-09-28: ผู้ใช้สั่งให้ทำถึง Phase 2.7 ในรอบเดียว รวม animation และ skill effects งาน 2.2–2.7 ชุดแรกดำเนินการแล้วและทดสอบใน Studio ยังไม่ publish รายละเอียดที่ส่งมอบจริงอยู่ใน [รายงาน 2.4–2.7](PHASE2_4_7_IMPLEMENTATION.md) ส่วนชื่อคลาส/อาคาร/เผ่าเพิ่มเติมนอกชุดส่งมอบยังเป็นแนวคิดอนาคต

## ภาพรวมเกม

ผู้เล่นเป็นหัวหน้ากิลด์ในโลกแฟนตาซีต่างโลก มีอาชีพและลงต่อสู้เองร่วมกับฮีโร่ AI สูงสุด 5 คน พัฒนาตัวเองและทีม สร้างฐานส่วนตัว และไต่หอคอย ส่วน Player Guild ของผู้เล่นหลายคนเป็นระบบอนาคต แยกจากฐานและทีม NPC ส่วนตัว

วงจรหลัก: ออกสำรวจ / เก็บทรัพยากร / ต่อสู้ / ไต่หอคอย → ได้วัสดุ XP อุปกรณ์และพิมพ์เขียว → พัฒนาตัวละคร ทีมและฐาน → เตรียมพร้อมสำหรับความท้าทายสูงขึ้น

## สิ่งที่มีแล้ว

Phase 2.1 มีฮีโร่ Warrior, Knight, Archer, Mage, Priest พร้อม basic attack และ starter ability อย่างละหนึ่ง, Goblin Camp, ระบบ server-authoritative damage/heal/aggro/downed/reward, HP/cooldown UI ไทย-อังกฤษ และการบันทึก Gold/XP เดิม มีคลังบัญชีและการสวมอาวุธฮีโร่แล้ว

Phase 2.2 เพิ่มผู้เล่นเลือกหนึ่งใน 5 คลาส มี stats/XP/level และ basic/skill ของตนเอง เล่นร่วมทีม AI 5 คนได้ มีปุ่ม PC/มือถือ การล้ม/ฟื้นตัว และ migration v1→v2 ผ่าน 75 automated tests, Studio combat ทุกคลาส, mobile simulation และ exact DataStore rejoin; ยังไม่ publish ดู [รายงาน 2.2](PHASE2_2_IMPLEMENTATION.md) ปัจจุบัน Phase 2.4–2.7 เพิ่ม Skill Tree, Class 2/3, Build Mode, หอคอย 10 ชั้น และ Human/Elf/Dwarf แล้ว

## อาชีพและการเลื่อนขั้น

แยกข้อมูลสามแกน: เผ่าพันธุ์, สาย/ขั้นอาชีพ และความเชี่ยวชาญสกิล ไม่ใช้เผ่าพันธุ์แทนอาชีพ

- Class 1 → Class 2 → Class 3 โดยขั้นใหม่มีทางเลือกแตกสาย
- ใช้เลเวลร่วมกับภารกิจทดสอบอาชีพ ไม่เลื่อนด้วยเลเวลอย่างเดียว
- ชุดเล่นปัจจุบันคงเพดาน Lv10: Class 2 ใช้ Lv3 + Quarry Patrol; Class 3 ใช้ Lv6 + หอคอยชั้น 5 ส่วน Lv20/50 เป็นแนวคิดสำหรับการขยายเกมในอนาคต
- Epic / Legendary เป็นประเภทคลาสพิเศษ ส่วน Secret เป็นวิธีค้นพบ/ปลดล็อก จึงอาจเป็นคลาสลับระดับ Epic ได้ ไม่ผูกทุกอย่างไว้ในช่อง rarity เดียว
- คลาสพิเศษมีวิธีเล่นและข้อแลกเปลี่ยน ไม่ใช่เพิ่มค่าสถานะให้เหนือคลาสปกติทุกด้าน
- ผู้เล่นและฮีโร่ใช้ definition ของคลาส/สกิลร่วมกัน แต่เก็บ class path, XP, แต้มสกิลและ build แยกแต่ละคน
- Class tier, class prestige, ความหายากไอเทม และระบบอันดับฮีโร่ F–SSS เป็นคนละเรื่อง; ระบบอันดับ/สุ่มฮีโร่ยังไม่อยู่ในงานนี้

ตัวอย่างสายอาชีพสำหรับออกแบบต่อ ไม่ใช่ catalog ที่รับรองว่าจะผลิตครบในเฟสเดียว:

| Class 1 | Class 2 | Class 3 |
| --- | --- | --- |
| Warrior | Berserker / Duelist | Warlord / Sword Saint |
| Knight | Guardian / Paladin | Fortress / Holy Sentinel |
| Archer | Ranger / Sniper | Beastmaster / Deadeye |
| Mage | Elementalist / Spellblade | Archmage / Arcane Knight |
| Priest | Cleric / Oracle | High Priest / Prophet |

Skill Tree มี active/passive, prerequisite, skill points, loadout และการ reset build สกิลขั้นต้นยังมีประโยชน์หลังเลื่อนขั้น จำนวนปุ่ม active บนมือถือและค่าการ reset ต้องกำหนดก่อนผลิตต้นไม้เต็มชุด

## คลาสพิเศษที่เสนอ

| คลาส | วิธีเล่นและข้อแลกเปลี่ยน |
| --- | --- |
| Commander | สั่งรวมเป้าหมาย ตั้งรับ ถอนกำลัง; เน้นประสิทธิภาพทีมมากกว่า solo damage เหมาะกับหัวหน้ากิลด์ |
| Rune Knight | เลือกรูนอาวุธ/เกราะ/ป้องกันเวท แต่ช่องรูนพร้อมใช้งานจำกัด |
| Bard | เลือกเพลงโจมตี ป้องกัน หรือฟื้นฟู; เพลงหลักเปิดได้หนึ่งแบบ |
| Shadow Dancer | เคลื่อนผ่านเงาและโจมตีด้านหลัง แต่ตัวบางและต้องจับจังหวะ |
| Dragon Knight | สะสมพลังแปลงร่างและใช้ไฟมังกร; มีช่วงอ่อนกำลังระหว่างรอ |
| Spellbreaker | ขัดร่ายและทำลายโล่เวท; ได้เปรียบน้อยลงเมื่อเจอศัตรูกายภาพ |
| Necromancer | ใช้วิญญาณเรียกบริวารหรือเสริมทีม; จำกัดบริวารและทรัพยากร |
| Chronomancer | ชะลอ เร่ง และคืน HP ที่เพิ่งเสียบางส่วน; ดาเมจต่ำ/คูลดาวน์ยาว ไม่ย้อนธุรกรรมหรือโลกทั้งใบ |
| Spirit Warden | เชื่อมพันธะรับความเสียหายแทนเพื่อน; ผู้ใช้รับความเสี่ยงร่วม |
| Bloodbound | ใช้ HP เสริมพลังแล้วดูดคืน; พลาดจังหวะอาจล้ม |
| Beastmaster | เลือกคู่หูแทงก์ ล่า หรือสนับสนุน; พึ่งพาคู่หู |
| Artificer | วางป้อม/กับดัก/อุปกรณ์; ต้องเตรียมตำแหน่ง |
| Oathbreaker | แตกเส้นทางคำสัตย์ของ Knight เพื่อใช้คำสาป; เสียพลังคุ้มกันบางส่วน |

ชุดพิเศษแรกที่แนะนำ: Commander, Rune Knight, Bard, Shadow Dancer แต่ต้องพิสูจน์สายปกติก่อน ส่วนบริวาร/ป้อม/สัตว์คู่หูตามหลังระบบ entity budget และการทดสอบมือถือ เงื่อนไขลับใช้ภารกิจ การสำรวจ เหตุการณ์และการตัดสินใจ ไม่จำเป็นต้องซื้อหรือสุ่ม

## Inventory และ Equipment

ใช้คลังกลางของบัญชีเป็นค่าเริ่มต้น พร้อมหน้าสวมอุปกรณ์แยกผู้เล่นและฮีโร่แต่ละคน ไม่ต้องย้ายของผ่านกระเป๋า 6 ใบ ไอเทมหนึ่ง instance ใส่ได้เพียงผู้สวมหนึ่งคนในเวลาเดียวกัน

ขยายจากอาวุธเดิมไปเกราะ/เครื่องประดับ พร้อม compatibility, เปรียบเทียบ stats, สวม/ถอด, ค้นหา/กรอง และความจุ การเปลี่ยนเจ้าของผู้สวมต้องตรวจและบันทึกแบบ atomic ฝั่ง server แยกวัสดุ stackable จากอุปกรณ์ instance การซื้อขายผู้เล่นยังไม่รวมอยู่ด้วย

## Build Mode และทรัพยากร

เริ่มบนที่ดินส่วนตัวด้วยอาคารสำเร็จรูปบนกริด: preview ก่อนวาง, หมุน, วาง, ย้าย, รื้อ, ตรวจชน/ขอบเขต/ทางเข้า และบอกราคา อาคารแบบพื้น-ผนัง-หลังคารายชิ้นเป็นส่วนขยายภายหลัง

รุ่นแรกให้ Guild Hall เดิมเป็นจุดอ้างอิง และอาคารที่วางได้จำนวนเล็กน้อย ได้แก่ คลังกับที่พัก ก่อนเพิ่มโรงงานที่มีระบบผลิตเต็มรูปแบบ เก็บรายละเอียดสิ่งปลูกสร้างเป็น ID/ตำแหน่ง/การหมุน/ระดับบนกริด ไม่บันทึก Instance หรือส่งราคาจาก client

| อาคารเป้าหมาย | หน้าที่ |
| --- | --- |
| Guild Hall | ระดับฐาน พื้นที่และข้อกำหนดอาคาร |
| ที่พักฮีโร่ | รองรับสมาชิกและกิจกรรมพักฟื้น; ยังไม่เพิ่ม party cap เกิน 5 |
| Tavern | รับสมัครและจัดการฮีโร่ |
| Warehouse | ความจุวัสดุ |
| Blacksmith / Alchemy | ผลิตอุปกรณ์และ consumable เมื่อระบบ crafting พร้อม |
| Training Ground | ทดลองสกิลและจัดทีม |
| Herb Garden | ผลิตสมุนไพรหลังออกแบบ production rules |
| Research Room | พิมพ์เขียวและความเชี่ยวชาญฐาน |

เริ่มไม้ หิน แร่ สมุนไพร โดยนำ Timber/Iron Ore/Herb เดิมมาใช้ ไม่สร้าง ID ซ้ำภายใต้ชื่อใหม่ เพิ่มหินเป็น content ใหม่ตามจำเป็น วัสดุขั้นสูง เช่น คริสตัลมานา เหล็กรูน แก่นวิญญาณตามพื้นที่/หอคอย

Server ตรวจสิทธิ์ที่ดิน ระยะเก็บ cooldown ของแหล่งทรัพยากร จำนวนวัสดุ และ placement ก่อนหักของพร้อมบันทึกอาคาร ป้องกันรับซ้ำและวางพร้อมกันเกินต้นทุน ต้องกำหนดกติกาคืนวัสดุเมื่อรื้อ ย้าย และพื้นที่เต็มก่อนเปิดใช้ ไม่สมมติคืนเต็มจำนวนโดยอัตโนมัติ

## หอคอย

ทำ 10 ชั้นแรกให้จบเป็นกิจกรรมส่วนตัว/ทีม NPC ก่อน co-op: ชั้นปกติ, encounter ต่างรูปแบบ, จุดพัก, บอสเป็นช่วง, checkpoint และชั้นที่ปลดล็อก

แยกรางวัล first-clear ออกจาก repeat rewards ใช้ run ID และ server completion ป้องกัน claim ซ้ำ ตาย/ออกเกมกลับเข้าได้ตามกติกาที่ชัดเจน รางวัลเชื่อม XP, วัสดุ, พิมพ์เขียวและเบาะแสเลื่อนอาชีพ โดยวัสดุพื้นฐานยังมีแหล่งนอกหอคอย ไม่บังคับเปิดโลกกว้างเพื่อให้ระบบนี้เล่นได้

## เผ่าพันธุ์

เริ่มมนุษย์ เอลฟ์ คนแคระสำหรับเนื้อหาชุดแรก แล้วขยายมนุษย์สัตว์ ออร์ค เผ่ามังกร และเผ่าวิญญาณ เผ่ามีรูปลักษณ์ เรื่องราวและ passive ขนาดเล็กพร้อมข้อแลกเปลี่ยน ไม่ล็อกว่าเผ่าใดเป็นอาชีพใดไม่ได้

Phase 2.2 เตรียม race definition/reference และตัวละครมนุษย์ที่เล่นได้ก่อน ไม่เพิ่มขั้นตอนเลือกเผ่า placeholder ที่ยังไม่มีผลจริง เผ่าถัดไปต้องผ่านงาน rig, อาวุธ/เกราะพอดีตัว, hitbox, animation และ mobile QA ก่อนเปิดให้เลือก ฮีโร่เก่าต้องคงเอกลักษณ์และอุปกรณ์เดิมผ่าน migration ที่ชัดเจน

## Animation / VFX / เสียง

ทำท่า idle/run/basic/cast/hit/downed/recover และ feedback ที่จำเป็นไปพร้อมกับคลาสแต่ละชุด ไม่เลื่อนไปทำตอนท้ายเกม กำหนด action markers/telegraph ให้ตรงผล server โดย animation client ไม่เป็นผู้ยืนยัน hit

เมื่อกลไกนิ่งจึงขัดเกลาคอมโบ ท่าแยกอาวุธ/projectile/impact/ฮีล/taunt และเสียง ให้แต่ละคลาสอ่านออกได้ คุม effect lifetime, จำนวนบริวาร/ป้อม และตัวเลือกเอฟเฟกต์สำหรับมือถือ

## ลำดับส่งมอบใหม่

| เฟส | ขอบเขต | เงื่อนไขผ่านหลัก |
| --- | --- | --- |
| 2.2 Player Character & Class Foundation | ผู้เล่นเลือก 1 ใน 5 starter classes, stats/XP/level แยก, basic + starter skill, PC/touch, downed/respawn, โครงสร้าง class tiers/race/skills | เลือก→สู้ร่วมทีม→รับ XP→rejoin ครบ, server rejects forged cast/reward, migration โปรไฟล์เก่าปลอดภัย, regression ผ่าน |
| 2.3 Inventory & Equipment | คลังร่วม ผู้สวมแยกผู้เล่น/ฮีโร่ อาวุธ/เกราะ/เครื่องประดับและ UI | ไม่ใส่ instance ซ้ำ, compatible slots, stat derivation, full-capacity/uncertain-save/rejoin ผ่าน |
| 2.4 Gathering & Build Mode MVP | ทรัพยากรพื้นฐาน, grid prefab, preview/rotate/move/dismantle, Hall/คลัง/ที่พัก | เก็บและหักของครั้งเดียว, placement/สิทธิ์/ทางเดินถูกต้อง, restore ฐานตรง, part budget มือถือ |
| 2.5 Class 2 & Skill Trees | ทำหนึ่งสาย end-to-end ก่อนขยายทั้ง 5, quest advancement, points/loadout/reset, animation/effects รายสาย | ผ่านเงื่อนไขจริง, เลือกกิ่ง/คิดแต้มถูก, reset ไม่มี duplication, build มีข้อแลกเปลี่ยน |
| 2.6 Tower MVP | 10 ชั้น จุดพัก/บอส checkpoint first-clear/repeat rewards | เล่นจบได้, fail/retry/leave/rejoin ปลอดภัย, รางวัลไม่ซ้ำ, เชื่อมฐาน/อาชีพโดยไม่ตัน |
| 2.7 Expanded Classes & Races | Class 3, ชุด Epic/Legendary/Secret, มนุษย์/เอลฟ์/คนแคระครบก่อนเผ่าอื่น, polish และ facility crafting ทีละระบบ | unlock/balance/migration/rig/equipment/performance ผ่านก่อนขยายจำนวน |
| 3+ | Co-op, Player Guild, ตลาด, war/territory และระบบสังคมตาม roadmap เดิม | ผ่าน gate multiplayer/economy/performance ของแต่ละระบบ |

Crafting เต็มรูปแบบเลื่อนจากแผน 2.2 เดิมไปหลัง inventory/build และการพิสูจน์วงจรหลัก ระบบอนาคตอื่นยังไม่ถูกรวมเข้าเฟสถัดไปโดยอัตโนมัติ

## Phase 2.2 ที่ดำเนินการแล้ว

ดำเนินการจากการ review โค้ด combat/persistence เดิม แล้วกำหนด player combat entity และ character progression ที่ไม่ใช้ player avatar แทน hero record เดิม:

1. ล็อก class selection, starter loadout, death/recovery และ XP participation rules ของผู้เล่น
2. เพิ่ม versioned definitions สำหรับ class path/race/skill references และออกแบบ additive schema migration พร้อมทดสอบข้อมูล v1; ยังไม่สร้าง Class 2/3 เต็มต้นไม้
3. ทำ vertical slice ผู้เล่น Warrior หนึ่งสายให้เลือกอาชีพ โจมตี ใช้สกิล และเล่นร่วมฮีโร่ได้ก่อน
4. ใช้สัญญาเดียวกันขยาย Knight, Archer, Mage, Priest พร้อมท่า/effect ที่อ่านออกและควบคุม PC/มือถือ
5. ทดสอบ authority/range/cooldown/ownership, reward participation, เลือกคลาสซ้ำ, downed/respawn และ exact DataStore rejoin; รัน regression ทั้งหมดและบันทึก Studio evidence

จบ 2.2 เมื่อผู้เล่นลงสู้ได้จริงกับทีม 5 คน และ save เดิมไม่เสียหาย ไม่รวม Build Mode, หอคอย, skill tree เต็มหรือคลาสลับในเฟสนี้ ผู้ใช้อนุมัติให้เริ่ม Phase 2.2 แล้วเมื่อ 2026-09-28 หลังรวมข้อมูลจากทั้งสามแชต ตาม [สถานะโครงการ](PROJECT_STATUS.md)


## Phase 2.3 — Inventory & Equipment ที่ดำเนินการแล้ว

ทำคลังบัญชีร่วมกับช่องสวมใส่แยกผู้เล่น/ฮีโร่ทั้งห้า รองรับอาวุธ เกราะ เครื่องประดับ และหน้าดูเปรียบเทียบ/กรองไอเทม ต้องกำหนดความเข้ากันของคลาสและช่อง การย้ายของระหว่างตัวละครแบบ atomic และห้าม instance เดียวสวมสองคน ก่อนขยาย content ทดสอบคลังเต็ม ย้ายของระหว่างภารกิจ save fail และ rejoin ให้ครบ อาวุธฝึกประจำคลาส 2.2 ต้องมีทางเปลี่ยนเป็นอาวุธจากคลังที่ชัดเจน โดยไม่ทำของฮีโร่เดิมหาย

ดำเนินการครบ: คลังร่วม 50 ชิ้น ช่องอาวุธ/เกราะ/เครื่องประดับแยกผู้เล่นและทีม ย้ายของ atomic กรอง/เปรียบเทียบ ร้าน Gold และขายของยืนยันสองขั้น มี prototype ภาพอุปกรณ์บนตัวละคร ผ่าน 89 tests, migration v2→v3 และ Studio rejoin ดู [รายงาน](PHASE2_3_IMPLEMENTATION.md) ยังไม่ publish

## Phase 2.4–2.7 ที่ส่งมอบแล้ว

เก็บไม้/หิน/แร่/สมุนไพร สร้าง Warehouse/Quarters/Blacksmith บนกริดพร้อม preview/หมุน/ย้าย/รื้อ คราฟต์ 3 สูตร มี Class 2 สองสายต่ออาชีพและ Class 3 สิบสายปกติ พร้อม Commander/Rune Knight/Bard แบบ Epic และ Shadow Dancer แบบ Secret Legendary แต้มและสกิลแยกผู้เล่น/ฮีโร่ครบ หอคอย 10 ชั้นมีบอส 5/10 และ checkpoint 5 เลือก Human/Elf/Dwarf พร้อมข้อแลกเปลี่ยนจริง มี procedural animation และ VFX รายประเภท ผ่าน 108 tests และ native tower 10/rejoin ดู [หลักฐาน](PHASE2_4_7_STUDIO_TEST.md)

## ทำอะไรต่อ: Phase 3 — Online activities

เริ่มจากทดสอบแยกข้อมูล/ที่ดินสองผู้เล่น แล้วทำกิจกรรม co-op ขนาดเล็กพร้อมตรวจ party ownership, รางวัล, หลุดแล้วกลับเข้า และโหลดบนมือถือก่อนขยาย multiplayer ระบบตลาดและ Player Guild ยังเป็นเฟสถัดไปตาม roadmap ไม่ได้เปิดใช้ในรอบนี้
