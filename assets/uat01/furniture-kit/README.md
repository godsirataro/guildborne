# Guild furniture art kit

Ten original low-poly freestanding prototypes: table, chair, bench, bookcase, rug, banner, planter, lantern, plinth and bed. Authored in studs with ground-centred pivots and even-stud footprints. Source: [generator](../../../tools/build_furniture_kit.py). Native preview: [FurnitureKit](../../../review/FurnitureKit.luau).

99 cuboid parts, 1,188 triangles. Editable [Blender scene](Guildborne_Furniture_Kit.blend), ten FBX, ten GLB, ten transparent PNG icons, [gallery](preview.png), geometry [catalog](kit.json), [export report](export-report.json) and [round-trip report](roundtrip-report.json).

Verification: all twenty exports preserve triangle counts, dimensions and origins through Blender reimport. A disposable Studio check passed3,564 assertions across all ten models and four rotations, including footprints, floor bounds, anchoring and noninteractive preview flags. Zero profile writes; preview destroyed. The source art is noncolliding; the runtime renderer adds conservative collision proxies. Roblox mesh upload/import and final device visual review remain pending.

Now bound to crafting, owned outdoor placement, movement, storage, recycling and new layout slots. See [implementation](../../../docs/uat01/FURNITURE_IMPLEMENTATION.md). Chairs/beds do not implement sitting/sleeping; lanterns have no real light yet. No paid products or game bonuses. Runtime placement checks land, overlap and routes server-side and preserves identity across moves/storage. Indoor surfaces, furniture themes and interactive seating/lighting remain pending.

Rebuild: run `python tools/build_furniture_kit.py`, then Blender background with `tools/blender_item_kit.py -- --kit assets/uat01/furniture-kit --name Guildborne_Furniture_Kit --max-triangles 400 --large-assets --front-view`; verify with `tools/verify_blender_kit.py -- --kit assets/uat01/furniture-kit`. `--front-view` changes presentation only; exports remain at their authored orientation.
