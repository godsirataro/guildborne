# Guildborne — Full Game Go-live Roadmap

**GL-2.0 · 15 ตุลาคม 2026 · แผนสำหรับตรวจรับ**

เป้าหมายตามคำขอล่าสุด: **เปิด Public ครั้งแรกเป็นตัวเต็ม Lv1–100 พร้อมทุกกลุ่มระบบ รวม Federation, สงคราม, ยึดพื้นที่ และตลาดผู้เล่น** แผนเปิด Lv35 แล้วค่อยเพิ่มระบบเหล่านี้ถูกแทนที่ในด้านเป้าหมายการส่งมอบ Lv35 เป็นเพียง milestone ภายใน/Closed Alpha ไม่ใช่ Public Go-live

คำสั่งเปลี่ยนเป้าหมายได้รับแล้ว แต่รายละเอียดจำนวนเนื้อหาและเกณฑ์ใหม่ในแผนนี้ยังรอ owner sign-off สถานะเกมยัง NOT PUBLIC READY; ไม่มีการเปลี่ยน release flags, production data หรือเปิดบริการจริงด้วยเอกสารนี้

## 1. ตัวเต็มหมายถึงอะไร

ทุกกลุ่มระบบด้านล่างต้องมี implementation ที่ใช้งานต่อเนื่องร่วมกันใน build เดียว ผ่านการทดสอบ และมีเนื้อหาที่เล่นได้จริง ไม่มีปุ่มเปล่า/placeholder หลัก/ระบบสำคัญที่ติด Coming Soon การมี catalog หรือไฟล์โมเดลไม่ถือว่าครบ

“ทุกระบบ” หมายถึงทุกกลุ่มในแผนที่แนบและขอบเขตที่ตกลง ไม่ใช่ทุกตัวอย่างไอเดียหรือเนื้อหาที่เพิ่มได้ไม่สิ้นสุด จำนวนเริ่มต้นที่เสนอจะระบุชัดและล็อกใน P0 ห้ามลดกลุ่มระบบกลับไปหลังเปิดเพียงเพื่อรักษากำหนดเวลา

| กลุ่มที่ต้องมีวันเปิด | ขอบเขตตัวเต็ม |
|---|---|
| Progression | Novice1 → Class1 ที่10 → Class2 ที่35 → Class3 ที่70 → Lv100 ทั้ง player/hero; ไม่มี Class4; quest prerequisites จริง |
| Campaign/world | Novice6ขั้น, campaign catalog6arcs/36stepsที่ต้องตรวจ mapping จากซอร์ส, main/side/secret/world/class/hero quests, ending และเส้นทางถึง100ไม่ตัน |
| Classes/builds | 5base classes,10Class2 paths,10Class3 paths และ4special pathsใน catalog; skill/status/respec/equipment/AI loadoutsครบตาม actor ที่รองรับ |
| Heroes | สูงสุด5NPCต่อเจ้าของ, recruit/tavern/rarity/roster/dispatch, per-instance progression, mentor, tactics/formations/manual override, combo, identity/personality/Bond/personal stories |
| Personal Guild | เจ้าของมนุษย์หนึ่งคนกับNPC; Hall/buildings/training/strategy/warehouse/forge/quarters/trophies/research; ไม่เปลี่ยนเป็นองค์กรหลายมนุษย์ |
| Island/living base | เกาะ, plots, themes, furniture, place/move/store/restore, ownership/material/entitlement, visits/privacy/discovery/return รวมเจ้าของออนไลน์คนละserver |
| Human Party/shared PvE | temporary1–6humans, NPCของแต่ละเจ้าของ, Solo/Partyร่วมencounter, shared travel, healing/tanking participation, conserved rewards/recovery |
| Federation | สมาพันธ์ถาวรของเจ้าของGuild/ผู้เล่น, invitations/applications, roles/leadership/delegation, leave/disband/recovery, independent participationตามสิทธิ์ |
| War/territory | สงครามที่เล่นได้จริง, roster lock, objectives/win/lose/cancel, reconnect/server-loss policy, result-once, territory ownership/benefit caps/upkeep/season reset |
| Economy/market | gathering/crafting/equipment/Gold + global player market, orders/partial fills/cancel/escrow/claims/history/reference prices, cross-server recovery/conservation |
| Endgame/live world | tower10floors, bosses, mastery/team trials/challenges, achievements/trophies, research3directions, dynamic events, seasonal replayability |
| Appearance/presentation | 4cosmetic races/13presets/20palettes, modular15R15parts, clothes/hair/beards/ears/tusks/gear, rig/animation/VFX/audioครบรายการrelease |
| Cities/nature/NPCs | เมืองเปิดใช้ทั้ง6เมืองและพื้นที่ที่เนื้อเรื่องต้องใช้, architecture/interiors/services, natural terrain/vegetation/lighting/audio, NPC routines/contact/interruption |
| UX/accessibility | native Roblox UI TH/EN, readable touch/keyboardและgamepadที่ประกาศรองรับ, loading/empty/error/retry/disabled states, reduced motion/flash |
| Rewards/commerce | daily7stepไม่เสียลำดับเมื่อขาดวัน, Premium shop/Pass/BattlePass, receipts/entitlements/season retention, approved capped PvE buffsไม่มีผลในwar |
| Operations/web | save/security/migrations, analytics/incident/recovery, official website/roadmap/devlogs/FAQ/real footage, supportและlaunch monitoring |

