# ของฟรีที่ช่วยงาน Modular Character System ของ Guildborne

ตรวจ **14 ตุลาคม 2026 (Asia/Bangkok)** · **RESEARCH / ADAPTATION PLAN**

อ่านแชต [09-Implement modular character system](codex://threads/01a12605-bc35-7000-9fa7-db8dff09d70e) และตรวจซอร์ส/รายงานที่อยู่ใน workspace อีกครั้ง ใช้แชตเป็นบริบท ไม่ใช้คำว่า done ในแชตแทนหลักฐานปัจจุบัน ไม่ได้ส่งข้อความหรือเปลี่ยนงานในแชตนั้น

## ข้อสรุปและช่องว่างจริง

ของที่ช่วยตรงที่สุดคือ **official R15 rig + body cage + clothing cage + caged garment reference + fitting tools**  
ของเสริมสำหรับงานศิลป์คือ MPFB, ผม/เครา CC0 และ free Standard ของ Quaternius โดยต้องดัดแปลง skeleton/geometry/fitting

- มี body Standard/Heavy เดิมและหลักฐาน local MeshPart articulation แล้ว จึงไม่เรียกว่าข้อต่อยังไม่ทำทั้งหมด
- renderer ปกติยังใช้ Parts substitutes; imported templates/asset IDs ยัง null ส่วน EditableMesh ที่ขยับได้เป็น isolated preview
- cages ยัง unavailable, เสื้อ/tunic/trousers/robe ยังไม่ผ่าน layered deformation และ Heavy fit
- beard/ears/tusks กับอีก11presets ยังไม่ใช่ generated/accepted assets จากการมี catalog13presets
- walk/run/attack/cast บนร่างจริงและ spawned NPC dialogue/work/streaming ยังเป็นงานรับรองแยก

[Character asset status](../../docs/CHARACTER_ASSET_STATUS.md), [Clothing compatibility](../../docs/CLOTHING_COMPATIBILITY.md), [Studio record](../../docs/CHARACTER_STUDIO_TEST.md) เป็นหลักฐานเดิมที่ตรวจอ่าน ไม่ใช่ tests ใหม่ที่รันใน research นี้

## แหล่งฟรีที่คัดตามงาน

รายการต่อไปนี้เป็น **11 research options** ซึ่งรวมเครื่องมือ/กลุ่มไฟล์ ไม่ใช่11โมเดลที่นำเข้าแล้ว

| ทางเลือก | ขอบเขตฟรี/สิทธิ์ | ใช้ช่วยอะไร | งานแปลงและข้อจำกัด |
|---|---|---|---|
| [Roblox R15 rig, body cages and clothing cages](https://create.roblox.com/docs/avatar/resources) | downloadable official reference; ไม่ยืนยัน CC0 | ใช้ cage topology/UV และ skeleton reference กับ Human Standard/Heavy และ tunic/trousers เดิม | ปรับ cage ตามแต่ละหุ่น; inspect licence/archive; preserve vertices/UV correspondence. |
| [Roblox body templates and Goblin reference](https://create.roblox.com/docs/avatar/character-bodies/project-files) | downloadable official reference; ไม่ยืนยัน CC0 | ศึกษา head/body/rig/cage และสร้างหน้าตา Guildborne; Goblin เป็น reference ไม่ใช่ accepted Orc | cleanup, original silhouette, neutral tint and 15 meshes; no automatic Heavy/Dwarf fit. |
| [Roblox caged clothing examples](https://create.roblox.com/docs/avatar/layered-accessories/project-files) | downloadable official reference; ไม่ยืนยัน CC0 | เทียบโครง garment/cage แล้วสร้าง tunic/trousers ของเกมให้เป็น layered จริง | Archive contents unknown; no verified fantasy tunic/trousers or universal fit. |
| [Avatar Setup — Development Avatar](https://create.roblox.com/docs/avatar-setup) | built-in Studio ฟรี | ทดลองบนสำเนา body+garments โดยเลือก workflow ให้ชัด | Input requirements apply; preserve compatible R15 rig or tool may replace it. Do not assume existing candidate qualifies. No Save/upload/publish in research. |
| [Accessory Fitting Tool](https://create.roblox.com/docs/avatar/accessory-fitting-tool) | built-in Studio ฟรี | ทดสอบ Standard/Heavy แบบcustom ทั้งใส่แยกและซ้อน tunic/trousers; rigid hair/hat offsets | Classic/Normal/Slender selector does not affect layered accessories; not Heavy/Orc/Dwarf fit proof. |
| [MPFB2](https://github.com/makehumancommunity/mpfb2) | เครื่องมือฟรี · GPLv3 code / CC0 core graphics | ทางเลือกสร้างฐาน Human ที่ปรับสัดส่วน แล้วเก็บเป็น preset geometry; ไม่เพิ่ม runtime full-body sliders | Specific documented compatibility is not local full-pipeline proof. Retopology, R15 split/rig/cages and art adaptation required. Addon dependencies/execution/telemetry unreviewed. |
| [MakeHuman Hair01](https://static.makehumancommunity.org/assets/assetpacks/hair01.html) | CC0 · 18 รายการใน catalog | คัดทรงผมเป็น donor/reference แล้วลด geometry/ปรับรูปทรงและสีให้เข้ากับเกม | Attach to existing HAIR IDs; per-head/preset fit; do not assume Roblox-ready. |
| [MakeHuman Bodyparts05](https://static.makehumancommunity.org/assets/assetpacks/bodyparts05.html) | CC0 · 5 รายการใน catalog | คัดเครา/หนวดให้Human/Dwarf เป็นชิ้นแยกและ tint แยก | rigid/skinned attachment choice, facial clipping and provenance review; no Dwarf fit confirmed. |
| [Universal Base Characters — Standard only](https://quaternius.com/packs/universalbasecharacters.html) | Standard ฟรีเท่านั้น · CC0; จำนวนฟรีไม่ทราบ | ศึกษา proportions/topology หรือคัด donor ที่อยู่ในfree tier | Paid Source blend/shaders excluded. Humanoid rig is not Roblox R15/15-part/cage compatibility. |
| [Modular Character Outfits — Fantasy Standard only](https://quaternius.com/packs/modularcharacteroutfitsfantasy.html) | Standard ฟรีเท่านั้น · CC0; จำนวนฟรีไม่ทราบ | คัดชิ้นเสื้อ/ชุดที่freeจริง เปลี่ยน silhouette/material แล้ว weight/rig/cage บนหุ่น Guildborne | No62parts/all12outfits free claim. Paid Source blend excluded. Not a ready Roblox layered garment. |
| [Universal Animation Library — Standard only](https://quaternius.itch.io/universal-animation-library) | Standard ฟรีเท่านั้น · CC0; จำนวนฟรีไม่ทราบ | คัดเฉพาะคลิปfree เพื่อศึกษา walk/idle/work poses และ retarget | Do not claim120+free or each advertised clip inStandard. R15 mapping, grip/foot contact, game timing and animation ownership remain work. |

## เลือก official files ให้ตรง workflow

[Avatar Resources](https://create.roblox.com/docs/avatar/resources) มี Standard R15 Rig and Attachments, Cages for Bodies, Cages for Clothing และ Combined Project Files; formats ที่หน้าเว็บเสนอคือ .blend/.ma/.fbx  
กลุ่ม rig/cage เป็นไฟล์สำหรับสร้างงานใน DCC ยังต้องเตรียม export ไม่ใช่ของที่โยนเข้า Studio ได้ทันที

[Body project files](https://create.roblox.com/docs/avatar/character-bodies/project-files) มี Round/Square/Muzzle แบบ Male/Female และ GoblinCharacter.zip; ใช้เป็น starting/reference แล้วแก้หน้าตา/สัดส่วนของเกม ไม่ตั้งชื่อ Goblin เป็น Orc ของ Guildborneหรือถือว่า fit Dwarf แล้ว

[Layered accessory references](https://create.roblox.com/docs/avatar/layered-accessories/project-files) แยก Tshirt-model.fbx ที่ **ยัง uncaged** ออกจาก Additional-FBX-assets.zip ที่ระบุ caged examples; ไม่มีหลักฐาน archive มี tunic/trousers แฟนตาซีสำเร็จรูปตาม IDs ของเรา

Roblox ระบุให้ใช้ไฟล์เหล่านี้เป็นตัวอย่าง/boilerplate/reference แต่รอบนี้ไม่ตรวจ licence/readme ใน archive จึงไม่ติดป้าย CC0/MIT หรือรับรองสิทธิ์แจก raw source

## Avatar Setup และ AFT ช่วยได้แค่ไหน

[Avatar Setup](https://create.roblox.com/docs/avatar-setup) มี Development Avatar สำหรับ NPC/starter characters แยกจาก Platform Avatar; preview animations/garments, attachment edits และ Cage Brush ช่วยเตรียมและตรวจงาน  
ไฟล์ Auto-Setup references กับ traditional templates เป็นคนละ workflow อย่าสลับใช้โดยถือว่าตรงกัน

[Input specifications](https://create.roblox.com/docs/avatar-setup/auto-setup-requirements) มีเงื่อนไข rig/head/pose/mesh; ถ้า rig ไม่เข้ามาตรฐานอาจสร้าง rig ใหม่ จึงต้องตรวจสำเนาโมเดล ไม่อนุมานว่า Human candidate ปัจจุบันผ่าน input แล้ว  
คำอธิบายภาพรวมบางส่วนกล่าวให้ bundle body ส่วน detailed layered-input table อนุญาต standalone แบบ best effort ข้อเสนอคือ bundle actual body+garment เพื่อจัด fitting ชัดเจน

[AFT](https://create.roblox.com/docs/avatar/accessory-fitting-tool) ใช้ custom bodies/custom animations/multiple layers ตรวจและแก้ fit บางส่วนได้ ตัวเลือก Classic/Normal/Slender **ไม่เปลี่ยน layered accessory fit** จึงไม่พิสูจน์ Standard/Heavy/Orc/Dwarf ผ่านโดยสลับ selector

ขั้นตอนอาจต่อไปถึง inventory upload/Marketplace ซึ่งอยู่นอกขอบเขตนี้ ไม่ใช้ Save/upload/publish จากคำขอ research และไม่มีการใช้เครื่องมือ Avatar Setup/AFT จริงรอบนี้

## แพ็กเสริม free-only ที่ต้องอ่าน tier ให้ถูก

Quaternius:
- Base Characters Standard122MB: โฆษณาทั้งkit6base+20hair เฉลี่ย13ktris; exact free inventory ยัง null
- Fantasy Outfits Standard280MB: body text12outfits/62parts/3texture variations ส่วนheader74models; เป็น whole-kit metadata ไม่ใช่จำนวนฟรี
- UAL Standard15MB: whole-library120+animations และ root/no-root motion; ไม่ยืนยันว่าทุกคลิปโฆษณาอยู่ในStandard
- หน้า body/outfits ระบุ60–70%free พร้อมOBJ/FBX/glTF; ไม่คำนวณปัดเศษเป็นfree count ไฟล์ .blend/shaders และ Pro/Source ที่มีราคา **ตัดออก**
- generic Humanoid/retargetable ไม่ใช่ R15/15meshes/WrapLayer/WrapTarget ที่ผ่านของเกม

MPFB:
- [Free FAQ](https://static.makehumancommunity.org/mpfb/faq/is_it_really_free.html) ระบุไม่มีpremium/paywall
- [License](https://github.com/makehumancommunity/mpfb2/blob/master/LICENSE.md) แยกGPLv3 programจากCC0 bundled graphics; [output FAQ](https://static.makehumancommunity.org/mpfb/faq/can_i_sell_models.html) ย้ำthird-party licences
- [2.0.18 release](https://static.makehumancommunity.org/mpfb/releases/release_2018.html) วันที่2026-10-10มีHair Editor fix สำหรับBlender4.2–5.2 นี่เป็นหลักฐานเฉพาะfeature ไม่ใช่ผ่านpipelineบนเครื่องนี้
- Hair01/Bodyparts05 เป็นcatalogCC0ที่คัดไว้ ไม่เหมารวมทุกแพ็กใน [catalog](https://static.makehumancommunity.org/assets/assetpacks/index.html) ซึ่งมีCC-BYด้วย
- ไม่รับ Suits02 ทั้งชุดแม้metadataCC0 เพราะมีทั้งgenericกับรายการชื่อfan/IP ยังไม่ตรวจprovenanceรายชิ้น
- ต้องretopology/ปรับศิลป์/แยก15parts/rig/cage เก็บbodypresetเป็น authored geometry ไม่เพิ่มruntimebody sliderโดยอัตโนมัติ

## จับคู่กับ source ที่ค้าง

| ช่องว่าง | source | ของที่ช่วย |
|---|---|---|
| production mesh binding | [AppearanceAssetRegistry.luau](/C:/Work/MySelf/Guildborne/src/server/Services/CharacterAppearance/AppearanceAssetRegistry.luau:8) · PLANNED_IDS_AND_TEMPLATES_NULL | Roblox R15 rig, body cages and clothing cages; Roblox body templates and Goblin reference |
| layered cages | [blender_modular_human.py](/C:/Work/MySelf/Guildborne/tools/blender_modular_human.py:139) · CAGES_UNAVAILABLE | Roblox R15 rig, body cages and clothing cages; Roblox caged clothing examples; Avatar Setup — Development Avatar |
| Standard/Heavy garment fit | [LocalGeometryRig.luau](/C:/Work/MySelf/Guildborne/src/shared/Presentation/ModularAppearance/LocalGeometryRig.luau:75) · FLEXIBLE_GARMENTS_EXCLUDED_FROM_ARTICULATED_PREVIEW | Accessory Fitting Tool; Roblox caged clothing examples; Modular Character Outfits — Fantasy Standard only |
| race/preset art coverage | [Renderer.luau](/C:/Work/MySelf/Guildborne/src/shared/Presentation/ModularAppearance/Renderer.luau:17) · STANDARD_HEAVY_PLACEHOLDER_ONLY_BEARD_RACE_FEATURES_REJECTED | MPFB2; MakeHuman Hair01; MakeHuman Bodyparts05; Roblox body templates and Goblin reference |
| gameplay animation | [LocalGeometryRig.luau](/C:/Work/MySelf/Guildborne/src/shared/Presentation/ModularAppearance/LocalGeometryRig.luau:37) · LOCAL_CALIBRATION_RECEIPTS_EXIST_GAMEPLAY_UNACCEPTED | Roblox R15 rig, body cages and clothing cages; Universal Animation Library — Standard only |
| shared NPC integration | [HeroRig.luau](/C:/Work/MySelf/Guildborne/src/server/Services/HeroRig.luau:2) · EXISTING_R6_CARRIER_WORLD_INTEGRATION_PENDING | Roblox R15 rig, body cages and clothing cages; Accessory Fitting Tool; Universal Animation Library — Standard only |

รักษา appearance save/ownership/revisions/fit/slots ผ่านระบบเดิม แยก cosmeticจากWEAPON entitlement และlegacy ancestry สถิติการต่อสู้  
NPCต้องเก็บ tags/IDs/worktools/prompt/dialogue/quests/routines และcleanup; HeroRig R6 carrierและcivic skeletonยังต้องadapter ไม่ใส่NPC AI scriptsทั่วไปมาแทน

## ลำดับที่คุ้มที่สุด

1. เลือก official rig/cage/reference แล้วตรวจarchive/สิทธิ์/hash โดยไม่ทับต้นฉบับ
2. ทำ body cage ให้ Human Standard และ Heavy เดิม พร้อม15visible parts และskin tintที่แยกเสื้อ/ตา/ฟัน
3. ทำ CLO_TUNIC_TRAVELER_01 และ CLO_TROUSERS_TRAVELER_01 เป็น layered garments จริง พร้อมweights/inner–outer cages
4. ทดสอบแต่ละชิ้นและใส่ซ้อนบนทั้งสองหุ่น เดิน/วิ่ง/นั่ง/ย่อ/โจมตี/ร่าย สวม–ถอด/cleanup และ modesty; ใช้ [cage/weight workflow](https://create.roblox.com/docs/art/accessories/rig-and-cage-existing-models) โดยไม่ลบvertices/เปลี่ยนreferenceUV
5. รับเฉพาะสิ่งที่ผ่านเข้าระบบเดิม แล้วตรวจPlayer/Hero/save/respawn/rejoin
6. ต่อspawned NPCทั้งสองโครงพร้อมงาน/บทพูด/streaming จากนั้นขยายElf/Orc/Dwarfและpresetsที่เหลือ

GUIรอบก่อนช่วยหน้าแต่งตัว/portrait/selection แต่ไม่แก้cages; Template Testerช่วยclassic texture preview ไม่แก้flexible garment fit  
animation/VFX/food/book/clutterก่อนหน้าช่วยโลกและpresentation ต่อได้หลังbody+clothesroute ผ่าน ไม่ใช่แทนจุดตรวจนี้

## สถานะหลักฐาน

SourceHEAD 4cc9a8232e0fd9ae7bf517983c274e800e8ad4a4; checkoutมีงานตัวละครเดิมที่ยังไม่commitและถูกเก็บไว้  
รันForge doctor/validate/plan, reconciliation, character-contract, Studio router validate/verifyแล้วผ่านตามขอบเขตmetadata/generated-files  
reconciliation502assets/73screens/89kit/402hashed/0missing; character contract89planned/15parts ไม่ได้สร้างmeshหรือรับรองfit

ไม่ได้download/install/import/upload/publish/executeaddon/avatarfittingtools หรือแก้runtime/registry/productionassets ยังไม่มีfreshStudio/game/device/humanartacceptance  
JSONคู่รายงานมีnullableIDs/freecounts, license/tier และreviewstatus  
ผู้รับต่อ: character/riggingartistสำหรับcages/garments, engineerสำหรับacceptedPlayer/Hero/NPCadapter, QAสำหรับfit/runtime/device evidence

Independent document review โดย asset_fit: **PASS** — จำนวนและ source gaps ตรงกัน แยก free tiers/rights/preview จาก runtime acceptance ถูกต้อง ไม่มี correction
Local catalog consistency check: **PASS** — JSON, unique keys, source paths, nullable free counts/runtime IDs และ no-acquisition flags

