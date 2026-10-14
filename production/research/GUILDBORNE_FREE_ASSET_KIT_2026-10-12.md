# Guildborne — คลังวัตถุดิบฟรีครบหมวดและแผนดัดแปลง

ตรวจวันที่ **12 ตุลาคม 2026** (Asia/Bangkok) · **RESEARCH / ADAPTATION PLAN**  
รายงานนี้รวมของจากสองรอบก่อนกับตัวเลือกใหม่ เพื่อเลือกวัตถุดิบและจุดต่อจริงของ Guildborne ไม่ใช่ประกาศว่ารับ asset เข้าเกมครบแล้ว

## คลังที่จัดไว้

- Creator Store **42 รายการ**: 30 รายการจากรายงานวันเดียวกัน + **12 รายการใหม่ที่ตรวจหน้าเว็บสด**
- แหล่งผู้สร้างนอก Store **18 แพ็ก CC0 ฟรี**: Quaternius 8 + Kenney 10
- Animation จาก Cinderlore **4 แพ็ก** ในรายงานก่อน ใช้ใบอนุญาตเฉพาะ Roblox ที่มีข้อจำกัด ไม่ใช่ CC0
- รวม **64 catalog records** ไม่ใช่ 64 โมเดลหรือ asset ที่ imported แล้ว และไม่รวมสอง MegaKit ที่ยังไม่ทราบเนื้อหาส่วนฟรีครบ

[JSON คลังรวมและสถานะ](C:/Work/MySelf/Guildborne/production/research/GUILDBORNE_FREE_ASSET_KIT_2026-10-12.json) · [รายงาน Store รอบแรก](C:/Work/MySelf/Guildborne/production/research/CREATOR_STORE_FREE_2026-10-12.md) · [VFX/animation/food/potion/books](C:/Work/MySelf/Guildborne/production/research/CREATOR_STORE_FREE_EXTRAS_2026-10-12.md)

ตัวเลข models/files ด้านล่างเป็นคำกล่าวบนหน้าเว็บผู้สร้าง ยังไม่ใช่การตรวจ archive จริง ไม่รวมจำนวนข้ามแพ็กเป็น “โมเดลไม่ซ้ำ” เพราะมี variants, growth stages, หลาย formats และชิ้นที่อาจซ้ำกัน

## แหล่งที่เหมาะกับการทำงานดัดแปลง

