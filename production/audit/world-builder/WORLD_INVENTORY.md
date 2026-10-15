# World source inventory

2026-10-16, source origin `bf948c6`; review-only source audit. No fresh Studio, physical-device or human acceptance is asserted. See `WORLD_GRAPH.json` for fixed topology and `ZONE_MATRIX.csv` for all 19 requested work rows.

Existing assembly lives in `src/server/Services/WorldService.luau`: `CityWorld` -> `CentralCityWorld`, `RegionalWorld` -> `AdventureMapKit`, and `CivicCityWorld` -> `CivicDistrictKit` / `CivicLandmarkKit`. `TravelService` owns safe floor/clearance selection, movement, respawn and follower reset; `TravelRules` retains distance, alive/combat/tower and cooldown restrictions. `City` and `CivicCities` shared configs expose geometry only.

| Area | Existing source and connection | Remaining scope |
| --- | --- | --- |
| Central City | 920 x 1020 ground, six districts, streets, Tavern/Crafting/Market anchors, quest NPCs; CityWorld guild portals | Reference route polish, actual player plus five heroes, performance and final art |
| Greenwood / Ironveil / Ashen | Three AdventureMapKit surfaces; City portal, primary/fallback, return, gathering; campaign services extend them | Fresh source-matched journeys, obstacles, escorts and combat readability |
| Six civic cities | Crownford, Sylvaris, Deepforge, Astralis, Crosshaven, Ironroot; 24 service buildings; charter entry, guide, city and guild exits | Forge/QuestHall remain visual references; all-city earned journey and final environment acceptance |
| Chapter00 | NoviceCourseWorld private course, per-player X slots | Default disabled; explicit Memory preview and fresh guided route required |
| Chapter04 | TowerWorld owner court; separate ExpansionWorld ten-floor combat run | Do not report orientation stations as ten floor acceptance |
| Chapter05 | CrosshavenWorld private court | Physically separate from civic Crosshaven; same-city overlay requires isolation/migration design |
| Chapter06 | ArchiveHeartWorld private court and arenas, ending/return state | Default disabled; finale regressions and visual/companion acceptance |
| Personal island | CityWorld promenade/links, GuildLandWorld, GuildHallWorld, ExpansionWorld | Visitor/owner departure, reconnect and device capacity checks |
| Territory and events | Three territory proposals and optional routes retained in matrix | No approved runtime coordinates/activation inferred |

`src/server/Config/Runtime.luau` uses DataStore and sets Novice/Ironveil/Ashen/Tower/Crosshaven/ArchiveHeartJourney false. Full historical Chapter00-06 evidence describes a separate Memory preview. Do not enable those flags or reuse staging persistence merely to make a route appear connected.

Documentation reconciliation: `docs/TRAVEL_SYSTEM.md` says two destinations; current City config has eleven. `docs/CENTRAL_CITY.md` describes future-only recruitment/crafting/exchange; current central code binds them to existing UI/services. The early exploration-only paragraph in `CIVIC_CITY_TRAVEL.md` predates later active civic Market/Tavern and authored institutions. `KNOWN_ISSUES.md` has old counts and unfinished-region language; later WORK_CHECKLIST and FRESH_FINALE_PROGRESS provide newer historical evidence, not fresh passes. Preserve historical records and attach current results separately.

Source gap: the east-facing Blacksmith at (370,-1000), approach near (398,-1000), lacked an explicit street spur in the audited origin. The central implementation worker owns the correction; do not route directly through its west wall from x=300. Inspect final geometry before claiming clearance.
