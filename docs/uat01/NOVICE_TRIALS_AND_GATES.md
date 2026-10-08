# Novice access and solo-trial evidence — 2026-10-04

## Implemented and tested

Novice profiles cannot use ordinary guild/economy/travel/party/building/market-reservation/combat commands before Chapter 00 founding. State/recovery/language/tutorial and the dedicated chapter/class/founding intents remain available. Guards exist in public network handling, domain command dispatch, recruitment/settlement services and market reservation. Internal recovery is not replaced by a new onboarding transaction system.

After founding, newly recruited or Tavern-hired Novice heroes begin at level 10/450 XP. Legacy profiles still recruit at level 1/0 XP. Schema 8 rejects under-level Novice heroes. Existing legacy saves and migrated legacy profiles are not uplifted. Actual UI regression after the changes selected Warrior and recruited Rowan normally at revision 2: player level 1, Rowan level 1/0 XP, Hall 1/cap 5.

`NoviceTrialSession` provides temporary server-side trial evidence, not a combat engine. Candidate lessons:

| Class | Requirements before victory |
| --- | --- |
| Warrior | 3 basic hits and 1 successful dodge |
| Knight | 2 successful taunts and 2 basic hits; matches the existing root-class skill |
| Archer | 3 ranged hits from 12–45 studs and 1 dodge |
| Mage | 3 ability hits and 1 dodge |
| Priest | Restore 40 actual HP and dodge once |

Runs require a level-10 classless profile after chapter 5, no party or expedition, a bounded server-created identity and a 300-second deadline. A companion's assistance, death, leaving the 45-stud arena, excessive events or victory before the lessons fails the run. Events are owner/run/player-bound and deduplicated; changed evidence under the same event ID is rejected. Successful runs yield a stable private NoviceTrial receipt. The combat adapter must supply genuine server-observed damage, healing, dodge, taunt, isolation and position measurements; client claims are not acceptable measurements.

## Validation and limits

483 full domain tests passed, including five trial tests and two access/recruitment tests. The market simulation completed 5,000 orders with zero invariant violations. Strict analysis, compilation and main/offline builds pass at 202 runtime files. The existing 1,450 native story JSON round trips were rerun after these changes. Startup is clean and the actual legacy UI regression is saved in `validation-novice-gates-legacy-live.json`.

Main runtime remains legacy and Novice is not enabled. The dedicated training combat/world adapter is still required; ordinary combat is intentionally unavailable to an unfinished Novice profile. These evidence rules and synthetic tests do not establish that the five trials can be played. Pending: class-preview kits, trial enemies/arenas/telegraphs, genuine event adapters, complete course interactions, actual-input onboarding and persistent reconnect/device/human acceptance.

Evidence: `validation-novice-trials-domain.txt`, `validation-novice-gates-domain.txt`, `tests/novice_trials.luau`, `tests/novice_story.luau`.
