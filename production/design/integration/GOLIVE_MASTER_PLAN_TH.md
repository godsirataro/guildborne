# Guildborne — Master Plan ถึง Go-live

> เป้าหมายการเปิด Lv35 ใน GL-1.0 ถูกแทนที่ตามคำขอล่าสุดด้วย [GL-2.0 ตัวเต็ม Lv100/สงคราม/ตลาด](FULL_GAME_GOLIVE_GL2_TH.md) เอกสารนี้เก็บไว้เป็นประวัติ ไม่ใช้เลื่อนระบบตัวเต็มไปหลังเปิดโดยอัตโนมัติ

Version: **GL-1.0 / 15 ตุลาคม 2026 / READY FOR OWNER PLAN REVIEW**

Plan sign-off: **PENDING** · Build release sign-off: **PENDING** · Public ready: **false**

## 1. สิ่งที่จะอนุมัติ

แผนนี้รวมขอบเขต Public เดิมกับข้อเสนอ Complete Expansion & Competitive Development Plan ทั้ง20กลุ่ม เพื่อส่งมอบเกม Lv1–35 ที่เล่น Solo และร่วมมือกับเพื่อนได้ พร้อมภาพ/เสียง/UI ที่ใช้งานจริง เว็บไซต์ และการดูแลหลังเปิด

คำขอปัจจุบันคือจัดทำแผนเพื่อพิจารณา ไม่ถือว่าผู้ใช้ sign off แล้ว เมื่ออนุมัติ GL-1.0 ให้ใช้ตารางขอบเขตและ gate ในเอกสารนี้เป็นแผนดำเนินงาน โดยไม่รีเซ็ตสถานะหลักฐานหรือแทนที่สัญญาข้อมูลเดิม ก่อนอนุมัติ ข้อเสนอเพิ่มในเอกสารนี้ยังเป็น PROPOSED

ต้นฉบับที่แนบตรงกับ `production/design/source-proposal.txt` แบบ byte-for-byte: SHA256 `2d7bb243a155b0f70e31692d9007c3b97617ee3c11a3686cb25a2f53445f8ad2` เก็บตัวอย่างจากต้นฉบับเป็นข้อเสนอ ไม่รับรองคำอ้าง platform/ตลาดหรือ source status จากต้นฉบับโดยอัตโนมัติ

Positioning: **Lead Your Heroes. Build Your Guild. Fight Together.** เป็นข้อความเสนอสำหรับ branding; ต้อง review ก่อน public copy

Core loop: เตรียมทีม/อุปกรณ์/กลยุทธ์ → สำรวจ/สู้/สั่งฮีโร่ → รับผลตอบแทน/พัฒนา → กลับ Hall/คราฟต์/ปรับทีม → ทดลองความท้าทายถัดไป เป้าหมาย session10–20นาทีและ FTUE0–30นาทีเป็นสมมติฐานที่ต้องวัด ไม่ใช่สถิติหรือบังคับเลเวล

## 2. ขอบเขตเปิดเกมที่รักษาไว้

- Public Lv1–35; Class1 ที่10, Class2 ที่35 พร้อม prerequisites จริง; สอง main arcs/12 campaign steps และ Novice journey 6 ขั้นก่อนหน้า; Hall สูงสุด4ใน candidate launch
- Player + NPC heroes สูงสุด5ต่อเจ้าของ; ฮีโร่ใหม่ใน Novice ruleset เริ่ม10หลัง Class1/Hall; ทดสอบครบ5 base classes และ10 Class2 paths สำหรับ player/hero ตามการใช้งานที่รองรับ
- Personal Guild = เจ้าของมนุษย์หนึ่งคน + NPC/Hall/เกาะ; Human Party = กลุ่มมนุษย์ชั่วคราว1–6คน; Federation เป็นงานหลังเปิด
- Solo/Party/ทีม NPC อยู่ใน supported shared PvE ได้โดยเก็บ personal quest/class gates; แบ่ง EXP/loot ตาม owner participation และงบ encounter ที่อนุมัติ
- Personal island, build/move/store/restore, plots/themes/materials/สิทธิ์และ visits; gathering, inventory, player/hero equipment, crafting และ Gold economy
- Human/Elf/Orc/Dwarf รวม13 presets สำหรับ Public,20 palettes ตาม catalog, modular15 R15 parts พร้อมเสื้อผ้า/ผม/ส่วนประกอบที่รองรับจริง; Beta8เป็นช่วงตรวจ ไม่ใช้ลด Public13
- Native Roblox TH/EN, UI สถานะครบ, mobile/accessibility, animation/VFX/audio และ city/NPC/monster/boss coverage ที่จำเป็นต่อเนื้อหาวันเปิด
- Free daily7-step UTC ไม่รีเซ็ตเมื่อลืมวัน; Premium shop และ Battle Pass ต้องมี catalog/entitlement/receipt/season lifecycle ที่ผ่านเกณฑ์ก่อนเปิดขาย
- Legacy saves/earned XP/classes/receipts/ancestry ต้องยังอ่านได้; appearance ไม่เปลี่ยน combat entitlement; Hall1 cap20,+5ถึง Hall17 cap100,18–20ไม่เพิ่ม cap สูตรนี้ไม่ถูกเปลี่ยนโดยแผน

