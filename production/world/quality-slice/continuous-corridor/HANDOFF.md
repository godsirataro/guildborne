# City–Greenwood western corridor handoff

LOCAL REVIEW CANDIDATE; native traversal, import and human art approval remain pending.
Base fa9ea00; branch codex/city-greenwood-corridor; worktree C:/Work/MySelf/Guildborne-city-greenwood.
Shared v6 ledger only. Scope world-quality-slice. No TravelService, TravelRules, City config, HeroService, WorldService, Bootstrap or production flags changed.

## Integration

The exact API is in ENGINEERING_CONTRACT.md. Existing standalone Studio / unpublished PlaceId0 / GameId0 / Memory-only initializer guards remain:

```luau
local handle = require(script.Parent.WorldQualitySlice)(folder)
local route = handle.buildContinuousCorridor()
city.walkingRoutes = {route}
```

This is explicit and idempotent; normal preview initialization does not build/open the corridor. Result id is `city_greenwood_west`. It returns a Model under GuildborneWorld,37 bounded OBB volumes, source/destination entry OBBs, canonical safeRecovery CFrames and a live geometry `isReady()` callback. Controller owns server eligibility and walking context, source-zone retention during transit, destination entry rechecks, safe correction and recovery. No side effect changes the shape of the existing regions collection.

Only the existing CityWall model at(0,0,-625) is detached during activation, and replaced by a cloned original CityArch (31-stud clear gap). Teardown restores that same wall; when the original town is already destroyed it destroys the detached owned wall. Failures restore state, including injected gate-pivot/floor-allocation failures. Readiness verifies all148 floor and5 gate part parents, anchors, collision/query flags, transforms and dimensions. It is geometry readiness, not permission or art acceptance.

## Geometry and seams

Source audit preserved actual City, guild, novice and private chapter placements. New road starts at GrandAvenue's actual south extent(0,.55,-664), straight through gate toZ-605, then bends west. It bypasses the guild belt at roughlyX-340 instead of joining private plots. All private guild slots start atX0 and grow east; reserved X>=-104,Z[-72,118] remains isolated. Private courts at eastern X/high Y and novice courses atX<=-4500 are untouched.

The full floor centerline is descriptor.json; subdivided walk points, native frames and shared sections are in ground.json. Its length is2567.475 studs. Main clear width24; shoulders84 taper to30 at the City gate and28 at Greenwood. Road/shoulder top triangles are disjoint, shared endpoints exact; no overlapping decorative road plates. Maximum slope1.114%, segment length78.572 studs. Maximum native vertex reconstruction error2.34e-13. Native floats and engine navigation are still separate gates.

New road ends at existing Greenwood Landing south edge(0,2,1526). It does NOT alter protected return portal posts atX±5,Z1517: the remaining9-stud portal throat must be tested with five followers. Existing spawn(0,7,1505) and fallback(0,7,1495), quality street, lodge and encounters stay unchanged. City Guild Zone Warp atZ-680 is also preserved. Shoulders and all imported scenery are noncolliding; only the24-stud road is supported walking space.

Native budget:444 ground WedgeParts =148 road colliders +296 noncolliding shoulder pieces; original cloned gate5 parts gives449 parts/153 colliders on activation.37 OBBs. Expected native probe39 segment paths including both existing approaches (`studio_probe.luau`); NOT RUN here. Ground lives under GuildborneWorld for the existing hero floor ray filter.

## Art and provenance

assets/production/world-slice/continuous-corridor/scenery.mesh.json uses the existing reviewed local-import schema. Controller must import it separately as noncolliding art at the supplied absolute CFrames; native factory intentionally creates only floor and original gate. Existing import_quality_meshes.py validation passed:8 reusable meshes,3026 vertices,3556 unique triangles,58 placements,31641 instanced triangles. Packet SHA25605270148a2a1f3983b0fa1afb26abc288004a674c144233ccd0cacfe6cf79f24.

