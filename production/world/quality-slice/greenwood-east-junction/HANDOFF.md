# Greenwood east junction candidate

Base: 4c52678. This bounded wave addresses the observed unsupported direct approach from Greenwood arrival (0,1505) to the existing east-road first node (70,1506). The existing alternative through Z1495 worked; this is not a claim that every route was disconnected.

Only WorldQualitySlice.luau, WorldQuality.luau, tests/world_quality.luau and the two new greenwood-east-junction folders are owned. Existing road/mesh packets and native Island/Landing/ArrivalStreetSouth/portal remain unchanged. No HeroService, QuestRoute or state authority changes.

## Geometry and honest width

Widths below are Z cross-sections. The slanted X14..70 span has approximately23.9962 studs perpendicular to its centerline, not an exact24-stud swept strip. Together with the22-stud arrival constraint, uniform24-stud clearance remains explicitly unfulfilled; this is the bounded supported-approach repair with existing portal and road endpoints preserved.

Native Island ends at Z1500, Landing spans X-14..14/Z1500..1526 and its top is Y2. ArrivalStreetSouth spans X-9..9 to Z1509 with top2.08. The old road begins at X70/Z1494..1518 with top2.1. New shared-edge wedge tessellation joins cross-sections X9/Z1493..1515 (22 studs), X14/Z1493..1517 (24), X70/Z1494..1518 (24), all top2.1 and underside1.7. New geometry stays south of Z1493. Native height transitions are at most0.1 stud, street0.02.

The existing portal posts at X+-5/Z1517 obstruct the edge of a nominal24-stud strip centered on arrival. The initial strip is therefore22 studs; the full24 begins atX14. The portal throat itself remains9 studs. This candidate does NOT meet a uniform24-stud clear-width claim from the portal/arrival point. That would require a separately scoped portal redesign. Centerline support alone is not full-width proof.

The original custom stone facing comprises five closed tapered courses, one decorative placement and60triangles, with each course embedded into actual native island and the junction underside. It introduces no gameplay rail/fall protection and has collision/query/touch disabled. Runtime asset IDs remain null.

## Integration

Use the explicit buildGreenwoodEastJunction() preview method; its physical owned model is separate from imported decorative scenery. Existing default construction is unchanged. The controller must require BOTH junction.isReady() and the GreenwoodIronveil route isReady() before opting into activation, and deactivate/unregister travel before destroying the approach. Geometry alone does not add authored local quest navigation. No activation or live persistence is performed here.

## Evidence and remaining gates

Matched before/after cameras include arrival facing east, return from the existing road, overhead junction and landing seam. Both contain the same native Greenwood pieces/portal, reviewed local world-slice artwork and existing east road/art. Only after adds new ground and stone facing. Dynamic actors, GUI and native lighting/material/physics behavior are omitted. Invisible collision-only ArrivalStreetSouth is not falsely rendered as an extra visible overlay.

Forge doctor/validate/plan, studio validate, reconciliation and character contract passed locally. Studio adapter verify failed on pre-existing stale generated manifest/source metadata; raw preflight-1 streams are retained, and adapter files are outside this wave. This does not certify gameplay or tool connectivity.

Independent geometry, runtime tests, fresh baseline, renders and their reviews are recorded separately. Native floor rays, bidirectional walking with five companions, camera/edge behavior, device performance and human art acceptance remain pending with the controller. No Studio or interactive Blender changes, provider calls, spending, uploads, push, PR, merge or publishing in this wave.

## Completed local evidence

Independent geometry run02 passed actual wedge-top polygon coverage (1459 square studs, no gaps or overlapping top interiors), old-road seam, native landing and all five stone-course closures/embeds. It scanned507 candidate triangles from existing reviewed scene meshes for above-floor intrusion; none intersected the walking area. Run01 failed in the verifier helper (quadrilateral passed to triangle clipper); its raw streams remain unchanged.

Both matched Blender runs exited0. Full tools/validate.ps1 passed973 tests, Rojo build/sourcemap, analyzer, compilation and repository validation. Existing analyzer warnings remain in raw baseline streams. A new test-local shadow warning was fixed afterward by renaming that local only; final source hashes and scoped rerun pass168 contract checks,234 mocked lifecycle checks, compilation and analysis in checks.json. No native physics result is inferred.

The visible gap is filled and the tan path continues into the existing road; stone facing appears along its outside edge. Surface detail remains plain and no guardrail/fall protection is introduced. All native/device/human gates above remain pending. Background Blender completed and interactive Blender was untouched.