ข้อเสนอให้ sign off เรื่องเกาะ: รักษา owner-online visits พร้อมค้นหาผ่านเพื่อน/ชื่อ/รหัส/public ตามสิทธิ์ และ discovery/routing ข้าม server เมื่อเจ้าของอยู่อีก instance; เจ้าของ offline แสดง unavailable และมี safe return ไม่เพิ่ม offline island simulation หรือ co-building ในรุ่นแรก G0 ต้องปิดรายละเอียด routing/capacity/privacy และ paid plot ที่ต้องผ่าน quest + entitlement + materials ให้ครบ หากจะลดเป็น same-server only ต้องเป็น scope change ที่เจ้าของอนุมัติแยก การทดสอบหลาย clients ใน Studio ไม่ผ่าน cloud/cross-server gate

## 3. สถานะจริง ณ วันที่จัดทำ

นี่คือการอ่านซอร์สและรายงานที่มีอยู่ ไม่ใช่การรัน Studio/device ใหม่ในงานวางแผนนี้

| ส่วน | หลักฐานที่มี | งานที่ยังเหลือ |
|---|---|---|
| Main route | รายงาน candidate เก่ามี Warrior/Hall/สอง arcs/Class2 แบบ local | full current-build route ทุก class/hero, cloud/rejoin, TH/EN และ human UAT |
| Hero tactics | `HeroTactics.luau` มี Balanced/Defensive, Focus/Hold/Regroup/Retreat และ role offsets | normal-player usability, persistent presets หากจะเพิ่ม, full population/device |
| Party6 | lifecycle/UI และรายงาน real local clientsถึง6สมาชิก | ทุกคนทำ normal route, travel/ready/return/reconnect และ shared encounters พร้อม heroes |
| Shared PvE | identity/participation/settlement/claims/coordinator มี source; e804 มีสองเจ้าของ Solo ได้2XP/3Goldรวมจาก isolated encounter | native travel/Party convoy, mixed populations, repeat/failure/cloud durability และ6คนพร้อม30heroes |
| e804 evidence limit | automation-assisted route, explicit fixture entry, Memory; earned heroXPและ committed profile revision เปลี่ยน | ไม่ใช่ natural shared travel, human UAT หรือ logout/cloud recovery |
| Native shared travel | รายงาน2ec894มี earned single-owner native entry/return/reward/repeat/fall recovery;8deffมี reviewed respawn fixและ synthetic scheduling | actual Player LoadCharacter rerunยังค้าง; ไม่ใช่Party convoyหรือlatest-build blanket acceptance |
| Analytics | bounded local event contract/tracker มี; external flagปิด | cohort/reporting/production delivery verification หลังสิทธิ์พร้อม |
| Combo/FTUE/Guild utility | มี design contracts | actual integrated prototype + tests + human feedback |
| Art/assets | Human Standard/Heavy source/exports และ local inspections บางส่วน | all13 imports, cages/fit, actual audio/animation, final art/device |
| Daily/season | local preview | final SKU/price/entitlement/season migration/receipts |
| Website | brief/schema/design proposals | actual website MVP, approved copy/assets/links/host |

อย่าใช้เว็บ brief14ต.ค.ที่บอก Party6ยังไม่มี implementation เป็นสถานะล่าสุด; อย่าใช้ test counts ในรายงานเก่าเป็น current acceptance การมี55 Forge task definitionsไม่เท่ากับงาน55ชิ้นเสร็จ

## 4. จัดข้อเสนอทั้ง20กลุ่มเข้าขอบเขต

L = ข้อกำหนด launch เดิม / N = ข้อเสนอเพิ่มขั้นต่ำก่อน Public รอ sign-offนี้ / X = หลังเปิด / P = งาน production

