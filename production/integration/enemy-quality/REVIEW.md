# Enemy quality slice — local review

## Delivered

CC0 Tribal and Monkroose source assets are retained byte-for-byte with atlas,
license, SHA256 and intake metrics. They are candidates for existing
`greenwood_scout` and `forest_captain`, not new encounter/reward identities.
Blender 5.2.1 imported both rigs and sampled seven source actions at 30 FPS.
The other seven source actions remain in the retained glTF and Blender file.

| Candidate | Vertices | Triangles | Bones | Source clips |
|---|---:|---:|---:|---:|
| greenwood_scout / Tribal | 4,792 | 6,620 | 43 | 14 |
| forest_captain / Monkroose | 3,495 | 5,824 | 43 | 14 |

Exported action samples: Idle 31, Walk 31, Run 18, Weapon 27, Punch 27,
HitReact 19 and Death 24. Endpoints are included. These are real source skeleton
poses, not generated placeholder motion. Pose PNGs show selected instants;
they are not a video or proof of temporal motion quality in Roblox.

## Executed checks

- `tools/validate.ps1`: passed; 890 existing tests, Rojo build/sourcemap,
  analysis, compile, repository checks. Studio acceptance remains separate.
- `tests/enemy_quality.luau`: passed; unbound IDs, finite timestamp handling,
  duplicate observation, cancellation, generation/removal/death/respawn and
  damage-versus-healing behavior.
- `tools/verify_enemy_slice.py --self-test`: passed one valid fixture and rejected
  13 malformed fixtures; both retained glTF files match intake SHA/metrics.
- Actual Blender import, action sampling, evaluated geometry bounds, pose render
  and scene save completed. Export receipts are per-actor `hashes.json`.
- Independent read-only review reconstructed hierarchical poses and weighted
  skinning for 42 samples (first/middle/end of each clip, both actors).
  Maximum bounds error: scout 0.000001393 studs; captain 0.000002178 studs,
  against a 0.0001-stud tolerance. This validates sampled export consistency.

Review corrected import FPS ordering, healing incorrectly triggering HitReact,
hash manifest self-inclusion, and excluded importer-generated custom bone display
shapes from mesh export. Initial failed Blender attempts are not counted as
successful runs; retained logs cover the two successful render runs. Final review camera fits sampled animated bounds
to avoid clipping the fallen captain's hand.

## Pending acceptance

No Studio import, runtime IDs, controller activation, contact marker verification,
continuous animation playback review, mobile/performance/multiplayer acceptance,
or human art approval is claimed. These external CC0 creatures have not received
custom modeling changes. Their fit with the final Guildborne art direction and
the captain's Antler Cleave/Root Burst presentation remains a review decision.

The pure selector remains `Enabled=false`, `Status=UNBOUND`. Existing native art
and authoritative combat/reward behavior remain active. Controller owns the next
local Studio import and adapter implementation; see `IMPORT_CONTRACT.md` for the
weighted geometry/pose schema, source facing and lifecycle requirements.
