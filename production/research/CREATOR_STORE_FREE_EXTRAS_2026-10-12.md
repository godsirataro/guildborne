# Guildborne — ของฟรีเพิ่มเติม: VFX, animation, อาหาร, potion/poison และหนังสือ

ตรวจวันที่ **12 ตุลาคม 2026** (Asia/Bangkok) · สถานะ **RESEARCH / รอตรวจรับ asset**  
ต่อจาก [รายงานชุดแรก](C:/Work/MySelf/Guildborne/production/research/CREATOR_STORE_FREE_2026-10-12.md)

## ผลที่พบ

ตรวจหน้า Creator Store สดเพิ่ม **17 รายการ** โดยเห็นปุ่ม **Get Model** ทุกชิ้น และอ่าน Description/Technical Details เมื่อมีแท็บนั้น ไม่ได้กดรับโมเดล ดาวน์โหลด หรือเปิดไฟล์ภายใน พบชุด animation ฟรีอีก **4 ชุดนอก Store** ซึ่งผู้สร้างระบุรวม 25 คลิป มีรายละเอียดท่าและใบอนุญาตให้ตรวจได้

คำว่า “ฟรี” ในรายงานหมายถึงหลักฐานการรับ asset จากหน้าเว็บ ยังไม่ยืนยันว่า dependencies ทุกชิ้นมีสิทธิ์ใช้ โหลดใน Guildborne ได้ หรือไม่มีค่าใช้จ่ายแฝงในสคริปต์ ค่า Script Count ที่ไม่แสดงเป็น **unknown/null** ไม่ใช่ศูนย์ จำนวน geometry เป็นของทั้ง asset และไม่ใช่ผลทดสอบมือถือ

**ลำดับแนะนำ:** ตรวจ portal/beam, หนังสือปิดและกาง, ขนมปัง/เนื้อ และ motion packs ที่มีชื่อท่าชัดเจนก่อน ส่วนคลัง VFX ขนาดใหญ่และระบบต่อสู้สำเร็จรูปเป็นตัวเลือกตรวจต่อ P1/P2 คือความสำคัญในการตรวจ ไม่ใช่อนุมัติใช้ production

## VFX และภาพสกิล

