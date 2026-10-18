# Woodland roadside settlement presentation

S13 source candidate based on `583ccb3`, branch `codex/regional-arrival-art`, under the existing `novice-entry-art` lease. This is the Novice arrival/courier–training–caravan presentation pass, not regional-world expansion. Prior `corridor/` and entry evidence packets are historical and were not rewritten.

## Material composition change

Removed 40 weak decorative pieces: eight oval road tabs, five training-apron tabs, three caravan-verge tabs, six isolated banks and eighteen small repeated outer ridges. Nine original noncolliding ground parts are now invisible: MainRoad, three northern CrossPaths, TrainingCourt, CaravanCourt, two RescuePaths and RescueRejoin.

Their presentation is replaced by one connected northern road with gentle bends, only the three meaningful destination branches, overlapping rounded clearings, a training equipment shelter, a western wagon waystation and twelve overlapping forest-screen banks. Unused opposite crossroad arms no longer create a northern training-grid silhouette. Existing entry architecture, courier shelter, original route positions, actors and gameplay authority are retained. The southern road segment Z[-194,-5] keeps its original width, color, material and top height; southern crossroads/stages remain unchanged.

All new scenery is original native Roblox Part geometry with native materials. No external asset, font, texture, runtime mesh ID, upload, paid generator or spending was used. Blender previews evaluate the authored geometry; runtime still uses the canonical Luau factory and generated Atomic module.

## Measured budget and contracts

| Measure | Previous candidate | This candidate |
| --- | ---: | ---: |
| Authored BaseParts, including proxies and markers | 564 | 595 |
| Visible source parts | — | 532 |
| Colliders | 61 | 61 |
| Direct route markers | 15 | 15 |
| Static art parts across eight owners | 4,512 | 4,760 |

Forty decorative parts were removed and 71 created: net +31 parts (+248 across eight owners). This is not a measured performance result. Runtime NPCs and service-created instances are excluded from these counts.

All 61 original collider transforms, dimensions, materials, colors and physics flags match the baseline. All 15 markers are exact and remain direct children. Original core geometry is unchanged except the permitted noncolliding ground visibility changes. New scenery is anchored, noncolliding, nonqueryable and non-touchable. Rotated corners stay inside local X±150 / Z±225; 400-stud slot spacing remains unchanged.

The checker preserves original warning footprints and tests six-stud buffers, actor/marker approach margins, courier dodge radius34 and radius24 around the controller-observed training warning center (62.6,94.5). The unchanged probe plans 25 runtime paths, including connected training/caravan legs. These paths were **not executed on this candidate**.

## Ground overlap repair and limitations

The first matched render exposed large dark overlap artifacts because the road and clearing top surfaces shared Y0.04. `diagnostic-coplanar-ground.png` and `after-render-attempt1.*` retain that failed visual attempt.

All 32 new thin ground coatings now have distinct tops Y0.007 through Y0.038 in 0.001-stud increments and thickness0.01. An authoring assertion caps tops at Y0.044, below the original static warning bottom Y0.05. The offline checker verifies exact separation and warning clearance. The underlying supported walk surface is unchanged; coatings do not collide. Final Blender renders were regenerated after this correction.

This removes mathematical coplanarity and the observed Blender artifact. It does **not** prove Roblox GPU depth stability: the controller must inspect close and distant oblique camera views at the real course origin (-4500,0,0), including motion, for flicker/seams. If runtime depth precision is insufficient, further presentation geometry work is required; do not promote Blender success to Studio acceptance.

## Evidence and reproduction

- `before.json` captures the factory at `583ccb3` (564 parts); `after.json` and `runtime.json` capture this candidate (595 parts) with the limited standalone Luau geometry adapter.
- `geometry-check.json` verifies the core contracts, removed tabs, bounds, clearances, unique ground tops and review/runtime parity. The runtime module remains Atomic.
- `check-receipts.json` retains exact commands, exit codes and raw stdout/stderr for sync, geometry checks, Luau compilation, Roblox-aware type analysis and diff checks.
- `before-render/` and `after-render/` contain four matched views, including three player-eye views and an overview, plus editable Blender scenes. These are **Blender source previews, not Studio screenshots**. Runtime actors, prompt labels and dynamic warnings are not included; shading/tessellation are approximate.
- `REVIEW.md` records independent bounded review; `manifest.json` records SHA-256 identities checked against staged Git bytes.

From this worktree:

```powershell
python tools/sync_novice_road_art.py --check
python production/world/novice-entry/capture_geometry.py --git-ref 583ccb3 --output production/world/novice-entry/settlement/before.json
python production/world/novice-entry/capture_geometry.py --source review/NoviceRoadKit.luau --output production/world/novice-entry/settlement/after.json
python production/world/novice-entry/capture_geometry.py --source src/server/Services/NoviceRoadArt.luau --output production/world/novice-entry/settlement/runtime.json
python production/world/novice-entry/settlement/run_checks.py
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background --disable-autoexec --python-exit-code 2 --python tools/blender_crown_road.py -- --geometry production/world/novice-entry/settlement/after.json --output production/world/novice-entry/settlement/after-render --view-set corridor
```

Replace `after` with `before` for baseline rendering. Camera coordinates, lens and resolution are in each `render-receipt.json`. The adapter does not emulate Roblox physics, navigation or full API semantics.

## Next owner and remaining gates

Controller owns Studio and the combined baseline. Integrate the local commit, preserve earned progress and use the established Memory review workflow to create the new factory snapshot; existing courses do not rebuild just because the ModuleScript changes. Run the unchanged explicit-model probe, inspect ordinary E interactions, warning/dodge readability and both caravan branches, then player plus five companions, owner isolation and device/eight-owner performance.

S13 made no Studio calls or mutations in this wave. Earlier controller tests are historical context, not passes for this candidate. Actual Studio navigation, ground-depth stability, dynamic warning visibility, interactions, companion movement, performance and human art approval remain pending. The southern course remains blockout geometry and the supported terrain remains flat; this bounded composition improvement does not finish full-island/high-fidelity or two-round world acceptance. No push, PR, merge, publishing or spending is authorized in this delivery.
