# Woodland Threshold — curated source art handoff

Delivered: 15 real CC0 source FBXs, an editable Blender 5.2.1 composition, actual GLB export, 1400x1400 Cycles camera render and bounded local EditableMesh JSON. Source archives were read-only. No Studio, publishing, upload, spending, production flags, gameplay source or saved IDs changed.

## Art and import

`assets/production/world-slice/woodland-threshold.png` is the final inspected render. The first render exposed white Ruins foliage diffuse materials; final art intentionally replaces those with a face-based leaf/bark palette. This is authored derivative color, not a claim to preserve an unavailable texture. Village material colors remain imported. No source fonts used. Preview ground/water are excluded from GLB and mesh JSON, which contain actual source meshes only.

`woodland-threshold.blend` contains reusable library, authored composition and separately named preview-only stage. `woodland-threshold.glb` contains the composition. `world-slice.mesh.json` conforms to controller schemaVersion 1: 27 chunks, 27,036 exported vertices, 36,867 unique triangles, 68 placements, 68,185 instanced triangles. Each chunk <=2,000 triangles; resources reused across placements. See IMPORT_CONTRACT.md for pivot compensation and actual Greenwood world offset. Geometry is NONCOLLIDING opt-in preview presentation; controller must inspect terrain height, native-art overlap and telegraph readability before runtime adoption.

## Reproduction

1. `python tools/build_world_slice.py` verifies the two fixed archive hashes and extracts only 15 reviewed FBX members plus embedded CC0 licenses from the original local Catalog path.
2. `"C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" --background --disable-autoexec --python-exit-code 2 --python tools/blender_world_slice.py`
3. `python tools/verify_world_slice.py` (Python 3.14 for Zstandard .blend validation).
4. Controller's `tools/import_quality_meshes.py assets/production/world-slice/world-slice.mesh.json` validates the actual agreed import schema. Controller owns the local Studio import.

`intake.json` records exact archive member/source/hash/license and null runtime IDs. `export-report.json` records actual Blender metrics and artifact hashes, excluding active logs. `closed-process-logs.json` seals both Blender run logs only after process exit. The first run and final run logs are preserved. Scripts and source artifacts are reviewable; subprocess success is not human art approval.

## Validation and independent review

Offline validator checks finite coordinates, budgets, indices, face colors, nondegenerate triangles, exact mesh bounds, world placement envelope, source hashes, real GLB payload/exclusion of preview stage, decompressed BLENDER header, PNG signature and output hashes. Controller schema validator passed. Python scripts compile. Independent source/art review confirmed handedness/winding, placement rotation, source licensing and visible real mesh detail. Its live-log hash finding was fixed by excluding live logs and sealing them externally after exit. No further Studio claims follow from this review.

Blender export/render process exited before handoff; no owned Blender process remains. Source/render is ready for controller import review. Studio import, source-world overlap, five-hero traversal with this art, physical-device performance and human visual approval remain NOT_RUN. WORLDGRAPH.md records all-world topology and remaining content gates without inventing level bands or declaring Lv1–100 complete.
