# Creator Store: ของฟรีที่เหมาะกับ Guildborne

วันที่ตรวจ: **12 ตุลาคม 2026 — Asia/Bangkok**

ขอบเขต: deep research แบบ **ฟรีเท่านั้น** ตามคำขอผู้ใช้ ไม่ใช่งานนำเข้าเกม
สถานะ: **RESEARCH / REVIEW CANDIDATE**; ยังไม่ผ่าน asset intake, Studio, device หรือ human art approval

## ข้อเสนอหลัก

เริ่มจาก **Synty Nature → Cave & Castle Interiors → Basement & Goblin Camp** ซึ่งหน้า Store ปัจจุบันแสดง Get Model, ผู้เผยแพร่ @Roblox และข้อความว่าอนุญาตใช้ในเกม Roblox ชุดเหล่านี้มีรูปแบบศิลป์ร่วมกัน จึงเหมาะเป็นชุดฐานให้ป่า เหมือง ซากโบราณ และเกาะกิลด์ โดยคัดเฉพาะชิ้นที่เพิ่มคุณภาพจากของเดิม

Weapons & Props และ Skeletons & Bones เหมาะเป็นลำดับถัดไป: มีอาวุธ/ศัตรูเดิมแล้ว จึงควรใช้เพิ่มรายละเอียดหรือเป็น visual replacement เฉพาะที่ผ่านตรวจ ไม่ยกระบบ combat/AI/reward จาก Store มาทับเกม

ข้อเสนอเรื่อง fit และลำดับความสำคัญเป็นการวิเคราะห์จาก source; ข้อมูล contents/ราคา/จำนวน geometry เป็นข้อเท็จจริงจากหน้า Store ไม่ใช่ผล benchmark

## วิธีตรวจและข้อจำกัด

- อ่าน README, production contracts, research ledger, plan, ล่าสุด docs/uat01/WORK_CHECKLIST.md และ source ที่เกี่ยวข้อง รวมถึง character work ที่ยังไม่ commit
- สำรวจ Store พร้อมตัวกรอง Free; ตรวจ **13 หน้า asset สด** ผ่าน browser ทั้ง Description และ Technical Details โดยเห็น **Get Model** ไม่มี Buy For ในรายการที่เลือก
- ราคาในรายงานหมายถึงการรับ asset จากหน้า Store ณ วันที่ตรวจ ไม่ใช่การรับรองว่าไม่มี dependency เสียเงินซ่อนอยู่: ยังไม่ได้อ่าน descendants/code ภายใน
- ตรวจลิงก์เอกสาร Roblox โดย web tools; บางหน้า Store ส่ง HTML ว่างให้ web reader จึงใช้ browser ตรวจ metadata แทน
- Studio MCP discovery คืน `studios: []`; ไม่ได้ดาวน์โหลด กด Get Model, insert, Play, upload, publish หรือเปิด commerce
- เลข Creator Store เป็น **candidate ID** เท่านั้น; runtime ID ในทะเบียนเกมยังไม่ถูกกำหนด
- HEAD ที่อ่าน: `4cc9a8232e0fd9ae7bf517983c274e800e8ad4a4`; checkout มีงาน character/UI/server ที่ยังไม่ commit อยู่ก่อนแล้ว จึงไม่อ้างว่างานวิจัยนี้ทดสอบ clean commit
- ผู้ช่วยอ่าน source และตรวจ policy แยกกันแล้ว; metadata หน้า Store ของ shortlist ตรวจโดย coordinator ไม่ใช่การรับรองอิสระว่าเนื้อหาโมเดลปลอดภัย

## รายการฟรีที่ตรวจหน้า Store สดแล้ว

จำนวน triangles/MeshParts ด้านล่างเป็น **ทั้ง asset ที่แจก** ไม่ใช่ต่อชิ้น ไม่ใช่จำนวนที่จะใช้ใน Guildborne และไม่ใช่ FPS estimate

`ไม่แสดง` ในคอลัมน์ Scripts หมายถึงหน้า Technical Details ไม่แสดง Script Count ไม่ได้พิสูจน์ว่าศูนย์สคริปต์