Market ตัวเต็มรุ่นแรกใช้ **Gold กับวัสดุที่อยู่ใน allowlist** ตามสัญญาตลาดปัจจุบัน เป็นตลาดที่ใช้งานจริงครบวงจร ไม่ใช่เพียง preview การซื้อขาย unique equipment ยังต้องแยก ownership/escrow contractก่อนเพิ่ม ไม่รวม Robux/entitlements/real-money trading/cash-out หรือเครื่องมือการเงิน

Hall1cap20,+5ต่อHallจนHall17cap100; Hall18–20ต้องมี non-level utility/visual benefits ที่กำหนดจริง ไม่แค่ปุ่มอัปเกรด Preserve old saves/earned classes/ancestry/receipts; cosmetic Orcไม่แก้โบนัสancestryเก่า Canonical Rowanยังเป็นWarrior

## 2. Phase roadmap ถึงตัวเต็ม

| Phase | งานที่ต้องส่ง | หลักฐานผ่าน / milestone |
|---|---|---|
| **P0 — Full-scope lock** | แปลงLv35releaseเป็นfullgame delivery plan, auditซอร์ส/ช่องว่าง,ล็อกcontent catalog/จำนวน,ออกแบบFederation/war/territory/marketเชื่อมกัน,กำหนดdevices/capacity/budget/owners | matrixทุกระบบมีowner/IDs/dependencies/acceptance; ไม่มีLv35-onlyเงื่อนไขค้างในแผนเปิดจริง; baselineปัจจุบันผ่าน |
| **P1 — Quality & fun benchmark** | หนึ่งย่านเมืองเสร็จจริง + Human Standard/Heavyพร้อมชุด/อาวุธ/animation/VFX/audio; five-hero tactics,FTUEและcomboแรก | เจ้าของตรวจรับภาพ/ความเป็นธรรมชาติ; ผู้เล่นใหม่เข้าใจคำสั่ง; real-device sample; ชุดนี้เป็นมาตรฐานขยาย |
| **P2 — Complete Lv1–35 Alpha** | Novice/Class1/Hall/hero/2arcs/Class2, inventory/craft/build/daily,normal routeครบทุกอาชีพ/mentor | เล่นด้วยinputปกติ,save/rejoin,TH/EN,no grants/skiptime; **internal/closed milestone ไม่เปิดPublic** |
| **P3 — Shared multiplayer foundation** | Party6,sharedPvE/travel/eligibility/immutable settlement/durable claims, mixed Solo/Party/NPC | 2/4/6humansกับheroes,outsiders,replay/fullbag/disconnect/serverfailure; conservedvalue; nativejoin/return |
| **P4 — Complete Lv35–100** | arcs3–6,Class3@70,specialpaths,tower/bosses/ending,Hallถึง20,ครบskill trees/gear/recipes/resources/questsต่อเลเวล | normalfree routeถึง100ทุกbranchที่รองรับ;ไม่มีHall/classcirculargate;oldsavecompatible;late-gamepacingผ่าน |
| **P5 — Living Guild & retention** | heroBond/personality/personalquests,training/strategy presets,trophies,Research,achievements/mastery,worldevents,challenge loops | ทุกระบบส่งผลให้เห็นจริง,saved/rejoin/replay-safe;ไม่มีmandatoryBondpowergrind;eventsใช้rewardauthorityเดิม |
| **P6 — Federation & war** | federationidentity/roles/leadership,invites/leave/disband,delegatedcommand/independentparticipants,warobjectives/roster/results,reconnectและseason rules | realmulti-teamwarจบได้;unauthorizedactionsถูกปฏิเสธ;serverlossไม่เดาผู้ชนะ;outcome/rewardonce |
| **P7 — Territory & global market** | capture/ownership/upkeep/bonuscaps/seasontransition,globalmaterialmarket,escrow/claims/history/operations | distinctliveserversจริง;fill/cancel/compaction/fencing/claimrecovery;zero conservationerror;territoryไม่บังคับmarketprice |
| **P8 — Full world/art completion** | ขยายqualitybenchmarkไปทุกเมือง/region/interior/NPC/enemy/boss,Public13และทุกreleaseoutfit/action/audio/UI | ไม่มีrequiredassetplaceholder;fit/load/rights/listening/route/device/humanartacceptance |
| **P9 — Full-game integration Alpha** | รวมP2–P8กับshop/BattlePass/seasons/analytics/web;แก้balance/security/performance/migrations | หนึ่งcandidateเล่นตั้งแต่1→100→endgame→Federation/war/territory→marketได้ครบ;offline/rejoin/fault/recoveryผ่าน |
| **P10 — Closed Beta & qualification** | fresh/returningTH/ENhumans,actualAndroid/iOS,cloud/cross-server,longsessions,war+market+PvEconcurrency,load/abusecases | ไม่มีP0/P1blockers,devices/capacityผ่าน,documentedhumanUAT;แก้และrerunaffectedpaths |
| **P11 — Release Candidate & go/no-go** | ตรึงcommit/assets/config/products/world,seasons,website/storecopy/footage,support/rollbackrehearsal | same-build evidenceครบ,ownerart/UATและreleaseleadตรวจmanifest;ownerอนุมัติtarget/build/actionsจริง |
| **P12 — Full-game Go-live** | เปิดPublicตัวเต็มพร้อมwar/territory/market/Lv100ตามapprovedmanifest,ตรวจordinaryaccount/save/trade/paidfulfillment | productionverificationและincidentcoverageพร้อม;ไม่เรียกLv35sliceว่าfullrelease |
| **P13 — Stabilization** | เฝ้า72hแรก,reviewทุกวันสัปดาห์แรก,day14retrospective,hotfix/rebalance | unresolvedlostvalue/dupe/securityไม่มีค้าง;ค่อยเพิ่มเนื้อหาใหม่จากfeedback |

