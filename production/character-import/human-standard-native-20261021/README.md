# Human Standard wearable and motion prototype

Source candidate: `71984291b4afb97fbe6ed455776f8b0070d891d2`.
This closes a bounded local prototype, **not** the shared-character foundation
or the game's art acceptance. No production renderer, profile schema,
appearance entitlement, live flag or imported asset ID was changed.

## Concrete change

Human Standard's existing source tunic and trousers now remain on the
articulated preview. Their single-influence triangles are partitioned into
nine bone-bound mesh segments, preserving all556 triangles, UVs, normals and
materials. Unsupported Heavy fit, robes, mixed weights/triangles and mismatched
source hashes reject explicitly. These are rigid source shells, not accepted
layered clothing or cages.

`LocalActorPreview.Attach(actor, selection)` uses the same existing candidate
for a player or hero, client-only in unpublished Studio PlaceId0/GameId0.
Its independent noncolliding visual root follows the real actor. It does not
replace the actor's Humanoid, movement, combat identity, equipment or physics.
A bounded cosmetic walk driver moves source elbows/knees independently.
The ordinary appearance renderer never calls this adapter.

The first two-actor attempt ran out of EditableMesh memory. Both failed
receipts are retained, with complete cleanup observed. The repair shares
immutable fixed mesh backing: two models retain50 logical mesh references
using25 actual EditableMesh allocations. Each still has separate MeshParts,
transforms, colors and joints. The last owner releases the backing.
Canceling an in-flight adapter build invalidates its ticket; cleanup completes
when the outstanding engine build returns, not by interrupting that operation.

## Native observations

Owned Studio: `f291dbaa-f592-422b-adc2-cf15a90e0173`.
The previously archived R6 three-road synthetic lab was reused; its ordinary
bootstraps are disabled, Memory policy is enforced, and no earned profile is
loaded. This is a mixed test fixture, not a claim that every script in Studio
matches candidate7198429. Eight relevant modules, including the generated
geometry and rig, matched current normalized source length/Adler32 before Play;
local SHA256 fingerprints are preserved in `native/expected-sources-v2.json`.

- Native garment probe:15 body meshes,15 preview motors,9 garment segments,
  556 garment triangles; unsupported Heavy rejected. Two independent models
  share25 backing resources, and releasing either retains the other's data.
- Actual player and owner-matched `a:Warrior` HeroService model used the same
  Human Standard selection. Roster/class eligibility is synthetic.
- 140 ordered samples across8.398 seconds record adapter-reported horizontal
  travel of23.483 studs for the player and22.234 for the following hero.
  These diagnostics filter position corrections; they are not sums of sampled
  root positions. Both retain CombatHealth57.
  Both show independent elbow/knee angle variation; the left-knee Euler-X
  spans are0.618 and0.620 radians. These samples are not continuous foot-contact,
  natural gait, combat animation or latency acceptance.
- Original22 player parts and45 hero parts retained tested size/physics
  properties. The six original hero Motor6D bindings remained unchanged.
  The player uses a different joint representation: the recorded original
  Motor6D count is0, not an assertion of15 original player motors.
- All nine garment welds per model matched their body-part transforms with
  zero measured position error at the stationary check. That does not prove
  seam quality, cloth deformation or weapon contact throughout the walk.
- Three remove/re-equip cycles retained50 references/25 backings.
- Player detach left the hero active with25 references/25 backings. Destroying
  a preview knee (first run) and the hero preview root (second run) cleaned up.
  Replacing the local player's Character while the old model remained in
  Workspace also cleaned up. Final references/backings/pending/handles are0.
- Final server report records0 reward callbacks,0 profile writes,0 combat
  commands and no client inspection model visible to the server. Play stopped
  and the owned Studio returned to Edit.

The unpaged pair trace returned `[Complex Table]`; that limited response is
retained. Seven20-row pages are the actual140-sample evidence. The first
single-player trace has120 samples and is preserved separately.

## Local and cloud checks

Full original validation on unchanged7198429 passed973 tests,398 strict runtime
Luau files, compilation, analysis, Rojo build/sourcemap and repository checks.
Receipt: `aa4b60637902452aa92bd6d21e79dcba`.
The focused25 geometry/backing-lifecycle checks passed in recorded run
`89ef61104c7b4887ad0f2e2390c771fb`. Raw streams, including empty files, remain
unchanged. Source reviewers found and required fixes for frame-failure and
character-replacement cleanup before this native run.

Local Blender5.2.1 LTS inspected the existing hashed Standard source with
auto-execution disabled:15 closed, UV-bearing, weighted body meshes passed
the repository's structural audit. Input source hash stayed
`d2d0c49d61f811715553fb7aa898a001edf03c2aa4ccf45756e017ab90247226`.
No model edits or regeneration occurred.

The authorized cloud coordinator separately reports Blender4.3.2/inspector
v0.1.1 on the immutable GLB at71f4c44:111224 bytes, SHA256
`db2370d83f1535326f72e88d27539cd1297433d42f3023b522c4e3effaf5785e`,
15 meshes/1648 vertices/884 triangles/2 materials/16 bones,0 failures,
0 warnings and13 not-tested checks. Before/after hashes matched.
Its raw report remains on cloud; `native/cloud-reported-summary.json` is an
attributed report, not fabricated local raw evidence. Do not repeat this
unchanged-input structural check. The cloud QA ZIP itself has not been
reviewed or executed locally because no supported Library ZIP read route
was available.

Cloud attachment empties were parented to the armature object, not individual
bones. That observation alone does not prove a defect. Native grip/socket
motion and contact remain the next inspection target.

## Quality gates still open and next deliverable

The screenshots are explicitly **not accepted art**. Existing player hair and
hero wardrobe/equipment remain visible and overlap the source preview. The
faceless base, silhouettes, clothing seams, weapon grip, feet and attack
retargeting need work. The adapter is a local inspection tool, not onboarding
or production appearance activation. It does not implement gender variants,
Elf/Orc/Dwarf, Heavy clothing fit, persistent save rollout, multiplayer,
physical devices or human approval.

Next bounded deliverable: define which legacy cosmetic meshes must be hidden
and exactly restored without hiding equipped weapons; inspect the actual
source-derived grip frames through movement and one existing attack, then
bind a reviewed actor renderer/creator path. S17 owns the shared appearance
design, S15 motion/equipment fit, S14 creator UX, Controller authority and
native integration. The current v1 schema still has no gender field; no
gender is inferred from Standard/Heavy or assigned to legacy profiles.

Manifest covers47 raw/derived evidence files,719604 bytes, excluding this
README, manifest and `.gitattributes`. It does not convert review evidence
into human art or release approval.
