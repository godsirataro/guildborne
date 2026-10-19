# Ironveil quarry edge closure — bounded art candidate

Base: controller7f392a5, which includes the142c1f9 clearance repair. World worktree reconciled with that base before authoring. Controller owns Studio/Rojo and interactive Blender; this wave used its explicitly assigned background Blender window only. No client/server changes, shared build input writes, provider calls, uploads or new PR.

## Replacement Dataset2

Replace `assets/production/world-slice/coast-prop-composition/scenery.mesh.json` in the combined preview; do not append another Dataset2. New SHA256: `8743e160609a44e48b80e81b9ff0fe21b043bfb7e69fa216f2d164149c7f6760`. Previous: `0a2dd8468029be8c7e9f829666be1413bd9d450b12a25f45beaec2c230480296`.

The previous clearance removed the bank over the yard but exposed a floating/open underside around the surveyed cut. This candidate adds original cool-gray quarry strata on21 exposed boundary segments, down to Y−14. Broad beds at Y0/12/26/42/60 echo the native Ironveil quarry rocks. The boundary stays exactly on the existing city/approach envelope planes; no scenery enters their interiors. No displacement of the reviewed bank or route occurs. Faces point toward the reserved open area.

Only `coast_headland_banks__bounded_003` gains geometry:182→338 triangles,156 additions. All old vertices/triangles/colors/face colors remain exact prefixes;19 other meshes and72 placements are unchanged. Dataset2 remains20 mesh resources with11595 unique /40271 instanced triangles, leaving405 unique-triangle headroom against12000. Physics flags, ground, ore-yard and bridge are unchanged. Runtime IDs remain null.

## Reproduction and evidence

Run `python production/world/quality-slice/ironveil-quarry-edge/recipe.py`, then `verify.py` from this checkout. Recipe binds exact integrated upstream commit/packet and archives original bytes and provenance. This is the final Dataset2 generation stage; the historical clearance recipe alone will recreate the open boundary.

Independent review tests all21 exposed boundary strips, nondegenerate faces, inward winding, no protected-interior overlap, schema/bounds, budget, exact old-data preservation and five historic obstruction rays. Two failed extraction attempts are retained alongside the final pass; the correction handles edges that cross mask corners without a vertex there. Offline geometry and renders do not prove native gameplay or human art acceptance.

Four before/after views include actual45 native Ironveil parts, existing ore yard, existing bridge, return portal and full Dataset2. Same cameras,16 samples,1280×720,32mm lens in both variants. Native retest cameras (Roblox coordinates):

| View | Eye | Target |
|---|---|---|
| Approach |365,10,1497|449,12,1468|
| Player arrival |486,8,1507|455,12,1468|
| Skyline |465,51,1570|500,13,1392|
| Reverse |515,17,1444|442,10,1484|
| Controller regression |500,48,1535|436,8,1468|

Native owner should inspect these views and skirt joins from both sides with all datasets loaded, verify route/player-plus-five-hero clearance, and check no backface gaps remain from accessible views. The decorative bank is not a watertight closed solid and carries no collision authority. The existing rectangular platforms, simple quarry composition and undressed exterior transitions still need broader art review; this wave does not claim whole-region polish, human approval or UAT completion.