**ทำขนาน ไม่เรียงรอทั้งหมด:** หลังP0 เปิดP1/P2/P3; P4ต่อยอดP2ขณะP3เดินต่อ; P5ตามidentity/saveที่นิ่ง; P6ตามP3และcontractที่ล็อก; P7 market-hardeningเริ่มขนานP3ได้ แต่territoryintegrationต้องมีP6 result authority; **P8เริ่มตั้งแต่P1** และจบก่อนP9 ห้ามรอsystemsเสร็จแล้วค่อยทำเมือง P9ต้องรอทุกrequiredstreamก่อนส่งP10

Critical dependencies: shared durable claims→multiplayer→war authority→territory/economy integration; progression/quest gates→Lv100route; goldenbody/rig→allpresets/animations→device; allstreams→fullintegration→Beta→RC→Go-live

## 3. เมือง สิ่งปลูกสร้าง และความเป็นธรรมชาติเป็น release gate

Art direction: stylized fantasy ที่น่าเชื่อ สัดส่วน/วัสดุ/การใช้งาน/การเคลื่อนไหวสอดคล้องกัน ไม่บังคับphotorealism แต่ไม่รับฉากblockoutเป็นงานfinal

| ด้าน | สิ่งที่ตรวจรับ |
|---|---|
| เมือง6แห่ง | Crownford/Sylvaris/Deepforge/Astralis/Crosshaven/Ironrootมีเอกลักษณ์district/landmark/materials;เส้นทางและserviceเข้าใจได้;ไม่ใช่สำเนาเมืองเปลี่ยนสี |
| Architecture | foundation/roof/door/stairs/columnsสัมพันธ์กัน;scaleตรงกับ13bodies;player+5heroesผ่าน;collision/occlusionไม่ติด |
| Interiors | โรงเตี๊ยม/forge/questhall/ร้าน/อาคารกิลด์ที่ใช้งานมีlayout/furniture/tools/servicepointsสมเหตุสมผล;ไม่สัญญาว่าdecorativefacadeทุกหลังเข้าได้ |
| Nature | terrainสูงต่ำ/ทางลาด/ริมฝั่ง/หิน/ต้นไม้/transitionตามbiome;safe routesและspawn/returnpoints;foliageไม่บังtelegraph |
| Living NPC | work/rest/travel/talk/interruption/resume,มือจับtoolsและcontactจริง,ไม่เดินทะลุอาคาร,stream/distancebudget |
| Heroes/motion | footcontact,turn/start/stop,weapon grip,wind-up/contact/recovery,formationไม่กอง,stairs/doors/warpsผ่าน |
| Atmosphere | lighting/material/ambientaudioเข้าพื้นที่;weather/timevariationถ้าบรรจุcatalogต้องไม่บังcriticalcues;ไม่มีsimulationเพิ่มโดยไม่จำเป็น |
| Evidence | ordinarywalk/combat/service/visitrecordingในเกมจริง,day/lightingconditionsที่รองรับ,deviceprofileและownerartreview |

