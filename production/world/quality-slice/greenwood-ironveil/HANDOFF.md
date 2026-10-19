# Greenwood to Ironveil: second physical route candidate

Base9588cb6, branch codex/greenwood-ironveil-route, fresh worktree. No Bootstrap, WorldService, TravelService or TravelRules edits. Controller owns activation, gate integration and all Studio access. No publishing, production DataStore calls, uploads, push or PR.

## Controller integration

The existing quality initializer now exposes buildGreenwoodIronveilCorridor(). Call it only in the existing standalone Memory preview after both regions exist. buildContinuousCorridor() is preserved. Combine the two returned descriptors through the existing multiroute travel contract; do not duplicate travel services or bypass release gates. Controller gate work a60a10d is a separate integration dependency, not included in this branch.

Route identity greenwood_ironveil_south, Greenwood -> Ironveil. Owned physical Model GreenwoodIronveilCorridor contains108 native WedgeParts (36 colliding road pieces,72 decorative shoulder pieces) and10 consecutive floor-center Vector3Value nodes. Nine bounded occupancy OBBs, both endpoint entries and source-zone recovery anchors are included. WalkWidth24, NavigationPointKind FloorCenter, NavigationBelowFloor4, NavigationAboveFloor14. Existing travel Y0..35 and private MineY100 are unchanged.

The art packet must be imported into a separate sibling Model such as GreenwoodIronveilScenery, NOT beneath GreenwoodIronveilCorridor: exact physical-model readiness deliberately rejects extra children/descendants. Art remains anchored/noncolliding/nonqueryable/nontouching. Decorative rails do not provide fall prevention. Preserve the existing west corridor and its separate coast/spire dataset.

isReady checks owned model/region identity, exact part/node structure, part transforms/size/flags, navigation indices/values and route metadata. route.destroy() cleans only this second Model and allows rebuilding. The parent handle destroy cleans both routes independently. New builder never alters City walls; old west wall behavior is preserved.

## Source-surveyed geometry

Control points (X,Y,Z): (70,2.10,1506), (110,2.10,1506), (180,2.10,1510), (300,2.10,1510), (390,2.10,1500). Tessellation subdivides this into10 nodes, with maximum segment40studs. Native wedge broad faces reconstruct the authored road surface; shoulders are36studs total width, not new walkable land.

The proposed original Z1490 lane intersected actual reviewed East Arrival Waymarker/tree geometry. Moving its beginning toZ1506 clears the complete tree bounds by2.825studs. Greenwood decorative arrival terrain isY2.02 and supplies no collision at the entry; the road supplies its own collision. Ironveil native Island top isY2. The new floor is0.08/0.10stud above these surfaces; engine step/path acceptance remains pending.

Greenwood entry center(80,7.5,1506),size(28,15,24); Ironveil entry center(390,7.5,1500),size(24,15,24). Recovery anchors Greenwood(60,7,1495),Ironveil(400,7,1500) lie on native source-zone islands. Existing west entry center(0,7.5,1510.5),size(28,15,35) remains disjoint and unchanged. source-survey.json records actual asset bounds, native obstacles and hashes; independent verification uses full original vertices instead of the rounded explanatory bounds.

## Executed local checks

checks-final01: actual tools/validate.ps1 baseline exited0,944 tests, Rojo build, analysis/compiler and repository/place/sourcemap checks. The analyzer also emitted existing tests/gui/novice_chapter.luau diagnostic warnings; raw stderr is retained rather than claiming warning-free output.

Source was then normalized only from CRLF to LF to satisfy repository attributes. Exact original raw input snapshots and line-ending-equivalence.json are retained. checks-normalized02 binds final LF sources:60 pure contract checks,153 actual-service source-injected mocked lifecycle checks, compilation and scoped Luau analysis all exited0 with unchanged inputs. Mock Instances prove lifecycle logic, not native physics. No baseline raw stream or receipt was rewritten.

Preflight Forge validate, Studio catalog validate, studio.py verify(98 generated files), character contract and reconciliation passed on this worktree. Tools reused existing pinned binaries. Source changes are limited to WorldQuality.luau, WorldQualitySlice.luau and tests/world_quality.luau; the rest are scoped route/art/evidence artifacts.

## Pending native gates

studio_probe.luau is NOT_RUN. It is controller-only and checks36 road colliders/10nodes,30 width rays and22 bidirectional engine paths including recovery endpoints. It does not move players, grant progression or establish actual five-hero traversal. Root must activate the reviewed descriptors and import the art, then run native floor/path, player+fivehero, entry/exit, blocked-gate, recovery and cleanup checks. Physical device, earned campaign, full-world and human-art acceptance remain unclaimed.

## Final structural art and reproducible inputs

Final packet assets/production/world-slice/greenwood-ironveil/scenery.mesh.json SHA25670690b5109f823a72fd14cd137cfabc3ac0cce29e2ec100cd670eb2c1788dc8e. Runtime descriptor SHA256a2f4c47c2b1438f9df981b3b6716349c13b0bb08f89b15c8d5952001d7bc908e; ground SHA2564a2c026106c7cbb9cfaf532cbcaf059efef7ff1ca0731998b9a846f7dea510c2. Embedded Luau spec exactly serializes that runtime descriptor.

Ten mesh resources /17 placements,5,752 unique /7,618 instanced triangles. Six resources are exact reviewed project assets; four original recipe resources provide deck skirt, stone edges, open arches and woodland rails. The final structure comprises165 closed solids/1,980 triangles plus68 skirt triangles. All remain decorative; no extra physical lane or fall-prevention collider was added.

Three matched before/after Blender cameras: woodland_departure, quarry_arrival, overview. Both final processes exited0 with unchanged input hashes. Editable .blend scenes, PNGs, raw stdout/stderr including warnings and exit receipts are preserved. Scene includes source-reviewed Greenwood meshes and labeled simplified native quarry context; images do not certify complete native visual integration. Final same-camera frames show intentional timber-to-stone bridge treatment; raw quarry blocks, uniform surfaces, empty surrounding context and ungrounded pier footing context remain visual limits.

The independent verifier reconstructs native WedgePart faces without importing the author generator; checks9,225 lane samples, exact old reviewed mesh triangles and conservative source-native obstacle boxes, full13 prop support rectangles, structural lane/strip containment and solid face winding/closedness. No engine PathfindingService calls were made here.

Preserved attempts: iteration-01 contains initial four prop footprint overhang failures; original generation raw streams were not captured and are not fabricated. iteration-02 retains the sparse ribbon art rejected after six actual matched renders. iteration-03 retains the first structural version: independent review found all2,088 faces/174 solids inward-facing, despite visible Blender renders. Corrected final winding and deliberate cart/sign bays pass independent checks. No rejected image or superseded geometry report is final acceptance.

Final independent-review.json: READY_FOR_NATIVE_ENGINEERING_COMPARISON_WITH_ART_GAPS. independent-05-final exit0 binds final packet, six render images/receipts, source retention and local test evidence. No native acceptance has been granted.
