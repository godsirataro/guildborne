# Class advancement, builds and ancestry — Phases 2.5 and 2.7

> Current decision (2026-09-29): Phase 2 is closed under the user-selected implementation/polish scope. Class 2 unlocks at level 30, Class 3 at 70; no Class 4. Actor cap is 100, unlocked at Guild Hall 20 (five levels per Hall). Existing quest/tower/path prerequisites still apply. Large shared city hub is the next Phase 3 priority. See [closure](PHASE2_CLOSURE.md).


> Current update — 2026-09-28: Current level ceiling is Hall×5 up to 50, for player and heroes; XP is banked. F–SSS hero rank is independent of class tier/prestige. New duplicate-class heroes each own their own skill build. Existing action poses and skill effects remain active. See [city progression](CITY_GUILD_DISPATCH.md).

The player and each owned hero keep a separate skill build. Their original base class and equipment compatibility remain stable; advancement selects a path within that class. Human/Class 1 legacy records migrate unchanged.

## Advancement

Class 2 requires level 3 and completion of Quarry Patrol. Class 3 requires level 6 and tower floor 5. These are the tuned ten-level slice gates, replacing the expansion plan's illustrative level-20/50 examples. Path choices are permanent in this slice; skill reset does not reset class or ancestry.

| Base class | Class 2 → Class 3 | Active specialization |
| --- | --- | --- |
| Warrior | Berserker → Warlord; Duelist → Sword Saint | Nearby area strike; stronger single-target lunge |
| Knight | Guardian → Fortress; Paladin → Holy Sentinel | Temporary guard and taunt; strike with self-healing |
| Archer | Ranger → Wild Warden; Sniper → Deadeye | Multi-target volley; longer-range heavy shot |
| Mage | Elementalist → Archmage; Spellblade → Arcane Knight | Area nova; close-range life-draining slash |
| Priest | Cleric → High Priest; Oracle → Prophet | Stronger ally healing; damaging slow |

Wild Warden is the current ranged branch. Summoned pets/Beastmaster entities remain later content rather than an unimplemented pet promise.

## Skill tree and loadout

Each actor earns one point per level after level 1. Vitality costs 1 (+6 maximum HP). Focus costs 1 (+2 Attack) and Ward costs 1 (+3 Defense); both require Vitality and are mutually exclusive. Path Art costs 2, requires Vitality/Class 2 and unlocks the branch active. Master Art costs 2 and requires Path Art/Class 3. Prerequisites and total spent points are validated against the saved actor level.

One learned art is equipped on Q/the existing mobile skill button; basic attack remains F/click. Starter skills remain selectable, and a normal Class 3 path retains its Class 2 art. Reset costs 10 Gold, clears learned nodes and equipped art, and preserves earned level/points and path. Shared ability cooldown prevents changing a loadout to bypass a cast cooldown. Players may edit builds at tower rest stops, but not during unresolved floor combat.

## Prestige and discovery

These Class 3 alternatives require a matching Class 2, level 6 and Hero Quarters:

| Prestige path | Base class | Gate | Tradeoff / active |
| --- | --- | --- | --- |
| Commander — Epic | Warrior | Tower 5 | -1 Attack, +2 Defense; nearby-party guard and taunt |
| Rune Knight — Epic | Knight | Tower 5 | Life-draining attack with a long cooldown |
| Bard — Epic | Priest | Tower 5 | -1 Attack, +2 Defense; nearby-party healing with a longer cooldown |
| Shadow Dancer — Legendary, Secret | Archer | Tower 10 + gathering all four node types | -6 HP, +2 Attack; draining strike |

Epic/Legendary prestige and Secret discovery are separate definition fields. These are earned progression choices, never purchases or random packs. The other special-class ideas in the expansion plan remain optional future content.

## Ancestry

One explicit, confirmed choice of Human, Elf or Dwarf is available to the player. Human is neutral; Elf gains 1 Attack and loses 3 HP; Dwarf gains 3 HP and 1 Defense but loses 1 movement speed. Every ancestry supports all starter classes. Elf ear ornaments and Dwarf beard braids fit existing R6/R15 head attachments without changing collision hitboxes. The five named companions retain their existing identities.

## Animation and effects

