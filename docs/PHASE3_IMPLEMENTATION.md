# Phase 3 — Central City Multiplayer Hub

Implementation date: 2026-09-29. Acceptance evidence is tracked separately in [Studio test record](PHASE3_STUDIO_TEST.md). No publication or Phase 4 work is authorized by this implementation.

The old small city is replaced by a shared crossroads city with six districts. [City design](CENTRAL_CITY.md) records geometry, road hierarchy, landmarks, future anchors and performance decisions. The kit adds timber house shells, stone arches/walls, towers, stalls, planters and banners. Guild administration has a council spire and arch; the tavern and forge have chimneys; the exchange has a stall frontage. Existing art assets remain reusable.

`CentralCityWorld` builds district folders, roads, eight ambience NPCs, signage and modular frontage beneath the existing city root. `CityWorld` keeps the guild promenade and owned plot links while providing city and guild portal references. Named city and personal spawn markers remain server-owned.

`TravelService` and pure `TravelRules` add destination validation, cooldown, floor/clearance fallback, session respawn and fall recovery. `HeroService` accepts city trail points, raycasts shared world surfaces and resets selected followers on travel. `CombatService` excludes city coordinates from engagement and suppresses idle city healing effects. Character collision groups prevent doorway blocking. See [travel contract](TRAVEL_SYSTEM.md).

The localized CityNavigation overlay adds a district/safe-zone label, a map button and N shortcut, six named destinations and a live position marker. A scrolling map panel preserves label sizes on short landscape screens. Existing progression/combat HUDs are retained. Future-only interactions use the same panel with a clear unavailable message. Thai strings stay in the central localization module; world signs are bilingual.

Thirteen additional automated tests extend the previous 123 to **136**. They cover destination allowlists, forged transforms/identity, unchanged progression on round trips, safe-zone boundaries, prohibited states, fallback definitions, localized unique districts, cooldown isolation, distant requests, foreign-party rejection and existing caps. Full validation also builds the Rojo place, checks strict types, compiles Luau and validates repository boundaries. Existing analyzer style warnings in unrelated UI files remain.

No schema migration or profile reset was added. Normal Runtime persistence stays DataStore. Studio testing used temporary Memory mode. Both two- and four-player sessions earned their parties through all three timed quests. An attempted four-client funding fixture wrote an unused top-level field instead of authoritative currency and did not fund recruitment; the probe correctly received InsufficientGold, then used normal quests. This temporary Studio-only source was removed and the exact disk bootstrap restored before handoff. No test fixture is shipped.

Deferred: global market, order book, player guild backend, new crafting economy, PvP, wars, full dungeons, Class 4 and all other excluded systems. Existing pre-Phase-3 settlement, equipment, dispatch and tower behavior is preserved. Streaming and physical-device performance need dedicated future evidence; Studio simulation alone is not a device benchmark.

Screenshots and remaining limitations are listed in the Studio test record. Treat it as the authority for what was actually tested.
