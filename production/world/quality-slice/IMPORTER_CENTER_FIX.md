# Runtime roof diagnosis: explicitly center each imported chunk

No further source face changes are indicated. The current source remains mesh SHA256 634a1067f4291d324f09b7b8d7cdcbb2aea748e251701ce6f57dfbc00c37a26d, 27 chunks / 27,452 vertices / 37,074 triangles / 85 placements; all 413 colliders are unchanged.

The controller reports that this exact revision still displays separated stable roof strips and floating sawmill roof segments while the front house looks solid. A read-only capture in this worker session showed the title menu, so it was not treated as a fresh roof observation. The controller's report and prior optimized-world-first.jpg remain the runtime evidence.

## Reproduction and proposed correction

The importer currently inserts shared-asset coordinates without recentering, then translates every chunk MeshPart by mesh:GetCenter(). Source JSON reconstruction with that additional per-chunk translation reproduces the distinctive separated stable roof and floating sawmill roof fragments: roof-extra-center.png. The same geometry at its intended world coordinates is roof-json-after.png. These are diagnostic Blender renders, not Studio acceptance. This single-variable reproduction strongly supports a double-center placement error rather than absent source faces.

Controller-owned file: production/integration/quality-slice/NativeAssetPreview.luau. Make this bounded change before adding each mesh's vertices:

```luau
local low = vector(def.vertices[1])
local high = low
for _, v in ipairs(def.vertices) do
    local point = vector(v)
    low = low:Min(point)
    high = high:Max(point)
end
local originalCenter = (low + high) / 2
centers[def.id] = originalCenter
-- In the existing AddVertex loop:
vertices[i] = mesh:AddVertex(vector(v) - originalCenter)
```

Keep the existing normal calculation: translation does not affect cross products. Keep fixed-size conversion. AFTER conversion, assert mesh:GetCenter().Magnitude < 0.0001 for this dataset. Remove the later assignment `centers[def.id] = mesh:GetCenter()`; it would now overwrite the saved original center with zero. Keep placement unchanged:

```luau
part.CFrame = CFrame.new(table.unpack(def.cframe))
    * CFrame.new(centers[def.meshId] * scale)
```

This explicitly stores chunk-local centered vertices and applies the source center exactly once. All existing center-adjusted expectedArt metadata remains valid. No new asset export, source hash, collider change, winding flip, additional triangle, server behavior or remote is needed.

Roblox's official [EditableMesh RaycastLocal example](https://create.roblox.com/docs/reference/engine/classes/EditableMesh/RaycastLocal) transforms mesh-local hit positions directly through MeshPart.CFrame with Size/MeshSize scaling; it does not add/subtract GetCenter. This supports the coordinate interpretation but is not a substitute for checking actual conversion behavior in Studio.

## Checks and next owner

chunk-center-checks.json records all 54,087 placement vertices satisfying `placement * (center + (vertex - center)) == placement * vertex`, maximum coordinate error 2.2737367544323206e-13 studs. Independent read-only review confirms the math and unchanged expectedArt transforms. Source script compiles. Current source geometry and budget stay unchanged.

Controller should implement this importer-only correction, verify fixed mesh center approximately zero and face/vertex counts retained, then capture the same Studio view. Confirm expectedArt positions still pass, source hash remains 634a1067, roofs align and Memory collision/traversal remains correct. If surfaces still fail after this exact recentering, compare dynamic/fixed face counts and positions before further geometry edits. This worker did not mutate Studio or the importer.

Reproduce the displaced diagnostic with Blender background running roof_diagnostic.py -- --json --extra-center; regular -- --json uses correct world placement.