| กลุ่มจากต้นฉบับ | ขอบเขตก่อน Public | ส่วนที่เก็บหลังเปิด | ชั้น / เจ้าของหลัก |
|---|---|---|---|
| 01 FTUE | contextual hints, borrowed ally lesson, ผู้เล่นลองสั่งทีมและรู้เป้าหมาย Class/Hall; ไม่ให้ permanent heroก่อน gate | เพิ่ม personalizationจากข้อมูลจริง | L+N / gameplay + UI |
| 02 Advanced Hero AI | Balanced/Defensive + Focus/Hold/Regroup/Retreat, role formation, manual override, reason feedback; ใช้ combat authorityเดิม | advanced skill-priority editor, saved per-hero tactical presets | N / combat |
| 03 Team Combo | หนึ่ง sequence Knight→Mage→Archer จาก resolved actions; visible timing/cancel/once-only result และ human fun review | ขยาย2–3และ full catalogเมื่อผลดี | N / combat + animation/VFX/audio |
| 04 Combat Feel/Boss | wind-up/contact/recovery, hit confirmation, dodge/telegraphs, role-useful bossesและ accessibility | encounter variantsเพิ่ม | L / combat + art |
| 05 Identity/Bond | owned instance identity, class/mentor/dialogueถูกต้อง | personality/preferences/Bond levels/personal quests/synergy; เริ่มหนึ่งเรื่อง optional | L(identity)+X / narrative |
| 06 Living Guild | Hall/quarters/warehouse/blacksmithเดิม + safe Training Ground และ Strategy Tableเปิด team/skill preparation | persisted loadout library, Trophy Hall, Research Roomและกิจวัตรเพิ่ม | L+N / guild + world |
| 07 Quests/Exploration | สองarcsครบ, varied objectives, journal/hints/fail/retry/return; class/hero trials | arcs/secret/world/hero storiesเพิ่ม | L / quest |
| 08 Human Party6 | invite→accept→ready→travel→play→leave/rejoin, ownership isolation | social conveniencesที่ไม่จำเป็นเพิ่ม | L / guild + UI |
| 09 Shared PvE/Rewards | shared authority, owner eligibility, fixed pool, loot fairness, pending grants/recovery | shared event variants | L / systems + combat |
| 10 Economy/Crafting | sources/sinks/costs/loot/solo-shared pacing, bag/equipment integrity, free main route | marketเปิดเมื่อผ่าน gateแยก | L / economy |
| 11 Mobile/Accessibility | touch/command controls, TH/ENไม่ล้น, low-quality telegraph, reduced motion, tested input paths | advanced remapping/optionsตาม feedback | L / UI + localization |
| 12 Save/Security/Performance | old/new/bad saves, session fencing, exploit/fault/replay, budgetsและจริงหลายอุปกรณ์ | scaleตามจำนวนผู้เล่นที่วัด | L / technical + QA |
| 13 Analytics/Balance | validated milestone/economy/session events, reportsที่ระบุ cohort/build/missing data, failuresไม่บล็อก gameplay | retention experiments/segmentationตามฐานข้อมูลจริง | N / growth + systems |
| 14 Guild Research | ไม่เป็น launch blocker | Military/Crafting/Exploration nodes, respec, costs ไม่ข้าม gates | X / gameplay |
| 15 Dynamic Events | ไม่เป็น launch blocker | Raid/Caravan/Boss/Surge/Defense/Ruins; reuse quest/reward authority | X / quest |
| 16 Replayability/Endgame | แสดงเป้าหมายเมื่อจบสองarcsและกิจกรรมเดิมที่ทำซ้ำได้; ไม่มี hard stopหลอกผู้เล่น | challenge encounters/mastery/achievements/team trials/season variants; tower/Class3ภายหลัง | L(clarity)+X / gameplay |
| 17 Social/Cosmetic | Public13, fit/equipment, island visits/privacy/returnตาม contractเดิม | showcase/trophies/preset libraries/Federation | L+X / character + guild |
| 18 Daily/Season/Shop | launch daily/paid entitlements/season retentionครบ, prices/capsอนุมัติ | cadence/events/reward catalogเพิ่ม | L / economy + release |
| 19 Website/Discovery | MVP Home/Features/Roadmap/Devlog/FAQ, real footage/brandและ official approved links | World/Classes/Gallery/Community expansion, CMS/loginหากจำเป็น | N / release + UI |
| 20 AI Production | reuse Studio v3/Forge, ownership/review/evidence/lessons, ทดลองเครื่องมือที่ช่วยงานจริง | automationขยายเมื่อวัดผลได้ | P / producer + technical |

การเปลี่ยนจากเดิมที่ต้องให้เจ้าของเห็น: comboหนึ่งชุด, tactical usability, borrowed command FTUE, Training Ground/Strategy Tableขั้นต่ำ และ website MVP ถูกเสนอเป็น pre-Public acceptance ใน GL-1.0; full Bond/Research/Eventsยังไม่เพิ่มเข้า launch ไม่เพิ่ม permanent saved tactic/formation schemaโดยนัย

Combo contract: Fireballเดิมไม่ใช่ AoE และ Piercing Shotยังไม่มี weak-point mechanic; ไม่เพิ่มโบนัส damage/statusแบบเดาสูตร ทดลอง resolved-action interactionก่อน หากต้องใช้โบนัสเพื่อให้สนุกให้ review balance table/window/cooldown/immune/cancel/reward interactionก่อน implement Canonical Rowanยังเป็น Warrior ไม่เปลี่ยนเป็น Knightตามตัวอย่างต้นฉบับ

