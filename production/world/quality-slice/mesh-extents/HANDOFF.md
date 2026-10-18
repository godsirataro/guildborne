# Bounded corridor mesh repair

Controller reported actual Studio Dataset2 import of df276a4 failed at NativeAssetPreview:90 CreateMeshPartAsync with mesh extents exceeding (2048,2048,2048), after0.306s. Dataset1 imported116placements/45267triangles separately; that is not acceptance for this packet. Historical failed packet and all prior evidence remain unchanged: cb3171b25c6bd52a24e8a1baa6af5c82c42b0c41127f255e6cb918fcf57da136. The earlier local triangle-budget checks missed resource extents.

## Fix and import target

Use assets/production/world-slice/corridor-landforms-bounded/scenery.mesh.json instead of the failed corridor-landforms packet. SHA256 88bd14ea6272fb1c51baebb220e1845b0949ceaabe23d8e8175c3b39b6d35bee. Replace only the controller-owned corridor art dataset; do not append both versions or touch ground/NavigationNodes/gate/other datasets.

West Z2330.2995133930144 and east Z2200 resources are each partitioned into two spatial chunks using the original triangles. Water already fits at X1700/Z1990 and remains exact. Every resource and scaled placement must be <=2000studs per axis; actual maximum1990 gives58studs native margin. Exact vertex-derived bounds are checked, rather than trusting metadata or checking triangle count alone. An indivisible oversized triangle fails closed.

13resources,63placements,8450vertices,5364unique triangles,33449instanced triangles,1332maximum faces per resource. All palette colors, ordered face coordinates, CFrames, scales and physics flags are preserved. All57 retained scenery placements and7resources remain exact. All new art remains noncolliding/nonqueryable/nontouching. Road metadata and444ground parts are unchanged. No runtime IDs, uploads, publishing or production writes.

## Validation

partition.py checks exact resource and placed-face multisets, metadata preservation, declared bounds, computed native/scale extents, budgets, canonical local importer schema, and rejection of the historical oversized packet. Reproduce with python production/world/quality-slice/mesh-extents/partition.py.

validate_geometry.py is the historical triangle clipping validator redirected to the bounded packet, with its58 locked input hashes retained. Actual execution passed:1040intersections,0violations,closest new surface0.035stud below preserved walk/shoulder plane. Raw stdout, empty stderr and receipt retained.

Independent read-only reviewer /root/extent_review recomputed world-space triangles with ordered vertices, actual RGB, all placement attributes and duplicate counts. Exact33449/33449 equality;57retained placements/7resources; maximum resource and scaled extent1990; minimum cross-product squared5.467136339734127e-06, no degenerate faces. Algorithm review found no blocker for this packet. This is local review, not Studio acceptance.

Blender wrapper renders the fixed packet without regenerating historical source. It records original recipe, partition source, wrapper and packet hashes. Original schematic City/Greenwood context limitations continue to apply. Render receipt reports actual process outcome separately.

## Remaining gates and ownership

Controller owns Studio retry/readback and ordinary walking with five heroes. User confirmed disposable build/Guildborne_WorldConnectivity.rbxlx Memory testing; do not infer production DataStore or publishing approval. Native import, single-sided rendering, runtime performance and human art/UAT acceptance remain pending for this repaired packet. Existing bare slopes, repetitive vegetation and rectangular water edges remain visual-polish gaps. This fix does not complete the two-round entire world program.

No runtime Luau changes; no new full-game baseline claimed. Local fix commit only, followed by v6 lease release; no push/PR/merge in this bounded worker handoff.

Final execution: Blender5.2.1LTS exited0; six PNG views and editable landforms.blend generated from the bounded packet. Overview visually inspected. All six render hashes and wrapper/partition/packet hashes verified. All70 historical manifest files verified unchanged.
