# City slice verification
2026-09-28, Roblox Studio MCP, Guildborne staging place 86788611613035.

## Isolation
QA uses GB_Player_city_staging_staging and its matching audit namespace, seeded from the earlier isolated Phase 2.7 v4 profile. Normal staging data is not reset. QA-only bootstrap override is removed from Studio after testing; disk bootstrap remains normal.

## Automated
122 tests pass, plus strict Roblox-aware analysis, Luau compilation, Rojo build and repository/link validation. Fourteen city tests cover migration, Hall XP banking, housing, rank odds, duplicate heroes, uncertain scout commits, journal progress, assignment locks, offline jobs, full inventory/uncertain claims, death/revival, injury deadlines, away-equipment ownership and durable receipt deduplication. See [test source](../tests/settlement.luau) and [validation output](evidence/city-validation.txt).

## Native checks
- v4 profile opens as v5, preserving five veteran heroes, player class/race, skill builds, equipment, buildings and tower history.
- City spawn, actual keyboard E portal travel, and native navigation along the promenade and island bridge passed.
- Main city quest accepted/claimed. Side gather counter advanced only after acceptance. Mira's NPC acceptance and herb hand-in passed at her city position.
- Scouted and hired a second Warrior (h:1) with separate hire:1:1 weapon; dispatched independently of the five-member field party.
- Selecting the away hero for field party returns HeroUnavailable.
- Tavern 1→2 upgrade charged resources. Quarters upgrade beyond Hall returned HallRequired; occupied dismantle returned HousingOccupied.
- Hall 2→3 applied banked XP, raising the player and veteran heroes to level 15. Quarters 1→2 raised capacity to 15, and the Side task rewarded its completed four-gather objective.
- CityWorld component add/remove with two synthetic identities passed (count 2→1→0, origins 180 studs apart, promenade length 350). This is not live multi-player acceptance.
- Exact full projected data equality across real Stop/Play while job was pending: PASS. The saved deadline elapsed during the restart. Claim yielded 8 Gold, 6 timber and 10 hero XP; repeat claim returned QuestNotActive.
- Desktop Map Overview opened with native button input. iPhone 17 Pro portrait EN/TH map and landscape TH risk text inspected. Game ScreenOrientation is Sensor. Landscape uses scrolling due to reduced height. Device simulation is restored to default afterward.

## Evidence boundaries
Live multi-player island visibility, foreign-owner actions and owner departure are not yet accepted as a two-client test. Death/revival and receipt fault scenarios are deterministic domain tests, not paid native purchases. No Developer Product ID is configured, no sales enabled, and no publish performed.

One QA-only malformed State payload caused a Localization error during an early navigation attempt; the test harness recovered using GetState, and later restart uses the actual UI button. This was not a normal server response. Invalid ScoutCandidate/SetParty names were harness mistakes; corrected commands are ScoutHero/UpdateParty. Retain those distinctions when reading earlier Output.

Screenshots: [city](evidence/city-arrival.jpg), [desktop map](evidence/city-dispatch.jpg), [Thai portrait](evidence/city-map-th.jpg), [landscape risks](evidence/city-risk-landscape.jpg). Raw snapshots and result details: [native evidence](evidence/city-native.json).

Final cleanup: Play stopped; normal bootstrap restored; all 63 Studio sources exactly match disk; device default with LandscapeLeft orientation. Final restarted Output has no runtime errors. [Output](evidence/city-output.txt), [component island test](evidence/city-island-component.json).
