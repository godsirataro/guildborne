# Walk forearm loop correction — 2026-10-17

Status: authored/exported and numerically verified; new Studio motion acceptance
and human art approval remain pending. This supersedes only the measured Walk
endpoint defect in the original export, not grounding or combat acceptance.

The retained CC0 Tribal/Monkroose glTF rotation channels already differ by about
6.899 degrees at the Walk endpoint. The exporter now copies that action to
`Guildborne_Walk_ForearmLoop` and authors only `LowerArm.R` rotation at frames
25–30. A spherical cubic segment over frames24–30 uses source incoming/outgoing
angular directions; original `Walk` remains in the saved Blender file. Original
glTF, atlas and license bytes remain unchanged. This is a Guildborne-authored
correction to licensed source animation, not an original creature/model claim.

## Exact preservation and results

The independent verifier compares against commit `967dc71`. Geometry, topology,
binds, weights, all translations, unrelated bones/frames and the other six clips
are identical. Walk remains one second with31 endpoint-inclusive samples.
No runtime selector, attack telegraph, server timing, collision or asset ID changed.

| Metric | Scout | Captain |
|---|---:|---:|
| Corrected maximum endpoint vertex error (studs) | 0.000000899 | 0.000001667 |
| Foot-weighted vertices, all31 frame trajectories unchanged | 445 | 438 |
| Maximum final-six angular step (degrees) | 2.650234 | 2.650114 |
| Final angular step (degrees) | 0.929981 | 0.929928 |
| First angular step (degrees) | 0.317391 | 0.317382 |

All49 sampled Blender evaluated bounds per actor agree with independently
reconstructed skinning within0.000002178 studs (31 Walk frames plus18 samples
across six other clips). Endpoint closure does not prove velocity continuity:
LINEAR-baked samples still change angular speed near the seam. Existing below-zero
geometry minima are unchanged; no planted-foot/grounding repair is claimed.

Initial verification rejected sub-microstud right-finger local differences caused
by recomputing inverse matrices under the changed parent. The exporter now retains
original unowned local samples and asserts actual authored unowned components
differ by less than0.000002 before canonicalization. No verifier threshold was
relaxed. Final Blender bounds independently check the resulting export, including
all corrected frames. Raw successful render/export logs are retained; the first
verification failure is documented here rather than counted as a pass.

## Review artifacts and reproduction

Each actor review directory contains the authored `source-review.blend`, final
`weighted-mesh.json`, inspection data,81 hashed artifacts,30 raw Walk frames per
view, two90-frame animated WebP previews (three cycles,3 seconds), and a contact
sheet of frames24–29,0,1. Views named front/side are oblique review views, not
orthographic anatomical reference views. Contact-sheet inspection shows complete
characters in frame and a continuous pose sequence; temporal feel still requires
playback review. No Studio/device playback is claimed.

After obtaining both Forge leases and an explicit stopped-worker Blender handoff:

1. Run Blender with `--background --factory-startup --disable-autoexec
   --python-exit-code 1 --python tools/blender_enemy_slice.py`.
2. Run Blender with the same flags and
   `--python production/integration/enemy-quality/render_walk_review.py`.
3. Run `python production/integration/enemy-quality/package_walk_review.py`.
4. Run `python production/integration/enemy-quality/verify_walk_correction.py
   --output production/integration/enemy-quality/walk-correction-verification.json`.

`-- --export-only` skips still rerendering when only numerical export diagnostics
change; it requires already current pose/loop images. Run packaging last to hash
all nested review frames. Pillow and NumPy were already installed; no packages
or external scripts were installed.

Fresh baseline `tools/validate.ps1`:890 tests, Rojo, strict analysis, compilation
and repository boundaries passed on this worker branch. Source verifier accepted
both retained sources and rejected13 malformed fixtures. Forge plan validation,
reconciliation and character contract passed. Studio router validate/verify failed
because this older worker's routing adapters do not cover the newly synchronized
v4 plan tasks; those unowned files were not changed. Controller must run its current
integrated baseline. This routing failure is separate from asset verification.

Controller owns next Studio probe: load exact new export, review3+ Walk loops at
gameplay distance from both sides while moving/turning, then Walk→Idle/Hit/Death,
telegraph visibility and death/respawn. Keep existing server authority and grounded
pivot handling. Runtime IDs remain null and acceptance flags remain false.
