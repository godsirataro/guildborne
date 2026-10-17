# Central court / arch ground handoff

LOCAL REVIEW CANDIDATE. No Studio access, push, PR, merge, publish or spending in this wave.

Baseline `9b79d5cde9fced226f795afe01c3bac442985eb5`; final mesh SHA-256 `011091586afb5416cb2c205b2a3db3e6ca36e4e82a79abe5489b24e6385e825d`.

Two existing forest surface resources now meet actual native trail edges, replacing the old 3-stud green margins. Continuous grass/soil/sand mixing forms irregular shoulders and a broader worn arch forecourt that ties the existing arch and paired ivy wings together. Restrained slate crescent details lie in the same flat surface. No randomly scattered props or new raised geometry. Ground remains at Y2.02 over native Y2; road, ramp, resource pockets and BossRise are excluded.

All 35 other mesh payloads (including the previous arrival work), all 116 placement records and all 413 collider records match baseline exactly. No runtime service/source/marker changes beyond regenerated WorldQualityAssets metadata. Adopted controller df69c68's dedicated 200-triangle sign assertion; it remains enforced.

Totals: 37 resources, 32,139 vertices, 44,967 unique triangles, 94,165 instanced triangles, 116 placements. Net increase 1,288 triangles / 744 vertices. Revised surfaces total 2,656 triangles; each has 1,328 triangles and 273/269 used colors, below 2,000 triangles and 320 palette entries per resource.

## Actual evidence

- `central-export.log`: final Blender 5.2.1 background export/render, exit 0.
- `central-initial-render.log`: initial four-view comparison, exit 0; before images retained for final comparisons.
- `central-render.log`: final corrected after-only comparison command, exit 0. Command requires `-- --after-only` after script path.
- `central-renders.json`: exact saved-source/image hashes. Overview camera (105,94,1545) -> (0,4,1410); arch camera (40,22,1435) -> (0,7,1380). Same 35mm lens, 1100x800, 24 samples and stage for both revisions.
- `central-checks.json`: six final commands exit 0, with unchanged raw stdout/stderr encoded as base64. Python compile, complete geometry verifier, importer dry validation, 28 Luau contracts and 19 mocked lifecycle checks, generated Luau compile and type analysis.
- `central-clearance.json`: full 22,346 square-stud supported free area; upward winding, native exclusions, no partial triangle overlaps, preserved baseline artifacts. Old arrival/silhouette/terrain gates run as well; dedicated central check is mandatory whenever forest resources exist.

## Iterations and limits

The initial 92e18f... render passed geometry but was rejected visually for coarse rectangular color blocks. Its raw export/render/check streams remain under `central-initial-*`. Continuous RGB mixing replaced hard palette selection. The unquantized export log remains as `central-unquantized-export.log`; final palette quantization reduces resource color count. One after-only render completed images then exited 1 due a missing command-line `--` separator; its untouched log is `central-render-argument-error.log`. The corrected final invocation exited 0.

Final images show a continuous worn forecourt and softer/irregular road shoulders. Flat ground and visible low-poly color faceting remain. The paired slate detail is deliberately restrained and should not be interpreted as a combat telegraph. This is a bounded composition improvement, not full high-fidelity or all-map completion. Geometry-only clearance cannot prove combat color contrast.

Controller owns final Studio integration. Import exact 011091586afb5416cb2c205b2a3db3e6ca36e4e82a79abe5489b24e6385e825d; verify 116 placements READY, collision/source hash match, both comparison cameras, native terrain material response, encounter telegraph contrast, route/hero traversal and import time/memory. No fresh Studio/runtime acceptance is claimed here; human art signoff remains external.