## 5. Roadmap และ dependency จนเปิด

| Gate | Deliverable | เริ่มได้เมื่อ | Exit evidence / ผู้รับรอง |
|---|---|---|---|
| G0 Plan & baseline | ลงมติ GL-1.0, reconcile visit/commerce/content contracts, snapshotงานล่าสุด, exact module ownership, approved launch matrix | ตอนนี้ | producerตรวจครบ20 themes; technical/QAรับ baseline; ownerรับ scope |
| G1 Playable identity slice | 5-hero tactics + borrowed lesson + comboหนึ่งชุด + training/preparation + one encounterครบภาพเสียง | G0, stable authoritative actions | normal Solo input, failure cleanup, humanทดลองแล้วสั่งทีมเข้าใจ; design/QA/art review |
| G2 Multiplayer integration | Party6/native travel/shared encounter/participation/settlement/recovery/return | G0; ทำขนานG1 | 2/4/6 clients + eligible solo outsiders; conserved budgets; receipt/fault tests; systems/QA |
| G3 Complete launch route | Novice→Class1→Hall→heroes→12steps→Class2/mentor, gather/craft/build/visits/rewards TH/EN | G1และเส้นทางG2พร้อมใช้ | fresh/returning full journeysทุก class/pathที่รองรับ, no grants/time skips, save/rejoin; gameplay/QA |
| G4 Asset & presentation complete | golden set→Beta8→Public13, all launch action/outfit/equipment/VFX/audio/NPC/world/UI coverage | golden setเริ่มคู่G1; ขยายเมื่อfitผ่าน | ownership/load/import, deformation/fit matrix, audiovisual/contact/cancel review, device costs; art/audio/QA |
| G5 Launch services & staging | final commerce/daily/season, schema migration, platform setup, telemetry, support/rollback runbook | contractsG0; integrateกับG2/G3 | namespaces/permissionsจริง, uncertain receipt/retry/rejoin, season boundary, no data loss; technical/economy/QA |
| G6 Closed Beta qualification | รวมG1–G5ใน candidateเดียว; fresh TH/EN players, true cloud, actual Android/iOS, mixed load | G1–G5ผ่าน relevant Beta scope; Beta8ได้แต่บันทึกPublic13ค้าง | issue ledger, cohort/latency/perf measurements, no critical blockers, normal routes; independent QA/human |
| G7 RC freeze | Public13ครบ,แก้ Beta blockers, website/store/trailer real copy, final release matrix/rollback rehearsal | G6 + all Public scopeรวมG4ครบ | exact commit/tree/assets/configและ current tests, owner art/UAT, release lead go/no-go |
| G8 Go-live | ownerอนุมัติ exact release target/build/products; execute staged checklist/verify | G7ผ่านและ scoped release approval | public ordinary-account join/save/reward/purchase checks, incident ownerพร้อม |
| G9 Stabilization | 72h close coverage, day1–7 daily review, day14 retrospective | G8 | no unresolved corrupt/duplicate/purchase-loss incidents; growth/retentionจากข้อมูลจริงก่อนลงทุนขยาย |

Critical path ที่ต้องติดตาม: G0→G2/G3→G5→G6→G7→G8 ขณะเดียวกัน G1/G4เป็นเส้นทางที่ทำให้ผ่านด้านความสนุกและ asset; เมื่อ import/fit/deviceติด จะกลายเป็น critical pathได้ทันที ห้ามถือ artworkเป็นงานเก็บท้าย

Websiteเริ่ม structure/copyหลังG0, ใช้ footageจริงหลังG1/G4, content freezeที่G7 ไม่ขัดจังหวะ engineerที่กำลังแก้ settlement หาก websiteยังไม่พร้อมให้ ownerตัดสิน waiverหรือเลื่อน ไม่เงียบตัด requirementที่เพิ่ง sign off

## 6. Timeline ที่นำไปบริหารได้

**ไม่มีวัน Go-live ที่ยืนยันใน GL-1.0** วันที่15ต.ค.เป็นวันที่จัดแผน ไม่ใช่ T0อัตโนมัติ T0คือวัน owner sign-offและยืนยันผู้รับผิดชอบ/เวลาทำงานจริงครบ

ใช้รอบวางงาน5วันทำการ เป็น cadenceเสนอ ไม่ใช่สัญญาว่าหนึ่งgateใช้5วัน:

