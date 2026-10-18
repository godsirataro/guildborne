# Nonoverlapping novice road floor — controller handoff

Status: LOCAL REVIEW CANDIDATE. Native Studio visual acceptance PENDING.
Base: c39467f68151128dbab78253b0a247a97e525dfe.

The controller reported that the prior 0.001-stud staggered surfaces failed the native ground visual gate at runtime origin -4500: a dashed dark seam at the courier junction and upstream flecks after walking from arrival (`settlement_arrival_walk_v5`). This worker did not inspect that screenshot directly. Historical settlement evidence is unchanged; its 25 engine paths were reported passed for that older candidate only.

This repair replaces 32 overlapping road/clearing shapes with one offline union, simplified to43 boundary vertices, triangulated to41 triangles and represented by82 native WedgeParts. Every top is Y0.045 and bottomY0.015. The wedges disable collision, query, touch and shadow casting. There are no imported meshes, asset IDs, new runtime services or per-frame operations.

Measured from the actual Luau factory via the limited offline adapter:
- 645 parts,582 visible,61 colliders,15 destination markers; eight owners imply5160 static parts, not a performance pass.
- All563 other part records match exactly; independent source diff verifies everything outside the ground block is byte-identical to the base, including all marker text.
- Native reconstructed top area17820.825686 studs²; pairwise overlap2.41e-10 studs² (floating-point noise), intended polygon intersection agrees within1e-6.
- Central lane rectangle X[-12,12],Z[-5,216] is fully covered (5304 studs²);345 other/protected samples covered by generator.
- The source cylinders are approximated with16 segments. Relative to that union, simplification loses466.9314 studs²(2.574%) and adds144.5124 studs²(0.797%). Conservative sampled boundary-distance bound1.99105 studs. This is not an identical footprint claim.
- Minimum planar right-triangle dimension0.65835 studs; thickness0.03. All vertices inside authored300x450 bounds.

Validation: sync exact LF bytes, captured geometry, compile, Roblox type analysis and git diff checks all passed (`check-receipts.json`, raw streams). Independent reviewer reconstructed82 native triangles with maximum vertex error6.07e-13, verified colliders/markers/runtime parity, and checked final UTF-8 text fidelity and emitter idempotence. The review found no remaining source blocker. A transient emitter encoding defect was corrected before final evidence; no corrupted labels remain.

Blender5.2.1 LTS renders are matched source previews, not Studio screenshots. Four before/after camera views and editable blends are included. They omit live actors, dynamic warnings and BillboardGui text. Arrival and training after previews were inspected; floor reads continuous and the static warning remains visible. The native negative-origin camera/walk gate is still required; floating-point seams cannot be certified away with these offline checks.

Controller next steps: integrate exact source, verify runtime hash/readback, run unchanged tests/studio_novice_road_probe.luau against the actual owner model, verify645/61/15 and25 engine paths, repeat ordinary arrival/courier/training/caravan walks and native ground-level screenshots at origin-4500. Inspect courier junction and upstream road for dark seams/flecks, static/dynamic telegraphs, and eight-owner performance as separate gates. No claim of new Studio/pathfinding/device/human acceptance.

Exact SHA-256:
- review/NoviceRoadKit.luau: d6f3fc2fed970a0a16ce1e876f4d3a1a221d4f62c9f46547787b5dfe6d120d0e
- src/server/Services/NoviceRoadArt.luau: 3ccd43ed4baa7b838ad4d188ed7952018adcbe33d830e01023af3730ed6071c4

Reproduce from repository root (Python with existing NumPy required; no dependency installed):
1. `python production/world/novice-entry/ground-union/generate.py --input production/world/novice-entry/ground-union/before.json`
2. `python production/world/novice-entry/ground-union/emit_wedges.py`
3. `python tools/sync_novice_road_art.py`
4. Capture review/runtime with this folder's capture_geometry.py into after.json/runtime.json, then run run_checks.py.
5. Use Blender background render_geometry.py with --geometry before.json or after.json, --output desired folder, --view-set corridor (absolute paths accepted).

Provenance: original project geometry and original local union/triangulation code; NumPy is used for distance computation. No external art, fonts, imports or uploads. No publishing, spending, production DataStore writes, push or merge. Local commit only. Stop after handoff and lease release; do not claim city-zones or start another wave. Controller will reconcile authoritative travel/zone/respawn/companion contracts before City-to-Greenwood work.