P1ทำลานเมือง→tavern→forgeพร้อมภายใน,NPC,เสียงและทีมฮีโร่ให้ownerรับรองก่อนขยาย คุณภาพแต่ละเมืองต้องเทียบbenchmarkนี้; assetในresearchต้องผ่านprovenance/license/payload/fit/importก่อนใช้งาน RuntimeIDsเป็นnullยังไม่ผ่าน

## 4. จำนวนเนื้อหาขั้นต่ำที่เสนอให้ล็อกใน P0

จำนวนต่อไปนี้เป็น **ข้อเสนอสำหรับsign-off ไม่ใช่รายงานว่าทำเสร็จ** ใช้ป้องกันคำว่า“ครบทุกระบบ”กลายเป็นขอบเขตไม่มีที่สิ้นสุด

| ระบบ | ขนาดรุ่นเต็มที่เสนอ |
|---|---|
| Progression/campaign | ครบcatalog5base/10Class2/10Class3/4specialpaths;6arcs/36campaignsteps+Novice6;13bodies/20palettes;tower10floors;Hall1–20 |
| Team combos | 3คอมโบที่เล่นต่างกันอย่างน้อย attack/control,protection,support;soloพร้อมNPCใช้ได้;หนึ่งชุดแรกใช้พิสูจน์ก่อนเพิ่ม |
| Bond/stories | ระบบBondใช้งานจริง;3hero-story templatesแบบมีต้น/กลาง/จบ,keyโดยownedinstance;dialogue/cosmeticrecognition;identityทุกheroไม่หายเมื่อduplicateclass |
| Living Guild | TrainingGround,StrategyTableพร้อมsavedteampresets,Blacksmith,Warehouse,HeroQuarters,TrophyHall,ResearchRoom/interactionที่เข้าถึงได้จริง |
| Guild research | Military/Crafting/Explorationอย่างละ3meaningfulnodes รวม9;boundedcosts/respec;ไม่ข้ามclass/Hall |
| Dynamic events | 3ประเภทแตกต่าง: defense,exploration/escort,wanderingboss;fullstart/end/eligibility/recovery;rotatingcontentไม่เปลี่ยนrewardauthority |
| Endgame | towerครบ + 3replayableteamchallenges + mastery/achievement/trophyloop;ไม่มีmandatorypaidaccess |
| War/territory | 1boundedobjectivewar modeที่เล่นจบได้จริง และ3distinctterritoriesที่capture/hold/contestได้;caps/upkeep/seasonresetครบ |
| Market | existingreviewedmaterialallowlist;ทุกalloweditemtradeได้end-to-end;ราคา/fee/slots/capsล็อกจากexistingconfigและbalance review |
| Website | Home,Features,Roadmap,World/Classes,Devlog,FAQ,Gallery;Playtest/Communityเมื่อมีapprovedlinks;ไม่มีfakePlaybutton |