| รอบ | งานที่ดึงเข้า | จุดตัดสิน |
|---|---|---|
| รอบแรกหลังT0 | G0, ปิด native shared entry/return gap, golden asset set, combo/FTUE design lock, ordinary-input evidence | ประเมินงานย่อยจากเวลาที่ใช้จริง + dependency/tool blockers |
| รอบต่อไป | G1/G2/G4ทำขนาน, G3เดินเส้นทางเต็มต่อเนื่อง, G5catalog/receipt/environment preparation | ส่ง playable incrementทุกจบรอบ; re-estimateตาม throughput |
| เมื่อ integrationพร้อม | G6 Beta; เก็บ D1เมื่อครบวันและ D7เมื่อครบ7วันจาก cohortจริง | ถ้าจะใช้ D7ประกอบ decision ต้องรอเวลา observationจริง; agentทำแทนไม่ได้ |
| หลัง Beta fixes/Public13 | G7 RC freezeและ targeted requalification | กำหนดวันเปิดจากผล gates, availabilityของ owner/supportและ platform approval |
| หลังเปิดจริง | G9ช่วง0–72h, day1–7, day14 | เปิด expansionเมื่อ stabilityผ่าน |

Producerต้องกรอกต่อ work package: remaining tasks, effort range, owner availability, external waiting time, earliest startและforecast finish หลังรอบแรก คำนวณวันรวมจาก dependencyและresourceจริง ไม่บวกเวลางานขนานทั้งหมด ไม่ใส่ estimateที่ไม่เคยประเมินเป็น commitmentบนเว็บ

หาก ownerต้องการวันเปิดตายตัว ให้เลือกเปลี่ยน scopeหรือ resourceอย่างชัดเจน; ห้ามลด data-integrity/security/device gates เพื่อรักษาวัน

## 7. Workstreams และ handoff

| Stream / accountable role | รับผิดชอบ | จุดต่อเดิม/ผลส่งมอบ |
|---|---|---|
| A Gameplay / game-design-lead | FTUE/tactics/combo/boss/route/balance | Novice* / HeroService / CombatService / existing skills, content contractsและ ordinary route recordings |
| B Multiplayer/data / technical-director | Party/travel/encounters/claims/save/commerce interfaces | HumanPartyRuntime, TravelService, SharedEncounterRuntime, SharedCombatCoordinator/Rewards, PlayerDataService; fault matrix |
| C Art/presentation / art-lead | models/rig/clothes/animation/UI/VFX/world | existing asset directories/appearance registry/action timeline; per-preset fitและruntime evidence |
| D Audio / audio-lead | impact/UI/world cue ownership/mix/IDs | AudioConfigและruntime hooks, listening/cancel/concurrency review |
| E QA/release / qa-lead | tests/cloud/device/UAT/security/rollback | candidate matrix + evidence/issue ledger; reviewerแยกจากผู้เขียน |
| F Product/web/liveops / producer + release-lead | website/copy/analytics/cohorts/support/catalog decisions | existing design manifest/AnalyticsAdapter, web directoryต้องassignก่อนเขียน, release checklist |

บทบาทไม่ใช่จำนวนคนที่มีพร้อมจริง; 33role definitionsไม่ใช่33คนทำงาน ใช้จำนวนconcurrent workersที่ hostรองรับและหนึ่งshared ledger ทุกงานclaim actual write scopesก่อนแก้; Studio/Blenderมีเจ้าของ sessionหนึ่งรายและส่งมอบชัดเจน UI/Localization/Bootstrap/Protocol/PlayerDataServiceเป็น shared integration points ต้องserialize

55 Forge tasksปัจจุบัน reuseตาม module: hero-tactics-slice, analytics-foundation, human-party-*, shared-pve-*, shared-combat-*, shared-local-travel และ expansion-integration ห้ามสร้าง ledgerใหม่หรือ rewrite plan.jsonเพื่อให้ statusดูเขียว Pending packagesเช่น combo/FTUE/guild utility/website/commerceต้องแตก taskพร้อมactual paths/checksและdependencyก่อนลงมือ ไม่ต้องสร้างservicesซ้ำตามชื่อในเอกสาร

## 8. นำ Research มาใช้จริง

| Track | สิ่งที่จะทดลองและส่งมอบ | Stop/fallback |
|---|---|---|
| Character/rig | ใช้ existing Blender source/scriptsเป็น baseline; เลือกfree helperหนึ่งตัวที่แก้fit/rig/export pain; golden Human Standard/Heavy + outfit/weapon | ถ้า license/import/cageไม่ผ่านกลับpipelineเดิม; ไม่ลด13presets |
| World/assets | เลือกmodelจากcatalogที่เข้ากับstyle/scale/license; ตรวจpayload/scriptsก่อนใช้; ลองหนึ่งsceneกับ5followers | ไม่แทนที่combatจากfree-model scripts; geometryไม่มีprovenanceไม่ผ่าน |
| Animation/VFX/audio | เลือกauthoring/pluginที่สร้างผล runtimeใช้งานได้; bind actual action/contact/cancel; owned/free audioที่สิทธิ์ถูกต้อง | offline video toolsไม่ใช่runtime animation; missing audio IDไม่ถือเสร็จ |
| Code/navigation | evaluate Codebase Memory/Graftเมื่อมีโจทย์ค้นหาที่rgทำได้ไม่ดี; pin/reviewnetwork/hooks/credential routes | เปรียบเทียบเวลางาน+ความผิดพลาด; ถ้าไม่ช่วยไม่เพิ่มdependency |
| Marketing | เลือกreviewed motion/video toolเฉพาะตัดคลิปเกมจริง | ห้ามสร้างfake gameplay; OpenDesignยังต้อง resolveตัวที่แน่นอน |

