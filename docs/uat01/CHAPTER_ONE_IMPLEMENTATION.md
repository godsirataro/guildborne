# Chapter 01 implementation contract — 2026-10-04

Source: `intake/QUEST_CATALOG_DRAFT.json`, MAIN_01_01–06. Source instructions are design proposals, not executable authority. This work implements the user's authorized first-release scope.

Chapter 00 already grants the chosen level-10 founder. MAIN_01_01 must acknowledge that same hero, not grant another starter. MAIN_01_02 may grant one additional guaranteed chosen companion, with an account-bound starter weapon; no random or paid requirement. Legacy onboarding and existing expedition save IDs remain intact.

| Chapter | Proposed server-observed objectives | Reward candidate |
| --- | --- | --- |
| MAIN_01_01 / First Guest | Meet the founder; configure a companion build; issue Regroup | 100 player/founder XP, 15 Gold; no duplicate founder |
| MAIN_01_02 / Empty Table | Visit guild stations with a companion; help the city; confirm team readiness | 100 XP, 15 Gold, one chosen level-10 companion |
| MAIN_01_03 / Two Sets of Tracks | Inspect two tracks; Focus and Regroup in an active escort encounter; finish escort | 100 XP, 20 Gold; acknowledge expedition access without resetting it |
| MAIN_01_04 / Woodland Debt | Inspect cut timber; choose workers/town allocation; recover and deliver timber | 100 XP, 20 Gold; equal rewards for both choices |
| MAIN_01_05 / The Quiet Wolves | Disable a false-crest mechanism; protect the companion; defeat forest guardian | 100 XP, 30 Gold, guaranteed local materials |
| MAIN_01_06 / A Home with a Name | Return evidence; choose a preset motto and crest; register recognition | Hall 2 permit; no automatic Hall upgrade or extra stat points |

The current 50 XP/level curve makes five 100-XP rewards take a newly founded player from XP450/level10 to XP950/level20 without required grinding. These are explicit local balance candidates. Other earned XP remains valid and is not rewritten. Existing Hall currency/material costs remain payable; a permit unlocks eligibility only. Full level/class/party balance remains pending.

Implementation sequence: strict bounded domain state and replay-safe candidate mutations; existing transaction recovery integration; owner/distance-validated world observations; guided UI and bilingual copy; actual fresh-profile journeys; persistence/device/multiplayer acceptance. No draft objective is complete merely because its UI opens, a client says it happened, or a synthetic fixture passes.

Current status: bounded domain state, private receipt recovery and public reward claims implemented; 510 full domain tests pass, including lost acknowledgment/replay/reconnect through the paid-material Hall2 upgrade. Hall2 policy consumes the existing 80 Gold/material price after the permit; legacy policy remains unchanged. Chapter01 bootstrap/world bindings are enabled only in the memory-only Novice preview. Strict analysis, compile, repository and all three builds pass with 222 runtime scripts. One actual fresh Chapter00-to-Chapter01-to-Hall2 journey is complete; this is not release approval.

Actual result (`validation-campaign-full-journey-live.json`): revision69, MageLv20/966XP, BramLv20/975XP, SageLv16/775XP, Hall2/cap25,49Gold,2timber. The six campaign quests yielded100Gold; real encounter rewards supplied29Gold. Hall upgrade consumed80Gold and6timber/6iron_ore/1iron_ingot/2herb. No profile grants or direct gameplay remote calls were used. Campaign markers cleaned up at completion. Choices: workers/together/compass. The R/ButtonY interaction key was patched during the run to resolve an E collision with inventory stations.

Post-journey polish: integer grid sizing fixes a real five-column wrap caused by fractional offset rounding; 54Novice and84Campaign synthetic EN/TH states pass, including704px reproduction width and all six chapter reward views. Campaign guidance and Hall permit reward copy are present; Hall upgrade is promoted above general navigation after recognition. Twelve native scroll-rebuild checks preserve scroll offset while explicit navigation still resets. These final presentation changes need a fresh actual journey after source sync.

The first local Chapter 01 world uses 24 owner-scoped interaction markers, the existing guild/city/Greenwood terrain and existing companion combat. The escort is a party crossing with the player's owned companion: inspect two tracks, issue Focus and Regroup during combat, win against the scout with a living nearby participating companion, and reach the trail marker. A separate moving caravan/NPC escort is still an art/gameplay expansion. Protecting the companion requires the archer victory; the forest captain is the guardian encounter. One actual route passed, but broader party/balance acceptance remains. City crate pickup and local route subtasks use temporary server session flags; reconnect may require repeating uncommitted local steps. Committed objectives survive via profile receipts. New transport visuals reuse original crate/log props with massless non-colliding root welds and verified cleanup; this is a cargo prop, not a hand-carry animation.

Synthetic world evidence: 24 markers, six receipt deliveries, living/distance/equipment/ownership/participation gates, retry handling and session cleanup pass with zero actual profile writes (`validation-campaign-world-native.json`). Actual fresh runtime starts at revision0 with campaign state initialized and no bootstrap errors. Production/legacy persistence migration is not enabled by this preview.

Evidence: `validation-campaign-transactions-domain.txt`, `validation-campaign-ui-native.json`. The synthetic transaction run completes Chapter 00 and all six Chapter 01 stages, injects lost acknowledgments for every objective and claim, then reloads the exact saved profile. This is domain/recovery evidence, not a real player journey.
