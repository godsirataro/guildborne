# Ironveil full-width dock repair

Review candidate based on controller commit 27d2c13ea4de1d9a2764a6cbef142be6918ff432, branch codex/ironveil-full-width-dock. Studio remains exclusively controller-owned. This worker used source tools and a separate background Blender process only. The human has approved the standalone Memory test file; that authorization does not turn local checks into native acceptance.

## Defect and repair

SECOND_EDGE_NATIVE_01.json is retained unchanged: 22/22 engine paths passed, 29/30 route-only floor rays passed. Node10 offset -11.5 had no whole-world floor at (391.269989,2.1,1511.429688), including +0.001 tangent. IronveilIsland ends at Z1510. Old full-width endpoint extended to Z1511.926605.

Move final control point from (390,2.1,1500) to (390,2.1,1495), and Ironveil entry center to (390,7.5,1495), preserving entry size(24,15,24), road width24 and recovery(400,7,1500). New full-width terminal tips lie at Z1506.836727 and1483.163273. Ground, runtime descriptor, original structures and four east prop placements follow the adjusted approach. Existing west corridor, service lifecycle/controller cleanup, travel authority, streaming, activation flags and recovery anchors are unchanged.

Validator now rejects terminal lanes lacking physical Island support over the full24-stud width and one stud before/after the seam. South part minimum Z is1477 (actual shoulder1477.2459); occupancy volume lower bound1479 (actual1479.217697). No planar hit tolerance was expanded. Island bounds come from AdventureMapKit native floor, not the larger travel zone.

## Evidence and limits

Independent checker proves the full continuous docking band along[-5,+10], lateral[-12,+12] is inside the Island with minimum margin2.34128studs. It separately checks6,734 samples in float64 and float32. Old geometry fails267/274 samples respectively; new geometry has zero unsupported samples. These are analytical/source checks, not engine rays. Raw outputs and the checker source are retained.

Updated Blender after views use four cameras and surveyed partial scene context. Separate background render exited0 with input hashes unchanged. Historical before/after renders and raw receipts were not overwritten. New image ironveil_dock_close.png shows overlap; it is not a Studio screenshot. Native terrain footing, actual party traversal, physical-device performance and human art/UAT remain pending. Decorative shoulders and rails are noncolliding; surrounding art remains a prototype.

Old greenwood-ironveil manifest/HANDOFF and raw reports describe the historical pre-repair revision. Original generated geometry/art inputs are archived under ironveil-dock/before; new manifest binds this candidate, including current canonical files. Do not run old render/evidence scripts into their occupied output folders.

## Controller native retest

Build/sync this source into the approved standalone Memory candidate and import the updated scenery packet as a separate sibling GreenwoodIronveilScenery, never beneath the strict physical route model. Keep root-owned integration and cleanup. Use ironveil-dock/studio_probe.luau: preserve all30 original route-only ray results, separately record84 full-width collidable-world support rays before/at/after the terminal seam (including offsetÂ±12, Â±11.5 and outward0.001), and22 bidirectional engine paths. Record hit instance and height. A route-only boundary miss must remain visible even if native Island support makes the whole-world dock safe. Actual player plus five companions and reverse travel remain separate acceptance gates.

No Studio calls, publishing, upload, paid operations, production DataStore access, push, PR or merge were performed by this repair worker.

## Fresh local checks

checks-final01: tools/validate.ps1 exited0 with953 tests, Rojo build/sourcemap, analysis/compiler and repository/place validation. Raw analyzer diagnostics in unchanged GUI fixtures are retained; this is not a warning-free baseline. Contract67 and actual-service source-injected mocked lifecycle155 checks passed. checks-scoped02 separately records contract/lifecycle/compile/scoped analysis exit0 with unchanged final source hashes. checks-probe01 records probe compilation exit0. No runtime probe was executed by this worker.

Independent review is READY_FOR_NATIVE_DOCKING_RETEST; it explicitly leaves parent baseline pending because review occurred before baseline completion. The later immutable baseline receipt supplies its result without modifying that reviewer statement.
