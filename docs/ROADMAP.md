# Delivery roadmap

> Launch scope decision — 2026-10-02: The user requires personal guild islands, portals in every launch city, public/friend visits, quest-gated Robux plot purchases with required material contributions, freely positioned buildings and purchasable permanent mixable building themes together in the FIRST public game release. See [authoritative scope and acceptance](LAUNCH_GUILD_ISLANDS.md). This supersedes older deferral of these specific systems, including theme monetization to Phase9; other release gates remain. Development resumed by the user on2026-10-03. Earlier15%quota pause is superseded; current evidence and remaining launch work are recorded in [the implementation checklist](uat01/WORK_CHECKLIST.md).

> Phase 4.5 update (2026-09-29): Phase 4.5 hardening is implemented for further controlled private testing. Public release remains disabled pending real independent-server, physical-device and sustained private cloud acceptance. No publication and no Phase 5.
> See [implementation](PHASE4_5_IMPLEMENTATION.md), [operations](MARKET_OPERATIONS_RUNBOOK.md), and [verification](PHASE4_5_STUDIO_TEST.md). Prior phase text is historical.


> Current Phase 4 status (2026-09-29): Phase 4 implementation and Studio acceptance are complete for a bounded pilot; 210 automated tests pass. True cross-server live acceptance, physical touch, cloud capacity and durable archive/epoch support remain public-release gates. Nothing was published and Phase 5 is not started.
> See [implementation](PHASE4_IMPLEMENTATION.md), [Studio evidence](PHASE4_STUDIO_TEST.md), and [invariants](PHASE4_MARKET_INVARIANTS.md). Older sections below retain historical/planned scope.


> Phase 3 Central City Multiplayer Hub — 2026-09-29: implemented and exercised through Roblox Studio MCP with two and four actual clients, up to 20 companions, round-trip travel, recovery, safe-zone checks and bilingual simulated mobile views. Automated total: 136. See [implementation](PHASE3_IMPLEMENTATION.md) and [detailed acceptance/limitations](PHASE3_STUDIO_TEST.md). No publication. Phase 4 remains unstarted and requires explicit approval. Historical city-slice notes below describe earlier work.

> Current decision (2026-09-29): Phase 2 is closed under the user-selected implementation/polish scope. Class 2 unlocks at level 30, Class 3 at 70; no Class 4. Actor cap is 100, unlocked at Guild Hall 20 (five levels per Hall). Existing quest/tower/path prerequisites still apply. Large shared city hub is the next Phase 3 priority. See [closure](PHASE2_CLOSURE.md).


> Current update — 2026-09-28: Phase 3 city/settlement slice is now implemented: [rules and current boundaries](CITY_GUILD_DISPATCH.md). Next is two-client island/isolation verification, published staging device/reconnect checks, then real Elixir product setup and receipt acceptance. Player-party co-op, dungeons and world bosses remain later Phase 3 work. Earlier monetization direction is extended by the user-authorized fixed-item revival Elixir; current Gold price is 1,000, planned product price 49 Robux, sales disabled.

Status, 2026-09-28: **Phase 1 accepted for the agreed solo-play handoff**, including TH/EN. Implementation, automated gates, Studio gameplay and real DataStore Stop/Play are agent-verified; published Player rejoin and remaining acceptance checks are user-reported passes. Two-player data/plot isolation remains deferred, not passed. See [implementation evidence](PHASE1_IMPLEMENTATION.md) and the [acceptance record](PHASE1_STUDIO_TEST.md). **Phase 2.1 Combat Foundation is implemented and Studio-verified, not published**: 59 automated tests, all five roles/abilities, secure rewards, exact real DataStore rejoin and bilingual touch-viewport inspection. See [combat report](PHASE2_1_IMPLEMENTATION.md). Phase 2.2 is implemented and Studio-verified, not published; see [the report](PHASE2_2_IMPLEMENTATION.md). Phase 2.3 is implemented and Studio-verified, not published; see [equipment report](PHASE2_3_IMPLEMENTATION.md). Phases 2.4–2.7 are implemented and Studio-verified, not published; see [expansion delivery](PHASE2_4_7_IMPLEMENTATION.md). Phase 3 is next. Later phases remain direction only.