ทุก adoption ต้องมี source/version/license/security/free-costตรวจจริง → isolated sample → quality/time comparison → accept/rejectและfallback → production bind → relevant tests เลือกเองในขอบเขตที่เคยอนุญาตได้ ไม่ต้องถามความชอบทุกplugin แต่ไม่ติดตั้งทุกตัว และไม่รันnetwork scriptที่ยังไม่review

งาน adoptionมีผลลัพธ์เป็นไฟล์/scene/animation/measurementที่ใช้กับเกม ไม่ใช่research reportเพิ่มอย่างเดียว เครื่องมือที่ใช้ไม่ได้บล็อกเฉพาะ dependent work การเสียเงิน/upload/publishยังต้องสิทธิ์เฉพาะตามAGENTS

## 9. Acceptance matrix ก่อน RC

| ด้าน | ขั้นต่ำที่จะตรวจ | Release blocker |
|---|---|---|
| Gameplay | fresh/returning,5classes/10Class2pathsของactorที่รองรับ, mentor/Borin/12steps/Hall4, free routeถึง35 | dead end, skipgate, grantผิด, ต้องจ่าย/market/สุ่มheroถึงเล่นต่อได้ |
| Tactics/combo | 5heroes, manual override, blocked/out-of-range/dead/respawn/travel/cancel/replay; mobilecommands | wrong-owner action, doubleproc, stale targetgeneration, unreadable warnings |
| Party/shared | 2/4/6humans, up to30heroes, solooutsider, heal/tank/latejoin/AFK/dead/disconnected/fullbag | lost/duplicate payout, last-hit-only exclusion, leaderลบสิทธิ์ที่earnedแล้ว |
| Value/recovery | pool sum/remainders/indivisible loot, personal quest rewardsแยก, partial recipient save, unknown result, shutdown/retry | conservation errorใดๆหรือ unresolved delivery |
| Island | owner/visitor/private/friends/public, ownerleave/privacychange, move/store/restore/theme/rights, discovery/returnตามcontract | ผู้เยี่ยมbuild/withdrawได้โดยไม่อนุญาต, ownershipหาย, stranded travel |
| Persistence | old/new/corrupt saves, migrations, session takeover/fencing, actual authorized staging rejoin | corruption, resetting earned progress, concurrent wrong-owner writes |
| Commerce/season | approved IDs/catalog/caps, deliverybefore ack, duplicate/reordered receipt, disabledoffersแต่pendingfulfillmentยังrecover, seasonrollover | chargeแต่lostdelivery, doublegrant, oldseasonreceiptsหาย |
| Art/audio | public13/beta8matrix, movement/outfit/weaponfit/cages, actualruntimeIDs/loadpermissions, listening | brokenrequiredassets, missing cues, clippingที่รบกวนเกม, assetrightsไม่ชัด |
| Device/performance | Android/iOSจริงอย่างน้อย30นาทีต่อtestdevice; model/OS/quality/buildระบุ;2/4/6+mixedload | sustained target30FPSขั้นต่ำที่ตกลงไม่ถึง, crash/thermal degradation/memorygrowthไม่มีขอบเขต |
| UX/accessibility | TH/EN, touch/keyboardและgamepad pathsที่ประกาศรองรับ, safeareas/focus, loading/retry/refused | ทำmainrouteไม่ได้, hiddencriticalstatus, color-only warnings |
| Analytics/web | actual outcome events, bounded fields/no secrets, failureisolation, featureavailabilityและlinksถูกต้อง | telemetryทำgameplayเสีย, ข้อมูลอ่อนไหว, claims/playlinksเท็จ |

กำหนดอุปกรณ์ขั้นต่ำและpopulation capจากmeasurementก่อนรับรอง;36allied actorsเป็นstresscaseไม่ใช่capacitypromise เก็บ CPU/GPU/frame-time/memory/network/sampleduration/qualityแยก อย่าใช้ค่าเฉลี่ยFPSอย่างเดียว

