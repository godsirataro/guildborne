# Full connected world: implementation and evidence gaps

Audit date: 2026-10-20. This document preserves the source audit at `cf6f2e00046985d1a62f00caf1b4ae6efe90b359` and incorporates the bounded full-connected startup packet committed in `1d92e78`. It is a requirements/dependency audit, not full-game acceptance. Later integrations and the synthetic party lab need their own evidence; this document does not independently certify them.

The requested outcome remains one connected open world, all cities, monsters and quests through level 100, tower gameplay, and a player with up to five hero companions. The current implementation has substantial campaign content and two continuous roads. Six civic cities still use portal travel. A configured chapter catalog is not an earned journey, and a synthetic party fixture is not earned recruitment.

## Requirement matrix

| Requirement | Actual implementation | Evidence and remaining gap |
| --- | --- | --- |
| Central City | `src/shared/Config/City.luau` defines Plaza, Guild, Market, Tavern, Tower and Warp districts, with bounds X -460..460 / Z -1640..-620. | Existing native city work is bounded to its recorded fixtures. City completeness, visual acceptance and the full connected journey remain separate gates. |
| City–Greenwood | `city_greenwood_west` is an allowed walking pair in `src/server/Systems/TravelRules.luau`; geometry is described by `src/shared/Config/WorldQuality.luau` and constructed through `src/server/Services/WorldService.luau`. | `PARTY_WALK_V6_PASS.md` records 79 segments / 1,488 samples with five synthetic eligible companions. This establishes that fixture, not five earned heroes or every city. |
| Greenwood–Ironveil | `greenwood_ironveil_south` is the second configured walking pair, using the same existing services. | `native-v8-20261019/README.md` records 84/84 support rays and 22/22 engine paths after dock repair. These checks do not establish actual five-hero travel, chaining both roads, or recovery under gameplay. The packet also preserves an original-route 28/30 probe result with misses; do not replace that with an unqualified all-routes pass. |
| Ironveil–Ashen | No third walking descriptor or allowed pair exists in the audited route configuration. The existing regional portal is not a road. | This is the next missing public regional edge. S13 owns its read-only survey; route coordinates and geometry are intentionally not invented here. |
| Six civic cities | `src/shared/Config/CivicCities.luau` and `src/server/Services/CivicCityWorld.luau` define Crownford, Sylvaris, Deepforge, Astralis, Crosshaven and Ironroot, including service anchors and portal travel. Their origins are X 0/400/800/1200/1600/2000 at Z -4000, with 200×250 bounds. | No continuous civic-city road graph is implemented by those positions. Historical `docs/uat01/validation-civic-institutions-walk.json` covers local city/service fixture paths, not travel between all cities with a party. No distinct city level bands are authored here. |
| Three adventure regions | `RegionalWorld.luau` constructs Greenwood, Ironveil and Ashen region geometry, gathering nodes and region/return portals. `City.luau` puts origins at (0,0,1400), (500,0,1400), (1000,0,1400). | Historical `docs/uat01/validation-regions-updated-walk.json` covers nine standard R15 paths and 1,402 studs with `playerInteraction=false`. It is not current earned-party acceptance or full overworld content coverage. |
| Level 1–100 story | Six Novice stages plus six campaign arcs of six stages exist in `src/server/Config/NoviceChapter.luau`, `ChapterOne.luau` through `ChapterSix.luau` and `CampaignSequence.luau`. | The fresh full-connected packet exposes all 36 campaign chapters through required level 100. It does not complete any of them. Historical earned completion and current native evidence are separated below. |
| Regional monsters | `AdventureEncounters.luau`, `AdventureEnemyProfiles.luau` and `AdventureRewards.luau` contain 12 regional actor prototypes, four per region. | Fixed prototype stats do not constitute authored level 1–100 overworld spawn bands, population density, encounter variety or balance. Native Greenwood combat evidence is a limited synthetic encounter. |
| Tower | `src/server/Systems/EnemyProfiles.luau`, `ExpansionSchema.luau` and `src/server/Services/ExpansionService.luau` implement ten combat floors, bosses at 5/10, checkpoint 5, first/repeat rewards and completion at 10. | Chapter Four's ten orientation checkpoints are not ten combat-floor victories. Fresh connected tower combat, rewards, retry and party acceptance remain unproven by the startup packet. |
| Player plus five heroes | `src/server/Config/Content.luau` sets party limit 5. Existing walking fixtures can exercise a synthetic full party. | `native-earned-journey-20261020/README.md` establishes fresh Novice → Warrior level 10 → Hall 1 plus one earned Mage, not five earned companions. Full recruitment, formation, combat and recovery across the whole world remain required. |
| Class progression | Approved Novice class gates are 10/35/70; Hall caps and legacy progression are retained in `Content.luau` and `src/shared/Data/Expansion.luau`. | Class Three permanent-proof candidate remains off in the full-connected preview. Story/borrowed mastery is not permanent Class Three proof acceptance. |

