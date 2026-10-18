# City–Greenwood walking guidance

Implementation based on ac8cd25 in `codex/walking-route-ui`. Read-only contract
verified against controller 05cc819 (S13 geometry and S17 projection).
Shared v6 gameplay-ui-quality lease; no Studio/Blender ownership or calls.

## Behavior

`WalkingRouteContext` reads only the two exact character attribute values
`city_greenwood_west|City|Greenwood` and its reverse, with a living Humanoid.
It validates ordered, finite FloorCenter Vector3Value nodes, identity, width and
height metadata. Native caller passes City geometry: endpoints must lie in City
and Greenwood, rejecting a consecutively streamed prefix without fixing count38.
Each update re-reads metadata; no stale route cache or zone writes.

An admitted route selects the next directed bend inside actual lane and height
bounds. Near bends (4 studs) guidance advances. It never grants admission,
completes quests, teleports or changes CurrentZone. Missing projection/geometry
clears guidance; ready campaign instructions remain intact. Hall-return goals
during an outward crossing keep following the admitted direction until arrival.
Unknown campaign objectives remain unavailable.

Ordinary approach guidance substitutes streamed corridor endpoints for the
City–Greenwood portal leg. City road routing and regional bearing-only semantics
remain unchanged. Missing metadata retains normal portal fallback outside transit.
Manual map selections remain pinned during crossing; only quest guidance consumes
the new route. The map retains guide/clear actions and suppresses false City or
regional position markers, using a neutral transit panel name. No safe-zone claim.

The existing responsive beacon displays localized walking text and a native
compass. Floor-center nodes do not masquerade as BasePart billboard anchors.

## Actual local checks

- `tests/gui/run_walking_routes.luau`: **47 PASS** (8 reader/projection,
  4 quest-integration, 35 existing route/tracker cases).
- `python tests/gui/run.py`: **60 PASS** native-source simulation cases
  (12 design,16 gameplay,14 waypoint,6 tracker,2 lifecycle,10 novice).
  Includes walking EN/TH at796×674 and320×568 with compass clearing on loss.
  These simulations do not measure real font fit or physical device behavior.
- Scoped Roblox-aware Luau LSP: **PASS**, eight files; nine changed Luau files
  compile. Forge doctor/plan-contract validate and `git diff --check`: **PASS**.
- Independent walking_review found incomplete-prefix issue; endpoint-domain
  guard and regression applied, reviewer rechecked: no remaining source blockers.

No full baseline duplicated; controller owns combined baseline and native proof.
Studio/render/TextFits, real clicks, physical-device and five-follower travel are
**NOT_RUN by this worker**. Controller must verify both directions, actual bends,
streaming/recovery, quest changes, portal cancellation, EN/TH small-screen map
and menu coexistence in the integrated continuous-world candidate.

Reproduce with existing `.tools/luau/luau.exe tests/gui/run_walking_routes.luau`
and `python tests/gui/run.py`. `.tools` is an ignored junction to controller tools.
No uploads, paid systems, publishing, push or merge performed.
