# Ironveil regional pair — original native source candidate

Base `3279e6d`; branch `codex/regional-enemy-art`. No Studio/Blender execution.

## Selection and real integration

Selected existing IDs `quarry_raider` (Melee, RaiderCamp) and `quarry_guardian`
(Boss, QuarryGuardian). These are the regular and elite encounters already used
by AdventureEncounters. Before this change they had 27/25 box parts; the Guardian
had Hammer Fall/Fault Line mechanics but no hammer in its visual template.

Actual route: AdventureScene builds AdventureEnemyKit templates; encounter
preview/session and AdventureCombatBridge attach the shared authoritative combat
adapter and EnemyArticulation. Regional roots are 1×1×1 at ground pivot + Y3 with
PivotOffset (0,-3,0). Tower's height-two convention is not used here. No root,
hitbox, encounter slot/ID, profile, reward, server attack timing, region service,
GUI or travel change. Runtime gates are not enabled by this art change.

## Catalog source decision

Read-only inspection used the actual local 94-item catalog's
`C:/Work/MySelf/Guildborne/docs/Guildborne-Catalog-94/Ultimate Monsters-20261015T191447Z-1-001.zip`.
Fresh SHA256: `61d7144dd8dfa05433e43c48cf3c68edd0a92be218fd29623114056654a79181`,
matching existing acquisition/intake. Embedded CC0 license has the previously
documented mismatched "Ultimate Platformer Pack" heading; existing
`assets/production/enemy-slice/intake.json` records pack-specific provenance review.
No archive script was executed and no file was downloaded for this wave.

Inspected members (not imported or copied into runtime):

| Member under Ultimate Monsters | Local structural evidence | Decision |
| --- | --- | --- |
| Big/glTF/Orc_Skull.gltf | 43 joints, 14 clips, 7,364 triangles; two skinned meshes including Orc_Weapon | Conditional raider donor; existing one-mesh exporter rejects it. Needs reviewed exporter adaptation, retargeting and art approval. |
| Flying/glTF/Goleling_Evolved.gltf | 13 joints, flying clips, no Walk | Does not support the existing grounded Guardian role. |
| Blob/glTF/Wizard.gltf | 4 joints, 9 clips, no Run/Weapon/spell cast | Not compatible with current 43-joint workflow for rune_caster. |
| Big/glTF/BlueDemon.gltf | 43 joints, 14 clips, 5,800 triangles | Technical donor, but demon shape does not preserve armored Ashen identity. |

No ready-to-bind regular/elite pair was identified. This wave therefore authors
original native shapes fitting existing anatomy, rather than substituting an
unrelated imported monster. Blender is not a dependency of this delivery. Future
Orc adaptation requires a separate reviewed multi-mesh job and exclusive Blender
handoff; S13 retains ownership. No runtime IDs are invented.

## Authored art and motion

Raider: layered mining armor, riveted shoulder/forearm protection, reinforced
boots, brow/temple plates, helmet lamp, salvage pouch, wrapped cylindrical pick
haft, socket, pick point and adze. Guardian: larger stepped stone slabs with
retaining metal, knuckle/toe plates, recessed core slit, cylindrical hammer haft,
pommel, clamped head, bevels and broad striking faces. Slate/Metal/Wood/Fabric
separate construction materials. Small Neon lamp/core surfaces use no Light.

The five original Head/UpperArm/UpperLeg pivot records remain exact and first.
Weapons bind to RightHand and thus the existing RightArm carrier. All twelve
original definition blocks are unchanged; only the two selected IDs use the new
local builder. Optional shape/material fields retain old defaults for the other
ten templates. Selected models alone receive IronveilForgedV1.

Animator changes are gated by that style AND the two exact IDs. Raider has a
ready-pick posture and quicker stride; Guardian has a slower heavy stride and
different overhead Hammer Fall / twisting Fault Line preparation. Only valid
RegionalTelegraphAt/Until with CombatState Windup can sustain warning poses.
Expired/cancelled warning returns to ready pose. EnemyActionAt/RegionalImpactAt
start immediate .5s follow-through, not fabricated post-hit anticipation. Future
events cannot mask a valid other hit. DamageCueAt adds .18s recoil; healing
FeedbackAt does not. ReducedMotion removes idle breathing. No root translation,
damage, telegraph geometry or server timing is driven by animation.

## Budgets (source-derived; native counts pending)

| Actor | Art parts | Carriers / motors | Existing root | Total BaseParts |
| --- | ---: | ---: | ---: | ---: |
| Quarry Raider | 63 | 6 / 6 | 1 | 70 |
| Quarry Guardian | 65 | 6 / 6 | 1 | 72 |

Each art part uses one existing articulation weld; builder cap is 90 art parts
(97 BaseParts including carriers/root). One of each Ironveil encounter yields
180 art + 24 carriers + 4 roots = 208 BaseParts, including unchanged Stone Guard
(24 art) and Crystal Shaman (28 art). Existing 90-stud animation cull remains.
No per-frame instances, no new emitters, particles, beams, trails, lights, textures,
audio or VFX allocations. Existing SkillEffects budgets and all other enemies'
animation routes are unchanged. These counts are not device-performance evidence.

## Actual local checks

- New focused harness invokes existing actual AdventurePatterns, AdventureBrain
  and AdventureLifecycle suites plus selected-ID/tuning compatibility: **17 PASS**.
  Initial harness used reference equality and failed a lifecycle table comparison;
  corrected to the repository's actual TableUtil.equal, then all 17 passed.
- Existing enemy_quality suite: **two PASS groups**, including Tower compatibility.
- Both changed runtime modules pass Roblox-mapped luau-lsp type analysis, with
  only the tool's disabled watched-file registration warning.
- Both runtime modules, focused harness and native probe compile successfully;
  `git diff --check` passes. Bridge, articulation, profiles, server patterns and
  SkillEffects have zero diff. No full baseline rerun by this worker.
- Original twelve definition blocks compared against HEAD after newline
  normalization: exact match, SHA256
  `0ebb3a93303a68044d8a233febe769ddeee0c681c675331cc52c35753f3281d2`.
- Independent review of Kit and Animator found no concrete blocker. Root separately
  reviewed native probe. Geometry overlap, grip/feet and visual quality need Studio.

## Native probe / bounded gallery

`ironveil_probe.luau` is a source-copy CLIENT probe for unsaved Studio. Its header
lists exact sibling modules, including BaselineAdventureEnemyKit from `3279e6d`.
It uses actual production factories with a private animator tag, reproduces the
regional bridge root/pivot, compares ten unaffected templates to baseline, checks
counts/welds/weapons/profiles/patterns, and exercises motion, warning cancellation,
expiry, confirmed impacts, damage/heal separation, death/removal/reset/Destroy.
It restores camera/settings and destroys fixtures. Optional GALLERY_SECONDS up to
60 shows both actors from negative Z (their front) at actual source dimensions.

**Probe is compiled only; native execution is NOT_RUN by this worker.** Controller
must inspect grips/intersections/grounding/silhouette and actual Ironveil combat,
then combined baseline. Physical devices, real multiplayer and human art signoff
remain pending. No push/PR/merge/publication/spending or production-data writes.
After delivery the lease is released and this worker stops for controller scope
reconciliation; no new wave is started.