Boss/monster counts,quest listทั้งหมด,items/recipes/outfits/animations/cuesและwarplayercapsต้องทำ **named release inventory** ในP0: rowมีcanonicalID,required/optional,owner,source/export/runtimeID,acceptanceและdependencies ก่อนP0ผ่านต้องไม่มีrequiredrowที่จำนวนหรือขอบเขตยังไม่กำหนด จำนวนNPC cosmetic variationsไม่ใช้แทนbehaviorcoverage

ตัวอย่างพื้นที่จากเอกสารเก่าไม่ถูกนับเป็นพื้นที่ที่อนุมัติอัตโนมัติ;3territoriesต้องเลือกจากworldที่รองรับจริงและล็อกIDs ห้ามเดา50สมาชิก/สงครามขนาดใหญ่จากdraftเก่า ต้องกำหนดpopulationจากloadqualificationก่อนcommit capacity promise

## 5. Federation, war และ territory contract

เอกสารเก่าใช้คำPlayerGuildสำหรับองค์กรมนุษย์ ให้ทำ mappingไปFederationแบบreviewed ไม่rename/deletepersistednamespaceอัตโนมัติ แต่ละPersonalGuildยังมีhumanownerคนเดียว Federationสมาชิกเป็นมนุษย์/เจ้าของGuild ไม่ใช่NPC

Membership/authority: atomic reservationและprovisional/active membership,concurrentinvite,cap,rolecapabilities,acceptedleadershiptransfer,leave/kick/rejoin/disband;Commanderไม่ใช่treasuryadminอัตโนมัติ Independentparticipantต้องมีscopeเฉพาะmatchไม่ให้สิทธิ์base/economyของคนอื่น

Federationtreasury/contribution: ถ้ามีsharedbudgets/research/warcostsในrelease ต้องreserve/commit/deliver/receiptครบ;disbandไม่ทิ้งfunds/pendingclaims;ไม่คัดลอกbalanceข้ามprofilesแล้วถือว่าatomic Exactdeposit/spend/refundpolicyต้องล็อกP0 ไม่เพิ่มarbitrarypersonalwithdrawalโดยนัย

Warstate: scheduled→registration→locked→running→resultpending→finalized หรือcancelled/void;authorityมีepoch/fencing;rosterrevision,eligibleparticipants,matchrules/gear/PvEboostexclusion,start/endและwinconditionsชัด Serverlostให้recoverจากvalidstateหรือvoid/rescheduleไม่แต่งผลผลแพ้ชนะ ข้อเสนอno-live-migrationในรุ่นแรกต้องระบุในUX

PvPอยู่ในmatch/zoneที่ยินยอม ไม่ทำsafe cityเป็นPvP ไม่ให้war lossยึดPersonalGuild/paidassets/marketescrow Reward/battleclaimsหนึ่งครั้งต่อeligibleparticipant; disconnect/kick/latearrival/lastsecondleadershipไม่เปลี่ยนearnedrights

Territorytransferconsume certifiedresultครั้งเดียว,compareownershiprevision/season;benefitduration/caps/upkeep/anti-snowballและbaselineresourcesสำหรับผู้ไม่มีterritory; oldseasonresultยึดcurrentseasonไม่ได้ ไม่มีปรับราคาตลาดโดยตรง ไม่มีpaidbuffในwar

## 6. ตลาดก่อนเปิดจริง

ReusePhase4.5 ledger: durableper-itembooks,profileescrow,matching/partialfill,cancelremaining,claimdelivery,epochfencing,receiptfloors/compaction,archive/recovery/circuitbreakers ไม่มีsecond ledgerเพื่อหลบข้อจำกัด

ต้องทดสอบdistinctliveJobIdsจริง: concurrentorders,fill/cancelrace,unknownwriteoutcome,serverrestart,offlineowner,fullbag/walletcap,stalewriter,archivetransition,replayedclaims และpause/reopenโดยรักษาpendingdelivery

สมการvalueต้องreconcileGold/items/fees/reserves/claimsตลอดscenario **conservationerrorต้องเป็น0** ทุกกรณีที่ทดสอบ หากunresolvedvalueมีแม้รายการเดียวห้ามผ่านmarketgate ไม่ใช้syntheticsoakแทนcloud ไม่มีtimeoutrefundที่เดาจากresponseหาย