## Gates by phase

**Planning update, 2026-09-28:** the user requested consolidation of player classes, Class 1→2→3 advancement, Epic/Legendary/Secret classes, skill trees, player/team equipment, resource gathering, base Build Mode, a tower and isekai races. The [expansion plan](EXPANSION_PLAN.md) is the current design direction and supersedes the former 2.2 equipment/crafting sequence. The user authorized Phase 2.2 after consolidating the three source chats and then continued through Phase 2.7 by explicit instruction. Phase 3 onward remains planned. Animations/effects accompany each playable feature, with polish after validation. Historical Phase 1 contracts below remain historical.

**Art Phase 1.5 closed by explicit user approval, not published.** Final Studio gameplay, bilingual mobile views, geometry gates and exact persistent rejoin passed; historical evidence and remaining device/multiplayer checks are recorded in [the art report](PHASE1_5_IMPLEMENTATION.md).

**Phase 1.6 implemented and Studio-verified, not published:** visible heroes, tavern, equipped visuals and followers. User amended the party maximum to five, with Knight/Tank and Mage/Magic joining the three original classes. Forty automated tests, native five-member lifecycle, navigation/respawn, bilingual simulated mobile UI and exact isolated DataStore rejoin passed. Published-client, physical-device and multiplayer checks remain open. See [the Phase 1.6 report](PHASE1_6_IMPLEMENTATION.md). Phase 2.1 adds only companion PvE in a bounded camp. Open-world combat, random packs, weekly recruitment rotation and rank systems remain deferred.

| Phase | Small deliverables | Validation / exit gate |
| --- | --- | --- |
| 0 — Architecture / GDD | Required nine design documents, research register, Git/Rojo structure, two smoke bootstraps | Validate files, Rojo build and source compilation; record unrun Studio checks; stop for approval |
| 1 — Playable vertical slice | Persistence first, then recruit/party, three quests, equipment, hall milestone, tutorial/UI | New tester completes loop unaided; rejoin retains committed progress; exploit/failure tests pass; no critical Studio errors |
| 1.5 — Visual vertical slice polish | Compact guild hub, 25 asset templates, Hall 1/2 silhouettes, lighting, TH/EN UI polish, Blender handoff | Actual Studio loop, movement/prompts, screenshots, mobile views, part budget and persistence regression; see art report |
| 1.6 — Visible heroes and party | Five visible classes, tavern recruitment, up to five followers, equipped weapon visuals, TH/EN | Legacy loop plus five-member lifecycle, navigation/respawn, isolated persistent rejoin, mobile and Output |
| 2.1 — Combat Foundation | Five distinct companion roles, Goblin Camp, secure damage/healing/aggro/rewards | Automated regression plus actual Studio combat, recovery, persistence and mobile inspection |
| 2.2 — Player Character & Class Foundation (implemented; Studio-verified) | Player chooses one of five starter classes; own stats/XP, basic/starter ability, PC/touch, class-tier/race foundations, essential animation/VFX | Player and five AI heroes fight together; secure actions/rewards, safe v1 migration, exact rejoin, regression and Studio/mobile checks |
| 2.3 — Inventory & Equipment (implemented; Studio-verified) | Shared account inventory, separate player/hero equipment, weapons/armor/accessories, comparison/filter UI | Exclusive instance equip, compatibility, atomic reassignment, full-capacity and save/rejoin checks |
| 2.4 — Gathering & Build Mode MVP | Wood/stone/ore/herbs; private grid prefabs, preview/rotate/place/move/dismantle; Hall anchor, warehouse and quarters | Server-owned resource awards and construction costs, plot/overlap/path checks, exact base restore, mobile part budget |
| 2.5 — Class 2 & Skill Trees | One advancement branch end-to-end, then five-class expansion; active/passive, points, loadout/reset, quest gates, animation/VFX | Prerequisites/point conservation, meaningful builds, reset/rejoin safety, readable PC/mobile combat |
| 2.6 — Tower MVP | First ten floors, varied encounters, rest/boss checkpoints, first-clear/repeat rewards tied to base progression | Complete/fail/retry/rejoin flows, duplicate-proof rewards, no basic-resource progression deadlock |
| 2.7 — Expanded Classes & Races | Class 3, special/secret class content, Human/Elf/Dwarf before other races; facility crafting and polish in bounded increments | Unlock/balance, migration, rig/equipment/animation compatibility, entity/effect budgets and device evidence |
| 3 — Online activities | Presence → invitations/player party → one co-op dungeon → one world boss | Published-client group travel/reconnect; duplicate boss claims rejected; bounded server/device load |
| 4 — Global marketplace | Storage experiment → escrow bridge → one-item limit orders → cancellation/partial fills → immediate orders → history/reference/charts → small allowlist | Conservation under faults; transient-state loss recovery; bounded load/latency; safe archive/receipt compaction before general launch |
| 5 — Player Guild | Create/invite/accept/leave, filtered names, explicit role permissions, roster | Concurrent joins/removals repaired; no privilege via stale membership; no treasury yet |
| 6 — Guild progression / boss | Reviewed treasury contribution/spend, one research branch, guild quest/boss | Shared funds reconcile; idempotent member rewards; progression offers specialization |
| 7 — PvP / Guild War | Competitive rules experiment → 8v8 objectives → 20v20 trial → 30v30 only if justified | Fairness by spend cohort; mobile/server performance; roster/result/void recovery tests |
| 8 — Territory / economy | One territory bonus → seasonal ownership transition → one configurable world event | Exactly-once ownership effects; capped production; baseline progression access survives concentrated control |
| 9 — Monetization | Policy/API review → bound cosmetics → carefully reviewed QoL/pass | Official receipt/ownership paths; persistent deduplication; refund/error cases; no paid combat advantage |
| 10 — Analytics / balancing / hardening | Broader dashboards, reconciliation at scale, exploit simulations, restore drills, economy experiments | SLOs supported by staging evidence; privacy/deletion and incident runbooks exercised |
| 11 — Closed alpha | Invited cohorts, feedback/support workflow, staged content rollout | Tutorial completion and retention data; no unresolved critical economy/data-loss defects; load beyond planned opening |
| 12 — Public beta | Gradual access expansion, operational coverage, known-issues communication | Rollback and recovery rehearsed; capacity margin; support and monitoring staffed |

