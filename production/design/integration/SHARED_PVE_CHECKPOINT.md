# Shared PvE checkpoint — 2026-10-14

## Stop checkpoint — requested quota50% remaining

Weekly usage reached50% used /50% remaining on the latest account read. New work stopped at the user's threshold. Owned Play stopped; localhost transfer server terminated; all worker leases released and root lease released after this checkpoint. No publishing, live commerce or production data writes occurred.

Latest full baseline: **885 tests and all automated checks PASS**, validation-shared-travel-respawn.log. Independent reviewer accepted the respawn source fix and bounded synthetic engine fixture. Latest built/synced local candidate `8deff026c6b574595e84ef89c1453cbe0115e3dc4196ff64604034ee781b0919` matched377 sources, one changed from2ec894. Synthetic anchored replacement/actual Heartbeat/raycast returns error0 both after delayed callback and Saving-to-Active retry. Folder cleanup and subsequent Stop Play remove fixture/listener. Original2ec894 actual Player LoadCharacter failure remains retained.

Actual-player rerun on8deff began normally and reached chapter2 objectives before the quota threshold; it did not reach shared entry/respawn. Memory progress is lost on Stop by design. **Next priority: rerun earned Novice/class/Hall then actual Player LoadCharacter in the shared scene and verify original position after the delayed spawn callback.** Do not claim corrected real-player respawn acceptance from the synthetic fixture. SHARED_NATIVE_TRAVEL.md contains candidate-specific methods and limitations. Then six-human companion load/shared travel, cloud persistence, assets/audio, devices, commerce and human UAT remain release gates.

## Latest continuation — V20 native travel

Candidate2ec894 matched377 local sources and passed883 automated tests/checks. One actual player earned Novice6, Warrior and Hall1, then entered and returned through native shared-scene prompts. The fixed2XP/3Gold pool was delivered once to actual Memory profile revision29 (player+hero each451XP). Reentry stayed unchanged. Independent reviewer accepted this bounded evidence. Injected scene fault and below-bounds recovery returned home. See SHARED_NATIVE_TRAVEL.md and its raw files.

Actual LoadCharacter exposed a race: heartbeat restored the saved point before WorldService's delayed respawn moved the player to normal home spawn. Failure retained in shared-travel-lifecycle-attempt1.json. Corrective source now arms per-character retry only after the delayed spawn callback, including Saving-to-Active retry. Independent review and fresh full validation are in progress; corrected engine retest remains pending. Do not promote the earlier candidate's results to the corrected source.

Sole ledger remains build/agentic/launch-v20-ledger.sqlite3. Local Play was stopped and observers/fixture globals cleared. Latest observed quota51% remaining; continue toward the user's50% stop point. Staging and production remain unchanged. Historical checkpoints follow.

## Latest continuation — V19, local candidate e804

**Later same-candidate result:** actual two-real-client Bootstrap payout and completed-scene reentry now pass scoped independent review. Both earned Novice/class/Hall, then explicitly entered the lab. Each hero gained1XP, Gold split1/2, both revisions28→29; reentry stayed29. No HumanParty membership in this run. See `SHARED_REAL_PROFILE_PAYOUT.md` and unchanged shared-e804 raw files. Dedicated server/clients closed; only Edit preview and Staging remain. Native shared travel is the next slice. V19 leases were all released before copying coordinator+learning history to sole active V20 (`build/agentic/launch-v20-ledger.sqlite3`); 55 task definitions, not55completed tasks.

Latest quota check: 54% weekly remaining; continue until the requested 50% stop point. Earlier figures below are historical.

Fresh `validation-shared-lifecycle.log`: **871 tests and all automated checks PASS**. Candidate SHA256 `e804fcda68202968fce5af6123d1c209c8e86f54c0f2f53bc4e36f141fe242c6` matched all 377 local Edit sources before Play. Staging and production were not changed.

Two real Studio clients previously completed all six Novice steps, class trials, Warrior selection and free Hall founding on candidate3f7; each reached revision28/level10/450XP/Hall1 with one earned hero. This does not prove Lv35 or persistence across a process restart. Their earned shared-scout encounter exposed the corpse-removal EnemyStep fault; the reviewed e804 source now closes a witnessed completed encounter after registered downed actors finish normal recovery.

