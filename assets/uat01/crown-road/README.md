# Crown Road / Chapter 00 environment prototype

Original 300 × 450 stud planning scene for the six Novice chapters. Its flat, spacious layout tests traversal and station placement; the richer concept illustration remains an art direction target.

- Seven editable Blender groups: landscape, courier/gate, training yard, caravan fork, crossroads arena, five disciplines, abandoned Hall.
- 104 visible block primitives / 1,248 triangles; 15 invisible route markers bring the native model to 119 parts.
- `Guildborne_Crown_Road.blend` retains the assembled scene. Seven component meshes plus one combined scene have FBX and GLB exports (16 files). Their shared origin preserves assembly. Native XYZ maps to Blender X,-Z,Y at one unit per stud. Do not infer final importer scale without a Roblox import check.
- `geometry.json` records native position, size, color and collision intent. Mesh exports require authored collision settings on import; native boolean metadata is not an imported Roblox collision configuration.
- `preview.png` is a Blender render, visually reviewed after correcting overlapping caravan path paint. `studio-hall-interior.png` is an unedited actual Studio capture.
- Standalone ArtReview includes an E travel pad at (-64, .2, 65), with Crown Road centered at (0, 0, -1200). The return pad is at (10, .2, -986). Review-only persistent streaming keeps this small board available; no production streaming policy is implied.

Fourteen native paths from arrival passed with AgentRadius 2, AgentHeight 5 and jumping disabled; lengths 97–409 studs. Actual E entry and nine normal-speed character-navigation destinations passed with 100 health. Navigation may automatically jump around props; the no-jump claim applies only to the native pathfinding fixture. The first gallery pad was outside the floor and was moved before successful entry.

All 16 exports passed import round trips with preserved triangle counts, bounds, origins and materials. This is environment review, not quest/trial/boss gameplay, finished terrain/art or a published map. NPCs, real encounter logic, interactions and release-device acceptance remain unbound.

Evidence: `docs/uat01/validation-novice-road-native.json`, `docs/uat01/validation-novice-road-live.json`, `roundtrip-report.json`. Source: `review/NoviceRoadKit.luau`, export tool: `tools/blender_crown_road.py`. Concept/prompt: `assets/uat01/generated/guildborne-crown-road-v1.png`, `assets/uat01/CROWN_ROAD_PROMPT.md`.