UXแสดงnooffers/stalequotes/partialfills/pendingclaims/pausedmarketอย่างถูกต้อง ไม่มีfakeprice/สัญญากำไร ตลาดเปิดพร้อมfullGo-liveตามเป้าหมายนี้; ถ้ายังไม่ผ่านต้องเลื่อนfullreleaseหรือให้ownerเปลี่ยนscopeอย่างชัดเจน ห้ามเงียบปิดmarketแล้วเรียกว่าตัวเต็ม

## 7. Mapping ข้อเสนอ20กลุ่ม: ไม่มีระบบหลักถูกเลื่อนไปหลังเปิด

| # | Theme | Phaseส่งมอบหลัก |
|---|---|---|
|01|FTUE|P1–P2|
|02|Advanced Hero AI|P1–P3,scaleP10|
|03|Team Combo|P1prototype→P5สามชุด→P9balance|
|04|Combat feel/boss|P1,P4,P8|
|05|Hero identity/Bond|P5|
|06|Living Guild|P2foundation→P5complete|
|07|Quest/exploration|P2+P4|
|08|Human Party6|P3|
|09|Shared PvE/rewards|P3,P9–P10|
|10|Economy/crafting|P2/P4/P7/P9|
|11|Mobile/accessibility|ทุกplayableslice,P8/P10รับรอง|
|12|Save/security/performance|ทุกphase,P9–P11รับรอง|
|13|Analytics/balance|P1foundation,P9productionreadiness,P10cohorts|
|14|Guild research|P5|
|15|Dynamic events|P5|
|16|Replayability/endgame|P4–P5|
|17|Social/cosmetics|P3visits,P5identity,P6Federation,P8assets|
|18|Daily/season/monetization|P2preview→P9qualified|
|19|Website/discovery|P1direction→P8footage→P11ready|
|20|AI production/releasepipeline|P0และต่อเนื่อง|

หลังเปิดเหลือเพิ่มเมือง/เควสต์/season/cosmetics/war modes/สินค้าใหม่และปรับbalance ไม่ใช่ค่อยสร้างระบบBond/Research/war/market/Class3ที่ขาดจากตัวเต็ม

## 8. Timeline และทรัพยากร

ไม่กำหนดวันปล่อยที่ไม่มีข้อมูลรองรับ และไม่ใช้estimatedreadinessเดิมของLv35กับfullscopeนี้ ภาระเพิ่มทั้งเนื้อหา/เมือง/animation/Federation/war/cross-servereconomyอย่างมีนัยสำคัญ จึงต้องประเมินใหม่ทั้งหมด

Cadenceเสนอ: รอบ5วันทำการ จบแต่ละรอบมีplayable/evidenceincrementและremainingeffort update P0ต้องทำworkbreakdownพร้อมeffortrange/owneravailability/externalwait จากนั้นforecastfinishด้วยdependencyและbottleneck ไม่ถือว่า1phase=1รอบ

วันต้องบันทึกหลังestimate: T0planlock, T1benchmarkapproved, T2Lv35Alpha, T3Lv100+multiplayerAlpha, T4war/marketAlpha, T5fullBeta, T6RC, T7Public ทั้งหมดเริ่มเป็นTBD เวลาจริงจะถูกล็อกเมื่อpreviousgateผ่านและcapacityพร้อม;การเก็บD7ต้องelapsed7วันจริงจากcohort

| Workstream | Accountable | งานขนาน |
|---|---|---|
|Gameplay/content|game-design-lead/narrative-lead|Lv1–100/classes/quests/Bond/research/events|
|Multiplayer/combat|engineering-lead|tactics/Party/sharedPvE/Federation/war|
|Economy/data|technical-director + market-engineer|saves/settlement/market/territorybenefits/commerce|
|World/characters|art-lead|goldenscene→6cities/regions/13bodies/outfits/rigs|
|Presentation|animation/VFX/audio/UI leads|eachclass/weapon/NPCaction,TH/EN/accessibility|
|Qualification|qa-lead/performance-engineer|automated/Studio/cloud/device/human evidence|
|Release/product|producer/release-lead|inventory/estimates/web/analytics/support/approvalmanifest|

Role definitionsไม่ใช่จำนวนworkersจริง ใช้availableconcurrencyและonecoordinatorledger Claimก่อนwrites,serializeBootstrap/Protocol/Localization/economysharedfilesและStudio/Blenderexclusivehandoffs ก่อนimplementใหม่ต้องreconcileactualmodulesและregisterscopedtasksตามแผนใหม่ ไม่activateทุกsystemในคราวเดียว

