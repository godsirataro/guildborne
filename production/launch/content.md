# Launch content candidate — 2026-10-14

Status: source policy and synthetic compatibility tests only. Not Studio, persistent Beta, or Public acceptance.

## Integration contract

`require(Server.Systems.ReleasePolicy)(require(Server.Config.ReleaseContent))` returns a resolver. Call `resolve(runtime, {isStudio, placeId, gameId})` once, before freezing content. `Runtime.LaunchCandidate == true`, Studio, PlaceId0, GameId0 and Memory are all mandatory. No cloud environment is enabled by this resolver.

The resolved profile exposes `Enabled`, `Id`, `MaxLevel`, `MaxHall`, `CampaignChapters` and `problem(data, action, args)`. Call the pure problem function after request validation and before command mutations. Project only its scalar fields to the client, never the function. Existing services still enforce class, level, ownership, proximity and transaction rules.

Fresh launch uses Novice, ChapterOne and ChapterTwo: 12 campaign steps following the six Novice steps. Hall4 naturally caps fresh Novice levels at35. Do not change `ProfileLevelCap` or truncate saved XP. Existing levels, classes, skills and future earned claims remain stored and valid. This preserves elevated legacy profiles; it is not a combat normalization feature.

Command gates stop new Hall upgrades beyond4, future class paths, Ashen travel/gather, future task acceptance and tower entry. LeaveTower and previously earned task claims remain available. Player Novice Class2 additionally requires campaign claimed12. Hero Novice Class2 is explicitly unavailable until a subject-owned hero mentor contract is implemented; the player's story/trial cannot stand in for a hero's proof. This is an open launch requirement, not completed hero advancement.

`CampaignService(content, util, economy, activeConfig, fullValidationCatalog?)` accepts an optional complete validation catalog. The active config must be its exact chapter prefix with matching choice semantics. Validation uses the complete catalog while observe/claim use only active chapters. Compose all six existing arcs for historical validation, only the first two for launch actions. No migration or deletion of later choices/objectives/permits is required.

## Verification

- `tests/run_launch_content.luau`: six grouped policy/compatibility tests, including all partial Chapter01–03 checkpoints, future choices and claims at Lv50, malformed validation catalogs, isolation guards, legacy preservation and blocked future commands.
- `tests/run_campaign.luau`: existing 46 campaign tests passed after the optional catalog change.
- `tests/run_latest_progression.luau`: existing 12 progression tests passed.
- These are service-level synthetic tests. No normal-player Lv1–35 playthrough, cloud save, device, commerce or publication acceptance is asserted.

## Remaining integration work

Root coordinator owns bootstrap selection, request dispatch, bilingual UI availability, build output and Studio verification. Spatial world entrances and prompts must communicate the same release boundary as authoritative request gates. A future enabled persistent release needs a separately tested environment policy; changing a runtime flag alone cannot activate this local-only candidate.


## Subsequent hero mentor implementation

The original HeroMentorUnavailable restriction is superseded by the optional, hero/path-specific proof described in `hero-mentor.md`. The player campaign receipt still cannot serve as a hero receipt. Missing proof now reports HeroMentorRequired. This source change requires its own candidate/Studio acceptance; prior player/Borin route evidence belongs to the prior SHA.