Human fun gate: รอบแรกเสนออย่างน้อย6ผู้ทดสอบใหม่ แบ่งTH/ENและtouch/keyboard บันทึกจำนวนที่ทำroute/commandได้โดยไม่ช่วย จุดติดขัด และเหตุผลที่อยาก/ไม่อยากเล่นต่อ ตัวเลขนี้เป็นขั้นต่ำเสนอสำหรับusability ไม่ใช่statistical retention proof ถ้าพบblockerให้แก้และทดสอบซ้ำกับคนใหม่ การวัดD1/D7ต้องมีcohort/เวลา/denominatorจริง ไม่กำหนดตัวเลขการันตีความนิยม

ทุกfeatureเก็บแยก Design / Source / Automated / Studio / Multiplayer / Platform / Device / Human / Release เป็น PASS/FAIL/PENDING/BLOCKED/N/Aพร้อมเหตุผล N/Aไม่ใช้ข้ามgateที่เกี่ยวข้อง Evidenceต้องผูกcommit/tree/config/assetversion/candidate/inputmethodและrawlogs; screenshotsหรือจำนวนtestsอย่างเดียวไม่พอ

## 10. ความเสี่ยงและแผนรับมือ

| Risk | เจ้าของ | วิธีลด/จุดตัดสิน |
|---|---|---|
| Shared durable settlementซับซ้อน | technical | ทำfault/replayก่อนscale; fixedsnapshot/pendingclaims; blockreleaseเมื่อvalueผิด |
| Scopeเพิ่มจาก20themes | producer | lockminimumในตาราง4; fullBond/Research/Eventsไม่ลากเข้าlaunch; changecontrolทุกครั้ง |
| Art13presets/fit/importล่าช้า | art | goldenfitก่อนmultiply, parallelกับcore, trackperpresetและoutfit; ไม่ใช้catalogแทนimports |
| เครื่องมือresearchไม่ช่วยจริง | tools | boundedpilot/time-reworkmeasurement; pipelinefallback; ไม่เพิ่มresearchแบบไม่มีdeliverable |
| มือถือรับ36+actorsไม่ไหว | performance | profileต้นทาง, boundAI/VFX/updatefrequency; capacitydecisionจากข้อมูล; ห้ามลด5heroesเงียบๆ |
| Account/asset/cloud/commerce access | release | verifyowners/namespaces/permissionsก่อนBeta; เตรียมmanifestให้ownerอนุมัติactionที่จำเป็น |
| คนใหม่ไม่เข้าใจจุดขาย | gameplay | borrowedcommandlesson, reasonfeedback, observefreshusers,ปรับลำดับก่อนเพิ่มcontent |
| Website/marketingกล่าวเกินจริง | release | availability≠implementation, realfootage/buildlabels, reviewcopyก่อนdeploy |

## 11. Go-live runbook

ก่อนเปิด: release leadเตรียมcommit/tree/builddigest, approved universe/place, asset ownership/runtimeIDs, schemas/migrations/namespace, product/pass/season IDsกับprices/caps, featureflags, supporteddevices/capacity, backup/recovery/rollbackrevision, knownissues, operator/incidentcontactและlaunchwindow เจ้าของลงนามexactmanifest ไม่ใช้เพียงคำว่าtestsผ่าน

ลำดับปฏิบัติเมื่ออนุมัติแล้ว:

1. Freeze source/config/assets; ตรวจCIและaffected acceptanceบนrevisionเดียว; confirmrollbackอ่านschemasใหม่ได้
2. ทดสอบในisolated authorized stagingรวมactualsave/rejoin/receipt/recoveryและtravelที่ใช้จริง; ห้ามใช้production profileเป็นtestfixture
3. Ownerให้scoped approvalสำหรับpublish/commerceตามmanifest; operatorทำเฉพาะtargetที่ระบุ
4. เปิดตามpopulation rolloutที่platformและownerอนุมัติ; verifyordinaryaccountjoin→tutorial→combat→reward→save→rejoin และapprovedpurchaseflow
5. Monitorjoin/save/pendingdelivery/dupe/error/crash/performance; updatewebsitePlaylinkเมื่อpublictargetตรวจแล้ว
6. ถ้าP0ใดๆให้หยุดขยาย/ปิดaffectedoffersหรือentry,รักษาpendingclaims/logs,ประเมินrollbackcompatible; ห้ามล้างprofilesหรือชดเชยมูลค่าโดยเดา

P0: save corruption/lost ownership/dupe/unresolved paid delivery/security breach/normaljoinไม่ได้ในวงกว้าง — no-goหรือincidentทันที P1: normalmainroute/multiplayer/recoveryติดขัด — ต้องแก้ก่อนRC ข้อยกเว้นเฉพาะminorcosmeticต้องมีowneracceptance, impactและdue dateในknownissues

0–72hต้องมีhuman on-callที่ระบุจริง ไม่สมมติว่าagentเฝ้า24hเอง Day1–7reviewdaily; Day14postmortemและcohortreview ใช้actualincidents/feedbackเลือกpatchและexpansion ไม่มีpaidadsอัตโนมัติ

