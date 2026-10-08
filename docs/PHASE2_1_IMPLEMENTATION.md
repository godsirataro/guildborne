# Phase 2.1 — Combat Foundation implementation

Status: **implemented and Studio-verified on 2026-09-28; not published**. The Phase 2.1 Definition of Done is met for the agreed solo-player foundation. At the Phase 2.1 handoff, 2.2 had not started. The user subsequently authorized it; see the [Phase 2.2 report](PHASE2_2_IMPLEMENTATION.md) for current status. Physical-device performance, published-client acceptance and two-player isolation are not claimed.

## Architecture and changed files

Server-private combat entities drive a shared 5 Hz update integrated with the existing HeroService scheduler. Pure rules validate stats, targeting, damage, healing, abilities and rewards. Client attributes are presentation only. The leader guides up to five companions into a three-Goblin camp connected to the original hub. Existing timed expeditions continue independently.

New runtime files:

- [Combat configuration](../src/server/Config/Combat.luau).
- [CombatStats](../src/server/Systems/CombatStats.luau), [CombatTargeting](../src/server/Systems/CombatTargeting.luau), [CombatDamage](../src/server/Systems/CombatDamage.luau), [CombatAbilities](../src/server/Systems/CombatAbilities.luau).
- [EnemyLifecycle](../src/server/Systems/EnemyLifecycle.luau), [CombatRewards](../src/server/Systems/CombatRewards.luau), [CombatValidator](../src/server/Systems/CombatValidator.luau).
- [CombatService](../src/server/Services/CombatService.luau), [EnemyService](../src/server/Services/EnemyService.luau), [CombatController](../src/client/Controllers/CombatController.luau).

Modified runtime files: ServerBootstrap and ClientBootstrap wire services; PlayerDataService adds a private combat commit using its existing checkpoint pipeline; HeroService integrates combat and cleanup; WorldService adds the camp; Art increases plot spacing to prevent camp overlap; HeroAnimator adds attack/downed poses; Localization and SliceUI describe current combat in TH/EN.

Tests: new [combat scenarios](../tests/combat.luau) and [Studio combat sampler](../tests/studio_combat_probe.luau), extended test harness and probe completion tracking. Validation now requires the three combat documents. Existing progression, schema and public command allowlist remain intact. Documentation adds this report, [combat rules](COMBAT.md) and [Studio evidence](PHASE2_1_STUDIO_TEST.md), with focused architecture/data/security/roadmap updates.

## Five roles and exact rules

| Class | Basic range / interval | Starter ability |
| --- | --- | --- |
| Knight | 5 studs / 1.5 s | Taunt: nearby Goblins within 14 studs prefer Knight for 3 s, cooldown 9 s. Damage creates 3× threat. |
| Warrior | 5 / 1.1 s | Power Strike: 2× attack, range 5, cooldown 6 s. |
| Archer | 21 / 1.5 s | Piercing Shot: 1.8× attack, range 23, cooldown 7 s; single target. |
| Mage | 19 / 1.8 s | Fireball: 2.3× attack, range 22, cooldown 8 s; single-target magic burst. |
| Priest | 17 / 2.2 s | Heal: floor(2× Attack + 8), range 23, cooldown 5 s; largest meaningful living-ally HP deficit. |

MaxHealth = base Health + 3×(level−1). Attack = base Attack + (level−1) + compatible equipped weapon Attack. Defense remains the class base value.

Damage = max(1, floor(Attack × ability multiplier × 100 / (100 + 8 × Defense) + 0.5)), capped at target HP. Invalid/nonfinite stats return no damage. Healing caps at missing HP; AI skips deficits below max(5, 20% MaxHealth), full HP, downed, distant or foreign targets. Magic currently shares Defense mitigation.

## Hero and enemy behavior

Hero states: Follow, Approach, Attack, CastAbility, Recover, ReturnToLeader, Downed. Acquisition range is 26 studs; leader leash 38. Melee roles approach with small slot offsets; ranged roles hold useful distance and step back below 9 studs. Movement retains throttled paths, trails and stuck recovery, with combat goals clamped inside the clearing. Gear/progression updates preserve current HP and cooldowns.

At zero HP heroes stop attacking/casting. After disengagement and at least 10 seconds downed they recover half HP. Outside combat, living heroes regenerate 8 HP/s after 8 seconds without combat activity. Heroes remain owned and resume following; player respawn is supported.

