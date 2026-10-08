# Crownford market and tavern — 2026-10-06

Two authored service buildings now replace the shared rectangular shells in Crownford. The same geometry specification produces native Roblox parts and Blender/GLB/FBX assets. Crimson tiled roofs, timber gables, ivory stone, quoin corners, windows, striped market awnings and a tavern sign follow the city reference's palette and architectural vocabulary. These are local architectural studies; they are not a completed reference-matched island.

Source: `assets/uat01/crownford-services-v1/kit.json`. Editable scene: `Guildborne_Crownford_Services.blend`; exports: `Market.glb`, `Market.fbx`, `Tavern.glb`, `Tavern.fbx`. Export pivots are building-local; the Blender presentation scene arranges the pair side by side. Preview and two interior renders are in that folder.

Market: 300 native parts, produce bins, stocked jars and counter. Tavern: 285 native parts, tables/benches, stocked shelf, hearth and counter. Both have plank flooring, wall panelling, ceiling beams and two warm lantern lights. Roof and detail parts are cosmetic; walls, floor, counters and substantial furniture provide collision. Eight-stud entry and central aisle, ten-stud entry clearance, .3-stud floor step. Existing service markers and server rules remain in place. Other five cities still use planning shells at this checkpoint.

## Evidence

- Clean GLB and FBX imports verify every object's bounds, triangle count and collision metadata against exported source geometry. See `roundtrip-report.json`; maximum bounds error is under .0001 stud.
- Isolated Studio path probe: 6 cities, 1,279 parts, 48 successful arrival-to-destination paths with radius 2, height 5, jumping disabled; no profile writes. Synthetic route checks are separate from player walking.
- Fresh `build/Guildborne_CrownfordArchitectureReview.rbxlx`: ordinary WASD movement entered the market, returned outside, walked around the east side and entered the tavern. No teleport, profile grants or gameplay remotes. Final tavern position (-58.287, 3.298, -27.517), health 100, Running state. Console empty; Play stopped. Screenshots: `evidence/crownford-market-walk.png`, `evidence/crownford-tavern-walk.png`.
- Full domain suite: 672 passed, including 5,000-order conservation load. Strict analyzer passed. Compiler initially exceeded the Windows command-line limit; `tools/validate.ps1` now compiles batches of 80 paths. All batches passed. Repository checks passed with 313 runtime sources. Main and Memory-only offline places rebuilt; staging configuration unchanged. Existing extra blank EOF lines in `tests/run.luau` were removed; diff whitespace check then passed.

This fixture demonstrates architecture traversal, not newly repeated market purchase/recruitment acceptance in the full game. Earlier service acceptance remains separate. Mobile performance, human visual approval, final reference likeness and cloud asset publication remain pending.
