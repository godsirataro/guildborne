# Tactical companion slice — local source implementation

Balanced preserves existing target scoring. Defensive limits automatic targets to valid enemies within 12 studs of the leader, preferring enemies currently targeting that leader. It does not grant defense stats, taunts, healing or rewards. Existing CombatTargeting ownership, space, line-of-sight and range validation remain authoritative. Party6 cross-owner combat is not enabled by this work.

Hold captures the owned selected hero's current server position, projected onto the existing server ground ray; missing ground rejects the order. Accepted orders invalidate pending path generations. It suppresses automatic offense, uses the existing follower navigation, permits telegraph evasion, and resumes its anchor after evasion. The anchor is discarded when beyond the leader leash, on death, travel, removal from the following team or tower transition. It grants no immunity and does not reset cooldowns. Regroup uses stable slot offsets with tank/front, melee/middle, ranged/support/back. Existing ground checks and breadcrumb fallback remain; actual obstacle navigation and crowd readability require Studio evidence.

Focus/Regroup/Retreat remain available. Preset selection clears manual orders; otherwise manual orders override the preset. Presets are transient on runtime combat actors, not saved profile fields. Mentor training retains exclusive movement ownership and bypasses normal follower/combat stepping until restoration.

The existing native combat HUD exposes six horizontally scrollable commands without adding a second tall mobile row. Hold binds K / gamepad D-pad right (J remains reserved for the quest tracker); existing bindings stay intact. Presets use native selectable buttons. TacticalPreset/TacticalReason attributes supply English/Thai behavior feedback. The tiny CombatIntent still accepts only action and actorId, never client positions, targets, stats or cooldowns.

An optional final HeroService combatObserver is forwarded into CombatService. Deferred protected calls emit combat_player_damage or combat_player_heal only for effective positive player effects, with `{amount}`; accepted owned companion commands emit hero_order_accepted with `{order}`. No names, target IDs or hero IDs are in these payloads. Observer errors or yields do not suspend the combat mutation; queued payloads contain copied scalar values only, with at most 32 pending observer calls (excess telemetry is dropped without affecting combat).

Local tests in tests/run_hero_tactics.luau verify unchanged Balanced selection, bounded Defensive targets, ownership filtering, manual override/health/cooldown preservation, engagement/leash and stale focus, unique five-hero role offsets, tiny input contract and EN/TH feedback. These pure tests do not certify runtime movement, touch fit or five-hero visuals. Integration owner must test all five heroes through Hold→evade→return, Regroup around obstacles, travel/death/rejoin, mentor suspension and real rendering in English/Thai. Full game baseline and independent review remain separate recorded checks.

## Queued observer identity follow-up

CombatService captures the original Player synchronously before task.defer and passes that object as the fourth callback argument. Missing players drop the observation before consuming a queue slot. Bootstrap must reject callbacks whose captured Player no longer matches the current connection; it must not attribute a queued hit by looking up the numeric owner alone. The bounded 32-call queue and protected asynchronous execution remain unchanged.

This adapter change requires a runtime regression: queue an effective hit, replace/remove the original Player before running the queued callback, and verify the replacement session receives no milestone. Pure tactical tests do not execute Roblox Players/task scheduling, so they are not claimed as proof of this race. Integration-owned observer/funnel tests and the runtime fixture must cover that boundary.

## Private combat step phase extraction

`CombatService.Step` retains its existing public signature and synchronous order. Its original body is now organized into private `prepareOwner`, `stepEnemies`, `stepOwner`, and `finishStep` functions. A private StepFrame carries the same Player/session/leader/character references, time and movement functions, player combat actor, **the same allies array**, engagement/recovery values and mutable fighting result. Enemy work completes before owner work; finish work runs last. No phase API, shared-world activation, new rewards or HeroService behavior was introduced.

Each original phase body was copied verbatim (the extraction script asserted each appeared exactly once in the resulting source). Regional.Sync stays in preparation; Regional.Step remains first in the enemy phase. Hero pairs iteration and enemy/allies ipairs iteration, captured reward GUID callbacks, tower key fencing, recovery and publishing order remain unchanged. The fighting result transfers after enemy work and after owner work.

Pre/post extracted body SHA256 values: prepareOwner `c3e40af51ba78a706c1af2e5095d27836612acbe3b3af7e9c90010402c60590d`; stepEnemies `88feddbe5f8e0888058e57c801d55123508f577bf012fdab262e2b20bb40af1d`; stepOwner `1521e3edf89aa2e64ccd174c47d78d40d94c90a1e9dcbbd4e4d21d39e670883a`; finishStep `f05609962fd9e3b2f2576beb775b9eabdd25159a876a5f35a9109e18fdd85e6a`. These establish text preservation of moved blocks, not live behavior acceptance.

Focused tactics runner: **6 checks passed**. CombatService compilation and Roblox-aware static analysis passed. Existing pure tactics tests do not execute Roblox CombatService; full baseline and independent phase/diff review are coordinator-owned follow-up gates. No new mirrored-implementation test was added for a text-preserving extraction.


## Hold support probe repair (2026-10-20)

CombatService Hold now probes from root reference +1 down17 instead of +8 down24, matching the reviewed follower repair and preserving the original reference-minus16 lower bound. This prevents selection of the Greenwood overhead lintel as a Hold target. No ownership, readiness, order, health, cooldown, observation or recovery logic changes.

Actual PlayerAction was extracted through its function boundary into ignored `build/hold-support-review/current.luau`, using real HeroTactics and geometric/server mocks. Eighteen cases passed: native floor2/lintel12.5/reference5 resolves root5; Travel/jump references7/9; elevated floor52; void; reference-minus20 rejection; minus16 acceptance; foreign/missing/not-following/dead/removed actors, dead/inactive leader, own-player selection and shared-policy rejection. Rejected commands preserve order/path/generation and emit no accepted-order observation; all cases preserve HP/stats/cooldowns. Original +8/down24 source resolves root15.5; the unchanged regression fails against it.

Run `.tools/luau/luau.exe build/hold-support-review/current.luau`; the original-regression runner intentionally exits nonzero. Raw stdout/stderr and exact source/harness hashes are in `build/hold-support-review/receipt.json`, SHA256 `b2ed0d627c835de19a1f33ed601aa5b6b12b74edfc9c7482efcc58b8712a2e1a`. CombatService compilation passed. Existing pure hero_tactics tests cannot inject actual CombatService, so no mirrored permanent test was added. Native behavior NOT_RUN; existing immutable Studio candidate was not changed.