| ลำดับ | ชุด / ผู้เผยแพร่ / candidate ID | Triangles / MeshParts / Scripts | ใช้หรือประยุกต์กับ Guildborne | เงื่อนไข |
|---|---|---|---|---|
| 1 | [Synty Nature Pack](https://create.roblox.com/store/asset/6933438443) — @Roblox — 6933438443 | 108,816 / 200 / ไม่แสดง | ต้นไม้ พุ่ม ดอกไม้ ท่อนไม้ หินและ outdoor props; เพิ่มความหลากหลาย Greenwood/เกาะกิลด์ | คัดชนิดและ variants; ปรับพาเลต; ไม่บังเส้นทางหรือ prompt |
| 2 | [Synty Dungeon Pack: Cave & Castle Interiors](https://create.roblox.com/store/asset/6934021345) — @Roblox — 6934021345 | 162,088 / 271 / ไม่แสดง | โมดูลถ้ำ/ภายในปราสาท หิน rune สะพาน อุโมงค์; เหมือง ห้องบอส และซากโบราณ | ใช้เป็นเปลือกภาพบนเส้นทางเดิม; ประตู/มุมเลี้ยวต้องรองรับผู้เล่นพร้อม 5 heroes |
| 3 | [Synty Dungeon Pack: Basement & Goblin Camp](https://create.roblox.com/store/asset/6933905899) — @Roblox — 6933905899 | 102,885 / 179 / ไม่แสดง | ค่าย goblin, basement/sewer modules, mine tracks และพืชใต้ดิน; แยกพื้นที่ด้วยเรื่องราว/สิ่งแวดล้อม | ชื่อ pack ไม่ได้แปลว่ามี goblin rig/AI พร้อมใช้; ไม่เท่ากับ cosmetic ORC |
| 4 | [Synty Dungeon Pack: Weapons & Props](https://create.roblox.com/store/asset/6933790012) — @Roblox — 6933790012 | 141,121 / 234 / ไม่แสดง | เพิ่มอาวุธและพร็อพที่ใช้รูปแบบเดียวกับ dungeon; ทดลองเฉพาะรายการที่ดีกว่า visual เดิม | อะแดปเตอร์ grip/pivot; preview และอาวุธที่สวมต้องตรงกัน; ไม่รับ Tool damage scripts |
| 5 | [Synty Dungeon Pack: Skeletons & Bones](https://create.roblox.com/store/asset/6934081776) — @Roblox — 6934081776 | 72,801 / 50 / ไม่แสดง | bones/props ใช้เล่าเรื่องห้องใต้ดินหรือซากโบราณ; skeleton เป็นเพียง candidate visual | ยังไม่พิสูจน์ rig/animation; animated enemy ต้องตรวจและ retarget |
| 6 | [Arched Stone Bridge](https://create.roblox.com/store/asset/466438261) — @EndorsedModel — 466438261 | 708 / ไม่แสดง / ไม่แสดง | สะพานเมือง คลอง หรือทางเดินป่า; ชิ้นเล็กเหมาะเป็นการทดลอง integration | ตรวจ slope, collision, scale และ companion route; ชื่อบัญชี EndorsedModel ไม่ใช่หลักฐานความปลอดภัย |
| 7 | [Medieval prop pack](https://create.roblox.com/store/asset/14798688821) — Sanguophage — 14798688821 | 57,733 / 102 / ไม่แสดง | candidate detail library สำหรับตลาด/โรงเตี๊ยม/forge/Hall | หน้าไม่มี description ที่อธิบาย contents/provenance; ต้องเลือกจากโมเดลจริงก่อนสรุปว่ามีชิ้นใด |
| 8 | [Play Smoke Puff](https://create.roblox.com/store/asset/13595063828) — Roblox Code Samples; credited @DevelopmentDeadline — 13595063828 | 36 / ไม่แสดง / 1 | ตัวอย่าง particle burst ตามตำแหน่งและขนาด Part; ประยุกต์ portal arrival, despawn หรือ forge puff | อ่าน script ก่อน; ผูก event ผ่าน existing presentation; geometry ต่ำไม่ได้แปลว่า particle GPU cost ต่ำ |
| 9 | [Particle Emitter Pack - fire, smoke, sparkles](https://create.roblox.com/store/asset/241587286) — @Wonuf — 241587286 | 36 / ไม่แสดง / ไม่แสดง | ตัวอย่าง configuration ของ emitter; ผู้สร้างระบุใช้ Roblox default textures; ปรับคบเพลิง ควัน และ heal sparkle | texture ไฟ/ควัน/sparkles มีใน VFXConfig แล้ว; ใช้ศึกษา settings หากไม่ได้เพิ่มคุณภาพจากของเดิม |
| 10 | [Forest Pack](https://create.roblox.com/store/asset/6432306802) — @Roblox — 6432306802 | 153,252 / 83 / 13 | PBR nature, leaf cards และ animated wildlife; เลือกพืชหรือผีเสื้อเพิ่มชีวิตเฉพาะจุด | รูปแบบสมจริงอาจไม่เข้ากับ Synty; transparency/double-sided leaves และ scripts ต้องตรวจ |
| 11 | [Medieval Low Poly Kit](https://create.roblox.com/store/asset/15239103896) — @Scotti925 — 15239103896 | 140,927 / 163 / ไม่แสดง | ผู้สร้างระบุป่า หิน บ้านธรรมดา คน ฯลฯ; เป็นทางเลือกเมื่อชิ้นใน Synty ไม่ตอบโจทย์ | provenance/rig ของคนไม่ชัด; ไม่ใช้แทนระบบ modular R15 โดยตรง |
| 12 | [House Props Pack - Duvall Drive](https://create.roblox.com/store/asset/10840642581) — @Roblox — 10840642581 | 243,941 / 514 / 1 | เลือกจาน ถ้วย ขวด หนังสือ เชิงเทียน ผ้าและ mannequin สำหรับ tavern/library/workshop | มีของยุคใหม่ปน; รูปแบบสมจริงและ dependency audio ต้องคัด; mannequin ไม่รับรอง fit ของ body ทุก preset |
| 13 | [Landscaping Pack - Duvall Drive](https://create.roblox.com/store/asset/10840661513) — @Roblox — 10840661513 | 912,716 / 1,803 / 4 | ivy, flowers, stonework, statues, garden details; candidate สำหรับสวนเมือง/กิลด์เฉพาะชิ้น | ไม่เริ่มจากทั้ง pack; geometry รวมสูงสุดใน shortlist; 2 Audio และ texture permissions ยังไม่ตรวจ |

ข้อมูลเวลาอัปเดตและ vertices เก็บใน [JSON catalogue](CREATOR_STORE_FREE_2026-10-12.json) เพื่อส่งต่อ asset curator; update date ไม่ใช่ asset-version ID ที่ pin แล้ว

## แผนประยุกต์ที่ตรงกับ source

| งาน | Source เดิมที่ใช้ต่อ | วิธีปรับปรุง |
|---|---|---|
| ป่าและเกาะ | src/server/Services/AdventurePropKit.luau, AdventureMapKit.luau, IslandScenery.luau | นำ Nature มาเป็น visual variants; คง floor/ramp/interaction เดิม; decor ไม่ collide/touch/query; นับ descendants ต่อฉากและคง scenery budget 300 parts |
| เหมือง/ซากโบราณ | IronveilMineArt.luau, AshenCourtArt.luau และ AdventurePropKit | ใช้ cave wall/ruins/runic dressing รอบเส้นทางและ encounter เดิม ไม่เพิ่ม full map หรือเดินชน geometry ใหม่โดยไม่ตรวจ |
| เมือง/โรงเตี๊ยม | CivicDistrictKit → CivicServiceKit → CivicCityWorld; CityInteriorKit | เปลี่ยนเฉพาะ detail ที่ช่วยอ่านสถานที่/หน้าที่ NPC; คงประตู prompt และชื่อ EN/TH; original interiors และอาคารบริการมีอยู่แล้ว |
| Gathering | src/server/Services/RegionalWorld.luau | ปรับภาพ TimberLogs/RockA/IronOreNode; คง ResourceNodeId, server GatherResource, cooldown และ reward |
| อาวุธ | WeaponVisuals.luau, HeroRig.luau, shared/Data/ItemVisuals.luau | prototype หนึ่งอาวุธก่อน; HeroRig ต้องการ Grip หรือ Shaft เป็น BasePart direct child; nested Handle ต้อง adapter; ตรวจ contact และ thumbnail |
| เฟอร์นิเจอร์ | shared/Presentation/FurnitureKit.luau, server/Services/FurnitureWorld.luau | ใช้ shell mesh ภายใน canonical kind เดิม; CollisionProxy/footprint/storage/theme rights ยังใช้ระบบเดิม |
| VFX | shared/Config/VFXConfig.luau, PathVFX.luau; SkillEffects/PathSkillEffects/PortalEffects | นำ smoke/settings ที่ตรวจแล้วมาประยุกต์กับ event เดิม; budget Desktop48/Touch30 เป็นนโยบายเดิม ไม่ใช่ตัวเลข benchmark ใหม่; คง telegraph และ cleanup |
| Audio ที่ยังขาด binding | shared/Config/AudioConfig.luau, MusicConfig.luau; AudioController/MusicController | มี local original WAV drafts แต่ AssetIds ทั้งสองว่าง; เป็น priority ต่อไปสำหรับ free audio library หรือ original audio intake ไม่ดึง audio player framework เข้ามา |

**แก้ต้นทางให้ reproducible:** AdventurePropKit, AdventureMapKit, CityInteriorKit, furniture และ weapons/previews เป็น generated libraries ดู tools/build_adventure_kit.py, build_region_maps.py, build_city_interiors.py, build_furniture_kit.py, build_weapon_kit.py, build_item_visuals.py ก่อนแก้ generated output งาน integration ควรออกแบบ adapter/mapping ให้สร้างซ้ำได้

**รักษาอัตลักษณ์:** wood/stone/roof/gold/leaf/magic ใช้พาเลตใน src/shared/Config/Art.luau; ชิ้นมี texture อาจเปลี่ยนสีด้วย Color อย่างเดียวไม่ได้ ต้องตรวจสิทธิ์และวิธีปรับจริง โลโก้/crest/landmarks/hero silhouettes ยังคงเป็น original identity

## สิ่งที่ยังไม่แนะนำให้รับทั้งระบบ

- Full RPG, inventory/quest/shop/crafting frameworks: เกมมี authority/persistence และ UI bindings อยู่แล้ว ไม่มีหลักฐานว่าการแทนระบบช่วยแก้ gap ปัจจุบัน
- NPC AI, working weapon หรือ monster scripts: ใช้ศึกษา/คัด visual ได้ แต่ไม่ยก damage, loot หรือ reward logic มารัน
- R6 animation packs หรือ generic R15 bodies/clothes: companion carrier เดิมและ appearance R15 ใหม่ใช้คนละ contract; ต้องตรวจ joints, grips, cages และ fit ของ Human Standard/Heavy รวมถึงเผ่าอื่น
- Whole maps/large PBR mega packs: ฟรีแต่เพิ่ม memory, draw calls, collision และความไม่สม่ำเสมอของ art; ไม่รับจากคำว่า low poly หรือ ratings อย่างเดียว
- Competitor rips, reuploads ที่ไม่ทราบต้นทาง หรือแพ็กที่คำอธิบายมีแต่ keyword spam: การกดรับฟรีไม่พิสูจน์ว่าเจ้าของมีสิทธิ์แจก

ไม่มีรายการเสียเงินใน catalogue นี้; Synty pack อื่น ๆ นอกห้าหน้าข้างต้นไม่ได้ถูกถือว่าฟรีโดยอัตโนมัติ

## สิทธิ์ ความปลอดภัย และ performance ก่อนนำเข้า

1. **บันทึกแหล่งที่มา:** listing/creator/candidate ID/วันรับ/license notice/update date และภายหลัง actual version ID/hash; อย่าเอา raw pack ไปขายต่อหรือแจกนอก Roblox โดยอนุมานจากคำว่าฟรี สิทธิ์ใช้ Creator Store ผูกกับ Roblox services ดู [Creator Store Terms](https://en.help.roblox.com/hc/en-us/articles/21308223046932-Creator-Store-Terms)
2. **ตรวจโมเดลใน isolated unpublished intake:** enumerate Script/LocalScript/ModuleScript, external require, dynamic loads, network, remotes และ obfuscation ก่อน Play; moderation/ratings ไม่รับรองปลอดภัย [Roblox security guidance](https://create.roblox.com/docs/scripting/security/third-party-vulnerabilities)
3. **ตรวจ dependencies:** mesh/image/audio/animation แต่ละ ID กับสิทธิ์ของ universe จริง; Open Use และ Restricted ใช้กฎต่างกัน การเห็น metadata หรือ Get Model ไม่ยืนยัน runtime loading [Asset privacy](https://create.roblox.com/docs/projects/assets/privacy)
4. **รับเฉพาะ presentation ที่อนุมัติ:** scenery ไม่จำเป็นต้องใช้ code; script ตัวอย่างต้องอ่านและปรับให้ทำงานผ่าน Guildborne hooks; sandbox/capabilities เป็นการควบคุมเสริม ยังต้องตรวจ beta และ config ไม่สมมติว่า ordinary Store imports ถูก sandbox โดยอัตโนมัติ [Script capabilities](https://create.roblox.com/docs/scripting/capabilities)
5. **ควบคุม updates:** ข้อเสนอของรายงานคือเก็บ reviewed version และไม่ auto-update third-party package โดยไม่ทบทวน เพราะ AutoUpdate รับเวอร์ชันใหม่เมื่อเปิด place ใน Studio [Packages](https://create.roblox.com/docs/projects/assets/packages)
6. **วัดฉากจริง:** count parts/mesh/texture pixels/materials/lights/transparency/emitter rates; reuse IDs; ใช้ collision proxies ตามหน้าที่; เปรียบเทียบฉากเดิมกับฉากใหม่พร้อม 5 heroes, resource prompts และ skill telegraphs [Improve performance](https://create.roblox.com/docs/performance-optimization/improve)
7. **ทดสอบ streaming และอุปกรณ์:** แบ่ง asset เป็นชิ้นที่เหมาะกับการโหลด; ไม่ทำทั้ง pack Persistent เพื่อซ่อนปัญหา; physical mobile ยังต้องวัดจริง [Instance streaming](https://create.roblox.com/docs/workspace/streaming), [Test on hardware](https://create.roblox.com/docs/performance-optimization/test-on-hardware)

## ขั้นต่อไปที่เสนอ — ยังไม่ได้ดำเนินการ

รอบ 1: คัด Nature 8–12 ชิ้น, cave/ruins 6–8 ชิ้น และ bridge 1 ชิ้นใน intake; จำนวนเป็นขอบเขตทดลอง ไม่ใช่ asset ที่ import แล้ว

รอบ 2: ทำ Greenwood กับทางเข้าเหมืองเป็นฉากเปรียบเทียบเดียว; ปรับพาเลต/scale/pivot; ตรวจผู้เล่นและ 5 companions ผ่านประตู/สะพาน/turns ได้ ไม่บัง boss telegraph หรือ gather prompt

รอบ 3: เพิ่ม weapon visual 1 ชิ้นและ smoke presentation 1 cue เมื่อฉากแรกผ่าน; ผูก inventory preview/equipped view ให้ตรงกัน ตรวจ spawn/despawn/rebuild และ Low quality

รอบ 4: ขยาย city/เฟอร์นิเจอร์หลังเลือก art direction; free audio เป็น research/intake แยก ใช้ keyword sword swing, shield block, bow release, forest ambience, tavern ambience, forge และ cave wind ไม่มี audio ID ที่ผ่านตรวจในรายงานนี้

**สถานะต่อ candidate:** listing verified = YES; downloaded/internal code/dependencies/actual version/imported/Studio/device/human approval = PENDING ทุกตัว ไม่มี RuntimeAssetId ใหม่

## Checks ที่ทำจริงในงานวิจัยนี้

Forge doctor/validate/plan, reconciliation, character-contract, Studio v3 validate/verify รันสำเร็จที่ระดับ tool/contracts; reconcile พบ 502 assets, 73 screens, 89 kit assets และ missing references 0 ตัวเลขนี้ไม่เท่ากับ assets imported/approved

Python launcher ของเครื่องพิมพ์คำเตือน location แต่ commands เสร็จ; ใช้ bundled Python ต่อสำหรับ ledger เล่มปัจจุบัน `build/agentic/character-slice-v3-ledger.sqlite3` ไม่ reset ledger เก่าที่ fingerprint ไม่ตรง

ไม่รัน baseline game regressions สำหรับการเพิ่มรายงานอย่างเดียว และไม่อ้าง test counts เก่าเป็น fresh pass ไม่มี evidence packet/Forge acceptance ที่ใช้ผล web research แทน runtime checks

## การส่งต่อ

ผู้รับถัดไป: **asset-curator + world-builder**, ต่อด้วย VFX/rigging/performance ตาม asset ที่เลือก ต้อง claim งาน intake/integration และ exclusive Studio ownership ก่อนเขียนหรือ import

รายงานนี้ไม่เปลี่ยน source/runtime flags/registries; independent source/policy review ช่วยตรวจข้อสรุป แต่ยังไม่ใช่โมเดลผ่านตรวจภายในหรือ human art acceptance