Security, basic analytics, and economy accounting start in Phase 1 and grow with each feature. Phase 10 does not excuse postponing them. Art polish, world size, and content quantity expand only after the current loop works.

## Phase 1 work packets

1. **Content and persistence foundation.** Define eight item IDs, three recruit definitions, three quest definitions, a Goblin Scout, XP thresholds, and Hall costs. Add schema validators, deep-copy defaults, session ownership, migrations, serialized commands, bounded audit export, and development/staging adapters. Demonstrate new load/save/rejoin before rewards exist.
2. **Recruitment and NPC party.** Free Warrior; Archer and Priest at 20 Gold each; exactly three roster slots and one party. Persist known class recruitment markers. Include ownership/duplicate selection checks and a loading/retry screen.
3. **One quest end to end, then data expansion.** Start/claim Trail Watch with server deadlines, deterministic reward snapshot, and duplicate-proof run sequence. Exercise failure boundaries. Add Timber Escort and Quarry Patrol through definitions using the same enemy type, not bespoke quest scripts.
4. **Equipment and Hall milestone.** Tap-to-equip a compatible owned weapon. Hall 1→2 costs 80 Gold, 6 Timber, 6 Iron Ore, 1 Iron Ingot and 2 Herbs in the same profile commit. No crafting implementation, gear enhancement subsystem, or other facility upgrades.
5. **Tutorial and minimal UI.** Guild, Party, Quests, Inventory screens; clear disabled reasons, costs, reward/XP feedback, and save status. Persist tutorial progress and restore the next action on rejoin. Verify 360×640 and 640×360 layouts plus PC input.
6. **Acceptance and failure rehearsal.** Fresh unaided user run, leave/rejoin after every progression step, server/storage fault injection, malicious client requests, migration tests, and Studio Output review. Produce evidence and stop before Phase 2 approval.

## Exact Phase 1 content contract

