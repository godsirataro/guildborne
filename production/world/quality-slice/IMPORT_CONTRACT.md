# Local mesh import contract

schemaVersion 1, agreed with controller proposal. `meshes`: id, vertices (Roblox Y-up studs), triangles (1-based vertex triplets), colors (sRGB RGB 0..1), faceColors (1-based per triangle). `placements`: meshId, name, cframe (12 Roblox components), scale [1,1,1]. No texture or uploaded asset dependency. Each chunk <=2000 triangles; IDs stable by source asset/chunk. Multiple placements reuse mesh resources.

Each asset is centered in X/Z with ground pivot Y=0; chunks retain that shared pivot (do not independently recenter). MeshPart creation may internally center mesh bounds: preserve vertex positions using EditableMesh resource semantics or compensate by the chunk bounds center if the import mechanism recenters. Compare resulting world AABB to exported placement bounds before acceptance. No guessed asset IDs.

Geometry file: assets/production/world-slice/world-slice.mesh.json. Placements use actual Roblox world coordinates with previewWorldOrigin [0,2,1410] inside Greenwood. Blender/GLB composition remains around local origin for editing; the JSON already includes that offset, so do not add it again. This is an opt-in art preview requiring visual overlap/occlusion review against native Greenwood, not a production replacement. All imported presentation parts must remain anchored, CanCollide=false, CanTouch=false, CanQuery=false. Existing game colliders, travel gates and server authority remain unchanged. Blender preview stage is excluded from JSON/GLB export. Runtime import and Studio visual acceptance are pending controller evidence.

## v2 explicit collision API

First import the current JSON into GuildborneWorld.QualitySourceArt using the reviewed controller importer; the folder must have LocalPreviewOnly=true. Validate receipt source SHA256 a6fed50575aa16a4572c8904bc312af9a0de64aa6332b9d532b548fbf9463d7d. Then, in a standalone Memory Studio server only:

```luau
local handle = require(game.ServerScriptService.Server.Services.WorldQualitySlice)(workspace.GuildborneWorld)
-- Read handle.colliders, handle.hiddenDecorations and handle.sourceMeshSha256.
-- Restore prior decorations and remove owned colliders:
handle.destroy()
```

The module expects 103 imported chunk placements and creates 413 static colliders under Greenwood.WorldQualityCollision. It performs no import itself and has no bootstrap caller. Repeated invocation returns the same active handle. Preexisting unowned collision folders fail before decoration mutation. Keep the handle for teardown; destroy does not remove imported art. Studio behavior is still pending controller verification. Do not use the earlier 27-chunk asset with this revision.