แนะนำใช้ **CC0 เป็นฐานหลักสำหรับวัตถุดิบที่ต้องแก้รูปทรงและนำเข้าของตัวเอง** ผู้สร้าง [Quaternius อนุญาตแก้และรวมโมเดล](https://quaternius.com/faq.html) และ [Kenney ระบุใช้ในงานเชิงพาณิชย์ได้โดยไม่บังคับเครดิต](https://kenney.nl/support) ส่วน [CC0](https://creativecommons.org/publicdomain/zero/1.0/) ให้สิทธิ์คัดลอก แก้ไข และเผยแพร่ตามขอบเขตที่ระบุ ไม่ให้ความเป็นเจ้าของแบบ exclusive หรือรับรอง trademark/publicity rights ของบุคคลอื่น

งานที่แก้ใหม่ ปก ตรา ชื่อ lore การจัดชุด และ implementation ของ Guildborne ต้องมีรายละเอียดของตัวเอง ที่มาของวัตถุดิบยังบันทึกไว้ ไม่ติดโลโก้ Kenney หรืออ้างว่าผู้สร้างเดิมรับรองเกม

Creator Store ใช้สิทธิ์ตาม listing และเงื่อนไขแพลตฟอร์ม การเห็น **Get Model** ยืนยันเส้นทางรับฟรีในหน้าที่ตรวจ ไม่พิสูจน์ที่มาทุก dependency ความปลอดภัย หรือสิทธิ์แจก source/ไฟล์นอก Roblox

## แพ็ก CC0 ฟรีที่เป็นฐานหลัก

### Quaternius — วัตถุดิบ 3D แฟนตาซี

| แพ็ก | จำนวนที่ผู้สร้างระบุ | สิ่งที่จะคัดมาดัดแปลง | ข้อจำกัด |
|---|---:|---|---|
| [Medieval Village Pack](https://quaternius.com/packs/medievalvillage.html) | 44 models | รูปทรงอาคาร หมู่บ้าน และพร็อพเมือง | เลือกองค์ประกอบให้เข้ากับเมืองเดิม ไม่แทน routes/service prompts |
| [Ultimate Modular Ruins](https://quaternius.com/packs/ultimatemodularruins.html) | 90 models | กำแพง เสา ซากอาคาร dungeon และพร็อพ; หน้าเว็บระบุ animated character | แอนิเมชัน/rig/collision จริงยังไม่ตรวจ |
| [Modular Weapons](https://quaternius.com/packs/medievalweapons.html) | 24 models | ดาบ มีด ธนู โล่ ค้อน | ต้องสร้าง Grip/Shaft และตรวจมือ/attachment ของเกม |
| [Ultimate RPG](https://quaternius.com/packs/ultimaterpg.html) | 106 models + PNG renders | อุปกรณ์ loot/inventory และฐานสำหรับ icon | render เดิมต้องปรับให้ตรงโมเดลที่แก้แล้ว; ไม่ยืนยัน modular armor/R15 fit |
| [Ultimate Monsters](https://quaternius.com/packs/ultimatemonsters.html) | 50 animated monsters | คัด silhouette มอนสเตอร์ ทำวัสดุและ faction ของ Guildborne | ไม่ทราบจำนวนคลิปแน่นอน; skeleton/การแปลงยังไม่ตรวจ |
| [Ultimate Animated Animals](https://quaternius.com/packs/ultimateanimatedanimals.html) | 12 animals; ผู้สร้างระบุ >12 animations ต่อสัตว์ | สัตว์ในเมือง/ป่า/คอก และตัวเลือก encounter | ไม่มีระบบขี่สัตว์หรือ passive wildlife ที่รับเข้าเกมแล้ว |
| [Ultimate Food](https://quaternius.com/packs/ultimatefood.html) | 103 models | อาหาร วัตถุดิบ ร้านขายของ และโต๊ะมื้อร่วม | คัดเฉพาะชิ้นที่เข้าบริบทแฟนตาซี; ไม่มี consume/buff mechanics จาก mesh |
| [Ultimate Crops](https://quaternius.com/packs/ultimatecrops.html) | 102 models; 5 growth stages | รูปพืชและวัตถุดิบ gathering | 102 คือ models ทั้งชุด ไม่ใช่ชนิดพืช 102 ชนิด; farming gameplay ยังเป็นงานออกแบบเพิ่ม |

หน้าแพ็กเหล่านี้ระบุ FBX/OBJ/Blend; Animals ระบุ glTF ด้วย ส่วน Monsters header ระบุ glTF แต่ body ของหน้าแสดง FBX/OBJ/Blend จึงต้องตรวจ archive จริง ไม่เหมารวมว่าทุกแพ็กมีทุก format หรือ .blend เป็นผลตรวจใน Blender แล้ว

### Kenney — เมือง, UI, input และเสียง

ทุกหน้าด้านล่างระบุ **CC0**, ของฟรี และเส้นทาง **Continue without donating** แพ็ก All-in-1 และโปรแกรมเสริมที่ขายแยกไม่จำเป็นต่อการรับแพ็กเหล่านี้

| แพ็ก | จำนวนบนหน้าเว็บ | ใช้ต่อยอด |
|---|---:|---|
| [Fantasy Town Kit](https://kenney.nl/assets/fantasy-town-kit) | 160 files | อาคาร/กำแพง/variants ทางเลือกสำหรับรายละเอียดเมือง |
| [Modular Dungeon Kit](https://kenney.nl/assets/modular-dungeon-kit) | 40 files | dungeon modules; หน้าเว็บมี animation/variation flags แต่คลิปและ rig ยังไม่ตรวจ |
| [Fantasy UI Borders](https://kenney.nl/assets/fantasy-ui-borders) | 140 files | กรอบ native ImageLabel/ImageButton; ออกแบบ slice และสีให้เข้ากับเกม |
| [UI Pack — RPG Expansion](https://kenney.nl/assets/ui-pack-rpg-expansion) | 85 files | button/panel/slider art |
| [Game Icons](https://kenney.nl/assets/game-icons) | 105 files | สัญลักษณ์ทั่วไป/control; ไม่ใช่คลังไอคอนสกิลแฟนตาซีที่ยืนยันแล้ว |
| [Input Prompts](https://kenney.nl/assets/input-prompts) | 1,500 files | keyboard/mouse/touch/generic control hints; ใช้ส่วน images |
| [RPG Audio](https://kenney.nl/assets/rpg-audio) | 50 files | foley, footsteps, weapon cue candidates |
| [UI Audio](https://kenney.nl/assets/ui-audio) | 50 files | button/switch/click cue candidates |
| [Music Jingles](https://kenney.nl/assets/music-jingles) | 85 files | เสียงดนตรีสั้นสำหรับ feedback; ไม่ใช่ 85 background scores |
| [Voiceover Pack — Fighter](https://kenney.nl/assets/voiceover-pack-fighter) | 45 files | audition เสียง vocal สำหรับต่อสู้; ภาษาและคำพูดยังไม่ระบุ |

[คู่มือ Input Prompts](https://kenney.nl/knowledge-base/game-assets-2d/using-input-prompts) ยืนยัน PNG/SVG และ bitmap ขนาด 64/128 แพ็กมีการกล่าวถึง fonts แต่โครงการไม่แจกฟอนต์ จึงคัด **image subset เท่านั้น** และไม่ใช้ glyph ของแบรนด์เป็นโลโก้ Guildborne

สำหรับ Kenney แพ็กอื่น หน้า pack ไม่เปิดเผย raw extension ทุกไฟล์ จึงไม่เดาว่าเสียงทั้งหมดเป็น WAV หรือกรอบทั้งหมดเป็น PNG การมีตัวเลข Files ไม่ยืนยันจำนวนโมเดล/คลิปไม่ซ้ำ การฟัง ภาษา duration sample rate loops และความเข้ากันได้ยังค้าง

## Creator Store ใหม่ที่ตรวจสด 12 รายการ

ทุกแถวเห็น **Get Model** และอ่าน Description/Technical Details ในวันที่ตรวจ ไม่ได้กดรับหรือเปิดไฟล์ภายใน Count ไม่แสดง = null/unknown ไม่ใช่ศูนย์

| ชิ้น / ผู้สร้าง | Triangles / Scripts ที่แสดง | ใช้เป็นวัตถุดิบ / เงื่อนไข |
|---|---|---|
| [Treasure Chest Union](https://create.roblox.com/store/asset/2496756132) — @Vyxium | 850 / unknown | หน้าเว็บบอกมี top/bottom unions แยกเปิดปิด; เหมาะศึกษาฝาหีบ ไม่ใช่ loot logic |
| [Medieval Building Pack](https://create.roblox.com/store/asset/313318251) — @EndorsedModel | 33,440 / unknown | พร็อพอาคารภายนอก; ผู้สร้างระบุเข้าอาคารไม่ได้ จึงไม่ใช้แทน tavern/forge ที่ผู้เล่นเดินเข้าได้ |
| [horse rigged and animated](https://create.roblox.com/store/asset/3381058398) — @BlckBrryJam | 4,547 / unknown; 21 MeshParts; 1 Animation object | หน้าเว็บอนุญาตใช้และขอเครดิต; กล่าวถึง 5 motions แต่ metadata มี 1 Animation object จึงต้องตรวจคลิปจริง |
| [Sword and shield](https://create.roblox.com/store/asset/5441932362) — @UviaRoblox | 3,396 / unknown; 14 MeshParts; 2 decals | ผู้สร้างระบุ free to use; เปลี่ยน crest หลังตรวจ provenance ของ decals |
| [Medieval Market Stalls](https://create.roblox.com/store/asset/16263631766) — @Scripted_Kool | 12,900 / unknown; 48 MeshParts | คัด stall/props ทีละชิ้น; คง market interaction/economy เดิม |
| [Anvil](https://create.roblox.com/store/asset/10971861418) — @Kajto_Kujo | 2,184 / unknown; 1 MeshPart | ทั่งตกแต่งสำหรับ workstation/forge; description ไม่ให้สิทธิ์แยกราย dependency |
| [Pickaxe](https://create.roblox.com/store/asset/11861768348) — @coolcapidog | 234 / 2; 2 MeshParts, 1 Audio, 1 Tool | รูปเครื่องมือ NPC คนงาน/นักขุด; ตรวจ geometry/audio/script และคง GatherResource |
| [Lever](https://create.roblox.com/store/asset/13114054675) — @adamqplaysroblox | 2,778 / 2; 1 Audio | ผู้สร้างกล่าวว่าทำเองและมี script; ใช้ shell/pose ผ่าน puzzle state เดิม |
| [Minecart](https://create.roblox.com/store/asset/73613290042723) — Wish Game / @clashnewbme | 88 / unknown; 1 MeshPart | static cargo/landmark เหมืองก่อน; ไม่ยืนยัน rail/physics controller |
| [Portcullis](https://create.roblox.com/store/asset/87891139) — @tusKOr661 | 288 / 2 | shell ประตูยก; code เก่าและ description ว่าง; ทางผ่านต้องรองรับ player + 5 heroes |
| [Monster](https://create.roblox.com/store/asset/454965215) — @Roblox / Luckymaxer | 2,916 / 3 | official visual/rig reference; ไม่ยืนยัน R15 หรือยก AI/damage เดิมมาใช้ |
| [Drooling Zombie (Rthro)](https://create.roblox.com/store/asset/3924238625) — @Roblox | 8,576 / 4; 15 MeshParts; 29 Animation objects | official NPC-kit candidate; Rthro ตาม docs ไม่ใช่หลักฐาน fit กับ carrier ของเกม |

[Roblox NPC kit](https://create.roblox.com/docs/resources/npc-kit) ระบุว่าปรับภาพได้และ skeleton/ชื่อ Motor6D มีผลต่อ animation ชุดนี้อยู่ใต้ [Limited Use License](https://create.roblox.com/docs/resources/limited-use-license) ที่ผูกกับ Roblox และต้องรักษา notices/เงื่อนไข dependencies จึงไม่รวมในหมวด CC0 หรืออ้างว่าลิขสิทธิ์ต้นฉบับกลายเป็นของ Guildborne

Store assets ที่ scripts unknown/มี scripts ต้องตรวจภายในก่อนรับ แม้ผู้เผยแพร่เป็น official หรือได้รับคะแนนสูง

## ครอบคลุมอะไร และยังขาดอะไร

| หมวด | วัตถุดิบที่คัดได้ | งานที่ยังต้องทำจริง |
|---|---|---|
| ตัวละคร player/hero | ใช้ original modular Human/Elf/Orc/Dwarf เดิม | body/clothing cages และ fit ราย preset; ยังไม่มีชุด armor ฟรีที่ตรวจผ่านครบ |
| อาวุธ/อุปกรณ์/loot | Modular Weapons, RPG, Synty Weapons/Props เดิม และ Store shell | canonical item mapping, Grip/Shaft, preview/equipped views, wearable fit |
| มอนสเตอร์/บอส | Monsters, official NPC references และ original regional/boss kits | skeleton adaptation, contact/timing, readable hit proxy, AI/reward คงเดิม |
| สัตว์/คอก/คาราวาน | Animals และ horse | passive wildlife/mount behavior ไม่เกิดจากการรับโมเดล |
| เมือง/บ้านกิลด์/ห้อง | Village/Town, stalls และ furniture/interior เดิม | route/footprint/proxy/ownership/streaming |
| ป่า/หิน/ทรัพยากร | Synty Nature เดิม, Crops, mine props | node identity, prompts, gather rewards; growth gameplay แยกออกแบบ |
| คราฟต์/alchemy | RPG props, anvil/pickaxe/cauldron, interior เดิม | workstation adapter; ไม่เพิ่ม recipe/effect จากชื่อ mesh |
| อาหาร/potion/books | Food และรายการก่อน | eat/drink/buff/poison/skill-book unlock mechanics ยังไม่รับเข้า |
| Dungeon/puzzles/loot | Ruins/Dungeon, chest/lever/gate | server marker/state/receipt/progression เดิม |
| VFX/ภาพสกิล | portal/beam/tween/particle จากรอบก่อน | ช่วงเวลา release, tint/shape/cleanup, multi-team/device budget |
| Animation | animal/monster candidates + Cinderlore 4 packs | playback permissions, skeleton fit; eat/drink/read/cast ยังไม่ยืนยัน |
| UI/icons/input | Kenney art + native symbols/layout เดิม | small-size alpha/slice/readability, TH/EN text native, touch/gamepad tests |
| SFX/vocals/jingles | RPG/UI Audio, Fighter voice, jingles + original sources | ฟัง/ตัด/mix, codec/rights/permissions, cue mapping; ไม่อนุมาน full BGM หรือเสียงภาษาไทย |
| Lore/quests/guild identity | ปก/ตรา/props ใช้วัตถุดิบข้างต้น | ชื่อ เรื่องราว สัญลักษณ์ และเหตุผลการใช้งานเขียนของ Guildborne เอง |

## วิธีทำให้เป็นภาษาภาพ Guildborne

อิง [ART_BIBLE](C:/Work/MySelf/Guildborne/production/ART_BIBLE.md): Navy/Obsidian, Brass/Gold, Ivory, Burgundy และ cyan arcane ที่ใช้พอดี รักษา silhouette/material readability และส่วนตัวละครที่ถอดเปลี่ยนได้

1. **เลือก family หลัก:** เริ่ม Quaternius เป็นฐานอุปกรณ์/เมือง/ruins หนึ่งแนว แล้วนำ Kenney UI/audio มาปรับ ส่วน Synty และ Store props คัดเฉพาะชิ้นที่เข้ากัน ไม่ผสมทุก pack ทั้งชุด
2. **แก้โครงรูป:** เปลี่ยน proportions, grip, guard, rim, bevel และรายละเอียดตามหน้าที่ ไม่ใช้เพียง recolor แล้วเรียกว่าต้นฉบับทั้งหมด
3. **ทำวัสดุเป็นชุด:** คุมไม้/เหล็ก/หิน/ผ้าและ texture density เดียวกัน ทำ variants ตามสิ่งที่ source/theme contract รองรับ
4. **ใส่รายละเอียดของเกม:** original crest, rune, signage, book cover และ wear marks ให้สื่อกิลด์/เมือง/ผู้ใช้ โดยคงที่มา/licence record
5. **ทำภาพไอคอนใหม่:** render โมเดลที่แก้แล้วในแสง/มุมเดียวกัน เพื่อให้ inventory ตรงกับ equipped appearance; live text/ราคา/จำนวนยังใช้ native UI
6. **แต่งจังหวะ motion/VFX/audio:** anticipation → action → impact → recovery; server เป็นผู้ตัดสิน hit/reward แม้ภาพหรือเสียงล่าช้า

## ชุดดัดแปลงที่เสนอให้ทำเป็นงานต่อ

เป็น **planned selection recipes** ยังไม่มีไฟล์ที่ดัดแปลง/import หรือ runtime IDs

| ชุด | วัตถุดิบ | งาน Guildborne ที่ทำเพิ่ม | จุดต่อ |
|---|---|---|---|
| **Forge & Gathering** | anvil/pickaxe/minecart, RPG props, rocks/logs เดิม | รูปเครื่องมือและโต๊ะคราฟต์ในวัสดุเดียวกัน, จุดมือ/ค้อน, เสียงตี/ขุด | ExpansionWorld + RegionalWorld + CraftItem |
| **Guild Home & Market** | Village/Town/Stalls, furniture เดิม, books/food | ตรา ผ้าป้าย เฟอร์นิเจอร์และของใช้ให้เข้ากับ guild home | FurnitureWorld/GuildHallWorld/CivicDistrictKit |
| **Alchemy & Skill Books** | potion/cauldron/open book/closed book เดิม | ปกหนังสือสูตรยา, ฉลากขวด, rune ของเกม, VFX bubbling presentation | CityInteriorKit + FriendlyNpcKit + native skill/journal views |
| **Ruins & Puzzle Rooms** | Ruins/Dungeon, lever/portcullis/chest | stone/rune family เดียวกัน, lever handles, safe gate passage, chest lid pose | TowerWorld/IronveilWorld/ArchiveHeartWorld |
| **Gear Families** | Modular Weapons/RPG | blade/guard/grip/crest และ material variants ภายใต้ item IDs ที่อนุมัติแล้ว | ItemVisuals/WeaponVisuals/HeroRig/WardrobeVisuals |
| **Enemy & Wildlife Families** | Monsters/Animals + original enemies | silhouette/material/rig adapters, ground contact, own encounter roles | AdventureCombatBridge/EnemyArticulation |
| **Native UI & Input** | Borders/RPG UI/Game Icons/Input Prompts images | art tokens, nine-slice metadata, icon scale, TH/EN/state/input mapping | AssetImage/SymbolIcon/UISymbols |
| **Audio Cue Library** | RPG/UI Audio/Fighter/Jingles + original audio sources | audition, trim, mix/layer และ map ตาม cue contracts | AudioConfig/MusicConfig/AudioController |

## จุดต่อที่ตรวจจาก source จริง

Checkout ที่มีงาน character ค้างอยู่ HEAD `4cc9a8232e0fd9ae7bf517983c274e800e8ad4a4` ไม่มีการแก้ runtime ในงานนี้

- [AdventureCombatBridge](C:/Work/MySelf/Guildborne/src/server/Services/AdventureCombatBridge.luau:35) แยก authoritative root จาก enemy art; EnemyArticulation ใช้ six-joint carriers จึงไม่รับ foreign rig แบบ drop-in
- [HeroRig](C:/Work/MySelf/Guildborne/src/server/Services/HeroRig.luau:90) ใช้ Grip/Shaft และ [WardrobeVisuals](C:/Work/MySelf/Guildborne/src/server/Services/WardrobeVisuals.luau:12) มี torso/shoulder presentation; welded armor ไม่เท่ากับ layered clothing
- [RegionalWorld](C:/Work/MySelf/Guildborne/src/server/Services/RegionalWorld.luau:44) กับ [ExpansionWorld](C:/Work/MySelf/Guildborne/src/server/Services/ExpansionWorld.luau:20) เป็นจุดเปลี่ยน resource shells; [workstation](C:/Work/MySelf/Guildborne/src/server/Services/ExpansionWorld.luau:53) ต่อกับ [server crafting](C:/Work/MySelf/Guildborne/src/server/Services/ExpansionService.luau:122)
- [FurnitureWorld](C:/Work/MySelf/Guildborne/src/server/Services/FurnitureWorld.luau:15) มี template และ collision proxy ตาม footprints; preserve grid/rotation/ownership
- [TowerWorld](C:/Work/MySelf/Guildborne/src/server/Services/TowerWorld.luau:71) แยก prompts/markers จาก puzzle state อย่าให้ imported lever script ปลด quest/แจก loot
- [AssetImage](C:/Work/MySelf/Guildborne/src/client/UI/AssetImage.luau:13) และ [SymbolIcon](C:/Work/MySelf/Guildborne/src/client/UI/SymbolIcon.luau:3) รองรับภาพและ native fallback
- [AudioConfig](C:/Work/MySelf/Guildborne/src/shared/Config/AudioConfig.luau:4) มี 22 cue contracts และ AssetIds ว่าง; [MusicConfig](C:/Work/MySelf/Guildborne/src/shared/Config/MusicConfig.luau:4) มี 7 track contracts/bindings ว่าง เป็นช่องต่อที่คุ้มตรวจรับ
- [AppearanceAssetRegistry](C:/Work/MySelf/Guildborne/src/server/Services/CharacterAppearance/AppearanceAssetRegistry.luau:8) ยังคง PLANNED/nil สำหรับ imported appearance; structural cage/15-part check ไม่ใช่ fit acceptance
- ทะเบียนที่อ่านมี 502 asset rows / 73 screens, runtime import IDs ไม่ถูกกำหนด และ uatApproved=false ในแถวที่ตรวจ **ไม่แปลว่าไม่มี native art ทำงานใน source** และไม่แทนประวัติ human acceptance ของ phase เก่า
- generators เดิม เช่น build_item_visuals.py, build_weapon_kit.py, build_adventure_enemies.py, build_furniture_kit.py และ build_city_interiors.py ต้องเปลี่ยนพร้อม adapter ภายหลัง ไม่แก้ generated output ลำพัง

เอกสาร enemy-kit/audit บางไฟล์มี pending descriptions และ test counts เก่า ขณะที่ actual source มี bridge แล้ว จึงยึด source และ status รายแถว ไม่อ้างว่า integration/live rollout ผ่านจาก README เก่า

## ลำดับที่คุ้มเริ่ม

**เสียง → ธรรมชาติ/ทรัพยากร → workstation/ห้อง → dungeon shells → gear → monster/wildlife rigs**

ควรเริ่มเป็นฉากย่อยหนึ่งเมือง/เกาะ/ห้อง dungeon พร้อมเสียงและ UI ที่ใช้จริง แล้วตรวจ player + 5 companions ในกล้องเล่นปกติ ขยาย family หลัง fit, motion, cleanup และ performance ผ่าน

Human/Elf/Orc/Dwarf modular appearance เดิมยังเป็นฐานตัวละครทุกอาชีพ; Wizard เป็น Human appearance แพ็กฟรีนี้ไม่เปลี่ยน ancestry bonuses, class gates, saves, rewards, market escrow หรือ permissions

## ตัวเลือกบางส่วนฟรีและสิ่งที่คัดออก

- [Medieval Village MegaKit](https://quaternius.com/packs/medievalvillagemegakit.html): Standard ฟรี แต่ตัวเลข 304 models คือทั้งชุดหลาย tiers ไม่ใช่ free count
- [Fantasy Props MegaKit](https://quaternius.com/packs/fantasypropsmegakit.html): Standard ฟรี แต่ 211 คือทั้งชุด; ยังไม่ยืนยันว่าทุก potion/book/tool อยู่ในส่วนฟรี
- ผู้สร้างกล่าวว่าทั้งสองมีส่วนฟรี 60–70%; exact free counts เป็น null ส่วน Pro/Source ที่เสียเงินไม่อยู่ในชุดหลัก
- Kenney All-in-1, Asset Forge/Shape และ paid creature/chest packs ไม่อยู่ในรายการฟรี
- ไม่รับ franchise/anime/competitor reuploads หรือ frameworks ต่อสู้/loot/crafting มาแทนระบบเดิม
- ไม่มี modular R15 armor, motion eat/drink/book-reading/spell-cast หรือ full ambient soundtrack ที่ผ่าน fit/playback/listening ในงานนี้

## ขั้น intake ที่ยังค้าง

รับเฉพาะชิ้นที่เลือกหลังตรวจสิทธิ์และ provenance ของไฟล์: เก็บต้นฉบับ/archive hash/version/licence; ตรวจ scripts/dependencies; วัด geometry/textures/audio จริง; ทำ adapter; แล้ว import และทดสอบ Studio/device/human ตามลำดับ

Roblox [character import](https://create.roblox.com/docs/avatar/character-bodies/import) มี preview/validation แต่ยังต้องผ่าน body specifications และ fit ของเกม เสียงต้องผ่าน [format/rights/privacy/import requirements](https://create.roblox.com/docs/audio/assets) และ quotas ของบัญชีจริง การเป็นไฟล์ฟรีไม่อนุมานว่า upload ได้ไม่จำกัดหรือทุก workflow มีค่าใช้จ่ายศูนย์

งานนี้อ่านเว็บ/source และสร้างคลังวิจัยเท่านั้น: ไม่มี Get acquisition/download, Blender/asset script execution, asset upload/import, Roblox publish, spending, DataStore write หรือ runtime change ค่ารับรอง internals/import/Studio/device/human ยังเป็น false; runtime IDs/version/hash ของ asset เป็น null

การตรวจเอกสาร/JSON และ independent research review ไม่แทน asset acceptance หรือ game regression จึงไม่มีการอ้างผล gameplay/mobile test ใหม่