## Campaign bands and preserved ownership

| Content | Configured required levels | Existing setting / scope |
| --- | --- | --- |
| Novice | 1, 3, 5, 7, 9, 10 | Six-stage introductory journey before normal progression. |
| Chapter One | 10, 12, 14, 16, 18, 20 | Early city/Greenwood story and guild establishment. |
| Chapter Two | 20, 22, 25, 28, 30, 35 | Ironveil; Hall 2–4 progression. |
| Chapter Three | 35, 38, 40, 43, 45, 50 | Ashen; Hall 4–7 progression. |
| Chapter Four | 50, 53, 55, 60, 63, 65 | Tower story/orientation and private court; rewards progress toward level 70 / Hall 11. |
| Chapter Five | 70, 72, 75, 78, 80, 85 | Crosshaven private court; Hall 11–14 progression. |
| Chapter Six | 85, 88, 90, 93, 95, 100 | Archive Heart; Hall 14–17 progression. |

Existing `CampaignWorld`, `IronveilWorld`, `AshenWorld`, `TowerWorld`, `CrosshavenWorld`, `ArchiveHeartWorld` and `CampaignService` implement chapter worlds and owner/session progression. Public road integration must preserve private mine, court, tower and Archive boundaries and retryable server receipts. The Ashen Chapter Four annex is a private story pocket, not a public interregional road.

The six civic charters remain `elian_charter`, `vaela_seedlings`, `borin_castings`, `nyra_stonecharts`, `sela_shelter` and `roka_shared_pot` for Crownford, Sylvaris, Deepforge, Astralis, Crosshaven and Ironroot respectively. A new road must preserve those identities and service bindings.

The 12 regional prototypes are:

- Greenwood: `greenwood_scout`, `greenwood_archer`, `greenwood_boar`, `forest_captain`.
- Ironveil: `quarry_raider`, `stone_guard`, `crystal_shaman`, `quarry_guardian`.
- Ashen: `arcane_sentinel`, `rune_caster`, `rune_hound`, `arcane_warden`.

The encounter catalog's `RuntimeEnabled=false` must not be summarized as all combat being disabled: `src/server/Services/RegionalCombat.luau` has a Studio, place/game-zero, Memory-only per-owner `OfflinePersonal` bridge on regional geometry. This is still not broad shared-world monster population acceptance. `GREENWOOD_COMBAT_NATIVE.md` uses a synthetic level-60 Knight with zero heroes and an anchored player for specific Captain attack behaviors.

## Current native packet versus historical completion

The packet [native-full-connected-20261020/README.md](native-full-connected-20261020/README.md), committed with `1d92e78`, records candidate SHA256 `ee1e72905495abcf62773ce1cd6742fe33591a3309ebd3de0462d7dd02f9f79e`. It uses zero art datasets and proves only bounded startup and one rejection:

- `source-comparison.json` matches 395 expected and actual sources with zero source/attribute mismatches using normalized UTF-8 length/Adler32. This is not cryptographic live-place identity.
- `fullChapterCatalog.json` is the corrected actual GetState catalog: 36 chapters, `MAIN_01_01`–`MAIN_06_06`, through required level 100, Active Studio Memory and regional combat available.
- `fullAdmission.json` records a fresh level-1 Novice's protocol `TravelZone(Ashen)` request rejected with `NoviceJourneyRequired`, revision 0 and unchanged pivot. It does not prove ordinary UI navigation or every admission rule.
- Startup contains both existing roads alongside later regions, with all six journey flags and `FullConnectedWorldCandidate`, launch release off, place/game zero, Memory and an empty allowed-DataStore-universe list.
- `fullStateInitial.json` retains the earlier incomplete catalog query. The standalone Content require in `fullStartup.json` is not the configured bootstrap runtime; use the actual GetState result for availability claims. Console warnings remain in the packet.