Five source mesh records are exact copies from the previously reviewed CC0 Catalog packet, with source/intake/license hashes in provenance.json. Bridge-side rails/supports, lookout piers and inward-tapered cliff skirt are original geometry. No new downloads, generator installs, runtime IDs, uploads, fonts or spending.21,401 transformed vertices were audited; scenery remains at least14 studs from route center and violates no western private buffer. The underground skirt is separately excluded from lane-distance measurement.

Real Blender5.2.1 LTS background execution produced corridor.blend and four final PNG views, each inspected. Earlier iterations and raw logs remain preserved. The first iteration lacked a cliff silhouette; the second had varying skirt-depth seam cracks, repaired using shared crosssection depths in final. Blender processes are stopped. City/Greenwood context boxes are explicitly schematic, not imported scene proof. This is a bounded scenic connection, not final all-world environmental approval.

## Validation and review

- Forge doctor/validate/plan, Studio validate/verify, reconciliation and character contract ran:70 tasks,33 roles,98 adapters;502 asset/73 screen/89 planned kit rows. Doctor's PATH-only Blender detection said false; actual absolute Blender binary subsequently ran successfully.
- Full tools/validate.ps1 completed:912 tests,Rojo build/sourcemap,384 strict Luau files and repository validation. Existing GUI-fixture warnings are preserved. This run overlapped final rollback refinements; it is not an exact final-commit full-suite hash claim.
- After final lifecycle refinement:37 pure contract checks +80 mocked lifecycle checks, compile and Roblox-aware type analysis all pass. Exact raw outputs and receipts are included. Mock results do not certify Studio.
- Independent reviewer reconstructed native geometry and reviewed gate lifecycle. Two readiness/rollback findings were repaired and rechecked; native gates remain pending.
- Source probe compiles and import schema validates. No Studio, real player movement, multi-client, five-companion or device performance runs by this worker.

## Reproduce

Run build_ground.py against descriptor.json, then embed_ground.py to update the generated section of WorldQuality.luau. run_checks.py executes the actual service through the scoped fixture and removes its temporary wrapper. Existing local NumPy is not required for ground builder. Blender art_recipe.py accepts --descriptor and --ground; --render runs the Blender-only branch. Review source before execution. Preserve historical evidence or write new receipts for reruns; do not relabel old checks as new acceptance.

Controller acceptance: integrate geometry and art, verify source/readback, call explicit factory only in approved Memory preview, wire authoritative route and callbacks, run39 engine segments, then ordinary bidirectional walking, respawn/recovery, denied entry, and five companions through both retained portal throats. Root owns all Studio mutations. No new PR/push/merge/publish. Stop this worker after local commit and v6 lease release.

Full connected cities and Lv1–100 remain the overall objective. This candidate covers only the first City↔Greenwood seam; Ironveil, Ashen, six civic cities, campaign/private-domain transitions, tower gates, quests, progression and remaining audio/animation/performance/art acceptance require their own source-grounded integrations. Do not expand Greenwood bounds to absorb the private belt or claim this packet completes the world.

Navigation metadata: geometry.NavigationNodes contains38 Vector3Value children named001..038; Value is exact generated floor centerline point, attribute Index is1-based. Model attributes RouteId,FromZone,ToZone,WalkWidth=24,NavigationPointKind="FloorCenter",NavigationBelowFloor=4,NavigationAboveFloor=14. No duplicate inferred curve. Greenwood entry spans35 legal source studs Z1493..1528 and final occupancy OBB extends over that existing landing/street; City entry remains40 legal source studs. Floor/scenery geometry unchanged.

Final independent review confirmed all38 navigation points exactly match generated floor centerline, all444 geometry records unchanged,35-stud Greenwood entry fully inside final occupancy box and40-stud City entry unchanged. Metadata allocation remains inside rollback. No remaining source blockers. Readiness scans153 integrity snapshots per call; controller should measure repeated follower-predicate cost in runtime before considering optimization.

Controller visual review of actual cliffbridge.png: functional corridor but sparse/flat, exposed floating-strip silhouette and repeated trees/rails; NOT final custom-art acceptance. Keep this engineering seam candidate moving. After seam acceptance, broader terrain/coast/water integration, irregular land massing, stronger landmarks and authored transitions remain required. No claim of high-fidelity finished world.