Three Goblins have 135 HP, 12 Attack, 3 Defense, speed 12, detection 22, basic range 5 and interval 1.6 s. They approach valid same-owner heroes, prefer accumulated threat/current targets, honor temporary taunt, and retarget after invalidation. Home leash is 30 studs. Disengagement returns them home and restores HP. A corpse despawns after 2 s and respawns after at least 18 s and reward submission completion.

## Authority, rewards and data

No combat RemoteEvent or public command was added. Forged DealDamage, Heal, SetHealth, SetStats, CastAbility, GiveKillReward and CombatReward intents are rejected. Server-private HP/stats/cooldowns, server-measured range, same-owner validation and server-owned NPC physics govern the simulation. Replicated attributes and local effects cannot grant damage or currency.

A death latch runs before any yielding work. Membership is captured when heroes first engage that enemy, including members who subsequently fall. Each death submits a server-generated operation through the existing serial, leased, revision-checked PlayerDataService commit, uncertain-write reconciliation, receipts and audit outbox. Replays cannot duplicate rewards; a stale immutable revision is never upgraded into a fresh grant. Each Goblin grants 3 Gold and 2 XP per participating hero. Gold/XP caps reject atomically.

**No schema migration or new persistent fields.** Schema remains v1. Existing Gold, XP, level and equipment fields are reused. HP, enemies, positions, threat and cooldowns are transient. Rejoin restores persistent progression and recreates healthy companions.

## Validation and Definition of Done

- **59 automated scenarios passed: all 40 previous tests plus 19 combat tests.** Coverage includes formulas, mitigation, invalid values, ranges/intervals, cooldowns, target ownership, taunt expiry, healing selection/cap, dead/downed restrictions, config references, forged intents, death latch, reward replay, uncertain commits, real candidate rollback at Gold/XP caps and rejoin. Rojo build, strict Roblox-aware analysis, compilation, repository/link and place-boundary checks passed.
- Actual Roblox Studio Client/Server Play through MCP: original quest/Hall loop, five-member recruitment/equipment/expedition lifecycle, all five basic attacks and abilities, Knight taunt, Priest healing, ranged attacks, Goblin deaths/respawns, downed recovery, camp return, player respawn, forged combat requests and real DataStore Stop/Play.
- A 600-sample fight observed all five roles, 9 deaths and 9 saved rewards. Extended isolated DataStore run recorded 24 deaths and 24 saved rewards, Gold 10→82, +48 XP for each participating hero, and two downed transitions followed by all five healthy followers.
- Exact persistent rejoin matched all public revision/data at revision 58, including Gold 82, five-member party, equipment, XP, Hall 2, quest history and English preference.
- Samsung Galaxy A06 simulation confirmed TouchEnabled=true, portrait 358×718 and landscape 705×338. TH/EN HP and cooldown rows fit. Landscape panel was reduced to 112 px high, above the visible joystick. No critical errors in final Studio Output.
- Four screenshots and machine-readable observations are linked in the [Studio report](PHASE2_1_STUDIO_TEST.md).

Every requested Phase 2.1 DoD item has observed or automated evidence. This is a foundation acceptance, not a release/load certification. Studio is stopped, device simulation reset to default, and repository sources restored to the normal staging namespace. No publishing, remote migration or Phase 2.2 work was performed.

## Performance risks and known limitations

One bounded five-hero/three-enemy scan per plot at 5 Hz; one cached client presentation update at 10 Hz. No per-NPC scripts, global per-frame scans or particle spam. Effects expire after 0.35 s; removed plots explicitly destroy despawned enemies.

The camp is a flat, open test encounter. Anchored server Goblin movement is not general obstacle-aware dungeon navigation. Melee/path movement and billboards can bunch during tight fights; the party HUD provides readable HP independently. Animations/effects are simple placeholders, without dedicated audio or polished cast clips. Piercing Shot and Fireball are single-target; there are no elemental resistances, criticals, buffs or AoE yet.

Per-kill DataStore/audit checkpoints need profiling and a durable batching design before scaling enemy counts. Submission retries are bounded to 25 seconds: extended storage failure can show Reward unavailable; a later reconciled checkpoint may still appear in the profile. A crash/disconnect before a successful checkpoint can lose an uncommitted reward. Successful checkpoints survive and are not retried as new grants.

Player movement is not a general anti-cheat system; this phase validates companion attacks and plot ownership. Multi-player plot isolation, real-device frame rate/memory, published Player behavior and long-duration load remain open. No known critical combat or progression defect remains in the tested scope.
