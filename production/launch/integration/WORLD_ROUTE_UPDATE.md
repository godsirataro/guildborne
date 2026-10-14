# World release boundary and normal Lv1–35 route — 2026-10-14

Public readiness remains false. This is a dirty-worktree local candidate, not a frozen release revision.

## Implemented

WorldService now passes the existing release policy to regional and expansion presentation. In the isolated launch candidate, Ashen entrance/resource prompts are disabled and labelled unavailable in English/Thai. City return remains enabled. Tower opens its recovery/leave panel while its world sign explains the Lv1–35 boundary. Navigation resource nodes and bestiary communicate the same restrictions. Server authority remains in the existing request policy; historical catalogs/saves remain readable.

ViewProjection derives BlockedZones/BlockedNodes from configured resource regions. Current regions are covered; any future region without resource nodes needs explicit projection coverage. Independent source reviewer: launch_progression; no blocker found.

## Build and automated checks

Candidate: `build/Guildborne_LaunchPreview.rbxlx`, SHA256 `55404c199438de6138cf0fee877151c9bc3c422e88a1f1c57e3ba2cf06e08a17`. Local Studio `Guildborne_IntegrationPreview.rbxlx`, Place0/Game0, Memory. 357 script entries synchronized, seven changed. Runtime source itself was not changed to enable cloud content.

`tools/validate.ps1`: 736 tests and all automated checks passed; raw log `validation-world.log`. Studio v3 validate/verify passed:33 roles,39 tasks,10 workflows,98 generated adapter files. Forge validate passed39 tasks/31 skills. These checks do not replace cloud/device/human acceptance.

Read-only `world-boundary-probe.luau` passed live checks: Ashen entry and two resources blocked, City exit retained, Greenwood/Ironveil open, Tower recovery panel retained.

## Normal single-client route

All checkpoints below used the same candidate and one fresh Memory session. Movement used normal-speed navigation; interactions used keyboard and native UI clicks. No inventory/profile grants, direct objective receipt calls, skipped server time, or saved-class fixture substitutions were used. Read-only snapshots inspected outcomes. The conversation tool-action record is the input trace; JSON snapshots alone do not prove the input method.

- Completed all six Novice chapters on rescue branch; five borrowed Class1 lessons; real Warrior solo trial (basic hits/dodge/victory), Hall trial, class confirmation and founder selection through UI. Hall1, Warrior10, Rowan10,0Gold,revision28.
- MAIN_01_01: met Rowan, saved equipped party, selected companion and used Regroup. Lv12,15Gold.
- MAIN_01_02: three island tour points, carried supplies through City, returned to tavern, recruited Priest Sage via confirmation. Lv14,30Gold.
- Greenwood: both tracks, Focus and Regroup while combat active, scout victory with companion then escort turn-in; workers timber choice/delivery; false crest, archer and Forest Captain. Boss reached0HP/Rewarded. Rowan and Sage were in the party for the boss.
- MAIN_01_06: evidence, motto Together, crest Sun, registration, UI reward. Campaign6/Hall permit2. Hall2 purchase123→43Gold.
- Ironveil: three scales/carrier/reception; signal sequence and safe shaft; miner escort paused at exit until player arrived; three supports, timed protection, repair order. Hall3 purchase223→63Gold released banked XP toLv28.
- Reagent/two seals/workers review; three controls, timed worker protection; Quarry Guardian defeated on surface with party and Rewarded; returned key and claimed Hall4 permit. Hall4 purchase321→81Gold released banked XP toLv35.
- Mentor and borrowed Berserker trial: used skill, dodged warning, defeated dummy. Server committed `complete_borrowed_path` and automatically returned the player; final mentor evidence and UI claim completed campaign12. Actual Class2 additionally requires the original Quarry Patrol expedition first-clear.
- Completed Trail Watch, Timber Escort and Quarry Patrol via native UI and real server timers (13/23/33 seconds with this party). Claimed each, then confirmed Berserker in Skills. Final revision114: playerLv35/tier2/pathberserker, Hall4, campaign12, three expedition first-clears,211Gold. This proves one actual Class2 branch only. `world-route-class2-raw.json` and `world-route-console-raw.json` record the final snapshot and full returned console stream.

Raw checkpoints are `world-route-raw.json`, `world-route-main02-04-raw.json`, `world-route-arc1-raw.json`, `world-route-hall3-raw.json`, `world-route-hall4-raw.json`, and `world-route-arc2-raw.json`. Preserve them unchanged. An earlier attempted Hall3 upgrade outside the guild made no change; normal return to guild then purchase succeeded. A few tool targeting/read-path errors were corrected; do not describe the session as an error-free console.

## Remaining release gates

Independent final evidence review by launch_progression passed the scoped local progression claims: matching candidate hash, mentor receipt, chapter12, sequential expedition claims and AdvanceClass114. Final player skills remain empty and starter skill is Power Strike; advancement proof is not proof of learned/equipped Berserker art in combat.

Other real class branches, hero mentor ownership/proof, Borin craft-two-ingots route, persistence/rejoin, multiplayer/cross-server, physical devices, runtime13 presets/fit/audio, final commerce and seasonal lifecycle, and human art/UAT/release signoff remain pending. A normal single-client route is not all-class acceptance. No publication, paid upload, production writes or live sales occurred.
