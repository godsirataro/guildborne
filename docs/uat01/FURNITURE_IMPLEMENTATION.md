# Guild furniture — local implementation, 2026-10-03

Base → Furniture provides ten original craftable decorations with native previews, EN/TH labels and explicit material costs. Crafting creates one owned `f:` record in storage. Placement, movement, rotation and storage preserve that identity without charging again. The initial local capacity is32owned pieces, including stored pieces; this provisional budget still needs physical-device testing. There are no Robux furniture products or paid rights in this implementation.

The first placement surface is opened outdoor build land: the starter eastern area and opened western plots. Furniture uses2-stud movement,90-degree rotation, bounded footprints and server-validated land/overlap/access checks. Furniture participates in the same obstacle grid as Hall and utility buildings. It does not require a door target itself. Building moves cannot overwrite it or block routes around it. Indoor floors, wall mounting, stacked tabletop objects and arbitrary-height placement remain pending.

Craft/place/store/recycle use the existing candidate/save/replay pipeline and owned-island spatial authority. Optional Schema7 furniture fields preserve old profiles. Records are bounded, use canonical unique IDs and reject unknown fields, invalid kinds and positions. Recycle requires a second UI click and returns half of each original material cost rounded down. Failed material-return capacity leaves the original piece intact. Recycling never reuses an ID.

New layout slots capture placed furniture along with Hall and utility buildings. Applying uses only currently owned records and stores extras; recycled references reject the whole application. Older slots without furniture metadata keep current furniture in place and must fit around it. Saving/deleting an occupied slot retains existing confirmation behavior. Furniture themes and final monetization are not implemented.

Native world rendering uses the committed state and removes stored pieces. Each solid piece has one invisible conservative collision proxy; the rug is noncolliding. Visible art is anchored and does not generate touch events. Chairs/beds do not yet support sitting/sleeping, lanterns do not emit a real light and decorative furniture grants no combat/production bonuses.

Evidence:

- 408domain tests, including crafting/replay, repeated ownership, before/after-save uncertainty, storage/rejoin, fine coordinates, locked land, shared Hall access, foreign IDs,32piece limit, malformed state, layout atomicity and recycled references.
- Disposable Studio native fixture:4,012checks across ten models and four rotations, verifying pivots, footprint corners, proxy flags, idempotent sync and store/restore lifecycle. Zero profile writes; fixture destroyed.
- Actual fresh offline UI: GatherResource revision1 earned2Timber; CraftFurniture revision2 consumed exactly2Timber; PlaceFurniture revision3 created chair f:1 at(50,1.02,-30); StoreFurniture revision4 removed it; PlaceFurniture revision5 restored the same ID at(52,1.02,-28), rotated90°. No additional item debit/credit occurred. Debug positioning near the gather node and programmatic UI scrolling were used; craft/place/store commands were real pointer/prompt interactions.
- Art:99parts/1,188triangles, editable Blender file, ten FBX+ten GLB round-trip verified, ten transparent icons. See [art kit](../../assets/uat01/furniture-kit/README.md).

Physical mobile/controller,32simultaneous pieces under multiplayer load, real persistence/reconnect, imported meshes, full indoor decoration, sitting/lighting interactions and human UAT remain pending. Ordinary Staging saves and live commerce remain untouched.

Additional offline UI acceptance: saved furniture layout at revision4, stored the chair at5 and reapplied the layout at6, restoring f:1 to(50,1.02,-30). First recycle click displayed confirmation without a profile revision; second click produced revision7 and returned exactly1Timber.

A32-piece native fixture exposed redundant shared path searches:32calls took39.02ms in one sample. The revised validator checks every footprint and searches each occupied half-island once. Twenty revised samples measured median1.196ms, maximum1.258ms for that same32-chair layout. This measures the furniture route-validation block only, not total save latency or device FPS. Regression cases move each of the32records outside the editable bounds and also test overlap between records.


## Theme finishes — 2026-10-03

All ten owned furniture kinds now accept the same theme rights as Hall/utility buildings, whether stored or placed. Six color/material finishes preserve geometry and collision; Human restores original art, plants/books retain their authored colors. These are finish variants, not sixty separately redesigned meshes. Paid IDs remain zero.

The server applies themes only after durable commit; foreign/missing IDs and unowned themes reject. Theme identity survives placement, storage, layouts and rejoin. No materials are consumed by applying an owned theme. Schema7 adds optional furniture.theme with ownership validation; legacy records default to Human.

Evidence: validation-furniture-themes-domain.txt (413 tests); studio_furniture_themes_probe.luau (2676 checks/60 finishes); studio_furniture_world_probe.luau (4015 checks, preserved model/proxy on theme change and restored theme after storage); studio_furniture_theme_ui_probe.luau (17 checks/6 previews, correct owned-furniture command, paid themes unavailable). Studio fixtures are disposable, with zero real profile writes or remote calls. This is not actual end-user/device acceptance.

Indoor placement, per-theme decorative geometry, imported materials, physical-device performance and human UAT remain outstanding.
