# Goblin asset native route decision — 2026-10-21

Use local mesh data -> EditableMesh -> MeshPart plus EditableImage-backed
SurfaceAppearance for the first bounded equipment fit/material preview. The
actual capability probe succeeded in owned Studio
`f291dbaa-f592-422b-adc2-cf15a90e0173`, Guildborne_PartyPresentationLab.rbxlx,
Edit mode, PlaceId0/GameId0, normal ServerBootstrap disabled, runtime lab absent.

`capability-probe.luau` was executed once via Studio MCP in Edit. The exact returned
JSON text is copied into `observed-result.json`; it is an observation record,
not a subprocess receipt or a complete raw MCP envelope. One triangle with
assigned UVs became a MeshPart. Four4x4 images passed exact pixel-buffer readback,
and Color/Normal/Roughness/Metalness map properties read back as EditableImage
object content after CreateSurfaceAppearanceAsync. Six UV records include the
mesh's existing/default UV records; this is not a claim of six authored corners.

All seven tracked objects received successful Destroy calls; tracked references
are zero and Workspace child count stayed2. None was parented into the DataModel.
This is API capability/cleanup evidence, not visible render verification, memory
profiling, actual Goblin import, garment fit, persistence, FBX/GLB importer
compatibility, production replication or human visual acceptance. No upload,
publication, asset-ID creation or access expansion was performed.

## Worker data and controller integration

S18 remains the sole writer of its assigned Goblin assets and export recipes.
Supply exact hashes, explicit Blender-to-Roblox axes/units, grip transform,
positions/triangles, per-corner UVs/normals/material indices and actual texture
files with channel mappings. Preserve original2K source maps. Any reduced native
preview derivative needs an explicit filename/resolution/hash and fidelity label.
Texture memory/resolution capability at asset scale is still untested.

The current tools/import_quality_meshes.py generic validator is face-color based;
it does not accept/validate this proposed UV/PBR extension. Controller must
implement/review a bounded loader without silently dropping maps. Do not ask S18
to edit shared loader/runtime code or acquire a Studio slot. First freeze and
review one sword export; then actual native geometry/UV/material inspection and
R6/preview grip, motion and exact-restore checks. Generated unskinned outfits
remain static assets until rigid segmentation or skinning/deformation is proven.

## Separate final import route

Current official Importer documentation supports FBX/glTF meshes with PBR and
offers Upload to Roblox (default on). Turning it off is documented as avoiding
adding the model to inventory; that wording alone is not a proof that no child
mesh/texture network upload occurs. Importer fidelity and save/reopen behavior
must therefore be checked separately from this in-memory route. The connected
Studio MCP has no dedicated local-FBX-import tool, and native computer UI control
is unavailable in this tool session. Do not pretend the final import was done or
that manual UI/upload is mandatory for the local geometry test.

Official sources checked:
- https://create.roblox.com/docs/reference/engine/classes/AssetService#CreateSurfaceAppearanceAsync
- https://create.roblox.com/docs/reference/engine/classes/EditableImage
- https://create.roblox.com/docs/reference/engine/classes/SurfaceAppearance
- https://create.roblox.com/docs/studio/importer

Controller releases quality-slice-integration after saving this decision.
S18 keeps its independent asset/Blender leases until its own stopped-process
handoff. No runtime/catalog/schema edits or outfit wearability are accepted here.

Independent read-only reviewer `/root/r6_preflight` approved this source/result
and bounded interpretation for archive, with no blocking issue. Seven-resource
accounting, reverse cleanup, full pixel-buffer comparisons and no-DataModel
parenting match the observation. Future reusable loader should additionally guard
RunService:IsStudio()/IsRunning(); this one-off script's Edit identity was checked
externally by the controller, while its inline guard checks only PlaceId/GameId0.