| Asset ฟรี / ผู้สร้าง | หลักฐานหน้าเว็บ | ประยุกต์กับ Guildborne | สิ่งที่ยังต้องตรวจ |
|---|---|---|---|
| [Parallax Portal](https://create.roblox.com/store/asset/14375826814) — Roblox Code Samples / @DevelopmentDeadline | 60 triangles, 120 vertices, 1 script; อัปเดต 10 ส.ค. 2023 | ประตู dungeon / เกาะกิลด์มีภาพลึก; P1 | เป็น parallax visual ไม่ได้ยืนยัน teleport/access logic; อ่าน script และ image dependencies |
| [Laser Beam Blaster](https://create.roblox.com/store/asset/16382650186) — Roblox Resources / @TooManyOveralls | 3,553 triangles, 3,531 vertices, 6 MeshParts; อัปเดต 17 ก.พ. 2024 | ศึกษา Beam สำหรับ mage channel, tether และเส้นเตือนบอส; P1 | เป็นพร็อพ blaster ให้ใช้ตามบทเรียน ไม่ใช่หลักฐานว่ามีสกิล beam สำเร็จรูปอยู่ในไฟล์ |
| [Tween Group](https://create.roblox.com/store/asset/13595118497) — Roblox Code Samples / @DevelopmentDeadline | 12 triangles, 24 vertices, 1 script; อัปเดต 21 มิ.ย. 2023 | รวม pulse/fade/scale เพื่อยกเลิกภาพสกิลพร้อมกัน; P1 | utility ไม่ใช่ animation clip; listing ระบุไม่รองรับ PlaybackState/Completed events |
| [Free-to-use VFX Pack #2 — Lazers and Blasts](https://create.roblox.com/store/asset/9088469378) — @BegoneDamen | 15,010 triangles, 32,388 vertices, 10 MeshParts; อัปเดต 13 มี.ค. 2022 | คัด beam/impact ทีละชิ้นเป็น visual variant; P2 | ชื่อระบุ free-to-use แต่ description ว่าง; ที่มา texture/mesh และ scripts ภายในยังไม่ตรวจ |
| [saythrt’s Mega Pack](https://create.roblox.com/store/asset/83841806206726) — No²³ / credited @15VSF | Get Model; อัปเดต 22 เม.ย. 2025; ไม่มี Technical Details tab | คลังอ้างอิงเอฟเฟกต์ เลือกเฉพาะชิ้นเล็ก; P2 | ผู้สร้างกล่าวว่ามี 7k+ textures, 180+ meshes, 14 scripts, 5 premades และ V.111: **เป็น description claims**; ขอเครดิตเมื่อดัดแปลง/repurpose; ที่มารายชิ้นยังไม่ตรวจ |

[บทเรียน Beam ของ Roblox](https://create.roblox.com/docs/tutorials/use-case-tutorials/vfx/laser-traps-with-beams) เชื่อม Laser Beam Blaster โดยตรง ส่วนตัวอย่าง damage ในบทเรียนตั้ง Health เป็นศูนย์เมื่อสัมผัส จึงนำมาใช้ได้เฉพาะแนวคิด presentation โดยผูก damage กับระบบ server ของ Guildborne ภายหลัง

จากรายงานเดิม [Play Smoke Puff](https://create.roblox.com/store/asset/13595063828) และ [Particle Emitter Pack](https://create.roblox.com/store/asset/241587286) ยังเป็นฐานทดลองควันและประกายที่ดี แต่เกมมี fire/smoke/spark อยู่แล้ว ต้องเทียบภาพจริงก่อนเพิ่ม dependency

**แนวคิดประยุกต์ ไม่ใช่สกิลที่ยืนยันว่ามีใน pack:**

- Fire: projectile trail + impact burst ให้จังหวะตรงกับ release เดิม
- Heal: aura สั้น + sparkle; ใช้สี/ทรงแยกทีมและประเภท heal
- Poison: ควันเขียวต่ำ + bubble เป็นภาพทดลองเท่านั้น; ยังไม่พบระบบพิษ/DoT ใน source
- Ice: burst/shards สั้นและคุมพื้นที่โปร่งใสทับซ้อน
- Rune/skill book: หนังสือกาง + วงแสง/หน้ากระดาษเรืองแสงที่ออกแบบตรา Guildborne เอง
- Portal: ใช้ parallax ให้ภาพมีมิติ ส่วนสิทธิ์เข้าเกาะ/teleport ยังอยู่ในบริการเดิม

ต้องวัด effects พร้อม player + companions สูงสุดห้าคน รวม enemy effects ก่อนอ้างว่าเหมาะมือถือ ไม่เปิด emitter ทุกชิ้นจาก Mega Pack พร้อมกัน

## Animation ใน Creator Store

| Asset ฟรี / ผู้สร้าง | สิ่งที่หน้าเว็บยืนยัน | เหมาะตรวจเพื่อ | ข้อจำกัด |
|---|---|---|---|
| [SimpleAnimation [R15]](https://create.roblox.com/store/asset/11720399759) — @GnomeCode | 4,752 triangles, 3,234 vertices, 2 scripts, 3 decals; 8 ธ.ค. 2022 | default R15 locomotion, footsteps/footprints; P2 | ผู้สร้างระบุ R15 แต่เป็น controller/default animations ไม่ใช่คลัง combat/cast ใหม่; ไม่แทน Animate เดิมโดยตรง |
| [Custom R15 Animations](https://create.roblox.com/store/asset/10328759036) — @Btwcodyyy | 1 script, **11 Animation objects**; 23 ก.ค. 2022 | ตรวจ idle/locomotion ที่อาจใช้ได้; P2 | ยังไม่รู้ชื่อทั้ง 11 คลิป ต้นฉบับ ความเข้ากันได้ หรือ permission ของ ID |
| [R15 Sword System With Animations](https://create.roblox.com/store/asset/6091930553) — @Count_Alfie | Get Model; ผู้สร้างระบุ R15 only และ leaderboard ยังไม่ครบ; 16 ธ.ค. 2020; ไม่มี Technical Details tab | ตรวจท่าดาบเป็นรายคลิป; P2 | ไม่ทราบจำนวน clips/scripts; ไม่รับระบบ combat สำเร็จรูปเข้ามาแทน server ของ Guildborne |

**ยังไม่มีตัวที่ยืนยันจากการตรวจครั้งนี้ว่าเป็นท่ากิน ดื่ม อ่านหนังสือ หรือร่ายเวท R15 พร้อมเล่นใน Guildborne** ชื่อ Healing Animations หรือจำนวน Animation objects ใน potion ไม่พอพิสูจน์ชนิดคลิป

Model ID เป็นตัวระบุโมเดลที่บรรจุคลิป ไม่ใช่ AnimationId สำหรับ Animator ต้องตรวจสิทธิ์ของคลิปกับ experience จริง Roblox มีระบบ [แชร์ animations ให้คน กลุ่ม และเกมโดยไม่ต้อง reupload ทุกครั้ง](https://create.roblox.com/docs/education/build-it-play-it-island-of-move/sharing-animations) แล้ว จึงไม่กำหนดให้ reupload แบบเหมารวม

สำหรับ NPC/hero ที่ไม่อยู่ใน Player.Character ต้องจัด Animator และเริ่ม track บน server ตาม [Animation API](https://create.roblox.com/docs/reference/engine/classes/Animation) เพื่อ replication ที่ถูกต้อง โดย animation marker ใช้จัด presentation ได้ แต่ไม่เป็นผู้ตัดสิน damage/reward

## แหล่งเสริมฟรีนอก Creator Store: Cinderlore Studios

เป็น **แหล่งผู้สร้างอีกแห่ง ไม่ใช่ Roblox official** หน้า product ระบุ no payment/signup, เวอร์ชัน 1.0.1, ไฟล์ .rbxm KeyframeSequence และ R15 compatible รายการด้านล่างเป็น **คำกล่าวและข้อมูลบนเว็บผู้สร้าง** ยังไม่ได้ดาวน์โหลด ดู motion จริง หรือทดสอบไฟล์

| ชุด | คลิปที่ผู้สร้างระบุ | ประโยชน์ที่เป็นไปได้ |
|---|---|---|
| [R15 Combat Starter Motions](https://cinderlore.com/products/r15-combat-starter-motions) | 7: guard, guard reaction, hit reaction, punches ซ้าย/ขวา | ท่าต่อสู้พื้นฐาน/ฝึกหุ่น; ไม่มีท่าดาบหรือร่ายเวทที่ยืนยันในรายการ |
| [R15 NPC Interaction Sampler](https://cinderlore.com/products/r15-npc-interaction-sampler) | 6: bow, head shake, pocket pickup, point, think, wave | เพิ่มท่าทางให้ NPC/Bookbinder; ไม่ได้ยืนยัน book-reading |
| [R15 Movement & Dash Sampler](https://cinderlore.com/products/r15-movement-dash-sampler) | 6: dash สี่ทิศ, vault สองมือ, wall jump | ท่าหลบ/เคลื่อนที่ทดลอง; movement gameplay ต้องใช้ code ของเกม |
| [R15 Fishing & Life-Skill Sampler](https://cinderlore.com/products/r15-fishing-life-skill-sampler) | 6: fishing windup/hold/release/wait, sickle, watering | motion layer งานตกปลา/เกษตร; ไม่ยืนยันว่ามีระบบตกปลาหรือเกษตรพร้อมใช้ |

[ใบอนุญาตผู้สร้าง v1.0 มีผล 6 ก.ย. 2026](https://cinderlore.com/license) ให้ใช้ในเกม Roblox เชิงพาณิชย์ แก้ท่า อัปโหลดใต้บัญชี/กลุ่มของเกม และทำงานร่วมทีมแบบ private โดยไม่ต้องเครดิต ห้ามแจก/ขายไฟล์เป็น asset, ใส่ public repository/template/pack, แจก ID เป็นคลังให้คนอื่นใช้ซ้ำ หรือใช้ในเกมนอก Roblox ครอบคลุมเฉพาะสี่ชุดฟรีนี้ ไม่รวม artwork/rig/พร็อพ/เสียง/VFX

[คู่มือนำเข้าเฉพาะของผู้สร้าง](https://cinderlore.com/help/importing-r15-animations) ใช้ editable source แล้ว publish เวอร์ชันสำหรับบัญชี/กลุ่มของเกม เป็น workflow ของชุดเหล่านี้ ไม่ใช่ข้อกำหนด universal ของทุก animation ยังไม่มีการยอมรับเงื่อนไข ดาวน์โหลด หรืออัปโหลดในงานนี้

## อาหารและเครื่องปรุง

| Asset ฟรี / ผู้สร้าง | Geometry ที่หน้าเว็บแสดง | ใช้กับ Guildborne |
|---|---|---|
| [Bread](https://create.roblox.com/store/asset/4933223142) — @WoozyNate | 578 triangles, 858 vertices; 23 เม.ย. 2020 | มื้อร่วมของ Roka, โต๊ะ tavern, ร้านอาหาร; P1 |
| [Meat](https://create.roblox.com/store/asset/1690639246) — @CourageousKyran | 156 triangles, 106 vertices, 1 MeshPart; 30 เม.ย. 2018 | ร้าน butcher/ครัว/หม้อต้ม; P1 |
| [Apple](https://create.roblox.com/store/asset/2759295720) — @kinglalu | 1,540 triangles, 922 vertices, 1 MeshPart; 18 ม.ค. 2019 | สวนผลไม้ ตลาด และตะกร้าส่งของ; P2 |

Description ของทั้งสามชิ้นว่าง จึงยังไม่ยืนยันต้นฉบับหรือ dependencies และไม่ได้พิสูจน์ว่า script-free แนะนำตรวจเป็นพร็อพตกแต่งก่อน ถ้าจะกินแล้วเพิ่ม HP/buff ต้องทำ item/consume contract ของ server แยกจาก mesh และท่าทาง

ชุด “low quality food pack - Claire” ID 130699546775916 ปรากฏใน search index แต่หน้าเว็บสดตอบ 404 จึงไม่อยู่ในรายการฟรีที่ยืนยัน ส่วน Polygon Food Pack ที่ค้นพบแสดงราคา $9.99 จึงคัดออก

## Potion / poison / อุปกรณ์ alchemy

| Asset ฟรี / ผู้สร้าง | หลักฐาน | ใช้กับ Guildborne / ข้อจำกัด |
|---|---|---|
| [Potion V10](https://create.roblox.com/store/asset/13043766945) — @Chrobahh | 1,898 triangles, 1,453 vertices; 8 เม.ย. 2023 | รูปขวดยาทางเลือก; P2; description ว่าง ไม่ยืนยันระบบ potion หรือที่มา |
| [Combat Potion Set](https://create.roblox.com/store/asset/5056649208) — @CharlieForms | 864 triangles, 1,026 vertices, **3 scripts, 6 Animation objects, 6 audio, 3 Tools**; 20 พ.ค. 2020 | ตรวจขวด/ท่าเป็นรายชิ้น; P2; เว็บกล่าว health/speed/forcefield 10 วินาที cooldown 20 วินาที แต่ไม่รับกติกานี้เป็นกติกา Guildborne |
| [blue mystical wizard’s cauldron for halloween](https://create.roblox.com/store/asset/11289365085) — @seG1as | 2,112 triangles, 1,805 vertices, 1 MeshPart; 16 ต.ค. 2022 | รูปหม้อปรุงยาอีกแบบ; P2; description ว่าง ไม่ยืนยัน effects หรือ crafting |

Poison และ potion ควรแยกความหมาย: potion คือขวด/ยาดื่มหรือวัตถุดิบ; poison คือสถานะโจมตี หากเพิ่มภาพ poison cloud ตอนนี้ต้องเรียกว่า visual prototype เพราะยังไม่มีสถานะ damage-over-time ที่ตรวจพบ

## หนังสือ / skill book / recipe / quest

| Asset ฟรี / ผู้สร้าง | หลักฐาน | ใช้กับ Guildborne |
|---|---|---|
| [Low Poly Book](https://create.roblox.com/store/asset/2702822393) — @980246 | **64 triangles**, 128 vertices, 1 MeshPart; 2 ม.ค. 2019 | ปก skill book/recipe/quest ledger หลายสี; P1; ผู้สร้างกล่าวให้ใช้ได้และ donation เป็นทางเลือก |
| [Open book](https://create.roblox.com/store/asset/13794493103) — @zzz_1551 | 514 triangles, 596 vertices, 1 MeshPart; 19 มิ.ย. 2023 | spellbook บน lectern, สูตร alchemy, พร็อพร่ายเวท; P1 |
| [Books](https://create.roblox.com/store/asset/13555696157) — @zzz_1551 | 588 triangles, 764 vertices, 3 MeshParts; 26 พ.ค. 2023 | กองหนังสือบน guild bookcase, ร้าน Bookbinder, library; P2 |

เปลี่ยนปกและตราเป็นงาน Guildborne เอง ไม่ถือว่าพร็อพเหล่านี้ปลดล็อกสกิลในเกมได้ หนังสือกางไม่เท่ากับ animation อ่านหนังสือ

## จุดต่อกับ source ปัจจุบัน

อิงการอ่าน source ใน checkout ที่มีงาน character ค้างอยู่ HEAD `4cc9a8232e0fd9ae7bf517983c274e800e8ad4a4` ไม่ใช่ผลทดสอบ runtime ใหม่

| พื้นที่ | สิ่งที่มีอยู่ | ขอบเขตการประยุกต์ |
|---|---|---|
| VFX | [SkillEffects](C:/Work/MySelf/Guildborne/src/client/Controllers/SkillEffects.luau:236) resolve identity จาก ActionAbilityId/ClassId/ActionEffect; มี 5 root skills และ 24 path arts / 13 visual families | เพิ่ม visual variant ใน resolver/adapter เดิม ให้ release ตรง ActionPose; damage คง server-authoritative |
| Animation | [PlayerCombatController](C:/Work/MySelf/Guildborne/src/client/Controllers/PlayerCombatController.luau:153), HeroAnimator/EnemyAnimator และ ActionPose | player overlay ต้อง blend กับ Animator; companion/enemy ใช้ cosmetic carrier หก joints จึงไม่ใช่ R15 clip drop-in |
| NPC | FriendlyNpcAnimator + CivicWorkMotion ปรับ Motor6D.C0 | ต้องกำหนดเจ้าของ joints/track ก่อนเพิ่ม Animator; ไม่วางสองระบบขับ pose ทับกัน |
| Alchemy | [CityInteriorKit](C:/Work/MySelf/Guildborne/src/server/Services/CityInteriorKit.luau:133) มี alchemy_study, ขวดตกแต่ง 15 ขวด, Flask/Cauldron/PotionSurface; FriendlyNpcKit มีขวดยาถือ | เปรียบเทียบความหลากหลายก่อนแทนของเดิม; library ที่ generated ต้องแก้ generator/adapter ไม่แก้ output ลำพัง |
| Food | [Content quest](C:/Work/MySelf/Guildborne/src/server/Config/Content.luau:155) roka_shared_pot ส่ง Herbs 4 ชิ้นให้มื้อร่วม; มี hearth activity | เพิ่มอาหารตกแต่งเข้ากับ scene ที่มีอยู่; ยังไม่พบ general eat/hunger/buff consume |
| Elixir | [DispatchService](C:/Work/MySelf/Guildborne/src/server/Services/DispatchService.luau:11) BuyElixir/ReviveHero | Elixir เป็น counter ฟื้น hero ใช้ Gold 1000 ไม่ใช่ HP/mana drink; ห้ามเปลี่ยนความหมายหรือ save เดิม |
| Books/skills | [FurnitureKit](C:/Work/MySelf/Guildborne/src/shared/Presentation/FurnitureKit.luau:42) guild_bookcase; TowerCharacterKit.Bookbinder; SkillTreeView/ExpansionView และ ExpansionService | native UI/learn/equip/reset ใช้กติกา SP เดิม; ยังไม่พบ consumable skill-book unlock |
| Poison | effect ที่พบคือ Heal/Taunt/Area/Guard/Drain/Slow และ direct hit | ภาพควันไม่เพิ่ม DoT เอง; ถ้าจะมี poison mechanic ต้องออกแบบ server status/tick/stack/expiry ก่อน |

Human/Elf/Orc/Dwarf appearance รุ่นใหม่มี R15 15 core parts; Wizard ใช้ Human appearance แต่ label R15 ของ pack ยังไม่พิสูจน์ fit ทุก scale, clothing, attachment, grip หรือ timing ของเกม

## ขั้นต่อไปที่ทำให้ตรวจรับได้

1. ตรวจต้นฉบับและเงื่อนไขรายชิ้น แล้วเก็บ asset version/dependency IDs และ hash จริง
2. เปิด asset ในพื้นที่ตรวจแยก ตรวจ descendants, scripts, require, HTTP, remotes และ package dependencies ก่อนรับเข้าเกม; free/popular/moderated ไม่ใช่หลักฐานปลอดภัยตาม [Roblox third-party vulnerability guidance](https://create.roblox.com/docs/scripting/security/third-party-vulnerabilities)
3. คัด geometry/emitter/clip ที่จำเป็น ตรวจ [dependency access](https://create.roblox.com/docs/projects/assets/privacy); ไม่ใส่ runtime ID จนมี import จริง
4. ต่อเข้าระบบ presentation/generator เดิม แล้วตรวจ scale, rig, motion/contact, marker timing และ cleanup
5. Studio test และวัดบนเครื่องจริงเป็นคนละขั้น; human art/UAT acceptance ยังค้างอยู่

ยังไม่ได้ทำขั้น intake/import ข้างต้น งานนี้เป็นการค้นคว้าเท่านั้น: ไม่มี acquire/download, script execution จาก asset, asset/animation upload, Roblox publish, spending, DataStore write, source runtime edit หรือการทดสอบมือถือ

## หลักฐานและไฟล์

- [JSON รายการและสถานะ](C:/Work/MySelf/Guildborne/production/research/CREATOR_STORE_FREE_EXTRAS_2026-10-12.json): Store 17 รายการ + external packs 4; unknown counts และ runtime/version/hash เป็น null
- อ่าน metadata สดครบตามรายการ ไม่รับรอง content ภายในหรือสินทรัพย์รายชิ้น
- ไม่คัด Healing Potion ที่อ้าง reupload, Healing Animations ที่ยังไม่รู้ชนิด clip, plugin ที่ต้องใช้ generation credits หรือ texture-fetch plugin ที่ยังไม่ตรวจที่มา/เครือข่าย
- หลักเกณฑ์สิทธิ์ Store ใช้ [Creator Store Terms](https://en.help.roblox.com/hc/en-us/articles/21308223046932-Creator-Store-Terms); “รับฟรี” ไม่อนุมานสิทธิ์แจกไฟล์นอกแพลตฟอร์ม
- เอกสารและ JSON ต้องผ่าน independent research review; ไม่ใช่ evidence packet ที่ผ่าน Studio/device/release acceptance

