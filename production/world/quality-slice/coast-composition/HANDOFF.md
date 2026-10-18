# Coast and beacon composition — bounded Studio review candidate

Base508430514a7320ca387409cdf5b0e5b95ee4ccbf (controller integrated asc61d840). Controller reported prior boundedpacket88bd14 native Dataset2 READY_LOCAL_ONLY:63placements/5364unique triangles/0.565709seconds and all anchored/noncolliding/nonqueryable/nontouching. That report applies only to the prior packet. This new packet79e3 has not been imported or tested in Studio by this worker.

## Import target and scope

Replace the controller-owned corridor ART dataset with assets/production/world-slice/coast-composition/scenery.mesh.json. SHA25679e3c3ea39f702ee77d6765ea41d0dffbdbc9cd4a1c674faa1a01832e82f807f. Do not append prior and new datasets;57retained props would duplicate. Keep ground, navigation, gate/landing, existing Greenwood dataset and other maps untouched. Root/controller exclusively owns Studio.

Only new art/evidence subfolders changed. All444ground parts,38nodes, road metadata and runtime source remain unchanged. The58locked source/art inputs passed;94files covered by both historical art manifests remain exact. All57retained scenery placements,7retained mesh resources and original beacon are exact. No additional scatter was added.

## Geometry change

Lower western terrain in the750–1100 bridge sight corridor toward existing beacon(-565,460), with a stepped ravine further along the west side. This exposes the beacon body rather than only its crown. Replace the rectangular L-water outline with a curved bay, shoreline overlap, broad landward terraces and two asymmetric headlands separated by low coves. Northern cap and side corners connect with shared boundary vertices. Terrain adjacent to the road is lowered only; immutable native shoulders remain.

Final budget:17mesh resources,67placements,5676unique triangles,33761instanced triangles. Computed actual resource AND scaledplacement maximum1972.468924913357studs (75.531075native margin); enforcedlimit2000. All new art stays noncolliding/nonqueryable/nontouching; broad visible land does not introduce authorized walking areas. Runtime asset IDs remain null. Existing reviewed CC0 tree resources are unchanged; new sculpt/coast is original procedural geometry. Existing provenance/licenses remain in prior packets/intake, with exact source hash linked by new provenance.json.

## Executed validation and review

run_checks.py records two real subprocesses with raw stdout/stderr, exact input hashes and unchanged-input assertion. Triangle clipping passed1148intersections,0violations, nearest surface0.035stud below preserved walk/shoulder plane. Independent sight test includes all exported art except target beacon and full444native WedgePart/Part geometry:24/24rays clear from route750..1100step50 to beaconY35/65/100. Clear rays do not mean the beacon stays in forward view: heading offset reaches roughly70degrees after the turn near1100. No unprovided native game geometry is included in these offline tests.

Independent reviewer /root/extent_review recomputed retention, transformed bounds, budgets, nonzero triangles (minimum cross-squared3.0627e-5) and northern seam topology. No above-water openedges at the northern cap. Reviewer inspected final overview/native_road_eye/spire_reveal/shoreline and found BOUNDED_READY for native comparison, not final environment approval.

Blender5.2.1LTS actually rendered nine matched BEFORE/AFTER views (18final PNGs), same camera JSON, lens28,1280x800,16samples and lighting. Includes exact controller road eye(-320,11,-250) toward(-323.33,8,-178.33). Both processes exited0; after-render input hashes stayed unchanged. All image, camera, renderer and packet hashes verified. Two editable .blend files retain actual comparison scenes. stderr contains Material/World.use_nodes deprecation warnings, not execution failures.

City/Greenwood context is schematic and existing native ocean outside the packet is omitted. The straight seam atZ-90 is intended to meet existing ocean, and must be checked natively; do not call the schematic backdrop a verified world join. Forestarrival is not evidence of complete native Greenwood presentation. Existing water color/waves/lighting may differ in Studio.

## Iterations and evidence integrity

iteration-01 preserves first geometry-only candidate. iteration-02 preserves shoreline/corner correction candidate; iteration-03 preserves sea-seam correction candidate. iteration-02-render preserves a rejected thin-bank presentation and an input-race receipt: author changed packet while that render was active, so its end-read packet hash is not trusted as exact rendered input evidence. Raw files were not rewritten. STATUS.json clearly excludes that iteration from acceptance. Final after/ was freshly rendered with run_render.py, which checks all input hashes before and after execution; it is the accepted local comparison source.

A stale recipe comment says the narrow private east shelf remains submerged. Actual final geometry peaks atY-10 there, confinedX<=-180; triangle exclusion is the authoritative check. No claim is made from that comment.

## Remaining gates and limits

Native import/readback, native route-eye views alongside actual City/Greenwood/ocean, player plusfivehero normalwalking, memory/frame-time and human art acceptance remain pending for79e3. User authorization permits the disposable Memory file; production DataStores and publishing remain prohibited. No new full-game baseline is claimed because no runtime Luau changed.

Remaining art gaps: large planar facets and bare broad terraces, nearparallel shore strips still engineered-looking, repetitive retained trees, plain sharplyfaceted beacon with bare base, broadflat native shoulders. This bounded wave improves landmark visibility and coast termination; it does not finish high-fidelity polish or the all-world program. Additional location-aware focal grouping was considered but not implemented; retention and terrain composition were prioritized.

Reproduce: python recipe.py; python run_checks.py; python run_render.py --variant before/after from this directory via its full repository path. NumPy is required for the independent sightline test. Never rerun into historical evidence directories. Preserve old reports as historical facts.

Local commit only, then release world-quality-slice sharedv6 lease and hand off. No uploads, downloads, Studio mutation, push, merge or publish performed.