On e804, `shared-rewards-recovery-attempt2.json` passes real CombatService/Coordinator with two synthetic physical owners and isolated Memory profiles: one owner down at death, 33 recovery ticks/~7.149s after death, both HP15/WalkSpeed17/JumpPower50/JumpHeight~7.2 before Completed, three stable terminal ticks, then conserved test pool11XP/7gold/3herbs and two receipts. Duplicate delivery and Memory service reconstruction remain stable. Attempt1 is preserved: its fixture omitted Prepare each recovery tick and therefore detached its owners; it is not evidence of a runtime recovery regression. No manual HP restoration was used.

`shared-hero-destroy-result.json` passes real HeroService lifecycle with two synthetic owners and five companions each: idempotent Destroy, no recreation or later effects, caller characters preserved and owned containers cleaned. Independent reviewer policy_review accepted both scoped evidence sets. These fixtures do not prove payout into real Bootstrap-loaded player profiles, public shared travel, six human clients, cloud durability or physical-device acceptance.

The optional actual-profile reward binding is source-reviewed and restricted to Studio/Place0/Game0/Memory/SharedCombatCandidate. It uses a separate Memory settlement namespace and the scout's fixed config pool2XP/3gold, a single external Pump worker, exact-session notification checks and bounded shutdown draining. Actual two-client payout remains pending. Historical checkpoints below are retained.

Work continues under the user's instruction to stop when available quota reaches50%. Last observed weekly quota:64% remaining; five-hour window unavailable. No credit reset or extra paid service was used.

## Tactical Studio evidence

Five synthetic physical heroes exercised real HeroService commands on a flat fixture floor: Hold drift about0.0036 studs; Regroup maximum horizontal distance0.696 studs; Defensive attributes, mentor command suspension, travel/unequip cleanup passed; reward callback count0. Model/session cleanup passed. The extra empty HeroService Heartbeat was removed by stopping/restarting Play after the fixture, not by Remove itself.

A second fixture exercised real CombatService and RegionalEvasion with an injected circular hazard. Initial attempt failed because the coordinator supplied the fixture container including actor roots to the geometry query; raw failure retained. Geometry-only ground input then passed allfive Evade→Hold returns at0.504–0.559 studs. This proves a synthetic flat-floor path, not natural boss telegraphs, obstacles, physical-device play or human feel. Independent policy_review inspected fixture/result scope.

## Shared authority and conservation

Implemented explicit opaque encounter/owner membership, composite actor/threat keys, stale membership rejection at effect time, and optional targeting policy preserving legacy default. Independent source review passed. Full regression found an ID-less legacy mock damage compatibility issue; corrected to require a key only for Enemy threat writes and retained the failed log. This is why focused checks did not replace the full baseline.

Prepared settlement module allocates a fixed XP/gold/item pool across eligible owner snapshots using deterministic integer remainder rotation. Injected store inserts immutable allocations once, resolves uncertain acknowledgements by retry/read and rejects changed payloads. Capacity32 records; no eviction, delivery acknowledgement, profile grants or cloud activation. Independent review caught malformed metatable-backed fake provider records; bounded raw-tree validation and regressions now reject them. Store reconstruction over the same Memory object is adapter restart evidence, not disk/process crash persistence.

The once-per-tick encounter scheduler and bounded contribution ledger now pass independent source review. Valid newer event sequences are consumed even for rejected effects; wounds expire and detached actor wounds are pruned. Neutral Recover removes wounds without granting activity or contribution. Every runtime HP restoration must eventually emit Heal or Recover exactly once. These remain private harness modules until reviewed integration enables a selected candidate zone. Party membership never grants an extra share by itself. Owner/team XP subdivision, durable per-profile receipts, overflow/retention, shared travel, actual multiplayer and external release gates remain unresolved.

Fresh full automated baseline passed818 tests, Rojo build/sourcemap, LSP, compilation, repository validation and diff checks (`validation-shared-reviewed.log`). Local Studio candidate b9a287d74c27cc7d1c59767d018568a4dae03ef6c05950216d2ff9b33178bbd0 synced371 source entries exactly. The seven-owner synthetic shared-flow fixture passed in Studio: enemy defeated after6 ticks,38 owner steps, conserved600XP/7gold/1item and0 profile writes. This is domain integration in Studio, not seven human clients, normal quest completion or durable payout evidence.

## Evidence files

- tactics-studio-fixture.luau / tactics-studio-result.json
- tactics-dodge-fixture.luau / tactics-dodge-attempt1.json / tactics-dodge-result.json
- validation-shared-foundation.log — failed baseline preserved
- shared-flow-fixture.luau — seven synthetic owners: owner NPC damage, healer, departed contributor, one enemy HP/tick, conserved settlement preparation; no profile writes
- ../evidence/shared-identity.md, shared-settlement.md, shared-runtime.md, shared-participation.md

