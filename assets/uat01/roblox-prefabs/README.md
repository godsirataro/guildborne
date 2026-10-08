# Guildborne local Roblox prefab library

88 static model entries across8categories;1576visible parts plus15invisible encounter markers and9review routes. The five weapon-kit models also occur in the30item kit, so88is not a unique gameplay-asset count. Hero/enemy models in this pack are static art; custom rigs/animations remain in their separate Blender/FBX libraries.

Use GuildbornePrefabLibrary.rbxm for the full library, or an individual category pack. Each binary has a readable.rbxmx alternative. Import into ServerStorage as a library, then clone/move the individual model you need: all authored pivots are at the origin, so placing the entire library in Workspace overlays its models. Furniture/maps preserve authored collision; character/item/cosmetic art is noncolliding. No scripts, Humanoids, purchases, prompts, remotes or ownership behavior are included. Map routes store local coordinates and do not automatically transform when the model moves.

## Verification and limitations

tools/build_prefab_library.py builds through Rojo, preserves model origin pivots, and produces hashes in pack-report.json. tools/verify_prefab_library.py decodes all9binary packs, verifies every transform/size/color/shape/collision/material and origin pivot, validates map markers/routes, and rejects any class outside the static model allowlist.3152geometry comparisons include aggregate and category copies.

Direct native Studio file insertion was attempted through MCP but LoadLocalAsset requires RobloxScript capability unavailable to this tool. No permission bypass was attempted. The portable binary/XML round-trip checks passed; manual Studio file-insertion acceptance remains pending. Existing native source-generated templates were separately tested in Studio earlier. No cloud upload or published asset ID.

Format references: [Rojo property serialization](https://rojo.space/docs/v7/properties/) and [Roblox XML model format](https://dom.rojo.space/xml.html). These packs are generated from the project's original authored manifests.
