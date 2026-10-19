# Blacksmith facade — original bounded art candidate

Base e34a2e7; branch `codex/blacksmith-facade`. Selected from actual native `wave9SmithWestFinal.png` and `wave9SmithEast.png`: the new apron props were readable but the large blank wall, shared box-house shell and foundation gap dominated both views. This wave gives only the existing Blacksmith an original stone/timber/vent facade. It is not a population or NPC-motion change.

## Additive import

Add `assets/production/world-slice/blacksmith-facade/scenery.mesh.json` once alongside the current five preview datasets; it replaces none. Packet SHA256 `1e803ebb0bfa131c7c0d2113ce50eb3227fcc82fea1aa9ab56ab94156135cf51`.8new `smith_facade_*` mesh resources/placements,1856triangles,155closed convex solids. Existing27repository mesh packets remain byte-identical; this does not mean all27 are loaded in Studio. No CityKit, CentralCityWorld, anchors, colliders, NPC modules, existing apron, controller build or Rojo inputs were edited. Decorative collision/query/touch remain false; runtime IDs remain null.

Original work: two upper plaster/timber bays with shuttered ventilation panels, end stone quoins, a two-course foundation facing down to grass, east door stone surround and solid gable infill/braces. Louvres are decorative shuttered panels, not new holes in the collision wall. All surface colors export as mesh face colors, without external textures, fonts or paid assets.

## Explicit 3D exception, not the old XZ validator

The old Borin reserve X356..384/Z−972..−944 reaches the building wall and would reject this facade. Controller explicitly authorized a separate narrow 3D exception. `actor-bound.json` records source hashes and all parsed Borin parts. For each part, the conservative radius is the sum of ancestor bone segment lengths, its offset from its bind bone and half its size diagonal. This permits arbitrary joint rotation, beyond actual work motion. HammerHead is limiting at6.096164 above root. Current grass rootY0.3 and fallbackY1 give conservative world maximum7.096164. Root-welded workstation top is3.524 with fallback root, lower than the actor bound. There is no Borin root-motion authoring in this packet.

Upper skin minimumY9.5 leaves2.403836studs above the computed maximum (and1.5 above a rounded Y8 envelope). Skin is bounded to Z−971.54..−971.10, overlapping the actual wall outer faceZ−971.5 by at most0.04stud and projecting at most0.40stud. It is wall-facing detail, not overhead street geometry. Lower end pilasters lie outside the central X356..384 reserve. Foundation facing may overlap that XZ reserve only inside original building footprintX349..391/Z−1029..−971 and Y0.3..1.8. The two exceptions are independently checked per solid; they do not enlarge the general walkable-space allowance.

East door opening remains Z−1008..−992 at X389.5..390.5. Original foundation topY1.8 and lintel undersideY16.5 give14.7stud native clearance. The new validator conservatively forbids new doorway geometry all the way toY20.8. Jambs stay outside the opening; gable startsY20.85. Native road/service station/Rukk positions remain untouched. The actor bound applies only to current native Borin geometry; new rigs, root motion or source changes invalidate it and require re-evaluation.

## Checks and render context

Run `python production/world/quality-slice/blacksmith-facade/build.py`, then `verify.py`. Independent checks cover≤3000total/≤1900per-resource triangle budgets, schema, finite vertices, outward winding, closed convex solids, exact3D exclusions, native/source contact support and unchanged27mesh packets. Source files remain authoritative and are hash-bound. These are offline geometry checks, not native companion navigation.

The before/after render includes the same297 source-reconstructed native context parts and the unchanged apron in both images; only after adds this facade. Four matched1600×900/24sample views and source.blend files are under the new asset folder. Dynamic actors/workstations/UI, distant city context and Roblox materials/lighting are not reconstructed, so controller must inspect native shadows, scale and NPC headroom separately.

| Native retest view | Eye | Target |
|---|---|---|
| Wider wall |365,12,−921|370,13,−982|
| West approach |325,12,−939|369,7,−969|
| Overview |420,62,−903|361,5,−988|
| East entry |434,12,−961|385,6,−991|

Retest Borin work/idle/dialogue, Rukk/forge entry, player+five-companion approach, clipping/backfaces and native camera shadows with all current preview datasets loaded. Inspect the roof/gable junction close up; the render is not proof of a sealed roof. The unchanged roof panels, remaining plain lower wall and broader repeated city architecture remain outside this delivery. No Studio mutation, interactive Blender change, provider call, upload, publish, push or game release occurred. Human art acceptance and city population remain separate pending gates.

Both background Blender renders exited 0. Actual matched images show a readable upper facade and doorway surround, with the original apron visible in both variants. Footing treatment covers only the authored faces; an unmodified side base gap and doorway threshold gap remain. See visual-review.json and the separate independent visual review for observations and limits. Studio remains exclusively controller-owned; the user's Memory-file test authorization is retained for that owner and does not establish a completed playtest.

Packaging note: staged hashes match the manifest. Git whitespace checking reports one trailing space at verify.py line 81. The reviewed verifier is retained byte-identical to its recorded SHA rather than rewriting evidence for cosmetic formatting. Blender stderr contains two use_nodes deprecation warnings for future Blender 6.0; both runs completed successfully on Blender 5.2.1.