The earlier policy incompatibility is now addressed within this isolated preview: formerly, continuous roads depended on launch mode while later arcs required launch off. `ServerBootstrap.server.luau` and `tools/build_quality_preview.py --full-connected-world` now compose the full campaign with existing walking services behind the explicit Memory-only guard. The builder rejects launch/shared-combat/continuous-launch combinations. This does not add a third road, change default Runtime or Release policy, enable permanent Class Three proof, or authorize publication/persistence. The packet records 32 extracted gate checks and three rejected option combinations; its full baseline was pending when collected.

Historical [FRESH_FINALE_PROGRESS.md](../../../docs/uat01/FRESH_FINALE_PROGRESS.md) records an October 6 Memory journey through six Novice and 36 campaign stages to Mage level 100 / XP 5,015 / Hall 17, using normal UI and keyboard-assisted navigation at speed 1 without grants or hotpatches. It predates current road/art integrations and permanent-proof work, uses earlier portal/private-court composition, and does not establish five earned companions, persistence, reconnect, multiplayer, devices or current whole-world acceptance. `FRESH_OCT06_PROGRESS.md` and `ASHEN_ACCEPTANCE.md` are similarly historical, bounded journey reports.

Fresh [native-earned-journey-20261020/README.md](native-earned-journey-20261020/README.md) establishes the six Novice stages, first class, Hall 1 and one earned companion, with four server reward transitions and recorded player/Mage XP. It is the current earned starting point, not a rerun of the entire historical finale.

## Progression constraints

`Content.luau` preserves level cap 100, party cap 5, Novice ruleset `guildborne.progression.2` and legacy `guildborne.legacy.1`. Novice Hall 0 caps at 10, Hall 1 at 20, then increases by five levels per Hall through Hall 17 / level 100. Legacy Hall caps remain Hall × 5. `Expansion.luau` uses class levels 10/35/70 for the Novice ruleset and preserves the legacy second-class level 30. Existing first-clear, tower-floor and path prerequisites also apply; levels alone do not grant advancement.

[class3-proof/PHASE_C_HANDOFF.md](../class3-proof/PHASE_C_HANDOFF.md) documents the separate permanent-proof work. `Class3ProofCandidate` remains off in the full-connected candidate. Do not turn historical borrowed mastery, a displayed catalog or synthetic entitlement into proof of permanently earned progression.

## Exact next dependency and implementation boundary

1. Complete bounded native traversal of the existing second road with the player and five companions, both directions and chained to City–Greenwood, including admission, separation and recovery. Retain the distinction between synthetic fixture eligibility and earned recruitment.
2. Finish S13's already assigned read-only Ironveil–Ashen survey. It must resolve public endpoints, clearance, vertical grade, streaming/party traversal and private-story boundaries before implementation ownership is expanded. This audit does not duplicate that survey.
3. After the survey and exclusive scope approval, add the third physical route descriptor, matching `TravelRules` identity, existing bootstrap gate/service wiring and client route/quest presentation under the full-connected Memory guard. Reuse existing services and authoritative eligibility. Preserve default Runtime, launch release, private-session ownership and reward behavior. Verify the third edge independently before claiming three-region continuous travel.
4. Define and implement the six-civic-city public road graph separately. World positions and working portals do not establish connected roads. Preserve civic charters, service entries and private story pockets.
5. Author the missing overworld level-band encounter distribution and validate the fresh earned level 1–100 journey, five-hero recruitment/combat, ten-floor tower, UI navigation/rewards and separately gated permanent Class Three proof. Visual review, physical-device/performance, durable saves, cross-server behavior and human acceptance remain distinct evidence gates.

`production/world/quality-slice/WORLDGRAPH.md` is historical topology guidance, not a current completion ledger. Neither this audit nor the startup packet marks the full game complete.