Procedural shoulder poses distinguish weapon attacks, area sweeps, guard/heal casts and draining strikes. Existing follower idle/run/downed/recovery animation remains active. Effects distinguish slash/projectile, area pulse, guard sphere, healing cross, drain beam and slowing orb. Bosses signal windup before attacking. Server actions supply replicated presentation markers; neither poses nor effects decide damage.

Effects last at most 1.25 seconds, use non-colliding local parts, cull beyond 100 studs, cap concurrent effect parts at 48 on desktop / 30 on touch and reduce area pulses on touch viewports. These are functional procedural animations/VFX, not bespoke uploaded animation clips or finished audio production. Further polish must preserve readable server timing and these budgets.


## Visual polish pass — 2026-09-28

Shared ActionPose now choreographs a 0.62-second preparation, release and recovery phrase across shoulders, torso, neck and hips, with R6/R15 joint names. Warrior twists into sweeping crescents with a short weapon trail; Archer draws and releases luminous bolts/rain; Mage projects a sigil and impact crown; Knight raises a faceted oath shield; Priest calls ascending healing lights. Drain returns violet wisps and Slow raises ice-like shards. Impact sparks use a built-in Roblox particle texture. These remain procedural game animations; no external animation asset was uploaded. Cosmetic preparation does not delay server damage or change cooldowns.

Memory-only Studio checks exercised all five actor poses, all five primary visual signatures, desktop and touch saturation, and trail/particle cleanup. Desktop saturation reached 48 parts; touch reached 30; all expired. The final trail/particle addition also passed a separate native spawn/cleanup check. All 108 domain tests and full build/strict gates remain green. Runtime sources now total 58. Preview rigs were removed by stopping Play and DataStore configuration was restored. See [native results](evidence/skill-polish-checks.json) and [automated output](evidence/skill-polish-validation.txt).

## Warrior crescent refinement — 2026-09-28
Warrior Physical/Area arts now have a .10-second charge, a tapered white/gold travelling crescent, release-only weapon trail and delayed .24-second impact sparks/ground arc. Area arts use a wider crescent. Uses original geometry and Roblox built-in particle texture; no purchased assets, uploaded animation IDs or external audio. Existing server damage timing is unchanged; this is cosmetic choreography, not a projectile hitbox.

Player pose overlay now supports both Motor6D and AnimationConstraint, with last-frame overlay removed before Animator evaluation to prevent accumulation. Native R15 AnimationConstraint shoulder movement and recovery were verified. API reference: [Roblox AnimationConstraint](https://create.roblox.com/docs/reference/engine/classes/AnimationConstraint).

Verification: 122 automated tests and full gates pass. Studio Memory cosmetic probe reached 40 parts for a cast, ten simultaneous requests capped at 48, then zero remaining effects and no Trail. No paid assets, live-profile edits or publish. This pass is the Warrior prototype; new sounds, camera effects and authored animation assets are not included. [Native results](evidence/warrior-vfx.json), [validation](evidence/warrior-vfx-validation.txt).

## Four-class VFX refinement — 2026-09-28
Mage Magic/Area: casting seal, comet trail and impact crown; Archer Physical/Area: bow energy, release bolt and staggered arrow rain; Knight Guard/Taunt: shield outline, translucent face, oath cross and target taunt mark; Priest Heal: caster seal, target healing ring, ascending lights and halo. Knight support pose now braces the arms separately. Existing Drain/Slow and other special-path effects remain available. Uses original geometry/built-in textures; no new sound, paid asset or animation upload.

Studio Memory cosmetic probes exercised seven class/effect combinations: peaks 23/27 Mage, 15/27 Archer, 20/22 Knight, 30 Priest; zero parts remaining after each phrase. Twelve simultaneous Heal requests peaked at the shared cap of 48 and cleaned up. Visual previews used the live R15 avatar with QA attributes, not server combat/reward acceptance. Desktop verified; this pass does not certify physical-device performance. 122 tests and all build/strict checks passed. Normal persistence restored and Play stopped; not published.

[Native checks](evidence/class-vfx.json), [validation](evidence/class-vfx-validation.txt), screenshots: [Mage](evidence/class-vfx-mage.jpg), [Archer](evidence/class-vfx-archer.jpg), [Knight](evidence/class-vfx-knight.jpg), [Priest](evidence/class-vfx-priest.jpg).
