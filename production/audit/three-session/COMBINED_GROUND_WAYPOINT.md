# Combined ground and waypoint candidate — 2026-10-17

Integrated S13 768ae4e as 6e4d38b and S14 77dc881 as d93f4f5 after independent source reviews found no integration blocker. Updated packaging expected-art count to 112.

Fresh Rojo Memory candidate: build/Guildborne_QualityPreview.rbxlx, SHA256 bb22755a4c36e58e2de701d85197b56d4227ddf7595328a82bd21337394eeea4. Opened new Studio instance 18ff56a4-08ef-47af-8ae3-1f5c831dce7b, verified PlaceId/GameId 0, IsolatedMemory flag and exact world source hash before Play. Existing earned gameplay instance remained untouched.

Actual client observations:

- Dataset source 8b4c7aa687d4b265b2e3d7da7c7548aef64f889fd093b9d1219eee094eab1911 reached READY_LOCAL_ONLY with 112 placements, 37,194 mesh triangles and 5.4567836 seconds load time.
- WorldCollisionReady true; collision and art hashes matched. Enemy binding READY_LOCAL_ONLY.
- All ten ground surface instances allocated successfully; observed world Y 2.01999998 and Size.Y 0.00100000005. This resolves the flat-mesh allocation question, not every camera's surface-depth quality.
- Tool screenshot at camera (105,94,1545) looking at (0,8,1430) showed rendered ground patches, foliage and continuous roofs. Screenshot appeared inline; no saved screenshot file is claimed. Flat, sparse overall terrain still falls short of final visual ambitions.
- Actual WaypointBeacon component fixture: English and Thai instructions, destination and distance all TextFits true with ZIndex 6. Screenshot visibly confirmed readable labels and native gold chevron/azure diamond without missing glyph. Fixture used a supplied target, not full CityNavigation traversal; ordinary route, streaming and respawn acceptance remains pending.
- Temporary fixture removed and prior GUI enabled states restored.

Local verification: 17 packaging tests passed. Full tools/validate.ps1 completed exit 0: 897 tests, 381 strict Luau files, Rojo/build/compile/sourcemap checks passed. Raw log remains build/controller-combined-baseline.log. Nine pre-existing Services UnknownGlobal warnings in GUI test harness remain; baseline does not prove Studio/device acceptance.

No runtime assets uploaded, no publishing or production persistence. Further world visual work and complete route verification remain required.

## Actual earned-quest navigation exposed a HUD overlap

After the combined candidate passed its component fixture, copied the exact current CityNavigation, QuestRoute and WaypointBeacon sources into uniquely named client-only review modules on preserved Memory instance a6d25956-416f-4c3b-96bd-8a471f6f9819. Replaced only the old navigation GUI/controller instance. Server, earned profile, rewards and position were not rewritten. This is a presentation hot-patch test, not a claim that this older place equals the fresh combined build. Existing localization remained loaded; this follow-up was English.

Ordinary N key, Guide to quest objective click and guild-menu close resolved the actual WoodlandDebt objective to Inspect the workers' cut timber. The card displayed Destination direction — follow paths and 42 studs. Ordinary W input moved from (-53.1068,5.0480,1430.4711) to (-53.1037,5.0480,1416.5698), increasing distance to 52; S returned near the original position and distance 41. This proves the full controller consumed actual projected quest state and recomputed distance during input-driven movement; it does not prove arrival, safe path or respawn behavior.

Actual full HUD screenshot exposed a defect absent in the isolated fixture: WaypointDirection Visible true, ZIndex 1, absolute (706,216), rotation 146.209 degrees overlaps the right-side Attack button. Destination text fits, but the compass is visually obscured. S14 was assigned a scoped follow-up to put a native rotating compass in a reserved lane inside the navigation card, with full-HUD overlap checks at 796x674 and short landscape. Keep this runtime issue open until its follow-up renders correctly.

Next concurrent work: S13 composing six terrain/embankment meshes under existing world-quality-slice lease; S14 compass fix; S15 Walk forearm seam correction approved only after explicit Blender release; S17 civic-host interaction patch awaits registered scope. Root retains Studio. Latest account usage 69% used, 31% remaining.
