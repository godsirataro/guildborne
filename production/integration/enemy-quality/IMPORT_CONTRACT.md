# Greenwood enemy art import contract

Existing identities: `greenwood_scout` (Melee) and `forest_captain` (Boss).
Source: Quaternius Ultimate Monsters, Tribal and Monkroose, CC0. Retained source
bytes and license are in `assets/production/enemy-slice/source`; intake SHA and
source metrics are in `intake.json`. The archive's license heading names another
pack; the author pack page confirms Ultimate Monsters is CC0. No Cinderlore files
are included. These are stylized creature candidates, pending human art approval.

## Authority and lifecycle

Keep AdventureScene, AdventureCombatBridge, RegionalCombat and
AdventureEncounterSession as encounter authority. Keep stats, collision roots,
spawn markers, owner/session attributes, reward ledger and respawn rules.
`EnemyVisualAssets` is disabled/unbound. No runtime asset ID or import success is
implied. Do not install an extra combat service or substitute render contact for
server damage. Existing native art remains until real import is verified.

The pure selector uses a caller-supplied generation identity; discard all local
death observation/playback keys when the model is removed/replaced. Feed server
clock time. Reuse playback keys, seek to the returned absolute event offset, and
stop on nil/removal. `DamageCueAt` is damage-only; `FeedbackAt` includes healing.
On death hold the authored final pose after the clip ends. Clear event state on
respawn, suspension and owner/encounter replacement. Moving loops require a
consumer playback clock; offset zero is not an instruction to restart each frame.

Basic attack damage currently happens before EnemyActionAt. Therefore Weapon and
Punch are inspection candidates, not bound attack animations. Telegraph and
confirmed impact have no assigned clip until contact is inspected and timing
fits the authoritative windup. Preserve existing warning geometry and cancel it
when the server leaves Windup. No fabricated contact marker is provided.

## Prepared Blender exporter

Run `tools/blender_enemy_slice.py` only with both the enemy file lease and the
exclusive enemy-blender-window lease, after explicit world-worker handoff.
Use background factory startup and `--disable-autoexec`. It imports retained glTF,
samples real source skeletal actions at 30 FPS, checks source timing, exports
weighted geometry and pose review images, and saves the imported scene. A Python
syntax check does not establish Blender execution or successful deformation.

Expected output per actor: `review/<id>/weighted-mesh.json`, `inspection.json`,
pose PNGs, `source-review.blend`, `hashes.json`. Existence and hashes must be checked
after the Blender process exits. JSON status is export-only, not Studio acceptance.

Weighted-mesh schemaVersion 1:

- `vertices`: positions in studs, Roblox Y-up, base at zero; scout height 5,
  captain height 7 (visual dimensions only, no change to collision/hit range).
  The retained model faces +Z. Apply the declared 180-degree model/root yaw when
  attaching beneath a Roblox -Z-facing combat root; rotate mesh and bones together.
- `triangles`: 1-based vertex indices; `cornerUV` retains original texture UVs.
- `bones`: parent index (0 means root), model-space bind and parent-local bind,
  CFrame arrays `[x,y,z,r00,r01,r02,r10,r11,r12,r20,r21,r22]`.
- `weights`: one list of `[boneIndex,weight]` pairs per vertex, maximum four
  influences, normalized. Do not reduce to a single rigid bone.
- `clips`: FPS, source duration, loop flag and frame arrays of per-bone rest-to-
  pose local delta CFrames. Last sample includes the endpoint.
- `colors`/`faceColors`: sampled atlas color per triangle for local preview;
  full texture fidelity requires the retained atlas/UVs. No texture upload occurs.

Controller owns Studio import. Use existing local EditableMesh review capability
only if available, respect engine limits and dispose handles on replacement.
Create bones in parent-before-child order (or resolve parent indices explicitly),
set all vertex influences, and verify rest pose before playing source frames.
Do not run the existing six-Motor6D native adapter over the skinned mesh.

## Required acceptance

Source verification and pure Luau tests are local checks. Blender evaluation,
visual inspection, Studio import, animation playback, actual combat cancellation,
death/respawn, rewards, multiplayer ownership, streaming and physical mobile
performance each need separate evidence. Real runtime import IDs remain null
until an authorized import exists. Human art/UAT/release approval remains external.
