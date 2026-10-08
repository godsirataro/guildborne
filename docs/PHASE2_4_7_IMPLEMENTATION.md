# Phase 2.4–2.7 delivery

Updated 2026-09-28. The user authorized all four phases in one implementation pass, explicitly including skill animation and effects. Implementation and the scoped Studio verification are complete; native evidence is recorded in the [Studio report](PHASE2_4_7_STUDIO_TEST.md). Nothing has been published.

## Delivered scope

| Phase | Playable slice |
| --- | --- |
| 2.4 | Four gathering nodes; server range/cooldown checks; private grid preview/rotate/place/move/dismantle; Warehouse and Hero Quarters with actual benefits |
| 2.5 | Two Class 2 branches for each of five base classes; independent player/hero skill points, prerequisites, mutually exclusive passives, active selection and paid reset |
| 2.6 | Ten sequential Spire floors; melee/ranged encounters, bosses at 5/10, rest stops, checkpoint 5, first/repeat rewards, failure/leave/retry and resumed fights |
| 2.7 | Ten normal Class 3 paths; Commander/Rune Knight/Bard Epic alternatives and Secret Legendary Shadow Dancer; Human/Elf/Dwarf; Blacksmith and three recipes; expanded procedural motion and VFX |

The level-10 slice uses Class 2 at level 3 plus Quarry Patrol, and Class 3 at level 6 plus Tower 5. The earlier level-20/50 numbers were proposals, not an existing progression contract. Prestige and discovery remain separate from class tier. The named special-class ideas beyond the four delivered alternatives, summoned pets, freeform wall construction and additional races remain later content.

## Implementation

Shared `Expansion` supplies bounded definitions, placement rules, skill prerequisites, compatibility and bonuses. `ExpansionSchema` validates the new state, and `ExpansionService` mutates only disposable saved-command candidates. `ExpansionWorld` derives gathering nodes/building visuals; `BuildView` supplies a local preview; `ExpansionView` exposes Base/Skills/Tower. `SkillEffects` owns bounded presentation parts. Existing combat, projection, HeroRig and persistence services integrate the new definitions.

Schema v4 adds only `data.expansion` to a valid v3 record. Legacy character, party, equipment, currencies and expeditions are preserved; v1/v2 chain through their existing migrations. Unexpected pre-existing expansion data is rejected. All newly introduced mutations use revision checks, receipts, atomic commits and uncertain-save reconciliation. Tower victories use a private server commit entry point rather than public completion packets.

## Validation and limitations

Current suite: 108 tests, including legacy regression and 19 expansion tests covering migration, resource/cost conservation, placement, crafting, all class branches, point/reset rules, ancestry, tower progression and fault recovery, plus every expanded active art and group-support exclusions. Final automated output and Studio evidence are linked from the [test report](PHASE2_4_7_STUDIO_TEST.md).

Animations are procedural poses layered over existing locomotion. Effects include projectiles/slashes, area pulses, guards, healing crosses, draining beams, slow orbs and boss telegraphs. They are functional game feedback, not bespoke uploaded animation clips, finished voice/audio or a completed art production pass. Physical-device, published-client and multiplayer testing remain separate acceptance work.

Detailed contracts: [base and crafting](BASE_BUILDING.md), [classes, skill trees and animation](CLASS_SKILLS.md), [tower](TOWER.md). After this delivery, the next roadmap phase is Phase 3 online activities; publishing and multiplayer rollout have not been performed by this implementation.
