# Original Greenwood gate identity handoff

LOCAL REVIEW CANDIDATE. No Studio access, push, PR, merge, publishing or spending.

Baseline `ba1aaa16b97c74a4f663ccdb2d72f0d2d9510a09`; source SHA-256 `9baaf8de0faf3ff7f4a4f2c32ea692e48aa9dbb021f609e3530029ed7844ddc7`.

The reviewed arch retains every original vertex, triangle, face-color assignment and palette prefix. Original new geometry appends a narrow offset leaf-shaped crown with a pine relief, jade insets and restrained old-gold carving; asymmetric pier panels repeat the same motif. The design ties the arch to the previously authored arrival charter. Existing ivy wings remain untouched. The crown rises 3.5 studs above the old arch and is deliberately offset to preserve sampled combat sightlines. Base XZ footprint and aperture remain clear.

Only the two arch mesh resources change (palette extension in both; geometry additions in chunk 2). All 35 other mesh payloads, all 116 placement records, all 413 colliders and runtime services/anchors remain unchanged. Generated collision metadata updates the source hash and the second arch chunk's art center for its taller bounds. No new collision or placement.

Budget: 300 added triangles and 182 vertices. Arch chunks 2,000 / 1,248 triangles, below 2,000 each; dedicated added-detail budget 400. Complete packet: 37 resources, 32,321 vertices, 45,267 unique triangles, 94,465 instanced triangles, 116 placements.

## Actual evidence

- `gate-export.log`: final Blender 5.2.1 source export/render, process exit 0.
- `gate-render.log` and `gate-renders.json`: eight actual same-camera before/after overview, arch, reverse and wider identity views; 35mm lens, 1100x800, same stage/lighting, source/image hashes; final renderer process exit 0. Overview (105,94,1545)->(0,4,1410); arch (40,22,1435)->(0,7,1380); reverse (-35,22,1325)->(0,16,1380); identity (40,25,1440)->(0,14,1380).
- `gate-checks.json`: nine local commands exit 0 (including final renderer/checker compilation and the repeated geometry verifier after hardening attachment checks); raw stdout/stderr preserved in base64. Python compile, complete geometry verifier, importer dry validation, 28 contract + 19 mocked lifecycle checks, generated Luau compile and type analysis. No full baseline repeated.
- `gate-clearance.json`: original topology prefixes and all other meshes/placements/colliders match baseline, footprint/envelopes/budgets, finite old-masonry XY projection tests, and three sampled depth attachments derived from actual exported old/new triangle intersections.
- Visibility compares added-triangle hits against baseline arch hits for 824 samples from each of three cameras. Zero newly blocked previously visible samples; already-occluded samples are explicitly recorded. This does not certify all cameras or animated telegraphs.

## Iterations and limits

Untouched earlier export/check outputs remain in `gate-initial-*`, `gate-visibility-iteration-*` and `gate-support-iteration-*`. The initial centered crown obscured several previously visible combat samples; narrowing and offsetting it resolved that failure. Pier panels moved outward and their backing was embedded into original stone. A final small narrowing removed an unsupported crown-edge sample. Failed checks are not represented as final PASS evidence.

The original arch camera slightly crops the new crown tip; it remains unchanged for comparison, with the wider identity pair showing the full crown. The reverse face is intentionally plain stone. The arch's large inherited circular outline and wall arrangement remain; this is a small original identity pass, not a full architectural rebuild. Depth attachment checks are sampled, not a whole-volume containment proof. Human art acceptance, Studio rendering/material response, import time/memory and gameplay traversal remain controller-owned gates.

Controller: import exact 9baaf8de0faf3ff7f4a4f2c32ea692e48aa9dbb021f609e3530029ed7844ddc7 into Memory preview, verify 116 placements READY and collision/source hash, the shifted center of arch__001, same-camera motif/silhouette read, return-side appearance, player plus hero aperture and combat telegraphs. Runtime IDs remain null in this source handoff.
