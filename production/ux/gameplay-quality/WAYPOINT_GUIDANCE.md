# Authored next-waypoint guidance

Status: local implementation and source review complete; Studio journey acceptance pending.

Quest navigation now presents a native gold/azure anchored beacon and English/Thai next-step card. The route uses the owned Hall's actual rotated Threshold, island access path, bridge approach and promenade. City routing follows a graph extracted from road centerlines and courtyard connectors. Each next segment is checked for collidable obstructions; absent anchors, disconnected roads and unsupported routes display unavailable guidance. No movement, teleport, currency or quest authority is added.

Regional/civic authored routes and unsupported island-local objectives remain unavailable. This is a deliberate coverage limitation, not a claim that every quest can be navigated. Routes must be accepted against actual world geometry before release. The ray check is not a continuous ground-support proof for arbitrary moved Hall placements.

The card avoids the compact combat roster and map button. Missing character roots or snapshots leave the quest pinned but unresolved; destruction releases callbacks and stale marker anchors are cleared. Independent source review found a respawn sentinel crash, which was fixed and re-reviewed with no remaining source blockers.

Validation: full baseline 896 regression cases, Rojo build/sourcemap, Roblox definitions analysis, Luau compilation and repository checks; GUI simulation 31 cases (12 foundation, 12 gameplay, 7 waypoint). The route suite contains 11 scoped cases within the baseline. Raw final outputs are stored in checks/waypoint-baseline.log and checks/waypoint-gui.log. These are local evidence only.

Controller handoff: walk from the owned Hall through the east bridge and promenade to the city portal; after arrival follow the avenue to Herald. Repeat with moved/rotated Hall, missing/disconnected anchors, an obstructed segment, EN/TH, compact landscape, and pinned-quest death/respawn. Verify native BillboardGui rendering and streamed geometry. Physical touch/performance remains untested. Controller retains exclusive Studio ownership.

The isolated GUI preview is generated with `python tools/build_gameplay_ui_review.py` at build/gameplay-ui-review/GuildborneGameplayUIReview.rbxlx. It contains one LocalScript and no server scripts/remotes, and uses simulated profile data. This gallery is not the world-routing acceptance fixture.
