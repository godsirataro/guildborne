# Ironveil ore receiving yard: standalone art candidate

Base ccd40f063b3111d38fde5a18ac70b732b4d102ce. Exact controller-approved admin dependency f7924799eaaefae3199d336052842197e7d3b238 was cherry-picked as f7ba72cbab8c18c22df398ae0944aece417bbeaa. Controller already owns that fix: integrate only the subsequent artwork commit. Sole ledger v8; no runtime/service/road/descriptor changes.

## Contents and integration

Original slate-roof timber weighhouse, copper balances, loading door/loft window, full stone foundation, sorting counter, cargo bins/crates/hoist, retaining masonry, bedrock skirt and visible fractured quarry ridges. Reviewed cart__000/cart__001 and silhouette_ruined_waymarker__000 match the existing CC0 source exactly. Provenance binds recipe, source packet and local village/ruins licenses; no external textures/fonts/downloads/providers/uploads were used.

Import scenery.mesh.json as a separate sibling model, e.g. IronveilOreYardScenery. Never put it under strict GreenwoodIronveilCorridor. All scenery must remain anchored, noncolliding, nonqueryable and nontouching. Runtime IDs remain null. Preserve every existing native map part, crystal, resource, spawn, return portal, mine marker and route anchor. source.blend contains editable Blender geometry; JSON uses RobloxYUp/studs with face colors.

## Evidence

survey.py reads all45 literal native Ironveil parts,5markers and3routes. Checks protect full24-stud visual lane, interaction radii and full encounter leash radii. Existing ascent collider is20studs wide; this package does not widen it. Art envelope X370..630/Z1280..1540/Y-30..40 preserves private pockets beginningY100.

Initial geometry failed on three retaining stones protruding0.01stud into the lane. The failed packet/source/raw report remain in iteration-01 and independent-01. Correction creates positive clearance, not relaxed tolerance. First visual round was HOLD for a floating foundation, blank approach gable, sparse cargo and unchanged quarry skyline; all8images/recipes/receipts remain in iteration-02. Revised geometry closes the plinth, adds loading detail and visible fractured ridges. independent-03 validates477footprints and8,028original outward faces,13resources/placements,10,933triangles with no reported lane/anchor/leash/support/schema/provenance failures.

Four identical cameras compare approach, player_arrival, skyline and reverse. Before/after include all45 native parts with source colors/yaws/wedges, existing bridge and return gate frame/mine marker. Dynamic actors, generated resource art, private pockets and GUI are excluded and identified in render-evidence.json. These are actual background Blender renders of source reconstruction, not Studio screenshots.

Preflight01 preserves inherited adapter-manifest failure. Exact approved admin fix plus canonical LF plan bytes resolved it; preflight02 passed Forge/Studio catalog validation and98adapter files without semantic plan changes. Asset-only delivery uses scoped geometry/schema/provenance/Python syntax/ownership checks, not a claimed new game regression run.

## Pending gates

Final independent visual decision is in independent-final.json. Controller owns native import, dock retest, actual player+five-companion traversal, gameplay occlusion, cleanup and performance. Neither Blender nor analytic clearances grants native/device/human acceptance. Decorative cliffs/rails do not provide walkable support or fall prevention. d974b81 dock native retest remains pending.

Public quarry presentation does not implement private Chapter02 Lv20-35 quests or rebalance public monsters. Ashen35-50, Tower50-65, Crosshaven70-85 and finale85-100 remain separate campaign/world acceptance. Ironveil-to-Ashen and civic-city continuous links are not added here. No Studio call, publication, production DataStore write, paid action, push, PR or merge performed.

## Interruption recovery

On resume, all author/reviewer agents had ended and no worker Blender process remained. The revised before render already had successful raw receipt and all4images; it was preserved. Only the missing after render was resumed in a separate background process. User interactive Blender was not touched.

Final closeout: checks-final01 syntax/whitespace/ownership checks exited0. checks-geometry04 reruns the independent verifier against the final composition metadata (the older independent-03 composition hash was superseded); raw reports remain intact. Final before and after Blender receipts exited0 with unchanged inputs. Blender emitted use_nodes deprecation warnings, retained in raw stderr. Final reverse view has a grounded foundation but the weighhouse occludes much of the bridge; broad native terrace planes remain simple. This bounded package is ready for native art review, not full-city final art acceptance.
