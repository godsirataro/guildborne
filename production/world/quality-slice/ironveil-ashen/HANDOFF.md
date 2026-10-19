# Ironveil–Ashen optional corridor and coast replacement

Base `efac81c`, branch `codex/ironveil-ashen-corridor`. This bounded candidate exports geometry and an optional builder only. It does not register or activate a third route, change launch eligibility, touch private campaign gates, or enable streaming. Controller owns registration, authoritative pair admission and selection of the reviewed coast variant. Client route identity is another owner's integration task.

## Floor and descriptor

Route `ironveil_ashen_south`, from Ironveil to Ashen. Floor-center navigation nodes: `(610,2.1,1505)`, `(650,2.1,1505)`, `(750,2.1,1505)`, `(850,2.1,1505)`, `(900,2.1,1505)`. Six anchored collidable/queryable Part floors, thickness 0.4, top Y2.1. Main lane X624..886/Z1493..1517, width 24. Landing pads X596..624 and X886..914, Z1493..1519; their extensions beyond native island Z1510 have real collision. Floor union is 7744 square studs. Native floors remain top Y2, a 0.1-stud seam step requiring native traversal review.

Four occupancy volumes, two region entries, and recovery transforms `(600,7,1500)` / `(900,7,1500)` follow the current descriptor pattern. Independent reconstruction checks the complete floor union, seam support, native-floor recovery and disjoint existing Ironveil entry. The north road edge Z1493 is three studs outside the regional combat bound Z<1490. This clearance is not proof against all dynamic companion drift.

`WorldQuality.IronveilAshenCorridor` supplies the strict spec. `WorldQualitySlice.buildIronveilAshenCorridor()` creates `IronveilAshenCorridor` only when explicitly called, with readiness/tamper checks, idempotent construction and owned cleanup. Existing two corridor data blocks remain byte-identical. WorldService, Bootstrap, TravelRules and client files remain untouched. The new floor has no imported mesh dependency.

## Dataset2 must be replaced, not overlaid

Original `assets/production/world-slice/coast-prop-composition/scenery.mesh.json` remains unchanged. Select the new `assets/production/world-slice/coast-prop-ashen-cut/scenery.mesh.json` in its place when reviewing this route. Importing both retains the obstruction and duplicates unchanged assets.

Only `coast_headland_banks__bounded_003` changes, from 338 to 397 triangles. All 19 other mesh records and all 72 placements remain exact. The authored subtraction is X636..918/Z1489..1523; actual removed surface bounds are X640..844.14644, Y-40..32.92660, Z1489..1523. Eight exposed cut-edge segments receive 48 outward quarry-strata triangles down to the existing bank minimum Y-40. Original terrain is globally open: new cut faces are capped, not a claim that the whole terrain became watertight. No unrelated bank silhouette, old road or Ironveil clearance is intentionally changed.

Replacement SHA256: `3c84bc3a213b8b6b6253cc95957c7a6af0c27d13f789c81f311c0b062a2aefc9`. Ground SHA256: `bd02bb8543cfddea8e33eb543c81c8f135b0549ce8c5a1585151fec88ff74577`. Runtime descriptor SHA256: `0f403a30466ed7279bf4f61c812106a0d61c129169d1489cca1569202f283112`.

## Evidence and remaining gates

Executed source checks: 88 contract checks and 172 mocked actual-service lifecycle checks passed; all three changed Luau files compiled. `tools/validate.ps1` exited 0: 970 baseline tests, Rojo build/sourcemap, type analysis, all-source compilation and repository/build-boundary checks passed. Its stderr retains nonfatal lint warnings, including a local variable shadow in the new test. Source byte identities are recorded in `source-checks.json`. After validation, only tests/world_quality.luau CRLF endings were normalized to repository LF. `normalized-checks/line-ending-equivalence.json` records the author's observed normalization and before/after hashes; the original mixed-ending file bytes were not retained, so independent byte-equivalence proof is unavailable. Fresh compiler/contract receipts bind final source bytes and were independently checked. Original streams and reviewer receipts remain unchanged.

Both background Blender runs exited 0. Independent visual review directly inspected all eight PNGs and verified their input/camera/context hashes. The before bank blocks the route; after shows the opening and continuous road into both pads. View 04 still has substantial foreground occlusion and is not the primary floor-support evidence; the overview and geometry reconstruction provide that comparison. Thin unrailed deck, broad flat cut faces and rough triangular color bands remain visible. This is functional connection geometry awaiting native review, not final environmental art.

Independent geometry receipts reconstruct all six floor colliders and the exact corridor area. Bank checks compare retained source face area/planes/colors/winding, cut-strip coverage and outward caps, all placed Dataset2 geometry including nonqueryable scenery, prior Ironveil/Greenwood-road clearances, and byte identity of all 29 existing mesh packets. These are offline checks. No native five-hero traversal, encounters, streaming, performance or human approval is implied.

Matched Blender comparison includes 91 source-reconstructed native Ironveil/Ashen pieces and portal frames, the existing Greenwood–Ironveil corridor and ore yard. Before uses original coast and no new road; after substitutes the variant and adds exact new floor Parts. Dynamic actors, resource art, UI, private pockets, Roblox lighting/materials and distant city are omitted. Source `.blend`, cameras, renderer inputs and image hashes are retained. Roads are bounded functional connection geometry; bridge understructure, edge protection and environmental polish are not established by these renders.

Required controller work: register builder only in the isolated Memory candidate; select the replacement Dataset2; coordinate TravelRules/Bootstrap/client allowlists; preserve launch Ashen rejection and separate campaign gates; run chained travel both directions, immediate reversal, region entry/respawn/recovery, gate revocation, source deletion, session replacement and player plus five followers. Rendered scenery is noncolliding and does not prevent edge falls. Never treat this optional builder as proof of full-world connectivity or Lv100 completion.

No Studio or interactive Blender mutation, paid provider, upload, publish, production persistence, push, PR or merge occurred in this worker scope.