| Category | Included |
| --- | --- |
| Personal Guild | One per player; Hall levels 1 and 2 only |
| Adventurers | Warrior, Archer, Priest; known deterministic recruitment; level and XP |
| Party | One NPC party with up to three owned adventurers |
| Quests | Trail Watch, Timber Escort, Quarry Patrol; one active run at a time |
| Enemy | Goblin Scout definition reused in all three quests |
| Currency / progression | Gold and adventurer XP only |
| Items | Timber, Iron Ore, Iron Ingot, Herb, Training Sword, Short Bow, Apprentice Staff, Iron Sword |
| Equipment | Owned weapon instances, compatibility, one slot each; no upgrades/crafting |
| Persistence | Versioned profile, safe load, checkpoints, session lease/fencing, rejoin, error handling |
| UI | Tutorial plus four primary screens, touch and PC support, saving/retry states |
| Observability | Basic funnel and committed economy/audit events with bounded export |

All eight catalog entries now have Phase 1 utility: Herb and Iron Ingot are Hall inputs, and Iron Sword is a stronger quest weapon. This is the minimal correction to the earlier reserved-only definitions; no crafting was added. “Upgrade” is satisfied by Hall level 2.

Explicit exclusions: global market, player-to-player transfers, player guilds, multiplayer parties, dungeons, bosses, PvP, war, territory, world events, seasons, Robux purchases, paid randomness, external backend, and settlement. No new live infrastructure is required by the Phase 0 scaffold.

## Phase 1 acceptance evidence

Recorded: 37 standalone Luau tests, Roblox-aware strict analysis, compilation, Rojo build/source map and repository validation pass. Local Studio UI gameplay and native RemoteEvent rejection/replay tests completed the Hall-2 route with 10 Gold and Warrior XP 90. [Native Output](evidence/studio-native-2026-09-28.txt) records those results. Actual staging DataStore restored exact active-quest and Hall-2 snapshots across Studio sessions; published-client rejoin was subsequently confirmed passed by the user. The criteria below remain the reference gates. Remaining solo checks were accepted from user confirmation; deferred multiplayer checks still require evidence before multiplayer acceptance.

- Record one clean unaided join → tutorial → recruit → party → all quests → rewards → equip → Hall upgrade → leave → rejoin flow. Proposed first-clear budget leaves 10 Gold after two recruits and Hall cost.
- Assert the restored roster, party, equipment, Gold/XP, inventory, first-clears, Hall level, and tutorial milestone match the last committed revision.
- Show duplicate/early/foreign claims and malformed payloads cannot alter authoritative state.
- Demonstrate failed initial load never overwrites existing progress; uncertain writes remain pending and reconcile without double reward.
- Exercise lease takeover, old-server save rejection, quota backoff, full inventory, and shutdown without trusting the final-save callback.
- Record relevant Luau test output, staging persistence results, target-device UI evidence, and a clean Studio Output log. Static compilation alone does not satisfy these gates.

## Dependencies and unresolved risks

| Risk / needed decision | Resolve by | Evidence required |
| --- | --- | --- |
| Two-player data/plot isolation | Before multiplayer acceptance | Deferred by user for solo Phase 1 handoff; not yet verified |
| Native profile adapter correctness and lease timing | Phase 1 foundation | Fault tests, serialized unknown-outcome recovery, review |
| Content fun and mobile pacing | Phase 1 acceptance | Unaided playtest; recruitment/upgrade timing |
| Global market hot-key throughput and receipt growth | Phase 4 experiment | Actual serialized sizes, load curves, downtime/recovery measurements |
| Safe bridge/archive compaction and offline discovery | Before market general launch | Fault-tested epoch closure and deterministic recovery scan |
| Thin-market/Sybil reference manipulation | Phase 4 closed test onward | Synthetic attacks plus observed participation; confidence labels |
| Shared-guild/match/territory consistency | Phases 5–8 | Recoverable state transitions under races and failure |
| 20v20/30v30 device/server feasibility | Phase 7 scale gate | Profiled representative devices and published servers |
| Monetization policy and API changes | Phase 9 | Dated official review, receipt/ownership validation |
| Audit retention, storage cost, deletion, support capacity | Before alpha/public rollout | Retention policy and rehearsed runbooks |

Do not estimate a commercial ship date before the first slice's evidence. Review scope at every exit gate, preserve completed work, and prefer a smaller proven feature over a broad unvalidated one.
