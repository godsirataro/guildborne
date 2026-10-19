# Borin workshop apron â€” additive city art candidate

Base6e6f4c376b3f3596141389165db2e8e171e80034; clean isolated branch `codex/city-workshop-cluster`. The actual native `native-hud-20261020/hud-clearance-recovered.png` shows a large blank Blacksmith sidewall behind Borin. This delivery targets that exact visible area, not a different plaza or new city. The existing rotated Blacksmith pivot is370,1,-1000; photographed wall Zâˆ’972; ground topY0.3.

## Candidate integration

Add `assets/production/world-slice/city-smith-apron/scenery.mesh.json` once as a new decorative dataset. SHA256 `d08edc14a62bd2fc9e1a3fb0e5a6b205df9532358567e19d93a3e22b356bb46f`. It does not replace any existing dataset. All existing26 mesh packet files remain byte-identical.8 new unique `smith_apron_*` resources/placements,2056triangles,150original solids. Collision/query/touch are false under the existing decorative contract; this packet does not add walkable surfaces or gameplay services. Existing building/anchor/NPC IDs remain unchanged. Runtime IDs are null; actual import is pending.

West flank: teal-and-linen canvas shelter, supported workbench, tool rail, hammer silhouettes, vise and ingots. East flank: tiered stock rack, trade pictogram, banded barrels and wheel/chock. These are original small-scale Guildborne meshes using the reviewed existing ore-yard geometry primitives; no new third-party intake, fonts, textures, paid provider or Forge call. All visible colors are exported face colors, not Blender-only materials.

Every vertex remains inside X346..354/Zâˆ’969..âˆ’959 or X386..394/Zâˆ’969..âˆ’959. The full central Borin reserve X356..384/Zâˆ’972..âˆ’944 remains untouched. The east party approach X396..424 has at least2.12studs additional clearance from this composition. Candidate is separated from the rotated foundation endingZâˆ’971 and does not cover the east entrance at390,âˆ’1000, service station, banners or existing landscape parts. Preserve Borin's runtime small workstation/routine when importing; offline renders omit dynamic NPCs and their attachments.

## Evidence and reproduction

`build.py` writes only the isolated new packet, solid inventory, metrics and provenance. `verify.py` independently checks schema, mesh budgets(â‰¤1900triangles per resource,â‰¤4000total), winding, closed convex solids, true geometry contact to ground, safe rectangles, lane buffer and unchanged existing packets. The first support failure and corrected pass are retained. These checks do not replace Studio player/companion pathfinding.

`render.py --survey` reconstructs bounded actual native context from source. Background Blender `--background --disable-autoexec --python-exit-code 2 --python .../render.py -- before` and `-- after` render the same297 context parts, cameras,1600Ã—900resolution and24samples. Source-survey hashes guard against stale inputs. Context includes exact local house rotations/roofs,72 interior parts, nearby roads, market stalls, banners, chimney and landscape. Distant buildings, actors, GUI, native materials and Roblox lighting are omitted. Four matched before/after PNGs and both source.blend files are in the asset directory.

| Native retest camera | Eye | Target |
|---|---|---|
| Smith wall |365,8,âˆ’943|370,6,âˆ’968|
| West approach |325,12,âˆ’939|369,7,âˆ’969|
| Overview |420,62,âˆ’903|361,5,âˆ’988|
| East entrance |434,12,âˆ’961|385,6,âˆ’991|

Controller should import once alongside all current datasets in the Memory preview, inspect these cameras with Borin and his workstation present, test ordinary dialogue approach and east forge entry with player+five companions, and inspect actual native shadows/scale. No Studio mutation, shared build/Rojo write, source runtime edit, push, upload or publishing was performed. This is one static composition improvement: city population, NPC routine quality, broad city polish and human art acceptance remain open.

Visual review: west approach and overview now show a coherent small working/supply frontage; east entry stays unobstructed. The close smith-wall camera is tightly cropped on the reserved center and is not useful as a whole-composition showcase. Original oversized blank wall, foundation gap, broad grass and sparse wider city remain visible; actors/animation are absent. This package does not solve the full lifeless-city complaint.

Background jobs ended exit0. After lease expiry was detected, authoring paused; all worker/background processes were confirmed stopped before the old lease was released and the same task reclaimed for final evidence/commit. No interactive Blender process was closed or changed.