## 12. หลัง Go-live เก็บเป้าหมายครบ

เมื่อstabilityผ่าน: optionalheroBondเรื่องแรกและcosmeticrecognition → livingGuild/trophies/presets/research → boundedLv35challenges/worldevents/seasoncadenceตามcapacity → chaptersต่อไป/tower/Class3ที่70/Lv100 → Federation/war/territory → player marketเมื่อescrow/cross-servergateผ่าน ลำดับย่อยให้ตัดสินจากdependencyและfeedback ไม่สัญญาวันหรือบังคับทำทุกอย่างตามเส้นตรง

FullBond, researchและeventsอยู่ในregistryเดิมและไม่ถูกลบ Endgameห้ามเปิดClass3/tower/เพิ่มlevelcapก่อนreleaseboundaryได้รับการแก้ไข Warไม่มีpaidPvEbuff; marketไม่บล็อกfreemainrouteและไม่ใช้แก้ราคาจากผลสงคราม

## 13. แบบ Sign-off

ข้อเสนอให้รับรองทั้งชุด:

- [ ] **S1 Product scope** — รับPublicเดิมครบตามข้อ2 รวม owner-online island discovery/routing ข้าม server และmappingครบ20themesตามข้อ4
- [ ] **S2 Added launch minimum** — รับtactics/borrowedFTUE/หนึ่งcombo/TrainingGround+StrategyTableขั้นต่ำ/analytics/websiteMVPเป็นขอบเขตเพิ่ม; fullBond/Research/Eventsหลังเปิด
- [ ] **S3 Delivery method** — core/multiplayerและart/tooladoptionทำขนาน,5-working-dayplanningcadence,ประมาณวันหลังวัดthroughput; targetdatesยังTBD
- [ ] **S4 Acceptance** — รับgatesและno-goตามข้อ9–11; currentcode/evidenceไม่ใช่releaseapproval; recordvisits/commerce/devicecontractsก่อนG0ผ่าน

ข้อความอนุมัติที่ใช้ได้: **“Sign off แผน GL-1.0 ตาม S1–S4 ให้ดำเนินงานตามแผน และเก็บการอนุมัติเปิดเกมจริงไว้ที่ G8”** หากแก้บางข้อให้ระบุSและสิ่งที่เปลี่ยน แล้วออกรุ่นใหม่ก่อนถือว่าอนุมัติ

Owner/approvedAt/approvedVersion: **ยังไม่ระบุ** ห้ามagentติ๊กแทนจากการจัดทำไฟล์

Plan approvalอนุญาตdevelopmentในขอบเขตที่ตกลง ไม่ทดแทนexplicitscopedapprovalของ Roblox publishingทั้งprivate/public, paid uploads/API/Robux spending, livecommerceหรือproductionDataStorewrites ตามAGENTS.md การขอreleaseapprovalจะมาพร้อมผลที่ตรวจได้ในG7 ไม่ถามเพื่อเริ่มงานreversibleที่อนุมัติแล้ว

## 14. แหล่งข้อมูลและสถานะการตรวจ

- `production/LAUNCH_PLAN.md`, `production/LATEST_GOALS.md`: approved Public boundaryเดิม
- `production/design/EXPANSION_PLAN.md`, `features.json`, `source-proposal.txt`: mapping20themes/source intake
- `production/design/TEAM_COMBO_DESIGN.md`, `FTUE_AND_FUN_GATES.md`, `HERO_TACTICS_CONTRACT.md`, `LIVING_GUILD_DESIGN.md`, `HERO_BOND_DESIGN.md`: boundeddesigncontracts
- `production/design/integration/SHARED_REAL_PROFILE_PAYOUT.md`, `PARTY_REAL_CLIENTS.md`, `REPORT.md`: historicalcandidate-specificevidence
- `production/design/integration/SHARED_NATIVE_TRAVEL.md`: newer scoped travel/respawn evidence; supersedes older travel-progress wording only for the tested scenarios
- `production/launch/integration/PARTY6_PLAN.md`, `docs/LAUNCH_GUILD_ISLANDS.md`: sharedPvE/visitscontract
- `docs/CHARACTER_ASSET_STATUS.md`, `production/research/GUILDBORNE_UNIFIED_FREE_CATALOG_2026-10-14.md`: imports/adoptionlimits
- `src/server/Systems/HeroTactics.luau`, `src/server/Config/Runtime.luau`: actualcommandsetและdefaultdisabledflagsที่อ่านครั้งนี้

งานนี้เป็นplanning/docsเท่านั้น; ไม่เปลี่ยนruntimeflagsหรือimplementationstatusในfeature registry ไม่promotehistoricaltestsเป็นfreshStudio/deviceผล ผลlocalbaselineและindependentplanreviewบันทึกใน `GOLIVE_PLAN_REVIEW.md` ข้างไฟล์นี้
