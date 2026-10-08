# Combat foundation — Phases 2.1 and 2.2

Player and companion PvE in a bounded Goblin Camp. The player controls a separate starter-class actor alongside up to five AI heroes. Three timed quests and their saved snapshots are unchanged; real-time combat quest objectives remain future encounter work.

## Boundaries

`Config/Combat` defines roles, abilities, Goblin stats, timing and rewards. `CombatStats`, `CombatTargeting`, `CombatDamage`, `CombatAbilities`, `EnemyLifecycle`, `CombatRewards` and `CombatValidator` are pure server rules. `CombatService` coordinates those rules from HeroService's existing shared 5 Hz scheduler. `EnemyService` owns the three camp models and movement. WorldService builds the small connected camp; HeroService retains trails, throttled paths, collision groups and recovery. No NPC contains a script.

`CombatController` displays replicated attributes, health bars, party health/cooldowns, hit/heal numbers and short cosmetic effects. HeroAnimator adds attack/downed poses. Client effects never cause hits. Server-private entities, not attributes or Humanoid health, are authoritative. Hero Humanoids remain alive for locomotion through a reversible downed state.

## Stats and formulas

Existing class definitions and saved base stats remain unchanged. Combat derives from server catalog class, committed level and compatible equipped weapon:

- MaxHealth = base Health + 3 × (level − 1).
- Attack = base Attack + (level − 1) + equipped weapon Attack.
- Defense = class base Defense; MoveSpeed and attack range/interval come from combat role configuration.
- Damage = max(1, floor(Attack × multiplier × 100 / (100 + 8 × Defense) + 0.5)). Actual applied damage is capped at remaining HP.
- Heal = floor(Priest Attack × 2 + 8), capped at missing HP. Only living, active same-owner heroes within 23 studs qualify. AI requires at least max(5 HP, 20% MaxHealth) missing and chooses the largest absolute deficit.

Negative, nonfinite, out-of-bounds stats and incompatible equipment are rejected. No random critical hits. Magic currently uses the same Defense mitigation formula with a distinct ability/effect identity; no resistances or elemental system.

| Class | Base HP / Attack / Defense | Basic range / interval | Starter ability |
| --- | --- | --- | --- |
| Knight | 40 / 4 / 7 | 5 studs / 1.5 s | Taunt: nearby enemies within 14 studs prefer the Knight for 3 s; 9 s cooldown. Normal damage creates 3× threat. |
| Warrior | 30 / 6 / 4 | 5 / 1.1 s | Power Strike: 2× attack, 5 studs, 6 s cooldown. |
| Archer | 22 / 8 / 2 | 21 / 1.5 s | Piercing Shot: 1.8× attack, 23 studs, 7 s cooldown. Single target in this phase. |
| Mage | 20 / 10 / 1 | 19 / 1.8 s | Fireball: 2.3× attack, 22 studs, 8 s cooldown. Single-target magic burst. |
| Priest | 24 / 4 / 3 | 17 / 2.2 s | Heal: 23 studs, 5 s cooldown. Lowest basic DPS; meaningful deficits only. |

Each ability declares Id, localized Name, Cooldown, Range, TargetType and Effect. Effect dispatch is server-side. Unknown abilities, another class's ability, invalid/downed targets, wrong owner, range and cooldown violations fail before consuming a cooldown.

## AI, targeting and threat

Heroes use Follow, Approach, Attack, CastAbility, Recover, ReturnToLeader and Downed. Existing-target preference is retained; threatening enemies and then distance resolve alternatives. Enemy selection weighs a bounded six-actor threat map (player plus five companions); live temporary taunt takes precedence and naturally expires. Invalid, dead, inactive or foreign entities cannot be targeted. No PvP path exists.

The leader must be alive, profile Active and inside their plot/camp. Combat begins beyond the entrance at local Z=48. Heroes acquire within 26 studs and remain within 38 studs of the leader. Ranged roles stop at useful range and step back when closer than 9 studs. Melee approach offsets avoid exact stacking. Outside combat the original trail resumes. Movement uses the existing path throttle and stuck/fall recovery.

Goblins idle, detect same-owner active heroes within 22 studs, approach, attack, retarget, die and respawn. Their fixed home leash is 30 studs. Leaving the camp, leader death/unavailability or loss of targets clears pursuit; returning home restores enemy HP. The camp is flat and open: anchored server movement is intentionally sufficient here, not a general dungeon navigation solution.

At 0 HP a hero stops fighting. After enemies disengage and at least 10 seconds downed, the hero recovers at half health. Living heroes regenerate 8 HP/s after 8 seconds without receiving/dealing damage, outside combat. Owned heroes are never deleted. Gear/progression snapshots do not refill HP or clear cooldowns.

## Rewards and persistence

