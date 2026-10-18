# Tower native presentation — source review candidate

Base `332bce6`, branch `codex/tower-enemy-presentation`. Original native geometry,
no imported mesh/animation IDs or third-party assets. No Blender used.

## Actual integration route

EnemyService.create calls EnemyProfiles.resolve(floor,index), then the existing
EnemyAppearance and EnemyArticulation modules. Tower floor 5/10 index 1 is Spire
Warden; other even-floor enemies are Echo Archers; the rest are Echo Guards.
Existing positions produce 34 enemies over ten floors: 14 guards, 18 archers,
two wardens. The Warden's existing 1.6 scale remains in EnemyService.

EnemyService, EnemyProfiles, CombatService, stats, rewards, hitboxes, root size,
attack clocks and IDs are unchanged. SkillEffects (including Basic and Fireball)
and ActionPose are unchanged. No new service or remotes.

## Authored presentation

- Guard: layered metal cuirass and greaves over dark fabric, violet tabard,
  framed shield with crest/studs, gripped sword with guard/fullered blade/tip.
- Archer: narrower torso, teal hood/mantle, segmented recurved bow with string,
  rimmed quiver and three individually fletched shafts.
- Warden: broader armor, five-tooth crown and shoulder fins, cylindrical hammer
  haft, pommel, banded head, striking faces and small emissive seal.

Two small visor lights per actor; Warden adds one small hammer seal. No lights,
textures, particles or animated instances are created per frame. Source-derived
art part counts are 60/63/63; with six invisible carriers and the existing root,
totals are 67/70/70. Runtime guard caps art at 78 (85 total). These are source
counts, not measured Studio or device cost. Collision/query/touch stay disabled.

Explicit limb groups attach weapons to hands' arm carriers and the quiver to
the torso. Socket pivots match the authored native geometry. Both overrides are
restricted to SpireForgedV2, nonregional, nonlegacy art; prior BindBone and legacy
goblin routes retain precedence and behavior.

Tower-only motion adds weapon-ready idle poses, eased start/stop gait, heavier
Warden cadence, and distinct confirmed-hit follow-through. EnemyActionAt is
published after server hit resolution, so no fictitious delayed windup is added.
The real TelegraphAt/TelegraphDuration drives Warden hammer preparation; nil or
expired warning releases it. Follow-through expires at .46 seconds and future
stamps cannot mask a valid other impact. DamageCueAt supplies cosmetic recoil;
healing feedback does not. ReducedMotion disables idle breathing. Root transforms
remain authoritative; only Motor6D.Transform is written. Feet/grip fit still need
visual assessment; this is not an imported skeletal clip or foot-contact proof.

EnemyAnimator accepts an optional tag for isolated fixtures. Omitted argument
keeps the canonical tag, so existing callers retain their behavior.

## Checks actually run locally

- Forge doctor, validate and plan: 69 tasks/31 skills valid; tool discovery status
  is not a Studio/Blender connection claim.
- Reconciliation: 502 assets, 73 screens, 89 kit assets, 402 files hashed, zero
  missing references; remaining reference conflicts are review items.
- Character contract: PASS (89 planned assets, 15 required body parts).
- Studio router validate/verify: PASS (33 roles, 69 tasks, 98 adapter files).
- `luau tests/enemy_quality.luau`: two PASS groups, actual asset-selection and
  ten-floor profile compatibility (34 spawn entries), unchanged camp/rewards.
- `luau tests/action_timeline.luau`: six PASS groups, retained Basic/Power Strike/
  Fireball timing contracts.
- `luau-compile --null`: three changed runtime modules, enemy_quality and native
  tower_probe compile successfully.
- Roblox-mapped luau-lsp analysis: three changed runtime modules PASS, no type
  diagnostics. Tool warns watched-file registration is disabled.
- `git diff --check`: PASS. Full combined baseline belongs to controller.
- Independent enemy_export_review inspected Animator and geometry/articulation:
  no concrete blocker. Root separately reviewed the probe. Review is static;
  posed intersections, silhouette quality and grounding remain Studio gates.

## Native probe / art gallery handoff

Install exact source copies in `ReplicatedStorage.TowerProbeModules` in an unsaved
local Studio fixture: EnemyAppearance, EnemyArticulation, EnemyAnimator,
ActionPose, EnemyProfiles and Combat. ActionPose must be Animator's sibling;
Shared VFXConfig and ActionTimeline use actual bootstrap paths. Run
`tower_probe.luau` on CLIENT. It owns a private tag, uses empty space 10,000 studs
above the original camera, restores camera/reduced-motion and destroys fixtures.
The existing canonical animator cannot adopt the unparented/retagged fixtures.

The probe asserts exact art counts, six joints/carriers, welds and weapon groups,
root invariants, 40 profile combinations, movement, confirmed-hit expiry/clear,
replacement, future timestamps, warning expiry/cancel, impact, death, removal,
tag reset and Destroy reset. Optional GALLERY_SECONDS (0..60) exposes a bounded
live gallery at real scales 1/1/1.6 for screenshots. Missed timing windows are
inconclusive, not accepted. No damage/reward or device claim is made.

**Native probe is COMPILE-ONLY / NOT RUN by this worker.** Controller must run
it and inspect silhouettes, overlaps, weapon grips and gait at gameplay distance,
then actual Tower combat and combined baseline. Physical-device performance,
multiplayer, human art approval and release remain pending. No publish, push,
PR, upload, spending or production-data writes were performed.
