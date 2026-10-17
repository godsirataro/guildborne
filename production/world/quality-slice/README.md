# Woodland Threshold — curated source art handoff

Delivered: 15 real CC0 source FBXs, an editable Blender 5.2.1 composition, actual GLB export, 1400x1400 Cycles camera render and bounded local EditableMesh JSON. Source archives were read-only. This revision adds explicit preview-only collision source; no default bootstrap, publishing, upload, spending, production flags or saved IDs changed.

## Art and import

`assets/production/world-slice/woodland-threshold.png` is the final inspected render. The first render exposed white Ruins foliage diffuse materials; final art intentionally replaces those with a face-based leaf/bark palette. This is authored derivative color, not a claim to preserve an unavailable texture. Village material colors remain imported. No source fonts used. Preview ground/water are excluded from GLB and mesh JSON, which contain actual source meshes only.

`woodland-threshold.blend` contains reusable library, authored composition and separately named preview-only stage. `woodland-threshold.glb` contains the composition. `world-slice.mesh.json` conforms to controller schemaVersion 1: 27 chunks, 27,452 exported vertices, 37,074 unique triangles, 85 placements, 76,994 instanced triangles. Each chunk <=2,000 triangles; resources reused across placements. See IMPORT_CONTRACT.md for pivot compensation and actual Greenwood world offset. Geometry is NONCOLLIDING opt-in preview presentation; controller must inspect terrain height, native-art overlap and telegraph readability before runtime adoption.

## Reproduction

1. `python tools/build_world_slice.py` verifies the two fixed archive hashes and extracts only 15 reviewed FBX members plus embedded CC0 licenses from the original local Catalog path.
2. `"C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" --background --disable-autoexec --python-exit-code 2 --python tools/blender_world_slice.py`
3. `python tools/verify_world_slice.py` (Python 3.14 for Zstandard .blend validation).
4. Controller's `tools/import_quality_meshes.py assets/production/world-slice/world-slice.mesh.json` validates the actual agreed import schema. Controller owns the local Studio import.

`intake.json` records exact archive member/source/hash/license and null runtime IDs. `export-report.json` records actual Blender metrics and artifact hashes, excluding active logs. `closed-process-logs.json` seals preserved Blender run logs only after background process exit. The first run and final run logs are preserved. Scripts and source artifacts are reviewable; subprocess success is not human art approval.

## Validation and independent review

Offline validator checks finite coordinates, budgets, indices, face colors, nondegenerate triangles, exact mesh bounds, world placement envelope, source hashes, real GLB payload/exclusion of preview stage, decompressed BLENDER header, PNG signature and output hashes. Controller schema validator passed. Python scripts compile. Independent source/art review confirmed handedness/winding, placement rotation, source licensing and visible real mesh detail. Its live-log hash finding was fixed by excluding live logs and sealing them externally after exit. No further Studio claims follow from this review.

Blender export/render process exited before handoff; no owned Blender process remains. Source/render is ready for controller import review. Studio import, source-world overlap, five-hero traversal with this art, physical-device performance and human visual approval remain NOT_RUN. WORLDGRAPH.md records all-world topology and remaining content gates without inventing level bands or declaring Lv1–100 complete.

## Historical playable revision v2 (superseded geometry below)

The source orientation audit found inconsistent building face normals (stable 125, house 14, sawmill 2). Blender recalculates normals and evaluates a thin inward solidify shell before export, producing actual back surfaces. This is verified export geometry, not yet proof of corrected Studio appearance.

The stable moves to (-40, 2, 1490), outside the native cross trail at Z1450. Sawmill moves west of the native loop. Road art follows ground Y2 through Z1380, the existing RootAscent ramp to Y6 at Z1355, and the raised forest route. Bridge top is Y6.08. The inspected final Blender render shows roofs, road and forest composition; its preview stage is not native Studio terrain evidence.

WorldQualityAssets and collision.json describe 413 bounded Part/WedgePart colliders, including structural source faces, road supports, bridge deck and a visible stable ground apron. The six physical wedge vertices are checked against Greenwood bounds. No structural collider intersects the center aisle X[-10,10] in the independent offline review; actual avatar/hero collision remains pending.

WorldQualitySlice is opt-in only, guards standalone Studio and Memory persistence, checks imported names/mesh IDs/transforms, hides only direct Greenwood Part decorations named Trunk or Canopy, and restores their four original properties on destroy. Native terrain, markers, portal, travel, resources and private islands remain unchanged. Imported mesh payload hash must separately match the controller import receipt; IDs/transforms alone do not prove vertex payload identity.

Fresh local checks and raw stdout/stderr are in playable-checks.json (REVIEW only). The standalone world contract has 28 checks. Previous checks.json describes the earlier asset revision. Studio lifecycle, pathfinding, player plus five heroes, performance/device and human visual approval remain NOT_RUN for v2. Controller owns those checks. Owned background Blender export completed with Blender quit; an unrelated interactive Blender window remains untouched.