Research adoption: P1ต้องเลือกfree-reviewedhelper/modelที่ช่วยactualgoldensetและนำผลเข้าเกม ไม่หยุดที่รายงาน; pin/license/payload/network/credentialreview→isolatedtrial→quality/timecomparison→accept/reject→fallback ใช้Blender/Studio/nativepipelineเดิมได้ทันที ไม่ต้องติดตั้งทุกpluginหรือซื้อassetsเพื่อถือว่าทำงานสำเร็จ

## 9. เกณฑ์ Full-game acceptance

- **Route:** fresh/returningทั้งTH/ENเล่น1→100และClass1/2/3ได้ทุกsupportedpath; Hall11ก่อน70/Hall17ก่อน100ไม่มีdeadlock;เชื่อมช่วงcatalogTower50–65ไป70ด้วยเนื้อหาที่ผ่านbalance ไม่บังคับgrind/market/paid/warเพื่อผ่านmainstory
- **All-system journey:** earn/gather/craft/equip→heroes/Bond/research→Party/sharedboss→Federation/war→territory→produce/trade/claim→leave/rejoin;มีทั้งSoloและsocialroutes ผู้เล่นSoloไม่ถูกบังคับเข้าร่วมสงครามเพื่อmainprogress
- **Value:** sharedreward/market/treasury/territory/commerceแต่ละledgerและการเชื่อมต่อconservevalue;partialwrites/replay/unknownoutcomesไม่เพิ่มหรือลบสิทธิ์โดยเดา
- **War:** concurrentteamsจริง,roster/permissions/reconnect/void/finalization/seasonrollover,duplicate-result/reward/territorytransfer tests;จุดรบปลอดpaidbuff
- **Assets/world:** namedreleaseinventoryทุกrequiredrowมีsource/provenance/runtimebinding/fitและhumanapproval;6cityroutes/services,13bodies,allrequiredoutfits/actions/audioจริง
- **Performance:** actualAndroid/iOSอย่างน้อย30นาทีต่อsupportedtestdevice,declaredminimumhardware/quality,PC/inputpaths;วัดframe-time/memory/thermal/network/servercost;target30FPSที่minimumdeviceตามplan ไม่ใช้emulatorแทน
- **Population:** 6humans+30heroes+enemies+mixedoutsidersสำหรับPvE;warมีcapsและloadscenarioแยกกำหนดP0แล้วพิสูจน์P10 ไม่ใช้36alliesเป็นservercapacityclaim
- **Security/data:** old/new/corruptsave/migrations,sessionownership/fencing,rate/ownership/rangevalidation,fullbag/offlinependingclaim,productionrollbackอ่านschemaใหม่ได้
- **Commerce/seasons:** approvedcatalog/prices/IDs/caps;fulfillmentbeforeack;disablednewpromptsยังrecoverpaidpending;oldseasonclaimretention;noPvEboostinwar
- **Human:** freshplayersเข้าใจเกม/tactics/market/warโดยไม่ให้developerบอกทุกขั้น;ownerตรวจเมือง/ความเป็นธรรมชาติและgamefeel;realcohortD1/D7ใช้วัดปรับไม่ใช่การันตีretention
- **Operations:** support/incidentownerจริง,logs/alerts/rollbackrunbook,websitecopyตรงreleasedbuild;privatecredentials/playerdataไม่เข้าpublicmanifest

Severity0/Severity1 critical bugs ต้องเป็น0ก่อนRC (เป็นระดับความรุนแรง ไม่ใช่หมายเลขphase): corruption/dupe/lostpaidvalue/security,blockednormalroute,brokenwar/marketrecoveryห้ามwaiveด้วยเอกสารภาพสวย Minorcosmeticwaiverต้องระบุimpact/owner/due dateและไม่ขัดbenchmarkที่ตกลง

## 10. Go-live / rollback

P11releasepacket: exactcommit/tree/buildhash/assets/config/schema/namespace,universe/place/ownerpermissions,product/pass/seasonIDs,marketallowlist/fees/caps,war/territoryrules/populationlimits,CI/evidence,knownissues/waivers,rollbackrevisionและhumanoperators

