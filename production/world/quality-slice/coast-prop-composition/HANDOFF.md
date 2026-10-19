# Two roadside composition clusters â€” local review candidate

Base: 957f434. Fresh branch codex/coast-prop-composition; previous worktrees preserved. Only the two new coast-prop-composition artifact directories change. Controller owns Studio/Rojo; no runtime activation, upload, push, PR, publish or DataStore operation.

## Replacement packet

Use assets/production/world-slice/coast-prop-composition/scenery.mesh.json as a replacement for the bespoke-spire art dataset, never append both versions. SHA256: f31077a0847a4a5db7a5918a411ee9b9ba22cdb0ac18ec686bc18859e10fc4e9.

All 20 mesh resources, rotations, scales, physics flags and 66 other placements remain exactly equal to the prior bespoke-spire packet (148ba821817101a0372d851f557d4c7593a594295814f0e20da194924adfb3ae). Six existing placement translations change; original 57 prop retention is now 51 exact, NOT 57. This packet still has 72 placements, 11,330 unique / 40,006 instanced triangles, leaving 670 unique triangle headroom. Ground 444 parts, navigation 38 nodes and 58 locked source inputs are unchanged. The third ridge proposal is deferred.

| Existing placement | Final X | Final Y | Final Z |
| --- | ---: | ---: | ---: |
| CorridorScenery_007 | -294 | 4.8366161981 | -178 |
| CorridorScenery_009 | -302 | 4.8194204883 | -184 |
| CorridorScenery_010 | -289 | 4.8626548556 | -168 |
| CorridorScenery_013 | -357 | 5.6674263833 | 179 |
| CorridorScenery_015 | -370 | 5.6407505062 | 169 |
| CorridorScenery_044 | -360 | 5.6127421904 | 155 |

The entry group was moved farther ahead than the first read-only proposal after actual matched renders showed its first coordinates mostly outside the road-eye frame. Same three named props and approach location; sign043 remains unchanged. The revised grouping is visible at walking-eye height and opens the opposite side toward the spire. Coast three props retain their proposed X/Z; low marker, rocks and bush form a foreground group, partially occluded by bridge rails.

## Executed evidence

independent-review-04.json and verify04-exit.json bind the final packet and verifier: exit0, unchanged inputs, 20 exact resources / 66 exact placements / 51 original props. Exact polygon subtraction establishes terrain coverage of complete conservative support rectangles: basal trunk footprint for the tree (canopy is not a contact surface), full mesh XZ rectangle for the other five. Basal-plane burial is 0.12 to 0.142 studs across the six placements. This is offline support geometry, not engine collision or proof that foliage should touch terrain.

Triangle-space checks find zero changed-prop intersections with the preserved road and no private-belt intrusion. Eighteen spire silhouette segment rays against changed props are unobstructed. Unchanged geometry is inherited; these rays do not certify every screen pixel or the entire native scene.

Real Blender 5.2.1 LTS background renders produced three matched before/after views: native_road_eye, spire_reveal and bridge_forward. Identical cameras, lighting, 28mm lens, 1280x800 and 16 samples. Before exit0 (34.52s), final after exit0 (49.32s), immutable-input checks passed. Raw stdout/stderr, including warnings, PNG hashes and editable landforms.blend scenes remain preserved. Schematic City/Greenwood reference boxes are not native geometry acceptance. User's open Blender was not modified.

Original game baseline tools/validate.ps1 passed: 944 tests, Rojo build, strict analysis, compilation, repository/place/sourcemap checks. baseline-validation.log is the unchanged merged raw stream; baseline-validation-note.json records the actual observed process exit and explicitly is not a record_check.py receipt. Existing pinned tools were reused without setup/download. Forge validate, Studio catalog validate and character contract passed. studio.py verify FAILED with pre-existing stale generated manifest/source metadata at base957f434; this out-of-scope condition was not repaired or presented as passing.

## Preserved iterations and limits

iteration01 contains initial packet/render whose entry cluster was off-frame; geometry alone had passed. iteration02 preserves the intermediate root-height correction packet without rendered acceptance. Initial independent-review.json FAIL used an over-conservative whole-canopy terrain coverage model; its verifier source remains preserved. Later reports distinguish basal support from foliage. No failed or superseded reports were promoted to final acceptance.

The coast rock is partly hidden by bridge rails, repeated silhouettes remain elsewhere, and broad slopes remain sparse. No new geometry or blanket tree scattering was added. Native import/comparison and any party traversal regression belong to controller after independent review. Prior controller spire/synthetic-party results do not automatically apply to this new packet. Physical-device, earned gameplay, full-game and human art acceptance are not claimed.

Independent art-review.json status: READY_FOR_NATIVE_COMPARISON_WITH_REMAINING_GAPS. Reviewer inspected and hash-bound all six final PNGs and both render receipts.