Final independent read-only review reconfirmed all 413 colliders within physical geometry bounds, all 103 expected placements matching current JSON, and continuous split ArrivalStreet coverage. Runtime MeshPart size or vertex alterations still require importer receipt and Studio inspection. No blocker found in that bounded source review.

Final local validation: 890 existing suite tests and 28 standalone world contract checks passed; new Luau modules compile and analyze; Rojo build plus repository/place boundary validation passed (372 strict Luau files). No live runtime acceptance is implied.

## Server/client integration correction

The earlier v2 API incorrectly required client-imported art to exist on the server. The server module now owns only generated collision and native decoration physics; client visibility belongs to controller preview integration. See IMPORT_CONTRACT.md for the replacement API, including recursively frozen reviewedArt metadata. Exports and generated collision data are unchanged. Fresh checks are in server-separation-checks.json. The 19 lifecycle checks execute the actual service source with fake Roblox Instances/services; they prove control flow, not Studio physics. The earlier v2 requirement to import before invoking the server module is superseded.

To reproduce mocked lifecycle checks, embed the current WorldQualitySlice source as a Luau long string in build/world_quality_harness.luau and call the function returned by require("../tests/world_quality") with that string. Run the generated file with Luau CLI. No source rewriting or production dependency injection is used.

Final separation checks: 894 existing suite tests, 28 geometry contracts and 19 mocked lifecycle checks passed. Changed Luau files compile and analyze. Initial analyzer failure from heterogeneous test callback inference is preserved in the first receipt; explicit parameter annotations and passing reruns are preserved in server-separation-final-checks.json. Independent read-only review found no blockers. No Studio or Blender mutation occurred.

## Geometry budget correction

Controller reported v2 failing at Fixed mesh budget unavailable after 7.39 seconds. This worker did not execute that Studio test. Blanket Solidify on stable/house/sawmill accounted for all 37,513 extra triangles versus the first export. This revision removes that blanket shell, retains corrected normals and original source silhouettes, and adds only 207 reversed large structural faces (stable 84, house 66, sawmill 57). These reuse original vertices; no full shell or rim geometry is generated. Identical exported vertex positions are shared within each chunk; colors and normals remain per face.

Current export is 27 chunks / 27,021 vertices / 37,074 unique triangles / 85 placements / 76,994 instanced triangles. Compared with the first successful controller import, unique vertex count is 15 lower, triangle count is 207 higher (+0.56%), and chunk count is unchanged. This does not guarantee EditableMesh allocation; controller must measure the complete combined preview. Chunk placement count changes with building chunks; all authored objects remain. All 413 collider records exactly equal the previous revision. collision.json, WorldQualityAssets, expectedArt and source hash were regenerated together.

Actual Blender export/render completed, final composition image inspected, and independent read-only checks found no blockers. budget-checks.json preserves raw validation output and closed Blender log hashes. Offline mesh/schema/hash checks, 28 geometry contracts, 19 mocked lifecycle checks, and generated Luau compile/analyze passed. The 894-test baseline passed in the preceding server separation commit; no gameplay behavior changes in this export. Studio memory, backface rendering and traversal remain pending for this new geometry.

## Targeted roof/backface correction

Controller reported successful b570 mesh loading (85 placements, 37,074 triangles, 5.3456 seconds) but rejected visible stable/sawmill roof holes. Source review found the roof geometry present and no global coordinate/winding inversion. The 207 large structural backfaces were coincident with the fronts and shared vertices. Reconstructing exact exported JSON chunks in Blender with a backface-transparent shader reproduced gaps in roofs and plaster; this diagnostic is not the Roblox renderer and does not prove the same backend cause.

The targeted correction gives those same 207 backfaces separate vertices and offsets them 0.02 studs inward. All 36,867 original faces, winding and colors remain unchanged. No blanket Solidify, roof replacement, new triangles or collider changes. The result has 27 chunks, 27,452 vertices, 37,074 triangles and 85 placements: 431 more vertices (+1.60%) than b570. All 413 collider records and placement transforms remain identical; regenerated expectedArt and source hash match the new mesh.

The paired roof-json-before.png / roof-json-after.png reconstruct baseline 0e3b07f and current JSON with the same camera position/target (mapped from the controller view) and diagnostic shader. The inspected after image shows continuous visible roof/plaster surfaces where the before image has gaps. Lens/framing/lighting and the preview ground differ from Studio. The earlier roof-cull-before.png and roof-json-cull.png are exploratory narrower JSON diagnostics; preserve their raw logs but use the paired images for comparison. roof_diagnostic.py -- --json --baseline reproduces the before view, and -- --json the after view.

Actual Blender export/render and JSON reconstruction completed. roof-checks.json records passing offline/schema/hash checks, 28 geometry contracts, 19 mocked server lifecycle checks and generated Luau compile/analyze. Independent read-only review confirmed face offsets, unchanged originals/colliders and matching manifests. Studio visual/memory/traversal acceptance for hash 634a1067 remains pending; controller must reimport the current mesh with WorldQualityAssets/collision.json and rebuild its metadata hash gates.