P12ทำเมื่อownerอนุมัติbuild/target/actionsนั้น: verifyisolatedstaging→publishตามscope→ordinaryaccountjoin/save/rejoin→PvE/war/territory/markettrade/claim/approvedpurchaseverification→openapprovedPlaylinks→monitor72h หากvalue/securityเสียให้stopnewadmission/offers/warregistrationตามระบบที่ได้รับผล รักษาpendingclaimsและfinalresults ไม่ล้างprofiles ไม่เปลี่ยนผลสงครามหรือคืนเงิน/ของด้วยการเดา

การเปิดแบบcontrolledpopulationเพื่อดูstabilityทำได้เมื่อplatform/ownerอนุมัติ แต่ตัวเต็มต้องเปิดทุกrequiredsystemที่ผ่านแล้ว ไม่แอบเปลี่ยนเป็นLv35release หากไม่ผ่านblockerให้delay;scopechangeต้องownerตัดสินใหม่

## 11. Sign-off ฉบับนี้

**ได้รับคำสั่งเป้าหมาย Full Game แล้ว; รายละเอียด GL-2.0 รอตรวจรับ**

- [ ] FG1 รับPublicแรกเป็นLv100/Class3/fullcampaign/Federation/war/territory/market พร้อม20systemgroups;Lv35เป็นinternalmilestone
- [ ] FG2 รับminimumcontentที่เสนอข้อ4 และให้P0ล็อกnamedinventoryที่เหลือก่อนถือว่าขอบเขตพร้อมimplement
- [ ] FG3 รับcity/naturalworldbenchmarkและhumanartgate;art/tooladoptionทำขนานcoreตั้งแต่ต้น
- [ ] FG4 รับP0–P13,dependency/acceptance/no-goและการforecastใหม่;ไม่บังคับวันเปิดจากLv35planเดิม

ข้อความรับรอง: **“Sign off GL-2.0 ตาม FG1–FG4: Go-live ตัวเต็มทุกระบบ รวม Lv100 สงคราม ยึดพื้นที่ และตลาด ตามแผน”**

Owner/approvedAt: PENDING; actualreleaseapproval:PENDING การรับรองแผนไม่ใช่สิทธิ์publish/privatepublish/paidupload/APIหรือRobuxspending/livecommerce/productionDataStorewrites สิทธิ์เหล่านั้นยังผูกกับscopedactionและbuildจริงตามAGENTS.md

## 12. Source precedence และสิ่งที่เปลี่ยน

GL-2.0แทนGL-1.0/ข้อความLv35-firstในLAUNCH_PLAN,LATEST_GOALS,EXPANSION_PLANในด้าน**เป้าหมายการเปิด** เอกสาร/featuremanifest/taskregistryเก่าที่ยังเขียนpost-launchสำหรับClass3/Bond/Research/events/Federation/war/marketเป็นhistoricalclassificationที่P0ต้องปรับ ไม่ใช่เหตุให้ตัดออกจากตัวเต็ม

RuntimeReleaseContentยังจำกัด35และflagsยังปิดตามcandidateปัจจุบัน จะแก้ภายหลังเมื่อimplementation/validationพร้อม ไม่ขยายallowlistจากเอกสารอย่างเดียว รายงานการทดสอบเก่ามีขอบเขตเท่าเดิม ไม่มีการอ้างว่าLv100/war/marketผ่านแล้ว

อ้างอิงที่ตรวจในงานนี้: `production/PROGRESSION_CONTRACT.md`, `docs/GUILD_WAR.md`, `docs/MARKETPLACE.md`, `production/design/integration/GOLIVE_MASTER_PLAN_TH.md` และ20-themeintake/ปัจจุบันในconversation เอกสารGuildWarเก่าใช้PlayerGuildและตัวเลขcapacityเชิงเสนอ ต้องmapFederationและvalidateใหม่ ข้อกำหนดด้านความปลอดภัยเดิมยังอยู่

งานนี้แก้แผนเท่านั้น ไม่รันgameplay/cloud/deviceใหม่ และไม่อ้างbaseline885จากรอบก่อนเป็นfreshfull-gameacceptance

Independent document review: feature_audit ตรวจครบ20themes, phase dependencies, scope transition, city/art gatesและauthority boundaries — PASSสำหรับownerreview ไม่มีblockingfindings; แก้ชื่อseverityให้ไม่สับสนกับphaseแล้ว Local structure/whitespaceและForge metadata validationผ่าน ไม่ใช่game/releaseacceptance
