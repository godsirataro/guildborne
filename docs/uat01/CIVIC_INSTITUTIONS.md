# Six city forges and quest halls

The 12 Forge/QuestHall planning shells have been replaced with authored native geometry, keeping each city's existing building position, route marker and 30 × 24 stud footprint. Every city now has four detailed service buildings: market, tavern, forge and quest hall. This expands local architecture, not the set of gameplay service transactions.

Forges contain an open furnace, flue, ingot bench, tool rack, anvil and open quench vat. Quest halls contain a charter desk, paper/seal, archive books, notice boards and side benches. The central aisle remains 8 studs wide, the doorway 8 studs wide with 10 studs of clearance, and the floor step 0.3 studs. Furniture, floors and walls collide; most roof/detail geometry is cosmetic.

The established six city roof/facade styles are reused. Each `assets/uat01/<city>-institutions-v1/` folder contains the shared part kit, editable Blender scene, Forge/QuestHall GLB and FBX files, exterior/interior renders and clean import reports. Interior review lights follow the authored lantern and ember locations. Full island architecture, final reference fidelity and environmental polish remain pending.

| City | Forge parts | Quest-hall parts |
| --- | ---: | ---: |
| Crownford | 235 | 255 |
| Sylvaris | 255 | 275 |
| Deepforge | 264 | 284 |
| Astralis | 258 | 278 |
| Crosshaven | 239 | 259 |
| Ironroot | 247 | 267 |

Native checks: 7,282 district parts, all 48 synthetic routes with radius 2/height 5/no jumping, and ordinary UI-selected approaches plus WASD entry into all 12 new buildings. Every arrival was within 2 studs of its indoor marker, with health 100. The first fixed-duration quest-hall walk was inconclusive under concurrent rendering load; adaptive ordinary input with read-only position observations then reached all six interiors. No teleport was injected through the test console. The review's explicit city/building buttons reposition only its isolated avatar. Evidence: `validation-civic-institutions-walk.json`.

Main/offline runtime now imports `CivicInstitutionArchitecture` through `CivicServiceKit`; strict analysis, compilation and repository/build-boundary checks passed at 316 runtime sources. The 672-domain-test baseline predates this visual-only batch. Full-game earned travel/repeated transactions, final mesh optimization, device performance and human art acceptance still require testing.

Rebuild geometry with `python tools/build_civic_institutions.py`; use Blender `tools/blender_crownford_services.py -- --city <City> --set institutions` and the equivalent arguments for `tools/verify_crownford_services.py`. `tools/relight_civic_institutions.py` updates Blender lights and review images without changing exported geometry. The walkable review adds city and service selectors in `build/Guildborne_CivicArchitectureReview.rbxlx`.
