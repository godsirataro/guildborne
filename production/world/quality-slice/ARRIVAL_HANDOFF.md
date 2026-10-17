# Arrival ground and charter sign handoff

LOCAL REVIEW CANDIDATE. No Studio import/test, publish, push or PR in this wave.

Baseline: `3b5e161082e79826d097a2c8cd55d069843b3c31`.
Source mesh SHA-256: `5185eb847a9ffd2e6caffbe123573f10f4ec91758de732faff8f4cba967d9495`.

The two existing arrival surface resources now cover the supported island, stable apron and landing up to the actual X +/-9 paved lane. The soil/grass wear field softens the old rectangular patches without moving the road or changing collision. A 147-triangle original carved pine sign and geometric lantern at (-14, 2, 1490) gives the arrival street a visible landmark. The lantern has no light instance or runtime behavior.

All 34 other mesh payloads, all 115 prior placement records and all 413 collision records match baseline. One sign placement is added. Total: 37 resources, 31,395 vertices, 43,679 unique triangles, 92,877 instanced triangles, 116 placements. Net increase: 2,255 triangles (unique and instanced), 1,232 vertices.

## Actual evidence

- `arrival-export.log`: Blender 5.2.1 background source export/render, process exit 0.
- `arrival-render.log` / `arrival-renders.json`: four actual saved-source Blender renders, process exit 0; matched lens 35 mm, 1100 x 800, 24 Cycles samples, same stage and lighting.
- Low camera: (40, 12, 1510) toward (-20, 5, 1460). Overview: (105, 94, 1545) toward (0, 4, 1410).
- `arrival-checks.json`: six commands exit 0; Python compile, complete mesh verifier, importer dry validation, 28 Luau contracts plus 19 mocked lifecycle checks, generated Luau compile and type analysis. Exact stdout/stderr retained as base64, including empty streams.
- `arrival-clearance.json`: 3,220 coating triangles; complete 8,816 square-stud supported area, upward normals, road clearance, no exact or partial overlaps. Sign bounds clear stable margin. 824 route/combat sample rays per camera, zero sign intersections. No all-camera guarantee.
- Older terrain and silhouette checkers still run; the two revised surfaces are explicitly delegated to the mandatory arrival checker. Independent reviewer found an optional-check bypass, which was corrected before final validation.

## Visual assessment and remaining gates

The low comparison shows a continuous earth forecourt up to both road edges, replacing the prior rectangular grass/earth cuts, and a readable pine sign in front of the stable. Overview retains the street and building composition. Existing straight cross-path edges and forest-region surfaces remain unchanged; this is a bounded arrival improvement, not all-map polish acceptance. The right foreground building partially fills the low view in both revisions; the camera and building were deliberately kept identical.

Controller owns Studio. Import this exact mesh hash into the Memory-only private preview; verify centered resource placement, all 116 placements ready, collision contract, low-camera composition, walking/hero routes, import time and memory. Roblox uses its own lighting/color conversion, so Blender appearance alone cannot pass that gate. Human art/UAT acceptance remains external.