Learning lesson recorded: lesson-7cd8ec745e56f182fa203750fd917d9a2c418abef7605865a8b27901dd89d40e. No skill promoted. Forge now has49 task definitions; counts are not readiness percentages.

## Durable claim increment

Version2 freezes actor IDs and divides each owner's XP pool under experimental equal-actors-v1; v1 remains unchanged in its separate namespace. Private durable profile receipts and grants now use the existing PlayerDataService transaction. Receipt lookup survives recent-cache eviction/session epochs; wallet/inventory/actor/receipt/audit/byte bounds reject whole recipient grants. Independent review fixed uncertain response interleaves, unrelated pending saves during yielding reads, adapter cleanup/capacity and public request-ID collisions. No public remote or runtime Bootstrap binding was added.

Fresh full baseline:837 tests and all automated checks passed in validation-shared-claims.log. Candidate0ad72b257dba96cbaa40a2e737a29ca7b7043f96efd9f2276788be704c483d0a matched373 Studio sources. Real modules with isolated Memory profiles passed7owners/14actors,600XP/7gold/13herbs,7durable receipts and service/session reconstruction replay. This is not process restart/cloud durability or7real clients.

CombatService's four private phases retain original body/order and pass independent review. Actual Studio tactical and dodge fixtures passed again; an injected-death fixture proved one reward callback, pending blocks respawn, completed callback permits respawn, player downed/passive recovery and cleanup with callback drainage. Reward callback was a yielding stub, not profile persistence.

The later candidate75169c5d3c878aba276ed9f44be9c8f4ca1d8d7829f86eb4e38402436486503b changes only compact Novice duplicate guidance after that baseline. All373 sources compared; onlySliceUI changed. Compile/LSP passed. English and Thai claim buttons now fit fully in the144px content viewport atCanvas0. A Thai chapter1 objective route then claimed through the visible button with no scrolling and advanced to chapter2. Earlier failed/clipped observations and the failed Crossroads Keeper attempt remain recorded in NOVICE_CHAPTER1_OBSERVATION.md. No gameplay difficulty was changed.

Current coordinator ledger is launch-v16-ledger.sqlite3 after releasing V15 leases;50 task definitions. The next mandatory integration is a shared basic scene using real player/companion actors and existing commands, followed by trusted participation/claim wiring. Shared world routing, durable retention beyond bounded fixture capacity, real multiplayer, imported art/audio, physical devices, commerce and human approval remain open.

## Subsequent Stage A and actual Party clients — 2026-10-15 Bangkok

The preceding entries are chronological history. Current coordinator is launch-v18-ledger.sqlite3, after all V16/V17 leases were released;52 task definitions. Latest observed quota60% remaining, with the user's50% stop threshold unchanged.

Full baseline848 tests, Rojo, sourcemap, LSP, compilation, repository and diff checks passed in validation-shared-context.log. Local candidate1ab631831ed07882021f555e787740e6f82763ca2fc1ef9a655603f9ec8312cf matched374 source entries exactly. Its optional CombatService context has independent scoped review. Two synthetic owners with five NPCs each and two leader rigs exercised once-per-stamp phases and owned commands. Actual effects fixture recorded12 damage and34 cross-owner healing, LOS and duplicate-cooldown rejection, current-session/geometry fencing, preserved HP/cooldowns and detach cleanup. Failed LOS attempt is retained. Injury was injected: this proves healing behavior, not enemy-wound participation or earned reward eligibility. Neutral recovery was not exercised. No profile service or payout path was present.

Separately, candidate75169's actual local server reached six Party members and rejected a seventh. Visible two-client invite/accept, scripted later real-client requests, leader-only permissions, stale revision, actual leader disconnect, grace expiry/replacement and identical disband replay are recorded in PARTY_REAL_CLIENTS.md. All six remaining clients projected solo after disband, profile revisions0. Session ended and owned clients/server closed. This is local Party lifecycle evidence with zero equipped NPCs, not six-team combat/performance or cross-server acceptance.

Party contextual EN/TH error text is source-implemented after that candidate; actual rendering remains pending. Stage B optional HeroService coordinator and root World factory are currently being implemented/reviewed, not accepted. Its synthetic physical test fixture is prepared but has not run. No Bootstrap activation, shared rewards, publishing, production profile writes or commerce was enabled by these changes.
