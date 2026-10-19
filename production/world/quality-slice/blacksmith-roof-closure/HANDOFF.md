# Blacksmith roof closure — bounded additive candidate

Base: `cf6f2e00046985d1a62f00caf1b4ae6efe90b359`. Branch: `codex/blacksmith-roof-closure`.

The controller's native `refFacadeWest.png` and `refDoorInside.png` show the missing west gable above the rear wall; `refFacadeEast.png` shows the separate apex seam above the existing east gable. This packet addresses both known openings on this Blacksmith only. Source, colliders, anchors and all 28 prior mesh packets must remain unchanged. CentralCityWorld belongs to S17; this candidate does not edit it. Additive import replaces no packet.

The work is original closed mesh geometry using the existing local mesh workflow, with no downloaded assets, textures, fonts, provider calls or paid uploads. Decorative collision, query and touch are disabled. Runtime IDs remain null until actual import. Background Blender is owned exclusively for this wave; interactive Blender and Studio remain untouched.

## Base checks

`studio.py validate`: PASS, 33 roles / 76 tasks / 10 workflows. `forge.py validate`: PASS, 76 tasks / 31 skills, plan-and-skill contract only. `studio.py verify`: ERROR, generated manifest or source metadata stale at the supplied base, before candidate edits. No adapter regeneration or out-of-scope fix is included. These metadata checks do not establish native gameplay acceptance.

## Packet and geometry evidence

Packet: `assets/production/world-slice/blacksmith-roof-closure/scenery.mesh.json`, SHA256 `821b419df0f43fb3d3702be9d11948a703af6c97d2947a315d334a217f2bdae6`. Three resources/placements, 80 triangles, seven closed convex solids. West triangle spans X349.45..350.05, Y20.8..30.6, Z-1028..-972, with four original timber members. Its base overlaps the native rear wall by 0.2 vertically. East repair comprises two convex bands at X389.8..390.35, extending 0.12 vertically into the roof and 0.15 into the existing gable. Its exterior face is recessed 0.10 behind the old gable front; its interior face is offset 0.15 from the old back, avoiding coincident exposed planes.

The independent third invocation passed: all 80 triangle windings, seven closed convex solids, packet indices/bounds, exact rotated roof-box contact, roof silhouette bounds, west rear-wall and east existing-gable contact, doorway exclusion and all 28 unchanged prior packet hashes. First and second invocation failures came from overly broad verifier envelope/door AABB assumptions; the final door check clips actual solid edges into the doorway Z interval. All three raw streams/exits are retained unchanged. See `independent-review.json` and `verify.py`.

## Remaining acceptance

Both background Blender runs exited 0 with matched camera/source context and unchanged apron/facade included in both variants. Parent inspected all six images: west opening is covered by the pale gable and timber; inside no longer shows the former sky opening; east closeup no longer shows the sky sliver over the old gable. Interior is darker under unchanged lighting, so the comparison is not interior-lighting acceptance. Existing crossed roof end geometry near the ridge remains visible and unchanged in both variants; this packet does not repair the original roof-panel overlap. Raw stderr retains Blender use_nodes deprecation warnings; no failed render exit is concealed.

Reproduction: run `build.py` with Python; run `render.py --survey` with Python to refresh the source survey; use Blender 5.2 in background mode with `--disable-autoexec --python-exit-code 2 --python production/world/quality-slice/blacksmith-roof-closure/render.py -- before` and repeat for `after`. Existing evidence should be preserved before any rerun. Camera coordinates are in `cameras.json`; PNGs and `.blend` files are under the asset packet's `before` and `after` directories. The independent verifier refuses to overwrite its report.

Geometry checks and matched Blender comparisons are offline evidence. Controller owns native import, west/inside/east camera review, depth fighting/backface inspection and traversal regression. Prior controller single-player entry and Borin sample results refer to the preceding facade, not this new closure packet. Human art acceptance, five-hero traversal and release remain external gates. No push, PR, merge, publication or production persistence is part of this delivery.
