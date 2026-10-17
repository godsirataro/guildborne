# Local mesh import contract

schemaVersion 1, agreed with controller proposal. `meshes`: id, vertices (Roblox Y-up studs), triangles (1-based vertex triplets), colors (sRGB RGB 0..1), faceColors (1-based per triangle). `placements`: meshId, name, cframe (12 Roblox components), scale [1,1,1]. No texture or uploaded asset dependency. Each chunk <=2000 triangles; IDs stable by source asset/chunk. Multiple placements reuse mesh resources.

Each asset is centered in X/Z with ground pivot Y=0; chunks retain that shared pivot (do not independently recenter). MeshPart creation may internally center mesh bounds: preserve vertex positions using EditableMesh resource semantics or compensate by the chunk bounds center if the import mechanism recenters. Compare resulting world AABB to exported placement bounds before acceptance. No guessed asset IDs.

Geometry file: assets/production/world-slice/world-slice.mesh.json. Placements use actual Roblox world coordinates with previewWorldOrigin [0,2,1410] inside Greenwood. Blender/GLB composition remains around local origin for editing; the JSON already includes that offset, so do not add it again. This is an opt-in art preview requiring visual overlap/occlusion review against native Greenwood, not a production replacement. All imported presentation parts must remain anchored, CanCollide=false, CanTouch=false, CanQuery=false. Existing game colliders, travel gates and server authority remain unchanged. Blender preview stage is excluded from JSON/GLB export. Runtime import and Studio visual acceptance are pending controller evidence.

## Server/client separation (supersedes v2 invocation ordering)

WorldQualitySlice runs only on a standalone Memory Studio server. It creates source-derived collision without requiring client-only imported art. The controller must validate the packaged dataset SHA against WorldQualityAssets.sourceMeshSha256 before invocation; the module validates its canonical generated collision data, not client requests.

```luau
local handle = require(game.ServerScriptService.Server.Services.WorldQualitySlice)(workspace.GuildborneWorld)
-- handle.colliders == 413; handle.disabledDecorationPhysics counts native decorations.
-- handle.sourceMeshSha256 identifies the canonical mesh source.
-- handle.reviewedArt is a recursively frozen COPY:
-- {sourceMeshSha256 = string, expectedArt = {name, meshId, position, rotation}[]}
handle.destroy()
```

Controller-owned preview code may copy reviewedArt into preview attributes/modules for local validation. No remotes or client approval are involved. The handle itself is mutable for lifecycle bookkeeping; the reviewedArt value and its nested tables are frozen copies of canonical data.

Server disables/restores CanCollide, CanQuery and CanTouch only for direct Greenwood Parts named Trunk/Canopy. It never reads or writes native decoration Transparency. The visible StableApron is a new owned ground support, removed on teardown. Idempotency, failure cleanup and refusal to replace an unowned collision folder remain enforced.

Controller client integration owns imported art validation and local decoration visibility after successful import, restoring LocalTransparencyModifier on cleanup. Import beneath GuildborneWorld or use explicit handle references; do not rely on the historical workspace.QualityArt_DatasetN path matching GuildborneWorld.QualitySourceArt. Collision initialization does not certify client art readiness. Controller must gate preview readiness on both collision success and actual local import success.

Source SHA256 remains 634a1067f4291d324f09b7b8d7cdcbb2aea748e251701ce6f57dfbc00c37a26d. The budget-corrected export has 27 chunks and 85 expected art placements. Collider geometry is unchanged; import the new JSON together with its regenerated WorldQualityAssets module and collision.json. Rebuild controller metadata and hash gates from this revision. Studio behavior remains pending controller verification.

## Explicit chunk centering correction

The runtime importer must subtract each chunk original bounds center from vertices before AddVertex, retain that original center separately, and apply placement * originalCenter exactly once. Do not rely on implicit CreateMeshPartAsync recentering. The original shared-pivot JSON and center-adjusted expectedArt remain unchanged. See IMPORTER_CENTER_FIX.md for the precise controller-owned change and diagnostic evidence.