One Goblin gives 3 Gold and 2 XP to each participating selected hero, including downed members. Membership is captured on first hero engagement, so a party/quest transition before death processing cannot silently change its recipients. Server death transition latches before spawning any yielding save work. A unique server-generated death operation uses the existing PlayerDataService commit, ownership lease, revision, uncertain-write recovery, audit outbox and recent receipt. Corpses despawn after 2 seconds; respawn waits for submission completion and the configured 18-second delay. Removed plots also destroy temporarily unparented corpses. No reward is displayed as saved until confirmed.

Phase 2.2 adds schema v2 character progression through an additive v1 migration. Gold/hero XP use existing fields; player XP uses data.character. Targets, health, threat, positions and cooldowns are never saved. A server crash before a reward checkpoint can lose that uncommitted reward, as it can lose any uncommitted operation; a committed reward survives. Repeating an uncertain commit uses its immutable ID/revision, never a new grant. Capacity/storage failures do not invent successful rewards. See implementation report for tested failure behavior and limits.

## Security and performance

Phase 2.2 adds CombatIntent accepting only Basic or Ability. Its four-token, four-per-second server bucket bounds spam. The persistent command allowlist still rejects DealDamage, Heal, CastAbility, SetHealth, SetStats, GiveKillReward and CombatReward. The private CommitCombat method has no network dispatcher. Only server-derived distances, entities, cooldown clock and stats reach combat rules. Hero assemblies use explicit server network ownership; Goblins are anchored server models. Client edits to attributes/UI cannot change the private simulation.

One shared 5 Hz loop performs bounded scans of one player, five heroes and three enemies per plot, with throttled existing pathfinding. No per-frame global descendant scans or per-NPC heartbeat connections. The client registers entities at creation and updates a small cached set at 10 Hz. Effects last 0.35 s and emit no particles. Debug counters are replicated bounded attributes, not one production analytics event per hit; durable reward audit remains separate.

Before many-entity battles: spatial partitioning, replication interest management, effect pooling if measured, path budgets, reward batching with a durable deduplication design, and device/server profiling. Current DataStore checkpoints per kill are suitable only for the small test camp. Future buff/debuff/area effects extend the effect dispatcher; dungeons can supply a new encounter lifecycle without embedding logic in NPC scripts. PvP requires explicit team/competitive rules and separate authorization.

Roblox ownership reference checked during implementation: [server ownership guidance](https://create.roblox.com/docs/physics/network-ownership). Server NPC ownership does not constitute a general player movement anti-cheat.


## Player character — Phase 2.2

The player selects Warrior/Archer/Priest/Knight/Mage once with UI confirmation. The saved Human/Class 1 definition has its own XP and level; the party still has five companion slots. The starter kit grants a non-inventory training weapon. Selecting a class permits resting the entire team and fighting solo; timed expeditions still require a hero party. There is no class respec, Class 2/3 advancement or skill tree in this phase.

Click/F performs one basic attack; Q uses the starter ability; two mobile buttons perform the same intents. No auto-attack runs for the player. The server chooses an eligible enemy in the class-specific range; Priest chooses the largest meaningful injured ally deficit, including self. Class ranges and cooldowns use the table above. The actor must currently be alive and inside its own camp (local X ±39, Z 48–117, Y −3–24), with an Active profile. This is range/plot authority, not general avatar movement anti-cheat.

Player participation is recorded only after actual damage, a successful taunt, or healing an ally involved with that living enemy. Merely accompanying the party awards no player XP. An eligible player adds 2 XP to the same atomic reward as participating companions; Gold is awarded once per death, not once per actor. Six recipients are valid; duplicate/unowned/unselected recipients reject the complete reward. Engagement reset clears participation.

At zero domain HP the player cannot attack or cast and has zero movement/jump speed. After ten seconds the server moves them to the guild at half HP; normal out-of-combat regeneration follows. Resetting the avatar during the session does not refill domain HP or erase cooldown/downed timers. On a new session transient combat state starts fresh. Companion downed rules remain unchanged.

The UI shows separate player and party HP, saved player XP/level, cooldown and failure feedback. A server-derived weapon fits R6/R15 hands; procedural upper-body poses and brief color-coded VFX accompany attacks. Bespoke animation clips and audio production remain later art work.

## Phase 2.4–2.7 extensions

Twenty-four new active arts cover both advancement branches of each base class plus four special paths. Equipped arts share the actor ability cooldown. Area, guard, drain and slow effects join existing attack/heal/taunt rules; Bard heals nearby owned allies and Commander guards them. Close-range Spellblade AI approaches its art range. Bosses wind up for 1.2 seconds with a telegraph. Procedural poses and bounded VFX ship with these systems; bespoke uploaded animation/audio remains art production. See [class contract](CLASS_SKILLS.md) and [tower contract](TOWER.md).
