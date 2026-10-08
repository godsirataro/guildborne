# Civic market and tavern services

Six exploration cities now bind their market and tavern buildings to the existing shared Exchange and recruitment screens. Use R / controller Y at the labelled service marker. Server checks retain a 14-stud interaction limit. City map targets use the same configured positions.

Tavern recruitment uses the existing profile and Gold rules. Upgrading the guild tavern is disabled outside the Guild, with an English/Thai explanation. Forge and quest-hall interiors still need further local gameplay; this milestone does not make each city a finished region.

## Verification — 2026-10-06

- 672 domain tests pass; strict Luau analysis passes; 311 runtime sources; all eight place builds and repository boundary validation pass.
- Native fixtures: 48 paths, 12 landings, 36 prompts; 36 city-map views / 216 text bounds; 120 tavern views and four confirmation cases. These fixtures are isolated checks, not six complete player journeys.
- Fresh Memory session, ordinary keyboard/mouse and speed-1 walking: claim city_gate and elian_charter, enter Crownford with 25 earned Gold, open the local market, then the local tavern. Scout costs 20 Gold, returns an Archer candidate, revision 11 and 5 Gold. Hire and replace are disabled for insufficient Gold; Upgrade Tavern is disabled outside Guild. No profile grants or gameplay remote injection. Console records the expected Gold reward/spend events without errors.
- Temporary client probe scripts removed after stopping Play. Evidence: validation-civic-services-native.json, validation-civic-services-domain.txt, validation-civic-services-types.txt.

Remaining: ordinary-input services acceptance in five other cities, mobile/controller play, persistent and multiplayer commerce/recruitment, final city art and content. No cloud publishing or Robux purchase was performed.
